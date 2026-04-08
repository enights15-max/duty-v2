<?php

namespace App\Services;

use App\Exceptions\ReviewFlowException;
use App\Models\Artist;
use App\Models\Customer;
use App\Models\Event\Booking;
use App\Models\Event\EventLineup;
use App\Models\Event;
use App\Models\Organizer;
use App\Models\Review;
use App\Services\ProfessionalCatalogBridgeService;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Schema;

class ReviewService
{
    public function __construct(
        protected ReviewModerationService $moderationService,
        protected LoyaltyService $loyaltyService,
        protected ProfessionalCatalogBridgeService $catalogBridge
    )
    {
    }

    public function pendingFor(Customer $customer): array
    {
        if (!Schema::hasTable('reviews')) {
            return [];
        }

        $bookings = Booking::query()
            ->with(['evnt.organizer', 'evnt.lineups.artist'])
            ->where('customer_id', $customer->id)
            ->where('paymentStatus', 'Completed')
            ->orderByDesc('id')
            ->get()
            ->filter(fn (Booking $booking) => $booking->evnt && $this->eventHasConcluded($booking->evnt))
            ->unique('event_id')
            ->values();

        return $bookings
            ->map(function (Booking $booking) use ($customer) {
                $event = $booking->evnt;
                $targets = collect();

                if (!$this->hasExistingReview($customer->id, $event->id, Event::class, $event->id)) {
                    $targets->push([
                        'target_type' => 'event',
                        'target_id' => (int) $event->id,
                        'title' => 'Califica el evento',
                        'display_name' => $this->eventTitle($event),
                        'image' => $event->thumbnail,
                    ]);
                }

                $organizerLegacyId = $this->resolveOrganizerLegacyIdForBooking($booking);
                if ($organizerLegacyId !== null && !$this->hasExistingReview($customer->id, $event->id, Organizer::class, $organizerLegacyId)) {
                    $organizer = Organizer::find($organizerLegacyId) ?? $event->organizer;
                    $targets->push([
                        'target_type' => 'organizer',
                        'target_id' => $organizerLegacyId,
                        'title' => 'Califica al organizador',
                        'display_name' => $organizer?->organizer_name ?: 'Organizer',
                        'image' => $organizer?->photo,
                    ]);
                }

                foreach ($event->lineups->whereNotNull('artist_id')->unique('artist_id') as $lineup) {
                    $artistId = (int) $lineup->artist_id;
                    if ($artistId <= 0 || $this->hasExistingReview($customer->id, $event->id, Artist::class, $artistId)) {
                        continue;
                    }

                    $targets->push([
                        'target_type' => 'artist',
                        'target_id' => $artistId,
                        'title' => 'Califica al artista',
                        'display_name' => $lineup->artist?->name ?: $lineup->display_name,
                        'image' => $lineup->artist?->photo,
                    ]);
                }

                if ($targets->isEmpty()) {
                    return null;
                }

                return [
                    'event_id' => (int) $event->id,
                    'booking_id' => (int) $booking->id,
                    'event_title' => $this->eventTitle($event),
                    'event_thumbnail' => $event->thumbnail,
                    'event_end_at' => optional($this->eventEndAt($event))->toIso8601String(),
                    'targets' => $targets->values()->all(),
                ];
            })
            ->filter()
            ->values()
            ->all();
    }

    public function submit(Customer $customer, array $payload): Review
    {
        if (!Schema::hasTable('reviews')) {
            throw new ReviewFlowException('Reviews are not available yet.', 503);
        }

        $targetType = (string) ($payload['target_type'] ?? '');
        $targetId = (int) ($payload['target_id'] ?? 0);
        $eventId = isset($payload['event_id']) ? (int) $payload['event_id'] : null;

        [$reviewableType, $reviewable] = $this->resolveReviewable($targetType, $targetId);
        $booking = $this->resolveEligibleBooking($customer, $reviewableType, $targetId, $eventId);

        $moderation = $this->moderationService->evaluate($payload['comment'] ?? null);

        $review = Review::updateOrCreate(
            [
                'customer_id' => $customer->id,
                'event_id' => $booking->event_id,
                'reviewable_type' => $reviewableType,
                'reviewable_id' => $targetId,
            ],
            [
                'booking_id' => $booking->id,
                'rating' => (int) $payload['rating'],
                'comment' => filled($payload['comment'] ?? null) ? trim((string) $payload['comment']) : null,
                'status' => $moderation['status'],
                'meta' => array_merge(
                    $moderation['meta'] ?? [],
                    [
                        'target_type' => $targetType,
                        'event_snapshot' => [
                            'id' => (int) $booking->event_id,
                            'title' => $booking->evnt ? $this->eventTitle($booking->evnt) : 'Event',
                            'image' => $booking->evnt?->thumbnail,
                        ],
                        'target_snapshot' => $this->snapshotFor($reviewableType, $reviewable),
                    ]
                ),
                'submitted_at' => now(),
            ]
        );

        if ($review->status === 'published') {
            $this->loyaltyService->awardFromRule(
                $customer,
                'published_review',
                'review',
                (string) $review->id,
                [
                    'event_id' => (int) $booking->event_id,
                    'target_type' => $targetType,
                    'target_id' => $targetId,
                ]
            );
        }

        return $review;
    }

    public function publishedTargetReviews(string $reviewableType, int $reviewableId, int $limit = 10): Collection
    {
        if (!Schema::hasTable('reviews')) {
            return collect();
        }

        return Review::query()
            ->with(['customer:id,fname,lname,photo'])
            ->where('reviewable_type', $reviewableType)
            ->where('reviewable_id', $reviewableId)
            ->where('status', 'published')
            ->latest()
            ->limit($limit)
            ->get();
    }

