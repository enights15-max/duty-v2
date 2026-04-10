<?php

namespace Tests\Feature\Api;

use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class OrganizerIdentityProfileApiTest extends ActorFeatureTestCase
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
        'event_contents',
        'events',
        'event_categories',
        'organizer_infos',
        'organizers',
        'customers',
        'users',
    ];

    protected bool $baselineDefaultLanguage = true;

    public function test_profile_details_resolve_identity_backed_organizer_and_identity_owned_events(): void
    {
        $this->ensureReviewsTable();

        DB::table('organizers')->insert([
            'id' => 501,
            'username' => 'legacy_collective',
            'email' => 'legacy@collective.test',
            'phone' => '8091231234',
            'status' => '1',
            'created_at' => now()->subMonths(2),
            'updated_at' => now()->subMonths(2),
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

        $identityId = (int) DB::table('identities')->insertGetId([
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
                'details' => 'Identity description',
            ]),
            'created_at' => now()->subMonth(),
            'updated_at' => now()->subMonth(),
        ]);

        DB::table('event_categories')->insert([
            'id' => 81,
            'language_id' => 1,
            'name' => 'Party',
            'slug' => 'party',
            'status' => 1,
            'serial_number' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 4501,
            'owner_identity_id' => $identityId,
            'organizer_id' => 501,
            'status' => 1,
            'date_type' => 'single',
            'event_type' => 'venue',
            'thumbnail' => 'identity-event.jpg',
            'start_date' => now()->addDays(9)->toDateString(),
            'start_time' => '21:00:00',
            'duration' => '4h',
            'end_date_time' => now()->addDays(9)->addHours(4),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 4501,
            'language_id' => 1,
            'event_category_id' => 81,
            'title' => 'Identity Rooftop',
            'slug' => 'identity-rooftop',
            'address' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson($this->apiUrl("/api/organizer/{$identityId}/profile"));

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'admin' => false,
                ],
            ]);

        $organizer = $response->json('data.organizer');
        $this->assertSame($identityId, $organizer['id']);
        $this->assertSame($identityId, $organizer['identity_id']);
        $this->assertSame(501, $organizer['legacy_organizer_id']);
        $this->assertSame('Identity Collective', $organizer['organizer_name']);
        $this->assertSame('1', (string) $organizer['events_count']);

        $upcoming = $response->json('data.events.categories.81.0');
        $this->assertSame(4501, $upcoming['id']);
        $this->assertSame('legacy_collective', $upcoming['organizer']);
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
