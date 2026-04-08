<?php

namespace Tests\Feature\Console;

use App\Models\Identity;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class IdentityMigrateCommandTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'organizer_infos',
        'organizers',
        'venues',
        'artists',
        'events',
        'customers',
        'users',
    ];

    public function test_identity_migrate_builds_users_identities_members_and_event_links(): void
    {
        $this->seedLegacyData();

        $this->artisan('identity:migrate')->assertExitCode(0);

        $this->assertSame(4, User::count(), 'Expected one user per seeded actor/customer.');
        $this->assertSame(4, Identity::where('type', 'personal')->count(), 'Expected personal identity for each user.');
        $this->assertSame(1, Identity::where('type', 'organizer')->count());
        $this->assertSame(1, Identity::where('type', 'venue')->count());
        $this->assertSame(1, Identity::where('type', 'artist')->count());

        $organizerUser = User::where('email', 'org@example.com')->firstOrFail();
        $venueUser = User::where('email', 'venue@example.com')->firstOrFail();
        $artistUser = User::where('email', 'artist@example.com')->firstOrFail();

        $organizerIdentity = Identity::where('type', 'organizer')->where('owner_user_id', $organizerUser->id)->firstOrFail();
        $venueIdentity = Identity::where('type', 'venue')->where('owner_user_id', $venueUser->id)->firstOrFail();
        $artistIdentity = Identity::where('type', 'artist')->where('owner_user_id', $artistUser->id)->firstOrFail();

        $organizerMeta = is_array($organizerIdentity->meta) ? $organizerIdentity->meta : [];
        $venueMeta = is_array($venueIdentity->meta) ? $venueIdentity->meta : [];
        $artistMeta = is_array($artistIdentity->meta) ? $artistIdentity->meta : [];

        $this->assertSame('active', $organizerIdentity->status);
        $this->assertSame('pending', $artistIdentity->status, 'Inactive legacy artists should become pending identities.');
        $this->assertSame('organizer', $organizerMeta['legacy_source'] ?? null);
        $this->assertSame(10, (int) ($organizerMeta['legacy_id'] ?? 0));
        $this->assertSame(10, (int) ($organizerMeta['id'] ?? 0));
        $this->assertArrayNotHasKey('password', $organizerMeta);
        $this->assertArrayNotHasKey('remember_token', $venueMeta);
        $this->assertSame('venue', $venueMeta['legacy_source'] ?? null);
        $this->assertSame('artist', $artistMeta['legacy_source'] ?? null);

        $event = DB::table('events')->where('id', 100)->first();
        $this->assertNotNull($event);
        $this->assertSame($organizerIdentity->id, (int) $event->owner_identity_id);
        $this->assertSame($venueIdentity->id, (int) $event->venue_identity_id);

        $this->assertSame(7, DB::table('identity_members')->count(), 'Expected owner membership for all identities.');
    }

    public function test_identity_migrate_is_idempotent(): void
    {
        $this->seedLegacyData();

        $this->artisan('identity:migrate')->assertExitCode(0);
        $this->artisan('identity:migrate')->assertExitCode(0);

        $this->assertSame(4, User::count());
        $this->assertSame(7, Identity::count());
        $this->assertSame(7, DB::table('identity_members')->count());
        $this->assertSame(1, Identity::where('type', 'organizer')->count());
        $this->assertSame(1, Identity::where('type', 'venue')->count());
        $this->assertSame(1, Identity::where('type', 'artist')->count());

        $event = DB::table('events')->where('id', 100)->first();
        $this->assertNotNull($event->owner_identity_id);
        $this->assertNotNull($event->venue_identity_id);
    }

    private function seedLegacyData(): void
    {
        DB::table('customers')->insert([
            'id' => 1,
            'email' => 'consumer@example.com',
            'username' => 'consumer_demo',
            'fname' => 'Con',
            'lname' => 'Sumer',
            'phone' => '+18095550001',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 10,
            'email' => 'org@example.com',
            'username' => 'org_demo',
            'phone' => '+18095550010',
            'password' => bcrypt('secret'),
            'status' => '1',
            'theme_version' => 'light',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizer_infos')->insert([
            'id' => 11,
            'organizer_id' => 10,
            'name' => 'Org Prime',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Main Ave 10',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('venues')->insert([
            'id' => 20,
            'name' => 'Venue Prime',
            'slug' => 'venue-prime',
            'username' => 'venue_demo',
            'email' => 'venue@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 30,
            'name' => 'DJ Prime',
            'username' => 'artist_demo',
            'email' => 'artist@example.com',
            'password' => bcrypt('secret'),
            'status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 100,
            'organizer_id' => 10,
            'venue_id' => 20,
            'owner_identity_id' => null,
            'venue_identity_id' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}

