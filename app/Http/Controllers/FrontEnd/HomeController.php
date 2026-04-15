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
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class HomeController extends Controller
{
  private $now_date_time;
  public function __construct()
  {
    $this->now_date_time = Carbon::now();
  }
  public function index()
  {
    try {
      $tickets = Ticket::get();
      $tController = new TicketController;
      foreach ($tickets as $tickets) {
        $tController->includeSlotSystemVariable($tickets->id);
      }


      $language = $this->getLanguage();

      $queryResult['seoInfo'] = $this->getSeoInfo($language, ['meta_keyword_home', 'meta_description_home']);

      // get the sections of selected home version
      $sectionInfo = $this->safeFirst((new Section())->getTable(), function () {
        return Section::first();
      }, (object) [
        'featured_section_status' => 0,
        'categories_section_status' => 0,
        'about_section_status' => 0,
        'features_section_status' => 0,
        'how_work_section_status' => 0,
        'testimonials_section_status' => 0,
        'partner_section_status' => 0,
      ]);
      $queryResult['secInfo'] = $sectionInfo;

      $queryResult['heroInfo'] = $this->safeFirst((new HeroSection())->getTable(), function () use ($language) {
        return $language->heroSec()->first();
      });

      $queryResult['secTitleInfo'] = $this->safeFirst('section_titles', function () use ($language) {
        return $language->sectionTitle()->first();
      });

      $categories = $this->safeGet((new EventCategory())->getTable(), function () use ($language) {
        return $language->event_category()
          ->where('status', 1)
          ->where('is_featured', '=', 'yes')
          ->orderBy('serial_number', 'asc')
          ->get();
      });


      $queryResult['categories'] = $categories;

      $queryResult['currencyInfo'] = $this->getCurrencyInfo();

      if ($sectionInfo->features_section_status == 1) {
        $queryResult['featureData'] = $this->safeFirst('basic_settings', function () {
          return Basic::select('features_section_image')->first();
        });

        $queryResult['features'] = $this->safeGet('features', function () use ($language) {
          return $language->feature()->orderBy('serial_number', 'asc')->get();
        });
      }


      if ($sectionInfo->about_us_section_status == 1) {
        $queryResult['aboutUsInfo'] = $this->safeFirst((new AboutUsSection())->getTable(), function () use ($language) {
          return $language->aboutUsSec()->first();
        });
      }
      $queryResult['heroSection'] = $this->safeFirst((new HeroSection())->getTable(), function () use ($language) {
        return HeroSection::where('language_id', $language->id)->first();
      });
      $queryResult['eventCategories'] = $this->safeGet((new EventCategory())->getTable(), function () use ($language) {
        return EventCategory::where([['language_id', $language->id], ['status', 1], ['is_featured', 'yes']])
          ->orderBy('serial_number', 'asc')
          ->get();
      });

      $queryResult['aboutUsSection'] = $this->safeFirst((new AboutUsSection())->getTable(), function () use ($language) {
        return AboutUsSection::where('language_id', $language->id)->first();
      });

      $queryResult['featureEventSection'] = $this->safeFirst((new EventFeatureSection())->getTable(), function () use ($language) {
        return EventFeatureSection::where('language_id', $language->id)->first();
      });
      $queryResult['featureEventItems'] = $this->safeGet((new EventFeature())->getTable(), function () use ($language) {
        return EventFeature::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
      });

      $queryResult['howWork'] = $this->safeFirst((new HowWork())->getTable(), function () use ($language) {
        return HowWork::where('language_id', $language->id)->first();
      });
      $queryResult['howWorkItems'] = $this->safeGet((new HowWorkItem())->getTable(), function () use ($language) {
        return HowWorkItem::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
      });

      if ($sectionInfo->testimonials_section_status == 1) {
        $queryResult['testimonialData'] = $this->safeFirst((new TestimonialSection())->getTable(), function () use ($language) {
          return TestimonialSection::where('language_id', $language->id)->first();
        });

        $queryResult['testimonials'] = $this->safeGet((new Testimonial())->getTable(), function () use ($language) {
          return Testimonial::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
        });
      }

      $queryResult['partnerInfo'] = $this->safeFirst((new PartnerSection())->getTable(), function () use ($language) {
        return PartnerSection::where('language_id', $language->id)->first();
      });
      $queryResult['partners'] = $this->safeGet((new Partner())->getTable(), function () {
        return Partner::orderBy('serial_number', 'asc')->get();
      });
      $queryResult['footerInfo'] = $this->safeFirst((new FooterContent())->getTable(), function () use ($language) {
        return FooterContent::where('language_id', $language->id)->first();
      });
      $queryResult['quickLinkInfos'] = $this->safeGet((new QuickLink())->getTable(), function () {
        return QuickLink::orderBy('serial_number', 'asc')->get();
      });

      return view('frontend.home.index-v1', $queryResult);
    } catch (\Throwable $exception) {
      report($exception);

      if (app()->environment('local', 'testing')) {
        throw $exception;
      }

      return view('landing');
    }
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

      $queryResult['seoInfo'] = $this->getSeoInfo($language, ['meta_keyword_home', 'meta_description_home']);

      // get the sections of selected home version
      $sectionInfo = $this->safeFirst((new Section())->getTable(), function () {
        return Section::first();
      }, (object) [
        'about_us_section_status' => 0,
        'testimonials_section_status' => 0,
      ]);
      $queryResult['secInfo'] = $sectionInfo;

      $queryResult['secTitleInfo'] = $this->safeFirst('section_titles', function () use ($language) {
        return $language->sectionTitle()->first();
      });

      $queryResult['currencyInfo'] = $this->getCurrencyInfo();


      if ($sectionInfo->about_us_section_status == 1) {
        $queryResult['aboutUsInfo'] = $this->safeFirst((new AboutUsSection())->getTable(), function () use ($language) {
          return $language->aboutUsSec()->first();
        });
      }
      $queryResult['heroSection'] = $this->safeFirst((new HeroSection())->getTable(), function () use ($language) {
        return HeroSection::where('language_id', $language->id)->first();
      });

      $queryResult['aboutUsSection'] = $this->safeFirst((new AboutUsSection())->getTable(), function () use ($language) {
        return AboutUsSection::where('language_id', $language->id)->first();
      });

      if ($sectionInfo->testimonials_section_status == 1) {
        $queryResult['testimonialData'] = $this->safeFirst((new TestimonialSection())->getTable(), function () use ($language) {
          return TestimonialSection::where('language_id', $language->id)->first();
        });

        $queryResult['testimonials'] = $this->safeGet((new Testimonial())->getTable(), function () use ($language) {
          return Testimonial::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
        });
      }

      $queryResult['featureEventSection'] = $this->safeFirst((new EventFeatureSection())->getTable(), function () use ($language) {
        return EventFeatureSection::where('language_id', $language->id)->first();
      });
      $queryResult['featureEventItems'] = $this->safeGet((new EventFeature())->getTable(), function () use ($language) {
        return EventFeature::where('language_id', $language->id)->orderBy('serial_number', 'asc')->get();
      });

      $queryResult['partnerInfo'] = $this->safeFirst((new PartnerSection())->getTable(), function () use ($language) {
        return PartnerSection::where('language_id', $language->id)->first();
      });
      $queryResult['partners'] = $this->safeGet((new Partner())->getTable(), function () {
        return Partner::orderBy('serial_number', 'asc')->get();
      });
      $queryResult['footerInfo'] = $this->safeFirst((new FooterContent())->getTable(), function () use ($language) {
        return FooterContent::where('language_id', $language->id)->first();
      });
      $queryResult['quickLinkInfos'] = $this->safeGet((new QuickLink())->getTable(), function () {
        return QuickLink::orderBy('serial_number', 'asc')->get();
      });
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
