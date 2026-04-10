<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Controllers\FrontEnd\Event\BookingController;
use App\Http\Helpers\GeoSearch;
use App\Jobs\BookingInvoiceJob;
use App\Models\Admin;
use App\Models\BasicSettings\Basic;
use App\Models\BasicSettings\PageHeading;
use App\Models\Earning;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Coupon;
use App\Models\Event\EventCategory;
use App\Models\Event\EventCity;
use App\Models\Event\EventContent;
use App\Models\Event\EventCountry;
use App\Models\Event\EventDates;
use App\Models\Event\EventImage;
use App\Models\Event\EventState;
use App\Models\Event\Slot;
use App\Models\Event\SlotImage;
use App\Models\Event\Ticket;
use App\Models\Event\TicketContent;
use App\Models\Event\VariationContent;
use App\Models\Event\Wishlist;
use App\Models\FcmToken;
use App\Models\Language;
use App\Models\Organizer;
use App\Models\TicketTransfer;
use App\Models\Customer;
use App\Services\BookingServices;
use App\Services\EventBookingGuardService;
use App\Services\EventCheckoutGuardService;
use App\Services\EventCheckoutPricingService;
use App\Services\EventCheckoutSelectionService;
use App\Services\EventEarlyBirdDiscountService;
use App\Services\EventInventorySummaryService;
use App\Services\EventPaymentVerificationService;
use App\Services\EventPurchaseLimitService;
use App\Services\OrganizerPublicProfileService;
use App\Services\EventSocialSummaryService;
use App\Services\EventTicketNameResolverService;
use App\Services\EventWaitlistService;
use App\Services\TicketJourneyService;
use App\Services\TicketPriceScheduleService;
use App\Services\BonusWalletService;
use App\Services\CheckoutFundingAllocatorService;
use App\Services\BookingFundingService;
use App\Services\FirebaseService;
use App\Services\FeeEngine;
use App\Services\WalletService;
use App\Services\NotificationService;
use App\Services\PlatformRevenueService;
use App\Support\PublicAssetUrl;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Fluent;
use Illuminate\Support\Str;
use stdClass;

class EventController extends Controller
{
  private $now_date_time;
  protected $walletService;
  protected $stripeService;
  protected $notificationService;
  protected $eventBookingGuardService;
  protected $eventCheckoutGuardService;
  protected $eventCheckoutPricingService;
  protected $eventCheckoutSelectionService;
  protected $eventEarlyBirdDiscountService;
  protected $eventTicketNameResolverService;
  protected $eventPaymentVerificationService;
  protected $bonusWalletService;
  protected $checkoutFundingAllocatorService;
  protected $bookingFundingService;
  protected $ticketPriceScheduleService;
  protected $eventSocialSummaryService;
  protected $organizerPublicProfileService;
  protected $eventInventorySummaryService;
  protected $eventWaitlistService;
  protected $ticketJourneyService;
  protected $feeEngine;
  protected $platformRevenueService;

