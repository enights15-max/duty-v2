<?php

namespace App\Services;

use App\Models\Reservation\TicketReservation;
use App\Models\Reservation\TicketReservationActionLog;

class ReservationAuditService
{
    public function log(
        TicketReservation $reservation,
        string $action,
        ?string $actorType = null,
        ?int $actorId = null,
        array $meta = []
    ): TicketReservationActionLog {
        return TicketReservationActionLog::create([
            'reservation_id' => $reservation->id,
            'actor_type' => $actorType,
            'actor_id' => $actorId,
            'action' => $action,
            'meta' => $meta,
        ]);
    }
}
