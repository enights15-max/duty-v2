<?php

namespace App\Services;

use App\Exceptions\ReviewFlowException;
use App\Models\Artist;
use App\Models\ArtistTip;
use App\Models\Customer;
use App\Models\Event\Booking;
use App\Models\PaymentMethod;
use App\Models\WalletTransaction;
use Carbon\Carbon;
use App\Services\Payments\PaymentGatewayRegistry;

class ArtistTipService
{
    public function __construct(
        protected WalletService $walletService,
        protected PaymentGatewayRegistry $paymentGatewayRegistry
    ) {
    }

    public function submit(Customer $customer, Artist $artist, array $payload): ArtistTip
    {
        $booking = $this->resolveEligibleBooking($customer, $artist, (int) ($payload['booking_id'] ?? 0));
        $amount = round((float) ($payload['amount'] ?? 0), 2);
        if ($amount <= 0) {
            throw new ReviewFlowException('Tip amount must be greater than zero.', 422);
        }

        $wallet = $this->walletService->getOrCreateWallet($customer);
        $walletAmount = !empty($payload['apply_wallet_balance'])
            ? min((float) $wallet->balance, $amount)
            : 0.0;
        $cardAmount = round($amount - $walletAmount, 2);

        $stripePaymentMethodId = (string) ($payload['stripe_payment_method_id'] ?? '');
        if ($cardAmount > 0 && $stripePaymentMethodId === '') {
            throw new ReviewFlowException('A saved card is required to cover the remaining tip balance.', 422);
        }

        if ($stripePaymentMethodId !== '' && !$this->paymentMethodBelongsToCustomer($customer, $stripePaymentMethodId)) {
            throw new ReviewFlowException('Selected card is not available for this customer.', 403);
        }

        $tip = ArtistTip::create([
            'customer_id' => $customer->id,
            'artist_id' => $artist->id,
            'booking_id' => $booking->id,
            'event_id' => $booking->event_id,
            'amount' => $amount,
            'wallet_amount' => $walletAmount,
            'card_amount' => $cardAmount,
            'currency' => 'DOP',
            'status' => 'processing',
            'meta' => [
                'event_title' => $this->eventTitle($booking),
                'artist_name' => $artist->name,
            ],
        ]);

        $captured = [
            'wallet' => null,
            'artist_credit' => null,
            'stripe' => null,
        ];

        try {
            if ($walletAmount > 0) {
                $captured['wallet'] = $this->walletService->debit(
                    $customer,
                    $walletAmount,
                    'artist_tip_wallet',
                    (string) $tip->id,
                    'artist_tip_wallet_' . $tip->id
                );
            }

            $captured['artist_credit'] = $this->walletService->credit(
                $artist,
                $amount,
                'artist_tip_credit',
                (string) $tip->id,
                'artist_tip_credit_' . $tip->id
            );

            if ($cardAmount > 0) {
                $captured['stripe'] = $this->paymentGatewayRegistry->chargeSavedCard(
                    $cardAmount > 0 && $walletAmount > 0 ? 'mixed' : 'stripe',
                    $customer,
                    $cardAmount,
                    'DOP',
                    'Artist Tip #' . $tip->id,
                    $stripePaymentMethodId,
                    [
                        'purpose' => 'artist_tip',
                        'tip_id' => (string) $tip->id,
                        'artist_id' => (string) $artist->id,
                        'booking_id' => (string) $booking->id,
                        'event_id' => (string) $booking->event_id,
                    ]
                );
            }

            $gatewayDescriptor = $this->resolveGatewayDescriptor($walletAmount, $cardAmount);

            $tip->forceFill([
                'status' => 'completed',
                'customer_wallet_transaction_id' => $captured['wallet']?->id,
                'artist_wallet_transaction_id' => $captured['artist_credit']?->id,
                'stripe_payment_intent_id' => is_object($captured['stripe']) ? ($captured['stripe']->id ?? null) : null,
                'completed_at' => now(),
                'meta' => array_merge($tip->meta ?? [], [
                    'payment_summary' => [
                        'amount' => $amount,
                        'wallet_amount' => $walletAmount,
                        'card_amount' => $cardAmount,
                        'mode' => $gatewayDescriptor['gateway'],
                        'gateway' => $gatewayDescriptor['gateway'],
                        'gateway_family' => $gatewayDescriptor['gateway_family'],
                        'verification_strategy' => $gatewayDescriptor['verification_strategy'],
                    ],
                ]),
            ])->save();

            return $tip->fresh();
        } catch (\Throwable $exception) {
            $this->compensate($customer, $artist, $tip, $captured, $exception);
            throw $exception;
        }
    }