  public function __construct(
    WalletService $walletService = null,
    BonusWalletService $bonusWalletService = null,
    \App\Services\StripeService $stripeService = null,
    NotificationService $notificationService = null,
    EventBookingGuardService $eventBookingGuardService = null,
    EventCheckoutGuardService $eventCheckoutGuardService = null,
    EventCheckoutPricingService $eventCheckoutPricingService = null,
    EventCheckoutSelectionService $eventCheckoutSelectionService = null,
    EventEarlyBirdDiscountService $eventEarlyBirdDiscountService = null,
    EventTicketNameResolverService $eventTicketNameResolverService = null,
    EventPaymentVerificationService $eventPaymentVerificationService = null,
    TicketPriceScheduleService $ticketPriceScheduleService = null,
    CheckoutFundingAllocatorService $checkoutFundingAllocatorService = null,
    BookingFundingService $bookingFundingService = null,
    EventSocialSummaryService $eventSocialSummaryService = null,
    OrganizerPublicProfileService $organizerPublicProfileService = null,
    EventInventorySummaryService $eventInventorySummaryService = null,
    EventWaitlistService $eventWaitlistService = null,
    TicketJourneyService $ticketJourneyService = null,
    FeeEngine $feeEngine = null,
    PlatformRevenueService $platformRevenueService = null
  )
  {
    $this->now_date_time = Carbon::now();
    // Use app() as fallback if not auto-injected in some places
    $this->walletService = $walletService ?? app(WalletService::class);
    $this->stripeService = $stripeService ?? app(\App\Services\StripeService::class);
    $this->notificationService = $notificationService ?? app(NotificationService::class);
    $this->eventBookingGuardService = $eventBookingGuardService ?? app(EventBookingGuardService::class);
    $this->eventCheckoutGuardService = $eventCheckoutGuardService ?? app(EventCheckoutGuardService::class);
    $this->eventCheckoutPricingService = $eventCheckoutPricingService ?? app(EventCheckoutPricingService::class);
    $this->eventCheckoutSelectionService = $eventCheckoutSelectionService ?? app(EventCheckoutSelectionService::class);
    $this->eventEarlyBirdDiscountService = $eventEarlyBirdDiscountService ?? app(EventEarlyBirdDiscountService::class);
    $this->eventTicketNameResolverService = $eventTicketNameResolverService ?? app(EventTicketNameResolverService::class);
    $this->eventPaymentVerificationService = $eventPaymentVerificationService ?? app(EventPaymentVerificationService::class);
    $this->bonusWalletService = $bonusWalletService ?? app(BonusWalletService::class);
    $this->ticketPriceScheduleService = $ticketPriceScheduleService ?? app(TicketPriceScheduleService::class);
    $this->checkoutFundingAllocatorService = $checkoutFundingAllocatorService ?? app(CheckoutFundingAllocatorService::class);
    $this->bookingFundingService = $bookingFundingService ?? app(BookingFundingService::class);
    $this->eventSocialSummaryService = $eventSocialSummaryService ?? app(EventSocialSummaryService::class);
    $this->organizerPublicProfileService = $organizerPublicProfileService ?? app(OrganizerPublicProfileService::class);
    $this->eventInventorySummaryService = $eventInventorySummaryService ?? app(EventInventorySummaryService::class);
    $this->eventWaitlistService = $eventWaitlistService ?? app(EventWaitlistService::class);
    $this->ticketJourneyService = $ticketJourneyService ?? app(TicketJourneyService::class);
    $this->feeEngine = $feeEngine ?? app(FeeEngine::class);
    $this->platformRevenueService = $platformRevenueService ?? app(PlatformRevenueService::class);
  }
  /* ***************************
   * Events Page Information
   * ***************************/
  public function index(Request $request)
  {
    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    $information = [];
    $information['page_title'] = PageHeading::where('language_id', $language->id)->pluck('event_page_title')->first();

    $categories = EventCategory::where([['language_id', $language->id], ['status', 1]])->orderBy('serial_number', 'asc')
      ->get()
      ->map(function ($category) {
        $category->image = $category->image ? asset('assets/admin/img/event-category/' . $category->image) : null;
        return $category;
      });

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

    // Professional Context Filter
    $activeIdentityId = $request->header('X-Identity-Id');
    $activeIdentity = $activeIdentityId ? \App\Models\Identity::find($activeIdentityId) : null;

    $events = Event::join('event_contents', 'events.id', 'event_contents.event_id')
      ->where('event_contents.language_id', $language->id)
      ->when($activeIdentity, function ($query) use ($activeIdentity) {
        // Enforce Explore Events isolation: pros only see their own events.
        if ($activeIdentity->type === 'organizer') {
          return $query->ownedByOrganizerActor($activeIdentity->id, $activeIdentity->legacy_organizer_id);
        } elseif ($activeIdentity->type === 'venue') {
          return $query->ownedByVenueActor($activeIdentity->id, $activeIdentity->legacy_venue_id);
        } elseif ($activeIdentity->type === 'artist') {
          return $query->participatesAsArtistActor($activeIdentity->id, $activeIdentity->legacy_artist_id);
        }
        return $query;
      })
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
      ->with(['ownerIdentity', 'venueIdentity'])
      ->select('events.*', 'event_contents.title', 'event_contents.city', 'event_contents.state', 'event_contents.country', 'event_contents.address', 'event_contents.zip_code', 'event_contents.slug')
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
      } elseif ($location && (!isset($lat_long['lat']) || !isset($lat_long['lng']))) {
        $events = $events->get();
      } elseif (!$location && (!isset($lat_long['lat']) || !isset($lat_long['lng']))) {
        $events = $events->get();
      }
    } else {
      $events = $events->get();
    }

    $eventCollection = $events->map(function ($event, $customer) {

      $event_date = $event->date_type == 'multiple' ? eventLatestDates($event->id) : null;

      $start_date = $event->date_type == 'multiple' ? @$event_date->start_date : $event->start_date;
      $start_time = $event->start_time;

      // Organizer
      if ($event->organizer_id != null) {
        $organizer = Organizer::find($event->organizer_id);
        $organizer_name = $organizer ? $organizer->username : null;
      } else {
        $admin = Admin::first();
        $organizer_name = $admin->username;
      }

      if ($event->event_type == 'online') {
        $ticket = Ticket::where('event_id', $event->id)->orderBy('price', 'asc')->first();
        $start_price = $ticket->price;
      } else {
        $ticket = Ticket::where('event_id', $event->id)->whereNotNull('price')->orderBy('price', 'asc')->first();
        if (!$ticket) {
          $ticket = Ticket::where('event_id', $event->id)->whereNotNull('f_price')->orderBy('price', 'asc')->first();
          $start_price = $ticket->f_price;
        } else {
          $start_price = $ticket->price;
        }
      }

      $customer = Auth::guard('sanctum')->user();
      if (!empty($customer)) {
        $wishlist = Wishlist::where([['event_id', $event->id], ['customer_id', $customer->id]])->first();
      } else {
        $wishlist = null;
      }
      $dates = null;
      if ($event->date_type == 'multiple') {
        $dates = EventDates::where('event_id', $event->id)->get();
      }
      return [
        'id' => $event->id,
        'title' => $event->title,
        'thumbnail' => asset('assets/admin/img/event/thumbnail/' . $event->thumbnail),
        'address' => $event->address,
        'date' => $start_date,
        'time' => $start_time,
        'date_type' => $event->date_type,
        'duration' => $event->date_type == 'multiple' ? @$event_date->duration : $event->duration,
        'organizer' => $organizer_name,
        'owner_identity' => $event->ownerIdentity,
        'venue_identity' => $event->venueIdentity,
        'event_type' => $event->event_type,
        'start_price' => $ticket->pricing_type == 'free' ? $ticket->pricing_type : $start_price,
        'wishlist' => !is_null($wishlist) ? 'yes' : 'no',
        'dates' => $dates,
      ];
    });

    $information['max'] = $max;
    $information['min'] = $min;
    $information['events'] = $eventCollection;

    $currencyInfo = $this->getCurrencyInfo();

    $information['base_currency_symbol'] = $currencyInfo->base_currency_symbol;
    $information['base_currency_symbol_position'] = $currencyInfo->base_currency_symbol_position;
    $information['base_currency_text'] = $currencyInfo->base_currency_text;
    $information['base_currency_text_position'] = $currencyInfo->base_currency_text_position;
    $information['base_currency_rate'] = $currencyInfo->base_currency_rate;


    return response()->json([
      'success' => true,
      'data' => $information
    ]);
  }

  /* *****************************
   * Event Details Page
   * *****************************/
  public function details(Request $request)
  {
    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first() : Language::where('is_default', 1)->first();

    $event_id = $request->event_id;

    $information['page_title'] = PageHeading::where('language_id', $language->id)->pluck('event_details_page_title')->first();

    // Base query for event content
    $content = EventContent::join('events', 'events.id', 'event_contents.event_id')
      ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
      ->where('event_contents.language_id', $language->id)
      ->where('events.id', $event_id)
      ->with(['ownerIdentity', 'venueIdentity'])
      ->select(
        'events.*',
        'event_contents.title',
        'event_contents.description',
        'event_contents.event_category_id',
        'event_categories.name',
        'event_contents.city',
        'event_contents.state',
        'event_contents.country',
        'event_contents.address',
        'event_contents.zip_code',
        'event_contents.refund_policy'
      )
      ->first();

    if ($content && $content->venue_id) {
      $venue = \App\Models\Venue::find($content->venue_id);
      if ($venue && $venue->image) {
        $venue->image = asset('assets/admin/img/venue/' . $venue->image);
      }
      $content->venue = $venue;
    }

    if (empty($content)) {
      return response()->json([
        'success' => false,
        'message' => 'The event is not found'
      ]);
    }

    // Fix potential image path issues
    $content->thumbnail = $content->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $content->thumbnail) : null;
    $content->image = $content->image ? asset('assets/admin/img/event/thumbnail/' . $content->image) : null;

    $dates = null;
    if ($content->date_type == 'multiple') {
      $dates = EventDates::where('event_id', $content->id)->get();
    }
    $content->dates = $dates;

    $information['content'] = $content;
    if (!is_null(@$content->organizer_id)) {
      $organizer = Organizer::join('organizer_infos', 'organizers.id', '=', 'organizer_infos.organizer_id')
        ->where('organizer_id', $content->organizer_id)
        ->select('organizers.id', 'organizer_infos.name', 'organizer_infos.address', 'organizers.photo')
        ->first();
      $image_url = !is_null($organizer->photo) ? asset('assets/admin/img/organizer-photo/' . $organizer->photo) : asset('assets/front/images/user.png');
      $organizer->photo = $image_url;
      $information['organizer'] = $organizer;
    } else {
      $admin = Admin::first();
      $admin->image = !is_null($admin->image) ? asset('assets/admin/img/admins/' . $admin->image) : asset('assets/admin/img/blank_user.jpg');
      $information['admin'] = $admin;
    }

    $information['owner_identity'] = $content->ownerIdentity;
    $information['venue_identity'] = $content->venueIdentity;

    // Check if tickets exist and modify query accordingly
    $tickets = Ticket::query()
      ->sellable()
      ->where('tickets.event_id', $event_id)
      ->get();
    $viewerCustomerId = resolveAuthenticatedCustomerId();
    $viewerCustomer = $viewerCustomerId ? Customer::find($viewerCustomerId) : null;
    $purchaseLimitService = app(EventPurchaseLimitService::class);


    $tickets->map(function ($ticket) use ($event_id, $content, $language, $viewerCustomer, $purchaseLimitService) {
      $pricingSnapshot = $this->ticketPriceScheduleService->resolveForTicket($ticket);
      $effectiveBasePrice = (float) ($pricingSnapshot['effective_price'] ?? ($ticket->price ?? $ticket->f_price ?? 0));
      $ticketLimitSummary = $purchaseLimitService->summarize($viewerCustomer, $content, $ticket);

      $ticket->base_price = round((float) ($ticket->price ?? $ticket->f_price ?? 0), 2);
      $ticket->current_price = round($effectiveBasePrice, 2);
      $ticket->has_price_schedule = (bool) ($pricingSnapshot['has_schedule'] ?? false);
      $ticket->current_price_schedule = $pricingSnapshot['current_schedule'] ?? null;
      $ticket->next_price_schedule = $pricingSnapshot['next_schedule'] ?? null;
      $ticket->next_price = $pricingSnapshot['next_schedule']['price'] ?? null;
      $ticket->next_price_effective_from = $pricingSnapshot['next_schedule']['effective_from'] ?? null;
      $ticket->purchase_status = $ticketLimitSummary['limit_reached'] ? 'true' : 'false';
      $ticket->purchase_qty = $ticketLimitSummary['already_purchased'];
      $ticket->remaining_purchase_qty = $ticketLimitSummary['remaining_allowed'];

      if ($ticket->event_type == 'online') {
        $ticket->title = $content->title ?? "";
      } else {
        $ticketContent = TicketContent::where('ticket_id', $ticket->id)->where('language_id', $language->id)->first();
        if (!is_null($ticketContent)) {
          $ticket->title = $ticketContent->title ?? "";
        }
      }
      if ($ticket->event_type == 'online' && $ticket->pricing_type == 'normal') {
        if ($ticket->early_bird_discount == 'enable') {
          $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
          if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
            $discountable_price_show = true;
            $calculate_price = $ticket->price - $ticket->early_bird_discount_amount;
          } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
            $c_price = ($ticket->price * $ticket->early_bird_discount_amount) / 100;
            $calculate_price = $ticket->price - $c_price;
            $discountable_price_show = true;
          } else {
            $discountable_price_show = false;
            $calculate_price = $ticket->price;
          }
        } else {
          $discountable_price_show = false;
          $calculate_price = $ticket->price;
        }

        if ($ticket->ticket_available_type == 'limited') {
          $stock = $ticket->ticket_available;
        } else {
          $stock = 99999999;
        }

        $ticket->ticket_stock = $stock;
        $ticket->slot_seat_active = null;
        $ticket->slot_unique_id = null;
        $ticket->seat_is_available = null;
        $ticket->purchase_status = $ticketLimitSummary['limit_reached'] ? 'true' : 'false';
        $ticket->purchase_qty = $ticketLimitSummary['already_purchased'];
        $ticket->discountable_price_show = $discountable_price_show;
        $ticket->total_price = $ticket->price;
        $ticket->payable_price = $calculate_price;
      } elseif ($ticket->event_type == 'online' && $ticket->pricing_type == 'free') {

        if ($ticket->ticket_available_type == 'limited') {
          $stock = $ticket->ticket_available;
        } else {
          $stock = 99999999;
        }
        $ticket->ticket_stock = $stock;
        $ticket->slot_seat_active = null;
        $ticket->slot_unique_id = null;
        $ticket->seat_is_available = null;
        $ticket->purchase_status = $ticketLimitSummary['limit_reached'] ? 'true' : 'false';
        $ticket->purchase_qty = $ticketLimitSummary['already_purchased'];
        $ticket->discountable_price_show = false;
        $ticket->total_price = 0.00;
        $ticket->payable_price = 0.00;
      } elseif ($ticket->event_type == 'venue') {
        if ($ticket->pricing_type == 'normal') {
          //normal ticket
          if ($ticket->normal_ticket_slot_enable == 1) {
            $slotBookService = new BookingServices();
            $slotItem = $slotBookService->showSlot($event_id, $ticket->id, $ticket->normal_ticket_slot_unique_id);
            $slotPrice = $slotItem['price'];
            $calculate_price = $slotPrice;
            $discountable_price_show = false;
            if ($ticket->early_bird_discount == 'enable') {
              $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
                $calculate_price = $slotPrice - $ticket->early_bird_discount_amount;
                $discountable_price_show = true;
              } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
                $c_price = ($slotPrice * $ticket->early_bird_discount_amount) / 100;
                $calculate_price = $slotPrice - $c_price;
                $discountable_price_show = true;
              } else {
                $calculate_price = $slotPrice;
              }
            }
            if ($slotItem['available_seat'] == true) {
              $seat_is_available = 'available';
            } else {
              $is_slot = Slot::where(
                [
                  'slot_unique_id' => $ticket->normal_ticket_slot_unique_id,
                  'event_id' => $event_id,
                  'ticket_id' => $ticket->id,
                ]
              )->first();

              if (!empty($is_slot)) {
                $seat_is_available = 'booked';
              } else {
                $seat_is_available = 'no_seat_found';
              }
            }

            $ticket->ticket_stock = null;
            $ticket->slot_seat_active = $ticket->normal_ticket_slot_enable;
            $ticket->slot_unique_id = $ticket->normal_ticket_slot_unique_id;
            $ticket->seat_is_available = $seat_is_available;
            $ticket->discountable_price_show = $discountable_price_show;
            $ticket->total_price = $slotPrice;
            $ticket->payable_price = $calculate_price;
          } else {
            $calculate_price = $ticket->price;
            $discountable_price_show = false;
            if ($ticket->early_bird_discount == 'enable') {
              $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
                $calculate_price = $ticket->price - $ticket->early_bird_discount_amount;
                $discountable_price_show = true;
              } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
                $c_price = ($ticket->price * $ticket->early_bird_discount_amount) / 100;
                $calculate_price = $ticket->price - $c_price;
                $discountable_price_show = true;
              } else {
                $calculate_price = $ticket->price;
              }
            }

            if ($ticket->ticket_available_type == 'limited') {
              $stock = $ticket->ticket_available;
            } else {
              $stock = 9999999;
            }

            $ticket->ticket_stock = $stock;
            $ticket->slot_seat_active = $ticket->normal_ticket_slot_enable;
            $ticket->slot_unique_id = $ticket->normal_ticket_slot_unique_id;
            $ticket->seat_is_available = null;
            $ticket->purchase_status = $ticketLimitSummary['limit_reached'] ? 'true' : 'false';
            $ticket->purchase_qty = $ticketLimitSummary['already_purchased'];
            $ticket->discountable_price_show = $discountable_price_show;
            $ticket->total_price = $ticket->price;
            $ticket->payable_price = $calculate_price;
          }
          $ticket->variations = collect();
        } elseif ($ticket->pricing_type == 'variation') {
          //varitations
          if (!is_null($ticket->variations)) {
            $variations = json_decode($ticket->variations, true);
            $slotBookService = new BookingServices();
            $updatedVariations = [];
            foreach ($variations as $key => $item) {
              $item = new Fluent($item);
              if ($item->slot_enable == 1) {
                $slotItem = $slotBookService->showSlot($event_id, $ticket->id, $item->slot_unique_id);
                $slotPrice = $slotItem['price'];
                if ($slotItem['available_seat'] == true) {
                  $seat_is_available = 'available';
                  if ($ticket->early_bird_discount == 'enable') {
                    $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
                    if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
                      $calculate_price = $slotPrice - $ticket->early_bird_discount_amount;
                      $discountable_price_show = true;
                    } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
                      $c_price = ($slotPrice * $ticket->early_bird_discount_amount) / 100;
                      $calculate_price = $slotPrice - $c_price;
                      $discountable_price_show = true;
                    } else {
                      $discountable_price_show = false;
                      $calculate_price = $slotPrice;
                    }
                  } else {
                    $discountable_price_show = false;
                    $calculate_price = $slotPrice;
                  }
                } else {
                  $discountable_price_show = false;
                  $calculate_price = $slotItem['price'];
                  $is_slot = Slot::where([
                    'slot_unique_id' => $item->slot_unique_id,
                    'event_id' => $event_id,
                    'ticket_id' => $ticket->id,
                  ])->first();
                  if (!empty($is_slot)) {
                    $seat_is_available = 'booked';
                  } else {
                    $seat_is_available = 'no_seat_found';
                  }
                }

                $item->ticket_stock = null;
                $item->purchase_status = null;
                $item->purchase_qty = null;
                $item->slot_seat_active = $item->slot_enable;
                // removed redundant assignment
                $item->seat_is_available = $seat_is_available;
                $item->discountable_price_show = $discountable_price_show;
                $item->total_price = $slotPrice;
                $item->payable_price = $calculate_price;
              } else {
                $discount_date = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
                if ($ticket->early_bird_discount == 'enable') {
                  if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast()) {
                    $calculate_price = $item->price - $ticket->early_bird_discount_amount;
                    $discountable_price_show = true;
                  } elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast()) {
                    $c_price = ($item->price * $ticket->early_bird_discount_amount) / 100;
                    $calculate_price = $item->price - $c_price;
                    $discountable_price_show = true;
                  } else {
                    $calculate_price = $item->price;
                    $discountable_price_show = false;
                  }

                  $de_varition_names = VariationContent::where(
                    [['ticket_id', $ticket->id]],
                  )->get();

                  if (Auth::guard('customer')->user()) {
                    if (count($de_varition_names) > 0) {
                      $purchase = isTicketPurchaseVenue(
                        $ticket->event_id,
                        $item->v_max_ticket_buy,
                        $ticket->id,
                        $de_varition_names[$key]['name'],
                      );
                    }
                  } else {
                    $purchase = ['status' => 'false', 'p_qty' => 0];
                  }

                  if ($item->ticket_available_type == 'limited') {
                    $stock = $item->ticket_available;
                  } else {
                    $stock = 99999999;
                  }

                  $item->ticket_stock = $stock;
                  $item->purchase_status = $purchase['status'];
                  $item->purchase_qty = $purchase['p_qty'];
                  $item->slot_seat_active = $item->slot_enable;
                  // removed redundant assignment
                  $item->seat_is_available = null;
                  $item->discountable_price_show = $discountable_price_show;
                  $item->total_price = $item->price;
                  $item->payable_price = $calculate_price;
                } else {

                  $de_varition_names = VariationContent::where(
                    [['ticket_id', $ticket->id]],
                  )->get();

                  if (Auth::guard('customer')->user()) {
                    if (count($de_varition_names) > 0) {
                      $purchase = isTicketPurchaseVenue(
                        $ticket->event_id,
                        $item->v_max_ticket_buy,
                        $ticket->id,
                        $de_varition_names[$key]['name'],
                      );
                    }
                  } else {
                    $purchase = ['status' => 'false', 'p_qty' => 0];
                  }

                  if ($item->ticket_available_type == 'limited') {
                    $stock = $item->ticket_available;
                  } else {
                    $stock = 99999999;
                  }

                  $item->ticket_stock = $stock;
                  $item->purchase_status = $purchase['status'];
                  $item->purchase_qty = $purchase['p_qty'];
                  $item->slot_seat_active = $item->slot_enable;
                  // removed redundant assignment
                  $item->seat_is_available = null;
                  $item->discountable_price_show = false;
                  $item->total_price = $item->price;
                  $item->payable_price = $item->price;
                }
              }

              $updatedVariations[] = $item;
            }
            $ticket->variations = $updatedVariations;
          } else {
            $ticket->variations = collect();
          }

          $ticket->ticket_stock = null;
          $ticket->slot_seat_active = null;
          $ticket->slot_unique_id = null;
          $ticket->seat_is_available = null;
          $ticket->discountable_price_show = 0.00;
          $ticket->total_price = 0.00;
          $ticket->payable_price = 0.00;
        } elseif ($ticket->pricing_type == 'free') {
          //free ticket
          if ($ticket->free_tickete_slot_enable == 1) {
            $slotBookService = new BookingServices();
            $slotItem = $slotBookService->showSlot($event_id, $ticket->id, $ticket->free_tickete_slot_unique_id);
            $slotPrice = $slotItem['price'];
            $calculate_price = 0.00;
            $discountable_price_show = false;

            if ($slotItem['available_seat'] == true) {
              $seat_is_available = 'available';
            } else {
              $is_slot = Slot::where(
                [
                  'slot_unique_id' => $ticket->free_tickete_slot_unique_id,
                  'event_id' => $event_id,
                  'ticket_id' => $ticket->id,
                ]
              )->first();
              if (!empty($is_slot)) {
                $seat_is_available = 'booked';
              } else {
                $seat_is_available = 'no_seat_found';
              }
            }

            $ticket->ticket_stock = null;
            $ticket->slot_seat_active = $ticket->free_tickete_slot_enable;
            $ticket->slot_unique_id = $ticket->free_tickete_slot_unique_id;
            $ticket->seat_is_available = $seat_is_available;
            $ticket->discountable_price_show = false;
            $ticket->total_price = 0.00;
            $ticket->payable_price = 0.00;
          } else {

            if ($ticket->ticket_available_type == 'limited') {
              $stock = $ticket->ticket_available;
            } else {
              $stock = 9999999;
            }

            $ticket->ticket_stock = $stock;
            $ticket->slot_seat_active = $ticket->free_tickete_slot_enable;
            $ticket->slot_unique_id = $ticket->free_tickete_slot_unique_id;
            $ticket->seat_is_available = null;
            $ticket->discountable_price_show = false;
            $ticket->total_price = 0.00;
            $ticket->payable_price = 0.00;
          }
          $ticket->variations = collect();
        }
      }
      return $ticket;
    });

    $information['tickets'] = $tickets;
    $information['inventory'] = $this->eventInventorySummaryService->summarizeEvent($content, $tickets);
    $information['waitlist'] = $this->eventWaitlistService->summaryForEvent($content, $viewerCustomer);
    $information['images'] = EventImage::where('event_id', $event_id)
      ->get()
      ->map(function ($data) {
        $data->image = asset('assets/admin/img/event-gallery/' . $data->image);
        return $data;
      });

    // Related events
    if ($content) {
      $related_events_data = EventContent::join('events', 'events.id', 'event_contents.event_id')
        ->where('event_contents.language_id', $language->id)
        ->where('event_contents.event_category_id', $content->event_category_id)
        ->where('events.id', '!=', $event_id)
        ->whereDate('events.end_date_time', '>=', $this->now_date_time)
        ->select('events.*', 'event_contents.title', 'event_contents.description', 'event_contents.slug', 'event_contents.city', 'event_contents.country')
        ->orderBy('events.id', 'desc')
        ->get();

      $related_events = $related_events_data->map(function ($event, $customer) {
        $event_date = $event->date_type == 'multiple' ? eventLatestDates($event->id) : null;

        $start_date = $event->date_type == 'multiple' ? @$event_date->start_date : $event->start_date;
        $start_time = $event->start_type == 'multiple' ? @$event_date->start_time : $event->start_time;

        // Organizer
        if ($event->organizer_id != null) {
          $organizer = Organizer::find($event->organizer_id);
          $organizer_name = $organizer ? $organizer->username : null;
        } else {
          $admin = Admin::first();
          $organizer_name = $admin->username;
        }

        if ($event->event_type == 'online') {
          $ticket = Ticket::where('event_id', $event->id)->orderBy('price', 'asc')->first();
          $start_price = $ticket->price;
        } else {
          $ticket = Ticket::where('event_id', $event->id)->whereNotNull('price')->orderBy('price', 'asc')->first();
          if (!$ticket) {
            $ticket = Ticket::where('event_id', $event->id)->whereNotNull('f_price')->orderBy('price', 'asc')->first();
            $start_price = $ticket->f_price;
          } else {
            $start_price = $ticket->price;
          }
        }

        $customer = Auth::guard('sanctum')->user();
        if (!empty($customer)) {
          $wishlist = Wishlist::where([['event_id', $event->id], ['customer_id', $customer->id]])->first();
        } else {
          $wishlist = null;
        }

        $dates = null;
        if ($event->date_type == 'multiple') {
          $dates = EventDates::where('event_id', $event->id)->get();
        }
        return [
          'id' => $event->id,
          'title' => $event->title,
          'thumbnail' => asset('assets/admin/img/event/thumbnail/' . $event->thumbnail),
          'address' => $event->address,
          'date' => $start_date,
          'time' => $start_time,
          'date_type' => $event->date_type,
          'duration' => $event->date_type == 'multiple' ? @$event_date->duration : $event->duration,
          'organizer' => $organizer_name,
          'event_type' => $event->event_type,
          'start_price' => $ticket->pricing_type == 'free' ? $ticket->pricing_type : $start_price,
          'wishlist' => !is_null($wishlist) ? 'yes' : 'no',
          'dates' => $dates,
        ];
      });
    } else {
      $related_events = [];
    }

    $information['related_events'] = $related_events;

    // Follower / Wishlist Logic
    $wishlist_count = Wishlist::where('event_id', $event_id)->count();
    $customer = Auth::guard('sanctum')->user();
    $is_wishlisted = false;
    if (!empty($customer)) {
      $wishlist_check = Wishlist::where([['event_id', $event_id], ['customer_id', $customer->id]])->first();
      $is_wishlisted = !is_null($wishlist_check);
    }
    $information['wishlist_count'] = $wishlist_count;
    $information['is_wishlisted'] = $is_wishlisted;
    $information['social'] = $this->eventSocialSummaryService->build($content, $customer);

    // Get active public rewards for this event (Social Proof)
    $information['rewards'] = \App\Models\EventRewardDefinition::where('event_id', $event_id)
      ->where('status', 'active')
      ->whereNull('exclusive_promoter_split_id')
      ->with('sponsorIdentity')
      ->get()
      ->map(function($reward) {
          return [
              'id' => $reward->id,
              'title' => $reward->title,
              'reward_type' => $reward->reward_type,
              'sponsor_name' => $reward->sponsorIdentity?->display_name ?? $reward->sponsorIdentity?->name,
              'sponsor_logo_url' => $reward->sponsorIdentity?->photo 
                  ? asset('assets/admin/img/admins/' . $reward->sponsorIdentity->photo) 
                  : null,
          ];
      });

    $currencyInfo = $this->getCurrencyInfo();
    $information['base_currency_symbol'] = $currencyInfo->base_currency_symbol;
    $information['base_currency_symbol_position'] = $currencyInfo->base_currency_symbol_position;
    $information['base_currency_text'] = $currencyInfo->base_currency_text;
    $information['base_currency_text_position'] = $currencyInfo->base_currency_text_position;
    $information['base_currency_rate'] = $currencyInfo->base_currency_rate;
    return response()->json([
      'success' => true,
      'data' => $information
    ]);
  }

  /* ******************************
   * Store event booking
   * ****************************/
  public function store_booking(Request $request)
  {
    $rules = [
      'fname' => 'required',
      'lname' => 'required',
      'email' => 'required',
      'phone' => 'required',
      'country' => 'required',
      'city' => 'nullable',
      'state' => 'nullable',
      'zip_code' => 'nullable',
      'address' => 'required',
      'event_id' => 'required',
      'gateway' => 'required',
      'gatewayType' => 'required',
      'quantity' => 'required',
      'selTickets' => 'nullable',
      'event_date' => 'required',
      'total' => 'required',
      'discount' => 'required',
      'tax' => 'required',
      'total_early_bird_dicount' => 'required',
      'customer_id' => 'nullable',
      'paymentStatus' => 'nullable',
      'fcm_token' => 'nullable',
      'apply_wallet_balance' => 'nullable|boolean',
      'apply_bonus_balance' => 'nullable|boolean',
      'stripe_payment_method_id' => 'nullable|string',
      'coupon_code' => 'nullable|string',
      'ticket_recipients' => 'nullable|array',
      'ticket_recipients.*.slot_key' => 'required_with:ticket_recipients|string',
      'ticket_recipients.*.ticket_id' => 'required_with:ticket_recipients|integer',
      'ticket_recipients.*.unit_index' => 'required_with:ticket_recipients|integer|min:1',
      'ticket_recipients.*.recipient_id' => 'required_with:ticket_recipients|integer',
    ];

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json([
        'status' => false,
        'validation_errors' => $validator->getMessageBag()->toArray()
      ]);
    }

    $customerResolution = $this->eventBookingGuardService->resolveAuthenticatedBookingCustomer($request);
    if ($customerResolution instanceof JsonResponse) {
      return $customerResolution;
    }
    $authCustomer = $customerResolution['authCustomer'];
    $recipientAssignments = $this->normalizeTicketRecipients(
      $request->input('ticket_recipients', [])
    );

    $recipientValidation = $this->validateTicketRecipients(
      $recipientAssignments,
      $authCustomer
    );
    if ($recipientValidation instanceof JsonResponse) {
      return $recipientValidation;
    }

    $event = \App\Models\Event::find($request->event_id);
    $dateWindowValidation = $this->eventBookingGuardService->validateEventDateWindow($event);
    if ($dateWindowValidation instanceof JsonResponse) {
      return $dateWindowValidation;
    }

    if ($event && $event->age_limit > 0) {
      if (empty($request->customer_id) || $request->customer_id == 'guest') {
        return response()->json([
          'status' => false,
          'message' => 'Login required for age restricted events',
          'error_type' => 'login_required'
        ], 403);
      }
      $customer = \App\Models\Customer::find($request->customer_id);
      if (!$customer || !$customer->date_of_birth) {
        return response()->json([
          'status' => false,
          'message' => 'Date of birth required',
          'error_type' => 'dob_required'
        ], 403);
      }
      if ($customer->age < $event->age_limit) {
        return response()->json([
          'status' => false,
          'message' => 'No cumples con la edad mínima para este evento.',
          'error_type' => 'age_restricted'
        ], 403);
      }
    }

    $ticketUnitSlots = $this->buildTicketUnitSlots(
      $event,
      is_array($request->selTickets) ? $request->selTickets : [],
      (int) $request->quantity
    );

    $recipientAssignments = $this->resolveTicketRecipientAssignments(
      $recipientAssignments,
      $ticketUnitSlots
    );
    if ($recipientAssignments instanceof JsonResponse) {
      return $recipientAssignments;
    }

    $ageValidation = $this->eventBookingGuardService->validateEventAgeRestriction($event, $authCustomer);
    if ($ageValidation instanceof JsonResponse) {
      return $ageValidation;
    }

    $purchaseLimitViolation = app(EventPurchaseLimitService::class)->validateSelection(
      $authCustomer,
      $event,
      is_array($request->selTickets) ? $request->selTickets : [],
      (int) $request->quantity,
      $recipientAssignments
    );
    if ($purchaseLimitViolation !== null) {
      return response()->json([
        'status' => $purchaseLimitViolation['status'] ?? false,
        'message' => $purchaseLimitViolation['message'] ?? 'No pudimos validar el límite de compra para esta selección.',
        'error_type' => $purchaseLimitViolation['error_type'] ?? 'purchase_limit_reached',
        'limit_context' => $purchaseLimitViolation['limit_context'] ?? null,
      ], (int) ($purchaseLimitViolation['status_code'] ?? 422));
    }

    $requestedGateway = Str::lower((string) $request->gateway);
    $applyWalletBalance = filter_var($request->input('apply_wallet_balance', false), FILTER_VALIDATE_BOOLEAN);
    $applyBonusBalance = filter_var($request->input('apply_bonus_balance', false), FILTER_VALIDATE_BOOLEAN);

    if (($requestedGateway === 'wallet' || $requestedGateway === 'bonus' || $applyWalletBalance || $applyBonusBalance || $requestedGateway === 'mixed') && !$authCustomer) {
      return response()->json([
        'status' => false,
        'message' => 'You must be logged in to use wallet or bonus balances.'
      ], 401);
    }

    $walletBalance = 0.0;
    $bonusBalance = 0.0;
    if ($authCustomer) {
      $walletBalance = (float) $this->walletService->getOrCreateWallet($authCustomer)->balance;
      $bonusBalance = (float) $this->bonusWalletService->getOrCreateWallet($authCustomer)->balance;
    }

    $fundingPlan = $this->checkoutFundingAllocatorService->allocate($request->total, [
      'gateway' => $requestedGateway,
      'wallet_balance' => $walletBalance,
      'bonus_balance' => $bonusBalance,
      'apply_wallet_balance' => $applyWalletBalance,
      'apply_bonus_balance' => $applyBonusBalance,
    ]);

    if ($requestedGateway === 'wallet' && !$fundingPlan['is_fully_covered']) {
      return response()->json([
        'status' => 'error',
        'message' => 'Insufficient wallet balance.'
      ], 400);
    }

    if ($requestedGateway === 'bonus' && !$fundingPlan['is_fully_covered']) {
      return response()->json([
        'status' => 'error',
        'message' => 'Insufficient bonus balance.'
      ], 400);
    }

    if (($applyWalletBalance || $applyBonusBalance || $requestedGateway === 'mixed') && $fundingPlan['requires_card'] && empty($request->stripe_payment_method_id)) {
      return response()->json([
        'status' => false,
        'message' => 'A saved card is required to complete the remaining balance.'
      ], 422);
    }

    if ($request['gatewayType'] == 'offline') {
      return response()->json([
        'status' => false,
        'message' => 'Offline payment is no longer supported. Stripe is the only available payment method.'
      ], 422);
    }

    $currencyInfo = $this->getCurrencyInfo();

    $total = $request->total;
    $discount = $request->discount;
    $total_early_bird_dicount = $request->total_early_bird_dicount;
    $tax_amount = $request->tax;
    $subtotal = (float) ($request->input('sub_total')
      ?? $request->input('subtotal')
      ?? $total);

    $primaryFeeBreakdown = $this->feeEngine->calculate(FeeEngine::OP_PRIMARY_TICKET_SALE, (float) $subtotal, [
      'fee_base_amount' => $total,
      'total_charge_amount' => $total,
      'currency' => $currencyInfo->base_currency_text,
    ]);
    $commission_amount = (float) ($primaryFeeBreakdown['fee_amount'] ?? 0);

    $paymentStatus = $request->paymentStatus;
    if (empty($paymentStatus)) {
      $paymentStatus = $request->gatewayType == 'online' ? 'completed' : 'pending';
    }

    $customerId = $authCustomer?->id ?? $request->customer_id;
    if (empty($customerId)) {
      $customerId = 'guest';
    }

    $arrData = array(
      'event_id' => $request->event_id,
      'currencyText' => $currencyInfo->base_currency_text,
      'currencyTextPosition' => $currencyInfo->base_currency_text_position,
      'currencySymbol' => $currencyInfo->base_currency_symbol,
      'currencySymbolPosition' => $currencyInfo->base_currency_symbol_position,
      'fname' => $request->fname,
      'lname' => $request->lname,
      'email' => $request->email,
      'phone' => $request->phone,
      'country' => $request->country,
      'state' => $request->state,
      'city' => $request->city,
      'zip_code' => $request->city,
      'address' => $request->address,
      'paymentMethod' => $request->gateway,
      'gatewayType' => Str::lower($request->gatewayType),
      'paymentStatus' => $paymentStatus,
      'event_date' => $request->event_date,
      'selTickets' => $request->selTickets,
      'attachmentFile' => isset($filename) ? $filename : null,
      'fcm_token' => $request->fcm_token,
      'price' => $total,
      'commission' => $commission_amount,
      'commission_percentage' => $primaryFeeBreakdown['percentage_value'] ?? null,
      'fee_policy_id' => $primaryFeeBreakdown['policy_id'] ?? null,
      'fee_policy_source' => $primaryFeeBreakdown['policy_source'] ?? null,
      'fee_charged_to' => $primaryFeeBreakdown['charged_to'] ?? null,
      'fee_base_amount' => $primaryFeeBreakdown['fee_base_amount'] ?? null,
      'quantity' => $request->quantity,
      'discount' => $discount,
      'total_early_bird_dicount' => $total_early_bird_dicount,
      'tax' => $tax_amount,
      'customer_id' => $customerId,
      'coupon_code' => $request->input('coupon_code'),
    );

    $bookingCollection = $this->storeData($arrData);
    if ($bookingCollection->isEmpty()) {
      return response()->json([
        'status' => false,
        'message' => 'No pudimos crear la reserva con la selección actual.',
      ], 422);
    }

    $paymentCapture = [];
    $requiresFundingCapture = (float) ($fundingPlan['wallet_amount'] ?? 0) > 0
      || (float) ($fundingPlan['bonus_amount'] ?? 0) > 0
      || (float) ($fundingPlan['card_amount'] ?? 0) > 0
      || (float) ($fundingPlan['card_total_charge'] ?? 0) > 0;

    if ($bookingCollection->isNotEmpty() && $request->gatewayType == 'online' && $paymentStatus == 'completed' && $authCustomer && $requiresFundingCapture) {
      try {
        $paymentCapture = $this->bookingFundingService->captureForBookings(
          $authCustomer,
          $bookingCollection,
          $fundingPlan,
          $request->input('stripe_payment_method_id'),
          (string) $currencyInfo->base_currency_text
        );
      } catch (\Exception $e) {
        foreach ($bookingCollection as $bookingInfo) {
          $bookingInfo->delete();
        }

        return response()->json([
          'status' => 'error',
          'message' => 'Payment failed: ' . $e->getMessage()
        ], 400);
      }
    }

    if ($bookingCollection->isNotEmpty()) {
      $ticket = DB::table('basic_settings')->select('how_ticket_will_be_send')->first();

      if ($ticket->how_ticket_will_be_send == 'instant') {
        // generate an invoice in pdf format
        $booking_controller = new BookingController();
        // Pass the entire collection to generateInvoice
        $invoice = $booking_controller->generateInvoice($bookingCollection, $firstBooking->event_id);

        //unlink qr code
        foreach ($bookingCollection as $bookingInfo) {
          if (!is_null($bookingInfo->variation)) {
            //generate qr code for without wise ticket
            $variations = json_decode($bookingInfo->variation, true);
            foreach ($variations as $variation) {
              @unlink(public_path('assets/admin/qrcodes/') . $bookingInfo->booking_id . '__' . $variation['unique_id'] . '.svg');
            }
          } else {
            //generate qr code for without wise ticket
            // Since quantity is always 1 per booking now
            for ($i = 1; $i <= $bookingInfo->quantity; $i++) {
              @unlink(public_path('assets/admin/qrcodes/') . $bookingInfo->booking_id . '__' . $i . '.svg');
            }
          }
          // update invoice for each booking (they share the same file)
          $bookingInfo->invoice = $invoice;
          $bookingInfo->save();
        }

        // send a mail to the customer with the invoice (Unified)
        $booking_controller->sendMail($bookingCollection);
      } else {
        // Delayed invoice - dispatch for each? or handle unified later?
        // For now, let's dispatch for each to be safe, though it might send multiple emails if not refactored.
        // Ideally BookingInvoiceJob should be updated too, but let's stick to 'instant' flow correctness first as it seems to be the default/preferred.
        foreach ($bookingCollection as $bookingInfo) {
          BookingInvoiceJob::dispatch($bookingInfo->id)->delay(now()->addSeconds(10));
        }
      }

      //earning revenue & transaction
      foreach ($bookingCollection as $bookingInfo) {
        $this->earning_revenue($bookingInfo);

        if ((string) $bookingInfo->paymentStatus !== '1' && strtolower((string) $bookingInfo->paymentStatus) !== 'completed') {
          $bookingInfo->paymentStatus = 1;
          $bookingInfo->save();
        }

        $transactionPayload = array_merge(
          $bookingInfo->toArray(),
          [
            'paymentStatus' => 1,
            'transcation_type' => 1,
            'fee_policy_id' => $primaryFeeBreakdown['policy_id'] ?? null,
            'fee_policy_source' => $primaryFeeBreakdown['policy_source'] ?? null,
            'fee_charged_to' => $primaryFeeBreakdown['charged_to'] ?? null,
            'fee_base_amount' => $primaryFeeBreakdown['fee_base_amount'] ?? null,
          ]
        );

        storeTranscation($transactionPayload);

        // Store settlement in the active professional owner wallet.
        if (bookingHasProfessionalOwner($bookingInfo)) {
          storeProfessionalOwner($bookingInfo);
        }
      }
    }

    $giftTransfersCreated = 0;
    if ($authCustomer && !$bookingCollection->isEmpty() && !empty($recipientAssignments)) {
      $giftTransfersCreated = $this->createAssignedTicketTransfers(
        $bookingCollection,
        $ticketUnitSlots,
        $recipientAssignments,
        $authCustomer
      );
    }

    foreach ($bookingCollection as $bookingInfo) {
      $this->ticketJourneyService->record($bookingInfo, 'primary_purchase', [
        'actor_customer_id' => $authCustomer?->id ?? (is_numeric((string) $customerId) ? (int) $customerId : null),
        'target_customer_id' => is_numeric((string) ($bookingInfo->customer_id ?? null))
          ? (int) $bookingInfo->customer_id
          : null,
        'price' => (float) ($bookingInfo->price ?? 0),
        'metadata' => [
          'payment_method' => $fundingPlan['payment_method'] ?? null,
          'payment_mode' => $fundingPlan['mode'] ?? null,
          'payment_status' => $bookingInfo->paymentStatus,
          'coupon_code' => $bookingInfo->coupon_code ?? null,
          'acquisition_source' => $bookingInfo->acquisition_source ?? 'primary_purchase',
        ],
      ]);
    }

    // Use the first booking for general info, but pass the whole collection for invoice/mail.
    $firstBooking = $bookingCollection->first();

    //send notification
    if ($customerId !== 'guest') {
      $user = \App\Models\User::find($customerId) ?: $authCustomer;
      $this->notificationService->notifyUser(
        $user,
        __('Ticket Purchase Successful'),
        'You have successfully purchased tickets for ' . ($firstBooking->evnt->title ?? 'an event') . '. View your tickets in the app.'
      );
    }

    // Pass info back - maybe just the first one or a summary
    $bookingInfo = $firstBooking;

    if (!empty($bookingInfo->invoice)) {
      $bookingInfo->invoice = asset('assets/admin/file/invoices/' . $bookingInfo->invoice);
    }

    if ($authCustomer && in_array(strtolower((string) $paymentStatus), ['completed', 'free'], true)) {
      app(\App\Services\LoyaltyService::class)->awardFromRule(
        $authCustomer,
        'event_purchase',
        'booking_order',
        (string) ($firstBooking->order_number ?: $firstBooking->booking_id ?: $firstBooking->id),
        [
          'event_id' => (int) $firstBooking->event_id,
          'booking_id' => (int) $firstBooking->id,
          'gateway' => (string) $fundingPlan['mode'],
        ]
      );
    }

    try {
      app(\App\Services\EventTicketRewardService::class)->issueForBookings($bookingCollection);
    } catch (\Throwable $exception) {
      Log::warning('Event ticket rewards could not be issued after checkout.', [
        'event_id' => $firstBooking?->event_id,
        'booking_ids' => $bookingCollection->pluck('id')->all(),
        'message' => $exception->getMessage(),
      ]);
    }

    $eventModel = $bookingInfo->relationLoaded('evnt') ? $bookingInfo->evnt : $bookingInfo->evnt()->first();
    $bookingInfoArray = $bookingInfo->toArray();
    $bookingInfoArray['organizer_name'] = $bookingInfo->organizer_name ?? null;
    $bookingInfoArray['event_title'] = $bookingInfo->event_title ?? ($eventModel->title ?? null);
    $bookingInfoArray['thumbnail'] = $bookingInfo->thumbnail
      ?? (!empty($eventModel?->thumbnail) ? asset('assets/admin/img/event/thumbnail/' . $eventModel->thumbnail) : null);
    $bookingInfoArray['venue_name'] = $bookingInfo->venue_name ?? ($eventModel->venue_name_snapshot ?? null);
    $bookingInfoArray['event_end_date'] = $bookingInfo->event_end_date ?? ($eventModel->end_date_time ?? null);
    $bookingInfoArray['total'] = $bookingInfo->total ?? 0;
    $bookingInfoArray['total_paid'] = $bookingInfo->total_paid
      ?? number_format((float) ($bookingInfo->price ?? 0), 2, '.', '');
    if (isset($bookingInfo->invoice)) {
        $bookingInfoArray['invoice'] = $bookingInfo->invoice;
    }

    return response()->json([
      'status' => true,
      'message' => 'Booking created successfully',
      'booking_info' => $bookingInfoArray,
      'payment_summary' => array_merge($fundingPlan, $paymentCapture),
      'gift_transfers_created' => $giftTransfersCreated,
    ]);

  }

  private function normalizeTicketRecipients($rawAssignments): array
  {
    if (!is_array($rawAssignments)) {
      return [];
    }

    $normalized = [];
    foreach ($rawAssignments as $assignment) {
      if (!is_array($assignment)) {
        continue;
      }

      $slotKey = trim((string) ($assignment['slot_key'] ?? ''));
      $recipientId = (int) ($assignment['recipient_id'] ?? 0);
      $ticketId = (int) ($assignment['ticket_id'] ?? 0);
      $unitIndex = (int) ($assignment['unit_index'] ?? 0);

      if ($slotKey === '' || $recipientId <= 0 || $ticketId <= 0 || $unitIndex <= 0) {
        continue;
      }

      $normalized[$slotKey] = [
        'slot_key' => $slotKey,
        'recipient_id' => $recipientId,
        'ticket_id' => $ticketId,
        'unit_index' => $unitIndex,
      ];
    }

    return $normalized;
  }

  private function validateTicketRecipients(array $recipientAssignments, ?Customer $buyer): ?JsonResponse
  {
    if (empty($recipientAssignments)) {
      return null;
    }

    if (!$buyer) {
      return response()->json([
        'status' => false,
        'message' => 'You must be logged in to assign tickets to another user.',
      ], 401);
    }

    $recipientIds = collect($recipientAssignments)
      ->pluck('recipient_id')
      ->map(fn ($id) => (int) $id)
      ->filter(fn ($id) => $id > 0)
      ->unique()
      ->values();

    if ($recipientIds->contains((int) $buyer->id)) {
      return response()->json([
        'status' => false,
        'message' => 'You cannot assign an extra ticket to your own account.',
      ], 422);
    }

    $existingRecipients = Customer::whereIn('id', $recipientIds->all())
      ->pluck('id')
      ->map(fn ($id) => (int) $id)
      ->all();

    $missingRecipients = $recipientIds
      ->reject(fn ($id) => in_array((int) $id, $existingRecipients, true))
      ->values();

    if ($missingRecipients->isNotEmpty()) {
      return response()->json([
        'status' => false,
        'message' => 'One or more selected recipients are no longer available.',
      ], 422);
    }

    return null;
  }

  private function buildTicketUnitSlots(?Event $event, array $variationsData, int $totalQuantity): array
  {
    $slots = [];

    if (empty($variationsData)) {
      $defaultTicketId = (int) optional($event?->ticket()->first())->id;
      for ($unitIndex = 1; $unitIndex <= $totalQuantity; $unitIndex++) {
        $slots[] = [
          'slot_key' => $defaultTicketId > 0 ? $defaultTicketId . ':' . $unitIndex : 'default:' . $unitIndex,
          'ticket_id' => $defaultTicketId,
          'unit_index' => $unitIndex,
        ];
      }

      return $slots;
    }

    $selectionCountsByTicket = [];
    foreach ($variationsData as $variation) {
      if (!is_array($variation)) {
        continue;
      }

      $ticketId = (int) ($variation['ticket_id'] ?? 0);
      $qty = max(0, (int) ($variation['qty'] ?? 0));
      if ($ticketId <= 0 || $qty <= 0) {
        continue;
      }

      $selectionCountsByTicket[$ticketId] = ($selectionCountsByTicket[$ticketId] ?? 0) + 1;
    }

    $selectionIndex = 0;
    foreach ($variationsData as $variation) {
      if (!is_array($variation)) {
        continue;
      }

      $ticketId = (int) ($variation['ticket_id'] ?? 0);
      $qty = max(0, (int) ($variation['qty'] ?? 0));
      if ($ticketId <= 0 || $qty <= 0) {
        continue;
      }

      $selectionIndex++;
      $requiresScopedSlotKey = ($selectionCountsByTicket[$ticketId] ?? 0) > 1
        || trim((string) ($variation['name'] ?? '')) !== '';
      $variationName = isset($variation['name']) ? trim((string) $variation['name']) : null;

      for ($unitIndex = 1; $unitIndex <= $qty; $unitIndex++) {
        $legacySlotKey = $ticketId . ':' . $unitIndex;
        $slots[] = [
          'slot_key' => $requiresScopedSlotKey
            ? $ticketId . ':' . $selectionIndex . ':' . $unitIndex
            : $legacySlotKey,
          'legacy_slot_key' => $legacySlotKey,
          'ticket_id' => $ticketId,
          'unit_index' => $unitIndex,
          'selection_index' => $selectionIndex,
          'variation_name' => $variationName,
        ];
      }
    }

    return $slots;
  }

  private function resolveTicketRecipientAssignments(array $recipientAssignments, array $ticketUnitSlots): array|JsonResponse
  {
    if (empty($recipientAssignments)) {
      return [];
    }

    $slotByKey = [];
    $slotsByLegacyKey = [];
    foreach ($ticketUnitSlots as $slot) {
      $slotByKey[$slot['slot_key']] = $slot;

      $legacySlotKey = trim((string) ($slot['legacy_slot_key'] ?? $slot['slot_key'] ?? ''));
      if ($legacySlotKey !== '') {
        $slotsByLegacyKey[$legacySlotKey][] = $slot;
      }
    }

    $resolved = [];
    foreach ($recipientAssignments as $assignment) {
      if (!is_array($assignment)) {
        continue;
      }

      $requestedSlotKey = trim((string) ($assignment['slot_key'] ?? ''));
      if ($requestedSlotKey === '') {
        continue;
      }

      $resolvedSlot = $slotByKey[$requestedSlotKey] ?? null;
      if (!$resolvedSlot) {
        $legacyMatches = $slotsByLegacyKey[$requestedSlotKey] ?? [];
        if (count($legacyMatches) > 1) {
          return response()->json([
            'status' => false,
            'message' => 'One or more ticket recipient assignments are ambiguous for mixed ticket variations. Refresh checkout and assign the recipient again.',
            'error_type' => 'ticket_recipient_assignment_ambiguous',
          ], 422);
        }

        $resolvedSlot = $legacyMatches[0] ?? null;
      }

      if (!$resolvedSlot) {
        return response()->json([
          'status' => false,
          'message' => 'One or more ticket recipient assignments no longer match the current ticket selection.',
          'error_type' => 'ticket_recipient_assignment_invalid',
        ], 422);
      }

      if (
        (int) ($assignment['ticket_id'] ?? 0) > 0
        && (int) $assignment['ticket_id'] !== (int) ($resolvedSlot['ticket_id'] ?? 0)
      ) {
        return response()->json([
          'status' => false,
          'message' => 'One or more ticket recipient assignments no longer match the current ticket selection.',
          'error_type' => 'ticket_recipient_assignment_invalid',
        ], 422);
      }

      if (
        (int) ($assignment['unit_index'] ?? 0) > 0
        && (int) $assignment['unit_index'] !== (int) ($resolvedSlot['unit_index'] ?? 0)
      ) {
        return response()->json([
          'status' => false,
          'message' => 'One or more ticket recipient assignments no longer match the current ticket selection.',
          'error_type' => 'ticket_recipient_assignment_invalid',
        ], 422);
      }

      $resolvedSlotKey = (string) $resolvedSlot['slot_key'];
      if (isset($resolved[$resolvedSlotKey])) {
        return response()->json([
          'status' => false,
          'message' => 'A ticket unit can only be assigned to one recipient.',
          'error_type' => 'ticket_recipient_assignment_duplicate',
        ], 422);
      }

      $resolved[$resolvedSlotKey] = [
        'slot_key' => $resolvedSlotKey,
        'recipient_id' => (int) $assignment['recipient_id'],
        'ticket_id' => (int) $resolvedSlot['ticket_id'],
        'unit_index' => (int) $resolvedSlot['unit_index'],
      ];
    }

    return $resolved;
  }

  private function createAssignedTicketTransfers($bookingCollection, array $ticketUnitSlots, array $recipientAssignments, Customer $buyer): int
  {
    $createdTransfers = 0;
    $recipients = Customer::whereIn(
      'id',
      collect($recipientAssignments)->pluck('recipient_id')->unique()->all()
    )->get()->keyBy('id');

    $bookings = $bookingCollection->values();
    foreach ($bookings as $index => $booking) {
      $slot = $ticketUnitSlots[$index] ?? null;
      if (!$slot) {
        continue;
      }

      $assignment = $recipientAssignments[$slot['slot_key']] ?? null;
      if (!$assignment) {
        continue;
      }

      $recipient = $recipients->get((int) $assignment['recipient_id']);
      if (!$recipient || (int) $recipient->id === (int) $buyer->id) {
        continue;
      }

      if ((int) ($booking->is_transferable ?? 1) !== 1) {
        continue;
      }

      if (TicketTransfer::where('booking_id', $booking->id)->where('status', 'pending')->exists()) {
        continue;
      }

      $transfer = TicketTransfer::create([
        'booking_id' => $booking->id,
        'from_customer_id' => $buyer->id,
        'to_customer_id' => $recipient->id,
        'status' => 'pending',
        'flow' => 'owner_offer',
        'notes' => 'Created automatically after checkout gift assignment.',
      ]);

      $booking->transfer_status = 'transfer_pending';
      $booking->save();

      $this->ticketJourneyService->record($booking, 'gift_transfer_pending', [
        'actor_customer_id' => (int) $buyer->id,
        'target_customer_id' => (int) $recipient->id,
        'transfer_id' => (int) $transfer->id,
        'metadata' => [
          'flow' => 'owner_offer',
          'notes' => 'Created automatically after checkout gift assignment.',
        ],
      ]);

      $eventTitle = optional($booking->evnt)->title ?: 'an event';
      $buyerName = trim(($buyer->fname ?? '') . ' ' . ($buyer->lname ?? ''));
      $senderLabel = $buyerName !== '' ? $buyerName : ($buyer->username ?? 'Someone');

      $this->notificationService->notifyUser(
        $recipient,
        __('Ticket waiting for you'),
        $senderLabel . ' bought a ticket for ' . $eventTitle . ' and sent it to your Transfer Inbox.',
        [
          'type' => 'ticket_transfer',
          'transfer_id' => $transfer->id,
          'booking_id' => $booking->id,
          'direction' => 'incoming',
        ]
      );

      $createdTransfers++;
    }

    return $createdTransfers;
  }

  private function storeData($info)
  {
    try {
      $event = Event::find($info['event_id']);
      if ($event) {
        if ($event->organizer_id) {
          $organizer_id = $event->organizer_id;
        } else {
          $organizer_id = null;
        }
      }

      // Generate common Order ID
      $orderNumber = uniqid();

      $totalQuantity = $info['quantity'];
      $bookings = collect();

      // Variations Logic Check - We need to split variations too if multiple
      // But usually variations are selected per ticket type.
      // If user selected: Ticket A (qty 2), Ticket B (qty 1).
      // Logic:
      // $info['selTickets'] contains the list of variations.
      // We should iterate over selTickets and create a booking for EACH unit.

      $variationsData = $info['selTickets'] ?? [];

      // If no variations (simple ticket), we use totalQuantity
      if (empty($variationsData)) {
        // Simple Ticket Loop
        for ($i = 0; $i < $totalQuantity; $i++) {
          $bookings->push($this->createSingleBooking($info, $organizer_id, $event, $orderNumber, null));
        }
      } else {
        // Variations Loop
        // selTickets = [{ticket_id: 1, qty: 2}, {ticket_id: 2, qty: 1}]
        foreach ($variationsData as $variation) {
          $qty = $variation['qty'];
          for ($j = 0; $j < $qty; $j++) {
            // Create a modified variation array for just this single unit
            $singleVariation = $variation;
            $singleVariation['qty'] = 1;
            $singleVariation['early_bird_dicount'] = $variation['early_bird_dicount'] / $qty; // Split discount?
            // No, early_bird_discount in variation is unit? or total? 
            // Usually it is unit discount in ticket config, but total in calculation?
            // Let's assume we handle price splitting in createSingleBooking

            // Actually, createSingleBooking calculates price based on input.
            // We need to pass the Specific Variation for this booking.
            $bookings->push($this->createSingleBooking($info, $organizer_id, $event, $orderNumber, [$singleVariation]));
          }
        }
      }

      return $bookings;
    } catch (\Exception $e) {
      // Log error
      return collect();
    }
  }

  private function createSingleBooking($info, $organizer_id, $event, $orderNumber, $specificVariation = null)
  {
    $totalQty = $info['quantity']; // Total order quantity

    // If specific variation is passed, use it. Otherwise use info['variation'] logic (which was bulk)
    // But we want to isolate.

    // Calculate Unit Values
    $unitPrice = $info['price'] / $totalQty;
    $unitTax = $info['tax'] / $totalQty;
    $unitCommission = $info['commission'] / $totalQty;
    $unitDiscount = $info['discount'] / $totalQty;
    $unitEarlyBird = $info['total_early_bird_dicount'] / $totalQty;

    // Handle Variations / Ticket Stock Update
    $variationsJson = null;
    $ticketId = null;
    if (!empty($specificVariation)) {
      // Logic to update stock for this single variation unit
      // Copied and adapted from original storeData stock logic
      $this->updateStock($specificVariation, $event);

      // Prepare variation JSON for this booking (qty 1)
      // We need to generate unique IDs for slots/seats if applicable
      $variationsJson = $this->processVariationsForBooking($specificVariation);
      $ticketId = (int) ($specificVariation[0]['ticket_id'] ?? 0) ?: null;
    } else {
      // Simple ticket stock update
      $ticket = $event->ticket()->first();
      if ($ticket) {
        $ticketId = (int) $ticket->id;
        $ticket->ticket_available = $ticket->ticket_available - 1;
        $ticket->save();
      }
    }

    $basic = Basic::where('uniqid', 12345)->select('tax', 'commission')->first();

    $resolvedTicket = null;
    if ($ticketId) {
      $resolvedTicket = Ticket::find($ticketId);
    }

    $payload = [
      'customer_id' => array_key_exists('customer_id', $info) ? $info['customer_id'] : null,
      'booking_id' => uniqid(),
      'order_number' => $orderNumber,
      'fname' => $info['fname'],
      'lname' => $info['lname'],
      'email' => $info['email'],
      'phone' => $info['phone'],
      'country' => $info['country'],
      'state' => $info['state'],
      'city' => $info['city'],
      'zip_code' => $info['zip_code'],
      'address' => $info['address'],
      'event_id' => $info['event_id'],
      'organizer_id' => $organizer_id,
      'variation' => $variationsJson,
      'price' => round($unitPrice, 2),
      'tax' => round($unitTax, 2),
      'commission' => round($unitCommission, 2),
      'tax_percentage' => $basic->tax,
      'commission_percentage' => array_key_exists('commission_percentage', $info)
        ? (float) ($info['commission_percentage'] ?? 0)
        : (float) ($basic->commission ?? 0),
      'quantity' => 1, // Always 1
      'discount' => round($unitDiscount, 2),
      'early_bird_discount' => round($unitEarlyBird, 2),
      'currencyText' => $info['currencyText'],
      'currencyTextPosition' => $info['currencyTextPosition'],
      'currencySymbol' => $info['currencySymbol'],
      'currencySymbolPosition' => $info['currencySymbolPosition'],
      'paymentMethod' => $info['paymentMethod'],
      'gatewayType' => $info['gatewayType'],
      'paymentStatus' => $info['paymentStatus'],
      'invoice' => array_key_exists('invoice', $info) ? $info['invoice'] : null,
      'attachmentFile' => array_key_exists('attachmentFile', $info) ? $info['attachmentFile'] : null,
      'event_date' => $info['event_date'],
      'conversation_id' => array_key_exists('conversation_id', $info) ? $info['conversation_id'] : null,
      'fcm_token' => array_key_exists('fcm_token', $info) ? $info['fcm_token'] : null,
      'fee_policy_id' => array_key_exists('fee_policy_id', $info) ? $info['fee_policy_id'] : null,
      'fee_policy_source' => array_key_exists('fee_policy_source', $info) ? $info['fee_policy_source'] : null,
      'fee_charged_to' => array_key_exists('fee_charged_to', $info) ? $info['fee_charged_to'] : null,
      'fee_base_amount' => array_key_exists('fee_base_amount', $info) ? $info['fee_base_amount'] : null,
    ];

    if (Schema::hasColumn('bookings', 'ticket_id')) {
      $payload['ticket_id'] = $ticketId;
    }
    if (Schema::hasColumn('bookings', 'organizer_identity_id')) {
      $payload['organizer_identity_id'] = $event?->owner_identity_id;
    }

    $restrictionPayload = $this->resolveResaleRestrictionPayload($info, $resolvedTicket);
    if (Schema::hasColumn('bookings', 'is_resellable')) {
      $payload['is_resellable'] = $restrictionPayload['is_resellable'];
    }
    if (Schema::hasColumn('bookings', 'resale_restriction_reason')) {
      $payload['resale_restriction_reason'] = $restrictionPayload['resale_restriction_reason'];
    }
    if (Schema::hasColumn('bookings', 'acquisition_source')) {
      $payload['acquisition_source'] = $restrictionPayload['acquisition_source'];
    }
    if (Schema::hasColumn('bookings', 'coupon_code')) {
      $payload['coupon_code'] = $restrictionPayload['coupon_code'];
    }

    return Booking::create($payload);
  }

  private function resolveResaleRestrictionPayload(array $info, ?Ticket $ticket): array
  {
    $couponCode = trim((string) ($info['coupon_code'] ?? ''));
    $usesPromotionalCoupon = $couponCode !== '';
    $allowPromotionalResale = true;

    if ($usesPromotionalCoupon && $ticket && Schema::hasColumn($ticket->getTable(), 'allow_promotional_resale')) {
      $allowPromotionalResale = (bool) ($ticket->allow_promotional_resale ?? true);
    }

    return [
      'is_resellable' => $usesPromotionalCoupon ? $allowPromotionalResale : true,
      'resale_restriction_reason' => $usesPromotionalCoupon && !$allowPromotionalResale
        ? 'promotional_restriction'
        : null,
      'acquisition_source' => $usesPromotionalCoupon
        ? 'promotional_coupon'
        : 'primary_purchase',
      'coupon_code' => $couponCode !== '' ? $couponCode : null,
    ];
  }

  private function updateStock($variations, $event)
  {
    $depletedTicketIds = [];

    foreach ($variations as $variation) {
      $ticket = Ticket::where('id', $variation['ticket_id'])->first();
      if ($ticket->pricing_type == 'normal' && $ticket->ticket_available_type == 'limited') {
        if ($ticket->ticket_available - $variation['qty'] >= 0) {
          $ticket->ticket_available = $ticket->ticket_available - $variation['qty'];
          $ticket->save();

          if ((int) $ticket->ticket_available <= 0) {
            $depletedTicketIds[] = (int) $ticket->id;
          }
        }
      } elseif ($ticket->pricing_type == 'variation') {
        $ticket_variations = json_decode($ticket->variations, true);
        $update_variation = [];
        foreach ($ticket_variations as $ticket_variation) {
          if ($ticket_variation['name'] == $variation['name']) {
            if ($ticket_variation['ticket_available_type'] == 'limited') {
              $ticket_available = intval($ticket_variation['ticket_available']) - intval($variation['qty']);
            } else {
              $ticket_available = $ticket_variation['ticket_available'];
            }
            $update_variation[] = array_merge($ticket_variation, ['ticket_available' => $ticket_available]);
          } else {
            $update_variation[] = $ticket_variation;
          }
        }
        $ticket->variations = json_encode($update_variation, true);
        $ticket->save();
      } elseif ($ticket->pricing_type == 'free' && $ticket->ticket_available_type == 'limited') {
        if ($ticket->ticket_available - $variation['qty'] >= 0) {
          $ticket->ticket_available = $ticket->ticket_available - $variation['qty'];
          $ticket->save();

          if ((int) $ticket->ticket_available <= 0) {
            $depletedTicketIds[] = (int) $ticket->id;
          }
        }
      }
    }

    // Auto-activate any tickets gated behind a now-depleted ticket.
    if (!empty($depletedTicketIds)) {
      $this->activateGatedTickets($depletedTicketIds);
    }
  }

  /**
   * When a gating ticket sells out, activate all tickets that depend on it.
   */
  private function activateGatedTickets(array $sourceTicketIds): void
  {
    $activated = Ticket::whereIn('gate_ticket_id', $sourceTicketIds)
      ->where('sale_status', 'paused')
      ->update(['sale_status' => 'active']);

    if ($activated > 0) {
      \Illuminate\Support\Facades\Log::info('Ticket gates opened.', [
        'source_ticket_ids' => $sourceTicketIds,
        'tickets_activated' => $activated,
      ]);
    }
  }

  private function processVariationsForBooking($variations)
  {
    $c_variations = [];
    foreach ($variations as $variation) {
      // Since qty is 1, loop runs once
      for ($i = 1; $i <= $variation['qty']; $i++) {
        $item = [
          'ticket_id' => $variation['ticket_id'],
          'early_bird_dicount' => $variation['early_bird_dicount'], // Already unit based? Or need split? Assuming unit.
          'name' => $variation['name'],
          'qty' => 1,
          'price' => $variation['price'],
          'scan_status' => 0,
          'unique_id' => uniqid(),
        ];
        // Add seat/slot info if exists
        if (isset($variation['seat_id']))
          $item['seat_id'] = $variation['seat_id'];
        if (isset($variation['seat_name']))
          $item['seat_name'] = $variation['seat_name'];
        if (isset($variation['slot_id']))
          $item['slot_id'] = $variation['slot_id'];
        if (isset($variation['slot_name']))
          $item['slot_name'] = $variation['slot_name'];
        if (isset($variation['slot_unique_id']))
          $item['slot_unique_id'] = $variation['slot_unique_id'];

        $c_variations[] = $item;
      }
    }
    return json_encode($c_variations, true);
  }
  public function categories(Request $request)
  {
    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first() : Language::where('is_default', 1)->first();
    $information['categories'] = EventCategory::where('language_id', $language->id)
      ->where('status', 1)
      ->orderBy('serial_number', 'asc')
      ->get()->map(function ($category) {
        $category->image = asset('assets/admin/img/event-category/' . $category->image);
        return $category;
      });

    return response()->json([
      'success' => true,
      'data' => $information
    ]);
  }

  public function slotMapping(Request $request)
  {

    $event_id = $request->event_id;
    $ticket_id = $request->ticket_id;
    $slot_unique_id = $request->slot_unique_id;


    if (empty($event_id) || empty($ticket_id) || empty($slot_unique_id)) {
      return response()->json([
        'success' => false,
        'message' => 'incorrect url'
      ], 401);
    }


    // removed redundant assignments

    $ticket = Ticket::find($ticket_id);
    $seatMappingImage = SlotImage::where([
      'event_id' => $event_id,
      'ticket_id' => $ticket_id,
      'slot_unique_id' => $slot_unique_id,
    ])->first();

    if (!$seatMappingImage) {
      return response()->json([
        'success' => false,
        'message' => "No Seat Available",
        'slots' => [],
      ]);
    }
    $bookedTicketData = app(\App\Services\BookingServices::class)->getBookingDeactiveData($event_id);

    $data['slot_image'] = !empty($seatMappingImage->image) ? asset('assets/admin/img/map-image/' . $seatMappingImage->image) : "";
    $data['pricing_type'] = $ticket->pricing_type;

    $slots = Slot::where([
      'event_id' => $event_id,
      'ticket_id' => $ticket_id,
      'slot_unique_id' => $slot_unique_id,
    ])->with('seats')->get();

    $allSlots = $slots->map(function ($slot) use ($bookedTicketData, $ticket) {

      $obj = new stdClass();
      $obj->id = $slot->id;
      $obj->event_id = $slot->event_id;
      $obj->ticket_id = $slot->ticket_id;
      $obj->slot_name = $slot->name;
      $obj->slot_type = $slot->type;
      $obj->slot_unique_id = $slot->slot_unique_id;
      $obj->slot_pos_x = $slot->pos_x;
      $obj->slot_pos_y = $slot->pos_y;
      $obj->slot_width = $slot->width;
      $obj->slot_height = $slot->height;
      $obj->slot_round = $slot->round;
      $obj->slot_rotate = $slot->rotate;
      $obj->slot_background_color = $slot->background_color;
      $obj->slot_border_color = $slot->border_color;
      $obj->slot_font_size = $slot->font_size;


      $thisSlotSeats = $slot->filtered_seats->each(function ($item) use ($ticket, $slot, $bookedTicketData) {

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
        $check_booked = $item->is_deactive;
        //when check is_booked
        if ($check_booked == 0) {
          $check_booked = in_array($item->id, $bookedTicketData['seat_ids']) ? 1 : 0;
        }
        $item->is_booked = $check_booked;
        return $item;
      });

      $obj->seats = $thisSlotSeats;

      $check_booked = $slot->is_deactive;
      if ($check_booked == 0) {
        if ($slot->type == 2) {
          $check_booked = in_array($slot->id, $bookedTicketData['slot_ids']) ? 1 : 0;
        } else {
          $activeSeatCount = $slot->seats->where('is_deactive', 0)->count();
          $bookedSeatCount = $slot->seats->where('is_booked', 1)->count();
          $check_booked = $activeSeatCount <= $bookedSeatCount ? 1 : 0;
        }
      }
      $obj->is_booked = $check_booked;
      return $obj;
    });


    $data['slots'] = $allSlots;

    return response()->json([
      'success' => true,
      'data' => $data,
    ]);
  }

  public function checkout2($data)
  {
    $data = new Fluent($data);
    $basic = Basic::select('event_guest_checkout_status')->first();
    $event_guest_checkout_status = $basic->event_guest_checkout_status;
    if ($event_guest_checkout_status != 1) {
      if (Auth::guard('sanctum')->check() == false) {
        $information['success'] = false;
        $information['message'] = "login Required";
        return $information;
      }
    }

    $selected_seats = !empty($data->seatData) ? $data->seatData : [];

    $selected_slot_seat = collect($selected_seats)
      ->groupBy('slot_id')
      ->map(function ($group) {
        $first = $group->first();
        return [
          'slot_id' => $first['slot_id'],
          'slot_name' => $first['slot_name'],
          'event_id' => $first['event_id'],
          'ticket_id' => $first['ticket_id'],
          'slot_unique_id' => $first['slot_unique_id'],
          'slot_type' => $first['s_type'],
          'seats' => collect($group)->map(function ($seat) {
            return [
              'seat_id' => $seat['id'],
              'seat_name' => $seat['name'],
              'discount' => $seat['discount'],
              'price' => $seat['price'],
              'payable_price' => $seat['payable_price'],
            ];
          })->values()->toArray(),
        ];
      })
      ->map(function ($slot) {
        // count and sum for each slot
        $slot['seat_count'] = count($slot['seats']);
        $slot['seats_price'] = collect($slot['seats'])->sum('payable_price');
        return $slot;
      })
      ->values()
      ->toArray();

    $select = false;
    $event_type = Event::where('id', $data->event_id)->select('event_type')->first();

    if ($event_type->event_type == 'venue') {
      foreach ($data->quantity as $qty) {
        if ($qty > 0) {
          $select = true;
          break;
        }
        continue;
      }

      //slot validation for variations wise seats
      if (count($selected_slot_seat) > 0) {
        $select = true;
      }
    } else {
      if ($data->pricing_type == 'free') {
        $select = true;
        //free ticket validation
        if (count($selected_slot_seat) > 0) {
          $select = true;
        }
      } elseif ($data->pricing_type == 'normal') {
        if ($data->quantity == 0) {
          $select = false;
        } else {
          $select = true;
        }

        //when selected slot & seat pricing type normal
        if (count($selected_slot_seat) > 0) {
          $select = true;
        }
      } else {
        foreach ($data->quantity as $qty) {
          if ($qty > 0) {
            $select = true;
            break;
          }
          continue;
        }
      }
    }


    if ($select == false) {
      $information['success'] = false;
      $information['message'] = "Please Select at least one ticket";
      return $information;
    }

    $information = [];
    $information['selTickets'] = '';
    $event = Event::where('id', $data->event_id)->select('event_type', 'id')->first();

    $check = false;


    if ($event->event_type == 'online') {
      //**************** stock check start *************** */
      $stock = StockCheck($data->event_id, $data->quantity);
      if ($stock == 'error') {
        $check = true;
      }

      //*************** stock check end **************** */

      if ($data->pricing_type == 'normal') {
        $price = Ticket::where('event_id', $data->event_id)->select('price', 'early_bird_discount', 'early_bird_discount_amount', 'early_bird_discount_type', 'early_bird_discount_date', 'early_bird_discount_time', 'ticket_available', 'ticket_available_type', 'max_ticket_buy_type', 'max_buy_ticket')->first();
        $information['quantity'] = $data->quantity;
        $total = $data->quantity * $price->price;

        //check guest checkout status enable or not
        if ($event_guest_checkout_status != 1) {
          //check max buy by customer
          $max_buy = isTicketPurchaseOnline($data->event_id, $price->max_buy_ticket);
          if ($max_buy['status'] == 'true') {
            $check = true;
          } else {
            $check = false;
          }
        } else {
          $check = false;
        }

        if ($price->early_bird_discount == 'enable') {

          $start = Carbon::parse($price->early_bird_discount_date . $price->early_bird_discount_time);
          $end = Carbon::parse($price->early_bird_discount_date . $price->early_bird_discount_time);
          $today = Carbon::now();
          if ($today <= ($end)) {
            if ($price->early_bird_discount_type == 'fixed') {
              $early_bird_dicount = $price->early_bird_discount_amount;
            } else {
              $early_bird_dicount = ($price->early_bird_discount_amount * $total) / 100;
            }
          } else {
            $early_bird_dicount = 0;
          }
        } else {
          $early_bird_dicount = 0;
        }

        $information['total_early_bird_dicount'] = $early_bird_dicount * $data->quantity;
        $information['total'] = $total;
        $information['sub_total'] = $total;
        $information['quantity'] = $data->quantity;
      } elseif ($data->pricing_type == 'free') {
        $price = Ticket::where('event_id', $data->event_id)->select('max_buy_ticket')->first();
        //check guest checkout status enable or not
        if ($event_guest_checkout_status != 1) {
          //check max buy by customer
          $max_buy = isTicketPurchaseOnline($data->event_id, $price->max_buy_ticket);
          if ($max_buy['status'] == 'true') {
            $check = true;
          }
        }

        $information['quantity'] = $data->quantity;
        $information['total'] = 0;
        $information['sub_total'] = 0;
      }
    } else {
      $tickets = Ticket::query()
        ->sellable()
        ->where('event_id', $data->event_id)
        ->select('id', 'title', 'pricing_type', 'price', 'variations', 'early_bird_discount', 'early_bird_discount_amount', 'early_bird_discount_type', 'early_bird_discount_date', 'early_bird_discount_time', 'normal_ticket_slot_unique_id', 'normal_ticket_slot_enable', 'free_tickete_slot_enable', 'free_tickete_slot_unique_id')
        ->get();
      $ticketArr = [];

      foreach ($tickets as $key => $ticket) {
        if ($ticket->pricing_type == 'variation') {
          $varArr1 = json_decode($ticket->variations, true);
          foreach ($varArr1 as $key => $var1) {
            $stock[] = [
              'name' => $var1['name'],
              'price' => $var1['price'],
              'ticket_available' => $var1['ticket_available'] - $data->quantity[$key],
            ];
            //check early_bird discount
            if ($ticket->early_bird_discount == 'enable') {
              $start = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              $end = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              $today = Carbon::now();
              if ($today <= ($end)) {
                if ($ticket->early_bird_discount_type == 'fixed') {
                  $early_bird_dicount = $ticket->early_bird_discount_amount;
                } else {
                  $early_bird_dicount = ($var1['price'] * $ticket->early_bird_discount_amount) / 100;
                }
              } else {
                $early_bird_dicount = 0;
              }
            } else {
              $early_bird_dicount = 0;
            }

            $var1['type'] = $ticket->pricing_type;
            $var1['early_bird_dicount'] = $early_bird_dicount;
            $var1['ticket_id'] = $ticket->id;
            $ticketArr[] = $var1;
          }
          $information['stock'] = $stock;
        } elseif ($ticket->pricing_type == 'normal') {
          //check early_bird discount
          if ($ticket->early_bird_discount == 'enable') {
            $start = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
            $end = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
            $today = Carbon::now();
            if ($today <= ($end)) {
              if ($ticket->early_bird_discount_type == 'fixed') {
                $early_bird_dicount = $ticket->early_bird_discount_amount;
              } else {
                $early_bird_dicount = ($ticket->price * $ticket->early_bird_discount_amount) / 100;
              }
            } else {
              $early_bird_dicount = 0;
            }
          } else {
            $early_bird_dicount = 0;
          }

          $language = Language::where('is_default', 1)->first();

          $ticketContent = TicketContent::where([['ticket_id', $ticket->id], ['language_id', $language->id]])->first();
          if (empty($ticketContent)) {
            $ticketContent = TicketContent::where('ticket_id', $ticket->id)->first();
          }

          $ticketArr[] = [
            'ticket_id' => $ticket->id,
            'early_bird_dicount' => $early_bird_dicount,
            'name' => $ticketContent->title ?? ($ticket->title ?? ('Ticket #' . $ticket->id)),
            'price' => $ticket->price,
            'type' => $ticket->pricing_type,
            'slot_unique_id' => (int) $ticket->normal_ticket_slot_unique_id
          ];
        } elseif ($ticket->pricing_type == 'free') {
          $language = Language::where('is_default', 1)->first();
          $ticketContent = TicketContent::where([['ticket_id', $ticket->id], ['language_id', $language->id]])->first();
          if (empty($ticketContent)) {
            $ticketContent = TicketContent::where('ticket_id', $ticket->id)->first();
          }
          $ticketArr[] = [
            'ticket_id' => $ticket->id,
            'early_bird_dicount' => 0,
            'name' => $ticketContent->title ?? ($ticket->title ?? ('Ticket #' . $ticket->id)),
            'price' => 0,
            'type' => $ticket->pricing_type,
            'slot_unique_id' => (int) $ticket->free_tickete_slot_unique_id
          ];
        }
      }

      if ($ticketArr === []) {
        return [
          'success' => false,
          'message' => 'No tickets available for the selected event.',
        ];
      }

      $selTickets = [];
      foreach ($data->quantity as $key => $qty) {
        if ($qty > 0) {
          if (!isset($ticketArr[$key])) {
            continue;
          }
          $selTickets[] = [
            'ticket_id' => $ticketArr[$key]['ticket_id'],
            'early_bird_dicount' => $qty * $ticketArr[$key]['early_bird_dicount'],
            'name' => $ticketArr[$key]['name'],
            'qty' => $qty,
            'price' => $ticketArr[$key]['price'],
          ];
        }
      }

      $sub_total = 0;
      $total_ticket = 0;
      $total_early_bird_dicount = 0;
      foreach ($selTickets as $key => $var) {
        $sub_total += $var['price'] * $var['qty'];
        $total_ticket += $var['qty'];
        $total_early_bird_dicount += $var['early_bird_dicount'];
      }


      //stock check
      foreach ($selTickets as $selTicket) {
        $stock = TicketStockCheck($selTicket['ticket_id'], $selTicket['qty'], $selTicket['name']);
        if ($stock == 'error') {
          $check = true;
          break;
        }
        //check guest checkout status enable or not
        if ($event_guest_checkout_status != 1) {
          $check_v = isTicketPurchaseVenueBackend($data->event_id, $selTicket['ticket_id'], $selTicket['name']);
          if ($check_v['status'] == 'true') {
            $check = true;
            break;
          }
        }
      }


      //check existins bookings seat or slot ids
      if (count($selected_slot_seat) > 0) {
        $check = $this->slotBookedDeactiveCheck($selected_slot_seat, $data->event_id);
      }


      $ticketArr = collect($ticketArr)->map(function ($ticket) {
        $ticket['slot_unique_id'] = (int) $ticket['slot_unique_id'];
        return $ticket;
      })->toArray();


      $slotGroups = collect($ticketArr)
        ->groupBy('slot_unique_id')
        ->map(fn($items) => $items[0])
        ->toArray();



      $seat_total_amount = 0;
      $seat_early_bird_discount = 0;
      $seat_sub_total = 0;
      $seat_total_ticket = 0;
      foreach ($selected_seats as $seat) {
        $seat_total_ticket += 1;
        $slot_unique_id = (int) $seat['slot_unique_id'];
        $seat_total_amount += $seat['price'];
        $seat_sub_total += $seat['price'];
        $seat_early_bird_discount += $seat['discount'];
        $selTickets[] = [
          'ticket_id' => $seat['ticket_id'],
          'early_bird_dicount' => $seat['discount'],
          'name' => array_key_exists($slot_unique_id, $slotGroups) ? $slotGroups[$slot_unique_id]['name'] : "",
          'qty' => 1,
          'price' => $seat['price'],
          'discount' => $seat['discount'],
          'payable_price' => $seat['payable_price'],
          'seat_id' => $seat['id'],
          'seat_name' => $seat['name'],
          'slot_id' => $seat['slot_id'],
          'slot_name' => $seat['slot_name'],
          'slot_unique_id' => $slot_unique_id,
          'event_id' => $seat['event_id'],
          's_type' => $seat['s_type'],
        ];
      }

      $total_early_bird_dicount += $seat_early_bird_discount;
      $sub_total += $seat_sub_total;
      $total = $sub_total - $total_early_bird_dicount;
      $total_ticket += $seat_total_ticket;

      $information['total'] = round($total, 2);
      $information['sub_total'] = round($sub_total, 2);
      $information['quantity'] = $total_ticket;
      $information['selTickets'] = $selTickets;
      $information['discount'] = null;
      $information['total_early_bird_dicount'] = round($total_early_bird_dicount, 2);
    }

    if ($check == true) {
      $information['success'] = false;
      $information['message'] = "Something went wrong..!";
      return $information;
    }

    $information['success'] = true;

    return $information;
  }

  public function slotBookedDeactiveCheck($selectedSlotSeat, $event_id): bool
  {
    $check = app(\App\Services\BookingServices::class)->checkBookingAndDeactiveSlotSeat($selectedSlotSeat, $event_id);
    return $check;
  }

  public function verifyPayment(Request $request)
  {
    $rules = [
      'gateway' => 'required',
      'total' => 'required',
    ];
    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json([
        'status' => false,
        'validation_errors' => $validator->getMessageBag()->toArray()
      ]);
    }

    $amount = $request->total;
    $gateway = $request->gateway;

    //convert payment amount
    $currencyInfo = Basic::select(
      'base_currency_symbol',
      'base_currency_symbol_position',
      'base_currency_text',
      'base_currency_text_position',
      'base_currency_rate'
    )
      ->firstOrFail();
    $gateway = strtolower($gateway);

    switch ($gateway) {
      case 'paypal':
        if ($currencyInfo->base_currency_text !== 'DOP') {
          $rate = floatval($currencyInfo->base_currency_rate);
          $convertedTotal = $amount / $rate;
        }
        $paidAmount = $currencyInfo->base_currency_text === 'DOP' ? $amount : $convertedTotal;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'paystack':
        if ($currencyInfo->base_currency_text !== 'NGN') {
          $information["success"] = true;
          $information["message"] = "";
          $information["paidAmount"] = 0.00;
          return ['success' => false, 'message' => 'Invalid currency for paystack payment.'];
        }
        $paidAmount = $amount * 100;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'flutterwave':
        $allowedCurrencies = array('BIF', 'CAD', 'CDF', 'CVE', 'EUR', 'GBP', 'GHS', 'GMD', 'GNF', 'KES', 'LRD', 'MWK', 'MZN', 'NGN', 'RWF', 'SLL', 'STD', 'TZS', 'UGX', 'USD', 'XAF', 'XOF', 'ZMK', 'ZMW', 'ZWD');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for flutterwave payment.'];
        }
        $paidAmount = intval($amount);

        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'razorpay':
        if ($currencyInfo->base_currency_text !== 'INR') {
          return ['success' => false, 'message' => 'Invalid currency for razorpay payment.'];
        }
        $paidAmount = $amount * 100;

        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'mercadopago':
        $allowedCurrencies = array('ARS', 'BOB', 'BRL', 'CLF', 'CLP', 'COP', 'CRC', 'CUC', 'CUP', 'DOP', 'EUR', 'GTQ', 'HNL', 'MXN', 'NIO', 'PAB', 'PEN', 'PYG', 'USD', 'UYU', 'VEF', 'VES');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for mercadopago payment.'];
        }
        $paidAmount = intval($amount);
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'mollie':
        $allowedCurrencies = array('AED', 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CZK', 'DKK', 'EUR', 'GBP', 'HKD', 'HRK', 'HUF', 'ILS', 'ISK', 'JPY', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'RUB', 'SEK', 'SGD', 'THB', 'TWD', 'USD', 'ZAR');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for mollie payment.'];
        }
        $paidAmount = sprintf('%0.2f', $amount);
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'stripe':
        if ($currencyInfo->base_currency_text !== 'DOP') {
          $rate = floatval($currencyInfo->base_currency_rate);
          $convertedTotal = round(($amount / $rate), 2);
        }

        $paidAmount = $currencyInfo->base_currency_text === 'DOP' ? $amount : $convertedTotal;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'authorize.net':
        $allowedCurrencies = array('USD', 'CAD', 'CHF', 'DKK', 'EUR', 'GBP', 'NOK', 'PLN', 'SEK', 'AUD', 'NZD');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for authorize.net payment.'];
        }
        $paidAmount = sprintf('%0.2f', $amount);
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];

        break;
      case 'phonepe':
        $allowedCurrencies = array('INR');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for phonepe payment.'];
        }
        $paidAmount = $amount * 100;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'myfatoorah':
        $allowedCurrencies = array('KWD', 'SAR', 'BHD', 'AED', 'QAR', 'OMR', 'JOD');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for myfatoorah payment.'];
        }
        $paidAmount = intval($amount);
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'midtrans':
        $allowedCurrencies = array('IDR');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for midtrans payment.'];
        }
        $paidAmount = (int) round($amount);
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'toyyibpay':
        $allowedCurrencies = array('RM');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for toyyibpay payment.'];
        }
        $paidAmount = $amount * 100;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'xendit':
        $allowedCurrencies = array('IDR', 'PHP', 'USD', 'SGD', 'MYR');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for xendit payment.'];
        }
        $paidAmount = $amount;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'monnify':
        $allowedCurrencies = array('NGN');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for monnify payment.'];
        }
        $paidAmount = $amount;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      case 'now_payments':
        $allowedCurrencies = array('USD', 'EUR', 'GBP', 'USDT', 'BTC', 'ETH');
        if (!in_array($currencyInfo->base_currency_text, $allowedCurrencies)) {
          return ['success' => false, 'message' => 'Invalid currency for now_payments payment.'];
        }
        $paidAmount = $amount;
        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
      default:
        $paidAmount = intval($amount);

        $information = [
          "success" => true,
          "message" => "",
          "paidAmount" => $paidAmount,
        ];
        break;
    }

    return $information;
  }

  public function earning_revenue($bookingInfo)
  {
    $earning = Earning::first();
    $earning->total_revenue = $earning->total_revenue + $bookingInfo->price + $bookingInfo->tax;
    if ($bookingInfo['organizer_id'] != null) {
      $earning->total_earning = $earning->total_earning + ($bookingInfo->tax + $bookingInfo->commission);
    } else {
      $earning->total_earning = $earning->total_earning + $bookingInfo->price + $bookingInfo->tax;
    }
    $earning->save();
    return;
  }

  public function checkoutVerify(Request $request)
  {
      $rules = [
        'event_guest_checkout_status' => 'required',
        'event_id' => 'required',
        'seat_data' => 'nullable',
        'quantity' => 'required',
        'pricing_type' => 'required',
      ];
      $validator = Validator::make($request->all(), $rules);
      if ($validator->fails()) {
        return response()->json([
          'status' => false,
          'validation_errors' => $validator->getMessageBag()->toArray()
        ]);
      }

      $basic = Basic::select('event_guest_checkout_status', 'tax')->first();

      if ($request->event_guest_checkout_status == 1) {
        $bs_checkout_status = $basic->event_guest_checkout_status;
        if ($bs_checkout_status != 1) {
          return [
            'success' => false,
            'message' => 'login Required',
          ];
        }
      }

      // Check for email and phone verification if user is logged in
      if (auth('customer')->check()) {
        $customer = auth('customer')->user();
        if (is_null($customer->email_verified_at)) {
          return [
            'success' => false,
            'message' => 'email_verification_required',
          ];
        }
        if (is_null($customer->phone_verified_at)) {
          return [
            'success' => false,
            'message' => 'phone_verification_required',
          ];
        }
      }

      $authenticatedCustomer = auth('customer')->user();
      $checkoutCustomer = $authenticatedCustomer instanceof Customer ? $authenticatedCustomer : Auth::guard('customer')->user();
      if (!$checkoutCustomer instanceof Customer) {
        $checkoutCustomer = null;
      }
      if (!$checkoutCustomer) {
        $sanctumUser = Auth::guard('sanctum')->user();
        if ($sanctumUser instanceof Customer) {
          $checkoutCustomer = $sanctumUser;
        }
      }

      $checkoutContext = $this->eventCheckoutSelectionService->buildContext($request);
      $quantityList = $checkoutContext['quantity_list'];
      $quantityScalar = $checkoutContext['quantity_scalar'];
      $quantity = $quantityList;
      $event_id = $request->event_id;
      $pricing_type = $request->pricing_type;
      $event_guest_checkout_status = $request->event_guest_checkout_status;
      $selected_seats = $checkoutContext['selected_seats'];
      $selected_slot_seat = $checkoutContext['selected_slot_seat'];
      $event_type = Event::where('id', $event_id)->select('event_type')->first();
      $select = $this->eventCheckoutSelectionService->hasAnySelection(
        $event_type->event_type,
        $pricing_type,
        $quantityList,
        $quantityScalar,
        $selected_slot_seat
      );

      if ($select == false) {
        return [
          'success' => false,
          'message' => "Please Select at least one ticket ",
        ];
      }

      $information = [];
      $information['tax_type'] = 'percentage';
      $information['tax'] = $basic->tax;
      $information['selTickets'] = '';
      $limitSelections = [];
      $event = Event::where('id', $event_id)->select('event_type', 'id')->first();

      $check = false;
      if ($event->event_type == 'online') {
        //**************** stock check start *************** */
        $stock = StockCheck($event_id, $quantity);
        if ($stock == 'error') {
          $check = true;
        }

        //*************** stock check end **************** */

        if ($pricing_type == 'normal') {
          $price = Ticket::where('event_id', $event_id)->select('id', 'price', 'f_price', 'pricing_type', 'early_bird_discount', 'early_bird_discount_amount', 'early_bird_discount_type', 'early_bird_discount_date', 'early_bird_discount_time', 'ticket_available', 'ticket_available_type', 'max_ticket_buy_type', 'max_buy_ticket')->first();
          $pricingSnapshot = $this->ticketPriceScheduleService->resolveForTicket($price);
          $effectiveUnitPrice = (float) ($pricingSnapshot['effective_price'] ?? ($price->price ?? 0));
          $information['quantity'] = $quantityScalar;
          $total = $quantityScalar * $effectiveUnitPrice;
          $limitSelections[] = [
            'ticket_id' => $price->id,
            'qty' => $quantityScalar,
            'name' => $price->title ?? ('Ticket #' . $price->id),
          ];

          if ($price->early_bird_discount == 'enable') {

            $start = Carbon::parse($price->early_bird_discount_date . $price->early_bird_discount_time);
            $end = Carbon::parse($price->early_bird_discount_date . $price->early_bird_discount_time);
            $today = Carbon::now();
            if ($today <= ($end)) {
              if ($price->early_bird_discount_type == 'fixed') {
                $early_bird_dicount = $price->early_bird_discount_amount;
              } else {
                $early_bird_dicount = ($price->early_bird_discount_amount * $total) / 100;
              }
            } else {
              $early_bird_dicount = 0;
            }
          } else {
            $early_bird_dicount = 0;
          }

          $information['total_early_bird_dicount'] = $early_bird_dicount * $quantity;
          $information['total'] = $total;
          $information['sub_total'] = $total;
          $information['quantity'] = $quantity;
        } elseif ($pricing_type == 'free') {
          $price = Ticket::where('event_id', $event_id)->select('id', 'title', 'max_buy_ticket')->first();
          $limitSelections[] = [
            'ticket_id' => $price->id,
            'qty' => $quantityScalar,
            'name' => $price->title ?? ('Ticket #' . $price->id),
          ];

          $information['quantity'] = $quantity;
          $information['total'] = 0;
          $information['sub_total'] = 0;
          $information['total_early_bird_dicount'] = 0.00;
        }
      } else {
        $tickets = Ticket::query()
          ->sellable()
          ->where('event_id', $event_id)
          ->select('id', 'title', 'pricing_type', 'price', 'variations', 'early_bird_discount', 'early_bird_discount_amount', 'early_bird_discount_type', 'early_bird_discount_date', 'early_bird_discount_time', 'normal_ticket_slot_unique_id', 'normal_ticket_slot_enable', 'free_tickete_slot_enable', 'free_tickete_slot_unique_id')
          ->get();
        $ticketArr = [];

        foreach ($tickets as $key => $ticket) {
          if ($ticket->pricing_type == 'variation') {
            $varArr1 = json_decode($ticket->variations, true);
            foreach ($varArr1 as $key => $var1) {
              $stock[] = [
                'name' => $var1['name'],
                'price' => $var1['price'],
                'ticket_available' => $var1['ticket_available'] - $quantity[$key],
              ];
              //check early_bird discount
              if ($ticket->early_bird_discount == 'enable') {
                $start = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
                $end = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
                $today = Carbon::now();
                if ($today <= ($end)) {
                  if ($ticket->early_bird_discount_type == 'fixed') {
                    $early_bird_dicount = $ticket->early_bird_discount_amount;
                  } else {
                    $early_bird_dicount = ($var1['price'] * $ticket->early_bird_discount_amount) / 100;
                  }
                } else {
                  $early_bird_dicount = 0;
                }
              } else {
                $early_bird_dicount = 0;
              }

              $var1['type'] = $ticket->pricing_type;
              $var1['early_bird_dicount'] = $early_bird_dicount;
              $var1['ticket_id'] = $ticket->id;
              $ticketArr[] = $var1;
            }
          } elseif ($ticket->pricing_type == 'normal') {
            //check early_bird discount
            if ($ticket->early_bird_discount == 'enable') {
              $start = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              $end = Carbon::parse($ticket->early_bird_discount_date . $ticket->early_bird_discount_time);
              $today = Carbon::now();
              if ($today <= ($end)) {
                if ($ticket->early_bird_discount_type == 'fixed') {
                  $early_bird_dicount = $ticket->early_bird_discount_amount;
                } else {
                  $early_bird_dicount = ($ticket->price * $ticket->early_bird_discount_amount) / 100;
                }
              } else {
                $early_bird_dicount = 0;
              }
            } else {
              $early_bird_dicount = 0;
            }

            $language = Language::where('is_default', 1)->first();

            $ticketContent = TicketContent::where([['ticket_id', $ticket->id], ['language_id', $language->id]])->first();
            if (empty($ticketContent)) {
              $ticketContent = TicketContent::where('ticket_id', $ticket->id)->first();
            }

            $ticketArr[] = [
              'ticket_id' => $ticket->id,
              'early_bird_dicount' => $early_bird_dicount,
              'name' => $ticketContent->title ?? ($ticket->title ?? ('Ticket #' . $ticket->id)),
              'price' => $ticket->price,
              'type' => $ticket->pricing_type,
              'slot_unique_id' => (int) $ticket->normal_ticket_slot_unique_id
            ];
          } elseif ($ticket->pricing_type == 'free') {
            $language = Language::where('is_default', 1)->first();
            $ticketContent = TicketContent::where([['ticket_id', $ticket->id], ['language_id', $language->id]])->first();
            if (empty($ticketContent)) {
              $ticketContent = TicketContent::where('ticket_id', $ticket->id)->first();
            }
            $ticketArr[] = [
              'ticket_id' => $ticket->id,
              'early_bird_dicount' => 0,
              'name' => $ticketContent->title ?? ($ticket->title ?? ('Ticket #' . $ticket->id)),
              'price' => 0,
              'type' => $ticket->pricing_type,
              'slot_unique_id' => (int) $ticket->free_tickete_slot_unique_id
            ];
          }
        }

        if ($ticketArr === []) {
          return [
            'success' => false,
            'message' => 'No tickets available for the selected event.',
          ];
        }

        $selTickets = [];
        foreach ($quantity as $key => $qty) {
          if ($qty > 0) {
            if (!isset($ticketArr[$key])) {
              continue;
            }
            $selTickets[] = [
              'ticket_id' => $ticketArr[$key]['ticket_id'],
              'early_bird_dicount' => $qty * $ticketArr[$key]['early_bird_dicount'],
              'name' => $ticketArr[$key]['name'],
              'qty' => $qty,
              'price' => $ticketArr[$key]['price'],
            ];
          }
        }

        $sub_total = 0;
        $total_ticket = 0;
        $total_early_bird_dicount = 0;
        foreach ($selTickets as $key => $var) {
          $sub_total += $var['price'] * $var['qty'];
          $total_ticket += $var['qty'];
          $total_early_bird_dicount += $var['early_bird_dicount'];
        }


        //stock check
        foreach ($selTickets as $selTicket) {
          $stock = TicketStockCheck($selTicket['ticket_id'], $selTicket['qty'], $selTicket['name']);
          if ($stock == 'error') {
            $check = true;
            break;
          }
        }


        //check existins bookings seat or slot ids
        if (count($selected_slot_seat) > 0) {
          $check = $this->slotBookedDeactiveCheck($selected_slot_seat, $event_id);
        }


        $ticketArr = collect($ticketArr)->map(function ($ticket) {
          $ticket['slot_unique_id'] = (int) $ticket['slot_unique_id'];
          return $ticket;
        })->toArray();


        $slotGroups = collect($ticketArr)
          ->groupBy('slot_unique_id')
          ->map(fn($items) => $items[0])
          ->toArray();


        $seat_total_amount = 0;
        $seat_early_bird_discount = 0;
        $seat_sub_total = 0;
        $seat_total_ticket = 0;
        foreach ($selected_seats as $seat) {
          $seat_total_ticket += 1;
          $slot_unique_id = (int) $seat['slot_unique_id'];
          $seat_total_amount += $seat['price'];
          $seat_sub_total += $seat['price'];
          $seat_early_bird_discount += $seat['discount'];
          $selTickets[] = [
            'ticket_id' => $seat['ticket_id'],
            'early_bird_dicount' => $seat['discount'],
            'name' => array_key_exists($slot_unique_id, $slotGroups) ? $slotGroups[$slot_unique_id]['name'] : "",
            'qty' => 1,
            'price' => $seat['price'],
            'discount' => $seat['discount'],
            'payable_price' => $seat['payable_price'],
            'seat_id' => $seat['id'],
            'seat_name' => $seat['name'],
            'slot_id' => $seat['slot_id'],
            'slot_name' => $seat['slot_name'],
            'slot_unique_id' => $slot_unique_id,
            'event_id' => $seat['event_id'],
            's_type' => $seat['s_type'],
          ];
        }

        $total_early_bird_dicount += $seat_early_bird_discount;
        $sub_total += $seat_sub_total;
        $total = $sub_total - $total_early_bird_dicount;
        $total_ticket += $seat_total_ticket;

        $information['total'] = round($total, 2);
        $information['sub_total'] = round($sub_total, 2);
        $information['quantity'] = $total_ticket;
        $information['selTickets'] = $selTickets;
        $limitSelections = $selTickets;
        $information['total_early_bird_dicount'] = round($total_early_bird_dicount, 2);
      }

      if ($check !== true) {
        $purchaseLimitViolation = app(EventPurchaseLimitService::class)->validateSelection(
          $checkoutCustomer,
          $event,
          $limitSelections,
          (int) $quantityScalar,
          is_array($request->input('ticket_recipients')) ? $request->input('ticket_recipients') : []
        );

        if ($purchaseLimitViolation) {
          return [
            'success' => false,
            'status' => false,
            'message' => $purchaseLimitViolation['message'],
            'error_type' => $purchaseLimitViolation['error_type'] ?? 'purchase_limit_reached',
            'limit_context' => $purchaseLimitViolation['limit_context'] ?? null,
          ];
        }
      }

      if ($check == true) {
        return [
          'success' => false,
          'message' => 'Something Went Wrong...!'
        ];
      }

      $requestedGateway = Str::lower((string) $request->input('gateway', 'stripe'));
      $applyWalletBalance = filter_var($request->input('apply_wallet_balance', false), FILTER_VALIDATE_BOOLEAN);
      $applyBonusBalance = filter_var($request->input('apply_bonus_balance', false), FILTER_VALIDATE_BOOLEAN);

      if (
        isset($information['total'])
        && (
          (float) $information['total'] > 0
          || $applyWalletBalance
          || $applyBonusBalance
          || in_array($requestedGateway, ['wallet', 'bonus', 'mixed'], true)
        )
      ) {
        $walletBalance = 0.0;
        $bonusBalance = 0.0;

        if ($checkoutCustomer instanceof Customer) {
          $walletBalance = (float) $this->walletService->getOrCreateWallet($checkoutCustomer)->balance;
          $bonusBalance = (float) $this->bonusWalletService->getOrCreateWallet($checkoutCustomer)->balance;
        }

        $information['payment_summary'] = array_merge(
          $this->checkoutFundingAllocatorService->allocate((float) $information['total'], [
            'gateway' => $requestedGateway,
            'wallet_balance' => $walletBalance,
            'bonus_balance' => $bonusBalance,
            'apply_wallet_balance' => $applyWalletBalance,
            'apply_bonus_balance' => $applyBonusBalance,
          ]),
          [
            'available_wallet_balance' => round($walletBalance, 2),
            'available_bonus_balance' => round($bonusBalance, 2),
          ]
        );
      }

      $information['success'] = true;
      return $information;
    }

  public function applyCoupon(Request $request)
  {
    $rules = [
      'coupon_code' => 'required',
      'price' => 'required',
      'total_early_bird_dicount' => 'required',
      'event_id' => 'required',
    ];
    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json([
        'status' => false,
        'validation_errors' => $validator->getMessageBag()->toArray()
      ]);
    }
    $early_bird_dicount = $request->total_early_bird_dicount;
    $coupon_code = $request->coupon_code;
    $event_id = $request->event_id;
    $price = $request->price;

    $coupon = Coupon::where('code', $coupon_code)->first();
    if (!$coupon) {
      return [
        'success' => false,
        'message' => "Coupon is not valid",
        'discount' => 0.00,
      ];
    } else {

      $start = Carbon::parse($coupon->start_date);
      $end = Carbon::parse($coupon->end_date);
      $today = Carbon::now();
      $event_id = $request->event_id;
      $events = json_decode($coupon->events, true);
      if (!empty($events)) {
        if (in_array($event_id, $events)) {

          // if coupon is active
          if ($today->greaterThanOrEqualTo($start) && $today->lessThan($end)) {
            $value = $coupon->value;
            $type = $coupon->type;

            if ($early_bird_dicount != '') {
              $cartTotal = $price - $early_bird_dicount;
            } else {
              $cartTotal = $price - $early_bird_dicount;
            }
            if ($type == 'fixed') {
              $couponAmount = $value;
            } else {
              $couponAmount = ($cartTotal * $value) / 100;
            }
            return [
              'success' => true,
              'message' => "Coupon applied successfully",
              'discount' => floatval($couponAmount),
            ];
          } else {
            return [
              'success' => false,
              'message' => "Coupon is not valid",
              'discount' => 0.00,
            ];
          }
        } else {
          return [
            'success' => false,
            'message' => "Coupon is not valid",
            'discount' => 0.00,
          ];
        }
      } else {
        // if coupon is active
        if ($today->greaterThanOrEqualTo($start) && $today->lessThan($end)) {
          $value = $coupon->value;
          $type = $coupon->type;
          if ($early_bird_dicount != '') {
            $cartTotal = $price - $early_bird_dicount;
          } else {
            $cartTotal = $price - $early_bird_dicount;
          }
          if ($type == 'fixed') {
            $couponAmount = $value;
          } else {
            $couponAmount = ($cartTotal * $value) / 100;
          }
          return [
            'success' => true,
            'message' => "Coupon applied successfully",
            'discount' => floatval($couponAmount),
          ];
        } else {
          return [
            'success' => false,
            'message' => "Coupon applied successfully",
            'discount' => "Coupon is not valid",
          ];
        }
      }
    }
  }
}
