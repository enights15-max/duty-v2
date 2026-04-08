<?php

namespace Tests\Feature;

use App\Models\Event;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class EventOwnershipScopeTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources'];
    protected array $baselineTruncate = [
        'events',
        'organizers',
        'identity_members',
        'identities',
        'users',
        'customers',
    ];

    public function test_organizer_scope_prefers_owner_identity_and_only_falls_back_when_identity_is_missing(): void
    {
        DB::table('events')->insert([
            [
                'id' => 1001,
                'organizer_id' => 41,
                'owner_identity_id' => 501,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 1002,
                'organizer_id' => 41,
                'owner_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 1003,
                'organizer_id' => 41,
                'owner_identity_id' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ids = Event::query()
            ->ownedByOrganizerActor(501, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([1001, 1002], $ids);
    }

    public function test_organizer_scope_can_use_legacy_only_when_identity_context_is_unavailable(): void
    {
        DB::table('events')->insert([
            [
                'id' => 2001,
                'organizer_id' => 41,
                'owner_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2002,
                'organizer_id' => 52,
                'owner_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ids = Event::query()
            ->ownedByOrganizerActor(null, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([2001], $ids);
    }
}
