<?php

namespace App\Services;

use Carbon\Carbon;

class ReservationExpiryService
{
    public function __construct(private TicketReservationService $ticketReservationService)
    {
    }

    public function handle(?Carbon $now = null): int
    {
        return $this->ticketReservationService->expireOverdueReservations($now);
    }
}
