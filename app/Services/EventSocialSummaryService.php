<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Wishlist;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class EventSocialSummaryService
{
    public function __construct(private SocialVisibilityService $socialVisibilityService)
    {
    }

    public function build(Event $event, ?Customer $viewer, int $limit = 12): array
    {
        $interestedCustomers = $this->resolveInterestedCustomers($event, $viewer, $limit);
        $attendingCustomers = $this->resolveAttendingCustomers($event, $viewer, $limit);
        $followedInterestedPeople = $viewer
            ? array_values(array_filter(
                $interestedCustomers,
                static fn (array $person): bool => ($person['is_following'] ?? false) === true
            ))
            : [];

        return [
            'interested_count' => (int) Wishlist::where('event_id', $event->id)->count(),
            'visible_interested_count' => count($interestedCustomers),
            'attending_count' => (int) Booking::query()
                ->where('event_id', $event->id)
                ->where('paymentStatus', 'completed')
                ->distinct()
                ->count('customer_id'),
            'visible_attending_count' => count($attendingCustomers),
            'interested_people' => $interestedCustomers,
            'followed_interested_people' => array_slice($followedInterestedPeople, 0, 6),
            'attending_people' => $attendingCustomers,
        ];
    }

    private function resolveInterestedCustomers(Event $event, ?Customer $viewer, int $limit): array
    {
        $customerIds = Wishlist::query()
            ->where('event_id', $event->id)
            ->orderByDesc('created_at')
            ->pluck('customer_id')
            ->filter()
            ->unique()
            ->values();

        return $this->filterVisibleCustomers($customerIds, $viewer, 'interested', $limit);
    }

    private function resolveAttendingCustomers(Event $event, ?Customer $viewer, int $limit): array
    {
        if ($event->end_date_time && Carbon::parse($event->end_date_time)->isPast()) {
            return [];
        }

        $customerIds = Booking::query()
            ->where('event_id', $event->id)
            ->where('paymentStatus', 'completed')
            ->orderByDesc('created_at')
            ->pluck('customer_id')
            ->filter()
            ->unique()
            ->values();

        return $this->filterVisibleCustomers($customerIds, $viewer, 'upcoming', $limit);
    }

    private function filterVisibleCustomers(Collection $customerIds, ?Customer $viewer, string $activity, int $limit): array
    {
        if ($customerIds->isEmpty()) {
            return [];
        }

        $customers = Customer::query()
            ->whereIn('id', $customerIds->all())
            ->where('status', 1)
            ->get()
            ->keyBy('id');

        $people = [];

        foreach ($customerIds as $customerId) {
            $customer = $customers->get($customerId);
            if (!$customer) {
                continue;
            }

            if (!$this->socialVisibilityService->canViewActivity($viewer, $customer, $activity)) {
                continue;
            }

            $people[] = $this->personPayload($customer, $viewer);

            if (count($people) >= $limit) {
                break;
            }
        }

        return $people;
    }

    private function personPayload(Customer $customer, ?Customer $viewer): array
    {
        return [
            'id' => $customer->id,
            'name' => trim(($customer->fname ?? '') . ' ' . ($customer->lname ?? '')) ?: ($customer->username ?? ('User ' . $customer->id)),
            'username' => $customer->username,
            'photo' => $this->photoUrl($customer->photo),
            'is_following' => $viewer ? $viewer->isFollowing($customer) : false,
        ];
    }

    private function photoUrl(?string $photo): ?string
    {
        if (!$photo) {
            return null;
        }

        if (filter_var($photo, FILTER_VALIDATE_URL)) {
            return $photo;
        }

        return asset('assets/admin/img/customer-profile/' . $photo);
    }
}
