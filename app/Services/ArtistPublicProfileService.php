<?php

namespace App\Services;

use App\Models\Artist;
use App\Models\Customer;
use App\Models\Identity;
use App\Models\Review;
use App\Support\PublicAssetUrl;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ArtistPublicProfileService
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
            ->where('type', 'artist')
            ->find($id);

        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity);
        }

        $identity = $this->catalogBridge->findIdentityForLegacy('artist', $id);
        if ($identity) {
            return $this->targetCache[$cacheKey] = $this->hydrateTarget($identity);
        }

        $legacyArtist = Artist::query()->find($id);
        if (!$legacyArtist) {
            return $this->targetCache[$cacheKey] = null;
        }

        return $this->targetCache[$cacheKey] = $this->hydrateTarget(null, $legacyArtist);
    }

    public function buildPublicPayload(array $target, ?Customer $viewer = null): array
    {
        $legacyId = $target['legacy_id'];
        $identity = $target['identity'];

        $followersCount = 0;
        $isFollowed = false;
        $hasPendingRequest = false;
        $averageRating = 0.0;
        $reviewCount = 0;

        if ($legacyId !== null) {
            $followersCount = DB::table('follows')
                ->where('followable_id', $legacyId)
                ->where('followable_type', Artist::class)
                ->where('status', 'accepted')
                ->count();

            if ($viewer) {
                $isFollowed = DB::table('follows')
                    ->where('followable_id', $legacyId)
                    ->where('followable_type', Artist::class)
                    ->where('status', 'accepted')
                    ->where('follower_id', $viewer->id)
                    ->where('follower_type', Customer::class)
                    ->exists();

                $hasPendingRequest = DB::table('follows')
                    ->where('followable_id', $legacyId)
                    ->where('followable_type', Artist::class)
                    ->where('status', 'pending')
                    ->where('follower_id', $viewer->id)
                    ->where('follower_type', Customer::class)
                    ->exists();
            }

            if (Schema::hasTable('reviews')) {
                $reviewQuery = Review::query()
                    ->where('reviewable_type', Artist::class)
                    ->where('reviewable_id', $legacyId)
                    ->where('status', 'published');

                $averageRating = round((float) ($reviewQuery->avg('rating') ?? 0), 1);
                $reviewCount = (clone $reviewQuery)->count();
            }
        }

        return [
            'id' => (int) ($legacyId ?? $target['profile_id']),
            'profile_id' => (int) $target['profile_id'],
            'identity_id' => $identity?->id,
            'legacy_artist_id' => $legacyId,
            'supports_follow' => $legacyId !== null,
            'supports_contact' => $legacyId !== null,
            'supports_reviews' => $legacyId !== null,
            'name' => $target['name'],
            'username' => $target['username'],
            'photo' => $target['photo'],
            'cover_photo' => $target['cover_photo'],
            'details' => $target['details'],
            'genres' => $target['genres'],
            'city' => $target['city'],
            'country' => $target['country'],
            'gallery' => $target['gallery'],
            'booking_notes' => $target['booking_notes'],
            'status' => $target['status'],
            'followers_count' => $followersCount,
            'is_following' => $isFollowed,
            'has_pending_request' => $hasPendingRequest,
            'average_rating' => number_format($averageRating, 1, '.', ''),
            'review_count' => $reviewCount,
            'socials' => $target['socials'],
            'events' => $this->buildProfileEvents($target),
            'identity' => $this->catalogBridge->publicIdentity($identity),
        ];
    }

    public function buildDirectoryRecords(string $search = ''): Collection
    {
        $normalizedSearch = $this->normalizeSearch($search);
        $legacyArtists = Artist::query()
            ->where('status', 1)
            ->get(['id', 'name', 'username', 'photo', 'details', 'facebook', 'twitter', 'linkedin', 'status', 'created_at']);

        $legacyById = $legacyArtists->keyBy('id');
        $identities = Identity::query()
            ->where('type', 'artist')
            ->where('status', 'active')
            ->get();

        $usedLegacyIds = [];
        $records = collect();

        foreach ($identities as $identity) {
            $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, 'artist');
            $legacyArtist = $legacyId !== null ? $legacyById->get((int) $legacyId) : null;
            $target = $this->hydrateTarget($identity, $legacyArtist);

            if (!$target || !$this->targetMatchesSearch($target, $normalizedSearch)) {
                continue;
            }

            if ($legacyId !== null) {
                $usedLegacyIds[] = (int) $legacyId;
            }

            $records->push($this->buildDirectoryRecord($target));
        }

        foreach ($legacyArtists as $legacyArtist) {
            if (in_array((int) $legacyArtist->id, $usedLegacyIds, true)) {
                continue;
            }

            $target = $this->hydrateTarget(null, $legacyArtist);
            if (!$target || !$this->targetMatchesSearch($target, $normalizedSearch)) {
                continue;
            }

            $records->push($this->buildDirectoryRecord($target));
        }

        return $this->attachDirectoryMetrics($records);
    }

    public function buildUpcomingEvents(?int $languageId = null, int $limit = 12, string $search = ''): array
    {
        $rows = DB::table('event_artist')
            ->join('events', 'events.id', '=', 'event_artist.event_id')
            ->join('artists', 'artists.id', '=', 'event_artist.artist_id')
            ->leftJoin('event_contents', function ($join) use ($languageId) {
                $join->on('event_contents.event_id', '=', 'events.id');
                if ($languageId !== null) {
                    $join->where('event_contents.language_id', '=', $languageId);
                }
            })
            ->where('artists.status', 1)
            ->where('events.status', 1)
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($subQuery) use ($search) {
                    $subQuery->where('artists.name', 'like', '%' . $search . '%')
                        ->orWhere('artists.username', 'like', '%' . $search . '%')
                        ->orWhere('event_contents.title', 'like', '%' . $search . '%');
                });
            });

        $this->applyUpcomingConstraint($rows);

        $events = $rows
            ->orderBy('events.start_date')
            ->orderBy('events.end_date_time')
            ->limit($limit)
            ->get([
                'events.id',
                'events.thumbnail',
                'events.start_date',
                'events.end_date_time',
                'artists.id as artist_id',
                'event_contents.title',
            ]);

        return $events->map(function ($event) {
            $target = $this->resolveByPublicId($event->artist_id);
            if (!$target) {
                return null;
            }

            return [
                'id' => (int) $event->id,
                'title' => $event->title ?: ('Event #' . $event->id),
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'starts_at' => $this->isoDate($event->start_date),
                'ends_at' => $this->isoDate($event->end_date_time),
                'artist' => [
                    'id' => (int) ($target['legacy_id'] ?? $target['profile_id']),
                    'name' => $target['name'],
                    'identity' => $this->catalogBridge->publicIdentity($target['identity']),
                ],
            ];
        })->filter()->values()->all();
    }

    private function buildProfileEvents(array $target, int $limit = 10): array
    {
        if (empty($target['legacy_id'])) {
            return [];
        }

        $events = DB::table('event_artist')
            ->join('events', 'events.id', '=', 'event_artist.event_id')
            ->leftJoin('event_contents', 'event_contents.event_id', '=', 'events.id')
            ->where('event_artist.artist_id', $target['legacy_id'])
            ->where('events.status', 1)
            ->orderBy('events.start_date')
            ->limit($limit)
            ->get([
                'events.id',
                'events.thumbnail',
                'events.start_date',
                'events.end_date_time',
                'event_contents.title',
                'event_contents.slug',
                'event_contents.address',
            ]);

        return $events->map(function ($event) {
            return [
                'id' => (int) $event->id,
                'title' => $event->title ?: ('Event #' . $event->id),
                'slug' => $event->slug,
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'date' => $this->isoDate($event->start_date),
                'address' => $event->address,
                'is_past' => $this->timestampValue($event->end_date_time) !== 0
                    ? now()->greaterThan($event->end_date_time)
                    : false,
            ];
        })->values()->all();
    }

    private function buildDirectoryRecord(array $target): array
    {
        return [
            'id' => (int) ($target['legacy_id'] ?? $target['profile_id']),
            'profile_id' => (int) $target['profile_id'],
            'legacy_artist_id' => $target['legacy_id'],
            'identity_id' => $target['identity']?->id,
            'type' => 'artist',
            'name' => $target['name'],
            'username' => $target['username'],
            'photo' => $target['photo'],
            'details' => $target['details'],
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
        $legacyIds = $records->pluck('legacy_artist_id')
            ->filter(fn ($value) => $value !== null)
            ->map(fn ($value) => (int) $value)
            ->values();

        $followers = $this->acceptedFollowerCounts($legacyIds);
        $upcomingCounts = $this->artistEventCounts($legacyIds, true);
        $totalCounts = $this->artistEventCounts($legacyIds, false);
        $reviewStats = $this->publishedReviewStats($legacyIds);

        return $records->map(function (array $record) use ($followers, $upcomingCounts, $totalCounts, $reviewStats) {
            $legacyId = $record['legacy_artist_id'];
            $ratingMeta = $legacyId !== null
                ? ($reviewStats->get($legacyId, ['average_rating' => 0.0, 'review_count' => 0]))
                : ['average_rating' => 0.0, 'review_count' => 0];

            $record['followers_count'] = $legacyId !== null ? (int) ($followers[$legacyId] ?? 0) : 0;
            $record['upcoming_events_count'] = $legacyId !== null ? (int) ($upcomingCounts[$legacyId] ?? 0) : 0;
            $record['total_events_count'] = $legacyId !== null ? (int) ($totalCounts[$legacyId] ?? 0) : 0;
            $record['average_rating'] = (float) ($ratingMeta['average_rating'] ?? 0.0);
            $record['review_count'] = (int) ($ratingMeta['review_count'] ?? 0);

            return $record;
        })->values();
    }

    private function acceptedFollowerCounts(Collection $artistIds): Collection
    {
        if ($artistIds->isEmpty()) {
            return collect();
        }

        return DB::table('follows')
            ->where('followable_type', Artist::class)
            ->where('status', 'accepted')
            ->whereIn('followable_id', $artistIds->all())
            ->selectRaw('followable_id as target_id, COUNT(*) as aggregate')
            ->groupBy('followable_id')
            ->pluck('aggregate', 'target_id');
    }

    private function publishedReviewStats(Collection $artistIds): Collection
    {
        if ($artistIds->isEmpty() || !Schema::hasTable('reviews')) {
            return collect();
        }

        return DB::table('reviews')
            ->where('reviewable_type', Artist::class)
            ->where('status', 'published')
            ->whereIn('reviewable_id', $artistIds->all())
            ->selectRaw('reviewable_id as target_id, AVG(rating) as average_rating, COUNT(*) as review_count')
            ->groupBy('reviewable_id')
            ->get()
            ->keyBy('target_id')
            ->map(fn ($row) => [
                'average_rating' => round((float) ($row->average_rating ?? 0), 1),
                'review_count' => (int) ($row->review_count ?? 0),
            ]);
    }

    private function artistEventCounts(Collection $artistIds, bool $upcomingOnly): Collection
    {
        if ($artistIds->isEmpty()) {
            return collect();
        }

        $query = DB::table('event_artist')
            ->join('events', 'events.id', '=', 'event_artist.event_id')
            ->whereIn('event_artist.artist_id', $artistIds->all())
            ->where('events.status', 1);

        if ($upcomingOnly) {
            $this->applyUpcomingConstraint($query);
        }

        return $query
            ->selectRaw('event_artist.artist_id as target_id, COUNT(DISTINCT event_artist.event_id) as aggregate')
            ->groupBy('event_artist.artist_id')
            ->pluck('aggregate', 'target_id');
    }

    private function hydrateTarget(?Identity $identity = null, ?Artist $legacyArtist = null): ?array
    {
        if (!$identity && !$legacyArtist) {
            return null;
        }

        $legacyId = $legacyArtist?->id;
        if ($legacyId === null && $identity) {
            $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, 'artist');
            if ($legacyId !== null && !$legacyArtist) {
                $legacyArtist = Artist::query()->find($legacyId);
            }
        }

        $meta = is_array($identity?->meta) ? $identity->meta : [];
        $photo = PublicAssetUrl::url($legacyArtist?->photo ?? ($meta['photo'] ?? null), 'assets/admin/img/artist');
        $coverPhoto = PublicAssetUrl::url($meta['cover_photo'] ?? null, 'assets/admin/img/artist');

        return [
            'profile_id' => (int) ($legacyId ?? $identity?->id ?? 0),
            'legacy_id' => $legacyId !== null ? (int) $legacyId : null,
            'identity' => $identity,
            'legacy' => $legacyArtist,
            'name' => $identity?->display_name ?? $legacyArtist?->name ?? null,
            'username' => $legacyArtist?->username ?? ($meta['username'] ?? ($identity?->slug)),
            'details' => $legacyArtist?->details ?? ($meta['details'] ?? ($meta['bio'] ?? null)),
            'photo' => $photo,
            'cover_photo' => $coverPhoto,
            'genres' => collect($meta['genres'] ?? [])
                ->filter(fn ($genre) => filled($genre))
                ->map(fn ($genre) => trim((string) $genre))
                ->values()
                ->all(),
            'city' => $meta['city'] ?? null,
            'country' => $meta['country'] ?? null,
            'gallery' => collect($meta['gallery'] ?? [])
                ->filter(fn ($image) => filled($image))
                ->map(fn ($image) => PublicAssetUrl::url((string) $image, 'assets/admin/img/artist'))
                ->filter()
                ->values()
                ->all(),
            'booking_notes' => $meta['booking_notes'] ?? null,
            'status' => (int) ($legacyArtist?->status ?? ($identity?->status === 'active' ? 1 : 0)),
            'socials' => [
                'facebook' => $legacyArtist?->facebook ?? ($meta['facebook'] ?? null),
                'twitter' => $legacyArtist?->twitter ?? ($meta['twitter'] ?? null),
                'linkedin' => $legacyArtist?->linkedin ?? ($meta['linkedin'] ?? null),
                'instagram' => $meta['instagram'] ?? null,
                'tiktok' => $meta['tiktok'] ?? null,
                'spotify' => $meta['spotify'] ?? null,
                'youtube' => $meta['youtube'] ?? null,
                'soundcloud' => $meta['soundcloud'] ?? null,
            ],
            'created_at' => $legacyArtist?->created_at ?? $identity?->created_at,
        ];
    }

    private function targetMatchesSearch(array $target, string $search): bool
    {
        if ($search === '') {
            return true;
        }

        $haystack = mb_strtolower(implode(' ', array_filter([
            $target['name'] ?? null,
            $target['username'] ?? null,
            $target['details'] ?? null,
        ])));

        return str_contains($haystack, $search);
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
