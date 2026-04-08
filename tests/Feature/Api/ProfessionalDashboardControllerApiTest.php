<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalDashboardControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [
        'users_customers',
        'identities',
        'legacy_identity_sources',
    ];

    protected array $baselineTruncate = [
        'identity_balance_transactions',
        'identity_balances',
        'identity_members',
        'identities',
        'organizers',
        'artists',
        'venues',
        'reviews',
        'bookings',
        'event_lineups',
        'event_artist',
        'event_contents',
        'events',
        'languages',
        'customers',
        'users',
    ];

    protected bool $baselineDefaultLanguage = false;

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureProfessionalDashboardSchema();
        $this->ensureDefaultLanguage();
    }

    public function test_organizer_dashboard_returns_real_stats_and_upcoming_events(): void
    {
        DB::table('users')->insert([
            'id' => 401,
            'email' => 'organizer-dashboard@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 401,
            'email' => 'organizer-dashboard@example.com',
            'password' => bcrypt('secret'),
            'fname' => 'Org',
            'lname' => 'Owner',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 941,
            'owner_user_id' => 401,
            'type' => 'organizer',
            'status' => 'active',
            'display_name' => 'Pulse Organizer',
            'slug' => 'pulse-organizer',
            'meta' => json_encode(['legacy_id' => 741]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 941,
            'user_id' => 401,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 741,
            'email' => 'organizer-dashboard@example.com',
            'organizer_name' => 'Pulse Organizer',
            'amount' => 180.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 941,
            'legacy_type' => 'organizer',
            'legacy_id' => 741,
            'balance' => 180.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 501,
                'organizer_id' => 741,
                'owner_identity_id' => 941,
                'thumbnail' => 'event-a.jpg',
                'status' => 1,
                'date_type' => 'single',
                'start_date' => now()->addDays(5)->toDateString(),
                'start_time' => '20:00',
                'end_date' => now()->addDays(5)->toDateString(),
                'end_time' => '23:00',
                'end_date_time' => now()->addDays(5)->setTime(23, 0),
                'event_type' => 'venue',
                'venue_name_snapshot' => 'Pulse Hall',
                'venue_city_snapshot' => 'Santo Domingo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 502,
                'organizer_id' => 741,
                'owner_identity_id' => 941,
                'thumbnail' => 'event-b.jpg',
                'status' => 1,
                'date_type' => 'single',
                'start_date' => now()->subDays(2)->toDateString(),
                'start_time' => '21:00',
                'end_date' => now()->subDays(2)->toDateString(),
                'end_time' => '23:00',
                'end_date_time' => now()->subDays(2)->setTime(23, 0),
                'event_type' => 'venue',
                'venue_name_snapshot' => 'Pulse Hall',
                'venue_city_snapshot' => 'Santo Domingo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 501,
                'language_id' => $this->defaultLanguageId(),
                'event_category_id' => 1,
                'title' => 'Pulse Nights',
                'slug' => 'pulse-nights',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 502,
                'language_id' => $this->defaultLanguageId(),
                'event_category_id' => 1,
                'title' => 'Past Pulse',
                'slug' => 'past-pulse',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            [
                'id' => 801,
                'customer_id' => 999,
                'event_id' => 501,
                'organizer_id' => 741,
                'organizer_identity_id' => 941,
                'price' => 120.00,
                'commission' => 20.00,
                'quantity' => 3,
                'paymentStatus' => 'Completed',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 802,
                'customer_id' => 999,
                'event_id' => 502,
                'organizer_id' => 741,
                'organizer_identity_id' => 941,
                'price' => 80.00,
                'commission' => 10.00,
                'quantity' => 2,
                'paymentStatus' => 'Completed',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('identity_balance_transactions')->insert([
            [
                'id' => '11111111-1111-1111-1111-111111111111',
                'identity_id' => 941,
                'type' => 'credit',
                'amount' => 55.00,
                'description' => 'Wallet transfer received',
                'reference_type' => 'wallet_transfer',
                'reference_id' => 'ref-1',
                'balance_before' => 125.00,
                'balance_after' => 180.00,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('reviews')->insert([
            'customer_id' => 401,
            'event_id' => 501,
            'reviewable_id' => 741,
            'reviewable_type' => \App\Models\Organizer::class,
            'rating' => 4,
            'status' => 'published',
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(401), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '941')
            ->getJson($this->apiUrl('/api/customers/professional/dashboard'));

        $response->assertOk()
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.stats.balance', 180)
            ->assertJsonPath('data.stats.event_count', 2)
            ->assertJsonPath('data.stats.ticket_sales', 5)
            ->assertJsonPath('data.stats.average_rating', '4.0')
            ->assertJsonPath('data.stats.review_count', 1)
            ->assertJsonPath('data.stats.gross_sales', 200)
            ->assertJsonPath('data.stats.net_sales', 170)
            ->assertJsonPath('data.stats.ledger_inflow', 55)
            ->assertJsonPath('data.stats.ledger_outflow', 0)
            ->assertJsonPath('data.stats.ledger_entries', 1)
            ->assertJsonCount(1, 'data.upcoming_events')
            ->assertJsonPath('data.upcoming_events.0.title', 'Pulse Nights');
    }

    public function test_artist_dashboard_uses_lineup_events_and_artist_reviews(): void
    {
        DB::table('users')->insert([
            'id' => 402,
            'email' => 'artist-dashboard@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 402,
            'email' => 'artist-dashboard@example.com',
            'password' => bcrypt('secret'),
            'fname' => 'Art',
            'lname' => 'Owner',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 942,
            'owner_user_id' => 402,
            'type' => 'artist',
            'status' => 'active',
            'display_name' => 'DJ Pulse',
            'slug' => 'dj-pulse',
            'meta' => json_encode(['legacy_id' => 742]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 942,
            'user_id' => 402,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 742,
            'name' => 'DJ Pulse',
            'username' => 'dj-pulse',
            'amount' => 90.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 942,
            'legacy_type' => 'artist',
            'legacy_id' => 742,
            'balance' => 90.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 503,
            'thumbnail' => 'artist-event.jpg',
            'status' => 1,
            'date_type' => 'single',
            'start_date' => now()->addDays(10)->toDateString(),
            'start_time' => '22:00',
            'end_date' => now()->addDays(10)->toDateString(),
            'end_time' => '23:59',
            'end_date_time' => now()->addDays(10)->setTime(23, 59),
            'event_type' => 'venue',
            'venue_name_snapshot' => 'Loft 9',
            'venue_city_snapshot' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 503,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => 1,
            'title' => 'Artist Session',
            'slug' => 'artist-session',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_lineups')->insert([
            'event_id' => 503,
            'artist_id' => 742,
            'source_type' => 'artist',
            'display_name' => 'DJ Pulse',
            'sort_order' => 1,
            'is_headliner' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 803,
            'customer_id' => 999,
            'event_id' => 503,
            'price' => 160.00,
            'commission' => 35.00,
            'quantity' => 4,
            'paymentStatus' => 'Completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reviews')->insert([
            'customer_id' => 402,
            'event_id' => 503,
            'reviewable_id' => 742,
            'reviewable_type' => \App\Models\Artist::class,
            'rating' => 5,
            'status' => 'published',
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(402), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '942')
            ->getJson($this->apiUrl('/api/customers/professional/dashboard'));

        $response->assertOk()
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.stats.balance', 90)
            ->assertJsonPath('data.stats.event_count', 1)
            ->assertJsonPath('data.stats.ticket_sales', 4)
            ->assertJsonPath('data.stats.average_rating', '5.0')
            ->assertJsonPath('data.stats.review_count', 1)
            ->assertJsonPath('data.stats.gross_sales', 160)
            ->assertJsonPath('data.stats.net_sales', 125)
            ->assertJsonCount(1, 'data.upcoming_events')
            ->assertJsonPath('data.upcoming_events.0.title', 'Artist Session');
    }

    public function test_dashboard_supports_time_ranges_and_comparisons(): void
    {
        DB::table('users')->insert([
            'id' => 403,
            'email' => 'organizer-ranged@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 403,
            'email' => 'organizer-ranged@example.com',
            'password' => bcrypt('secret'),
            'fname' => 'Range',
            'lname' => 'Owner',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 943,
            'owner_user_id' => 403,
            'type' => 'organizer',
            'status' => 'active',
            'display_name' => 'Range Organizer',
            'slug' => 'range-organizer',
            'meta' => json_encode(['legacy_id' => 743]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 943,
            'user_id' => 403,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 743,
            'email' => 'organizer-ranged@example.com',
            'organizer_name' => 'Range Organizer',
            'amount' => 250.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 943,
            'legacy_type' => 'organizer',
            'legacy_id' => 743,
            'balance' => 250.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 504,
                'organizer_id' => 743,
                'owner_identity_id' => 943,
                'thumbnail' => 'range-a.jpg',
                'status' => 1,
                'date_type' => 'single',
                'start_date' => now()->subDays(3)->toDateString(),
                'start_time' => '20:00',
                'end_date' => now()->subDays(3)->toDateString(),
                'end_time' => '23:00',
                'end_date_time' => now()->subDays(3)->setTime(23, 0),
                'event_type' => 'venue',
                'created_at' => now()->subDays(4),
                'updated_at' => now(),
            ],
            [
                'id' => 505,
                'organizer_id' => 743,
                'owner_identity_id' => 943,
                'thumbnail' => 'range-b.jpg',
                'status' => 1,
                'date_type' => 'single',
                'start_date' => now()->subDays(10)->toDateString(),
                'start_time' => '20:00',
                'end_date' => now()->subDays(10)->toDateString(),
                'end_time' => '23:00',
                'end_date_time' => now()->subDays(10)->setTime(23, 0),
                'event_type' => 'venue',
                'created_at' => now()->subDays(11),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 504,
                'language_id' => $this->defaultLanguageId(),
                'event_category_id' => 1,
                'title' => 'Range Current',
                'slug' => 'range-current',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 505,
                'language_id' => $this->defaultLanguageId(),
                'event_category_id' => 1,
                'title' => 'Range Previous',
                'slug' => 'range-previous',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            [
                'id' => 804,
                'customer_id' => 999,
                'event_id' => 504,
                'organizer_id' => 743,
                'organizer_identity_id' => 943,
                'price' => 200.00,
                'commission' => 20.00,
                'quantity' => 5,
                'paymentStatus' => 'Completed',
                'created_at' => now()->subDays(2),
                'updated_at' => now(),
            ],
            [
                'id' => 805,
                'customer_id' => 999,
                'event_id' => 505,
                'organizer_id' => 743,
                'organizer_identity_id' => 943,
                'price' => 100.00,
                'commission' => 10.00,
                'quantity' => 2,
                'paymentStatus' => 'Completed',
                'created_at' => now()->subDays(9),
                'updated_at' => now(),
            ],
        ]);

        DB::table('reviews')->insert([
            [
                'customer_id' => 403,
                'event_id' => 504,
                'reviewable_id' => 743,
                'reviewable_type' => \App\Models\Organizer::class,
                'rating' => 5,
                'status' => 'published',
                'submitted_at' => now()->subDays(2),
                'created_at' => now()->subDays(2),
                'updated_at' => now(),
            ],
            [
                'customer_id' => 403,
                'event_id' => 505,
                'reviewable_id' => 743,
                'reviewable_type' => \App\Models\Organizer::class,
                'rating' => 4,
                'status' => 'published',
                'submitted_at' => now()->subDays(9),
                'created_at' => now()->subDays(9),
                'updated_at' => now(),
            ],
        ]);

        DB::table('identity_balance_transactions')->insert([
            [
                'id' => '22222222-1111-1111-1111-111111111111',
                'identity_id' => 943,
                'type' => 'credit',
                'amount' => 80.00,
                'description' => 'Wallet transfer received',
                'reference_type' => 'wallet_transfer',
                'reference_id' => 'range-ref-1',
                'balance_before' => 170.00,
                'balance_after' => 250.00,
                'created_at' => now()->subDays(2),
                'updated_at' => now(),
            ],
            [
                'id' => '33333333-1111-1111-1111-111111111111',
                'identity_id' => 943,
                'type' => 'debit',
                'amount' => 20.00,
                'description' => 'Wallet transfer sent',
                'reference_type' => 'wallet_transfer',
                'reference_id' => 'range-ref-2',
                'balance_before' => 190.00,
                'balance_after' => 170.00,
                'created_at' => now()->subDays(2),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs(Customer::findOrFail(403), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '943')
            ->getJson($this->apiUrl('/api/customers/professional/dashboard?range=7d'));

        $response->assertOk()
            ->assertJsonPath('data.range', '7d')
            ->assertJsonPath('data.stats.event_count', 1)
            ->assertJsonPath('data.stats.ticket_sales', 5)
            ->assertJsonPath('data.stats.gross_sales', 200)
            ->assertJsonPath('data.stats.net_sales', 180)
            ->assertJsonPath('data.stats.review_count', 1)
            ->assertJsonPath('data.stats.ledger_inflow', 80)
            ->assertJsonPath('data.stats.ledger_outflow', 20)
            ->assertJsonPath('data.comparisons.ticket_sales.previous', 2)
            ->assertJsonPath('data.comparisons.ticket_sales.delta', 3)
            ->assertJsonPath('data.comparisons.gross_sales.previous', 100)
            ->assertJsonPath('data.comparisons.net_sales.previous', 90);
    }

    private function ensureProfessionalDashboardSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('organizer_name')->nullable();
                $table->string('email')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('organizers') && !Schema::hasColumn('organizers', 'organizer_name')) {
            Schema::table('organizers', function (Blueprint $table): void {
                $table->string('organizer_name')->nullable();
            });
        }

        if (Schema::hasTable('organizers') && !Schema::hasColumn('organizers', 'amount')) {
            Schema::table('organizers', function (Blueprint $table): void {
                $table->decimal('amount', 15, 2)->default(0);
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('artists') && !Schema::hasColumn('artists', 'amount')) {
            Schema::table('artists', function (Blueprint $table): void {
                $table->decimal('amount', 15, 2)->default(0);
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('city')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('venues') && !Schema::hasColumn('venues', 'amount')) {
            Schema::table('venues', function (Blueprint $table): void {
                $table->decimal('amount', 15, 2)->default(0);
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->string('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('event_type')->nullable();
                $table->string('venue_name_snapshot')->nullable();
                $table->string('venue_city_snapshot')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
            'status' => fn (Blueprint $table) => $table->tinyInteger('status')->default(1),
            'date_type' => fn (Blueprint $table) => $table->string('date_type')->nullable(),
            'start_date' => fn (Blueprint $table) => $table->date('start_date')->nullable(),
            'start_time' => fn (Blueprint $table) => $table->string('start_time')->nullable(),
            'end_date' => fn (Blueprint $table) => $table->date('end_date')->nullable(),
            'end_time' => fn (Blueprint $table) => $table->string('end_time')->nullable(),
            'end_date_time' => fn (Blueprint $table) => $table->dateTime('end_date_time')->nullable(),
            'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
            'venue_name_snapshot' => fn (Blueprint $table) => $table->string('venue_name_snapshot')->nullable(),
            'venue_city_snapshot' => fn (Blueprint $table) => $table->string('venue_city_snapshot')->nullable(),
            'venue_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_id')->nullable(),
            'venue_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_identity_id')->nullable(),
        ] as $column => $definition) {
            if (Schema::hasTable('events') && !Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id');
                $table->unsignedBigInteger('event_category_id')->default(1);
                $table->string('title');
                $table->string('slug');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_dates')) {
            Schema::create('event_dates', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->string('end_time')->nullable();
                $table->dateTime('start_date_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_artist')) {
            Schema::create('event_artist', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_lineups')) {
            Schema::create('event_lineups', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->string('source_type', 32);
                $table->string('display_name');
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_headliner')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->integer('quantity')->default(1);
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('bookings') && !Schema::hasColumn('bookings', 'paymentStatus')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('paymentStatus')->nullable();
            });
        }

        foreach ([
            'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->default(0),
            'commission' => fn (Blueprint $table) => $table->decimal('commission', 15, 2)->default(0),
        ] as $column => $definition) {
            if (Schema::hasTable('bookings') && !Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }

        if (!Schema::hasTable('reviews')) {
            Schema::create('reviews', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('reviewable_id');
                $table->string('reviewable_type');
                $table->integer('rating');
                $table->text('comment')->nullable();
                $table->string('status')->default('published');
                $table->json('meta')->nullable();
                $table->timestamp('submitted_at')->nullable();
                $table->timestamps();
            });
        }
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
