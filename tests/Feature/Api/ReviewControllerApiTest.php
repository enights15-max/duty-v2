<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ReviewControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'loyalty'];
    protected array $baselineTruncate = ['loyalty_point_transactions'];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureReviewSchema();
        $this->truncateTables([
            'reviews',
            'bookings',
            'event_contents',
            'event_lineups',
            'events',
            'identities',
            'identity_members',
            'artists',
            'organizer_infos',
            'organizers',
            'customers',
            'users',
        ]);
        $this->seedCustomer();
    }

    public function test_pending_reviews_returns_event_organizer_and_artist_targets_for_concluded_booking(): void
    {
        $organizerId = $this->seedOrganizer('Duty Collective');
        $artistId = $this->seedArtist('DJ Nova');
        $eventId = $this->seedEvent($organizerId, 'Duty Closing Set');
        $this->seedBooking($eventId, $organizerId);
        $this->seedLineup($eventId, $artistId, 'DJ Nova');

        Sanctum::actingAs(Customer::findOrFail(501), [], 'sanctum');

        $response = $this->getJson($this->apiUrl('/api/customers/reviews/pending'));

        $response->assertOk();
        $response->assertJsonPath('data.items.0.event_id', $eventId);
        $response->assertJsonCount(3, 'data.items.0.targets');
        $response->assertJsonFragment([
            'target_type' => 'event',
            'target_id' => $eventId,
        ]);
        $response->assertJsonFragment([
            'target_type' => 'organizer',
            'target_id' => $organizerId,
        ]);
        $response->assertJsonFragment([
            'target_type' => 'artist',
            'target_id' => $artistId,
        ]);
    }

    public function test_store_review_creates_review_and_updates_pending_targets(): void
    {
        $organizerId = $this->seedOrganizer('Duty Collective');
        $artistId = $this->seedArtist('DJ Pulse');
        $eventId = $this->seedEvent($organizerId, 'Duty Sunset Session');
        $this->seedBooking($eventId, $organizerId);
        $this->seedLineup($eventId, $artistId, 'DJ Pulse');

        Sanctum::actingAs(Customer::findOrFail(501), [], 'sanctum');

        $storeResponse = $this->postJson($this->apiUrl('/api/customers/reviews'), [
            'target_type' => 'event',
            'target_id' => $eventId,
            'rating' => 5,
            'comment' => 'Great production and smooth entry.',
        ]);

        $storeResponse->assertOk();
        $storeResponse->assertJsonPath('data.status', 'published');

        $this->assertDatabaseHas('reviews', [
            'customer_id' => 501,
            'event_id' => $eventId,
            'reviewable_type' => \App\Models\Event::class,
            'reviewable_id' => $eventId,
            'rating' => 5,
            'status' => 'published',
        ]);
        $this->assertDatabaseHas('loyalty_point_transactions', [
            'customer_id' => 501,
            'reference_type' => 'review',
            'points' => 25,
        ]);

        $pendingResponse = $this->getJson($this->apiUrl('/api/customers/reviews/pending'));
        $pendingResponse->assertOk();
        $targets = collect($pendingResponse->json('data.items.0.targets'));
        $this->assertFalse($targets->contains(
            fn (array $target) => ($target['target_type'] ?? null) === 'event'
                && (int) ($target['target_id'] ?? 0) === $eventId
        ));
        $pendingResponse->assertJsonFragment([
            'target_type' => 'organizer',
            'target_id' => $organizerId,
        ]);
        $pendingResponse->assertJsonFragment([
            'target_type' => 'artist',
            'target_id' => $artistId,
        ]);
    }

    public function test_suspicious_review_comment_enters_pending_moderation(): void
    {
        $organizerId = $this->seedOrganizer('Duty Collective');
        $eventId = $this->seedEvent($organizerId, 'Duty Suspicious Review Case');
        $this->seedBooking($eventId, $organizerId);

        Sanctum::actingAs(Customer::findOrFail(501), [], 'sanctum');

        $response = $this->postJson($this->apiUrl('/api/customers/reviews'), [
            'target_type' => 'organizer',
            'target_id' => $organizerId,
            'event_id' => $eventId,
            'rating' => 4,
            'comment' => 'Write me on whatsapp and visit https://example.com',
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.status', 'pending_moderation');
        $this->assertDatabaseCount('loyalty_point_transactions', 0);
    }

    public function test_legacy_organizer_review_endpoint_uses_unified_reviews(): void
    {
        $organizerId = $this->seedOrganizer('Duty Legacy Flow');
        $eventId = $this->seedEvent($organizerId, 'Duty Legacy Event');
        $this->seedBooking($eventId, $organizerId);

        Sanctum::actingAs(Customer::findOrFail(501), [], 'sanctum');

        $response = $this->postJson($this->apiUrl('/api/organizers/review'), [
            'organizer_id' => $organizerId,
            'rating' => 5,
            'comment' => 'Excellent organizer.',
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.reviewable_type', \App\Models\Organizer::class);

        $this->assertDatabaseHas('reviews', [
            'customer_id' => 501,
            'event_id' => $eventId,
            'reviewable_type' => \App\Models\Organizer::class,
            'reviewable_id' => $organizerId,
            'rating' => 5,
        ]);
    }

    public function test_organizer_review_endpoint_accepts_organizer_identity_id_for_identity_owned_event(): void
    {
        $organizerId = $this->seedOrganizer('Duty Identity Flow');
        $this->seedOrganizerIdentity($organizerId, 801);
        $eventId = $this->seedEvent($organizerId, 'Duty Identity Event', [
            'organizer_id' => null,
            'owner_identity_id' => 801,
        ]);
        $this->seedBooking($eventId, null, 801);

        Sanctum::actingAs(Customer::findOrFail(501), [], 'sanctum');

        $response = $this->postJson($this->apiUrl('/api/organizers/review'), [
            'organizer_identity_id' => 801,
            'event_id' => $eventId,
            'rating' => 5,
            'comment' => 'Excellent organizer from identity flow.',
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.reviewable_type', \App\Models\Organizer::class);

        $this->assertDatabaseHas('reviews', [
            'customer_id' => 501,
            'event_id' => $eventId,
            'reviewable_type' => \App\Models\Organizer::class,
            'reviewable_id' => $organizerId,
            'rating' => 5,
        ]);
    }

    private function ensureReviewSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('photo')->nullable();
                $table->string('email')->nullable();
                $table->string('username')->nullable();
                $table->string('password')->nullable();
                $table->integer('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('organizer_infos')) {
            Schema::create('organizer_infos', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('photo')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->date('start_date')->nullable();
                $table->time('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->time('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
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

        if (!Schema::hasTable('event_lineups')) {
            Schema::create('event_lineups', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->string('source_type')->nullable();
                $table->string('display_name')->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_headliner')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identities')) {
            Schema::create('identities', function (Blueprint $table) {
                $table->id();
                $table->string('type');
                $table->string('status')->default('active');
                $table->unsignedBigInteger('owner_user_id')->nullable();
                $table->string('display_name')->nullable();
                $table->string('slug')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_members')) {
            Schema::create('identity_members', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('identity_id');
                $table->unsignedBigInteger('user_id');
                $table->string('role')->default('owner');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('reviews')) {
            Schema::create('reviews', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('reviewable_id');
                $table->string('reviewable_type');
                $table->tinyInteger('rating');
                $table->text('comment')->nullable();
                $table->string('status')->default('published');
                $table->json('meta')->nullable();
                $table->timestamp('submitted_at')->nullable();
                $table->timestamps();
                $table->unique(
                    ['customer_id', 'event_id', 'reviewable_type', 'reviewable_id'],
                    'reviews_customer_event_target_unique'
                );
            });
        }
    }

    private function seedCustomer(): void
    {
        DB::table('customers')->insert([
            'id' => 501,
            'fname' => 'Duty',
            'lname' => 'Customer',
            'email' => 'customer501@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedOrganizer(string $name): int
    {
        $id = (int) DB::table('organizers')->insertGetId([
            'email' => strtolower(str_replace(' ', '', $name)) . '@example.com',
            'username' => strtolower(str_replace(' ', '_', $name)),
            'password' => bcrypt('secret'),
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizer_infos')->insert([
            'organizer_id' => $id,
            'language_id' => 1,
            'name' => $name,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedArtist(string $name): int
    {
        return (int) DB::table('artists')->insertGetId([
            'name' => $name,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEvent(int $organizerId, string $title, array $overrides = []): int
    {
        $id = (int) DB::table('events')->insertGetId(array_merge([
            'organizer_id' => $organizerId,
            'owner_identity_id' => null,
            'thumbnail' => 'event.jpg',
            'start_date' => now()->subDays(3)->toDateString(),
            'start_time' => '20:00:00',
            'end_date' => now()->subDays(2)->toDateString(),
            'end_time' => '01:00:00',
            'end_date_time' => now()->subDays(2),
            'event_type' => 'venue',
            'date_type' => 'single',
            'created_at' => now(),
            'updated_at' => now(),
        ], $overrides));

        DB::table('event_contents')->insert([
            'event_id' => $id,
            'title' => $title,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedBooking(int $eventId, ?int $organizerId, ?int $organizerIdentityId = null): int
    {
        return (int) DB::table('bookings')->insertGetId([
            'customer_id' => 501,
            'event_id' => $eventId,
            'organizer_id' => $organizerId,
            'organizer_identity_id' => $organizerIdentityId,
            'paymentStatus' => 'Completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedOrganizerIdentity(int $organizerId, int $identityId): void
    {
        DB::table('identities')->insert([
            'id' => $identityId,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 501,
            'display_name' => 'Organizer Identity ' . $identityId,
            'slug' => 'organizer-identity-' . $identityId,
            'meta' => json_encode(['legacy_id' => $organizerId]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedLineup(int $eventId, int $artistId, string $name): void
    {
        DB::table('event_lineups')->insert([
            'event_id' => $eventId,
            'artist_id' => $artistId,
            'source_type' => 'registered',
            'display_name' => $name,
            'sort_order' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
