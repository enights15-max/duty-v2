<?php

namespace Tests\Feature;

use App\Models\Identity;
use App\Services\ProfessionalCatalogBridgeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalCatalogBridgeServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];

    public function test_bridge_resolves_identity_from_id_and_legacy_id_meta_keys(): void
    {
        $identityFromId = (int) DB::table('identities')->insertGetId([
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 9001,
            'display_name' => 'DJ Linked',
            'slug' => 'dj-linked',
            'meta' => json_encode([
                'id' => 301,
                'legacy_source' => 'artist',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $identityFromLegacyId = (int) DB::table('identities')->insertGetId([
            'type' => 'artist',
            'status' => 'pending',
            'owner_user_id' => 9002,
            'display_name' => 'DJ Pending',
            'slug' => 'dj-pending',
            'meta' => json_encode([
                'legacy_id' => 302,
                'legacy_source' => 'artist',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        /** @var ProfessionalCatalogBridgeService $service */
        $service = app(ProfessionalCatalogBridgeService::class);
        $resolvedMap = $service->resolveIdentityMap('artist', [301, 302, 999]);

        $this->assertSame($identityFromId, $resolvedMap->get('301')->id);
        $this->assertSame($identityFromLegacyId, $resolvedMap->get('302')->id);
        $this->assertNull($service->findIdentityForLegacy('artist', 999));
        $this->assertSame($identityFromLegacyId, $service->findIdentityForLegacy('artist', 302)?->id);
    }

    public function test_bridge_can_extract_legacy_ids_and_inject_actor_context_keys(): void
    {
        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9010,
            'display_name' => 'QA Organizer',
            'slug' => 'qa-organizer',
            'meta' => json_encode([
                'legacy_source' => 'organizer',
                'legacy_id' => 401,
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        /** @var Identity $identity */
        $identity = Identity::query()->findOrFail($identityId);
        /** @var ProfessionalCatalogBridgeService $service */
        $service = app(ProfessionalCatalogBridgeService::class);

        $this->assertSame(401, $service->legacyIdForIdentity($identity, 'organizer'));
        $this->assertNull($service->legacyIdForIdentity($identity, 'venue'));

        $request = Request::create('/api/customers/professional/events', 'GET');
        $service->injectLegacyActorIds($request, $identity);

        $this->assertSame(401, $request->get('organizer_id_actor'));
    }
}
