<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Ticket;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Schema;

class EventInventorySummaryService
{
    public function summarizeEvent(Event $event, iterable $tickets = []): array
    {
        $resolvedTickets = $this->resolveTicketsForEvent($event, $tickets);
        $eventId = (int) $event->id;
        $soldCount = $this->soldCountMap([$eventId])[$eventId] ?? 0;
        $marketplaceAvailableCount = $this->marketplaceCountMap([$eventId])[$eventId] ?? 0;

        return $this->buildSummary($event, $resolvedTickets, (int) $soldCount, (int) $marketplaceAvailableCount);
    }

    public function summarizeMany(iterable $events): array
    {
        $eventsCollection = collect($events)
            ->filter(fn ($event) => $event instanceof Event)
            ->values();

        if ($eventsCollection->isEmpty()) {
            return [];
        }

        $eventIds = $eventsCollection
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->filter(fn ($id) => $id > 0)
            ->values()
            ->all();

        if (empty($eventIds)) {
            return [];
        }

        $ticketsByEvent = Schema::hasTable((new Ticket())->getTable())
            ? Ticket::query()
                ->whereIn('event_id', $eventIds)
                ->get()
                ->groupBy(fn (Ticket $ticket) => (int) $ticket->event_id)
            : collect();

        $soldCountMap = $this->soldCountMap($eventIds);
        $marketplaceCountMap = $this->marketplaceCountMap($eventIds);

        $summaries = [];
        foreach ($eventsCollection as $event) {
            $eventId = (int) $event->id;
            $summaries[$eventId] = $this->buildSummary(
                $event,
                $ticketsByEvent->get($eventId, collect()),
                (int) ($soldCountMap[$eventId] ?? 0),
                (int) ($marketplaceCountMap[$eventId] ?? 0)
            );
        }

        return $summaries;
    }

    /**
     * Aggregate dashboard-friendly metrics across multiple events.
     */
    public function aggregate(iterable $events): array
    {
        $summaries = $this->summarizeMany($events);

        $availableKnown = 0;
        $soldKnown = 0;
        $inventoryKnown = 0;
        $soldOutEvents = 0;
        $lowStockEvents = 0;
        $marketplaceFallbackEvents = 0;

        foreach ($summaries as $summary) {
            $soldOutEvents += $summary['primary_sold_out'] ? 1 : 0;
            $lowStockEvents += $summary['low_stock'] ? 1 : 0;
            $marketplaceFallbackEvents += $summary['show_marketplace_fallback'] ? 1 : 0;

            if ($summary['primary_available_tickets'] !== null) {
                $availableKnown += (int) $summary['primary_available_tickets'];
            }

            if ($summary['primary_tickets_sold'] !== null) {
                $soldKnown += (int) $summary['primary_tickets_sold'];
            }

            if ($summary['primary_total_inventory'] !== null) {
                $inventoryKnown += (int) $summary['primary_total_inventory'];
            }
        }

        $sellThroughPercent = $inventoryKnown > 0
            ? round(($soldKnown / $inventoryKnown) * 100, 1)
            : null;

        return [
            'tickets_available' => $availableKnown,
            'sell_through_percent' => $sellThroughPercent,
            'sold_out_events' => $soldOutEvents,
            'low_stock_events' => $lowStockEvents,
            'marketplace_fallback_events' => $marketplaceFallbackEvents,
            'tracked_inventory_events' => collect($summaries)
                ->filter(fn (array $summary) => $summary['primary_total_inventory'] !== null)
                ->count(),
        ];
    }

    /**
     * @param iterable<Ticket> $tickets
     */
    private function buildSummary(Event $event, iterable $tickets, int $soldCount, int $marketplaceAvailableCount): array
    {
        $availableCount = 0;
        $hasUnlimitedPrimary = false;
        $hasPrimaryInventory = false;

        foreach ($tickets as $ticket) {
            if (!$ticket instanceof Ticket) {
                continue;
            }

            $ticketSummary = $this->summarizeTicket($ticket);
            $hasPrimaryInventory = $hasPrimaryInventory || $ticketSummary['has_primary_inventory'];
            $hasUnlimitedPrimary = $hasUnlimitedPrimary || $ticketSummary['has_unlimited_inventory'];
            $availableCount += (int) $ticketSummary['available_count'];
        }

        $trackedOfficialAvailability = $hasPrimaryInventory && !$hasUnlimitedPrimary
            ? max(0, $availableCount)
            : null;

        $trackedInventoryTotal = $trackedOfficialAvailability !== null
            ? max(0, $trackedOfficialAvailability + $soldCount)
            : null;

        $sellThroughPercent = $trackedInventoryTotal && $trackedInventoryTotal > 0
            ? round(($soldCount / $trackedInventoryTotal) * 100, 1)
            : null;

        $primarySoldOut = $hasPrimaryInventory
            ? ($hasUnlimitedPrimary ? false : $availableCount <= 0)
            : false;

        $lowStockThreshold = $trackedInventoryTotal !== null
            ? max(10, (int) ceil($trackedInventoryTotal * 0.15))
            : null;

        $lowStock = $trackedOfficialAvailability !== null
            && !$primarySoldOut
            && $trackedOfficialAvailability > 0
            && $trackedOfficialAvailability <= (int) $lowStockThreshold;

        $availabilityState = $primarySoldOut
            ? ($marketplaceAvailableCount > 0 ? 'sold_out_marketplace' : 'sold_out')
            : ($lowStock ? 'low_stock' : 'available');
        $isPastEvent = $this->isPastEvent($event);
        $showWaitlistCta = !$isPastEvent && $primarySoldOut && $marketplaceAvailableCount <= 0;

        return [
            'has_primary_inventory' => $hasPrimaryInventory,
            'primary_inventory_limited' => $hasPrimaryInventory && !$hasUnlimitedPrimary,
            'primary_available_tickets' => $trackedOfficialAvailability,
            'primary_tickets_sold' => $soldCount,
            'primary_total_inventory' => $trackedInventoryTotal,
            'primary_sell_through_percent' => $sellThroughPercent,
            'primary_sold_out' => $primarySoldOut,
            'low_stock' => $lowStock,
            'low_stock_count' => $lowStock ? $trackedOfficialAvailability : null,
            'marketplace_available_count' => $marketplaceAvailableCount,
            'show_marketplace_fallback' => $primarySoldOut && $marketplaceAvailableCount > 0,
            'show_waitlist_cta' => $showWaitlistCta,
            'is_past_event' => $isPastEvent,
            'availability_state' => $availabilityState,
            'demand_label' => $this->demandLabelForState(
                $availabilityState,
                $trackedOfficialAvailability,
                $marketplaceAvailableCount
            ),
        ];
    }

