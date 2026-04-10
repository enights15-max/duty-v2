<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Event;
use App\Models\Event\EventCategory;
use App\Models\Event\EventContent;
use App\Models\Organizer;
use App\Models\OrganizerInfo;
use App\Services\OrganizerPublicProfileService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use PHPMailer\PHPMailer\PHPMailer;

class OrganizerController extends Controller
{
  public function __construct(
    private OrganizerPublicProfileService $organizerPublicProfileService
  ) {
  }

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
      $information = [];
      $information['basicInfo'] = $this->basicInfo();

      if (filled($request->admin)) {
        $admin = Admin::first();
        $information['organizer'] = $admin;
        $information['admin'] = true;

        $relations = ['information' => function ($query) use ($language) {
          return $query->where('language_id', $language->id);
        }];
        if (Schema::hasTable('tickets')) {
          $relations[] = 'tickets';
        }

        $events = Event::with($relations)->where('organizer_id', NULL)->get();
        $information['organizer_info'] = [];
      } else {
        $target = $this->organizerPublicProfileService->resolveByPublicId($id, $language->id);
        if (!$target) {
          abort(404);
        }

        $payload = $this->organizerPublicProfileService->buildPublicPayload(
          $target,
          auth('customer')->user()
        );
        $legacyOrganizer = $target['legacy'];

        $information['organizer_info'] = (object) [
          'name' => $payload['name'],
          'details' => $payload['details'],
          'city' => $payload['city'],
          'state' => $payload['state'],
          'country' => $payload['country'],
          'address' => $payload['address'],
          'zip_code' => $payload['zip_code'],
          'designation' => $payload['designation'],
        ];

        $information['organizer'] = (object) [
          'id' => $payload['id'],
          'username' => $legacyOrganizer?->username ?? $payload['username'],
          'photo' => $payload['photo'],
          'email' => $payload['email'],
          'phone' => $payload['phone'],
          'facebook' => $payload['facebook'],
          'twitter' => $payload['twitter'],
          'linkedin' => $payload['linkedin'],
          'created_at' => $target['created_at'],
        ];
        $information['admin'] = false;

        $relations = ['information' => function ($query) use ($language) {
          return $query->where('language_id', $language->id);
        }];
        if (Schema::hasTable('tickets')) {
          $relations[] = 'tickets';
        }

        $events = Event::with($relations)->ownedByOrganizerActor(
          $target['identity']?->id,
          $target['legacy_id']
        )->orderBy('start_date')->get();
        
      }

      $categories = EventCategory::where('status', 1)
        ->where('language_id', $language->id)
        ->orderBy('serial_number', 'asc')->get();
      $information['categories'] = $categories;


      $information['events'] = $events;
      return view('frontend.organizer.details', $information); //code...
    } catch (\Exception $th) {
      if (app()->environment('testing')) {
        throw $th;
      }

      return view('errors.404');
    }
  }

  private function basicInfo(): object
  {
    if (!Schema::hasTable('basic_settings')) {
      return (object) [
        'breadcrumb' => null,
        'google_recaptcha_status' => 0,
      ];
    }

    $columns = collect(['breadcrumb', 'google_recaptcha_status'])
      ->filter(fn (string $column) => Schema::hasColumn('basic_settings', $column))
      ->values()
      ->all();

    $basicInfo = !empty($columns)
      ? DB::table('basic_settings')->select($columns)->first()
      : null;

    return (object) array_merge([
      'breadcrumb' => null,
      'google_recaptcha_status' => 0,
    ], (array) $basicInfo);
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
