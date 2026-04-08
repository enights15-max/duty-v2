<?php

namespace App\Services;

use App\Models\Identity;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Schema;

class ProfessionalCatalogBridgeService
{
    public function findIdentityForLegacy(string $type, int|string|null $legacyId): ?Identity
    {
        if (!Schema::hasTable('identities')) {
            return null;
        }

        $normalized = $this->normalizeLegacyId($legacyId);
        if ($normalized === null) {
            return null;
        }

        return Identity::query()
            ->where('type', $type)
            ->where(function ($query) use ($normalized) {
                $query->where('meta->id', $normalized)
                    ->orWhere('meta->legacy_id', $normalized);
            })
            ->first();
    }

    public function resolveIdentityMap(string $type, iterable $legacyIds): Collection
    {
        if (!Schema::hasTable('identities')) {
            return collect();
        }

        $normalizedIds = collect($legacyIds)
            ->map(fn ($legacyId) => $this->normalizeLegacyId($legacyId))
            ->filter(fn ($legacyId) => $legacyId !== null)
            ->unique()
            ->values();

        if ($normalizedIds->isEmpty()) {
            return collect();
        }

        return Identity::query()
            ->where('type', $type)
            ->where(function ($query) use ($normalizedIds) {
                $query->whereIn('meta->id', $normalizedIds->all())
                    ->orWhereIn('meta->legacy_id', $normalizedIds->all());
            })
            ->get()
            ->reduce(function (Collection $carry, Identity $identity) {
                $legacyId = $this->legacyIdForIdentity($identity);
                if ($legacyId === null) {
                    return $carry;
                }

                $carry->put($this->keyForLegacyId($legacyId), $identity);

                return $carry;
            }, collect());
    }

    public function legacyIdForIdentity(Identity $identity, ?string $expectedType = null): int|string|null
    {
        if ($expectedType !== null && $identity->type !== $expectedType) {
            return null;
        }

        $meta = is_array($identity->meta) ? $identity->meta : [];

        return $meta['legacy_id'] ?? $meta['id'] ?? null;
    }

    public function injectLegacyActorIds(Request $request, Identity $identity): void
    {
        $legacyId = $this->legacyIdForIdentity($identity);
        if ($legacyId === null) {
            return;
        }

        $requestKey = match ($identity->type) {
            'organizer' => 'organizer_id_actor',
            'venue' => 'venue_id_actor',
            'artist' => 'artist_id_actor',
            default => null,
        };

        if ($requestKey === null) {
            return;
        }

        $request->merge([$requestKey => $legacyId]);
    }

    public function publicIdentity(?Identity $identity): ?array
    {
        if (!$identity) {
            return null;
        }

        return [
            'id' => $identity->id,
            'type' => $identity->type,
            'status' => $identity->status,
            'slug' => $identity->slug,
            'display_name' => $identity->display_name,
            'is_verified' => $identity->status === 'active',
        ];
    }

    public function keyForLegacyId(int|string|null $legacyId): ?string
    {
        $normalized = $this->normalizeLegacyId($legacyId);
        if ($normalized === null) {
            return null;
        }

        return (string) $normalized;
    }

    private function normalizeLegacyId(int|string|null $legacyId): int|string|null
    {
        if ($legacyId === null) {
            return null;
        }

        if (is_string($legacyId)) {
            $legacyId = trim($legacyId);
            if ($legacyId === '') {
                return null;
            }

            return ctype_digit($legacyId) ? (int) $legacyId : $legacyId;
        }

        return $legacyId;
    }
}
