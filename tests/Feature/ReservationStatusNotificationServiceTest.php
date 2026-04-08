<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Reservation\TicketReservation;
use App\Services\NotificationService;
use App\Services\ReservationStatusNotificationService;
use Illuminate\Support\Facades\Mail;
use Mockery;
use Tests\TestCase;

class ReservationStatusNotificationServiceTest extends TestCase
{
    public function test_it_builds_and_sends_reservation_refund_notification(): void
    {
        $customer = new Customer([
            'fname' => 'QA',
            'lname' => 'Customer',
            'email' => 'qa@example.com',
        ]);
        $customer->setAttribute('id', 501);
        $customer->exists = true;

        $event = new Event();
        $event->setAttribute('id', 701);
        $event->exists = true;
        $event->setRelation('information', new EventContent([
            'event_id' => 701,
            'title' => 'Reservation Test Event',
        ]));

        $reservation = new TicketReservation([
            'customer_id' => 501,
            'event_id' => 701,
            'reservation_code' => 'RSV-QA-901',
            'status' => 'cancelled',
        ]);
        $reservation->setAttribute('id', 901);
        $reservation->exists = true;
        $reservation->setRelation('customer', $customer);
        $reservation->setRelation('event', $event);

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')
            ->once()
            ->with(
                $customer,
                'Duty: reembolso procesado',
                Mockery::on(fn (string $body) => str_contains($body, 'RSV-QA-901') && str_contains($body, 'Reservation Test Event')),
                Mockery::on(function (array $data) {
                    return ($data['type'] ?? null) === 'reservation_update'
                        && ($data['action'] ?? null) === 'refund_processed'
                        && ($data['reservation_id'] ?? null) === '901';
                })
            )
            ->andReturnTrue();

        Mail::shouldReceive('raw')
            ->once()
            ->with(
                Mockery::on(fn (string $body) => str_contains($body, '$54.00') && str_contains($body, 'RSV-QA-901')),
                Mockery::type(\Closure::class)
            );

        $service = new ReservationStatusNotificationService($notificationService);
        $service->notifyCustomerNow($reservation, 'refund_processed', [
            'gross_amount' => 54.00,
        ]);
    }
}
