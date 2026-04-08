<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Organizer\ReservationController;
use App\Models\Organizer;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationStatusNotificationService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class OrganizerReservationManagementControllerTest extends ActorFeatureTestCase
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
        'organizers',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureOrganizerReservationSchema();
        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldIgnoreMissing();
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);
    }

    public function test_organizer_index_only_shows_reservations_for_owned_events(): void
    {
        $this->seedOrganizer(5101, 'owner_5101');
        $this->seedOrganizer(5102, 'owner_5102');
        $this->seedCustomer(6101);

        $eventOne = $this->seedEvent(7101, 5101, 'Organizer One Event');
        $eventTwo = $this->seedEvent(7102, 5102, 'Organizer Two Event');
        $ticketOne = $this->seedTicket(8101, $eventOne, 'Ticket One', 9);
        $ticketTwo = $this->seedTicket(8102, $eventTwo, 'Ticket Two', 9);

        $this->seedReservation(9101, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-OWN-001',
        ]);

        $this->seedReservation(9102, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-OTHER-001',
        ]);

        auth('organizer')->setUser(Organizer::findOrFail(5101));

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/organizer/event-booking/reservations', 'GET'));
        $data = $view->getData();

        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-OWN-001', optional($data['reservations']->first())->reservation_code);
        $this->assertSame(1, $data['metrics']['total']);
    }

    public function test_organizer_cannot_open_reservation_from_other_organizer(): void
    {
        $this->seedOrganizer(5201, 'owner_5201');
        $this->seedOrganizer(5202, 'owner_5202');
        $this->seedCustomer(6201);

        $eventOne = $this->seedEvent(7201, 5201, 'Scoped Event');
        $eventTwo = $this->seedEvent(7202, 5202, 'Restricted Event');
        $ticketOne = $this->seedTicket(8201, $eventOne, 'Scoped Ticket', 10);
        $ticketTwo = $this->seedTicket(8202, $eventTwo, 'Restricted Ticket', 10);

        $this->seedReservation(9201, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-SCOPED-001',
        ]);
        $this->seedReservation(9202, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-RESTRICTED-001',
        ]);

        auth('organizer')->setUser(Organizer::findOrFail(5201));

        $controller = app(ReservationController::class);
        $controller->show(9201);
        $this->expectException(ModelNotFoundException::class);
        $controller->show(9202);
    }

    public function test_organizer_can_cancel_owned_active_reservation_and_release_inventory(): void
    {
        $this->seedOrganizer(5301, 'owner_5301');
        $this->seedCustomer(6301);

        $eventId = $this->seedEvent(7301, 5301, 'Cancelable Organizer Event');
        $ticketId = $this->seedTicket(8301, $eventId, 'Cancelable Organizer Ticket', 4);
        $this->seedReservation(9301, [
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-ORG-CANCEL-001',
            'quantity' => 2,
            'status' => 'active',
        ]);

        auth('organizer')->setUser(Organizer::findOrFail(5301));

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(
                Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 9301),
                'cancelled',
                Mockery::type('array')
            );
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $controller = app(ReservationController::class);
        $response = $controller->cancel(9301);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertSame('cancelled', DB::table('ticket_reservations')->where('id', 9301)->value('status'));
        $this->assertSame(6, (int) DB::table('tickets')->where('id', $ticketId)->value('ticket_available'));
        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 9301,
            'actor_type' => 'organizer',
            'actor_id' => 5301,
            'action' => 'cancelled',
        ]);
    }

    public function test_organizer_export_only_contains_owned_reservations(): void
    {
        $this->seedOrganizer(5302, 'owner_5302');
        $this->seedOrganizer(5303, 'owner_5303');
        $this->seedCustomer(6302);

        $eventOne = $this->seedEvent(7302, 5302, 'Organizer Export Event One');
        $eventTwo = $this->seedEvent(7303, 5303, 'Organizer Export Event Two');
        $ticketOne = $this->seedTicket(8302, $eventOne, 'Export Ticket One', 5);
        $ticketTwo = $this->seedTicket(8303, $eventTwo, 'Export Ticket Two', 5);

        $this->seedReservation(9302, [
            'event_id' => $eventOne,
            'ticket_id' => $ticketOne,
            'reservation_code' => 'RSV-ORG-EXPORT-OWN',
        ]);
        $this->seedReservation(9303, [
            'event_id' => $eventTwo,
            'ticket_id' => $ticketTwo,
            'reservation_code' => 'RSV-ORG-EXPORT-OTHER',
        ]);

        auth('organizer')->setUser(Organizer::findOrFail(5302));

        $controller = app(ReservationController::class);
        $response = $controller->export(Request::create('/organizer/event-booking/reservations/export', 'GET', [
            'status' => 'all',
        ]));

        ob_start();
        $response->sendContent();
        $csv = ob_get_clean();

        $this->assertStringContainsString('RSV-ORG-EXPORT-OWN', $csv);
        $this->assertStringNotContainsString('RSV-ORG-EXPORT-OTHER', $csv);
    }

    private function ensureOrganizerReservationSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->string('status')->default('1');
                $table->string('theme_version')->default('light');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
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

    private function seedOrganizer(int $id, string $username): void
    {
        DB::table('organizers')->insert([
            'id' => $id,
            'username' => $username,
            'email' => $username . '@example.com',
            'password' => bcrypt('secret'),
            'status' => '1',
            'theme_version' => 'light',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedCustomer(int $id): void
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "organizer-reservation-{$id}@example.com",
            'fname' => 'Organizer',
            'lname' => 'Customer',
            'phone' => '8090000000',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Av. Organizer',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEvent(int $id, int $organizerId, string $title): int
    {
        DB::table('events')->insert([
            'id' => $id,
            'organizer_id' => $organizerId,
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
            'customer_id' => 6101,
            'event_id' => 7101,
            'ticket_id' => 8101,
            'reservation_code' => 'RSV-ORG-SEED-' . $id,
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
            'fname' => 'Organizer',
            'lname' => 'Customer',
            'email' => 'organizer-reservation@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'state' => 'Distrito Nacional',
            'city' => 'Santo Domingo',
            'zip_code' => '10100',
            'address' => 'Av. Organizer',
            'created_at' => $now,
            'updated_at' => $now,
        ], $overrides));
    }
}
