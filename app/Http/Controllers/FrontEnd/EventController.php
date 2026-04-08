<?php

namespace App\Http\Controllers\Frontend;

use Carbon\Carbon;
use App\Models\Event;
use App\Models\Organizer;
use App\Models\Event\Coupon;
use App\Models\Event\Ticket;
use Illuminate\Http\Request;
use App\Models\Event\Wishlist;
use App\Http\Helpers\GeoSearch;
use App\Models\Event\EventCity;
use App\Models\Event\EventDates;
use App\Models\Event\EventImage;
use App\Models\Event\EventState;
use App\Models\Event\EventContent;
use App\Models\Event\EventCountry;
use Illuminate\Support\Facades\DB;
use App\Models\Event\EventCategory;
use App\Http\Controllers\Controller;
use App\Models\Event\Slot;
use App\Models\Event\SlotImage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;

class EventController extends Controller
{
  private $now_date_time;
  public function __construct()
  {
    $this->now_date_time = Carbon::now();
  }
  //index
  public function index(Request $request)
  {
    $language = $this->getLanguage();
    $information = [];
    $categories = EventCategory::where([['language_id', $language->id], ['status', 1]])->orderBy('serial_number', 'asc')->get();
    $information['categories'] = $categories;


    //for filter
    $category = $location = $event_type = $min = $max = $keyword = $date1 = $date2 = $country_id = $state_id = $city_id = null;

    if ($request->country) {
      $country_id = EventCountry::where('language_id', $language->id)
        ->where('slug', $request->country)
        ->value('id');
    }

    if ($request->state) {
      $state_id = EventState::where('language_id', $language->id)
        ->where('slug', $request->state)
        ->value('id');
    }

    if ($request->city) {
      $city_id = EventCity::where('language_id', $language->id)
        ->where('slug', $request->city)
        ->value('id');
    }

    $cscIds = [];
    $cscQuery = EventContent::where('language_id', $language->id);
    if ($country_id) {
      $cscQuery->where('country_id', $country_id);
    }

    if ($state_id) {
      $cscQuery->where('state_id', $state_id);
    }

    if ($city_id) {
      $cscQuery->where('city_id', $city_id);
    }
    $cscIds = $cscQuery->pluck('event_id')->toArray();


    if ($request->filled('category')) {
      $category = $request['category'];
      $category = EventCategory::where([['slug', $category], ['status', 1]])->first();
      $category = $category->id;
    }
    $eventSIds = [];
    if ($request->filled('location')) {
      $location = $request['location'];

      $event_contents = EventContent::where(function ($query) use ($location) {
        return $query->where('address', 'like', '%' . $location . '%')
          ->orWhere('city', 'like', '%' . $location . '%')
          ->orWhere('country', 'like', '%' . $location . '%')
          ->orWhere('state', 'like', '%' . $location . '%');
      })->where('language_id', $language->id)->get();

      foreach ($event_contents as $event_content) {
        if (!in_array($event_content->event_id, $eventSIds)) {
          array_push($eventSIds, $event_content->event_id);
        }
      }
    }

    if ($request->filled('event')) {
      $event_type = $request['event'];
    }
    $eventIds = [];

    if ($request->filled('min') && $request->filled('max')) {
      $min = $request['min'];
      $max = $request['max'];

      $tickets = Ticket::where('tickets.f_price', '>=', $min)->where('tickets.f_price', '<=', $max)->get();

      foreach ($tickets as $ticket) {
        if (!in_array($ticket->event_id, $eventIds)) {
          array_push($eventIds, $ticket->event_id);
        }
      }
    }

    if ($request->filled('search-input')) {
      $keyword = $request['search-input'];
    }
    $eventIds2 = [];
    if ($request->filled('dates')) {

      $dates = $request['dates'];
      $dateArray = explode(' ', $dates);

      $date1 = $dateArray[0];
      $date2 = $dateArray[2];

      $q_events = EventDates::whereDate('start_date', '<=', $date1)->whereDate('end_date', '>=', $date2)->get();
      foreach ($q_events as $evnt) {
        if (!in_array($evnt->event_id, $eventIds2)) {
          array_push($eventIds2, $evnt->event_id);
        }
      }

      $events = Event::whereDate('start_date', '<=', $date1)->whereDate('end_date', '>=', $date2)->get();

      foreach ($events as $event) {
        if (!in_array($event->id, $eventIds2)) {
          array_push($eventIds2, $event->id);
        }
      }
    }

    $information['countries'] = EventCountry::where([
      ['language_id', $language->id],
      ['status', 1]
    ])
      ->orderBy('serial_number', 'asc')
      ->get();

    $information['states'] = EventState::where([
      ['language_id', $language->id],
      ['status', 1]
    ])
      ->orderBy('serial_number', 'asc')
      ->get();

    $information['cities'] = EventCity::where([
      ['language_id', $language->id],
      ['status', 1]
    ])
      ->orderBy('serial_number', 'asc')
      ->get();

    //search by location
    $locationEveIds = [];
    $location = null;
    $lat_long = [];
    $bs = DB::table('basic_settings')->select('google_map_status', 'google_map_radius', 'google_map_api_key')->first();
    $radius = $bs->google_map_status == 1 ? $bs->google_map_radius : 5000;

    if ($request->filled('location')) {
      $location = $request->location;

      if ($bs->google_map_status == 1) {
        $lat_long = GeoSearch::getCoordinates($location, $bs->google_map_api_key);
        // dd($lat_long);
      } else {
        $locationEveIds = EventContent::Where('language_id', $language->id)
          ->where('address', 'like', '%' . $location . '%')
          ->distinct()
          ->pluck('event_id')
          ->toArray();
      }
    }

    $events = EventContent::join('events', 'events.id', 'event_contents.event_id')
      ->where('event_contents.language_id', $language->id)
      ->when($category, function ($query, $category) {
        return $query->where('event_contents.event_category_id', '=', $category);
      })
      ->when($event_type, function ($query, $event_type) {
        return $query->where('events.event_type', '=', $event_type);
      })
      ->when(($min && $max), function ($query) use ($eventIds) {
        return $query->whereIn('events.id', $eventIds);
      })
      ->when(($location && $bs->google_map_status == 0), function ($query) use ($locationEveIds) {
        return $query->whereIn('events.id', $locationEveIds);
      })
      ->when(($request->filled('country') || $request->filled('state') || $request->filled('city')), function ($query) use ($cscIds) {
        return $query->whereIn('events.id', $cscIds);
      })
      ->when(($date1 && $date2), function ($query) use ($eventIds2) {
        return $query->whereIn('events.id', $eventIds2);
      })
      ->when($keyword, function ($query, $keyword) {
        return $query->where('event_contents.title', 'like', '%' . $keyword . '%');
      })
      ->where('events.status', 1)
      ->whereDate('events.end_date_time', '>=', $this->now_date_time)
      ->select('events.*', 'event_contents.title', 'event_contents.description', 'event_contents.city', 'event_contents.state', 'event_contents.country', 'event_contents.address', 'event_contents.zip_code', 'event_contents.slug')
      ->orderBy('events.id', 'desc');
    //condition for geo location search
    if ($bs->google_map_status == 1) {
      if ($location && is_array($lat_long) && isset($lat_long['lat'], $lat_long['lng'])) {
        $events = $events->get()->map(function ($item) use ($lat_long) {
          $item->distance = round(GeoSearch::getDistance(
            $item->latitude,
            $item->longitude,
            $lat_long['lat'],
            $lat_long['lng']
          ));

          return $item;
        })->filter(function ($item) use ($radius) {
          $item = floatval($item->distance) <= $radius;
          return $item;
        });


        $events = $request->filled('sort') && $request->input('sort') == 'distance-away'
          ? $events->sortByDesc('distance')
          : $events->sortBy('distance');

        $events = $events->values(); // Reset keys

        $page = request()->get('page', 1);
        $perPage = 9;
        $offset = ($page * $perPage) - $perPage;
        $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
          $events->slice($offset, $perPage),
          $events->count(),
          $perPage,
          $page,
          ['path' => request()->url(), 'query' => request()->query()]
        );
        $events = $paginated;
      } elseif ($location && (!isset($lat_long['lat']) || !isset($lat_long['lng']))) {
        $events = new \Illuminate\Pagination\LengthAwarePaginator([], 0, 9, request('page', 1), [
          'path' => request()->url(),
          'query' => request()->query(),
        ]);
      } elseif (!$location && (!isset($lat_long['lat']) || !isset($lat_long['lng']))) {
        $events = $events->paginate(9);
      }
    } else {
      $events = $events->paginate(9);
    }


