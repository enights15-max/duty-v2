<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Identity;
use App\Models\PlatformRevenueEvent;
use App\Models\TicketTransfer;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class PlatformRevenueService
{
    public function __construct(
        private FeeEngine $feeEngine
    ) {
    }

    public function record(array $attributes): ?PlatformRevenueEvent
    {
        if (!Schema::hasTable('platform_revenue_events')) {
            return null;
        }

        $idempotencyKey = (string) ($attributes['idempotency_key'] ?? '');
        if ($idempotencyKey !== '') {
            $existing = PlatformRevenueEvent::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existing) {
                return $existing;
            }
        }

        return PlatformRevenueEvent::query()->create([
            'idempotency_key' => $idempotencyKey !== '' ? $idempotencyKey : (string) Str::uuid(),
            'policy_id' => $attributes['policy_id'] ?? null,
            'operation_key' => $attributes['operation_key'],
            'reference_type' => $attributes['reference_type'] ?? null,
            'reference_id' => isset($attributes['reference_id']) ? (string) $attributes['reference_id'] : null,
            'booking_id' => $attributes['booking_id'] ?? null,
            'event_id' => $attributes['event_id'] ?? null,
            'ticket_id' => $attributes['ticket_id'] ?? null,
            'transfer_id' => $attributes['transfer_id'] ?? null,
            'actor_customer_id' => $attributes['actor_customer_id'] ?? null,
            'target_customer_id' => $attributes['target_customer_id'] ?? null,
            'owner_identity_id' => $attributes['owner_identity_id'] ?? null,
            'owner_identity_type' => $attributes['owner_identity_type'] ?? null,
            'organizer_id' => $attributes['organizer_id'] ?? null,
            'venue_id' => $attributes['venue_id'] ?? null,
            'artist_id' => $attributes['artist_id'] ?? null,
            'venue_identity_id' => $attributes['venue_identity_id'] ?? null,
            'gross_amount' => round((float) ($attributes['gross_amount'] ?? 0), 2),
            'fee_amount' => round((float) ($attributes['fee_amount'] ?? 0), 2),
            'net_amount' => round((float) ($attributes['net_amount'] ?? 0), 2),
            'total_charge_amount' => round((float) ($attributes['total_charge_amount'] ?? ($attributes['gross_amount'] ?? 0)), 2),
            'charged_to' => $attributes['charged_to'] ?? \App\Models\FeePolicy::CHARGED_TO_SELLER,
            'currency' => $attributes['currency'] ?? 'DOP',
            'status' => $attributes['status'] ?? 'completed',
            'metadata' => $attributes['metadata'] ?? null,
            'occurred_at' => $attributes['occurred_at'] ?? now(),
        ]);
    }

    public function recordPrimaryTicketSale(Booking|array $booking, array $context = []): ?PlatformRevenueEvent
    {
        $bookingId = data_get($booking, 'id');
        $eventId = data_get($booking, 'event_id');
        $event = $this->resolveEvent($booking, $eventId);
        $ownerContext = $this->resolveOwnerContext($event, $booking);

        return $this->record([
            'idempotency_key' => 'platform_revenue_primary_booking_' . $bookingId,
            'policy_id' => $context['policy_id'] ?? null,
            'operation_key' => FeeEngine::OP_PRIMARY_TICKET_SALE,
            'reference_type' => 'booking',
            'reference_id' => $bookingId,
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'ticket_id' => data_get($booking, 'ticket_id'),
            'actor_customer_id' => data_get($booking, 'customer_id'),
            'target_customer_id' => data_get($booking, 'customer_id'),
            'gross_amount' => (float) data_get($booking, 'price', 0),
            'fee_amount' => (float) data_get($booking, 'commission', 0),
            'net_amount' => max(0, (float) data_get($booking, 'price', 0) - (float) data_get($booking, 'commission', 0)),
            'total_charge_amount' => (float) data_get($booking, 'price', 0) + (float) data_get($booking, 'tax', 0),
            'charged_to' => $context['charged_to'] ?? \App\Models\FeePolicy::CHARGED_TO_SELLER,
            'currency' => $context['currency'] ?? data_get($booking, 'currencyText', 'DOP'),
            'metadata' => [
                'subtotal_amount' => round((float) data_get($booking, 'price', 0), 2),
                'processing_fee_amount' => round((float) data_get($booking, 'tax', 0), 2),
                'commission_percentage' => data_get($booking, 'commission_percentage'),
                'fee_policy_source' => $context['policy_source'] ?? null,
                'fee_base_amount' => $context['fee_base_amount'] ?? null,
            ] + $ownerContext['metadata'],
            'occurred_at' => now(),
        ] + $ownerContext['columns']);
    }

    public function recordMarketplaceResale(
        Booking $booking,
        Customer $buyer,
        Customer $seller,
        array $feeBreakdown,
        ?TicketTransfer $transfer = null,
        array $metadata = []
    ): ?PlatformRevenueEvent {
        $event = $this->resolveEvent($booking, $booking->event_id);
        $ownerContext = $this->resolveOwnerContext($event, $booking);

        return $this->record([
            'idempotency_key' => 'platform_revenue_marketplace_booking_' . $booking->id,
            'policy_id' => $feeBreakdown['policy_id'] ?? null,
            'operation_key' => FeeEngine::OP_MARKETPLACE_RESALE,
            'reference_type' => 'booking',
            'reference_id' => $booking->id,
            'booking_id' => $booking->id,
            'event_id' => $booking->event_id,
            'ticket_id' => $booking->ticket_id,
            'transfer_id' => $transfer?->id,
            'actor_customer_id' => $buyer->id,
            'target_customer_id' => $seller->id,
            'gross_amount' => (float) ($feeBreakdown['gross_amount'] ?? 0),
            'fee_amount' => (float) ($feeBreakdown['fee_amount'] ?? 0),
            'net_amount' => (float) ($feeBreakdown['net_amount'] ?? 0),
            'total_charge_amount' => (float) ($feeBreakdown['total_charge_amount'] ?? $feeBreakdown['gross_amount'] ?? 0),
            'charged_to' => $feeBreakdown['charged_to'] ?? \App\Models\FeePolicy::CHARGED_TO_SELLER,
            'currency' => $feeBreakdown['currency'] ?? 'DOP',
            'metadata' => [
                'seller_customer_id' => $seller->id,
                'buyer_customer_id' => $buyer->id,
                'seller_payout' => round((float) ($feeBreakdown['net_amount'] ?? 0), 2),
                'listing_price' => round((float) ($feeBreakdown['gross_amount'] ?? 0), 2),
                'fee_policy_source' => $feeBreakdown['policy_source'] ?? null,
            ] + $metadata + $ownerContext['metadata'],
            'occurred_at' => now(),
        ] + $ownerContext['columns']);
    }

    public function recordMarketplaceCardProcessing(
        Booking $booking,
        Customer $buyer,
        array $feeBreakdown,
        ?TicketTransfer $transfer = null,
        array $metadata = []
    ): ?PlatformRevenueEvent {
        $event = $this->resolveEvent($booking, $booking->event_id);
        $ownerContext = $this->resolveOwnerContext($event, $booking);

        return $this->record([
            'idempotency_key' => 'platform_revenue_marketplace_card_processing_booking_' . $booking->id,
            'policy_id' => $feeBreakdown['policy_id'] ?? null,
            'operation_key' => FeeEngine::OP_MARKETPLACE_CARD_PROCESSING,
            'reference_type' => 'booking',
            'reference_id' => $booking->id,
            'booking_id' => $booking->id,
            'event_id' => $booking->event_id,
            'ticket_id' => $booking->ticket_id,
            'transfer_id' => $transfer?->id,
            'actor_customer_id' => $buyer->id,
            'target_customer_id' => $buyer->id,
            'gross_amount' => (float) ($feeBreakdown['gross_amount'] ?? 0),
            'fee_amount' => (float) ($feeBreakdown['fee_amount'] ?? 0),
            'net_amount' => (float) ($feeBreakdown['net_amount'] ?? 0),
            'total_charge_amount' => (float) ($feeBreakdown['total_charge_amount'] ?? $feeBreakdown['gross_amount'] ?? 0),
            'charged_to' => $feeBreakdown['charged_to'] ?? \App\Models\FeePolicy::CHARGED_TO_BUYER,
            'currency' => $feeBreakdown['currency'] ?? 'DOP',
            'metadata' => [
                'buyer_customer_id' => $buyer->id,
                'card_amount' => round((float) ($feeBreakdown['gross_amount'] ?? 0), 2),
                'card_total_charge' => round((float) ($feeBreakdown['total_charge_amount'] ?? 0), 2),
                'fee_policy_source' => $feeBreakdown['policy_source'] ?? null,
            ] + $metadata + $ownerContext['metadata'],
            'occurred_at' => now(),
        ] + $ownerContext['columns']);
    }

    private function resolveEvent(Booking|array $booking, mixed $eventId): ?Event
    {
        if ($booking instanceof Booking && $booking->relationLoaded('evnt')) {
            return $booking->getRelation('evnt');
        }

        if ($eventId) {
            return Event::query()->find($eventId);
        }

        return null;
    }

    private function resolveOwnerContext(?Event $event, Booking|array $booking): array
    {
        $ownerIdentityId = $event?->owner_identity_id ? (int) $event->owner_identity_id : null;
        $venueIdentityId = $event?->venue_identity_id ? (int) $event->venue_identity_id : null;
        $ownerIdentityType = null;

        $organizerId = data_get($booking, 'organizer_id') ?: $event?->organizer_id;
        $venueId = $event?->venue_id;
        $artistId = null;

        if ($ownerIdentityId && Schema::hasTable('identities')) {
            $ownerIdentity = Identity::query()->find($ownerIdentityId);
            $ownerIdentityType = $ownerIdentity?->type;

            if ($ownerIdentityType === 'venue' && !$venueIdentityId) {
                $venueIdentityId = $ownerIdentityId;
            }
        }

        return [
            'columns' => [
                'owner_identity_id' => $ownerIdentityId,
                'owner_identity_type' => $ownerIdentityType,
                'organizer_id' => $organizerId,
                'venue_id' => $venueId,
                'artist_id' => $artistId,
                'venue_identity_id' => $venueIdentityId,
            ],
            'metadata' => [
                'event_type' => $event?->event_type,
                'owner_identity_id' => $ownerIdentityId,
                'venue_identity_id' => $venueIdentityId,
            ],
        ];
    }
}
