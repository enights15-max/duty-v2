<?php

namespace App\Services;

use Carbon\Carbon;

class EventEarlyBirdDiscountService
{
    /**
     * Calculates early-bird discount for a ticket and base amount.
     * Keeps legacy semantics from EventController checkout logic.
     */
    public function calculate(object $ticket, float $baseAmount, ?Carbon $currentTime = null): float
    {
        if (($ticket->early_bird_discount ?? null) !== 'enable') {
            return 0.0;
        }

        $end = Carbon::parse(($ticket->early_bird_discount_date ?? '') . ($ticket->early_bird_discount_time ?? ''));
        $now = $currentTime ?? Carbon::now();

        if ($now->gt($end)) {
            return 0.0;
        }

        if (($ticket->early_bird_discount_type ?? null) === 'fixed') {
            return (float) ($ticket->early_bird_discount_amount ?? 0);
        }

        return ((float) ($ticket->early_bird_discount_amount ?? 0) * $baseAmount) / 100;
    }
}
