<?php

namespace App\Services;

use App\Models\BonusTransaction;
use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Ticket;
use App\Models\Reservation\ReservationPayment;
use App\Models\Reservation\TicketReservation;
use App\Models\WalletTransaction;
use Carbon\Carbon;
use Exception;
use App\Services\Payments\PaymentGatewayRegistry;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class TicketReservationService
{
    public function __construct(
        private CheckoutFundingAllocatorService $fundingAllocator,
        private WalletService $walletService,
        private BonusWalletService $bonusWalletService,
        private PaymentGatewayRegistry $paymentGatewayRegistry,
        private ReservationBookingConversionService $reservationBookingConversionService,
        private TicketPriceScheduleService $ticketPriceScheduleService,
        private EventTreasuryService $eventTreasuryService
    ) {
    }

    public function createReservation(Customer $customer, array $payload): TicketReservation
    {
        $ticket = Ticket::with('event')->findOrFail((int) $payload['ticket_id']);
        $event = $ticket->event;
        if (!$event instanceof Event) {
            throw new Exception('Event not found for selected ticket.');
        }

        $this->assertTicketEligibleForReservation($ticket, (int) $payload['quantity']);

        $quantity = (int) $payload['quantity'];
        $unitPrice = $this->resolveTicketUnitPrice($ticket);
        $totalAmount = round($unitPrice * $quantity, 2);
        $depositRequired = $this->resolveDepositRequired($ticket, $totalAmount);
        $requestedAmount = isset($payload['payment_amount'])
            ? round((float) $payload['payment_amount'], 2)
            : $depositRequired;

        if ($requestedAmount < $depositRequired) {
            throw new Exception('Initial payment must cover the required deposit.');
        }

        if ($requestedAmount > $totalAmount) {
            throw new Exception('Initial payment cannot exceed the reservation total.');
        }

        $fundingPlan = $this->resolveFundingPlan($customer, $requestedAmount, $payload);
        $this->assertFundingCompleteness(
            $fundingPlan,
            (string) ($this->resolveGatewayDescriptor((string) ($payload['gateway'] ?? 'mixed'))['gateway'] ?? 'mixed')
        );

        $reservationCode = 'RSV-' . strtoupper(Str::random(10));
        $capture = $this->captureFunding(
            $customer,
            $fundingPlan,
            $payload['stripe_payment_method_id'] ?? null,
            'reservation_' . $reservationCode,
            'Reservation ' . $reservationCode,
            [
                'reservation_code' => $reservationCode,
                'ticket_id' => $ticket->id,
                'event_id' => $event->id,
            ]
        );

        return DB::transaction(function () use ($customer, $ticket, $event, $quantity, $unitPrice, $totalAmount, $depositRequired, $requestedAmount, $fundingPlan, $reservationCode, $payload, $capture) {
            $this->decrementTicketInventory($ticket, $quantity);

            $reservation = TicketReservation::create([
                'customer_id' => $customer->id,
                'event_id' => $event->id,
                'ticket_id' => $ticket->id,
                'reservation_code' => $reservationCode,
                'quantity' => $quantity,
                'reserved_unit_price' => $unitPrice,
                'total_amount' => $totalAmount,
                'deposit_required' => $depositRequired,
                'amount_paid' => $requestedAmount,
                'remaining_balance' => round($totalAmount - $requestedAmount, 2),
                'deposit_type' => $ticket->reservation_deposit_type,
                'deposit_value' => $ticket->reservation_deposit_value,
                'minimum_installment_amount' => $ticket->reservation_min_installment_amount,
                'final_due_date' => $ticket->reservation_final_due_date,
                'expires_at' => $this->resolveReservationExpiry($ticket, $event),
                'event_date' => $payload['event_date'] ?? $event->start_date,
                'status' => round($totalAmount - $requestedAmount, 2) <= 0 ? 'completed' : 'active',
                'payment_method' => $fundingPlan['payment_method'],
                'fname' => $payload['fname'] ?? $customer->fname,
                'lname' => $payload['lname'] ?? $customer->lname,
                'email' => $payload['email'] ?? $customer->email,
                'phone' => $payload['phone'] ?? $customer->phone,
                'country' => $payload['country'] ?? $customer->country,
                'state' => $payload['state'] ?? $customer->state,
                'city' => $payload['city'] ?? $customer->city,
                'zip_code' => $payload['zip_code'] ?? $customer->zip_code,
                'address' => $payload['address'] ?? $customer->address,
            ]);

            $this->storePaymentRows($reservation, $capture, $fundingPlan, 'initial');
            $this->eventTreasuryService->syncReservationRevenue($reservation->fresh(['event', 'payments']));

            if ($reservation->status === 'completed') {
                $this->reservationBookingConversionService->convert($reservation);
            }

            return $reservation->fresh(['ticket', 'event', 'payments', 'bookings.paymentAllocations']);
        });
    }

    public function payReservation(Customer $customer, TicketReservation $reservation, array $payload): TicketReservation
    {
        if ((int) $reservation->customer_id !== (int) $customer->id) {
            throw new Exception('Reservation does not belong to the authenticated customer.');
        }

        if (!in_array($reservation->status, ['active'], true)) {
            throw new Exception('Only active reservations can receive payments.');
        }

        if ($reservation->expires_at && $reservation->expires_at->isPast()) {
            throw new Exception('This reservation has already expired.');
        }

        $paymentAmount = round((float) ($payload['payment_amount'] ?? 0), 2);
        if ($paymentAmount <= 0) {
            throw new Exception('Payment amount must be positive.');
        }

        if ($paymentAmount > (float) $reservation->remaining_balance) {
            throw new Exception('Payment amount cannot exceed the remaining balance.');
        }

        $minimumInstallment = (float) ($reservation->minimum_installment_amount ?? 0);
        if ($minimumInstallment > 0 && $paymentAmount < (float) $reservation->remaining_balance && $paymentAmount < $minimumInstallment) {
            throw new Exception('Payment amount does not meet the minimum installment.');
        }

        $fundingPlan = $this->resolveFundingPlan($customer, $paymentAmount, $payload);
        $this->assertFundingCompleteness(
            $fundingPlan,
            (string) ($this->resolveGatewayDescriptor((string) ($payload['gateway'] ?? 'mixed'))['gateway'] ?? 'mixed')
        );

        $capture = $this->captureFunding(
            $customer,
            $fundingPlan,
            $payload['stripe_payment_method_id'] ?? null,
            'reservation_installment_' . $reservation->reservation_code . '_' . Str::uuid(),
            'Reservation installment ' . $reservation->reservation_code,
            [
                'reservation_code' => $reservation->reservation_code,
                'reservation_id' => $reservation->id,
            ]
        );

        return DB::transaction(function () use ($reservation, $paymentAmount, $fundingPlan, $capture) {
            $reservation->amount_paid = round((float) $reservation->amount_paid + $paymentAmount, 2);
            $reservation->remaining_balance = round((float) $reservation->total_amount - (float) $reservation->amount_paid, 2);
            $reservation->payment_method = $fundingPlan['payment_method'];
            if ($reservation->remaining_balance <= 0) {
                $reservation->status = 'completed';
                $reservation->remaining_balance = 0;
            }
            $reservation->save();

            $this->storePaymentRows($reservation, $capture, $fundingPlan, 'installment');
            $this->eventTreasuryService->syncReservationRevenue($reservation->fresh(['event', 'payments']));

            if ($reservation->status === 'completed') {
                $this->reservationBookingConversionService->convert($reservation);
            }

            return $reservation->fresh(['ticket', 'event', 'payments', 'bookings.paymentAllocations']);
        });
    }

    public function previewCreateReservation(Customer $customer, array $payload): array
    {
        $ticket = Ticket::with('event')->findOrFail((int) $payload['ticket_id']);
        $event = $ticket->event;
        if (!$event instanceof Event) {
            throw new Exception('Event not found for selected ticket.');
        }

        $quantity = max(1, (int) ($payload['quantity'] ?? 1));
        $this->assertTicketEligibleForReservation($ticket, $quantity);

        $unitPrice = $this->resolveTicketUnitPrice($ticket);
        $totalAmount = round($unitPrice * $quantity, 2);
        $depositRequired = $this->resolveDepositRequired($ticket, $totalAmount);
        $requestedAmount = isset($payload['payment_amount'])
            ? round((float) $payload['payment_amount'], 2)
            : $depositRequired;

        if ($requestedAmount < $depositRequired) {
            throw new Exception('Initial payment must cover the required deposit.');
        }

        if ($requestedAmount > $totalAmount) {
            throw new Exception('Initial payment cannot exceed the reservation total.');
        }

        return [
            'reservation' => [
                'ticket_id' => (int) $ticket->id,
                'event_id' => (int) $event->id,
                'unit_price' => $unitPrice,
                'quantity' => $quantity,
                'total_amount' => $totalAmount,
                'deposit_required' => $depositRequired,
                'requested_amount' => $requestedAmount,
                'minimum_installment_amount' => $ticket->reservation_min_installment_amount !== null
                    ? round((float) $ticket->reservation_min_installment_amount, 2)
                    : null,
                'final_due_date' => $ticket->reservation_final_due_date,
            ],
            'payment_summary' => $this->buildFundingPreview($customer, $requestedAmount, $payload),
        ];
    }

    public function previewReservationPayment(Customer $customer, TicketReservation $reservation, array $payload): array
    {
        if ((int) $reservation->customer_id !== (int) $customer->id) {
            throw new Exception('Reservation does not belong to the authenticated customer.');
        }

        if (!in_array($reservation->status, ['active'], true)) {
            throw new Exception('Only active reservations can receive payments.');
        }

        if ($reservation->expires_at && $reservation->expires_at->isPast()) {
            throw new Exception('This reservation has already expired.');
        }

        $paymentAmount = round((float) ($payload['payment_amount'] ?? 0), 2);
        if ($paymentAmount <= 0) {
            throw new Exception('Payment amount must be positive.');
        }

        if ($paymentAmount > (float) $reservation->remaining_balance) {
            throw new Exception('Payment amount cannot exceed the remaining balance.');
        }

        $minimumInstallment = (float) ($reservation->minimum_installment_amount ?? 0);
        if ($minimumInstallment > 0 && $paymentAmount < (float) $reservation->remaining_balance && $paymentAmount < $minimumInstallment) {
            throw new Exception('Payment amount does not meet the minimum installment.');
        }

        return [
            'reservation' => [
                'id' => (int) $reservation->id,
                'remaining_balance' => round((float) $reservation->remaining_balance, 2),
                'requested_amount' => $paymentAmount,
                'minimum_installment_amount' => $minimumInstallment > 0 ? round($minimumInstallment, 2) : null,
                'final_due_date' => $reservation->final_due_date,
            ],
            'payment_summary' => $this->buildFundingPreview($customer, $paymentAmount, $payload),
        ];
    }

    public function expireOverdueReservations(?Carbon $now = null): int
    {
        $now = $now ?: Carbon::now();
        if (!Schema::hasTable('ticket_reservations')) {
            return 0;
        }

        $expiredCount = 0;

        TicketReservation::query()
            ->where('status', 'active')
            ->whereNotNull('expires_at')
            ->where('expires_at', '<', $now)
            ->chunkById(100, function ($reservations) use (&$expiredCount) {
                foreach ($reservations as $reservation) {
                    DB::transaction(function () use ($reservation, &$expiredCount) {
                        $ticket = Ticket::find($reservation->ticket_id);
                        if ($ticket && $ticket->ticket_available_type === 'limited') {
                            $ticket->ticket_available = (int) $ticket->ticket_available + (int) $reservation->quantity;
                            $ticket->save();
                        }

                        $reservation->status = 'expired';
                        $reservation->save();
                        $expiredCount++;
                    });
                }
            });

        return $expiredCount;
    }

    private function assertTicketEligibleForReservation(Ticket $ticket, int $quantity): void
    {
        if ((int) $ticket->reservation_enabled !== 1) {
            throw new Exception('This ticket is not eligible for reservation.');
        }

        if ($ticket->pricing_type !== 'normal') {
            throw new Exception('Reservations are currently available only for normal tickets.');
        }

        if ($quantity <= 0) {
            throw new Exception('Reservation quantity must be at least 1.');
        }

        if ($ticket->ticket_available_type === 'limited' && (int) $ticket->ticket_available < $quantity) {
            throw new Exception('Insufficient ticket inventory for reservation.');
        }
    }

    private function resolveTicketUnitPrice(Ticket $ticket): float
    {
        $pricing = $this->ticketPriceScheduleService->resolveForTicket($ticket);

        return round((float) ($pricing['effective_price'] ?? ($ticket->f_price ?? $ticket->price ?? 0)), 2);
    }

    private function resolveDepositRequired(Ticket $ticket, float $totalAmount): float
    {
        $value = round((float) ($ticket->reservation_deposit_value ?? 0), 2);
        if (($ticket->reservation_deposit_type ?? null) === 'percentage') {
            return round(($totalAmount * $value) / 100, 2);
        }

        return min($totalAmount, $value);
    }

    private function resolveFundingPlan(Customer $customer, float $amount, array $payload): array
    {
        $walletBalance = (float) $this->walletService->getOrCreateWallet($customer)->balance;
        $bonusBalance = (float) $this->bonusWalletService->getOrCreateWallet($customer)->balance;
        $gatewayDescriptor = $this->resolveGatewayDescriptor((string) ($payload['gateway'] ?? 'mixed'));
        $fundingPlan = $this->fundingAllocator->allocate($amount, [
            'gateway' => (string) ($gatewayDescriptor['gateway'] ?? strtolower((string) ($payload['gateway'] ?? 'mixed'))),
            'wallet_balance' => $walletBalance,
            'bonus_balance' => $bonusBalance,
            'apply_wallet_balance' => filter_var($payload['apply_wallet_balance'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'apply_bonus_balance' => filter_var($payload['apply_bonus_balance'] ?? false, FILTER_VALIDATE_BOOLEAN),
        ]);

        return array_merge(
            $fundingPlan,
            $this->buildGatewayContractForFundingPlan(
                (string) ($gatewayDescriptor['gateway'] ?? 'mixed'),
                $fundingPlan
            )
        );
    }

    private function buildFundingPreview(Customer $customer, float $amount, array $payload): array
    {
        $walletBalance = (float) $this->walletService->getOrCreateWallet($customer)->balance;
        $bonusBalance = (float) $this->bonusWalletService->getOrCreateWallet($customer)->balance;
        $requestedGateway = $this->resolveGatewayDescriptor((string) ($payload['gateway'] ?? 'stripe'));
        $fundingPlan = $this->fundingAllocator->allocate($amount, [
            'gateway' => (string) ($requestedGateway['gateway'] ?? strtolower((string) ($payload['gateway'] ?? 'stripe'))),
            'wallet_balance' => $walletBalance,
            'bonus_balance' => $bonusBalance,
            'apply_wallet_balance' => filter_var($payload['apply_wallet_balance'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'apply_bonus_balance' => filter_var($payload['apply_bonus_balance'] ?? false, FILTER_VALIDATE_BOOLEAN),
        ]);

        $hasSelectedCard = !empty($payload['stripe_payment_method_id']);
        $effectiveGateway = $this->resolveGatewayDescriptor((string) ($fundingPlan['payment_method'] ?? ($requestedGateway['gateway'] ?? 'stripe')));

        return array_merge($fundingPlan, [
            'available_wallet_balance' => round($walletBalance, 2),
            'available_bonus_balance' => round($bonusBalance, 2),
            'has_selected_card' => $hasSelectedCard,
            'can_submit' => !$fundingPlan['requires_card'] || $hasSelectedCard,
            'requested_gateway' => $requestedGateway['gateway'] ?? null,
            'gateway' => $effectiveGateway['gateway'] ?? null,
            'gateway_family' => $effectiveGateway['gateway_family'] ?? null,
            'verification_strategy' => $effectiveGateway['verification_strategy'] ?? null,
        ]);
    }

    /**
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    private function resolveGatewayDescriptor(string $gateway): array
    {
        return app(EventPaymentVerificationService::class)->describeGateway($gateway);
    }

    private function assertFundingCompleteness(array $fundingPlan, string $gateway): void
    {
        if ($gateway === 'wallet' && !$fundingPlan['is_fully_covered']) {
            throw new Exception('Insufficient wallet balance.');
        }

        if ($gateway === 'bonus' && !$fundingPlan['is_fully_covered']) {
            throw new Exception('Insufficient bonus balance.');
        }

        if ($fundingPlan['requires_card']) {
            return;
        }
    }

    private function captureFunding(
        Customer $customer,
        array $fundingPlan,
        ?string $stripePaymentMethodId,
        string $reference,
        string $description,
        array $metadata
    ): array {
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
                    'reservation_bonus',
                    $reference,
                    'reservation_bonus_' . $reference
                );
            }

            if (($fundingPlan['wallet_amount'] ?? 0) > 0) {
                $captured['wallet'] = $this->walletService->debit(
                    $customer,
                    (float) $fundingPlan['wallet_amount'],
                    'reservation_wallet',
                    $reference,
                    'reservation_wallet_' . $reference
                );
            }

            if (($fundingPlan['card_total_charge'] ?? 0) > 0) {
                if (empty($stripePaymentMethodId)) {
                    throw new Exception('A saved card is required to complete the remaining balance.');
                }

                $captured['stripe'] = $this->paymentGatewayRegistry->chargeSavedCard(
                    (string) ($fundingPlan['requested_gateway'] ?? $fundingPlan['payment_method'] ?? 'stripe'),
                    $customer,
                    (float) $fundingPlan['card_total_charge'],
                    'DOP',
                    $description,
                    $stripePaymentMethodId,
                    $metadata
                );
            }
        } catch (\Throwable $exception) {
            $this->compensateFunding($customer, $reference, $captured);
            throw $exception;
        }

        return $captured;
    }

    private function compensateFunding(Customer $customer, string $reference, array $captured): void
    {
        try {
            if ($captured['wallet'] instanceof WalletTransaction) {
                $this->walletService->credit(
                    $customer,
                    (float) $captured['wallet']->amount,
                    'reservation_wallet_reversal',
                    $reference,
                    'reservation_wallet_reversal_' . $reference
                );
            }

            if ($captured['bonus'] instanceof BonusTransaction) {
                $this->bonusWalletService->credit(
                    $customer,
                    (float) $captured['bonus']->amount,
                    'reservation_bonus_reversal',
                    $reference,
                    'reservation_bonus_reversal_' . $reference,
                    'reversal'
                );
            }
        } catch (\Throwable $rollbackException) {
            report($rollbackException);
        }
    }

    private function storePaymentRows(TicketReservation $reservation, array $capture, array $fundingPlan, string $groupPrefix): void
    {
        $paymentGroup = $groupPrefix . '_' . Str::uuid();

        $rows = [
            [
                'source_type' => 'bonus_wallet',
                'amount' => (float) ($fundingPlan['bonus_amount'] ?? 0),
                'fee_amount' => 0.0,
                'reference_type' => 'bonus_transaction',
                'reference_id' => $capture['bonus']?->id,
            ],
            [
                'source_type' => 'wallet',
                'amount' => (float) ($fundingPlan['wallet_amount'] ?? 0),
                'fee_amount' => 0.0,
                'reference_type' => 'wallet_transaction',
                'reference_id' => $capture['wallet']?->id,
            ],
            [
                'source_type' => 'card',
                'amount' => (float) ($fundingPlan['card_amount'] ?? 0),
                'fee_amount' => (float) ($fundingPlan['card_processing_fee'] ?? 0),
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => is_object($capture['stripe']) ? ($capture['stripe']->id ?? null) : null,
            ],
        ];

        foreach ($rows as $row) {
            if ($row['amount'] <= 0 && $row['fee_amount'] <= 0) {
                continue;
            }

            ReservationPayment::create([
                'reservation_id' => $reservation->id,
                'payment_group' => $paymentGroup,
                'source_type' => $row['source_type'],
                'amount' => $row['amount'],
                'fee_amount' => $row['fee_amount'],
                'total_amount' => round($row['amount'] + $row['fee_amount'], 2),
                'reference_type' => $row['reference_type'],
                'reference_id' => $row['reference_id'],
                'status' => 'completed',
                'paid_at' => now(),
                'meta' => $this->buildPersistedPaymentMeta($fundingPlan, $row),
            ]);
        }
    }

    /**
     * @return array<string, string|null>
     */
    private function buildGatewayContractForFundingPlan(string $requestedGateway, array $fundingPlan): array
    {
        $effectiveGateway = (string) ($fundingPlan['payment_method'] ?? $requestedGateway);

        return app(EventPaymentVerificationService::class)->buildGatewayContract(
            $requestedGateway,
            $effectiveGateway
        );
    }

    /**
     * @param array{source_type:string,amount:float,fee_amount:float,reference_type:?string,reference_id:mixed} $row
     * @return array<string, mixed>
     */
    private function buildPersistedPaymentMeta(array $fundingPlan, array $row): array
    {
        $meta = $this->buildGatewayContractForFundingPlan(
            (string) ($fundingPlan['requested_gateway'] ?? $fundingPlan['gateway'] ?? $fundingPlan['payment_method'] ?? 'mixed'),
            $fundingPlan
        );

        $sourceGatewayDescriptor = $this->resolveGatewayDescriptor($this->resolveSourceGateway($fundingPlan, (string) $row['source_type']));

        return array_merge($meta, [
            'source_type' => $row['source_type'],
            'source_gateway' => $sourceGatewayDescriptor['gateway'] ?? null,
            'source_gateway_family' => $sourceGatewayDescriptor['gateway_family'] ?? null,
            'source_verification_strategy' => $sourceGatewayDescriptor['verification_strategy'] ?? null,
            'source_amount' => round((float) ($row['amount'] ?? 0), 2),
            'source_fee_amount' => round((float) ($row['fee_amount'] ?? 0), 2),
        ]);
    }

    private function resolveSourceGateway(array $fundingPlan, string $sourceType): string
    {
        return match ($sourceType) {
            'bonus_wallet' => 'bonus',
            'wallet' => 'wallet',
            'card' => (($fundingPlan['mode'] ?? null) === 'mixed' || ($fundingPlan['requested_gateway'] ?? null) === 'mixed')
                ? 'mixed'
                : 'stripe',
            default => (string) ($fundingPlan['gateway'] ?? $fundingPlan['payment_method'] ?? 'mixed'),
        };
    }

    private function resolveReservationExpiry(Ticket $ticket, Event $event): ?Carbon
    {
        if (!empty($ticket->reservation_final_due_date)) {
            return Carbon::parse($ticket->reservation_final_due_date);
        }

        if (!empty($event->start_date)) {
            return Carbon::parse($event->start_date)->endOfDay();
        }

        return null;
    }

    private function decrementTicketInventory(Ticket $ticket, int $quantity): void
    {
        if ($ticket->ticket_available_type !== 'limited') {
            return;
        }

        $ticket->ticket_available = (int) $ticket->ticket_available - $quantity;
        $ticket->save();
    }
}
