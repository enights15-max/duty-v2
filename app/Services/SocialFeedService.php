<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Wishlist;
use App\Models\Follow;
use App\Models\Organizer;
use App\Models\Venue;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class SocialFeedService
{
    public function __construct(
        private readonly SocialVisibilityService $socialVisibilityService,
        private readonly OrganizerPublicProfileService $organizerPublicProfileService
    ) {
    }

    public function build(Customer $viewer, ?int $languageId = null, int $limit = 9): array
    {
        $acceptedFollows = $viewer->follows()
            ->where('status', 'accepted')
            ->get(['followable_id', 'followable_type']);

        $followedCustomerIds = $acceptedFollows
            ->where('followable_type', Customer::class)
            ->pluck('followable_id')
            ->map(static fn ($id) => (int) $id)
            ->unique()
            ->values();

        $followedOrganizerIds = $acceptedFollows
            ->where('followable_type', Organizer::class)
            ->pluck('followable_id')
            ->map(static fn ($id) => (int) $id)
            ->unique()
            ->values();

        $followedVenueIds = $acceptedFollows
            ->where('followable_type', Venue::class)
            ->pluck('followable_id')
            ->map(static fn ($id) => (int) $id)
            ->unique()
            ->values();

        $items = collect()
            ->concat($this->buildFollowedAttendanceItems($viewer, $followedCustomerIds))
            ->concat($this->buildFollowedInterestItems($viewer, $followedCustomerIds))
            ->concat($this->buildFollowedProfileItems($followedOrganizerIds, $followedVenueIds, $languageId));

        $deduped = collect();
        $seenEventIds = [];

        foreach ($items as $item) {
            $eventId = (int) ($item['event_id'] ?? 0);
            if ($eventId <= 0 || in_array($eventId, $seenEventIds, true)) {
                continue;
            }

            $seenEventIds[] = $eventId;
            $deduped->push($item);

            if ($deduped->count() >= $limit) {
                break;
            }
        }

        $pendingRequests = Follow::query()
            ->where('followable_id', $viewer->id)
            ->where('followable_type', Customer::class)
            ->where('status', 'pending')
            ->count();

        return [
            'items' => $deduped->values()->all(),
            'summary' => [
                'following_people_count' => $followedCustomerIds->count(),
                'following_profiles_count' => $followedOrganizerIds->count() + $followedVenueIds->count(),
                'pending_requests_count' => $pendingRequests,
            ],
        ];
    }

    private function buildFollowedAttendanceItems(Customer $viewer, Collection $followedCustomerIds): Collection
    {
        if ($followedCustomerIds->isEmpty()) {
            return collect();
        }

        $customers = Customer::query()
            ->whereIn('id', $followedCustomerIds->all())
            ->where('status', 1)
            ->get()
            ->keyBy('id');

        $bookings = Booking::query()
            ->with(['evnt.information'])
            ->whereIn('customer_id', $followedCustomerIds->all())
            ->where('paymentStatus', 'completed')
            ->whereHas('evnt', function ($query) {
                $query->where('status', 1)
                    ->where(function ($eventQuery) {
                        $eventQuery->whereNull('end_date_time')
                            ->orWhere('end_date_time', '>', now());
                    });
            })
            ->orderByDesc('created_at')
            ->get();

        return $this->groupEventItemsFromCustomerActivity(
            $bookings,
            $customers,
            $viewer,
            'upcoming',
            'followed_people_going'
        );
    }

    private function buildFollowedInterestItems(Customer $viewer, Collection $followedCustomerIds): Collection
    {
        if ($followedCustomerIds->isEmpty()) {
            return collect();
        }

        $customers = Customer::query()
            ->whereIn('id', $followedCustomerIds->all())
            ->where('status', 1)
            ->get()
            ->keyBy('id');

        $wishlists = Wishlist::query()
            ->with(['event.information'])
            ->whereIn('customer_id', $followedCustomerIds->all())
            ->whereHas('event', function ($query) {
                $query->where('status', 1)
                    ->where(function ($eventQuery) {
                        $eventQuery->whereNull('end_date_time')
                            ->orWhere('end_date_time', '>', now());
                    });
            })
            ->orderByDesc('created_at')
            ->get();

        return $this->groupEventItemsFromCustomerActivity(
            $wishlists,
            $customers,
            $viewer,
            'interested',
            'followed_people_interested'
        );
    }

    private function buildFollowedProfileItems(Collection $followedOrganizerIds, Collection $followedVenueIds, ?int $languageId): Collection
    {
        if ($followedOrganizerIds->isEmpty() && $followedVenueIds->isEmpty()) {
            return collect();
        }

        $organizerIdentityIds = $followedOrganizerIds
            ->map(function (int $legacyOrganizerId) use ($languageId) {
                $target = $this->organizerPublicProfileService->resolveByPublicId($legacyOrganizerId, $languageId);
                return $target['identity']?->id ?? null;
            })
            ->filter()
            ->values();

        $events = \DB::table('event_contents')
            ->join('events', 'events.id', '=', 'event_contents.event_id')
            ->where('events.status', 1)
            ->where(function ($query) {
                $query->whereNull('events.end_date_time')
                    ->orWhere('events.end_date_time', '>', now());
            })
            ->when($languageId !== null, function ($query) use ($languageId) {
                $query->where('event_contents.language_id', $languageId);
            })
            ->where(function ($query) use ($followedOrganizerIds, $organizerIdentityIds, $followedVenueIds) {
                if ($organizerIdentityIds->isNotEmpty()) {
                    $query->whereIn('events.owner_identity_id', $organizerIdentityIds->all())
                        ->orWhere(function ($fallback) use ($followedOrganizerIds) {
                            $fallback->whereNull('events.owner_identity_id')
                                ->whereIn('events.organizer_id', $followedOrganizerIds->all());
                        });
                } elseif ($followedOrganizerIds->isNotEmpty()) {
                    $query->whereIn('events.organizer_id', $followedOrganizerIds->all());
                }

                if ($followedVenueIds->isNotEmpty()) {
                    $query->orWhereIn('events.venue_id', $followedVenueIds->all());
                }
            })
            ->orderBy('events.start_date')
            ->limit(12)
            ->get([
                'events.id as event_id',
                'events.thumbnail',
                'events.start_date',
                'events.start_time',
                'event_contents.address',
                'events.event_type',
                'events.organizer_id',
                'events.owner_identity_id',
                'events.venue_id',
                'event_contents.title',
            ]);

        return $events->map(function ($event) use ($languageId, $followedVenueIds) {
            $reason = $followedVenueIds->contains((int) ($event->venue_id ?? 0))
                ? 'A place you follow is hosting this'
                : 'From profiles you follow';

            return [
                'event_id' => (int) $event->event_id,
                'title' => $event->title ?: ('Event #' . $event->event_id),
                'thumbnail' => $this->eventThumbnailUrl($event->thumbnail ?? null),
                'starts_at' => $event->start_date,
                'start_time' => $event->start_time,
                'organizer_name' => $this->organizerPublicProfileService->organizerNameForEvent(
                    $event->owner_identity_id ?? null,
                    $event->organizer_id ?? null,
                    $languageId
                ),
                'address' => $event->address,
                'event_type' => $event->event_type,
                'reason_type' => 'followed_profile_event',
                'reason_label' => $reason,
                'people' => [],
                'people_count' => 0,
            ];
        });
    }

    private function groupEventItemsFromCustomerActivity(
        Collection $rows,
        Collection $customers,
        Customer $viewer,
        string $visibilityKey,
        string $reasonType
    ): Collection {
        $grouped = [];

        foreach ($rows as $row) {
            $customerId = (int) ($row->customer_id ?? 0);
            $customer = $customers->get($customerId);
            if (!$customer) {
                continue;
            }

            if (!$this->socialVisibilityService->canViewActivity($viewer, $customer, $visibilityKey)) {
                continue;
            }

            $event = $row->evnt ?? $row->event ?? null;
            if (!$event instanceof Event) {
                continue;
            }

            $eventId = (int) $event->id;
            if (!isset($grouped[$eventId])) {
                $grouped[$eventId] = [
                    'event' => $event,
                    'people' => [],
                    'people_ids' => [],
                ];
            }

            if (in_array($customerId, $grouped[$eventId]['people_ids'], true)) {
                continue;
            }

            $grouped[$eventId]['people_ids'][] = $customerId;
            $grouped[$eventId]['people'][] = $this->personPayload($customer, $viewer);
        }

        return collect($grouped)
            ->map(function (array $group) use ($reasonType) {
                /** @var Event $event */
                $event = $group['event'];
                $people = array_slice($group['people'], 0, 4);

                return [
                    'event_id' => (int) $event->id,
                    'title' => $event->information?->title ?: ('Event #' . $event->id),
                    'thumbnail' => $this->eventThumbnailUrl($event->thumbnail),
                    'starts_at' => $event->start_date,
                    'start_time' => $event->start_time,
                    'organizer_name' => $this->organizerPublicProfileService->organizerNameForEvent(
                        $event->owner_identity_id,
                        $event->organizer_id
                    ),
                    'address' => $event->address,
                    'event_type' => $event->event_type,
                    'reason_type' => $reasonType,
                    'reason_label' => $this->reasonLabel($reasonType, $people),
                    'people' => $people,
                    'people_count' => count($group['people_ids']),
                ];
            })
            ->sortBy(function (array $item) {
                return Carbon::parse($item['starts_at'] ?? now())->timestamp;
            })
            ->values();
    }

    private function reasonLabel(string $reasonType, array $people): string
    {
        $count = count($people);
        $firstName = $people[0]['name'] ?? 'Someone';

        return match ($reasonType) {
            'followed_people_going' => $count === 1
                ? $firstName . ' is going'
                : $count . ' people you follow are going',
            'followed_people_interested' => $count === 1
                ? $firstName . ' is interested'
                : $count . ' people you follow are interested',
            default => 'From your network',
        };
    }

    private function personPayload(Customer $customer, Customer $viewer): array
    {
        return [
            'id' => (int) $customer->id,
            'name' => trim(($customer->fname ?? '') . ' ' . ($customer->lname ?? '')) ?: ($customer->username ?? ('User ' . $customer->id)),
            'username' => $customer->username,
            'photo' => $this->customerPhotoUrl($customer->photo),
            'is_following' => $viewer->isFollowing($customer),
        ];
    }

    private function customerPhotoUrl(?string $photo): ?string
    {
        if (!$photo) {
            return null;
        }

        if (filter_var($photo, FILTER_VALIDATE_URL)) {
            return $photo;
        }

        return asset('assets/admin/img/customer-profile/' . ltrim($photo, '/'));
    }

    private function eventThumbnailUrl(?string $thumbnail): ?string
    {
        if (!$thumbnail) {
            return null;
        }

        if (filter_var($thumbnail, FILTER_VALIDATE_URL)) {
            return $thumbnail;
        }

        return asset('assets/admin/img/event/thumbnail/' . ltrim($thumbnail, '/'));
    }
}
