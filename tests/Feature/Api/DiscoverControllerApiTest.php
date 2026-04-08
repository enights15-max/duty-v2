<?php

namespace Tests\Feature\Api;

use App\Models\Artist;
use App\Models\Organizer;
use App\Models\Venue;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class DiscoverControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [
        'users_customers',
        'identities',
        'follows',
        'legacy_identity_sources',
        'discovery_catalog',
    ];
    protected array $baselineTruncate = [
        'identities',
        'identity_members',
        'follows',
        'event_artist',
        'event_contents',
        'events',
        'organizer_infos',
        'organizers',
        'venues',
        'artists',
        'customers',
        'users',
    ];
    protected bool $baselineDefaultLanguage = true;

    public function test_artist_discovery_returns_identity_enriched_sections(): void
    {
        $this->ensureReviewsTable();

        DB::table('artists')->insert([
            [
                'id' => 101,
                'name' => 'DJ Nova',
                'username' => 'dj_nova',
                'photo' => 'missing-artist.jpg',
                'status' => 1,
                'created_at' => now()->subDays(5),
                'updated_at' => now()->subDays(5),
            ],
            [
                'id' => 102,
                'name' => 'DJ Fresh',
                'username' => 'dj_fresh',
                'photo' => null,
                'status' => 1,
                'created_at' => now()->subDay(),
                'updated_at' => now()->subDay(),
            ],
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 7001,
            'display_name' => 'DJ Nova Verified',
            'slug' => 'dj-nova-verified',
            'meta' => json_encode([
                'legacy_id' => 101,
                'legacy_source' => 'artist',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('follows')->insert([
            [
                'follower_id' => 1,
                'follower_type' => 'customer',
                'followable_id' => 101,
                'followable_type' => Artist::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'follower_id' => 2,
                'follower_type' => 'customer',
                'followable_id' => 101,
                'followable_type' => Artist::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('events')->insert([
            [
                'id' => 1001,
                'status' => 1,
                'thumbnail' => 'nova-event.jpg',
                'start_date' => now()->addDays(7),
                'end_date_time' => now()->addDays(7)->addHours(4),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 1002,
                'status' => 1,
                'thumbnail' => 'fresh-event.jpg',
                'start_date' => now()->addDays(10),
                'end_date_time' => now()->addDays(10)->addHours(4),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 1001,
                'language_id' => 1,
                'title' => 'Nova Sunset Session',
                'slug' => 'nova-sunset-session',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 1002,
                'language_id' => 1,
                'title' => 'Fresh Rooftop',
                'slug' => 'fresh-rooftop',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_artist')->insert([
            [
                'event_id' => 1001,
                'artist_id' => 101,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 1002,
                'artist_id' => 102,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('reviews')->insert([
            [
                'customer_id' => 1,
                'booking_id' => null,
                'event_id' => 1001,
                'reviewable_id' => 101,
                'reviewable_type' => Artist::class,
                'rating' => 5,
                'comment' => 'Great set',
                'status' => 'published',
                'meta' => null,
                'submitted_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'customer_id' => 2,
                'booking_id' => null,
                'event_id' => 1001,
                'reviewable_id' => 101,
                'reviewable_type' => Artist::class,
                'rating' => 4,
                'comment' => 'Strong performance',
                'status' => 'published',
                'meta' => null,
                'submitted_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'customer_id' => 3,
                'booking_id' => null,
                'event_id' => 1002,
                'reviewable_id' => 102,
                'reviewable_type' => Artist::class,
                'rating' => 3,
                'comment' => 'Good',
                'status' => 'published',
                'meta' => null,
                'submitted_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $response = $this->getJson($this->apiUrl('/api/discover/artists'));

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $popular = $response->json('data.popular');
        $this->assertSame(101, $popular[0]['id']);
        $this->assertSame(2, $popular[0]['followers_count']);
        $this->assertSame($identityId, $popular[0]['identity']['id']);
        $this->assertSame(4.5, $popular[0]['average_rating']);
        $this->assertNull($popular[0]['photo']);

        $topRated = $response->json('data.top_rated');
        $this->assertSame(101, $topRated[0]['id']);
        $this->assertSame(2, $topRated[0]['review_count']);

        $upcomingEvent = $response->json('data.upcoming_events.0');
        $this->assertSame(1001, $upcomingEvent['id']);
        $this->assertSame($identityId, $upcomingEvent['artist']['identity']['id']);
    }

    public function test_organizer_discovery_filters_and_returns_active_sections(): void
    {
        $this->ensureReviewsTable();

        DB::table('organizers')->insert([
            [
                'id' => 201,
                'username' => 'pulse_live',
                'status' => '1',
                'created_at' => now()->subDays(30),
                'updated_at' => now()->subDays(30),
            ],
            [
                'id' => 202,
                'username' => 'quiet_collective',
                'status' => '1',
                'created_at' => now()->subDays(3),
                'updated_at' => now()->subDays(3),
            ],
        ]);

        DB::table('organizer_infos')->insert([
            [
                'organizer_id' => 201,
                'language_id' => 1,
                'name' => 'Pulse Collective',
                'city' => 'Santo Domingo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'organizer_id' => 202,
                'language_id' => 1,
                'name' => 'Quiet Events',
                'city' => 'Santiago',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 7101,
            'display_name' => 'Pulse Collective',
            'slug' => 'pulse-collective',
            'meta' => json_encode([
                'id' => 201,
                'legacy_source' => 'organizer',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('follows')->insert([
            [
                'follower_id' => 1,
                'follower_type' => 'customer',
                'followable_id' => 201,
                'followable_type' => Organizer::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'follower_id' => 2,
                'follower_type' => 'customer',
                'followable_id' => 201,
                'followable_type' => Organizer::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('events')->insert([
            'id' => 2001,
            'organizer_id' => 201,
            'owner_identity_id' => $identityId,
            'status' => 1,
            'thumbnail' => 'pulse-event.jpg',
            'start_date' => now()->addDays(14),
            'end_date_time' => now()->addDays(14)->addHours(6),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 2001,
            'language_id' => 1,
            'title' => 'Pulse Festival',
            'slug' => 'pulse-festival',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reviews')->insert([
            'customer_id' => 1,
            'booking_id' => null,
            'event_id' => 2001,
            'reviewable_id' => 201,
            'reviewable_type' => Organizer::class,
            'rating' => 5,
            'comment' => 'Well organized',
            'status' => 'published',
            'meta' => null,
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson($this->apiUrl('/api/discover/organizers?q=Pulse'));

        $response->assertStatus(200)->assertJson(['success' => true]);

        $popular = $response->json('data.popular');
        $this->assertCount(1, $popular);
        $this->assertSame($identityId, $popular[0]['id']);
        $this->assertSame(201, $popular[0]['legacy_organizer_id']);
        $this->assertSame($identityId, $popular[0]['identity']['id']);

        $active = $response->json('data.active');
        $this->assertSame($identityId, $active[0]['id']);
        $topRated = $response->json('data.top_rated');
        $this->assertSame($identityId, $topRated[0]['id']);
        $this->assertEquals(5.0, $topRated[0]['average_rating']);

        $upcomingEvent = $response->json('data.upcoming_events.0');
        $this->assertSame(2001, $upcomingEvent['id']);
        $this->assertSame($identityId, $upcomingEvent['organizer']['id']);
        $this->assertSame($identityId, $upcomingEvent['organizer']['identity']['id']);
    }

    public function test_venue_discovery_returns_recommended_directory_and_upcoming_events(): void
    {
        $this->ensureReviewsTable();

        DB::table('venues')->insert([
            [
                'id' => 301,
                'name' => 'Harbor Club',
                'slug' => 'harbor-club',
                'city' => 'Santo Domingo',
                'country' => 'DO',
                'status' => 1,
                'created_at' => now()->subDays(20),
                'updated_at' => now()->subDays(20),
            ],
            [
                'id' => 302,
                'name' => 'Forest Yard',
                'slug' => 'forest-yard',
                'city' => 'Jarabacoa',
                'country' => 'DO',
                'status' => 1,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 7201,
            'display_name' => 'Harbor Club',
            'slug' => 'harbor-club-verified',
            'meta' => json_encode([
                'id' => 301,
                'legacy_source' => 'venue',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('follows')->insert([
            [
                'follower_id' => 1,
                'follower_type' => 'customer',
                'followable_id' => 301,
                'followable_type' => Venue::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'follower_id' => 2,
                'follower_type' => 'customer',
                'followable_id' => 301,
                'followable_type' => Venue::class,
                'status' => 'accepted',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('events')->insert([
            [
                'id' => 3001,
                'venue_id' => null,
                'venue_identity_id' => $identityId,
                'status' => 1,
                'thumbnail' => 'harbor-event.jpg',
                'start_date' => now()->addDays(5),
                'end_date_time' => now()->addDays(5)->addHours(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3002,
                'venue_id' => 302,
                'venue_identity_id' => null,
                'status' => 1,
                'thumbnail' => 'forest-event.jpg',
                'start_date' => now()->addDays(15),
                'end_date_time' => now()->addDays(15)->addHours(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 3001,
                'language_id' => 1,
                'title' => 'Harbor Nights',
                'slug' => 'harbor-nights',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 3002,
                'language_id' => 1,
                'title' => 'Forest Gathering',
                'slug' => 'forest-gathering',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('reviews')->insert([
            [
                'customer_id' => 1,
                'booking_id' => null,
                'event_id' => 3001,
                'reviewable_id' => 301,
                'reviewable_type' => Venue::class,
                'rating' => 5,
                'comment' => 'Amazing venue',
                'status' => 'published',
                'meta' => null,
                'submitted_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'customer_id' => 2,
                'booking_id' => null,
                'event_id' => 3002,
                'reviewable_id' => 302,
                'reviewable_type' => Venue::class,
                'rating' => 4,
                'comment' => 'Nice atmosphere',
                'status' => 'published',
                'meta' => null,
                'submitted_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $response = $this->getJson($this->apiUrl('/api/discover/venues'));

        $response->assertStatus(200)->assertJson(['success' => true]);

        $recommended = $response->json('data.recommended');
        $this->assertSame(301, $recommended[0]['id']);
        $this->assertSame($identityId, $recommended[0]['identity']['id']);

        $topRated = $response->json('data.top_rated');
        $this->assertSame(301, $topRated[0]['id']);
        $this->assertEquals(5.0, $topRated[0]['average_rating']);

        $upcomingEvent = $response->json('data.upcoming_events.0');
        $this->assertSame(3001, $upcomingEvent['id']);
        $this->assertSame($identityId, $upcomingEvent['venue']['identity']['id']);
    }

    private function ensureReviewsTable(): void
    {
        if (Schema::hasTable('reviews')) {
            return;
        }

        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('reviewable_id');
            $table->string('reviewable_type');
            $table->unsignedTinyInteger('rating');
            $table->text('comment')->nullable();
            $table->string('status', 32)->default('published');
            $table->json('meta')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();
        });
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
