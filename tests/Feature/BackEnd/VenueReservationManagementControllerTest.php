<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Venue\ReservationController;
use App\Models\Venue;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationStatusNotificationService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class VenueReservationManagementControllerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'reservations', 'booking_payment_allocations'];
    protected bool $baselineDefaultLanguage = true;
    protected array $baselineTruncate = [
        'ticket_reservation_action_logs',
        'reservation_payments',
        'ticket_reservations',
        'bookings',
        'event_contents',
        'tickets',
        'events',
        'venues',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureVenueReservationSchema();
        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldIgnoreMissing();
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);
    }

    public function test_venue_index_only_shows_reservations_for_owned_events(): void
    {
        $this->seedVenue(5401, 'venue_5401');
        $this->seedVenue(5402, 'venue_5402');
        $this->seedCustomer(6401);

        $eventOne = $this->seedEvent(7401, 5401, 'Venue One Event');
        $eventTwo = $this->seedEvent(7402, 5402, 'Venue Two Event');
        $ticketOne = $this->seedTicket(8401, $eventOne, 'Venue Ticket One', 9);
        $ticketTwo = $this->seedTicket(8402, $eventTwo, 'Venue Ticket Two', 9);

        $this->seedReservation(9401, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-VENUE-OWN-001',
        ]);

        $this->seedReservation(9402, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-VENUE-OTHER-001',
        ]);

        auth('venue')->setUser(Venue::findOrFail(5401));

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/venue/event-booking/reservations', 'GET'));
        $data = $view->getData();

        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-VENUE-OWN-001', optional($data['reservations']->first())->reservation_code);
        $this->assertSame(1, $data['metrics']['total']);
    }

    public function test_venue_cannot_open_reservation_from_other_venue(): void
    {
        $this->seedVenue(5501, 'venue_5501');
        $this->seedVenue(5502, 'venue_5502');
        $this->seedCustomer(6501);

        $eventOne = $this->seedEvent(7501, 5501, 'Scoped Venue Event');
        $eventTwo = $this->seedEvent(7502, 5502, 'Restricted Venue Event');
        $ticketOne = $this->seedTicket(8501, $eventOne, 'Scoped Venue Ticket', 10);
        $ticketTwo = $this->seedTicket(8502, $eventTwo, 'Restricted Venue Ticket', 10);

        $this->seedReservation(9501, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-VENUE-SCOPED-001',
        ]);
        $this->seedReservation(9502, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-VENUE-RESTRICTED-001',
        ]);

        auth('venue')->setUser(Venue::findOrFail(5501));

        $controller = app(ReservationController::class);
        $controller->show(9501);
        $this->expectException(ModelNotFoundException::class);
        $controller->show(9502);
    }

    public function test_venue_can_cancel_owned_active_reservation_and_release_inventory(): void
    {
        $this->seedVenue(5601, 'venue_5601');
        $this->seedCustomer(6601);

        $eventId = $this->seedEvent(7601, 5601, 'Cancelable Venue Event');
        $ticketId = $this->seedTicket(8601, $eventId, 'Cancelable Venue Ticket', 5);
        $this->seedReservation(9601, [
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-VENUE-CANCEL-001',
            'quantity' => 2,
            'status' => 'active',
        ]);

        auth('venue')->setUser(Venue::findOrFail(5601));

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(
                Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 9601),
                'cancelled',
                Mockery::type('array')
            );
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $controller = app(ReservationController::class);
        $response = $controller->cancel(9601);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertSame('cancelled', DB::table('ticket_reservations')->where('id', 9601)->value('status'));
        $this->assertSame(7, (int) DB::table('tickets')->where('id', $ticketId)->value('ticket_available'));
        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 9601,
            'actor_type' => 'venue',
            'actor_id' => 5601,
            'action' => 'cancelled',
        ]);
    }

    public function test_venue_export_only_contains_owned_reservations(): void
    {
        $this->seedVenue(5602, 'venue_5602');
        $this->seedVenue(5603, 'venue_5603');
        $this->seedCustomer(6602);

        $eventOne = $this->seedEvent(7602, 5602, 'Venue Export Event One');
        $eventTwo = $this->seedEvent(7603, 5603, 'Venue Export Event Two');
        $ticketOne = $this->seedTicket(8602, $eventOne, 'Venue Export Ticket One', 5);
        $ticketTwo = $this->seedTicket(8603, $eventTwo, 'Venue Export Ticket Two', 5);

        $this->seedReservation(9602, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-VENUE-EXPORT-OWN',
        ]);
        $this->seedReservation(9603, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-VENUE-EXPORT-OTHER',
        ]);

        auth('venue')->setUser(Venue::findOrFail(5602));

        $controller = app(ReservationController::class);
        $response = $controller->export(Request::create('/venue/event-booking/reservations/export', 'GET', [
            'status' => 'all',
        ]));

        ob_start();
        $response->sendContent();
        $csv = ob_get_clean();

        $this->assertStringContainsString('RSV-VENUE-EXPORT-OWN', $csv);
        $this->assertStringNotContainsString('RSV-VENUE-EXPORT-OTHER', $csv);
    }

    private function ensureVenueReservationSchema(): void
    {
        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table) {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->string('theme_version')->default('light');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('events', 'venue_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('venue_id')->nullable();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->default('limited');
                $table->integer('ticket_available')->default(0);
                $table->string('pricing_type')->default('normal');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reservation_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->string('paymentStatus')->nullable();
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

    private function seedVenue(int $id, string $username): void
    {
        DB::table('venues')->insert([
            'id' => $id,
            'username' => $username,
            'email' => $username . '@example.com',
            'password' => bcrypt('secret'),
            'theme_version' => 'light',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedCustomer(int $id): void
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "venue-reservation-{$id}@example.com",
            'fname' => 'Venue',
            'lname' => 'Customer',
            'phone' => '8090000000',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Av. Venue',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEvent(int $id, int $venueId, string $title): int
    {
        DB::table('events')->insert([
            'id' => $id,
            'venue_id' => $venueId,
            'thumbnail' => 'demo-event.jpg',
            'end_date_time' => now()->addMonth(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $languageId = (int) DB::table('languages')->where('is_default', 1)->value('id');

        DB::table('event_contents')->insert([
            'event_id' => $id,
            'language_id' => $languageId,
            'title' => $title,
            'slug' => strtolower(str_replace(' ', '-', $title)),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedTicket(int $id, int $eventId, string $title, int $available): int
    {
        DB::table('tickets')->insert([
            'id' => $id,
            'event_id' => $eventId,
            'title' => $title,
            'ticket_available_type' => 'limited',
            'ticket_available' => $available,
            'pricing_type' => 'normal',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedReservation(int $id, array $overrides): void
    {
        $now = now();

        DB::table('ticket_reservations')->insert(array_merge([
            'id' => $id,
            'customer_id' => 6401,
            'event_id' => 7401,
            'ticket_id' => 8401,
            'reservation_code' => 'RSV-VEN-SEED-' . $id,
            'booking_order_number' => null,
            'quantity' => 1,
            'reserved_unit_price' => 300,
            'total_amount' => 300,
            'deposit_required' => 60,
            'amount_paid' => 60,
            'remaining_balance' => 240,
            'deposit_type' => 'percentage',
            'deposit_value' => 20,
            'minimum_installment_amount' => 50,
            'final_due_date' => $now->copy()->addWeek(),
            'expires_at' => $now->copy()->addDays(3),
            'event_date' => $now->copy()->addMonth()->format('Y-m-d H:i:s'),
            'status' => 'active',
            'payment_method' => 'mixed',
            'fname' => 'Venue',
            'lname' => 'Customer',
            'email' => 'venue-reservation@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'state' => 'Distrito Nacional',
            'city' => 'Santo Domingo',
            'zip_code' => '10100',
            'address' => 'Av. Venue',
            'created_at' => $now,
            'updated_at' => $now,
        ], $overrides));
    }
}