    private function compensate(Customer $customer, Artist $artist, ArtistTip $tip, array $captured, \Throwable $exception): void
    {
        try {
            if ($captured['artist_credit'] instanceof WalletTransaction) {
                $this->walletService->debit(
                    $artist,
                    (float) $captured['artist_credit']->amount,
                    'artist_tip_credit_reversal',
                    (string) $tip->id,
                    'artist_tip_credit_reversal_' . $tip->id
                );
            }

            if ($captured['wallet'] instanceof WalletTransaction) {
                $this->walletService->credit(
                    $customer,
                    (float) $captured['wallet']->amount,
                    'artist_tip_wallet_reversal',
                    (string) $tip->id,
                    'artist_tip_wallet_reversal_' . $tip->id
                );
            }
        } catch (\Throwable $rollbackException) {
            report($rollbackException);
        }

        $tip->forceFill([
            'status' => 'failed',
            'meta' => array_merge($tip->meta ?? [], [
                'failure_reason' => $exception->getMessage(),
            ]),
        ])->save();
    }

    private function paymentMethodBelongsToCustomer(Customer $customer, string $paymentMethodId): bool
    {
        return PaymentMethod::forActor($customer)
            ->where('stripe_payment_method_id', $paymentMethodId)
            ->where('status', 'active')
            ->exists();
    }

    /**
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    private function resolveGatewayDescriptor(float $walletAmount, float $cardAmount): array
    {
        $gateway = $cardAmount > 0 && $walletAmount > 0
            ? 'mixed'
            : ($cardAmount > 0 ? 'card' : 'wallet');

        return app(EventPaymentVerificationService::class)->describeGateway($gateway);
    }

    private function resolveEligibleBooking(Customer $customer, Artist $artist, int $bookingId): Booking
    {
        $booking = Booking::query()
            ->with(['evnt.lineups.artist', 'evnt.artists'])
            ->where('id', $bookingId)
            ->where('customer_id', $customer->id)
            ->where('paymentStatus', 'Completed')
            ->first();

        if (!$booking || !$booking->evnt || !$this->eventHasConcluded($booking->evnt)) {
            throw new ReviewFlowException('Only attendees of concluded events can tip this artist.', 403);
        }

        $inLineup = $booking->evnt->lineups->contains(fn ($lineup) => (int) $lineup->artist_id === (int) $artist->id);
        $inLegacyArtistPivot = $booking->evnt->artists->contains(fn ($eventArtist) => (int) $eventArtist->id === (int) $artist->id);

        if (!$inLineup && !$inLegacyArtistPivot) {
            throw new ReviewFlowException('This artist is not associated with the selected event.', 422);
        }

        return $booking;
    }

    private function eventHasConcluded($event): bool
    {
        $endAt = $this->eventEndAt($event);
        return $endAt !== null && $endAt->isPast();
    }

    private function eventEndAt($event): ?Carbon
    {
        if (!empty($event->end_date_time)) {
            return Carbon::parse($event->end_date_time);
        }

        if (!empty($event->end_date) && !empty($event->end_time)) {
            return Carbon::parse($event->end_date . ' ' . $event->end_time);
        }

        if (!empty($event->start_date) && !empty($event->start_time)) {
            return Carbon::parse($event->start_date . ' ' . $event->start_time);
        }

        return null;
    }

    private function eventTitle(Booking $booking): string
    {
        return $booking->evnt?->information?->title
            ?? 'Event';
    }
}
