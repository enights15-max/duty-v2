<?php

namespace App\Services;

use App\Models\Event\Ticket;
use App\Models\Reservation\TicketReservation;
use Carbon\CarbonInterface;
use Exception;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class AdminReservationManagementService
{
    public function __construct(
        private ReservationBookingConversionService $conversionService
    ) {
    }

    public function extend(TicketReservation $reservation, CarbonInterface $expiresAt, ?CarbonInterface $finalDueDate = null): TicketReservation
    {
        if ($reservation->status !== 'active') {
            throw new Exception('Only active reservations can be extended.');
        }

        if ($expiresAt->isPast()) {
            throw new Exception('Expiration must be a future date and time.');
        }

        return DB::transaction(function () use ($reservation, $expiresAt, $finalDueDate) {
            $lockedReservation = $this->lockReservation($reservation);
            $lockedReservation->expires_at = $expiresAt;

            if ($finalDueDate !== null) {
                $lockedReservation->final_due_date = $finalDueDate;
            }

            $lockedReservation->save();

            return $this->freshReservation($lockedReservation);
        });
    }

    public function cancel(TicketReservation $reservation): TicketReservation
    {
        if ($reservation->status === 'completed') {
            throw new Exception('Completed reservations cannot be cancelled from this module.');
        }

        if ($reservation->status === 'cancelled') {
            throw new Exception('This reservation is already cancelled.');
        }

        return DB::transaction(function () use ($reservation) {
            $lockedReservation = $this->lockReservation($reservation);

            if ($lockedReservation->status === 'active') {
                $this->releaseInventory($lockedReservation);
            }

            $lockedReservation->status = 'cancelled';
            $lockedReservation->save();

            return $this->freshReservation($lockedReservation);
        });
    }

    public function markDefaulted(TicketReservation $reservation): TicketReservation
    {
        if ($reservation->status === 'completed') {
            throw new Exception('Completed reservations cannot be marked as defaulted.');
        }

        if ($reservation->status === 'defaulted') {
            throw new Exception('This reservation is already marked as defaulted.');
        }

        return DB::transaction(function () use ($reservation) {
            $lockedReservation = $this->lockReservation($reservation);

            if ($lockedReservation->status === 'active') {
                $this->releaseInventory($lockedReservation);
            }

            $lockedReservation->status = 'defaulted';
            $lockedReservation->save();

            return $this->freshReservation($lockedReservation);
        });
    }

    public function reactivate(TicketReservation $reservation, CarbonInterface $expiresAt, ?CarbonInterface $finalDueDate = null): TicketReservation
    {
        if (!in_array($reservation->status, ['expired', 'defaulted', 'cancelled'], true)) {
            throw new Exception('Only expired, defaulted or cancelled reservations can be reactivated.');
        }

        if ((float) $reservation->remaining_balance <= 0) {
            throw new Exception('Reservations with no remaining balance do not need reactivation.');
        }

        if ($expiresAt->isPast()) {
            throw new Exception('Expiration must be a future date and time.');
        }

        return DB::transaction(function () use ($reservation, $expiresAt, $finalDueDate) {
            $lockedReservation = $this->lockReservation($reservation);
            $this->reserveInventory($lockedReservation);

            $lockedReservation->status = 'active';
            $lockedReservation->expires_at = $expiresAt;

            if ($finalDueDate !== null) {
                $lockedReservation->final_due_date = $finalDueDate;
            }

            $lockedReservation->save();

            return $this->freshReservation($lockedReservation);
        });
    }

    public function convert(TicketReservation $reservation): Collection
    {
        if ($reservation->status !== 'completed') {
            throw new Exception('Only completed reservations can be converted to bookings.');
        }

        return $this->conversionService->convert($reservation);
    }

    private function lockReservation(TicketReservation $reservation): TicketReservation
    {
        return TicketReservation::query()
            ->lockForUpdate()
            ->findOrFail($reservation->id);
    }

    private function reserveInventory(TicketReservation $reservation): void
    {
        $ticket = Ticket::query()->lockForUpdate()->find($reservation->ticket_id);
        if (!$ticket) {
            throw new Exception('The ticket attached to this reservation no longer exists.');
        }

        if ($ticket->ticket_available_type !== 'limited') {
            return;
        }

        if ((int) $ticket->ticket_available < (int) $reservation->quantity) {
            throw new Exception('There is not enough ticket inventory to reactivate this reservation.');
        }

        $ticket->ticket_available = (int) $ticket->ticket_available - (int) $reservation->quantity;
        $ticket->save();
    }

    private function releaseInventory(TicketReservation $reservation): void
    {
        $ticket = Ticket::query()->lockForUpdate()->find($reservation->ticket_id);
        if (!$ticket || $ticket->ticket_available_type !== 'limited') {
            return;
        }

        $ticket->ticket_available = (int) $ticket->ticket_available + (int) $reservation->quantity;
        $ticket->save();
    }

    private function freshReservation(TicketReservation $reservation): TicketReservation
    {
        return $reservation->fresh([
            'customer',
            'ticket',
            'event',
            'event.information',
            'payments',
            'bookings.paymentAllocations',
        ]);
    }
}
