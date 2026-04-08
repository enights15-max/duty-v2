<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Event;
use App\Models\Event\EventCategory;
use App\Models\Event\EventContent;
use App\Models\Event\Ticket;
use App\Models\Organizer;
use App\Models\OrganizerInfo;
<<<<<<< Updated upstream
=======
use App\Services\OrganizerPublicProfileService;
use Carbon\Carbon;
>>>>>>> Stashed changes
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use PHPMailer\PHPMailer\PHPMailer;

class OrganizerController extends Controller
{
  //show
  public function index(Request $request)
  {
    $language = $this->getLanguage();

    $organizer_name = $username = $location = null;

    $organizerIds = [];
    if ($request->filled('organizer')) {
      $organizer_name = $request->organizer;

      $organizer_infos = OrganizerInfo::where('name', 'like', '%' . $organizer_name . '%')
        ->where('language_id', $language->id)
        ->get();
      foreach ($organizer_infos as $info) {
        if (!in_array($info->organizer_id, $organizerIds)) {
          array_push($organizerIds, $info->organizer_id);
        }
      }
    }
    if ($request->filled('username')) {
      $username = $request->username;
    }
    $locationIds = [];
    if ($request->filled('location')) {
      $location = $request->location;
      $organizer_infos = OrganizerInfo::where('city', 'like', '%' . $location . '%')
        ->orWhere('state', 'like', '%' . $location . '%')
        ->orWhere('country', 'like', '%' . $location . '%')
        ->orWhere('address', 'like', '%' . $location . '%')
        ->where('language_id', $language->id)
        ->get();
      foreach ($organizer_infos as $info) {
        if (!in_array($info->organizer_id, $locationIds)) {
          array_push($locationIds, $info->organizer_id);
        }
      }
    }

    $collection = Organizer::with(['organizer_info' => function ($query) use ($language) {
      return $query->where('language_id', $language->id);
    }])->when($username, function ($query) use ($username) {
      return $query->where('username', 'like', '%' . $username . '%');
    })
      ->when($location, function ($query) use ($locationIds) {
        return $query->whereIn('id', $locationIds);
      })
      ->when($organizer_name, function ($query) use ($organizerIds) {
        return $query->whereIn('id', $organizerIds);
      })
      ->paginate(20);

    return view('frontend.organizer.index', compact('collection'));
  }

  public function details(Request $request, $id, $name)
  {
    try {
      $language = $this->getLanguage();
      $profileService = app(OrganizerPublicProfileService::class);
      $information = [];
      $information['basicInfos'] = DB::table('basic_settings')
        ->select('google_recaptcha_status')
        ->first();

      $categories = EventCategory::where('status', 1)
        ->where('language_id', $language->id)
        ->orderBy('serial_number', 'asc')
        ->get();

      $eventQuery = Event::with([
        'tickets',
        'lineups',
        'information' => function ($query) use ($language) {
          return $query->where('language_id', $language->id);
        },
      ])->orderByRaw('CASE WHEN end_date_time IS NULL OR end_date_time >= ? THEN 0 ELSE 1 END', [Carbon::now()])
        ->orderBy('start_date')
        ->orderBy('start_time');

      if (filled($request->admin)) {
        $admin = Admin::first();
        $information['organizer'] = (object) [
          'id' => $admin->id,
          'username' => $admin->username,
          'photo' => $admin->image,
          'created_at' => $admin->created_at,
          'facebook' => null,
          'linkedin' => null,
          'twitter' => null,
          'details' => null,
        ];
        $information['admin'] = true;

        $events = (clone $eventQuery)
          ->whereNull('organizer_id')
          ->get();
        $information['organizer_info'] = (object) [
          'name' => $admin->username,
          'details' => null,
          'city' => null,
          'state' => null,
          'country' => null,
          'address' => null,
          'zip_code' => null,
          'designation' => __('Platform host'),
        ];
        $information['organizerProfile'] = [
          'id' => (int) $admin->id,
          'identity_id' => null,
          'legacy_organizer_id' => null,
          'supports_follow' => false,
          'supports_contact' => false,
          'supports_reviews' => false,
          'photo' => $admin->image ? asset('assets/admin/img/admins/' . $admin->image) : asset('assets/front/images/user.png'),
          'cover_photo' => null,
          'phone' => null,
          'email' => $admin->email ?? null,
          'username' => $admin->username,
          'status' => 1,
          'facebook' => null,
          'twitter' => null,
          'linkedin' => null,
          'organizer_name' => $admin->username,
          'name' => $admin->username,
          'country' => null,
          'city' => null,
          'state' => null,
          'address' => null,
          'zip_code' => null,
          'designation' => __('Platform host'),
          'details' => null,
          'user_type' => 'organizer',
          'followers_count' => 0,
          'events_count' => $events->count(),
          'is_followed' => false,
          'average_rating' => '0.0',
          'review_count' => 0,
          'reviews' => collect(),
          'identity' => null,
        ];
      } else {
<<<<<<< Updated upstream
        $organizer = Organizer::where('id', $id)->first();
=======
        $target = $profileService->resolveByPublicId($id, $language->id);
        if (!$target) {
          return view('errors.404');
        }
>>>>>>> Stashed changes

        $information['organizer_info'] = OrganizerInfo::where('organizer_id', $id)->where('language_id', $language->id)->first();

        $information['organizer'] = $organizer;
        $information['admin'] = false;
        $information['organizerProfile'] = $profileService->buildPublicPayload(
          $target,
          Auth::guard('customer')->user()
        );

<<<<<<< Updated upstream
        $events = Event::with(['tickets', 'information' => function ($query) use ($language) {
          return $query->where('language_id', $language->id);
        }])->where('organizer_id', $organizer->id)->get();
        
=======
        $events = (clone $eventQuery)
          ->ownedByOrganizerActor($identity?->id, $target['legacy_id'])
          ->get();
>>>>>>> Stashed changes
      }

      $information['categories'] = $categories;
      $information['events'] = $this->prepareOrganizerEvents($events, $categories);
      $information['categoryTabs'] = $this->buildCategoryTabs($categories, $information['events']);
      return view('frontend.organizer.details', $information); //code...
    } catch (\Exception $th) {
      return view('errors.404');
    }
  }

