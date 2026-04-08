<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\BackEnd\Event\TicketController;
use App\Http\Controllers\Controller;
use App\Http\Controllers\FrontEnd\PaymentGateway\MyFatoorahController;
use App\Http\Controllers\FrontEnd\PaymentGateway\XenditController;
use App\Http\Controllers\FrontEnd\Shop\PaymentGateway\MyFatoorahController as ShopGatewayMyFatoorahController;
use App\Http\Controllers\FrontEnd\Shop\PaymentGateway\XenditController as ShopXenditController;
use App\Models\BasicSettings\Basic;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\EventCategory;
use App\Models\Event\EventContent;
use App\Models\Event\Ticket;
use App\Models\Footer\FooterContent;
use App\Models\Footer\QuickLink;
use App\Models\HomePage\AboutUsSection;
use App\Models\HomePage\EventFeature;
use App\Models\HomePage\EventFeatureSection;
use App\Models\HomePage\HeroSection;
use App\Models\HomePage\HowWork;
use App\Models\HomePage\HowWorkItem;
use App\Models\HomePage\Partner;
use App\Models\HomePage\PartnerSection;
use App\Models\HomePage\Section;
use App\Models\HomePage\Testimonial;
use App\Models\HomePage\TestimonialSection;
use App\Models\Language;
use App\Services\OrganizerPublicProfileService;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class HomeController extends Controller
{
  private $now_date_time;
  public function __construct()
  {
    $this->now_date_time = Carbon::now();
  }
  public function index(OrganizerPublicProfileService $organizerProfileService)
  {
    $tickets = Ticket::get();
     $tController = new TicketController;
    foreach($tickets as $tickets){
      $tController->includeSlotSystemVariable($tickets->id);
    }


    $language = $this->getLanguage();

    $queryResult['seoInfo'] = $language->seoInfo()->select('meta_keyword_home', 'meta_description_home')->first();

    // get the sections of selected home version
    $sectionInfo = Section::first();
    $queryResult['secInfo'] = $sectionInfo;

    $queryResult['heroInfo'] = $language->heroSec()->first();

    $queryResult['secTitleInfo'] = $language->sectionTitle()->first();

    $categories = $language->event_category()->where('status', 1)->where('is_featured', '=', 'yes')->orderBy('serial_number', 'asc')
      ->get();


    $queryResult['categories'] = $categories;

    $queryResult['currencyInfo'] = $this->getCurrencyInfo();

    if ($sectionInfo->features_section_status == 1) {
      $queryResult['featureData'] = Basic::select('features_section_image')->first();

      $queryResult['features'] = $language->feature()->orderBy('serial_number', 'asc')->get();
    }


    if ($sectionInfo->about_us_section_status == 1) {
      $queryResult['aboutUsInfo'] = $language->aboutUsSec()->first();
    }
    $queryResult['heroSection'] = HeroSection::where('language_id', $language->id)->first();
    $queryResult['eventCategories'] = EventCategory::where([['language_id', $language->id], ['status', 1], ['is_featured', 'yes']])->orderBy('serial_number', 'asc')->get();
    $queryResult['featuredEvents'] = $this->buildFeaturedEvents($language->id);
    $queryResult['sceneEvents'] = $this->buildSceneEvents($language->id);
    $queryResult['categorySignals'] = $this->buildCategorySignals($queryResult['eventCategories'], $language->id);
    $queryResult['hostSpotlights'] = $this->buildHostSpotlights(
      $queryResult['featuredEvents']->concat($queryResult['sceneEvents']),
      $organizerProfileService,
      $language->id
    );
    $queryResult['socialSnapshot'] = [
      'upcoming_events' => Event::query()
        ->where('status', 1)
        ->where('end_date_time', '>=', $this->now_date_time)
        ->count(),
      'categories' => $queryResult['eventCategories']->count(),
      'featured_events' => $queryResult['featuredEvents']->count(),
      'hosts' => collect($queryResult['hostSpotlights'])->count(),
    ];

    $queryResult['aboutUsSection'] = AboutUsSection::where('language_id', $language->id)->first();

    $queryResult['featureEventSection'] = EventFeatureSection::where('language_id', $language->id)->first();
    $queryResult['featureEventItems'] = EventFeature::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();

    $queryResult['howWork'] = HowWork::where('language_id', $language->id)->first();
    $queryResult['howWorkItems'] = HowWorkItem::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();

    if ($sectionInfo->testimonials_section_status == 1) {
      $queryResult['testimonialData'] = TestimonialSection::where('language_id', $language->id)->first();

      $queryResult['testimonials'] = Testimonial::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
    }

    $queryResult['partnerInfo'] = PartnerSection::where('language_id', $language->id)->first();
    $queryResult['partners'] = Partner::orderBy('serial_number', 'asc')->get();
    $queryResult['footerInfo'] = FooterContent::where('language_id', $language->id)->first();
    $queryResult['quickLinkInfos'] = QuickLink::orderBy('serial_number', 'asc')->get();

    return view('frontend.home.index-v1', $queryResult);
  }

  private function baseHomeEventsQuery(int $languageId)
  {
    return DB::table('event_contents')
      ->join('events', 'events.id', '=', 'event_contents.event_id')
      ->leftJoin('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
      ->where([
        ['event_contents.language_id', '=', $languageId],
        ['events.status', '=', 1],
        ['events.end_date_time', '>=', $this->now_date_time],
      ])
      ->select(
        'event_contents.id as content_id',
        'event_contents.title',
        'event_contents.slug',
        'event_contents.description',
        'event_contents.event_category_id',
        'events.id',
        'events.thumbnail',
        'events.start_date',
        'events.start_time',
        'events.end_date_time',
        'event_contents.address',
        'events.event_type',
        'events.date_type',
        'events.owner_identity_id',
        'events.organizer_id',
        'events.is_featured',
        'event_categories.name as categoryName'
      );
  }

  private function buildFeaturedEvents(int $languageId, int $limit = 6): Collection
  {
    $events = (clone $this->baseHomeEventsQuery($languageId))
      ->where('events.is_featured', '=', 'yes')
      ->orderBy('events.start_date')
      ->orderBy('events.start_time')
      ->limit($limit)
      ->get();

    return $this->attachEventPricing($events);
  }

  private function buildSceneEvents(int $languageId, int $limit = 3): Collection
  {
    $baseQuery = $this->baseHomeEventsQuery($languageId);

    if (Auth::guard('customer')->check()) {
      $wishlistCategoryIds = DB::table('wishlists')
        ->join('event_contents', 'event_contents.event_id', '=', 'wishlists.event_id')
        ->where('wishlists.customer_id', Auth::guard('customer')->id())
        ->pluck('event_contents.event_category_id')
        ->filter()
        ->unique()
        ->values();

      if ($wishlistCategoryIds->isNotEmpty()) {
        $personalizedEvents = (clone $baseQuery)
          ->whereIn('event_contents.event_category_id', $wishlistCategoryIds->all())
          ->orderByDesc('events.is_featured')
          ->orderBy('events.start_date')
          ->limit($limit)
          ->get();

        if ($personalizedEvents->isNotEmpty()) {
          return $this->attachEventPricing($personalizedEvents);
        }
      }
    }

    $events = (clone $baseQuery)
      ->orderByDesc('events.is_featured')
      ->orderBy('events.start_date')
      ->orderByDesc('events.created_at')
      ->limit($limit)
      ->get();

    return $this->attachEventPricing($events);
  }

  private function buildCategorySignals(Collection $categories, int $languageId): Collection
  {
    $categoryCounts = DB::table('event_contents')
      ->join('events', 'events.id', '=', 'event_contents.event_id')
      ->where([
        ['event_contents.language_id', '=', $languageId],
        ['events.status', '=', 1],
        ['events.end_date_time', '>=', $this->now_date_time],
      ])
      ->groupBy('event_contents.event_category_id')
      ->selectRaw('event_contents.event_category_id, COUNT(*) as total')
      ->pluck('total', 'event_contents.event_category_id');

    return $categories
      ->take(6)
      ->map(function ($category) use ($categoryCounts) {
        $category->event_count = (int) ($categoryCounts[$category->id] ?? 0);

        return $category;
      });
  }

  private function buildHostSpotlights(Collection $events, OrganizerPublicProfileService $organizerProfileService, int $languageId): Collection
  {
    $hosts = collect();
    $usedKeys = [];

    foreach ($events as $event) {
      $ownerIdentityId = $event->owner_identity_id ?? null;
      $legacyOrganizerId = $event->organizer_id ?? null;
      $lookupKey = $ownerIdentityId ? 'identity:' . $ownerIdentityId : 'legacy:' . $legacyOrganizerId;

      if (!$ownerIdentityId && !$legacyOrganizerId) {
        continue;
      }

      if (in_array($lookupKey, $usedKeys, true)) {
        continue;
      }

      $profile = $organizerProfileService->organizerPayloadForEvent($ownerIdentityId, $legacyOrganizerId, $languageId);
      if (!$profile) {
        continue;
      }

      $usedKeys[] = $lookupKey;
      $displayName = $profile['organizer_name'] ?? $profile['username'] ?? __('Organizer');

      $hosts->push([
        'name' => $displayName,
        'username' => $profile['username'] ?? $displayName,
        'route' => route('frontend.organizer.details', [
          $profile['id'],
          str_replace(' ', '-', $profile['username'] ?? $displayName),
        ]),
        'followers_count' => (int) ($profile['followers_count'] ?? 0),
        'events_count' => (int) ($profile['events_count'] ?? 0),
        'review_count' => (int) ($profile['review_count'] ?? 0),
        'average_rating' => $profile['average_rating'] ?? '0.0',
        'designation' => $profile['designation'] ?? null,
        'city' => $profile['city'] ?? null,
        'photo' => $profile['photo'] ?? null,
      ]);

      if ($hosts->count() >= 3) {
        break;
      }
    }

    return $hosts;
  }

  private function attachEventPricing(Collection $events): Collection
  {
    $eventIds = $events->pluck('id')->filter()->unique()->values();

    if ($eventIds->isEmpty()) {
      return $events;
    }

    $tickets = Ticket::query()
      ->whereIn('event_id', $eventIds->all())
      ->orderByRaw('CASE WHEN price IS NULL THEN 1 ELSE 0 END')
      ->orderBy('price')
      ->get(['event_id', 'price', 'f_price', 'pricing_type']);

    $ticketMap = [];
    foreach ($tickets as $ticket) {
      if (!array_key_exists((int) $ticket->event_id, $ticketMap)) {
        $ticketMap[(int) $ticket->event_id] = $ticket;
      }
    }

    return $events->map(function ($event) use ($ticketMap) {
      $ticket = $ticketMap[(int) $event->id] ?? null;

      if (!$ticket) {
        $event->price_display = null;
        $event->is_free = false;

        return $event;
      }

      $isPaidTicket = $ticket->price !== null || $ticket->pricing_type === 'variation';
      $event->price_display = $isPaidTicket ? symbolPrice($ticket->price ?? 0) : __('FREE');
      $event->is_free = !$isPaidTicket;

      return $event;
    });
  }
  //offline
  public function offline()
  {
    return view('frontend.offline');
  }

  public function about()
  {
    try {
      $language = $this->getLanguage();

      $queryResult['seoInfo'] = $language->seoInfo()->select('meta_keyword_home', 'meta_description_home')->first();

      // get the sections of selected home version
      $sectionInfo = Section::first();
      $queryResult['secInfo'] = $sectionInfo;

      $queryResult['secTitleInfo'] = $language->sectionTitle()->first();

      $queryResult['currencyInfo'] = $this->getCurrencyInfo();


      if ($sectionInfo->about_us_section_status == 1) {
        $queryResult['aboutUsInfo'] = $language->aboutUsSec()->first();
      }
      $queryResult['heroSection'] = HeroSection::where('language_id', $language->id)->first();

      $queryResult['aboutUsSection'] = AboutUsSection::where('language_id', $language->id)->first();

      if ($sectionInfo->testimonials_section_status == 1) {
        $queryResult['testimonialData'] = TestimonialSection::where('language_id', $language->id)->first();

        $queryResult['testimonials'] = Testimonial::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
      }

      $queryResult['featureEventSection'] = EventFeatureSection::where('language_id', $language->id)->first();
      $queryResult['featureEventItems'] = EventFeature::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();

      $queryResult['partnerInfo'] = PartnerSection::where('language_id', $language->id)->first();
      $queryResult['partners'] = Partner::orderBy('serial_number', 'asc')->get();
      $queryResult['footerInfo'] = FooterContent::where('language_id', $language->id)->first();
      $queryResult['quickLinkInfos'] = QuickLink::orderBy('serial_number', 'asc')->get();
      return view('frontend.about', $queryResult); //code...
    } catch (\Exception $th) {
    }
  }

  public function midtrans_cancel()
  {
    Session::forget('event_id');
    Session::forget('selTickets');
    Session::forget('arrData');
    Session::forget('paymentId');
    Session::forget('discount');
    Session::forget('token');

    return redirect()->route('index')->with(['alert-type' => 'error', 'message' => 'Payment Canceled.']);
  }
  public function xendit_callback(Request $request)
  {
    return $request->all();
    if (Session::get('xendit_payment_type') == 'event') {
      $data = new XenditController();
      $data->callback($request);
    } elseif (Session::get('xendit_payment_type') == 'shop') {
      $data = new ShopXenditController();
      $data->callback($request);
    }
  }

  public function myfatoorah_callback(Request $request)
  {
    $type = Session::get('myfatoorah_payment_type');
    if ($type == 'event') {
      $data = new MyFatoorahController();
      $data = $data->successCallback($request);
      // return redirect($data);
      Session::forget('myfatoorah_payment_type');
      if ($data['status'] == 'success') {
        return redirect()->route('event_booking.complete', ['id' => $data['event_id'], 'booking_id' => $data['booking_id']]);
      } else {
        return redirect()->route('check-out')->with(['alert-type' => 'error', 'message' => 'Payment Cancel']);
      }
    } elseif ($type == 'shop') {
      $data = new ShopGatewayMyFatoorahController();
      $data = $data->successCallback($request);
      Session::forget('myfatoorah_payment_type');
      if ($data['status'] == 'success') {
        return redirect()->route('product_order.complete');
      } else {
        return redirect()->route('shop.checkout')->with(['alert-type' => 'error', 'message' => 'Payment failed']);
      }
    }
  }

  public function myfatoorah_cancel(Request $request)
  {
    return redirect()->route('index')->with(['alert-type' => 'error', 'message' => 'Payment failed']);
  }

  public function testPDF(Request $request){

    $bookingInfo = Booking::orderBy('id','desc')->first();
    $fileName = $bookingInfo->booking_id . '.pdf';
    $directory = public_path('assets/admin/file/invoices/');
    @mkdir($directory, 0775, true);
    $fileLocated = $directory . $fileName;

    // get event title
    $language =  Language::where('is_default', 1)->first();
    $event = Event::find($bookingInfo->event_id);
    $eventInfo = EventContent::where('event_id', $bookingInfo->event_id)->where('language_id', $language->id)->first();

    $width = "50%";
    $float = "right";
    $mb = "35px";
    $ml = "18px";

    $pdf =  PDF::loadView('frontend.event.invoice', compact('bookingInfo', 'event', 'eventInfo', 'width', 'float', 'mb', 'ml', 'language'));
    return $pdf->stream('invoice.pdf');

    return view('frontend.event.invoice', compact('bookingInfo', 'event', 'eventInfo', 'width', 'float', 'mb', 'ml', 'language'));


    PDF::loadView('frontend.event.invoice', compact('bookingInfo', 'event', 'eventInfo', 'width', 'float', 'mb', 'ml', 'language'))->save($fileLocated);

  }

}