    public function publishedTargetStats(string $reviewableType, int $reviewableId): array
    {
        if (!Schema::hasTable('reviews')) {
            return ['average' => '0.0', 'count' => 0];
        }

        $query = Review::query()
            ->where('reviewable_type', $reviewableType)
            ->where('reviewable_id', $reviewableId)
            ->where('status', 'published');

        $average = round((float) ($query->avg('rating') ?? 0), 1);

        return [
            'average' => number_format($average, 1, '.', ''),
            'count' => (clone $query)->count(),
        ];
    }

    private function resolveReviewable(string $targetType, int $targetId): array
    {
        $map = [
            'event' => Event::class,
            'organizer' => Organizer::class,
            'artist' => Artist::class,
        ];

        $reviewableType = $map[$targetType] ?? null;
        if (!$reviewableType) {
            throw new ReviewFlowException('Unsupported review target.', 422);
        }

        $reviewable = $reviewableType::find($targetId);
        if (!$reviewable) {
            throw new ReviewFlowException('Review target not found.', 404);
        }

        return [$reviewableType, $reviewable];
    }

    private function resolveEligibleBooking(Customer $customer, string $reviewableType, int $targetId, ?int $eventId): Booking
    {
        $candidate = match ($reviewableType) {
            Event::class => $this->eligibleEventBooking($customer, $targetId),
            Organizer::class => $this->eligibleOrganizerBooking($customer, $targetId, $eventId),
            Artist::class => $this->eligibleArtistBooking($customer, $targetId, $eventId),
            default => null,
        };

        if (!$candidate) {
            throw new ReviewFlowException(
                'You can only review completed events you attended.',
                403
            );
        }

        return $candidate;
    }

    private function eligibleEventBooking(Customer $customer, int $eventId): ?Booking
    {
        return Booking::query()
            ->with('evnt')
            ->where('customer_id', $customer->id)
            ->where('event_id', $eventId)
            ->where('paymentStatus', 'Completed')
            ->orderByDesc('id')
            ->get()
            ->first(fn (Booking $booking) => $booking->evnt && $this->eventHasConcluded($booking->evnt));
    }

    private function eligibleOrganizerBooking(Customer $customer, int $organizerId, ?int $eventId): ?Booking
    {
        return Booking::query()
            ->with('evnt')
            ->where('customer_id', $customer->id)
            ->when($eventId, fn ($query) => $query->where('event_id', $eventId))
            ->where('paymentStatus', 'Completed')
            ->orderByDesc('id')
            ->get()
            ->first(function (Booking $booking) use ($organizerId) {
                return $booking->evnt
                    && $this->eventHasConcluded($booking->evnt)
                    && $this->resolveOrganizerLegacyIdForBooking($booking) === $organizerId;
            });
    }

    private function eligibleArtistBooking(Customer $customer, int $artistId, ?int $eventId): ?Booking
    {
        return Booking::query()
            ->with(['evnt.lineups' => fn ($query) => $query->select('id', 'event_id', 'artist_id', 'display_name')])
            ->where('customer_id', $customer->id)
            ->when($eventId, fn ($query) => $query->where('event_id', $eventId))
            ->where('paymentStatus', 'Completed')
            ->orderByDesc('id')
            ->get()
            ->first(function (Booking $booking) use ($artistId) {
                return $booking->evnt
                    && $this->eventHasConcluded($booking->evnt)
                    && $booking->evnt->lineups->contains(fn (EventLineup $lineup) => (int) $lineup->artist_id === $artistId);
            });
    }

    private function hasExistingReview(int $customerId, int $eventId, string $reviewableType, int $reviewableId): bool
    {
        return Review::query()
            ->where('customer_id', $customerId)
            ->where('event_id', $eventId)
            ->where('reviewable_type', $reviewableType)
            ->where('reviewable_id', $reviewableId)
            ->exists();
    }

    private function eventHasConcluded(Event $event): bool
    {
        $endAt = $this->eventEndAt($event);
        return $endAt !== null && $endAt->isPast();
    }

    private function eventEndAt(Event $event): ?Carbon
    {
        if (!empty($event->end_date_time)) {
            return Carbon::parse($event->end_date_time);
        }

        if (!empty($event->end_date) && !empty($event->end_time)) {
            return Carbon::parse($event->end_date . ' ' . $event->end_time);
        }

        if (!empty($event->start_date) && !empty($event->start_time)) {
            return Carbon::parse($event->start_date . ' ' . $event->start_time);
        }

        return null;
    }

    private function eventTitle(Event $event): string
    {
        return $event->information?->title
            ?? optional($event->information()->first())->title
            ?? 'Event';
    }

    private function snapshotFor(string $reviewableType, mixed $reviewable): array
    {
        return match ($reviewableType) {
            Event::class => [
                'name' => $this->eventTitle($reviewable),
                'image' => $reviewable->thumbnail,
            ],
            Organizer::class => [
                'name' => $reviewable->organizer_name ?: 'Organizer',
                'image' => $reviewable->photo,
            ],
            Artist::class => [
                'name' => $reviewable->name,
                'image' => $reviewable->photo,
            ],
            default => [],
        };
    }

    private function resolveOrganizerLegacyIdForBooking(Booking $booking): ?int
    {
        $organizerIdentityId = $booking->organizer_identity_id
            ?? $booking->evnt?->owner_identity_id
            ?? null;

        if ($organizerIdentityId !== null) {
            $identity = \App\Models\Identity::query()->find($organizerIdentityId);
            $legacyId = $identity ? $this->catalogBridge->legacyIdForIdentity($identity, 'organizer') : null;
            if (is_numeric($legacyId)) {
                return (int) $legacyId;
            }
        }

        return !empty($booking->organizer_id) ? (int) $booking->organizer_id : null;
    }
}