    private function demandLabelForState(
        string $availabilityState,
        ?int $trackedOfficialAvailability,
        int $marketplaceAvailableCount
    ): string {
        return match ($availabilityState) {
            'low_stock' => $trackedOfficialAvailability !== null
                ? 'Quedan ' . $trackedOfficialAvailability . ' entradas'
                : 'Últimas entradas',
            'sold_out_marketplace' => 'Agotado · ' . $marketplaceAvailableCount . ' en blackmarket',
            'sold_out' => 'Sold out',
            default => 'Tickets disponibles',
        };
    }

    private function isPastEvent(Event $event): bool
    {
        return !empty($event->end_date_time)
            && now()->greaterThan($event->end_date_time);
    }

    private function summarizeTicket(Ticket $ticket): array
    {
        $pricingType = strtolower((string) ($ticket->pricing_type ?? 'normal'));

        if ($pricingType === 'variation') {
            $variations = json_decode((string) $ticket->variations, true);
            if (!is_array($variations) || empty($variations)) {
                return [
                    'has_primary_inventory' => false,
                    'has_unlimited_inventory' => false,
                    'available_count' => 0,
                ];
            }

            $availableCount = 0;
            $hasUnlimitedInventory = false;

            foreach ($variations as $variation) {
                if (!is_array($variation)) {
                    continue;
                }

                $availabilityType = strtolower((string) ($variation['ticket_available_type'] ?? 'unlimited'));
                if ($availabilityType === 'limited') {
                    $availableCount += max(0, (int) ($variation['ticket_available'] ?? 0));
                    continue;
                }

                $hasUnlimitedInventory = true;
            }

            return [
                'has_primary_inventory' => true,
                'has_unlimited_inventory' => $hasUnlimitedInventory,
                'available_count' => $hasUnlimitedInventory ? 0 : $availableCount,
            ];
        }

        $availabilityType = strtolower((string) ($ticket->ticket_available_type ?? 'unlimited'));
        if ($availabilityType === 'limited') {
            return [
                'has_primary_inventory' => true,
                'has_unlimited_inventory' => false,
                'available_count' => max(0, (int) ($ticket->ticket_available ?? 0)),
            ];
        }

        return [
            'has_primary_inventory' => true,
            'has_unlimited_inventory' => true,
            'available_count' => 0,
        ];
    }

    /**
     * @param iterable<Ticket> $tickets
     * @return Collection<int, Ticket>
     */
    private function resolveTicketsForEvent(Event $event, iterable $tickets): Collection
    {
        $resolved = collect($tickets)
            ->filter(fn ($ticket) => $ticket instanceof Ticket);

        if ($resolved->isNotEmpty()) {
            return $resolved->values();
        }

        if ($event->relationLoaded('tickets')) {
            /** @var Collection<int, Ticket> $loaded */
            $loaded = $event->tickets instanceof Collection ? $event->tickets : collect();
            return $loaded->values();
        }

        if (!Schema::hasTable((new Ticket())->getTable())) {
            return collect();
        }

        return $event->tickets()->get();
    }

    /**
     * @param array<int> $eventIds
     * @return array<int, int>
     */
    private function soldCountMap(array $eventIds): array
    {
        return Booking::query()
            ->whereIn('event_id', $eventIds)
            ->where('paymentStatus', '!=', 'rejected')
            ->selectRaw('event_id, COALESCE(SUM(quantity), 0) as aggregate')
            ->groupBy('event_id')
            ->pluck('aggregate', 'event_id')
            ->map(fn ($value) => (int) $value)
            ->all();
    }

    /**
     * @param array<int> $eventIds
     * @return array<int, int>
     */
    private function marketplaceCountMap(array $eventIds): array
    {
        return Booking::query()
            ->visibleMarketplaceListings()
            ->whereIn('event_id', $eventIds)
            ->selectRaw('event_id, COUNT(*) as aggregate')
            ->groupBy('event_id')
            ->pluck('aggregate', 'event_id')
            ->map(fn ($value) => (int) $value)
            ->all();
    }
}
