<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use App\Models\Organizer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class SocialFeedControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [
        'users_customers',
        'follows',
        'identities',
        'discovery_catalog',
        'legacy_identity_sources',
    ];

    protected array $baselineTruncate = [
        'follows',
        'wishlists',
        'bookings',
        'event_contents',
        'events',
        'organizer_infos',
        'organizers',
        'customers',
        'users',
        'languages',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureLanguagesTable();
        $this->ensureEventColumns();
        $this->ensureWishlistTable();
        $this->ensureBookingsTable();
    }

    public function test_social_feed_returns_cards_from_followed_people_and_profiles(): void
    {
        DB::table('languages')->insert([
            'id' => 1,
            'name' => 'English',
            'code' => 'en',
            'is_default' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            [
                'id' => 1,
                'email' => 'viewer@example.com',
                'username' => 'viewer',
                'fname' => 'View',
                'lname' => 'Er',
                'password' => bcrypt('secret'),
                'status' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'email' => 'friend@example.com',
                'username' => 'friend',
                'fname' => 'Jade',
                'lname' => 'Rivera',
                'password' => bcrypt('secret'),
                'status' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('organizers')->insert([
            'id' => 10,
            'username' => 'club-mirage',
            'email' => 'club@example.com',
            'password' => bcrypt('secret'),
            'status' => '1',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizer_infos')->insert([
            'id' => 11,
            'language_id' => 1,
            'organizer_id' => 10,
            'name' => 'Club Mirage',
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 100,
                'status' => 1,
                'organizer_id' => null,
                'start_date' => now()->addDays(2),
                'end_date_time' => now()->addDays(2)->addHours(6),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 101,
                'status' => 1,
                'organizer_id' => 10,
                'start_date' => now()->addDays(4),
                'end_date_time' => now()->addDays(4)->addHours(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 102,
                'status' => 1,
                'organizer_id' => null,
                'start_date' => now()->addDays(1),
                'end_date_time' => now()->addDays(1)->addHours(4),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 100,
                'language_id' => 1,
                'title' => 'People Saved This',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 101,
                'language_id' => 1,
                'title' => 'Promoter Drop',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 102,
                'language_id' => 1,
                'title' => 'Network Night',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('follows')->insert([
            [
                'follower_id' => 1,
                'follower_type' => Customer::class,
                'followable_id' => 2,
                'followable_type' => Customer::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'follower_id' => 1,
                'follower_type' => Customer::class,
                'followable_id' => 10,
                'followable_type' => Organizer::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('wishlists')->insert([
            'event_id' => 100,
            'customer_id' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 900,
            'event_id' => 102,
            'customer_id' => 2,
            'paymentStatus' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(1), [], 'sanctum');

        $response = $this->getJson($this->apiUrl('/api/social/feed'), [
            'Accept-Language' => 'en',
        ]);

        $response->assertOk();
        $response->assertJsonPath('success', true);

        $payload = $response->json('data');
        $this->assertIsArray($payload['items']);
        $this->assertGreaterThanOrEqual(3, count($payload['items']));

        $reasonTypes = collect($payload['items'])->pluck('reason_type')->all();
        $this->assertContains('followed_people_interested', $reasonTypes);
        $this->assertContains('followed_people_going', $reasonTypes);
        $this->assertContains('followed_profile_event', $reasonTypes);

        $summary = $payload['summary'];
        $this->assertSame(1, $summary['following_people_count']);
        $this->assertSame(1, $summary['following_profiles_count']);
    }

    protected function ensureLanguagesTable(): void
    {
        if (!Schema::hasTable('languages')) {
            Schema::create('languages', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('code')->nullable();
                $table->tinyInteger('is_default')->default(0);
                $table->timestamps();
            });
        }
    }

    protected function ensureWishlistTable(): void
    {
        if (!Schema::hasTable('wishlists')) {
            Schema::create('wishlists', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureEventColumns(): void
    {
        $columns = [
            'status' => fn (Blueprint $table) => $table->tinyInteger('status')->default(1),
            'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
            'start_date' => fn (Blueprint $table) => $table->timestamp('start_date')->nullable(),
            'start_time' => fn (Blueprint $table) => $table->string('start_time')->nullable(),
            'end_date_time' => fn (Blueprint $table) => $table->timestamp('end_date_time')->nullable(),
            'address' => fn (Blueprint $table) => $table->text('address')->nullable(),
            'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
        ];

        foreach ($columns as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', function (Blueprint $table) use ($definition) {
                    $definition($table);
                });
            }
        }
    }

    protected function ensureBookingsTable(): void
    {
        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->string('scan_status')->nullable();
                $table->timestamps();
            });
        }
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
