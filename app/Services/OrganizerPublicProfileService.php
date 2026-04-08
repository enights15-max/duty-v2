<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Identity;
use App\Models\Organizer;
use App\Models\Review;
use App\Support\PublicAssetUrl;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class OrganizerPublicProfileService
{
    private array $targetCache = [];

    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function resolveByPublicId(int|string|null $id, ?int $languageId = null): ?array
    {
        if ($id === null || $id === '' || (string) $id === '0') {
            return null;
        }

        $cacheKey = $this->cacheKey('public:' . $id, $languageId);
        if (array_key_exists($cacheKey, $this->targetCache)) {
            return $this->targetCache[$cacheKey];
        }

        $identity = Identity::query()
            ->where('type', 'organizer')
            ->find($id);

        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity, $languageId);
        }

        $identity = $this->catalogBridge->findIdentityForLegacy('organizer', $id);
        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity, $languageId);
        }

        $legacyOrganizer = Organizer::query()->find($id);
        if (!$legacyOrganizer) {
            return $this->targetCache[$cacheKey] = null;
        }

        return $this->targetCache[$cacheKey] = $this->hydrateTarget(null, $languageId, $legacyOrganizer);
    }

    public function resolveFromOwnership(
        int|string|null $ownerIdentityId,
        int|string|null $legacyOrganizerId,
        ?int $languageId = null
    ): ?array {
        $cacheKey = $this->cacheKey('owned:' . ($ownerIdentityId ?? 'null') . ':' . ($legacyOrganizerId ?? 'null'), $languageId);
        if (array_key_exists($cacheKey, $this->targetCache)) {
            return $this->targetCache[$cacheKey];
        }

        $identity = null;
        if ($ownerIdentityId !== null) {
            $identity = Identity::query()
                ->where('type', 'organizer')
                ->find($ownerIdentityId);
        }

        $legacyOrganizer = null;
        if ($legacyOrganizerId !== null) {
            $legacyOrganizer = Organizer::query()->find($legacyOrganizerId);
        }

        if (!$identity && $legacyOrganizerId !== null) {
            $identity = $this->catalogBridge->findIdentityForLegacy('organizer', $legacyOrganizerId);
        }

        if (!$identity && !$legacyOrganizer) {
            return $this->targetCache[$cacheKey] = null;
        }

        return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity, $languageId, $legacyOrganizer);
    }

    public function buildPublicPayload(array $target, ?Customer $viewer = null): array
    {
        $identity = $target['identity'];
        $legacy = $target['legacy'];
        $legacyId = $target['legacy_id'];
        $meta = $identity?->meta ?? [];

        $followersCount = 0;
        $isFollowed = false;
        $averageRating = 0.0;
        $reviewCount = 0;
        $reviews = [];

        if ($legacyId !== null) {
            $followersCount = DB::table('follows')
                ->where('followable_id', $legacyId)
                ->where('followable_type', Organizer::class)
                ->where('status', 'accepted')
                ->count();

            if ($viewer) {
                $isFollowed = DB::table('follows')
                    ->where('followable_id', $legacyId)
                    ->where('followable_type', Organizer::class)
                    ->where('status', 'accepted')
                    ->where('follower_id', $viewer->id)
                    ->where('follower_type', Customer::class)
                    ->exists();
            }

            if (Schema::hasTable('reviews')) {
                $reviewQuery = Review::query()
                    ->where('reviewable_type', Organizer::class)
                    ->where('reviewable_id', $legacyId)
                    ->where('status', 'published');

                $averageRating = round((float) ($reviewQuery->avg('rating') ?? 0), 1);
                $reviewCount = (clone $reviewQuery)->count();
                $reviews = (clone $reviewQuery)
                    ->with([
                        'customer' => function ($query) {
                            $query->select('id', 'fname', 'lname', 'photo');
                        },
                    ])
                    ->orderByDesc('created_at')
                    ->limit(10)
                    ->get();
            } elseif (Schema::hasTable('organizer_reviews') && $legacy && method_exists($legacy, 'reviews')) {
                $averageRating = round((float) ($legacy->reviews()->avg('rating') ?? 0), 1);
                $reviewCount = (int) $legacy->reviews()->count();
                $reviews = $legacy->reviews()
                    ->with([
                        'customer' => function ($query) {
                            $query->select('id', 'fname', 'lname', 'photo');
                        },
                    ])
                    ->orderByDesc('created_at')
                    ->limit(10)
                    ->get();
            }
        }

        return [
            'id' => (int) $target['profile_id'],
            'identity_id' => $identity?->id,
            'legacy_organizer_id' => $legacyId,
            'supports_follow' => $legacyId !== null,
            'supports_contact' => $legacyId !== null || $identity !== null,
            'supports_reviews' => $legacyId !== null,
            'photo' => PublicAssetUrl::url($legacy?->photo ?? ($meta['photo'] ?? null), 'assets/admin/img/organizer-photo'),
            'cover_photo' => PublicAssetUrl::url($legacy?->cover_photo ?? ($meta['cover_photo'] ?? null), 'assets/admin/img/organizer-cover'),
            'phone' => $legacy?->phone ?? null,
            'email' => $legacy?->email ?? null,
            'username' => $identity?->slug ?? ($legacy?->username ?? ($meta['username'] ?? null)),
            'status' => $legacy?->status ?? ($identity?->status === 'active' ? 1 : 0),
            'facebook' => $legacy?->facebook ?? ($meta['facebook'] ?? null),
            'twitter' => $legacy?->twitter ?? ($meta['twitter'] ?? ($meta['instagram'] ?? null)),
            'linkedin' => $legacy?->linkedin ?? ($meta['linkedin'] ?? null),
            'instagram' => $meta['instagram'] ?? null,
            'tiktok' => $meta['tiktok'] ?? null,
            'website' => $meta['website'] ?? null,
            'organizer_name' => $target['name'],
            'name' => $target['name'],
            'country' => $target['country'],
            'city' => $target['city'],
            'state' => $target['state'],
            'address' => $target['address'],
            'zip_code' => $target['zip_code'],
            'designation' => $target['designation'],
            'details' => $target['details'],
            'user_type' => 'organizer',
            'followers_count' => $followersCount,
            'events_count' => $this->eventCountForTarget($target, false),
            'is_followed' => $isFollowed,
            'average_rating' => number_format($averageRating, 1, '.', ''),
            'review_count' => $reviewCount,
            'reviews' => $reviews,
            'identity' => $this->catalogBridge->publicIdentity($identity),
        ];
    }

    public function buildDirectoryRecords(?int $languageId = null, string $search = ''): Collection
    {
        $normalizedSearch = $this->normalizeSearch($search);
        $legacyRows = $this->loadLegacyRows($languageId);
        $legacyRowsById = $legacyRows->keyBy('id');

        $identities = Identity::query()
            ->where('type', 'organizer')
            ->where('status', 'active')
            ->get();

        $usedLegacyIds = [];
        $records = collect();

        foreach ($identities as $identity) {
            $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, 'organizer');
            $legacyRow = $legacyId !== null ? $legacyRowsById->get((int) $legacyId) : null;
            $target = $this->hydrateTarget($identity, $languageId, $legacyRow ? Organizer::query()->find($legacyRow->id) : null, $legacyRow);

            if (!$target || !$this->targetMatchesSearch($target, $normalizedSearch)) {
                continue;
            }

            if ($legacyId !== null) {
                $usedLegacyIds[] = (int) $legacyId;
            }

            $records->push($this->buildDirectoryRecord($target));
        }

        foreach ($legacyRows as $legacyRow) {
            if (in_array((int) $legacyRow->id, $usedLegacyIds, true)) {
                continue;
            }

            $target = $this->hydrateTarget(null, $languageId, Organizer::query()->find($legacyRow->id), $legacyRow);
            if (!$target || !$this->targetMatchesSearch($target, $normalizedSearch)) {
                continue;
            }

            $records->push($this->buildDirectoryRecord($target));
        }

        return $this->attachDirectoryMetrics($records);
    }

    public function buildUpcomingEvents(?int $languageId = null, int $limit = 12, string $search = ''): array
    {
        $normalizedSearch = $this->normalizeSearch($search);

        $rows = DB::table('events')
            ->leftJoin('event_contents', function ($join) use ($languageId) {
                $join->on('event_contents.event_id', '=', 'events.id');
                if ($languageId !== null) {
                    $join->where('event_contents.language_id', '=', $languageId);
                }
            })
            ->where('events.status', 1)
            ->where(function ($query) {
                $query->whereNotNull('events.owner_identity_id')
                    ->orWhereNotNull('events.organizer_id');
            });

        $this->applyUpcomingConstraint($rows);

        $events = $rows
            ->orderBy('events.start_date')
            ->orderBy('events.end_date_time')
            ->limit($limit * 4)
            ->get([
                'events.id',
                'events.thumbnail',
                'events.start_date',
                'events.end_date_time',
                'events.owner_identity_id',
                'events.organizer_id',
                'event_contents.title',
            ]);

        $payload = [];
        foreach ($events as $event) {
            $target = $this->resolveFromOwnership($event->owner_identity_id, $event->organizer_id, $languageId);
            if (!$target) {
                continue;
            }

            if ($normalizedSearch !== '') {
                $haystacks = [
                    $event->title,
                    $target['name'],
                    $target['username'],
                    $target['city'],
                ];
                if (!$this->matchesSearch($normalizedSearch, $haystacks)) {
                    continue;
                }
            }

            $payload[] = [
                'id' => (int) $event->id,
                'title' => $event->title ?: ('Event #' . $event->id),
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'starts_at' => $this->isoDate($event->start_date),
                'ends_at' => $this->isoDate($event->end_date_time),
                'organizer' => [
                    'id' => (int) $target['profile_id'],
                    'legacy_organizer_id' => $target['legacy_id'],
                    'name' => $target['name'],
                    'identity' => $this->catalogBridge->publicIdentity($target['identity']),
                ],
            ];

            if (count($payload) >= $limit) {
                break;
            }
        }

        return $payload;
    }

    public function organizerNameForEvent(
        int|string|null $ownerIdentityId,
        int|string|null $legacyOrganizerId,
        ?int $languageId = null
    ): ?string {
        $target = $this->resolveFromOwnership($ownerIdentityId, $legacyOrganizerId, $languageId);
        if (!$target) {
            return null;
        }

        return $target['username'] ?: $target['name'];
    }

    public function organizerPayloadForEvent(
        int|string|null $ownerIdentityId,
        int|string|null $legacyOrganizerId,
        ?int $languageId = null
    ): ?array {
        $target = $this->resolveFromOwnership($ownerIdentityId, $legacyOrganizerId, $languageId);
        if (!$target) {
            return null;
        }

        return $this->buildPublicPayload($target, Auth::guard('sanctum')->user());
    }

    public function applyOwnershipConstraint(Builder $query, array $target): Builder
    {
        return $query->ownedByOrganizerActor(
            $target['identity']?->id,
            $target['legacy_id']
        );
    }

    private function hydrateTarget(
        ?Identity $identity,
        ?int $languageId = null,
        ?Organizer $legacyOrganizer = null,
        ?object $preloadedLegacyRow = null
    ): ?array {
        $legacyId = $identity
            ? $this->catalogBridge->legacyIdForIdentity($identity, 'organizer')
            : ($legacyOrganizer?->id ?? null);

        $legacyRow = $preloadedLegacyRow;
        if ($legacyRow === null && $legacyId !== null) {
            $legacyRow = $this->loadLegacyRows($languageId)
                ->firstWhere('id', (int) $legacyId);
        }

        if ($legacyOrganizer === null && $legacyId !== null) {
            $legacyOrganizer = Organizer::query()->find($legacyId);
        }

        if (!$identity && !$legacyOrganizer && !$legacyRow) {
            return null;
        }

        $meta = $identity?->meta ?? [];
        $name = trim((string) ($identity?->display_name
            ?? $legacyRow?->organizer_name
            ?? $legacyOrganizer?->organizer_name
            ?? $legacyOrganizer?->username
            ?? ($meta['display_name'] ?? 'Organizer')));

        return [
            'profile_id' => (int) ($identity?->id ?? $legacyId ?? 0),
            'identity' => $identity,
            'legacy' => $legacyOrganizer,
            'legacy_id' => $legacyId !== null ? (int) $legacyId : null,
            'name' => $name,
            'username' => $legacyRow?->username ?? $legacyOrganizer?->username ?? ($meta['username'] ?? ($identity?->slug)),
            'city' => $meta['city'] ?? $legacyRow?->city ?? $legacyOrganizer?->city ?? null,
            'country' => $meta['country'] ?? $legacyRow?->country ?? $legacyOrganizer?->country ?? null,
            'state' => $meta['state'] ?? $legacyRow?->state ?? $legacyOrganizer?->state ?? null,
            'zip_code' => $meta['zip_code'] ?? $legacyRow?->zip_code ?? $legacyOrganizer?->zip_code ?? null,
            'address' => $meta['address_line'] ?? $legacyRow?->address ?? $legacyOrganizer?->address ?? null,
            'designation' => $meta['designation'] ?? $legacyRow?->designation ?? $legacyOrganizer?->designation ?? null,
            'details' => $meta['details'] ?? $legacyRow?->details ?? $legacyOrganizer?->details ?? null,
            'photo' => $legacyRow?->photo ?? $legacyOrganizer?->photo ?? null,
            'created_at' => $identity?->created_at ?? $legacyRow?->created_at ?? $legacyOrganizer?->created_at,
        ];
    }

    private function buildDirectoryRecord(array $target): array
    {
        return [
            'id' => (int) $target['profile_id'],
            'legacy_organizer_id' => $target['legacy_id'],
            'identity_id' => $target['identity']?->id,
            'type' => 'organizer',
            'name' => $target['name'],
            'username' => $target['username'],
            'photo' => PublicAssetUrl::url($target['photo'], 'assets/admin/img/organizer-photo'),
            'city' => $target['city'],
            'country' => $target['country'],
            'designation' => $target['designation'],
            'details' => $target['details'],
            'followers_count' => 0,
            'upcoming_events_count' => 0,
            'total_events_count' => 0,
            'average_rating' => 0.0,
            'review_count' => 0,
            'has_identity' => $target['identity'] !== null,
            'identity' => $this->catalogBridge->publicIdentity($target['identity']),
            'created_at' => $this->isoDate($target['created_at']),
            '_created_sort' => $this->timestampValue($target['created_at']),
        ];
    }

    private function attachDirectoryMetrics(Collection $records): Collection
    {
        if ($records->isEmpty()) {
            return collect();
        }

        $identityIds = $records->pluck('identity_id')->filter()->map(fn ($id) => (int) $id)->values();
        $legacyIds = $records->pluck('legacy_organizer_id')->filter()->map(fn ($id) => (int) $id)->values();

        $followers = $this->acceptedFollowerCounts($legacyIds);
        $reviews = $this->publishedReviewStats($legacyIds);
        $upcomingByIdentity = $this->eventCountsByIdentity($identityIds, true);
        $upcomingByLegacy = $this->eventCountsByLegacyFallback($legacyIds, true);
        $totalByIdentity = $this->eventCountsByIdentity($identityIds, false);
        $totalByLegacy = $this->eventCountsByLegacyFallback($legacyIds, false);

        return $records->map(function (array $record) use (
            $followers,
            $reviews,
            $upcomingByIdentity,
            $upcomingByLegacy,
            $totalByIdentity,
            $totalByLegacy
        ) {
            $legacyId = $record['legacy_organizer_id'];
            $identityId = $record['identity_id'];
            $reviewMeta = $legacyId !== null
                ? ($reviews->get($legacyId, ['average_rating' => 0.0, 'review_count' => 0]))
                : ['average_rating' => 0.0, 'review_count' => 0];

            $record['followers_count'] = $legacyId !== null ? (int) ($followers[$legacyId] ?? 0) : 0;
            $record['upcoming_events_count'] = (int) ($identityId !== null ? ($upcomingByIdentity[$identityId] ?? 0) : 0)
                + (int) ($legacyId !== null ? ($upcomingByLegacy[$legacyId] ?? 0) : 0);
            $record['total_events_count'] = (int) ($identityId !== null ? ($totalByIdentity[$identityId] ?? 0) : 0)
                + (int) ($legacyId !== null ? ($totalByLegacy[$legacyId] ?? 0) : 0);
            $record['average_rating'] = (float) ($reviewMeta['average_rating'] ?? 0.0);
            $record['review_count'] = (int) ($reviewMeta['review_count'] ?? 0);

            return $record;
        });
    }

    private function eventCountForTarget(array $target, bool $upcomingOnly): int
    {
        $identityId = $target['identity']?->id;
        $legacyId = $target['legacy_id'];

        return (int) ($identityId !== null ? ($this->eventCountsByIdentity(collect([$identityId]), $upcomingOnly)[$identityId] ?? 0) : 0)
            + (int) ($legacyId !== null ? ($this->eventCountsByLegacyFallback(collect([$legacyId]), $upcomingOnly)[$legacyId] ?? 0) : 0);
    }

    private function acceptedFollowerCounts(Collection $legacyIds): Collection
    {
        if ($legacyIds->isEmpty()) {
            return collect();
        }

        return DB::table('follows')
            ->where('followable_type', Organizer::class)
            ->where('status', 'accepted')
            ->whereIn('followable_id', $legacyIds->all())
            ->selectRaw('followable_id as target_id, COUNT(*) as aggregate')
            ->groupBy('followable_id')
            ->pluck('aggregate', 'target_id');
    }

    private function publishedReviewStats(Collection $legacyIds): Collection
    {
        if ($legacyIds->isEmpty() || !Schema::hasTable('reviews')) {
            return collect();
        }

        return DB::table('reviews')
            ->where('reviewable_type', Organizer::class)
            ->where('status', 'published')
            ->whereIn('reviewable_id', $legacyIds->all())
            ->selectRaw('reviewable_id as target_id, AVG(rating) as average_rating, COUNT(*) as review_count')
            ->groupBy('reviewable_id')
            ->get()
            ->keyBy('target_id')
            ->map(fn ($row) => [
                'average_rating' => round((float) ($row->average_rating ?? 0), 1),
                'review_count' => (int) ($row->review_count ?? 0),
            ]);
    }

    private function eventCountsByIdentity(Collection $identityIds, bool $upcomingOnly): Collection
    {
        if ($identityIds->isEmpty()) {
            return collect();
        }

        $query = DB::table('events')
            ->where('status', 1)
            ->whereIn('owner_identity_id', $identityIds->all());

        if ($upcomingOnly) {
            $this->applyUpcomingConstraint($query);
        }

        return $query
            ->selectRaw('owner_identity_id as target_id, COUNT(DISTINCT id) as aggregate')
            ->groupBy('owner_identity_id')
            ->pluck('aggregate', 'target_id');
    }

    private function eventCountsByLegacyFallback(Collection $legacyIds, bool $upcomingOnly): Collection
    {
        if ($legacyIds->isEmpty()) {
            return collect();
        }

        $query = DB::table('events')
            ->where('status', 1)
            ->whereNull('owner_identity_id')
            ->whereIn('organizer_id', $legacyIds->all());

        if ($upcomingOnly) {
            $this->applyUpcomingConstraint($query);
        }

        return $query
            ->selectRaw('organizer_id as target_id, COUNT(DISTINCT id) as aggregate')
            ->groupBy('organizer_id')
            ->pluck('aggregate', 'target_id');
    }

    private function loadLegacyRows(?int $languageId = null): Collection
    {
        static $cache = [];

        $cacheKey = (string) ($languageId ?? 'default');
        if (array_key_exists($cacheKey, $cache)) {
            return $cache[$cacheKey];
        }

        $query = DB::table('organizers')
            ->where('organizers.status', '1')
            ->leftJoin('organizer_infos', function ($join) use ($languageId) {
                $join->on('organizers.id', '=', 'organizer_infos.organizer_id');
                if ($languageId !== null) {
                    $join->where('organizer_infos.language_id', '=', $languageId);
                }
            })
            ->select([
                'organizers.id',
                'organizers.username',
                'organizers.photo',
                'organizers.phone',
                'organizers.email',
                'organizers.facebook',
                'organizers.twitter',
                'organizers.linkedin',
                'organizers.status',
                'organizers.created_at',
                'organizer_infos.name as organizer_name',
                'organizer_infos.city',
                'organizer_infos.country',
                'organizer_infos.state',
                'organizer_infos.zip_code',
                'organizer_infos.address',
                'organizer_infos.designation',
                'organizer_infos.details',
            ]);

        return $cache[$cacheKey] = $query->get()
            ->unique('id')
            ->values();
    }

    private function applyUpcomingConstraint($query): void
    {
        $now = now()->toDateTimeString();

        $query->where(function ($builder) use ($now) {
            $builder->where('events.end_date_time', '>=', $now)
                ->orWhere(function ($fallback) use ($now) {
                    $fallback->whereNull('events.end_date_time')
                        ->where('events.start_date', '>=', $now);
                });
        });
    }

    private function targetMatchesSearch(array $target, string $search): bool
    {
        if ($search === '') {
            return true;
        }

        return $this->matchesSearch($search, [
            $target['name'],
            $target['username'],
            $target['city'],
            $target['country'],
            $target['designation'],
            $target['details'],
        ]);
    }

    private function matchesSearch(string $search, array $haystacks): bool
    {
        if ($search === '') {
            return true;
        }

        foreach ($haystacks as $haystack) {
            if ($haystack !== null && str_contains(mb_strtolower((string) $haystack), $search)) {
                return true;
            }
        }

        return false;
    }

    private function normalizeSearch(string $search): string
    {
        return mb_strtolower(trim($search));
    }

    private function cacheKey(string $prefix, ?int $languageId): string
    {
        return $prefix . ':' . ($languageId ?? 'default');
    }

    private function isoDate($value): ?string
    {
        if ($value === null) {
            return null;
        }

        return optional($value)->toIso8601String() ?? (string) $value;
    }

    private function timestampValue($value): int
    {
        if ($value instanceof \DateTimeInterface) {
            return $value->getTimestamp();
        }

        $timestamp = strtotime((string) $value);

        return $timestamp !== false ? $timestamp : 0;
    }
}
