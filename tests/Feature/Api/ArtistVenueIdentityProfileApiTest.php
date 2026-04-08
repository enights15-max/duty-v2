<?php

namespace Tests\Feature\Api;

use App\Models\Artist;
use App\Models\Venue;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ArtistVenueIdentityProfileApiTest extends ActorFeatureTestCase
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
        'venues',
        'artists',
        'customers',
        'users',
    ];

    protected bool $baselineDefaultLanguage = true;

    public function test_artist_profile_resolves_identity_first_and_keeps_legacy_social_id(): void
    {
        DB::table('artists')->insert([
            'id' => 401,
            'name' => 'Legacy Nova',
            'username' => 'legacy_nova',
            'details' => 'Legacy artist details',
            'status' => 1,
            'created_at' => now()->subDays(10),
            'updated_at' => now()->subDays(10),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 8401,
            'display_name' => 'Nova Verified',
            'slug' => 'nova-verified',
            'meta' => json_encode([
                'legacy_id' => 401,
                'legacy_source' => 'artist',
                'details' => 'Identity artist details',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('follows')->insert([
            'follower_id' => 1,
            'follower_type' => 'customer',
            'followable_id' => 401,
            'followable_type' => Artist::class,
            'status' => 'accepted',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 4101,
            'status' => 1,
            'thumbnail' => 'nova-profile-event.jpg',
            'start_date' => now()->addDays(7),
            'end_date_time' => now()->addDays(7)->addHours(4),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 4101,
            'language_id' => 1,
            'title' => 'Nova Identity Set',
            'slug' => 'nova-identity-set',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_artist')->insert([
            'event_id' => 4101,
            'artist_id' => 401,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson($this->apiUrl('/api/artist/' . $identityId . '/profile'));

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => 401,
                    'profile_id' => 401,
                    'identity_id' => $identityId,
                    'legacy_artist_id' => 401,
                    'name' => 'Nova Verified',
                    'followers_count' => 1,
                ],
            ]);

        $this->assertSame($identityId, $response->json('data.identity.id'));
        $this->assertSame(4101, $response->json('data.events.0.id'));
        $this->assertSame('Nova Identity Set', $response->json('data.events.0.title'));
    }

    public function test_venue_profile_resolves_identity_first_and_formats_identity_owned_events(): void
    {
        $this->ensureTicketsTable();
        $this->ensureEventTimingColumns();

        DB::table('venues')->insert([
            'id' => 501,
            'name' => 'Legacy Hall',
            'slug' => 'legacy-hall',
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'status' => 1,
            'created_at' => now()->subDays(14),
            'updated_at' => now()->subDays(14),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 8501,
            'display_name' => 'Sky Hall Verified',
            'slug' => 'sky-hall-verified',
            'meta' => json_encode([
                'legacy_id' => 501,
                'legacy_source' => 'venue',
                'address_line' => 'Av. Winston Churchill',
                'city' => 'Santo Domingo',
                'country' => 'DO',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('follows')->insert([
            'follower_id' => 1,
            'follower_type' => 'customer',
            'followable_id' => 501,
            'followable_type' => Venue::class,
            'status' => 'accepted',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 5101,
                'venue_id' => null,
                'venue_identity_id' => $identityId,
                'status' => 1,
                'thumbnail' => 'sky-hall-upcoming.jpg',
                'start_date' => now()->addDays(5),
                'start_time' => '20:00:00',
                'end_date_time' => now()->addDays(5)->addHours(4),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 5102,
                'venue_id' => 501,
                'venue_identity_id' => null,
                'status' => 1,
                'thumbnail' => 'sky-hall-past.jpg',
                'start_date' => now()->subDays(5),
                'start_time' => '19:00:00',
                'end_date_time' => now()->subDays(5)->addHours(4),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 5101,
                'language_id' => 1,
                'title' => 'Sky Hall Opening',
                'slug' => 'sky-hall-opening',
                'address' => 'Av. Winston Churchill',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 5102,
                'language_id' => 1,
                'title' => 'Sky Hall Classics',
                'slug' => 'sky-hall-classics',
                'address' => 'Av. Winston Churchill',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('tickets')->insert([
            [
                'event_id' => 5101,
                'price' => 900,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 5102,
                'price' => 500,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $response = $this->getJson($this->apiUrl('/api/venue/' . $identityId . '/profile'));

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => 501,
                    'profile_id' => 501,
                    'identity_id' => $identityId,
                    'legacy_venue_id' => 501,
                    'name' => 'Sky Hall Verified',
                    'followers_count' => 1,
                ],
            ]);

        $this->assertSame($identityId, $response->json('data.identity.id'));
        $this->assertSame(5101, $response->json('data.events.0.id'));
        $this->assertSame('Sky Hall Opening', $response->json('data.events.0.title'));
        $this->assertSame(5102, $response->json('data.past_events.0.id'));
        $this->assertEquals(900.0, $response->json('data.events.0.start_price'));
    }

    private function ensureTicketsTable(): void
    {
        if (Schema::hasTable('tickets')) {
            return;
        }

        Schema::create('tickets', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('event_id');
            $table->string('price')->nullable();
            $table->timestamps();
        });
    }

    private function ensureEventTimingColumns(): void
    {
        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'start_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('start_time')->nullable();
            });
        }
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
