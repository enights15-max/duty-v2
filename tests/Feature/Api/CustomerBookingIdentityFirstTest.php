<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\CustomerController;
use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class CustomerBookingIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'follows', 'event_rewards'];
    protected array $baselineTruncate = [
        'admins',
        'page_headings',
        'event_reward_claim_logs',
        'event_reward_instances',
        'event_reward_definitions',
        'bookings',
        'event_contents',
        'events',
        'organizer_infos',
        'organizers',
        'customers',
        'users',
        'identities',
        'identity_members',
        'follows',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureLanguagesTable();
        $this->ensureDefaultLanguage();
        $this->ensureCustomerBookingTables();
        $this->seedAdminAndLanguageContent();
        $this->seedCustomerActor();
    }

    public function test_customer_dashboard_and_bookings_resolve_identity_first_organizer_name_from_event_ownership(): void
    {
        $bookingId = $this->seedIdentityBackedBooking();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $dashboardRequest = Request::create('/api/customers/dashboard', 'GET');
        $dashboardRequest->headers->set('Accept-Language', 'en');
        $dashboardResponse = app(CustomerController::class)->dashboard($dashboardRequest);
        $dashboardPayload = $dashboardResponse->getData(true);

        $bookingsRequest = Request::create('/api/customers/bookings', 'GET');
        $bookingsRequest->headers->set('Accept-Language', 'en');
        $bookingsResponse = app(CustomerController::class)->bookings($bookingsRequest);
        $bookingsPayload = $bookingsResponse->getData(true);

        $this->assertTrue($dashboardPayload['success']);
        $this->assertTrue($bookingsPayload['success']);

        $dashboardBooking = collect($dashboardPayload['data']['bookings'])->firstWhere('id', $bookingId);
        $bookingRecord = collect($bookingsPayload['data']['bookings'])->firstWhere('id', $bookingId);

        $this->assertSame('Identity Collective', $dashboardBooking['organizer_name'] ?? null);
        $this->assertSame('Identity Collective', $bookingRecord['organizer_name'] ?? null);
        $this->assertSame('Identity Rooftop', $bookingRecord['event_title'] ?? null);
    }

    public function test_customer_booking_details_returns_identity_backed_organizer_payload(): void
    {
        $bookingId = $this->seedIdentityBackedBooking();
        $this->seedBookingReward($bookingId, 4501);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $request = Request::create('/api/customers/booking/details', 'GET', [
            'booking_id' => $bookingId,
        ]);
        $request->headers->set('Accept-Language', 'en');

        $response = app(CustomerController::class)->booking_details($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['success']);
        $this->assertSame(701, $payload['data']['organizer']['id'] ?? null);
        $this->assertSame(701, $payload['data']['organizer']['identity_id'] ?? null);
        $this->assertSame(501, $payload['data']['organizer']['legacy_organizer_id'] ?? null);
        $this->assertSame('Identity Collective', $payload['data']['organizer']['organizer_name'] ?? null);
        $this->assertCount(1, $payload['data']['rewards'] ?? []);
        $this->assertCount(1, $payload['data']['booking']['rewards'] ?? []);
        $this->assertSame('Welcome drink', $payload['data']['booking']['rewards'][0]['definition']['title'] ?? null);
        $this->assertSame('activated', $payload['data']['booking']['rewards'][0]['status'] ?? null);
    }

    private function seedAdminAndLanguageContent(): void
    {
        DB::table('languages')->updateOrInsert(
            ['id' => 1],
            [
                'name' => 'English',
                'code' => 'en',
                'direction' => 'ltr',
                'is_default' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );

        DB::table('admins')->insert([
            'id' => 1,
            'username' => 'admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('page_headings')->insert([
            'language_id' => 1,
            'customer_dashboard_page_title' => 'Dashboard',
            'customer_booking_page_title' => 'Bookings',
            'customer_booking_details_page_title' => 'Booking details',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedCustomerActor(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'customer@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 101,
            'email' => 'customer@example.com',
            'fname' => 'Test',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedIdentityBackedBooking(): int
    {
        DB::table('organizers')->insert([
            'id' => 501,
            'username' => 'legacy_collective',
            'email' => 'legacy@collective.test',
            'phone' => '8091231234',
            'status' => '1',
            'created_at' => now()->subMonth(),
            'updated_at' => now()->subMonth(),
        ]);

        DB::table('organizer_infos')->insert([
            'organizer_id' => 501,
            'language_id' => 1,
            'name' => 'Legacy Collective',
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'designation' => 'Promoter',
            'details' => 'Legacy organizer details',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 701,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9001,
            'display_name' => 'Identity Collective',
            'slug' => 'identity-collective',
            'meta' => json_encode([
                'legacy_id' => 501,
                'legacy_source' => 'organizer',
                'city' => 'Santo Domingo',
                'country' => 'DO',
                'designation' => 'Identity-first promoter',
            ]),
            'created_at' => now()->subWeeks(2),
            'updated_at' => now()->subWeeks(2),
        ]);

        DB::table('events')->insert([
            'id' => 4501,
            'owner_identity_id' => 701,
            'organizer_id' => 501,
            'status' => 1,
            'thumbnail' => 'identity-event.jpg',
            'end_date_time' => now()->addDays(9),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 4501,
            'language_id' => 1,
            'title' => 'Identity Rooftop',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return (int) DB::table('bookings')->insertGetId([
            'customer_id' => 101,
            'event_id' => 4501,
            'organizer_id' => 501,
            'organizer_identity_id' => null,
            'price' => 150,
            'tax' => 0,
            'discount' => 0,
            'invoice' => 'booking-4501.pdf',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedBookingReward(int $bookingId, int $eventId): void
    {
        DB::table('event_reward_definitions')->insert([
            'id' => 8801,
            'event_id' => $eventId,
            'title' => 'Welcome drink',
            'reward_type' => 'drink',
            'trigger_mode' => 'on_ticket_scan',
            'fulfillment_mode' => 'qr_claim',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_instances')->insert([
            'id' => 9801,
            'event_id' => $eventId,
            'reward_definition_id' => 8801,
            'booking_id' => $bookingId,
            'claim_code' => 'DRINK-001194-01-ABCD',
            'claim_qr_payload' => 'duty://event-reward-claim?code=DRINK-001194-01-ABCD',
            'status' => 'activated',
            'activated_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureCustomerBookingTables(): void
    {
        if (!Schema::hasTable('admins')) {
            Schema::create('admins', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('page_headings')) {
            Schema::create('page_headings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('customer_dashboard_page_title')->nullable();
                $table->string('customer_booking_page_title')->nullable();
                $table->string('customer_booking_details_page_title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('photo')->nullable();
                $table->string('phone')->nullable();
                $table->string('facebook')->nullable();
                $table->string('twitter')->nullable();
                $table->string('linkedin')->nullable();
                $table->string('status')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'photo' => fn (Blueprint $table) => $table->string('photo')->nullable(),
            'facebook' => fn (Blueprint $table) => $table->string('facebook')->nullable(),
            'twitter' => fn (Blueprint $table) => $table->string('twitter')->nullable(),
            'linkedin' => fn (Blueprint $table) => $table->string('linkedin')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('organizers', $column)) {
                Schema::table('organizers', $definition);
            }
        }

        if (!Schema::hasTable('organizer_infos')) {
            Schema::create('organizer_infos', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->string('city')->nullable();
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('address')->nullable();
                $table->string('designation')->nullable();
                $table->text('details')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'state' => fn (Blueprint $table) => $table->string('state')->nullable(),
            'zip_code' => fn (Blueprint $table) => $table->string('zip_code')->nullable(),
            'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('organizer_infos', $column)) {
                Schema::table('organizer_infos', $definition);
            }
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->integer('status')->default(1);
                $table->string('thumbnail')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'venue_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_id')->nullable(),
            'status' => fn (Blueprint $table) => $table->integer('status')->default(1),
            'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
            'end_date_time' => fn (Blueprint $table) => $table->dateTime('end_date_time')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->decimal('discount', 15, 2)->default(0);
                $table->string('invoice')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'customer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('customer_id')->nullable(),
            'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'organizer_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_identity_id')->nullable(),
            'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->default(0),
            'tax' => fn (Blueprint $table) => $table->decimal('tax', 15, 2)->default(0),
            'discount' => fn (Blueprint $table) => $table->decimal('discount', 15, 2)->default(0),
            'invoice' => fn (Blueprint $table) => $table->string('invoice')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }
    }
}
