<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalLookupControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureSchema();
        $this->truncateTables([
            'artists',
            'venues',
        ]);
    }

    public function test_organizer_identity_can_search_registered_venues_for_authoring(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $this->seedVenue(77, 'Duty Arena', 'duty-arena', 1);
        $this->seedVenue(78, 'Solar Club', 'solar-club', 1);
        $this->seedVenue(79, 'Hidden Venue', 'hidden-venue', 0);
        $this->seedLegacyIdentity('venue', 77, 301, 'Duty Arena');

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/venues/search?q=arena'));

        $response->assertOk();
        $response->assertJsonPath('data.0.id', 77);
        $response->assertJsonPath('data.0.name', 'Duty Arena');
        $response->assertJsonPath('data.0.has_identity', true);
        $response->assertJsonCount(1, 'data');
    }

    public function test_venue_identity_can_search_registered_artists_for_authoring(): void
    {
        $identityId = $this->seedVenueIdentity();
        $this->seedArtist(31, 'DJ Nova', 'dj-nova', 1);
        $this->seedArtist(32, 'DJ Orbit', 'dj-orbit', 1);
        $this->seedArtist(33, 'Sleep Mode', 'sleep-mode', 0);
        $this->seedLegacyIdentity('artist', 31, 401, 'DJ Nova');

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/artists/search?q=dj'));

        $response->assertOk();
        $response->assertJsonCount(2, 'data');
        $response->assertJsonPath('data.0.id', 31);
        $response->assertJsonPath('data.0.has_identity', true);
        $response->assertJsonPath('data.1.id', 32);
    }

    public function test_organizer_lookup_syncs_active_venue_identity_without_legacy_row(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $this->seedActiveProfessionalIdentityWithoutLegacy(
            type: 'venue',
            ownerUserId: 11,
            displayName: 'Santo Santo',
            slug: 'santo-santo'
        );

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/venues/search?q=santo'));

        $response->assertOk();
        $response->assertJsonPath('data.0.name', 'Santo Santo');
        $this->assertTrue(DB::table('venues')->where('slug', 'santo-santo')->exists());
    }

    public function test_venue_lookup_syncs_active_artist_identity_without_legacy_row(): void
    {
        $identityId = $this->seedVenueIdentity();
        $this->seedActiveProfessionalIdentityWithoutLegacy(
            type: 'artist',
            ownerUserId: 11,
            displayName: 'Gianvald',
            slug: 'gianvald'
        );

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/artists/search?q=gian'));

        $response->assertOk();
        $response->assertJsonPath('data.0.name', 'Gianvald');
        $this->assertTrue(DB::table('artists')->where('username', 'gianvald')->exists());
    }

    public function test_artist_identity_cannot_use_professional_authoring_search_endpoints(): void
    {
        $identityId = $this->seedLegacyIdentity('artist', 31, 501, 'Artist Identity');
        $this->seedArtist(31, 'DJ Nova', 'dj-nova', 1);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/artists/search?q=dj'));

        $response->assertStatus(403);
        $response->assertJsonPath('message', 'An active organizer or venue identity is required.');
    }

    private function ensureSchema(): void
    {
        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('photo')->nullable();
                $table->text('details')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('slug')->nullable();
                $table->string('username')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->string('zip_code')->nullable();
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->string('image')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }
    }

    private function seedOrganizerIdentity(): int
    {
        $this->seedBaseAccount();

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

    private function seedVenueIdentity(): int
    {
        $this->seedBaseAccount();

        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => 11,
            'type' => 'venue',
            'status' => 'active',
            'display_name' => 'Duty Venue',
            'slug' => 'duty-venue',
            'meta' => json_encode(['legacy_id' => 77]),
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

    private function seedLegacyIdentity(string $type, int $legacyId, int $identityId, string $displayName): int
    {
        $this->seedBaseAccount();

        DB::table('identities')->insert([
            'id' => $identityId,
            'owner_user_id' => 11,
            'type' => $type,
            'status' => 'active',
            'display_name' => $displayName,
            'slug' => strtolower(str_replace(' ', '-', $displayName)),
            'meta' => json_encode(['legacy_id' => $legacyId]),
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

    private function seedBaseAccount(): void
    {
        if (!DB::table('users')->where('id', 11)->exists()) {
            DB::table('users')->insert([
                'id' => 11,
                'email' => 'authoring-owner@example.com',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (!DB::table('customers')->where('id', 101)->exists()) {
            DB::table('customers')->insert([
                'id' => 101,
                'email' => 'authoring-owner@example.com',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    private function seedVenue(int $id, string $name, string $username, int $status): void
    {
        DB::table('venues')->insert([
            'id' => $id,
            'name' => $name,
            'slug' => strtolower(str_replace(' ', '-', $name)),
            'username' => $username,
            'address' => 'Calle 1',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'Dominican Republic',
            'zip_code' => '10101',
            'latitude' => 18.4800000,
            'longitude' => -69.9200000,
            'status' => $status,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedArtist(int $id, string $name, string $username, int $status): void
    {
        DB::table('artists')->insert([
            'id' => $id,
            'name' => $name,
            'username' => $username,
            'details' => 'Artist profile',
            'status' => $status,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }

    private function seedActiveProfessionalIdentityWithoutLegacy(
        string $type,
        int $ownerUserId,
        string $displayName,
        string $slug
    ): int {
        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => $ownerUserId,
            'type' => $type,
            'status' => 'active',
            'display_name' => $displayName,
            'slug' => $slug,
            'meta' => json_encode([
                'display_name' => $displayName,
                'username' => $slug,
                'city' => 'Santo Domingo',
                'country' => 'Dominican Republic',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => $ownerUserId,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $identityId;
    }
}
