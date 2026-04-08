<?php

namespace App\Console\Commands;

use App\Services\ReservationReminderService;
use Illuminate\Console\Command;

class SendReservationRemindersCommand extends Command
{
    protected $signature = 'reservations:send-reminders';
    protected $description = 'Send reminder notifications before ticket reservations expire';

    public function __construct(private ReservationReminderService $reservationReminderService)
    {
        parent::__construct();
    }

    public function handle(): int
    {
        $summary = $this->reservationReminderService->handle();

        $this->info('Reservation reminders completed.');
        $this->info('24h reminders: ' . (int) ($summary['24h'] ?? 0));
        $this->info('2h reminders: ' . (int) ($summary['2h'] ?? 0));
        $this->info('Skipped: ' . (int) ($summary['skipped'] ?? 0));

        return self::SUCCESS;
    }
}
