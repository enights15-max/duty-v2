<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Organizer;
use App\Models\Venue;
use App\Services\ArtistPublicProfileService;
use App\Services\EventInventorySummaryService;
use App\Services\EventWaitlistService;
use App\Services\OrganizerPublicProfileService;
use App\Services\SocialVisibilityService;
use App\Services\VenuePublicProfileService;
use App\Support\PublicAssetUrl;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SearchController extends Controller
{
    public function __construct(
        private SocialVisibilityService $socialVisibilityService,
        private OrganizerPublicProfileService $organizerPublicProfileService,
        private ArtistPublicProfileService $artistPublicProfileService,
        private VenuePublicProfileService $venuePublicProfileService,
        private EventInventorySummaryService $eventInventorySummaryService,
        private EventWaitlistService $eventWaitlistService
    )
    {
    }

    /**
     * Universal search across users, events, artists, venues, and organizers.
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');
        $authUser = Auth::guard('sanctum')->user();

        if (strlen($query) < 2) {
            return response()->json([
                'success' => true,
                'data' => [
                    'users' => [],
                    'events' => [],
                    'artists' => [],
                    'venues' => [],
                    'organizers' => [],
                ],
            ]);
        }

        $like = '%' . $query . '%';

        // 1. Users (customers)
        $users = Customer::where('status', 1)
            ->where(function ($q) use ($like) {
                $q->where('fname', 'LIKE', $like)
                    ->orWhere('lname', 'LIKE', $like)
                    ->orWhere('username', 'LIKE', $like)
                    ->orWhere('email', 'LIKE', $like);
            })
            ->select('id', 'fname', 'lname', 'username', 'email', 'photo')
            ->limit(10)
            ->get()
            ->map(function ($u) use ($authUser) {
                $followersCount = $u->followers()->where('status', 'accepted')->count();
                $followingCount = $u->follows()->where('status', 'accepted')->count();
                $isFollowing = $authUser ? $authUser->isFollowing($u) : false;
                $followsYou = $authUser ? $u->isFollowing($authUser) : false;

                return [
                    'id' => $u->id,
                    'type' => 'user',
                    'name' => trim($u->fname . ' ' . $u->lname),
                    'username' => $u->username,
                    'photo' => PublicAssetUrl::url($u->photo, 'assets/admin/img/customer-profile'),
                    'followers_count' => $followersCount,
                    'following_count' => $followingCount,
                    'is_following' => $isFollowing,
                    'follows_you' => $followsYou,
                    'mutual_connection' => $isFollowing && $followsYou,
                ];
            });

        // 2. Events
        $eventContents = EventContent::where('title', 'LIKE', $like)
            ->limit(10)
            ->get();

        $events = $eventContents->map(function ($ec) use ($authUser) {
            $event = Event::query()->with('tickets')->find($ec->event_id);
            if (!$event || $event->status != 1)
                return null;

            $inventorySummary = $this->eventInventorySummaryService->summarizeEvent($event);
            $waitlistSummary = $this->eventWaitlistService->summaryForEvent($event, $authUser);

            return [
                'id' => $event->id,
                'type' => 'event',
                'name' => $ec->title,
                'thumbnail' => $event->thumbnail
                    ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail)
                    : null,
                'date' => $event->start_date,
                'is_past' => $event->end_date_time ? now()->greaterThan($event->end_date_time) : false,
                'inventory_summary' => $inventorySummary,
                'waitlist' => $waitlistSummary,
                'availability_state' => $inventorySummary['availability_state'] ?? 'available',
                'show_marketplace_fallback' => (bool) ($inventorySummary['show_marketplace_fallback'] ?? false),
                'show_waitlist_cta' => (bool) ($inventorySummary['show_waitlist_cta'] ?? false),
                'marketplace_available_count' => (int) ($inventorySummary['marketplace_available_count'] ?? 0),
                'waitlist_count' => (int) ($waitlistSummary['waitlist_count'] ?? 0),
                'viewer_waitlist_subscribed' => (bool) ($waitlistSummary['viewer_waitlist_subscribed'] ?? false),
                'demand_label' => $inventorySummary['demand_label'] ?? 'Tickets disponibles',
            ];
        })->filter()->values();

        // 3. Artists
        $artists = $this->artistPublicProfileService
            ->buildDirectoryRecords($query)
            ->take(10)
            ->map(function (array $artist) {
                return [
                    'id' => $artist['id'],
                    'type' => 'artist',
                    'name' => $artist['name'],
                    'username' => $artist['username'],
                    'photo' => $artist['photo'],
                    'followers_count' => $artist['followers_count'] ?? 0,
                    'upcoming_events_count' => $artist['upcoming_events_count'] ?? 0,
                    'review_count' => $artist['review_count'] ?? 0,
                    'identity' => $artist['identity'],
                ];
            })
            ->values();

        // 4. Venues
        $venues = $this->venuePublicProfileService
            ->buildDirectoryRecords($query)
            ->take(10)
            ->map(function (array $venue) {
                return [
                    'id' => $venue['id'],
                    'type' => 'venue',
                    'name' => $venue['name'],
                    'city' => $venue['city'],
                    'photo' => $venue['photo'],
                    'followers_count' => $venue['followers_count'] ?? 0,
                    'upcoming_events_count' => $venue['upcoming_events_count'] ?? 0,
                    'review_count' => $venue['review_count'] ?? 0,
                    'identity' => $venue['identity'],
                ];
            })
            ->values();

        // 5. Organizers
        $organizers = $this->organizerPublicProfileService
            ->buildDirectoryRecords(null, $query)
            ->take(10)
            ->map(function (array $organizer) {
                return [
                    'id' => $organizer['id'],
                    'type' => 'organizer',
                    'name' => $organizer['name'],
                    'city' => $organizer['city'],
                    'photo' => $organizer['photo'],
                    'followers_count' => $organizer['followers_count'] ?? 0,
                    'upcoming_events_count' => $organizer['upcoming_events_count'] ?? 0,
                    'review_count' => $organizer['review_count'] ?? 0,
                    'identity' => $organizer['identity'] ?? null,
                ];
            })
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'users' => $users,
                'events' => $events,
                'artists' => $artists,
                'venues' => $venues,
                'organizers' => $organizers,
            ],
        ]);
    }

    /**
     * Get public profile for a user.
     */
    public function userProfile($id)
    {
        $customer = Customer::find($id);
 
         if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        // Count events attended (completed bookings AND ticket scanned)
        $eventsAttended = \App\Models\Event\Booking::where('customer_id', $customer->id)
            ->where('paymentStatus', 'completed')
            ->where('scan_status', 1)
            ->count();

        // Unique events attended
        $uniqueEvents = \App\Models\Event\Booking::where('customer_id', $customer->id)
            ->where('paymentStatus', 'completed')
            ->where('scan_status', 1)
            ->distinct('event_id')
            ->count('event_id');

        $authUser = auth('sanctum')->user();
        $followersCount = $customer->followers()->where('status', 'accepted')->count();
        $followingCount = $customer->follows()->where('status', 'accepted')->count();
        $isFollowing = $authUser ? $authUser->isFollowing($customer) : false;
        $followsYou = $authUser ? $customer->isFollowing($authUser) : false;
        $hasPendingRequest = $authUser ? $authUser->hasPendingFollowRequest($customer) : false;
        $upcomingAttendance = \App\Models\Event\Booking::query()
            ->where('customer_id', $customer->id)
            ->where('paymentStatus', 'completed')
            ->whereHas('evnt', function ($query) {
                $query->where(function ($eventQuery) {
                    $eventQuery->whereNull('end_date_time')
                        ->orWhere('end_date_time', '>', now());
                });
            })
            ->distinct()
            ->count('event_id');
        $visibility = $this->socialVisibilityService->profileVisibility($authUser, $customer);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $customer->id,
                'name' => trim($customer->fname . ' ' . $customer->lname),
                'username' => $customer->username,
                'photo' => PublicAssetUrl::url($customer->photo, 'assets/admin/img/customer-profile'),
                'country' => $customer->country,
                'city' => $customer->city,
                'is_verified' => !is_null($customer->email_verified_at),
                'is_private' => (bool) $customer->is_private,
                'member_since' => $customer->created_at?->format('M Y'),
                'is_following' => $isFollowing,
                'follows_you' => $followsYou,
                'mutual_connection' => $isFollowing && $followsYou,
                'has_pending_request' => $hasPendingRequest,
                'followers_count' => $followersCount,
                'following_count' => $followingCount,
                'can_view_activity' => $visibility['can_view_activity'],
                'activity_visibility' => $visibility['activity_visibility'],
                'stats' => [
                    'events_attended' => $eventsAttended,
                    'unique_events' => $uniqueEvents,
                    'upcoming_attendance' => $upcomingAttendance,
                ],
            ],
        ]);
    }

    /**
     * Get public profile for an artist.
     */
    public function artistProfile($id)
    {
        $target = $this->artistPublicProfileService->resolveByPublicId($id);
        if (!$target) {
            return response()->json(['success' => false, 'message' => 'Artist not found.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->artistPublicProfileService->buildPublicPayload(
                $target,
                auth('sanctum')->user()
            ),
        ]);
    }

    /**
     * Helper to verify if the authenticated user has access 
     * to view the lists of a specific customer (target user).
     */
    private function canViewUserLists($authUser, $targetUser)
    {
        return $this->socialVisibilityService->canViewProfileActivity($authUser, $targetUser);
    }

    public function userUpcomingAttendance($id)
    {
        $customer = Customer::find($id);
        if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!$this->socialVisibilityService->canViewActivity(auth('sanctum')->user(), $customer, 'upcoming')) {
            return response()->json(['success' => false, 'message' => 'Profile activity is hidden.'], 403);
        }

        $bookings = \App\Models\Event\Booking::with(['evnt.information'])
            ->where('customer_id', $customer->id)
            ->where('paymentStatus', 'completed')
            ->whereHas('evnt', function ($query) {
                $query->where(function ($eventQuery) {
                    $eventQuery->whereNull('end_date_time')
                        ->orWhere('end_date_time', '>', now());
                });
            })
            ->orderBy('created_at', 'desc')
            ->get()
            ->unique('event_id')
            ->values();

        $events = $bookings->map(function ($booking) {
            $event = $booking->evnt;
            $info = $event ? $event->information : null;

            return [
                'id' => $event ? $event->id : null,
                'title' => $info ? $info->title : 'Unknown Event',
                'thumbnail' => $event && $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'date' => $event ? $event->start_date : null,
                'booking_id' => $booking->id,
                'total_paid' => $booking->price + $booking->tax - $booking->discount,
            ];
        })->filter(function ($event) {
            return $event['id'] !== null;
        })->values();

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }

    /**
     * Profile Tab: "Asistidos" - Events this user has attended (Ticket Scanned)
     */
    public function userAttendedEvents($id)
    {
        $customer = Customer::find($id);
 
         if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!$this->socialVisibilityService->canViewActivity(auth('sanctum')->user(), $customer, 'attended')) {
            return response()->json(['success' => false, 'message' => 'Profile activity is hidden.'], 403);
        }

        $bookings = \App\Models\Event\Booking::with(['evnt.information'])
            ->where('customer_id', $customer->id)
            ->where('paymentStatus', 'completed')
            ->where('scan_status', 1)
            ->orderBy('created_at', 'desc')
            ->get();

        $events = $bookings->map(function ($booking) {
            $event = $booking->evnt;
            $info = $event ? $event->information : null;
            return [
                'id' => $event ? $event->id : null,
                'title' => $info ? $info->title : 'Unknown Event',
                'thumbnail' => $event && $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'date' => $event ? $event->start_date : null,
                'booking_id' => $booking->id,
                'total_paid' => $booking->price + $booking->tax - $booking->discount,
            ];
        })->filter(function ($e) {
            return $e['id'] !== null;
        })->values();

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }

    /**
     * Profile Tab: "Intereses" - Events on this user's wishlist
     */
    public function userInterestedEvents($id)
    {
        $customer = Customer::find($id);
 
         if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!$this->socialVisibilityService->canViewActivity(auth('sanctum')->user(), $customer, 'interested')) {
            return response()->json(['success' => false, 'message' => 'Profile activity is hidden.'], 403);
        }

        $wishlists = \App\Models\Event\Wishlist::where('customer_id', $customer->id)
            ->with(['event', 'event.information'])
            ->orderBy('created_at', 'desc')
            ->get();

        $events = $wishlists->map(function ($w) {
            $event = $w->event;
            if (!$event)
                return null;
            $info = $event->information;
            return [
                'id' => $event->id,
                'title' => $info ? $info->title : 'Unknown Event',
                'thumbnail' => $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null,
                'date' => $event->start_date,
                'is_past' => $event->end_date_time ? now()->greaterThan($event->end_date_time) : false,
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }

    /**
     * Profile Tab: "Favoritos" - Entities this user follows (Artists, Venues, Organizers, etc.)
     */
    public function userFavorites($id)
    {
        $customer = Customer::find($id);
        if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!$this->canViewUserLists(auth('sanctum')->user(), $customer)) {
            return response()->json(['success' => false, 'message' => 'Profile is private.'], 403);
        }

        $follows = $customer->follows()->where('status', 'accepted')->with('followable')->get();

        $favorites = $follows->map(function ($follow) {
            $entity = $follow->followable;
            if (!$entity)
                return null;

            $type = strtolower(class_basename($entity));
            $name = match ($type) {
                'customer' => trim(($entity->fname ?? '') . ' ' . ($entity->lname ?? '')),
                'artist', 'venue' => $entity->name ?? '',
                'organizer' => $entity->organizer_name ?? ($entity->username ?? 'Organizer'),
                default => $entity->name ?? '',
            };
            $photoAttr = match ($type) {
                'venue' => 'image',
                default => 'photo',
            };

            $photoPath = '';
            if ($type === 'customer')
                $photoPath = 'assets/admin/img/customer-profile/';
            elseif ($type === 'artist')
                $photoPath = 'assets/admin/img/artist/';
            elseif ($type === 'venue')
                $photoPath = 'assets/admin/img/venue/';
            elseif ($type === 'organizer')
                $photoPath = 'assets/admin/img/organizer-photo/';

            return [
                'id' => $entity->id,
                'type' => $type,
                'name' => $name,
                'photo' => PublicAssetUrl::url($entity->{$photoAttr}, $photoPath),
                'identifier' => $entity->username ?? $entity->slug ?? null,
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $favorites,
        ]);
    }

    /**
     * Profile Tab: "Seguidores" - Users following this customer
     */
    public function userFollowers($id)
    {
        $customer = Customer::find($id);
        if (!$customer || $customer->status != 1) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!$this->canViewUserLists(auth('sanctum')->user(), $customer)) {
            return response()->json(['success' => false, 'message' => 'Profile is private.'], 403);
        }

        $followers = $customer->followers()->where('status', 'accepted')->with('follower')->get();

        $data = $followers->map(function ($follow) {
            $user = $follow->follower;
            if (!$user)
                return null;

            $type = strtolower(class_basename($user));
            $name = '';
            $photo = null;

            if ($type === 'customer') {
                $name = trim(($user->fname ?? '') . ' ' . ($user->lname ?? ''));
                $photo = PublicAssetUrl::url($user->photo, 'assets/admin/img/customer-profile');
            } elseif ($type === 'artist') {
                $name = $user->name ?? '';
                $photo = PublicAssetUrl::url($user->photo, 'assets/admin/img/artist');
            } elseif ($type === 'venue') {
                $name = $user->name ?? '';
                $photo = PublicAssetUrl::url($user->image, 'assets/admin/img/venue');
            } elseif ($type === 'organizer') {
                $name = $user->organizer_name ?? ($user->username ?? 'Organizer');
                $photo = PublicAssetUrl::url($user->photo, 'assets/admin/img/organizer-photo');
            }

            return [
                'id' => $user->id,
                'type' => $type,
                'name' => $name,
                'photo' => $photo,
                'identifier' => $user->username ?? '',
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }
}
