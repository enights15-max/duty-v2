<?php

namespace App\Services;

use App\Models\Reservation\TicketReservation;
use Carbon\Carbon;

class ReservationReminderService
{
    public function __construct(
        private ReservationStatusNotificationService $notificationService,
        private ReservationAuditService $auditService
    ) {
    }

    public function handle(): array
    {
        $now = now();
        $cutoff24h = (clone $now)->addHours(24);

        $reservations = TicketReservation::query()
            ->with(['customer', 'event.information', 'actionLogs'])
            ->where('status', 'active')
            ->where('remaining_balance', '>', 0)
            ->where(function ($query) use ($now, $cutoff24h) {
                $query->whereBetween('expires_at', [$now, $cutoff24h])
                    ->orWhereBetween('final_due_date', [$now, $cutoff24h]);
            })
            ->get();

        $summary = [
            '24h' => 0,
            '2h' => 0,
            'skipped' => 0,
        ];

        foreach ($reservations as $reservation) {
            $dueAt = $this->resolveDueAt($reservation);
            if (!$dueAt || $dueAt->lte($now)) {
                $summary['skipped']++;
                continue;
            }

            $action = $this->resolveReminderAction($dueAt, $now);
            if (!$action) {
                $summary['skipped']++;
                continue;
            }

            if ($reservation->actionLogs->contains(fn ($log) => $log->action === $action)) {
                $summary['skipped']++;
                continue;
            }

            $sent = $this->notificationService->notifyCustomer($reservation, $action, [
                'expires_at' => $dueAt->toDateTimeString(),
                'final_due_date' => optional($reservation->final_due_date)->toDateTimeString(),
                'remaining_balance' => (float) $reservation->remaining_balance,
            ]);

            if (!$sent) {
                $summary['skipped']++;
                continue;
            }

            $this->auditService->log($reservation, $action, 'system', null, [
                'expires_at' => $dueAt->toDateTimeString(),
                'remaining_balance' => (float) $reservation->remaining_balance,
            ]);

            if ($action === 'payment_due_reminder_2h') {
                $summary['2h']++;
            } else {
                $summary['24h']++;
            }
        }

        return $summary;
    }

    protected function resolveDueAt(TicketReservation $reservation): ?Carbon
    {
        $dates = collect([$reservation->expires_at, $reservation->final_due_date])
            ->filter()
            ->map(fn ($value) => $value instanceof Carbon ? $value->copy() : Carbon::parse($value))
            ->sort();

        return $dates->first();
    }

    protected function resolveReminderAction(Carbon $dueAt, Carbon $now): ?string
    {
        if ($dueAt->lte((clone $now)->addHours(2))) {
            return 'payment_due_reminder_2h';
        }

        if ($dueAt->lte((clone $now)->addHours(24))) {
            return 'payment_due_reminder_24h';
        }

        return null;
    }
}
