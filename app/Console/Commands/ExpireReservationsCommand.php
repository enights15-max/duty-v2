<?php

namespace App\Console\Commands;

use App\Services\ReservationExpiryService;
use Illuminate\Console\Command;

class ExpireReservationsCommand extends Command
{
    protected $signature = 'reservations:expire';
    protected $description = 'Expire overdue ticket reservations and release inventory';

    public function __construct(private ReservationExpiryService $reservationExpiryService)
    {
        parent::__construct();
    }

    public function handle(): int
    {
        $expired = $this->reservationExpiryService->handle();
        $this->info("Expired reservations: {$expired}");

        return self::SUCCESS;
    }
}