    $max = Ticket::max('f_price');
    $min = Ticket::min('f_price');
    $information['max'] = $max;
    $information['min'] = $min;
    $information['events'] = $events;

    return view('frontend.event.event', compact('information'));
  }

  private function transformEventListingPaginator($events, ?int $languageId = null)
  {
    $collection = method_exists($events, 'getCollection')
      ? $events->getCollection()
      : collect($events);

    if ($collection->isEmpty()) {
      return $events;
    }

    $eventIds = $collection->pluck('id')->filter()->unique()->values();
    $ticketGroups = Ticket::query()
      ->sellable()
      ->whereIn('event_id', $eventIds->all())
      ->get([
        'event_id',
        'event_type',
        'pricing_type',
        'price',
        'f_price',
        'variations',
        'normal_ticket_slot_enable',
        'slot_seat_min_price',
      ])
      ->groupBy('event_id');

    $organizerProfileService = app(OrganizerPublicProfileService::class);
    $admin = null;

    $transformed = $collection->map(function ($event) use ($ticketGroups, $organizerProfileService, $languageId, &$admin) {
      $eventDate = null;
      if (($event->date_type ?? null) === 'multiple') {
        $eventDate = eventLatestDates($event->id);
      }

      $startDate = $eventDate?->start_date ?: ($event->start_date ?? null);
      $duration = $eventDate?->duration ?: ($event->duration ?? null);
      $startDateTime = null;
      if (!empty($startDate) && !empty($event->start_time)) {
        try {
          $startDateTime = Carbon::parse(trim($startDate . ' ' . $event->start_time));
        } catch (\Throwable $throwable) {
          $startDateTime = null;
        }
      }

      $statusLabel = __('Upcoming');
      $statusClass = 'upcoming';
      if ($startDateTime && $startDateTime->isPast()) {
        $statusLabel = __('Live');
        $statusClass = 'live';
      }

      $ticketPreview = $this->buildEventTicketPreview(collect($ticketGroups->get($event->id, collect())));
      $description = trim(strip_tags((string) ($event->description ?? '')));
      $organizerProfile = $organizerProfileService->organizerPayloadForEvent(
        $event->owner_identity_id ?? null,
        $event->organizer_id ?? null,
        $languageId
      );

      if ($organizerProfile) {
        $organizerName = $organizerProfile['organizer_name'] ?? $organizerProfile['username'];
        $organizerRoute = route('frontend.organizer.details', [
          $organizerProfile['id'],
          str_replace(' ', '-', $organizerProfile['username'] ?? $organizerName),
        ]);
      } else {
        $admin = $admin ?: Admin::first();
        $organizerName = $admin?->username ?? __('Duty');
        $organizerRoute = $admin
          ? route('frontend.organizer.details', [$admin->id, str_replace(' ', '-', $admin->username), 'admin' => 'true'])
          : '#';
      }

      $event->listing_badge = ($event->event_type ?? null) === 'online' ? __('Online event') : __('Venue event');
      $event->status_label = $statusLabel;
      $event->status_class = $statusClass;
      $event->date_badge = $startDate ? Carbon::parse($startDate)->translatedFormat('M d') : __('Date TBD');
      $event->date_full = $startDate ? Carbon::parse($startDate)->translatedFormat('D, M d') : __('Date TBD');
      $event->time_badge = !empty($event->start_time)
        ? Carbon::parse($event->start_time)->translatedFormat('h:i A')
        : __('Time TBD');
      $event->duration_badge = $duration ?: __('Schedule TBD');
      $event->short_description = mb_strlen($description) > 140
        ? mb_substr($description, 0, 140) . '...'
        : ($description ?: __('More details will be announced soon.'));
      $event->location_badge = ($event->event_type ?? null) === 'venue'
        ? ($event->address ?: __('Venue to be announced'))
        : __('Online event');
      $event->price_display = $ticketPreview['price_display'];
      $event->price_hint = $ticketPreview['price_hint'];
      $event->ticket_count = $ticketPreview['ticket_count'];
      $event->organizer_name = $organizerName;
      $event->organizer_route = $organizerRoute;
      $event->distance_km = !empty($event->distance) ? number_format($event->distance / 1000, 2) : null;

      return $event;
    });

    if (method_exists($events, 'setCollection')) {
      $events->setCollection($transformed);

      return $events;
    }

    return $transformed;
  }

  private function buildEventTicketPreview(Collection $tickets): array
  {
    if ($tickets->isEmpty()) {
      return [
        'price_display' => __('Tickets soon'),
        'price_hint' => __('Lineup and ticket drops coming next.'),
        'ticket_count' => 0,
      ];
    }

    $ticket = $tickets
      ->sort(function (Ticket $first, Ticket $second) {
        return $this->eventTicketComparablePrice($first) <=> $this->eventTicketComparablePrice($second);
      })
      ->first();

    $price = $this->eventTicketComparablePrice($ticket);
    if ($price <= 0) {
      return [
        'price_display' => __('Free'),
        'price_hint' => __('Open access'),
        'ticket_count' => $tickets->count(),
      ];
    }

    return [
      'price_display' => symbolPrice($price),
      'price_hint' => $tickets->count() > 1 ? __('From the lowest ticket tier') : __('Current starting tier'),
      'ticket_count' => $tickets->count(),
    ];
  }

  private function eventTicketComparablePrice(Ticket $ticket): float
  {
    if ($ticket->pricing_type === 'variation') {
      $variations = json_decode($ticket->variations ?? '[]', true);
      if (is_array($variations) && !empty($variations)) {
        $variationPrices = collect($variations)
          ->map(function ($variation) {
            if (!empty($variation['slot_enable'])) {
              return (float) ($variation['slot_seat_min_price'] ?? 0);
            }

            return (float) ($variation['price'] ?? 0);
          })
          ->filter(fn($price) => $price >= 0)
          ->values();

        if ($variationPrices->isNotEmpty()) {
          return (float) $variationPrices->min();
        }
      }
    }

    if ((int) $ticket->normal_ticket_slot_enable === 1 && $ticket->slot_seat_min_price !== null) {
      return (float) $ticket->slot_seat_min_price;
    }

    if ($ticket->price !== null) {
      return (float) $ticket->price;
    }

    if ($ticket->f_price !== null) {
      return (float) $ticket->f_price;
    }

    return 0.0;
  }

  //details
  public function details($slug, $id)
  {
    try {
      $language = $this->getLanguage();
      $information = [];

      //remove all session data
      Session::forget('selTickets');
      Session::forget('total');
      Session::forget('quantity');
      Session::forget('total_early_bird_dicount');
      Session::forget('event');
      Session::forget('online_gateways');
      Session::forget('offline_gateways');

      $tickets_count = Ticket::where('event_id', $id)->get()->count();
      $information['tickets_count'] = $tickets_count;
      if ($tickets_count < 1) {
        $content = EventContent::join('events', 'events.id', 'event_contents.event_id')
          ->join('event_images', 'event_images.event_id', '=', 'events.id')
          ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
          ->where('event_contents.language_id', $language->id)
          ->where('events.id', $id)
          ->select('events.*', 'event_contents.title', 'event_contents.slug as eventSlug', 'event_contents.description', 'meta_keywords', 'meta_description', 'event_contents.event_category_id', 'event_categories.name', 'event_categories.slug', 'event_contents.city', 'event_contents.state', 'event_contents.country', 'event_contents.address', 'event_contents.zip_code', 'event_contents.refund_policy')
          ->first();
        if (is_null($content)) {
          Session::flash('alert-type', 'warning');
          // Session::flash('message', 'No event content found for ' . $language->name . ' Language');
          return redirect()->route('index');
        }
      } else {
        $content = EventContent::join('events', 'events.id', 'event_contents.event_id')
          ->join('tickets', 'tickets.event_id', '=', 'events.id')
          ->join('event_images', 'event_images.event_id', '=', 'events.id')
          ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
          ->where('event_contents.language_id', $language->id)
          ->where('events.id', $id)
          ->select('events.*', 'event_contents.title', 'event_contents.slug as eventSlug', 'event_contents.description', 'meta_keywords', 'meta_description', 'event_contents.event_category_id', 'event_categories.name', 'event_categories.slug', 'tickets.price', 'tickets.variations', 'tickets.pricing_type', 'event_contents.city', 'event_contents.state', 'event_contents.country', 'event_contents.address', 'event_contents.zip_code', 'event_contents.refund_policy')
          ->first();
        if (is_null($content)) {
          Session::flash('alert-type', 'warning');
          // Session::flash('message', 'No event content found for ' . $language->name . ' Language');
          return redirect()->route('index');
        }
      }

      $information['content'] = $content;
      $images = EventImage::where('event_id', $id)->get();
      $information['images'] = $images;

      $event_model = Event::with(['artists', 'venue'])->find($id);
      $information['artists'] = $event_model ? $event_model->artists : [];
      $information['venue_profile'] = $event_model ? $event_model->venue : null;

      $information['organizer'] = '';
      if ($content) {
        if ($content->organizer_id != NULL) {
          $organizer = Organizer::where('id', $content->organizer_id)->first();
          $information['organizer'] = $organizer;
        }
      }

      $category_id = $content->event_category_id;
      $event_id = $content->id;
      $related_events = EventContent::join('events', 'events.id', 'event_contents.event_id')
        ->where('event_contents.language_id', $language->id)
        ->where('event_contents.event_category_id', $category_id)
        ->where('events.id', '!=', $event_id)
        ->whereDate('events.end_date_time', '>=', $this->now_date_time)
        ->select('events.*', 'event_contents.title', 'event_contents.description', 'event_contents.slug', 'event_contents.city', 'event_contents.country', 'event_contents.address')
        ->orderBy('events.id', 'desc')
        ->get();


      $information['event_id'] = $event_id;
      $information['related_events'] = $related_events;
      return view('frontend.event.event-details', $information); //code...
    } catch (\Exception $th) {
      return view('errors.404');
    }
  }
  //applyCoupon
  public function applyCoupon(Request $request)
  {
    $coupon = Coupon::where('code', $request->coupon_code)->first();

    if (!$coupon) {
      Session::put('discount', NULL);
      return response()->json(['status' => 'error', 'message' => "Coupon is not valid"]);
    } else {

      $start = Carbon::parse($coupon->start_date);
      $end = Carbon::parse($coupon->end_date);
      $today = Carbon::now();
      $event = Session::get('event');
      $event_id = $event->id;
      $events = json_decode($coupon->events, true);
      if (!empty($events)) {
        if (in_array($event_id, $events)) {

          // if coupon is active
          if ($today->greaterThanOrEqualTo($start) && $today->lessThan($end)) {
            $value = $coupon->value;
            $type = $coupon->type;
            $early_bird_dicount = Session::get('total_early_bird_dicount');
            if ($early_bird_dicount != '') {
              $cartTotal = Session::get('sub_total') - $early_bird_dicount;
            } else {
              $cartTotal = Session::get('sub_total') - $early_bird_dicount;
            }
            if ($type == 'fixed') {
              $couponAmount = $value;
            } else {
              $couponAmount = ($cartTotal * $value) / 100;
            }
            $cartTotal - $couponAmount;
            Session::put('discount', $couponAmount);
            return response()->json(['status' => 'success', 'message' => "Coupon applied successfully"]);
          } else {
            return response()->json(['status' => 'error', 'message' => "Coupon is not valid"]);
          }
        } else {
          return response()->json(['status' => 'error', 'message' => "Coupon is not valid"]);
        }
      } else {
        // if coupon is active
        if ($today->greaterThanOrEqualTo($start) && $today->lessThan($end)) {
          $value = $coupon->value;
          $type = $coupon->type;
          $early_bird_dicount = Session::get('total_early_bird_dicount');
          if ($early_bird_dicount != '') {
            $cartTotal = Session::get('sub_total') - $early_bird_dicount;
          } else {
            $cartTotal = Session::get('sub_total') - $early_bird_dicount;
          }
          if ($type == 'fixed') {
            $couponAmount = $value;
          } else {
            $couponAmount = ($cartTotal * $value) / 100;
          }
          $cartTotal - $couponAmount;
          Session::put('discount', $couponAmount);
          return response()->json(['status' => 'success', 'message' => "Coupon applied successfully"]);
        } else {
          return response()->json(['status' => 'error', 'message' => "Coupon is not valid"]);
        }
      }
    }
  }

  //add_to_wishlist
  public function add_to_wishlist($id)
  {
    if (Auth::guard('customer')->check()) {
      $customer_id = Auth::guard('customer')->user()->id;
      $check = Wishlist::where('event_id', $id)->where('customer_id', $customer_id)->first();

      if (!empty($check)) {
        $notification = array('message' => 'You already added this event into your wishlist..!', 'alert-type' => 'error');
        return back()->with($notification);
      } else {
        $add = new Wishlist;
        $add->event_id = $id;
        $add->customer_id = $customer_id;
        $add->save();
        $notification = array('message' => 'Add to your wishlist successfully..!', 'alert-type' => 'success');
        return back()->with($notification);
      }
    } else {
      return redirect()->route('customer.login');
    }
  }
  //search country
  public function getCountry(Request $request)
  {
    $search = $request->input('search');
    $page = $request->input('page', 1);
    $pageSize = 10;

    $language = $this->getLanguage();
    $query = EventCountry::where('language_id', $language->id);

    if ($search) {
      $query->where('name', 'like', "%{$search}%");
    }

    // Add pagination
    $countries = $query->skip(($page - 1) * $pageSize)
      ->take($pageSize + 1)
      ->get(['id', 'slug', 'name']);


    // Check if there's more data
    $hasMore = count($countries) > $pageSize;
    $results = $hasMore ? $countries->slice(0, $pageSize) : $countries;

    return response()->json([
      'results' => $results,
      'more' => $hasMore
    ]);
  }


  public function searchSate(Request $request)
  {

    $search = $request->input('search');
    $page = $request->input('page', 1);
    $pageSize = 10;

    $language = $this->getLanguage();

    $country_id = null;
    if ($request->country) {
      $country_id = EventCountry::where('language_id', $language->id)
        ->where('slug', $request->country)
        ->value('id');
    }

    $query = EventState::where('language_id', $language->id)
      ->when($request->country, function ($q) use ($country_id) {
        return $q->where('country_id', $country_id);
      });

    if ($search) {
      $query->where('name', 'like', "%{$search}%");
    }

    // Add pagination
    $cities = $query->skip(($page - 1) * $pageSize)
      ->take($pageSize + 1)
      ->get(['id', 'slug', 'name']);

    // Check if there's more data
    $hasMore = count($cities) > $pageSize;
    $results = $hasMore ? $cities->slice(0, $pageSize) : $cities;

    return response()->json([
      'results' => $results,
      'more' => $hasMore
    ]);
  }


  public function getSearchCity(Request $request)
  {
    $search = $request->input('search');
    $page = $request->input('page', 1);
    $pageSize = 10;

    $language = $this->getLanguage();

    $state_id = null;
    if ($request->state) {
      $state_id = EventState::where('language_id', $language->id)
        ->where('slug', $request->state)
        ->value('id');
    }

    $query = EventCity::where('language_id', $language->id)
      ->when($request->state, function ($q) use ($state_id) {
        return $q->where('state_id', $state_id);
      });

    if ($search) {
      $query->where('name', 'like', "%{$search}%");
    }

    // Add pagination
    $cities = $query->skip(($page - 1) * $pageSize)
      ->take($pageSize + 1)
      ->get(['id', 'slug', 'name']);

    // Check if there's more data
    $hasMore = count($cities) > $pageSize;
    $results = $hasMore ? $cities->slice(0, $pageSize) : $cities;

    return response()->json([
      'results' => $results,
      'more' => $hasMore
    ]);
  }


  public function slotMapping(Request $request)
  {

    $ticket_id = $request->ticket_id;
    $slot_unique_id = $request->slot_unique_id;
    $event_id = $request->event_id;
    $ticket = Ticket::find($ticket_id);
    $seatMappingImage = SlotImage::where([
      'event_id' => $event_id,
      'ticket_id' => $ticket_id,
      'slot_unique_id' => $slot_unique_id,
    ])->first();

    if (!$seatMappingImage) {
      return response()->json([
        'status' => 'error',
        'message' => "No Seat Available",
        'slots' => [],
      ]);
    }

    $bookedTicketData = app(\App\Services\BookingServices::class)->getBookingDeactiveData($event_id);

    $data['cover_image'] = $seatMappingImage->image;
    $data['pricing_type'] = $ticket->pricing_type;

    $slots = Slot::where([
      'event_id' => $event_id,
      'ticket_id' => $ticket_id,
      'slot_unique_id' => $slot_unique_id,
    ])->with('seats')->get();

    $slots->map(function ($slot) use ($bookedTicketData, $ticket) {

      $slot->slot_name = $slot->name;
      $slot->slot_type = $slot->type;
      $slot->filtered_seats->each(function ($item) use ($ticket, $slot, $bookedTicketData) {
        if ($ticket->early_bird_discount == 'enable') {
          $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
          if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
            $calculate_price = $item->price - $ticket->early_bird_discount_amount;
          } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
            $c_price = ($item->price * $ticket->early_bird_discount_amount) / 100;
            $calculate_price = $item->price - $c_price;
          } else {
            $calculate_price = $item->price;
          }
        } else {
          $calculate_price = $item->price;
        }
        $item->payable_price = $calculate_price;
        $item->seat_type = $slot->type;
        //when seat is deactive
        $seat_check_booked = $item->is_deactive;
        //when check is_booked
        if ($seat_check_booked == 0) {
          $seat_check_booked = in_array($item->id, $bookedTicketData['seat_ids']) ? 1 : 0;
        }
        $item->is_booked = $seat_check_booked;
        return $item;
      });

      $check_booked = $slot->is_deactive;
      if ($check_booked == 0) {
        if ($slot->type == 2) {
          $check_booked = in_array($slot->id, $bookedTicketData['slot_ids']) ? 1 : 0;
        } else {
          $check_booked = $slot->seats->count() == $slot->seats->where('is_booked', 1)->count() ? 1 : 0;
        }
      }

      $slot->is_booked = $check_booked;
      return $slot;
    });


    return response()->json([
      'status' => 'success',
      'message' => "",
      'slots' => json_encode($slots->toArray()),
      'view' => view('frontend.event.slots.slot-mapping-seat', $data)->render()
    ]);
  }

  // filter for AJAX
  public function filter(Request $request)
  {
    $language = $this->getLanguage();
    $category_id = $request->category_id;

    $events = EventContent::join('events', 'events.id', 'event_contents.event_id')
      ->where('event_contents.language_id', $language->id)
      ->when($category_id, function ($query, $category_id) {
        return $query->where('event_contents.event_category_id', '=', $category_id);
      })
      ->where('events.status', 1)
      ->whereDate('events.end_date_time', '>=', $this->now_date_time)
      ->select('events.*', 'event_contents.title', 'event_contents.description', 'event_contents.slug', 'event_contents.city', 'event_contents.country', 'event_contents.address')
      ->orderBy('events.id', 'desc')
      ->take(9)
      ->get();

    $html = '';
    if ($events->count() > 0) {
      foreach ($events as $event) {
        $html .= view('frontend.partials.event-card', compact('event'))->render();
      }
    } else {
      $html = '<div class="col-12 text-center"><h3>' . __('No Events Found') . '</h3></div>';
    }

    return response()->json(['html' => $html]);
  }
}
