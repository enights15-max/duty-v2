<?php

namespace Tests\Feature\Console;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationStatusNotificationService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class ReservationReminderCommandTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'reservations'];
    protected array $baselineTruncate = [
        'ticket_reservation_action_logs',
        'ticket_reservations',
        'event_contents',
        'events',
        'tickets',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureReminderSchema();
    }

    public function test_command_sends_24h_and_2h_reminders_once(): void
    {
        $this->seedCustomer(1701);
        $this->seedEvent(2701, 'Reminder Event');
        $this->seedTicket(3701, 2701);

        $this->seedReservation(4701, [
            'customer_id' => 1701,
            'event_id' => 2701,
            'ticket_id' => 3701,
            'reservation_code' => 'RSV-REM-24H',
            'expires_at' => now()->addHours(10),
        ]);

        $this->seedReservation(4702, [
            'customer_id' => 1701,
            'event_id' => 2701,
            'ticket_id' => 3701,
            'reservation_code' => 'RSV-REM-2H',
            'expires_at' => now()->addMinutes(90),
        ]);

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 4701), 'payment_due_reminder_24h', Mockery::type('array'))
            ->andReturnTrue();
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 4702), 'payment_due_reminder_2h', Mockery::type('array'))
            ->andReturnTrue();
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $this->artisan('reservations:send-reminders')
            ->expectsOutput('Reservation reminders completed.')
            ->expectsOutput('24h reminders: 1')
            ->expectsOutput('2h reminders: 1')
            ->assertExitCode(0);

        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 4701,
            'actor_type' => 'system',
            'action' => 'payment_due_reminder_24h',
        ]);
        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 4702,
            'actor_type' => 'system',
            'action' => 'payment_due_reminder_2h',
        ]);

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldNotReceive('notifyCustomer');
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $this->artisan('reservations:send-reminders')
            ->expectsOutput('24h reminders: 0')
            ->expectsOutput('2h reminders: 0')
            ->assertExitCode(0);
    }

    public function test_command_skips_reservations_without_delivery_channel(): void
    {
        $this->seedCustomer(1702);
        $this->seedEvent(2702, 'Skipped Reminder Event');
        $this->seedTicket(3702, 2702);

        $this->seedReservation(4703, [
            'customer_id' => 1702,
            'event_id' => 2702,
            'ticket_id' => 3702,
            'reservation_code' => 'RSV-REM-SKIP',
            'expires_at' => now()->addHours(8),
        ]);

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->andReturnFalse();
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $this->artisan('reservations:send-reminders')
            ->expectsOutput('24h reminders: 0')
            ->expectsOutput('2h reminders: 0')
            ->expectsOutput('Skipped: 1')
            ->assertExitCode(0);

        $this->assertDatabaseMissing('ticket_reservation_action_logs', [
            'reservation_id' => 4703,
            'action' => 'payment_due_reminder_24h',
        ]);
    }

    private function ensureReminderSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->timestamp('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->integer('ticket_available')->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_reservation_action_logs')) {
            Schema::create('ticket_reservation_action_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reservation_id');
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('action', 64);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id): void
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "reservation-reminder-{$id}@example.com",
            'fname' => 'Reminder',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEvent(int $id, string $title): void
    {
        DB::table('events')->insert([
            'id' => $id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $id,
            'title' => $title,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedTicket(int $id, int $eventId): void
    {
        DB::table('tickets')->insert([
            'id' => $id,
            'event_id' => $eventId,
            'ticket_available' => 10,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedReservation(int $id, array $overrides = []): void
    {
        DB::table('ticket_reservations')->insert(array_merge([
            'id' => $id,
            'customer_id' => 1701,
            'event_id' => 2701,
            'ticket_id' => 3701,
            'reservation_code' => 'RSV-' . $id,
            'quantity' => 1,
            'reserved_unit_price' => 100.00,
            'total_amount' => 100.00,
            'deposit_required' => 25.00,
            'amount_paid' => 25.00,
            'remaining_balance' => 75.00,
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ], $overrides));
    }
}
