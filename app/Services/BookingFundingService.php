<?php

namespace App\Services;

use App\Models\BonusTransaction;
use App\Models\Customer;
use App\Models\Event\Booking;
use App\Models\Event\BookingPaymentAllocation;
use App\Models\WalletTransaction;
use App\Services\Payments\PaymentGatewayRegistry;
use Exception;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class BookingFundingService
{
    public function __construct(
        private WalletService $walletService,
        private BonusWalletService $bonusWalletService,
        private PaymentGatewayRegistry $paymentGatewayRegistry
    ) {
    }

    /**
     * @param Collection<int, Booking> $bookings
     * @return array<string, mixed>
     */
    public function captureForBookings(
        Customer $customer,
        Collection $bookings,
        array $fundingPlan,
        ?string $stripePaymentMethodId,
        string $currencyCode
    ): array {
        if ($bookings->isEmpty()) {
            throw new Exception('No bookings available for funding.');
        }

        $orderReference = (string) ($bookings->first()->order_number ?: $bookings->first()->booking_id);
        $captured = [
            'bonus' => null,
            'wallet' => null,
            'stripe' => null,
        ];

        try {
            if (($fundingPlan['bonus_amount'] ?? 0) > 0) {
                $captured['bonus'] = $this->bonusWalletService->debit(
                    $customer,
                    (float) $fundingPlan['bonus_amount'],
                    'ticket_booking_bonus',
                    $orderReference,
                    'ticket_booking_bonus_' . $orderReference
                );
            }

            if (($fundingPlan['wallet_amount'] ?? 0) > 0) {
                $captured['wallet'] = $this->walletService->debit(
                    $customer,
                    (float) $fundingPlan['wallet_amount'],
                    'ticket_booking_wallet',
                    $orderReference,
                    'ticket_booking_wallet_' . $orderReference
                );
            }

            if (($fundingPlan['card_total_charge'] ?? 0) > 0) {
                if (empty($stripePaymentMethodId)) {
                    throw new Exception('A saved Stripe payment method is required to cover the remaining balance.');
                }

                $captured['stripe'] = $this->paymentGatewayRegistry->chargeSavedCard(
                    (string) ($fundingPlan['requested_gateway'] ?? $this->inferRequestedGateway($fundingPlan)),
                    $customer,
                    (float) $fundingPlan['card_total_charge'],
                    $currencyCode,
                    "Ticket Booking #{$orderReference}",
                    $stripePaymentMethodId,
                    [
                        'booking_id' => $bookings->first()->booking_id,
                        'order_number' => $orderReference,
                        'funding_mode' => (string) ($fundingPlan['mode'] ?? 'card'),
                    ]
                );
            }
        } catch (\Throwable $exception) {
            $this->compensate($customer, $orderReference, $captured);
            throw $exception;
        }

        $stripePaymentIntentId = is_object($captured['stripe']) ? ($captured['stripe']->id ?? null) : null;

        DB::transaction(function () use ($bookings, $fundingPlan, $captured) {
            BookingPaymentAllocation::whereIn('booking_id', $bookings->pluck('id')->all())->delete();

            $this->storeSourceAllocations(
                $bookings,
                $fundingPlan,
                'bonus_wallet',
                (float) ($fundingPlan['bonus_amount'] ?? 0),
                0.0,
                $captured['bonus']?->id,
                'bonus_transaction'
            );
            $this->storeSourceAllocations(
                $bookings,
                $fundingPlan,
                'wallet',
                (float) ($fundingPlan['wallet_amount'] ?? 0),
                0.0,
                $captured['wallet']?->id,
                'wallet_transaction'
            );
            $this->storeSourceAllocations(
                $bookings,
                $fundingPlan,
                'card',
                (float) ($fundingPlan['card_amount'] ?? 0),
                (float) ($fundingPlan['card_processing_fee'] ?? 0),
                is_object($captured['stripe']) ? ($captured['stripe']->id ?? null) : null,
                'stripe_payment_intent'
            );
        });

        return [
            'bonus_transaction_id' => $captured['bonus']?->id,
            'wallet_transaction_id' => $captured['wallet']?->id,
            'stripe_payment_intent_id' => $stripePaymentIntentId,
        ];
    }

    private function compensate(Customer $customer, string $orderReference, array $captured): void
    {
        try {
            if ($captured['wallet'] instanceof WalletTransaction) {
                $this->walletService->credit(
                    $customer,
                    (float) $captured['wallet']->amount,
                    'ticket_booking_wallet_reversal',
                    $orderReference,
                    'ticket_booking_wallet_reversal_' . $orderReference
                );
            }

            if ($captured['bonus'] instanceof BonusTransaction) {
                $this->bonusWalletService->credit(
                    $customer,
                    (float) $captured['bonus']->amount,
                    'ticket_booking_bonus_reversal',
                    $orderReference,
                    'ticket_booking_bonus_reversal_' . $orderReference,
                    'reversal'
                );
            }
        } catch (\Throwable $rollbackException) {
            report($rollbackException);
        }
    }

    /**
     * @param Collection<int, Booking> $bookings
     */
    private function storeSourceAllocations(
        Collection $bookings,
        array $fundingPlan,
        string $sourceType,
        float $sourceAmount,
        float $feeAmount,
        ?string $referenceId,
        ?string $referenceType
    ): void {
        if ($sourceAmount <= 0 && $feeAmount <= 0) {
            return;
        }

        $amountParts = $this->splitAmountAcrossBookings($bookings, $sourceAmount);
        $feeParts = $this->splitAmountAcrossBookings($bookings, $feeAmount);

        foreach ($bookings as $index => $booking) {
            $amount = $amountParts[$index] ?? 0.0;
            $fee = $feeParts[$index] ?? 0.0;

            if ($amount <= 0 && $fee <= 0) {
                continue;
            }

            BookingPaymentAllocation::create([
                'booking_id' => $booking->id,
                'source_type' => $sourceType,
                'amount' => $amount,
                'fee_amount' => $fee,
                'total_amount' => round($amount + $fee, 2),
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'meta' => $this->buildPersistedAllocationMeta($fundingPlan, $sourceType, $amount, $fee),
            ]);
        }
    }

    /**
     * @param Collection<int, Booking> $bookings
     * @return array<int, float>
     */
    private function splitAmountAcrossBookings(Collection $bookings, float $amount): array
    {
        if ($amount <= 0) {
            return array_fill(0, $bookings->count(), 0.0);
        }

        $totalPrice = (float) $bookings->sum(fn (Booking $booking) => (float) $booking->price);
        if ($totalPrice <= 0) {
            $count = max(1, $bookings->count());
            $base = round($amount / $count, 2);
            $parts = array_fill(0, $count, $base);
            $parts[$count - 1] = round($amount - array_sum(array_slice($parts, 0, $count - 1)), 2);
            return $parts;
        }

        $parts = [];
        $allocated = 0.0;
        $lastIndex = $bookings->count() - 1;

        foreach ($bookings->values() as $index => $booking) {
            if ($index === $lastIndex) {
                $parts[$index] = round($amount - $allocated, 2);
                continue;
            }

            $ratio = ((float) $booking->price) / $totalPrice;
            $parts[$index] = round($amount * $ratio, 2);
            $allocated += $parts[$index];
        }

        return $parts;
    }

    /**
     * @return array<string, mixed>
     */
    private function buildPersistedAllocationMeta(array $fundingPlan, string $sourceType, float $amount, float $fee): array
    {
        $paymentVerification = app(EventPaymentVerificationService::class);
        $requestedGateway = (string) ($fundingPlan['requested_gateway'] ?? $this->inferRequestedGateway($fundingPlan));
        $effectiveGateway = (string) ($fundingPlan['gateway'] ?? $fundingPlan['payment_method'] ?? $requestedGateway);
        $sourceGateway = $this->resolveSourceGateway($fundingPlan, $sourceType);
        $sourceDescriptor = $paymentVerification->describeGateway($sourceGateway);

        return array_merge(
            $paymentVerification->buildGatewayContract($requestedGateway, $effectiveGateway),
            [
                'source_type' => $sourceType,
                'source_gateway' => $sourceDescriptor['gateway'] ?? null,
                'source_gateway_family' => $sourceDescriptor['gateway_family'] ?? null,
                'source_verification_strategy' => $sourceDescriptor['verification_strategy'] ?? null,
                'source_amount' => round($amount, 2),
                'source_fee_amount' => round($fee, 2),
            ]
        );
    }

    private function inferRequestedGateway(array $fundingPlan): string
    {
        $mode = (string) ($fundingPlan['mode'] ?? '');

        return match ($mode) {
            'wallet' => 'wallet',
            'bonus' => 'bonus',
            'mixed' => 'mixed',
            default => (string) ($fundingPlan['payment_method'] ?? 'stripe'),
        };
    }

    private function resolveSourceGateway(array $fundingPlan, string $sourceType): string
    {
        return match ($sourceType) {
            'bonus_wallet' => 'bonus',
            'wallet' => 'wallet',
            'card' => (($fundingPlan['mode'] ?? null) === 'mixed' || ($fundingPlan['requested_gateway'] ?? null) === 'mixed')
                ? 'mixed'
                : 'stripe',
            default => (string) ($fundingPlan['gateway'] ?? $fundingPlan['payment_method'] ?? 'stripe'),
        };
    }
}
