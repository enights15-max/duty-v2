<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ArtistPublicProfileService;
use App\Services\OrganizerPublicProfileService;
use App\Services\ProfessionalCatalogBridgeService;
use App\Services\VenuePublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class DiscoverController extends Controller
{
    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge,
        private OrganizerPublicProfileService $organizerPublicProfileService,
        private ArtistPublicProfileService $artistPublicProfileService,
        private VenuePublicProfileService $venuePublicProfileService
    )
    {
    }

    public function artists(Request $request)
    {
        $limit = $this->resolveLimit($request);
        $search = trim((string) $request->input('q', ''));
        $languageId = $this->resolveLanguageId($request);

        $directory = $this->artistPublicProfileService->buildDirectoryRecords($search);

        return response()->json([
            'success' => true,
            'data' => [
                'query' => $search,
                'popular' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['followers_count', 'desc'],
                    ['upcoming_events_count', 'desc'],
                    ['_created_sort', 'desc'],
                ])->take($limit)),
                'top_rated' => $this->withoutSortMeta($this->sortDirectory(
                    $directory->filter(fn (array $record) => (int) ($record['review_count'] ?? 0) > 0),
                    [
                        ['average_rating', 'desc'],
                        ['review_count', 'desc'],
                        ['followers_count', 'desc'],
                        ['upcoming_events_count', 'desc'],
                    ]
                )->take($limit)),
                'new' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['_created_sort', 'desc'],
                    ['followers_count', 'desc'],
                ])->take($limit)),
                'upcoming_events' => $this->artistPublicProfileService->buildUpcomingEvents($languageId, $limit, $search),
            ],
        ]);
    }

    public function organizers(Request $request)
    {
        $limit = $this->resolveLimit($request);
        $search = trim((string) $request->input('q', ''));
        $languageId = $this->resolveLanguageId($request);
        $directory = $this->organizerPublicProfileService->buildDirectoryRecords($languageId, $search);

        return response()->json([
            'success' => true,
            'data' => [
                'query' => $search,
                'popular' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['followers_count', 'desc'],
                    ['upcoming_events_count', 'desc'],
                    ['_created_sort', 'desc'],
                ])->take($limit)),
                'top_rated' => $this->withoutSortMeta($this->sortDirectory(
                    $directory->filter(fn (array $record) => (int) ($record['review_count'] ?? 0) > 0),
                    [
                        ['average_rating', 'desc'],
                        ['review_count', 'desc'],
                        ['followers_count', 'desc'],
                        ['upcoming_events_count', 'desc'],
                    ]
                )->take($limit)),
                'active' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['upcoming_events_count', 'desc'],
                    ['total_events_count', 'desc'],
                    ['followers_count', 'desc'],
                ])->take($limit)),
                'upcoming_events' => $this->organizerPublicProfileService->buildUpcomingEvents($languageId, $limit, $search),
            ],
        ]);
    }

    public function venues(Request $request)
    {
        $limit = $this->resolveLimit($request);
        $search = trim((string) $request->input('q', ''));
        $languageId = $this->resolveLanguageId($request);

        $directory = $this->venuePublicProfileService->buildDirectoryRecords($search);

        return response()->json([
            'success' => true,
            'data' => [
                'query' => $search,
                'recommended' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['upcoming_events_count', 'desc'],
                    ['followers_count', 'desc'],
                    ['_created_sort', 'desc'],
                ])->take($limit)),
                'top_rated' => $this->withoutSortMeta($this->sortDirectory(
                    $directory->filter(fn (array $record) => (int) ($record['review_count'] ?? 0) > 0),
                    [
                        ['average_rating', 'desc'],
                        ['review_count', 'desc'],
                        ['followers_count', 'desc'],
                        ['upcoming_events_count', 'desc'],
                    ]
                )->take($limit)),
                'new' => $this->withoutSortMeta($this->sortDirectory($directory, [
                    ['_created_sort', 'desc'],
                    ['upcoming_events_count', 'desc'],
                ])->take($limit)),
                'upcoming_events' => $this->venuePublicProfileService->buildUpcomingEvents($languageId, $limit, $search),
            ],
        ]);
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

    private function resolveLanguageId(Request $request): ?int
    {
        $locale = trim((string) $request->header('Accept-Language', ''));
        if ($locale !== '') {
            $languageId = DB::table('languages')->where('code', $locale)->value('id');
            if ($languageId !== null) {
                return (int) $languageId;
            }
        }

        $defaultLanguageId = DB::table('languages')->where('is_default', 1)->value('id');
        if ($defaultLanguageId !== null) {
            return (int) $defaultLanguageId;
        }

        $firstLanguageId = DB::table('languages')->orderBy('id')->value('id');

        return $firstLanguageId !== null ? (int) $firstLanguageId : null;
    }

    private function resolveLimit(Request $request, int $default = 12, int $max = 24): int
    {
        $limit = (int) $request->input('limit', $default);

        return max(1, min($limit, $max));
    }

    private function sortDirectory(Collection $records, array $rules): Collection
    {
        return $records
            ->sort(function (array $left, array $right) use ($rules) {
                foreach ($rules as [$key, $direction]) {
                    $result = ($left[$key] ?? 0) <=> ($right[$key] ?? 0);
                    if ($result === 0) {
                        continue;
                    }

                    return $direction === 'desc' ? -$result : $result;
                }

                return 0;
            })
            ->values();
    }

    private function withoutSortMeta(Collection $records): array
    {
        return $records->map(function (array $record) {
            unset($record['_created_sort']);

            return $record;
        })->values()->all();
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

}
