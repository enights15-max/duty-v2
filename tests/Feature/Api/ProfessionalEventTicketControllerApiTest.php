<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalEventTicketControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureTicketManagementSchema();
        $this->truncateTables([
            'basic_settings',
            'venues',
            'events',
            'event_contents',
            'tickets',
            'ticket_contents',
            'ticket_price_schedules',
            'ticket_reservations',
            'bookings',
        ]);

        if (!DB::table('basic_settings')->exists()) {
            DB::table('basic_settings')->insert([
                'id' => 1,
                'event_country_status' => 0,
                'event_state_status' => 0,
            ]);
        }
    }

    public function test_organizer_can_create_simple_ticket_with_schedules_and_reservations(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $eventId = $this->seedOrganizerEvent($identityId);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets"),
            [
                'title' => 'General Admission',
                'description' => 'Ingreso general del evento',
                'pricing_type' => 'normal',
                'price' => 650,
                'ticket_available_type' => 'limited',
                'ticket_available' => 120,
                'max_ticket_buy_type' => 'limited',
                'max_buy_ticket' => 4,
                'reservation_enabled' => true,
                'reservation_deposit_type' => 'fixed',
                'reservation_deposit_value' => 150,
                'reservation_final_due_date' => '2026-05-20',
                'reservation_min_installment_amount' => 75,
                'sale_status' => 'active',
                'price_schedules' => [
                    [
                        'label' => 'Launch',
                        'effective_from' => now()->toIso8601String(),
                        'price' => 550,
                        'sort_order' => 0,
                        'is_active' => true,
                    ],
                ],
            ]
        );

        $response->assertCreated();
        $response->assertJsonPath('data.title', 'General Admission');
        $response->assertJsonPath('data.reservation_enabled', true);
        $response->assertJsonPath('data.max_buy_ticket', 4);
        $response->assertJsonPath('data.price_schedules.0.label', 'Launch');

        $ticketId = (int) $response->json('data.id');

        $this->assertDatabaseHas('tickets', [
            'id' => $ticketId,
            'event_id' => $eventId,
            'title' => 'General Admission',
            'reservation_enabled' => 1,
            'sale_status' => 'active',
        ]);
        $this->assertDatabaseHas('ticket_contents', [
            'ticket_id' => $ticketId,
            'title' => 'General Admission',
        ]);
        $this->assertSame(
            1,
            DB::table('ticket_price_schedules')->where('ticket_id', $ticketId)->count()
        );
    }

    public function test_ticket_update_rejects_inventory_below_active_reservations(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $eventId = $this->seedOrganizerEvent($identityId);
        $ticketId = $this->seedSimpleTicket($eventId, 'VIP Access', 40);

        DB::table('ticket_reservations')->insert([
            'ticket_id' => $ticketId,
            'event_id' => $eventId,
            'quantity' => 12,
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets/{$ticketId}"),
            [
                'title' => 'VIP Access',
                'pricing_type' => 'normal',
                'price' => 1200,
                'ticket_available_type' => 'limited',
                'ticket_available' => 8,
                'max_ticket_buy_type' => 'limited',
                'max_buy_ticket' => 2,
                'reservation_enabled' => false,
                'sale_status' => 'active',
            ]
        );

        $response->assertStatus(422);
        $response->assertJsonPath(
            'message',
            'No puedes dejar disponibles por debajo de las reservas activas de este ticket.'
        );
    }

    public function test_organizer_can_duplicate_ticket_and_clone_schedule_into_paused_copy(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $eventId = $this->seedOrganizerEvent($identityId);
        $ticketId = $this->seedSimpleTicket($eventId, 'Balcony', 32);

        DB::table('ticket_price_schedules')->insert([
            'ticket_id' => $ticketId,
            'label' => 'Presale',
            'effective_from' => now(),
            'price' => 900,
            'sort_order' => 0,
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets/{$ticketId}/duplicate")
        );

        $response->assertCreated();
        $response->assertJsonPath('data.sale_status', 'paused');
        $response->assertJsonPath('data.price_schedules.0.label', 'Presale');

        $duplicateId = (int) $response->json('data.id');
        $this->assertDatabaseHas('tickets', [
            'id' => $duplicateId,
            'event_id' => $eventId,
            'sale_status' => 'paused',
        ]);
        $this->assertSame(
            1,
            DB::table('ticket_price_schedules')->where('ticket_id', $duplicateId)->count()
        );
    }

    public function test_venue_identity_can_list_and_archive_its_own_event_tickets(): void
    {
        [$identityId, $customerId] = $this->seedVenueIdentity();
        $eventId = $this->seedVenueEvent($identityId);
        $ticketId = $this->seedSimpleTicket($eventId, 'Venue General', 80);

        Sanctum::actingAs(Customer::findOrFail($customerId), [], 'sanctum');

        $indexResponse = $this->withHeader('X-Identity-Id', (string) $identityId)->get(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets")
        );

        $indexResponse->assertOk();
        $indexResponse->assertJsonPath('data.tickets.0.id', $ticketId);

        $statusResponse = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets/{$ticketId}/status"),
            ['sale_status' => 'archived']
        );

        $statusResponse->assertOk();
        $statusResponse->assertJsonPath('data.sale_status', 'archived');
        $this->assertDatabaseHas('tickets', [
            'id' => $ticketId,
            'sale_status' => 'archived',
        ]);
    }

    public function test_venue_identity_cannot_manage_tickets_for_organizer_owned_event_at_same_venue(): void
    {
        $organizerIdentityId = $this->seedOrganizerIdentity();
        [$venueIdentityId, $venueCustomerId] = $this->seedVenueIdentity();

        $eventId = (int) DB::table('events')->insertGetId([
            'venue_id' => 77,
            'venue_identity_id' => $venueIdentityId,
            'organizer_id' => 901,
            'owner_identity_id' => $organizerIdentityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-05-10',
            'start_time' => '20:00',
            'end_date' => '2026-05-11',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(10),
            'status' => 1,
            'review_status' => 'approved',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'title' => 'Organizer Event At Venue',
            'slug' => 'organizer-event-at-venue',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $ticketId = $this->seedSimpleTicket($eventId, 'Organizer Owned Ticket', 80);

        Sanctum::actingAs(Customer::findOrFail($venueCustomerId), [], 'sanctum');

        $indexResponse = $this->withHeader('X-Identity-Id', (string) $venueIdentityId)->get(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets")
        );

        $indexResponse->assertStatus(404);
        $indexResponse->assertJsonPath('message', 'Event not found for the active profile.');

        $statusResponse = $this->withHeader('X-Identity-Id', (string) $venueIdentityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}/tickets/{$ticketId}/status"),
            ['sale_status' => 'archived']
        );

        $statusResponse->assertStatus(404);
        $statusResponse->assertJsonPath('message', 'Event not found for the active profile.');

        $this->assertDatabaseHas('tickets', [
            'id' => $ticketId,
            'sale_status' => 'active',
        ]);
    }

    private function ensureTicketManagementSchema(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table) {
                $table->id();
                $table->tinyInteger('event_country_status')->default(0);
                $table->tinyInteger('event_state_status')->default(0);
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->string('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->string('review_status')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id');
                $table->unsignedBigInteger('event_category_id')->nullable();
                $table->string('title');
                $table->string('slug')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->text('description')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->nullable();
                $table->decimal('f_price', 15, 2)->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->nullable();
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->nullable();
                $table->string('early_bird_discount')->nullable();
                $table->string('early_bird_discount_type')->nullable();
                $table->decimal('early_bird_discount_amount', 15, 2)->nullable();
                $table->date('early_bird_discount_date')->nullable();
                $table->string('early_bird_discount_time')->nullable();
                $table->json('variations')->nullable();
                $table->unsignedTinyInteger('normal_ticket_slot_enable')->default(0);
                $table->unsignedBigInteger('normal_ticket_slot_unique_id')->nullable();
                $table->unsignedTinyInteger('free_tickete_slot_enable')->default(0);
                $table->unsignedBigInteger('free_tickete_slot_unique_id')->nullable();
                $table->decimal('slot_seat_min_price', 15, 2)->nullable();
                $table->boolean('reservation_enabled')->default(false);
                $table->string('reservation_deposit_type', 32)->nullable();
                $table->decimal('reservation_deposit_value', 15, 2)->nullable();
                $table->date('reservation_final_due_date')->nullable();
                $table->decimal('reservation_min_installment_amount', 15, 2)->nullable();
                $table->string('sale_status')->default('active');
                $table->timestamp('archived_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_contents')) {
            Schema::create('ticket_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->unsignedBigInteger('language_id');
                $table->string('title');
                $table->text('description')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_price_schedules')) {
            Schema::create('ticket_price_schedules', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->string('label')->nullable();
                $table->dateTime('effective_from');
                $table->decimal('price', 15, 2);
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_reservations')) {
            Schema::create('ticket_reservations', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedInteger('quantity')->default(1);
                $table->string('status')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedInteger('quantity')->default(1);
                $table->json('variation')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedOrganizerIdentity(): int
    {
        DB::table('users')->insert([
            'id' => 11,
            'email' => 'organizer-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 101,
            'email' => 'organizer-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => 11,
            'type' => 'organizer',
            'status' => 'active',
            'display_name' => 'Duty Organizer',
            'slug' => 'duty-organizer',
            'meta' => json_encode(['legacy_id' => 901]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => 11,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $identityId;
    }

    private function seedVenueIdentity(): array
    {
        DB::table('users')->insert([
            'id' => 22,
            'email' => 'venue-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 202,
            'email' => 'venue-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('venues')->insert([
            'id' => 77,
            'name' => 'Duty Arena',
            'username' => 'duty-arena',
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'Dominican Republic',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => 22,
            'type' => 'venue',
            'status' => 'active',
            'display_name' => 'Duty Arena',
            'slug' => 'duty-arena',
            'meta' => json_encode(['legacy_id' => 77]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => 22,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return [$identityId, 202];
    }

    private function seedOrganizerEvent(int $identityId): int
    {
        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-05-10',
            'start_time' => '20:00',
            'end_date' => '2026-05-11',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(10),
            'status' => 1,
            'review_status' => 'approved',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'title' => 'Organizer Event',
            'slug' => 'organizer-event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function seedVenueEvent(int $identityId): int
    {
        $eventId = (int) DB::table('events')->insertGetId([
            'venue_id' => 77,
            'venue_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-05-10',
            'start_time' => '20:00',
            'end_date' => '2026-05-11',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(10),
            'status' => 1,
            'review_status' => 'approved',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'title' => 'Venue Event',
            'slug' => 'venue-event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function seedSimpleTicket(int $eventId, string $title, int $available): int
    {
        $ticketId = (int) DB::table('tickets')->insertGetId([
            'event_id' => $eventId,
            'event_type' => 'venue',
            'title' => $title,
            'pricing_type' => 'normal',
            'price' => 500,
            'f_price' => 500,
            'ticket_available_type' => 'limited',
            'ticket_available' => $available,
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 4,
            'sale_status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_contents')->insert([
            'ticket_id' => $ticketId,
            'language_id' => $this->defaultLanguageId(),
            'title' => $title,
            'description' => 'Ticket description',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $ticketId;
    }

    private function defaultLanguageId(): int
    {
        return (int) DB::table('languages')->where('is_default', 1)->value('id');
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
