<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\EventContent;
use App\Models\Identity;
use App\Models\IdentityBalanceTransaction;
use App\Models\Language;
use App\Models\Organizer;
use App\Models\Review;
use App\Models\Venue;
use App\Services\EventInventorySummaryService;
use App\Services\EventCollaboratorSplitService;
use App\Services\ProfessionalBalanceService;
use App\Services\ProfessionalCatalogBridgeService;
use App\Traits\HasIdentityActor;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfessionalDashboardController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge,
        private ProfessionalBalanceService $professionalBalanceService,
        private EventInventorySummaryService $eventInventorySummaryService,
        private EventCollaboratorSplitService $collaboratorSplitService
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active professional identity is required.',
            ], 403);
        }

        $legacyId = $this->resolveLegacyId($identity);
        $range = $this->normalizeRange((string) $request->query('range', 'all'));
        $window = $this->rangeWindow($range);
        $eventsQuery = $this->eventsQueryForIdentity($identity, $legacyId);
        $managedEvents = (clone $eventsQuery)->get();
        $inventorySummaries = $this->eventInventorySummaryService->summarizeMany($managedEvents);
        $inventoryOverview = $this->eventInventorySummaryService->aggregate($managedEvents);

        $eventCount = $this->eventCountForIdentity($identity, $legacyId, $window);
        $sales = $this->salesSummaryForIdentity($identity, $legacyId, $window);
        $rating = $this->ratingForIdentity($identity, $legacyId, $window);
        $balance = $this->balanceForIdentity($identity, $legacyId);
        $ledger = $this->ledgerSummaryForIdentity($identity, $window);
        $collaborations = $this->collaboratorSplitService->identitySummary($identity);
        $comparisons = $this->comparisonsForIdentity($identity, $legacyId, $window);

        $upcomingEventsQuery = (clone $eventsQuery)
                ->where(function (Builder $query): void {
                    $query->where(function (Builder $single): void {
                        $single->where('date_type', 'single')
                            ->whereDate('start_date', '>=', Carbon::today()->toDateString());
                    })->orWhere(function (Builder $multiple): void {
                        $multiple->where('date_type', 'multiple')
                            ->where('end_date_time', '>=', Carbon::now());
                    });
                })
                ->orderByRaw('CASE WHEN start_date IS NULL THEN 1 ELSE 0 END')
                ->orderBy('start_date')
                ->orderBy('start_time')
                ->limit(5)
                ->get();

        $upcomingEvents = $this->serializeUpcomingEvents(
            $upcomingEventsQuery,
            $inventorySummaries
        );

        $inventoryWatch = $this->serializeInventoryWatch(
            $managedEvents,
            $inventorySummaries
        );

        return response()->json([
            'status' => 'success',
            'data' => [
                'profile_type' => $identity->type,
                'range' => $range,
                'stats' => [
                    'balance' => $balance,
                    'event_count' => $eventCount,
                    'ticket_sales' => $sales['ticket_sales'],
                    'average_rating' => $rating['average'],
                    'review_count' => $rating['count'],
                    'gross_sales' => $sales['gross_sales'],
                    'net_sales' => $sales['net_sales'],
                    'ledger_inflow' => $ledger['inflow'],
                    'ledger_outflow' => $ledger['outflow'],
                    'ledger_entries' => $ledger['entries'],
                    'tickets_available' => $inventoryOverview['tickets_available'],
                    'sell_through_percent' => $inventoryOverview['sell_through_percent'],
                    'sold_out_events' => $inventoryOverview['sold_out_events'],
                    'low_stock_events' => $inventoryOverview['low_stock_events'],
                    'marketplace_fallback_events' => $inventoryOverview['marketplace_fallback_events'],
                ],
                'comparisons' => $comparisons,
                'upcoming_events' => $upcomingEvents,
                'inventory_watch' => $inventoryWatch,
                'collaboration_summary' => $collaborations,
            ],
        ]);
    }

    private function eventsQueryForIdentity(Identity $identity, ?int $legacyId): Builder
    {
        $query = Event::query()
            ->with(['venue', 'information', 'dates'])
            ->with(['lineups.artist']);

        return match ($identity->type) {
            'organizer' => $query->ownedByOrganizerActor((int) $identity->id, $legacyId),
            'venue' => $query->ownedByVenueActor((int) $identity->id, $legacyId),
            'artist' => $query->where(function (Builder $artistEvents) use ($legacyId): void {
                $artistEvents->whereHas('lineups', function (Builder $lineups) use ($legacyId): void {
                    $lineups->where('artist_id', $legacyId);
                })->orWhereHas('artists', function (Builder $artists) use ($legacyId): void {
                    $artists->where('artists.id', $legacyId);
                });
            })->distinct('events.id'),
            default => $query->whereRaw('1 = 0'),
        };
    }

    private function eventCountForIdentity(Identity $identity, ?int $legacyId, array $window): int
    {
        $query = $this->applyEventWindowFilter(
            $this->eventsQueryForIdentity($identity, $legacyId),
            $window['current_start'],
            $window['current_end']
        );

        return (clone $query)->count();
    }

    private function salesBaseQueryForIdentity(Identity $identity, ?int $legacyId): Builder
    {
        $base = Booking::query()->where('paymentStatus', 'Completed');

        return match ($identity->type) {
            'organizer' => $base->ownedByOrganizerActor((int) $identity->id, $legacyId),
            'venue' => $base->whereHas('evnt', function (Builder $events) use ($identity, $legacyId): void {
                $events->ownedByVenueActor((int) $identity->id, $legacyId);
            }),
            'artist' => $base->whereHas('evnt', function (Builder $events) use ($legacyId): void {
                $events->where(function (Builder $artistEvents) use ($legacyId): void {
                    $artistEvents->whereHas('lineups', function (Builder $lineups) use ($legacyId): void {
                        $lineups->where('artist_id', $legacyId);
                    })->orWhereHas('artists', function (Builder $artists) use ($legacyId): void {
                        $artists->where('artists.id', $legacyId);
                    });
                });
            }),
            default => $base->whereRaw('1 = 0'),
        };
    }

    private function salesSummaryForIdentity(Identity $identity, ?int $legacyId, array $window): array
    {
        $query = $this->applyCreatedAtWindowFilter(
            $this->salesBaseQueryForIdentity($identity, $legacyId),
            $window['current_start'],
            $window['current_end']
        );

        $rows = (clone $query)->get(['price', 'commission', 'quantity']);

        return [
            'ticket_sales' => (int) $rows->sum(fn ($row) => (int) ($row->quantity ?? 0)),
            'gross_sales' => round((float) $rows->sum(fn ($row) => (float) ($row->price ?? 0)), 2),
            'net_sales' => round((float) $rows->sum(fn ($row) => (float) ($row->price ?? 0) - (float) ($row->commission ?? 0)), 2),
        ];
    }

    private function balanceForIdentity(Identity $identity, ?int $legacyId): float
    {
        return match ($identity->type) {
            'organizer' => $this->professionalBalanceService->currentOrganizerBalance((int) $identity->id, $legacyId),
            'artist' => $this->professionalBalanceService->currentArtistBalance((int) $identity->id, $legacyId),
            'venue' => $this->professionalBalanceService->currentVenueBalance((int) $identity->id, $legacyId),
            default => 0.0,
        };
    }

    private function ratingForIdentity(Identity $identity, ?int $legacyId, array $window): array
    {
        if (!$legacyId) {
            return ['average' => '0.0', 'count' => 0];
        }

        $reviewableType = match ($identity->type) {
            'organizer' => Organizer::class,
            'artist' => Artist::class,
            'venue' => Venue::class,
            default => null,
        };

        if (!$reviewableType) {
            return ['average' => '0.0', 'count' => 0];
        }

        $query = Review::query()
            ->where('reviewable_type', $reviewableType)
            ->where('reviewable_id', $legacyId)
            ->where('status', 'published');

        $query = $this->applyReviewWindowFilter(
            $query,
            $window['current_start'],
            $window['current_end']
        );

        $average = round((float) ($query->avg('rating') ?? 0), 1);

        return [
            'average' => number_format($average, 1, '.', ''),
            'count' => (clone $query)->count(),
        ];
    }

    private function ledgerSummaryForIdentity(Identity $identity, array $window): array
    {
        $query = IdentityBalanceTransaction::query()
            ->where('identity_id', (int) $identity->id);

        $query = $this->applyCreatedAtWindowFilter(
            $query,
            $window['current_start'],
            $window['current_end']
        );

        $rows = (clone $query)->get(['type', 'amount']);

        return [
            'entries' => $rows->count(),
            'inflow' => round((float) $rows->filter(fn ($row) => ($row->type ?? '') === 'credit')->sum('amount'), 2),
            'outflow' => round((float) $rows->filter(fn ($row) => ($row->type ?? '') === 'debit')->sum('amount'), 2),
        ];
    }

    private function comparisonsForIdentity(Identity $identity, ?int $legacyId, array $window): array
    {
        $currentSales = $this->salesSummaryForIdentity($identity, $legacyId, $window);
        $currentRating = $this->ratingForIdentity($identity, $legacyId, $window);

        if (!$window['previous_start'] || !$window['previous_end']) {
            return [
                'event_count' => $this->comparisonPayload($this->eventCountForIdentity($identity, $legacyId, $window), null),
                'ticket_sales' => $this->comparisonPayload($currentSales['ticket_sales'], null),
                'gross_sales' => $this->comparisonPayload($currentSales['gross_sales'], null),
                'net_sales' => $this->comparisonPayload($currentSales['net_sales'], null),
                'review_count' => $this->comparisonPayload($currentRating['count'], null),
            ];
        }

        $previousWindow = [
            'current_start' => $window['previous_start'],
            'current_end' => $window['previous_end'],
            'previous_start' => null,
            'previous_end' => null,
        ];

        $previousSales = $this->salesSummaryForIdentity($identity, $legacyId, $previousWindow);
        $previousRating = $this->ratingForIdentity($identity, $legacyId, $previousWindow);

        return [
            'event_count' => $this->comparisonPayload(
                $this->eventCountForIdentity($identity, $legacyId, $window),
                $this->eventCountForIdentity($identity, $legacyId, $previousWindow)
            ),
            'ticket_sales' => $this->comparisonPayload($currentSales['ticket_sales'], $previousSales['ticket_sales']),
            'gross_sales' => $this->comparisonPayload($currentSales['gross_sales'], $previousSales['gross_sales']),
            'net_sales' => $this->comparisonPayload($currentSales['net_sales'], $previousSales['net_sales']),
            'review_count' => $this->comparisonPayload($currentRating['count'], $previousRating['count']),
        ];
    }

    private function comparisonPayload(int|float $current, int|float|null $previous): array
    {
        if ($previous === null) {
            return [
                'current' => $current,
                'previous' => null,
                'delta' => null,
                'delta_percent' => null,
            ];
        }

        $delta = round((float) $current - (float) $previous, 2);
        $deltaPercent = (float) $previous === 0.0
            ? null
            : round(($delta / (float) $previous) * 100, 1);

        return [
            'current' => $current,
            'previous' => $previous,
            'delta' => $delta,
            'delta_percent' => $deltaPercent,
        ];
    }

    private function normalizeRange(string $range): string
    {
        return in_array($range, ['7d', '30d', 'all'], true) ? $range : 'all';
    }

    private function rangeWindow(string $range): array
    {
        if ($range === 'all') {
            return [
                'current_start' => null,
                'current_end' => null,
                'previous_start' => null,
                'previous_end' => null,
            ];
        }

        $days = $range === '7d' ? 7 : 30;
        $currentEnd = Carbon::now()->endOfDay();
        $currentStart = Carbon::now()->subDays($days - 1)->startOfDay();
        $previousEnd = (clone $currentStart)->subSecond();
        $previousStart = (clone $currentStart)->subDays($days)->startOfDay();

        return [
            'current_start' => $currentStart,
            'current_end' => $currentEnd,
            'previous_start' => $previousStart,
            'previous_end' => $previousEnd,
        ];
    }

    private function applyCreatedAtWindowFilter(Builder $query, ?Carbon $start, ?Carbon $end): Builder
    {
        if (!$start || !$end) {
            return $query;
        }

        return $query->whereBetween('created_at', [$start, $end]);
    }

    private function applyReviewWindowFilter(Builder $query, ?Carbon $start, ?Carbon $end): Builder
    {
        if (!$start || !$end) {
            return $query;
        }

        return $query->where(function (Builder $builder) use ($start, $end): void {
            $builder->whereBetween('submitted_at', [$start, $end])
                ->orWhere(function (Builder $fallback) use ($start, $end): void {
                    $fallback->whereNull('submitted_at')
                        ->whereBetween('created_at', [$start, $end]);
                });
        });
    }

    private function applyEventWindowFilter(Builder $query, ?Carbon $start, ?Carbon $end): Builder
    {
        if (!$start || !$end) {
            return $query;
        }

        return $query->where(function (Builder $builder) use ($start, $end): void {
            $builder->where(function (Builder $single) use ($start, $end): void {
                $single->where('date_type', 'single')
                    ->whereBetween('start_date', [$start->toDateString(), $end->toDateString()]);
            })->orWhere(function (Builder $multiple) use ($start, $end): void {
                $multiple->where('date_type', 'multiple')
                    ->whereDate('start_date', '<=', $end->toDateString())
                    ->where('end_date_time', '>=', $start);
            });
        });
    }

    private function resolveLegacyId(Identity $identity): ?int
    {
        $legacyId = $this->catalogBridge->legacyIdForIdentity($identity, $identity->type);
        return is_numeric($legacyId) ? (int) $legacyId : null;
    }

    private function serializeUpcomingEvents($events, array $inventorySummaries = []): array
    {
        $defaultLanguageId = (int) (Language::query()->where('is_default', 1)->value('id')
            ?? Language::query()->min('id')
            ?? 1);

        return $events->map(function (Event $event) use ($defaultLanguageId, $inventorySummaries): array {
            $content = EventContent::query()
                ->where('event_id', $event->id)
                ->where('language_id', $defaultLanguageId)
                ->first()
                ?: $event->information;

            $inventory = $inventorySummaries[(int) $event->id] ?? [];

            return [
                'id' => $event->id,
                'title' => $content?->title ?: 'Untitled event',
                'event_type' => $event->event_type,
                'date_type' => $event->date_type,
                'status' => (int) $event->status,
                'start_date' => $event->start_date,
                'start_time' => $event->start_time,
                'end_date' => $event->end_date,
                'end_time' => $event->end_time,
                'thumbnail_url' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'venue_summary' => [
                    'name' => $event->venue_name_snapshot ?: $event->venue?->name,
                    'city' => $event->venue_city_snapshot ?: $event->venue?->city,
                ],
                'inventory' => $inventory,
            ];
        })->values()->all();
    }

    private function serializeInventoryWatch($events, array $inventorySummaries): array
    {
        $rankedEvents = $events
            ->map(function (Event $event) use ($inventorySummaries) {
                $summary = $inventorySummaries[(int) $event->id] ?? [];
                $state = $summary['availability_state'] ?? 'available';

                $priority = match ($state) {
                    'sold_out_marketplace', 'sold_out' => 0,
                    'low_stock' => 1,
                    default => 2,
                };

                return [
                    'event' => $event,
                    'priority' => $priority,
                    'summary' => $summary,
                ];
            })
            ->sort(function (array $left, array $right) {
                if ($left['priority'] !== $right['priority']) {
                    return $left['priority'] <=> $right['priority'];
                }

                $leftDate = $left['event']->start_date ? strtotime((string) $left['event']->start_date) : PHP_INT_MAX;
                $rightDate = $right['event']->start_date ? strtotime((string) $right['event']->start_date) : PHP_INT_MAX;

                return $leftDate <=> $rightDate;
            })
            ->take(5)
            ->pluck('event');

        return $this->serializeUpcomingEvents($rankedEvents, $inventorySummaries);
    }
}
