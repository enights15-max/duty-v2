<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\TicketJourneyEvent;
use Illuminate\Support\Facades\Schema;

class TicketJourneyService
{
    public function record(?Booking $booking, string $type, array $context = []): void
    {
        if (!$booking || !Schema::hasTable('ticket_journey_events')) {
            return;
        }

        TicketJourneyEvent::query()->create([
            'booking_id' => $booking->id,
            'event_id' => $booking->event_id,
            'ticket_id' => $booking->ticket_id,
            'actor_customer_id' => $context['actor_customer_id'] ?? null,
            'target_customer_id' => $context['target_customer_id'] ?? null,
            'transfer_id' => $context['transfer_id'] ?? null,
            'type' => $type,
            'price' => array_key_exists('price', $context)
                ? $this->normalizePrice($context['price'])
                : null,
            'metadata' => $context['metadata'] ?? null,
            'occurred_at' => $context['occurred_at'] ?? now(),
        ]);
    }

    public function summarizeForEvent(Event|int $event): array
    {
        if (!Schema::hasTable('ticket_journey_events')) {
            return $this->emptySummary();
        }

        $eventId = $event instanceof Event ? (int) $event->id : (int) $event;

        $query = TicketJourneyEvent::query()->where('event_id', $eventId);

        $movementTypes = [
            'gift_transfer_pending',
            'gift_transfer_accepted',
            'gift_transfer_rejected',
            'gift_transfer_cancelled',
            'listed',
            'unlisted',
            'marketplace_purchase',
            'scanned',
        ];

        $movedTicketCount = (clone $query)
            ->whereIn('type', $movementTypes)
            ->distinct('booking_id')
            ->count('booking_id');

        $listingCount = (clone $query)->where('type', 'listed')->count();
        $resaleCount = (clone $query)->where('type', 'marketplace_purchase')->count();
        $giftPendingCount = (clone $query)->where('type', 'gift_transfer_pending')->count();
        $giftAcceptedCount = (clone $query)->where('type', 'gift_transfer_accepted')->count();
        $scanCount = (clone $query)->where('type', 'scanned')->count();

        $resalePriceStats = (clone $query)
            ->where('type', 'marketplace_purchase')
            ->whereNotNull('price')
            ->selectRaw('AVG(price) as average_price, MAX(price) as max_price')
            ->first();

        return [
            'journey_event_count' => (clone $query)->count(),
            'tickets_moved_count' => $movedTicketCount,
            'listing_count' => $listingCount,
            'resale_count' => $resaleCount,
            'gift_transfer_pending_count' => $giftPendingCount,
            'gift_transfer_completed_count' => $giftAcceptedCount,
            'scan_count' => $scanCount,
            'average_resale_price' => $this->normalizePrice(optional($resalePriceStats)->average_price),
            'max_resale_price' => $this->normalizePrice(optional($resalePriceStats)->max_price),
        ];
    }

    public function emptySummary(): array
    {
        return [
            'journey_event_count' => 0,
            'tickets_moved_count' => 0,
            'listing_count' => 0,
            'resale_count' => 0,
            'gift_transfer_pending_count' => 0,
            'gift_transfer_completed_count' => 0,
            'scan_count' => 0,
            'average_resale_price' => null,
            'max_resale_price' => null,
        ];
    }

    private function normalizePrice(mixed $value): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }

        return round((float) $value, 2);
    }
}
