<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Identity;
use App\Models\Review;
use App\Models\Venue;
use App\Support\PublicAssetUrl;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class VenuePublicProfileService
{
    private array $targetCache = [];

    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function resolveByPublicId(int|string|null $id): ?array
    {
        if ($id === null || $id === '' || (string) $id === '0') {
            return null;
        }

        $cacheKey = 'public:' . $id;
        if (array_key_exists($cacheKey, $this->targetCache)) {
            return $this->targetCache[$cacheKey];
        }

        $identity = Identity::query()
            ->where('type', 'venue')
            ->find($id);

        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity);
        }

        $identity = $this->catalogBridge->findIdentityForLegacy('venue', $id);
        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity);
        }

        $legacyVenue = Venue::query()->find($id);
        if (!$legacyVenue) {
            return $this->targetCache[$cacheKey] = null;
        }

        return $this->targetCache[$cacheKey] = $this->hydrateTarget(null, $legacyVenue);
    }

    public function resolveFromOwnership(int|string|null $venueIdentityId, int|string|null $legacyVenueId): ?array
    {
        $cacheKey = 'owned:' . ($venueIdentityId ?? 'null') . ':' . ($legacyVenueId ?? 'null');
        if (array_key_exists($cacheKey, $this->targetCache)) {
            return $this->targetCache[$cacheKey];
        }

        $identity = null;
        if ($venueIdentityId !== null) {
            $identity = Identity::query()
                ->where('type', 'venue')
                ->find($venueIdentityId);
        }

        $legacyVenue = null;
        if ($legacyVenueId !== null) {
            $legacyVenue = Venue::query()->find($legacyVenueId);
        }

        if (!$identity && $legacyVenueId !== null) {
            $identity = $this->catalogBridge->findIdentityForLegacy('venue', $legacyVenueId);
        }

        if (!$identity && !$legacyVenue) {
            return $this->targetCache[$cacheKey] = null;
        }

        return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity, $legacyVenue);
    }

    public function buildPublicPayload(array $target, ?Customer $viewer = null, ?int $languageId = null): array
    {
        $legacyId = $target['legacy_id'];
        $identity = $target['identity'];

        $followersCount = 0;
        $isFollowing = false;
        $averageRating = 0.0;
        $reviewCount = 0;

        if ($legacyId !== null) {
            $followersCount = DB::table('follows')
                ->where('followable_id', $legacyId)
                ->where('followable_type', Venue::class)
                ->where('status', 'accepted')
                ->count();

            if ($viewer) {
                $isFollowing = DB::table('follows')
                    ->where('followable_id', $legacyId)
                    ->where('followable_type', Venue::class)
                    ->where('status', 'accepted')
                    ->where('follower_id', $viewer->id)
                    ->where('follower_type', Customer::class)
                    ->exists();
            }

            if (Schema::hasTable('reviews')) {
                $reviewQuery = Review::query()
                    ->where('reviewable_type', Venue::class)
                    ->where('reviewable_id', $legacyId)
                    ->where('status', 'published');

                $averageRating = round((float) ($reviewQuery->avg('rating') ?? 0), 1);
                $reviewCount = (clone $reviewQuery)->count();
            }
        }

        ['events' => $events, 'past_events' => $pastEvents] = $this->buildProfileEvents($target, $languageId);

        return [
            'id' => (int) ($legacyId ?? $target['profile_id']),
            'profile_id' => (int) $target['profile_id'],
            'identity_id' => $identity?->id,
            'legacy_venue_id' => $legacyId,
            'supports_follow' => $legacyId !== null,
            'supports_contact' => $legacyId !== null,
            'name' => $target['name'],
            'slug' => $target['slug'],
            'address' => $target['address'],
            'city' => $target['city'],
            'state' => $target['state'],
            'country' => $target['country'],
            'zip_code' => $target['zip_code'],
            'latitude' => $target['latitude'],
            'longitude' => $target['longitude'],
            'description' => $target['description'],
            'image' => $target['image'],
            'status' => $target['status'],
            'followers_count' => $followersCount,
            'is_following' => $isFollowing,
            'average_rating' => number_format($averageRating, 1, '.', ''),
            'review_count' => $reviewCount,
            'socials' => $target['socials'],
            'identity' => $this->catalogBridge->publicIdentity($identity),
            'events' => $events,
            'past_events' => $pastEvents,
        ];
    }

    public function buildDirectoryRecords(string $search = ''): Collection
    {
        $normalizedSearch = $this->normalizeSearch($search);
        $legacyVenues = Venue::query()
            ->where('status', 1)
            ->get([
                'id',
                'name',
                'slug',
                'address',
                'city',
                'state',
                'country',
                'zip_code',
                'latitude',
                'longitude',
                'description',
                'image',
                'status',
                'created_at',
            ]);

        $legacyById = $legacyVenues->keyBy('id');
        $identities = Identity::query()
            ->where('type', 'venue')
            ->where('status', 'active')
            ->get();

        $usedLegacyIds = [];
        $records = collect();

        foreach ($identities as $identity) {
            $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, 'venue');
            $legacyVenue = $legacyId !== null ? $legacyById->get((int) $legacyId) : null;
            $target = $this->hydrateTarget($identity, $legacyVenue);

            if (!$target || !$this->targetMatchesSearch($target, $normalizedSearch)) {
                continue;
            }

            if ($legacyId !== null) {
                $usedLegacyIds[] = (int) $legacyId;
            }

            $records->push($this->buildDirectoryRecord($target));
        }

        foreach ($legacyVenues as $legacyVenue) {
            if (in_array((int) $legacyVenue->id, $usedLegacyIds, true)) {
                continue;
            }

            $target = $this->hydrateTarget(null, $legacyVenue);
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
                $query->whereNotNull('events.venue_identity_id')
                    ->orWhereNotNull('events.venue_id');
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
                'events.venue_id',
                'events.venue_identity_id',
                'event_contents.title',
            ]);

        return $events->map(function ($event) use ($normalizedSearch) {
            $target = $this->resolveFromOwnership($event->venue_identity_id, $event->venue_id);
            $matchesTarget = $target && $this->targetMatchesSearch($target, $normalizedSearch);
            $matchesTitle = $normalizedSearch === '' || str_contains(
                mb_strtolower((string) ($event->title ?? '')),
                $normalizedSearch
            );

            if (!$target || (!$matchesTarget && !$matchesTitle)) {
                return null;
            }

            return [
                'id' => (int) $event->id,
                'title' => $event->title ?: ('Event #' . $event->id),
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'starts_at' => $this->isoDate($event->start_date),
                'ends_at' => $this->isoDate($event->end_date_time),
                'venue' => [
                    'id' => (int) ($target['legacy_id'] ?? $target['profile_id']),
                    'name' => $target['name'],
                    'identity' => $this->catalogBridge->publicIdentity($target['identity']),
                ],
            ];
        })->filter()->take($limit)->values()->all();
    }

    private function buildProfileEvents(array $target, ?int $languageId = null): array
    {
        $rows = DB::table('events')
            ->leftJoin('event_contents', function ($join) use ($languageId) {
                $join->on('event_contents.event_id', '=', 'events.id');
                if ($languageId !== null) {
                    $join->where('event_contents.language_id', '=', $languageId);
                }
            })
            ->where('events.status', 1)
            ->where(function ($query) use ($target) {
                if (!empty($target['identity']?->id)) {
                    $query->where('venue_identity_id', $target['identity']->id);

                    if (!empty($target['legacy_id'])) {
                        $query->orWhere(function ($fallback) use ($target) {
                            $fallback->whereNull('venue_identity_id')
                                ->where('venue_id', $target['legacy_id']);
                        });
                    }

                    return;
                }

                if (!empty($target['legacy_id'])) {
                    $query->where('venue_id', $target['legacy_id']);
                    return;
                }

                $query->whereRaw('1 = 0');
            })
            ->orderBy('events.start_date')
            ->limit(24)
            ->get([
                'events.id',
                'events.thumbnail',
                'events.start_date',
                'events.start_time',
                'events.end_date_time',
                'event_contents.title',
                'event_contents.slug',
                'event_contents.address',
            ]);

        $upcoming = [];
        $past = [];

        $ticketPriceMap = $this->resolveEventStartPrices($rows->pluck('id')->values());

        foreach ($rows as $event) {
            $formatted = [
                'id' => (int) $event->id,
                'title' => $event->title ?: ('Event #' . $event->id),
                'slug' => $event->slug,
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'date' => $this->isoDate($event->start_date),
                'time' => $event->start_time,
                'start_price' => $ticketPriceMap[$event->id] ?? 0,
                'address' => $event->address,
            ];

            if ($this->isPastEvent($event)) {
                $past[] = $formatted;
            } else {
                $upcoming[] = $formatted;
            }
        }

        return [
            'events' => $upcoming,
            'past_events' => $past,
        ];
    }

    private function buildDirectoryRecord(array $target): array
    {
        return [
            'id' => (int) ($target['legacy_id'] ?? $target['profile_id']),
            'profile_id' => (int) $target['profile_id'],
            'legacy_venue_id' => $target['legacy_id'],
            'identity_id' => $target['identity']?->id,
            'type' => 'venue',
            'name' => $target['name'],
            'slug' => $target['slug'],
            'photo' => $target['image'],
            'city' => $target['city'],
            'country' => $target['country'],
            'description' => $target['description'],
            'followers_count' => 0,
            'upcoming_events_count' => 0,
            'total_events_count' => 0,
            'average_rating' => 0.0,
            'review_count' => 0,
            'has_identity' => $target['identity'] !== null,
            'identity' => $this->catalogBridge->publicIdentity($target['identity']),
            'created_at' => $target['created_at']?->toIso8601String(),
            '_created_sort' => $this->timestampValue($target['created_at']),
        ];
    }

    private function attachDirectoryMetrics(Collection $records): Collection
    {
        $legacyIds = $records->pluck('legacy_venue_id')
            ->filter(fn ($value) => $value !== null)
            ->map(fn ($value) => (int) $value)
            ->values();
        $identityIds = $records->pluck('identity_id')
            ->filter(fn ($value) => $value !== null)
            ->map(fn ($value) => (int) $value)
            ->values();

        $followers = $this->acceptedFollowerCounts($legacyIds);
        $reviewStats = $this->publishedReviewStats($legacyIds);
        $identityUpcoming = $this->eventCountsByIdentity($identityIds, true);
        $identityTotal = $this->eventCountsByIdentity($identityIds, false);
        $legacyUpcoming = $this->eventCountsByLegacy($legacyIds, true);
        $legacyTotal = $this->eventCountsByLegacy($legacyIds, false);

        return $records->map(function (array $record) use ($followers, $reviewStats, $identityUpcoming, $identityTotal, $legacyUpcoming, $legacyTotal) {
            $legacyId = $record['legacy_venue_id'];
            $identityId = $record['identity_id'];
            $ratingMeta = $legacyId !== null
                ? ($reviewStats->get($legacyId, ['average_rating' => 0.0, 'review_count' => 0]))
                : ['average_rating' => 0.0, 'review_count' => 0];

            $record['followers_count'] = $legacyId !== null ? (int) ($followers[$legacyId] ?? 0) : 0;
            $record['upcoming_events_count'] = (int) (($identityId !== null ? ($identityUpcoming[$identityId] ?? 0) : 0) + ($legacyId !== null ? ($legacyUpcoming[$legacyId] ?? 0) : 0));
            $record['total_events_count'] = (int) (($identityId !== null ? ($identityTotal[$identityId] ?? 0) : 0) + ($legacyId !== null ? ($legacyTotal[$legacyId] ?? 0) : 0));
            $record['average_rating'] = (float) ($ratingMeta['average_rating'] ?? 0.0);
            $record['review_count'] = (int) ($ratingMeta['review_count'] ?? 0);

            return $record;
        })->values();
    }

    private function acceptedFollowerCounts(Collection $venueIds): Collection
    {
        if ($venueIds->isEmpty()) {
            return collect();
        }

        return DB::table('follows')
            ->where('followable_type', Venue::class)
            ->where('status', 'accepted')
            ->whereIn('followable_id', $venueIds->all())
            ->selectRaw('followable_id as target_id, COUNT(*) as aggregate')
            ->groupBy('followable_id')
            ->pluck('aggregate', 'target_id');
    }

    private function publishedReviewStats(Collection $venueIds): Collection
    {
        if ($venueIds->isEmpty() || !Schema::hasTable('reviews')) {
            return collect();
        }

        return DB::table('reviews')
            ->where('reviewable_type', Venue::class)
            ->where('status', 'published')
            ->whereIn('reviewable_id', $venueIds->all())
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
            ->whereIn('venue_identity_id', $identityIds->all())
            ->where('status', 1);

        if ($upcomingOnly) {
            $this->applyUpcomingConstraint($query);
        }

        return $query
            ->selectRaw('venue_identity_id as target_id, COUNT(DISTINCT id) as aggregate')
            ->groupBy('venue_identity_id')
            ->pluck('aggregate', 'target_id');
    }

    private function eventCountsByLegacy(Collection $venueIds, bool $upcomingOnly): Collection
    {
        if ($venueIds->isEmpty()) {
            return collect();
        }

        $query = DB::table('events')
            ->whereNull('venue_identity_id')
            ->whereIn('venue_id', $venueIds->all())
            ->where('status', 1);

        if ($upcomingOnly) {
            $this->applyUpcomingConstraint($query);
        }

        return $query
            ->selectRaw('venue_id as target_id, COUNT(DISTINCT id) as aggregate')
            ->groupBy('venue_id')
            ->pluck('aggregate', 'target_id');
    }

    private function hydrateTarget(?Identity $identity = null, ?Venue $legacyVenue = null): ?array
    {
        if (!$identity && !$legacyVenue) {
            return null;
        }

        $legacyId = $legacyVenue?->id;
        if ($legacyId === null && $identity) {
            $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, 'venue');
            if ($legacyId !== null && !$legacyVenue) {
                $legacyVenue = Venue::query()->find($legacyId);
            }
        }

        $meta = is_array($identity?->meta) ? $identity->meta : [];
        $image = PublicAssetUrl::url($legacyVenue?->image ?? ($meta['image'] ?? $meta['photo'] ?? null), 'assets/admin/img/venue');
        $coverPhoto = PublicAssetUrl::url($meta['cover_photo'] ?? null, 'assets/admin/img/venue');

        return [
            'profile_id' => (int) ($legacyId ?? $identity?->id ?? 0),
            'legacy_id' => $legacyId !== null ? (int) $legacyId : null,
            'identity' => $identity,
            'legacy' => $legacyVenue,
            'name' => $identity?->display_name ?? $legacyVenue?->name ?? null,
            'slug' => $legacyVenue?->slug ?? ($identity?->slug),
            'address' => $legacyVenue?->address ?? ($meta['address_line'] ?? null),
            'city' => $legacyVenue?->city ?? ($meta['city'] ?? null),
            'state' => $legacyVenue?->state ?? ($meta['state'] ?? null),
            'country' => $legacyVenue?->country ?? ($meta['country'] ?? null),
            'zip_code' => $legacyVenue?->zip_code ?? ($meta['zip_code'] ?? null),
            'latitude' => $legacyVenue?->latitude ?? ($meta['latitude'] ?? null),
            'longitude' => $legacyVenue?->longitude ?? ($meta['longitude'] ?? null),
            'description' => $legacyVenue?->description ?? ($meta['description'] ?? ($meta['details'] ?? null)),
            'image' => $image,
            'cover_photo' => $coverPhoto,
            'status' => (int) ($legacyVenue?->status ?? ($identity?->status === 'active' ? 1 : 0)),
            'socials' => [
                'instagram' => $meta['instagram'] ?? null,
                'facebook' => $meta['facebook'] ?? null,
                'tiktok' => $meta['tiktok'] ?? null,
                'whatsapp' => $meta['whatsapp'] ?? null,
            ],
            'created_at' => $legacyVenue?->created_at ?? $identity?->created_at,
        ];
    }

    private function targetMatchesSearch(array $target, string $search): bool
    {
        if ($search === '') {
            return true;
        }

        $haystack = mb_strtolower(implode(' ', array_filter([
            $target['name'] ?? null,
            $target['city'] ?? null,
            $target['country'] ?? null,
            $target['description'] ?? null,
        ])));

        return str_contains($haystack, $search);
    }

    private function isPastEvent(object $event): bool
    {
        if (!empty($event->end_date_time)) {
            return now()->greaterThan($event->end_date_time);
        }

        if (!empty($event->start_date)) {
            return now()->greaterThan($event->start_date);
        }

        return false;
    }

    private function resolveEventStartPrices(Collection $eventIds): array
    {
        if ($eventIds->isEmpty() || !Schema::hasTable('tickets')) {
            return [];
        }

        $prices = [];
        $rows = DB::table('tickets')
            ->whereIn('event_id', $eventIds->all())
            ->get(['event_id', 'price']);

        foreach ($rows->groupBy('event_id') as $eventId => $tickets) {
            $normalized = collect($tickets)->map(function ($ticket) {
                if (($ticket->price ?? null) === 'free' || (float) ($ticket->price ?? 0) <= 0) {
                    return 'free';
                }

                return (float) $ticket->price;
            });

            $numeric = $normalized->filter(fn ($value) => $value !== 'free')->sort()->values();
            $prices[(int) $eventId] = $numeric->isNotEmpty()
                ? (float) $numeric->first()
                : ($normalized->contains('free') ? 'free' : 0);
        }

        return $prices;
    }

    private function normalizeSearch(string $search): string
    {
        return mb_strtolower(trim($search));
    }

    private function applyUpcomingConstraint($query): void
    {
        $now = now()->toDateTimeString();

        $query->where(function ($subQuery) use ($now) {
            $subQuery->where('events.end_date_time', '>=', $now)
                ->orWhere(function ($fallbackQuery) use ($now) {
                    $fallbackQuery->whereNull('events.end_date_time')
                        ->where('events.start_date', '>=', $now);
                });
        });
    }

    private function timestampValue($value): int
    {
        if ($value instanceof \DateTimeInterface) {
            return $value->getTimestamp();
        }

        if ($value === null) {
            return 0;
        }

        $timestamp = strtotime((string) $value);

        return $timestamp !== false ? $timestamp : 0;
    }

    private function isoDate($value): ?string
    {
        $timestamp = $this->timestampValue($value);
        if ($timestamp === 0) {
            return null;
        }

        return date(DATE_ATOM, $timestamp);
    }
}
