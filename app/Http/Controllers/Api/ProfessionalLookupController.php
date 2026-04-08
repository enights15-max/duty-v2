<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Identity;
use App\Models\Venue;
use App\Services\ProfessionalCatalogBridgeService;
use App\Services\IdentityLegacyMirrorService;
use App\Support\PublicAssetUrl;
use App\Traits\HasIdentityActor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfessionalLookupController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        protected ProfessionalCatalogBridgeService $catalogBridge,
        protected IdentityLegacyMirrorService $legacyMirror
    ) {
    }

    public function venues(Request $request): JsonResponse
    {
        if (!$this->hasProfessionalIdentity()) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $search = trim((string) $request->input('q', ''));
        $limit = $this->resolveLimit($request);
        $ownerPriorityIds = $this->ownedLegacyIds('venue');
        $this->ensureSearchableLegacyCatalog('venue', $search);
        $ownerPriorityIds = $this->ownedLegacyIds('venue');

        $venues = Venue::query()
            ->where('status', 1)
            ->when($search !== '', function ($query) use ($search) {
                $term = mb_strtolower($search);
                $like = '%' . $term . '%';
                $prefix = $term . '%';

                $query->where(function ($builder) use ($like) {
                    $builder->whereRaw('LOWER(name) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(username) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(city) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(country) LIKE ?', [$like]);
                })->orderByRaw(
                    'CASE
                        WHEN LOWER(name) LIKE ? THEN 0
                        WHEN LOWER(username) LIKE ? THEN 1
                        WHEN LOWER(city) LIKE ? THEN 2
                        ELSE 3
                    END',
                    [$prefix, $prefix, $prefix]
                );
            })
            ->when(!empty($ownerPriorityIds), function ($query) use ($ownerPriorityIds) {
                $placeholders = implode(',', array_fill(0, count($ownerPriorityIds), '?'));
                $query->orderByRaw(
                    "CASE WHEN venues.id IN ($placeholders) THEN 0 ELSE 1 END",
                    $ownerPriorityIds
                );
            })
            ->orderBy('name')
            ->limit($limit)
            ->get([
                'id',
                'name',
                'slug',
                'username',
                'address',
                'city',
                'state',
                'country',
                'zip_code',
                'latitude',
                'longitude',
                'image',
            ]);

        $identityMap = $this->catalogBridge->resolveIdentityMap('venue', $venues->pluck('id'));

        return response()->json([
            'status' => 'success',
            'data' => $venues->map(function (Venue $venue) use ($identityMap, $ownerPriorityIds) {
                $identity = $identityMap->get($this->catalogBridge->keyForLegacyId($venue->id));

                return [
                    'id' => (int) $venue->id,
                    'type' => 'venue',
                    'name' => $venue->name,
                    'slug' => $venue->slug,
                    'username' => $venue->username,
                    'photo' => PublicAssetUrl::url($venue->image, 'assets/admin/img/venue'),
                    'address' => $venue->address,
                    'city' => $venue->city,
                    'state' => $venue->state,
                    'country' => $venue->country,
                    'postal_code' => $venue->zip_code,
                    'latitude' => $venue->latitude,
                    'longitude' => $venue->longitude,
                    'has_identity' => $identity !== null,
                    'is_owned_by_active_account' => in_array((int) $venue->id, $ownerPriorityIds, true),
                    'identity' => $this->catalogBridge->publicIdentity($identity),
                ];
            })->values()->all(),
        ]);
    }

    public function artists(Request $request): JsonResponse
    {
        if (!$this->hasProfessionalIdentity()) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $search = trim((string) $request->input('q', ''));
        $limit = $this->resolveLimit($request);
        $ownerPriorityIds = $this->ownedLegacyIds('artist');
        $this->ensureSearchableLegacyCatalog('artist', $search);
        $ownerPriorityIds = $this->ownedLegacyIds('artist');

        $artists = Artist::query()
            ->where('status', 1)
            ->when($search !== '', function ($query) use ($search) {
                $term = mb_strtolower($search);
                $like = '%' . $term . '%';
                $prefix = $term . '%';

                $query->where(function ($builder) use ($like) {
                    $builder->whereRaw('LOWER(name) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(username) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(details) LIKE ?', [$like]);
                })->orderByRaw(
                    'CASE
                        WHEN LOWER(name) LIKE ? THEN 0
                        WHEN LOWER(username) LIKE ? THEN 1
                        ELSE 2
                    END',
                    [$prefix, $prefix]
                );
            })
            ->when(!empty($ownerPriorityIds), function ($query) use ($ownerPriorityIds) {
                $placeholders = implode(',', array_fill(0, count($ownerPriorityIds), '?'));
                $query->orderByRaw(
                    "CASE WHEN artists.id IN ($placeholders) THEN 0 ELSE 1 END",
                    $ownerPriorityIds
                );
            })
            ->orderBy('name')
            ->limit($limit)
            ->get([
                'id',
                'name',
                'username',
                'photo',
                'details',
            ]);

        $identityMap = $this->catalogBridge->resolveIdentityMap('artist', $artists->pluck('id'));

        return response()->json([
            'status' => 'success',
            'data' => $artists->map(function (Artist $artist) use ($identityMap, $ownerPriorityIds) {
                $identity = $identityMap->get($this->catalogBridge->keyForLegacyId($artist->id));

                return [
                    'id' => (int) $artist->id,
                    'type' => 'artist',
                    'name' => $artist->name,
                    'username' => $artist->username,
                    'photo' => PublicAssetUrl::url($artist->photo, 'assets/admin/img/artist'),
                    'details' => $artist->details,
                    'has_identity' => $identity !== null,
                    'is_owned_by_active_account' => in_array((int) $artist->id, $ownerPriorityIds, true),
                    'identity' => $this->catalogBridge->publicIdentity($identity),
                ];
            })->values()->all(),
        ]);
    }

    private function hasProfessionalIdentity(): bool
    {
        $identity = $this->getActiveIdentity();

        return $identity && in_array($identity->type, ['organizer', 'venue'], true);
    }

    private function resolveLimit(Request $request, int $default = 12): int
    {
        $limit = (int) $request->input('limit', $default);

        if ($limit < 1) {
            return $default;
        }

        return min($limit, 25);
    }

    private function ownedLegacyIds(string $type): array
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || (int) $identity->owner_user_id <= 0) {
            return [];
        }

        return Identity::query()
            ->where('owner_user_id', (int) $identity->owner_user_id)
            ->where('type', $type)
            ->where('status', 'active')
            ->get()
            ->map(fn (Identity $profile) => $this->catalogBridge->legacyIdForIdentity($profile, $type))
            ->filter(fn ($legacyId) => is_numeric($legacyId) && (int) $legacyId > 0)
            ->map(fn ($legacyId) => (int) $legacyId)
            ->unique()
            ->values()
            ->all();
    }

    private function ensureSearchableLegacyCatalog(string $type, string $search): void
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || (int) $identity->owner_user_id <= 0) {
            return;
        }

        $this->legacyMirror->syncOwnerProfessionalIdentities((int) $identity->owner_user_id, [$type]);
        $this->legacyMirror->syncMatchingActiveIdentities($type, $search);
    }
}
