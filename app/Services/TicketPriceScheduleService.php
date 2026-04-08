<?php

namespace App\Services;

use App\Models\Event\Ticket;
use App\Models\Event\TicketPriceSchedule;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Schema;

class TicketPriceScheduleService
{
    public function resolveForTicket(Ticket $ticket, ?Carbon $at = null): array
    {
        $at = $at ?: Carbon::now();
        $basePrice = round((float) ($ticket->price ?? $ticket->f_price ?? 0), 2);

        if (!$this->canUseSchedules($ticket)) {
            return [
                'base_price' => $basePrice,
                'effective_price' => $basePrice,
                'has_schedule' => false,
                'current_schedule' => null,
                'next_schedule' => null,
            ];
        }

        $current = $ticket->priceSchedules()
            ->reorder()
            ->where('is_active', true)
            ->where('effective_from', '<=', $at)
            ->orderByDesc('effective_from')
            ->orderByDesc('sort_order')
            ->first();

        $next = $ticket->priceSchedules()
            ->reorder()
            ->where('is_active', true)
            ->where('effective_from', '>', $at)
            ->orderBy('effective_from')
            ->orderBy('sort_order')
            ->first();

        $effectivePrice = round((float) ($current->price ?? $basePrice), 2);

        return [
            'base_price' => $basePrice,
            'effective_price' => $effectivePrice,
            'has_schedule' => $current !== null || $next !== null,
            'current_schedule' => $this->serializeSchedule($current),
            'next_schedule' => $this->serializeSchedule($next),
        ];
    }

    public function resolveEventStartPrice(int $eventId, ?Collection $tickets = null): array
    {
        $tickets = $tickets ?: Ticket::query()->where('event_id', $eventId)->get();
        if ($tickets->isEmpty()) {
            return [
                'ticket' => null,
                'start_price' => null,
            ];
        }

        $selectedTicket = null;
        $selectedPrice = null;

        foreach ($tickets as $ticket) {
            if (($ticket->pricing_type ?? null) === 'free') {
                return [
                    'ticket' => $ticket,
                    'start_price' => 'free',
                ];
            }

            $candidatePrice = $this->resolveDisplayPrice($ticket);
            if ($candidatePrice === null) {
                continue;
            }

            if ($selectedTicket === null || $candidatePrice < $selectedPrice) {
                $selectedTicket = $ticket;
                $selectedPrice = $candidatePrice;
            }
        }

        return [
            'ticket' => $selectedTicket,
            'start_price' => $selectedPrice,
        ];
    }

    public function syncSchedules(Ticket $ticket, array $rows): void
    {
        if (!Schema::hasTable('ticket_price_schedules')) {
            return;
        }

        $normalized = collect($rows)
            ->map(function ($row, $index) {
                if (!is_array($row)) {
                    return null;
                }

                $price = round((float) ($row['price'] ?? 0), 2);
                $effectiveFrom = $row['effective_from'] ?? null;
                if ($price <= 0 || empty($effectiveFrom)) {
                    return null;
                }

                return [
                    'label' => filled($row['label'] ?? null) ? (string) $row['label'] : null,
                    'effective_from' => Carbon::parse((string) $effectiveFrom),
                    'price' => $price,
                    'sort_order' => (int) ($row['sort_order'] ?? $index),
                    'is_active' => filter_var($row['is_active'] ?? true, FILTER_VALIDATE_BOOLEAN),
                ];
            })
            ->filter()
            ->sortBy(fn (array $schedule) => sprintf(
                '%s-%06d',
                $schedule['effective_from']->format('YmdHis'),
                (int) $schedule['sort_order']
            ))
            ->values();

        $ticket->priceSchedules()->delete();

        foreach ($normalized as $schedule) {
            $ticket->priceSchedules()->create($schedule);
        }
    }

    private function resolveDisplayPrice(Ticket $ticket): ?float
    {
        if (($ticket->pricing_type ?? null) === 'normal') {
            return $this->resolveForTicket($ticket)['effective_price'];
        }

        if (($ticket->pricing_type ?? null) === 'variation') {
            $variations = json_decode((string) ($ticket->variations ?? '[]'), true) ?: [];
            $prices = collect($variations)
                ->map(fn ($variation) => is_array($variation) ? ($variation['price'] ?? null) : null)
                ->filter(fn ($price) => $price !== null && $price !== '' && is_numeric($price))
                ->map(fn ($price) => round((float) $price, 2))
                ->filter(fn ($price) => $price >= 0);

            if ($prices->isNotEmpty()) {
                return (float) $prices->min();
            }
        }

        $fallback = $ticket->price ?? $ticket->f_price;
        return $fallback === null ? null : round((float) $fallback, 2);
    }

    private function canUseSchedules(Ticket $ticket): bool
    {
        return Schema::hasTable('ticket_price_schedules')
            && (int) ($ticket->id ?? 0) > 0
            && ($ticket->pricing_type ?? null) === 'normal';
    }

    private function serializeSchedule(?TicketPriceSchedule $schedule): ?array
    {
        if (!$schedule) {
            return null;
        }

        return [
            'id' => $schedule->id,
            'label' => $schedule->label,
            'effective_from' => optional($schedule->effective_from)->toIso8601String(),
            'price' => round((float) $schedule->price, 2),
            'sort_order' => (int) $schedule->sort_order,
            'is_active' => (bool) $schedule->is_active,
        ];
    }
}