  private function prepareOrganizerEvents(Collection $events, Collection $categories): Collection
  {
    $categoriesById = $categories->keyBy('id');

    return $events
      ->filter(fn($event) => !empty($event->information))
      ->map(function (Event $event) use ($categoriesById) {
        $content = $event->information;
        $category = $categoriesById->get($content->event_category_id);

        $eventDate = null;
        if ($event->date_type === 'multiple') {
          $eventDate = eventLatestDates($event->id);
        }

        $startDate = $eventDate?->start_date ?: $event->start_date;
        $duration = $eventDate?->duration ?: $event->duration;
        $startDateTime = null;
        if (!empty($startDate) && !empty($event->start_time)) {
          try {
            $startDateTime = Carbon::parse(trim($startDate . ' ' . $event->start_time));
          } catch (Exception $exception) {
            $startDateTime = null;
          }
        }

        $endDateTime = null;
        if (!empty($event->end_date_time)) {
          try {
            $endDateTime = Carbon::parse($event->end_date_time);
          } catch (Exception $exception) {
            $endDateTime = null;
          }
        }

        $statusLabel = __('Upcoming');
        $statusClass = 'upcoming';
        if ($endDateTime && $endDateTime->isPast()) {
          $statusLabel = __('Over');
          $statusClass = 'over';
        } elseif ($startDateTime && $startDateTime->isPast()) {
          $statusLabel = __('Live');
          $statusClass = 'live';
        }

        $ticketPreview = $this->buildTicketPreview($event->tickets);
        $description = trim(strip_tags((string) ($content->description ?? '')));

        $event->event_url = route('event.details', [$content->slug, $event->id]);
        $event->category_name = $category?->name ?? __('Event');
        $event->category_slug = $category?->slug ?? 'all';
        $event->date_badge = $startDate ? Carbon::parse($startDate)->translatedFormat('M d') : __('Date TBD');
        $event->date_full = $startDate ? Carbon::parse($startDate)->translatedFormat('D, M d') : __('Date TBD');
        $event->time_badge = !empty($event->start_time)
          ? Carbon::parse($event->start_time)->translatedFormat('h:i A')
          : __('Time TBD');
        $event->duration_badge = $duration ?: __('Schedule TBD');
        $event->location_badge = $event->event_type === 'venue'
          ? ($content->address ?: __('Venue to be announced'))
          : __('Online event');
        $event->status_label = $statusLabel;
        $event->status_class = $statusClass;
        $event->short_description = mb_strlen($description) > 140
          ? mb_substr($description, 0, 140) . '...'
          : ($description ?: __('More details will be announced soon.'));
        $event->price_display = $ticketPreview['price_display'];
        $event->price_hint = $ticketPreview['price_hint'];
        $event->is_free = $ticketPreview['is_free'];
        $event->ticket_count = $event->tickets->count();
        $event->lineup_count = $event->lineups->count();

        return $event;
      })
      ->values();
  }

  private function buildCategoryTabs(Collection $categories, Collection $events): Collection
  {
    $counts = $events
      ->groupBy(fn($event) => $event->category_slug ?? 'all')
      ->map(fn(Collection $group) => $group->count());

    return $categories
      ->map(function ($category) use ($counts) {
        $category->event_count = (int) ($counts[$category->slug] ?? 0);

        return $category;
      })
      ->filter(fn($category) => $category->event_count > 0)
      ->values();
  }

  private function buildTicketPreview(Collection $tickets): array
  {
    if ($tickets->isEmpty()) {
      return [
        'price_display' => __('Tickets soon'),
        'price_hint' => __('Lineup and ticket drops coming next.'),
        'is_free' => false,
      ];
    }

    $ticket = $tickets
      ->sort(function (Ticket $first, Ticket $second) {
        $firstValue = $this->ticketComparablePrice($first);
        $secondValue = $this->ticketComparablePrice($second);

        return $firstValue <=> $secondValue;
      })
      ->first();

    $priceValue = $this->ticketComparablePrice($ticket);
    if ($priceValue === 0.0 && $ticket->pricing_type !== 'variation' && $ticket->price === null && $ticket->f_price === null) {
      return [
        'price_display' => __('Free'),
        'price_hint' => __('Open access'),
        'is_free' => true,
      ];
    }

    return [
      'price_display' => symbolPrice($priceValue),
      'price_hint' => $tickets->count() > 1 ? __('From the lowest ticket tier') : __('Current starting tier'),
      'is_free' => false,
    ];
  }

  private function ticketComparablePrice(Ticket $ticket): float
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

    if ($ticket->normal_ticket_slot_enable == 1 && $ticket->slot_seat_min_price !== null) {
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


  public function sendMail(Request $request)
  {

    $info = DB::table('basic_settings')
      ->select('google_recaptcha_status', 'website_title', 'smtp_status', 'smtp_host', 'smtp_port', 'encryption', 'smtp_username', 'smtp_password', 'from_mail', 'from_name', 'email_address')
      ->first();

    $rules = [
      'name' => 'required',
      'email' => 'required',
      'subject' => 'required',
      'message' => 'required'
    ];
    if ($info->google_recaptcha_status == 1) {
      $rules['g-recaptcha-response'] = 'required|captcha';
    }

    $msgs = [];

    if ($info->google_recaptcha_status == 1) {
      $msgs['g-recaptcha-response.required'] = 'Please verify that you are not a robot.';
      $msgs['g-recaptcha-response.captcha'] = 'Captcha error! try again later or contact site admin.';
    }

    $validator = Validator::make($request->all(), $rules);

    if ($validator->fails()) {
      return response()->json([
        'errors' => $validator->getMessageBag()->toArray()
      ], 400);
    }
    $organizer = Organizer::where('id', $request->id)->first();


    $name = $request->name;
    $subject = $request->subject;

    $message = '<p>Message : ' . $request->message . '</p> <p><strong>Enquirer Name: </strong>' . $name . '<br/><strong>Enquirer Mail: </strong>' . $request->email . '</p>';

    $mail = new PHPMailer(true);
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    if ($info->smtp_status == 1) {

      $mail->isSMTP();
      $mail->Host       = $info->smtp_host;
      $mail->SMTPAuth   = true;
      $mail->Username   = $info->smtp_username;
      $mail->Password   = $info->smtp_password;

      if ($info->encryption == 'TLS') {
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
      }

      $mail->Port       = $info->smtp_port;
    }

    try {
      $mail->setFrom($info->from_mail, $info->from_name);
      $mail->addAddress($organizer->email);

      $mail->isHTML(true);
      $mail->Subject = $subject;
      $mail->Body = $message;

      $mail->send();

      Session::flash('message', 'Your contact request send to organizer successfully.');
      Session::flash('alert-type', 'success');
    } catch (\Exception $e) {
      Session::flash('message', 'Something went wrong');
      Session::flash('alert-type', 'error');
    }

    return 'success';
  }
}
