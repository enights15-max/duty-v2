<?php

namespace App\Http\Controllers\BackEnd\Event;

use Carbon\Carbon;
use App\Models\City;
use App\Models\Event;
use App\Models\Identity;
use App\Models\State;
use App\Models\Country;
use App\Models\Language;
use App\Models\Organizer;
use App\Models\Event\Ticket;
use Illuminate\Http\Request;
use App\Models\Artist;
use App\Models\Event\EventCity;
use App\Models\Event\EventDates;
use App\Models\Event\EventImage;
use App\Models\Event\EventState;
use App\Models\Event\EventContent;
use App\Models\Event\EventCountry;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Mews\Purifier\Facades\Purifier;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Session;
use App\Http\Requests\Event\StoreRequest;
use Illuminate\Support\Facades\Validator;
use App\Http\Requests\Event\UpdateRequest;
use App\Http\Requests\TicketSettingRequest;
use App\Services\EventAuthoringService;
use App\Services\EventCloneService;
use App\Services\EventCollaboratorSplitService;
use App\Services\EventQrCodeService;
use App\Services\NotificationService;

class EventController extends Controller
{
  protected NotificationService $notificationService;
  protected EventCollaboratorSplitService $eventCollaboratorSplitService;

  public function __construct(
    NotificationService $notificationService,
    EventCollaboratorSplitService $eventCollaboratorSplitService
  )
  {
    $this->notificationService = $notificationService;
    $this->eventCollaboratorSplitService = $eventCollaboratorSplitService;
  }

  //index
  public function index(Request $request)
  {
    $information['langs'] = Language::all();

    $language = Language::where('code', $request->language)->firstOrFail();
    $information['language'] = $language;
    $lifecycle = $request->input('lifecycle', 'all');
    $statusFilter = $request->input('status_filter', 'all');
    $statusFilter = in_array($statusFilter, ['all', 'active', 'inactive'], true) ? $statusFilter : 'all';
    $submissionFilter = $request->input('submission_filter', 'all');
    $submissionFilter = in_array($submissionFilter, ['all', 'app_submitted', 'admin_authored'], true)
      ? $submissionFilter
      : 'all';
    $viewMode = $request->filled('view_mode')
      ? $request->input('view_mode')
      : Session::get('admin.events.index.view_mode', 'list');
    $viewMode = in_array($viewMode, ['list', 'grid'], true) ? $viewMode : 'list';

    $gridColumns = $request->filled('grid_columns')
      ? (int) $request->input('grid_columns')
      : (int) Session::get('admin.events.index.grid_columns', 3);
    $gridColumns = in_array($gridColumns, [2, 3, 4], true) ? $gridColumns : 3;

    $gridDensity = $request->filled('grid_density')
      ? $request->input('grid_density')
      : Session::get('admin.events.index.grid_density', 'comfortable');
    $gridDensity = in_array($gridDensity, ['comfortable', 'compact'], true) ? $gridDensity : 'comfortable';

    $sortBy = $request->filled('sort_by')
      ? $request->input('sort_by')
      : Session::get('admin.events.index.sort_by', 'timeline');
    $sortBy = in_array($sortBy, ['timeline', 'newest', 'oldest', 'title_asc', 'title_desc'], true) ? $sortBy : 'timeline';
    $featuredOnly = $request->boolean('featured_only');

    Session::put('admin.events.index.view_mode', $viewMode);
    Session::put('admin.events.index.grid_columns', $gridColumns);
    Session::put('admin.events.index.grid_density', $gridDensity);
    Session::put('admin.events.index.sort_by', $sortBy);

    $now = Carbon::now()->toDateTimeString();
    $effectiveEndExpression = "COALESCE((SELECT MAX(event_dates.end_date_time) FROM event_dates WHERE event_dates.event_id = events.id), events.end_date_time)";

    $event_type = null;
    if (filled($request->event_type)) {
      $event_type = $request->event_type;
    }
    $title = null;
    if (request()->filled('title')) {
      $title = request()->input('title');
    }

    $events = Event::join('event_contents', 'event_contents.event_id', '=', 'events.id')
      ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
      ->where('event_contents.language_id', '=', $language->id)
      ->when($title, function ($query) use ($title) {
        return $query->where('event_contents.title', 'like', '%' . $title . '%');
      })
      ->when($event_type, function ($query) use ($event_type) {
        return $query->where('events.event_type', $event_type);
      })
      ->when($statusFilter === 'active', function ($query) {
        return $query->where('events.status', 1);
      })
      ->when($statusFilter === 'inactive', function ($query) {
        return $query->where('events.status', 0);
      })
      ->when($featuredOnly, function ($query) {
        return $query->where('events.is_featured', 'yes');
      });

    $information['lifecycleCounts'] = [
      'all' => (clone $baseQuery)->count(),
      'current' => (clone $baseQuery)
        ->whereRaw("({$effectiveEndExpression} IS NULL OR {$effectiveEndExpression} >= ?)", [$now])
        ->count(),
      'expired' => (clone $baseQuery)
        ->whereRaw("{$effectiveEndExpression} < ?", [$now])
        ->count(),
    ];

    $information['submissionCounts'] = [
      'all' => (clone $baseQuery)->count(),
      'app_submitted' => (clone $baseQuery)
        ->where(function ($query) {
          $query->whereNotNull('events.owner_identity_id')
            ->orWhereNotNull('events.venue_identity_id');
        })
        ->count(),
      'admin_authored' => (clone $baseQuery)
        ->whereNull('events.owner_identity_id')
        ->whereNull('events.venue_identity_id')
        ->count(),
    ];

    $events = (clone $baseQuery)
      ->select('events.*', 'event_contents.id as eventInfoId', 'event_contents.title', 'event_contents.slug', 'event_categories.name as category')
      ->selectRaw("{$effectiveEndExpression} as effective_end_date_time")
      ->selectRaw("CASE WHEN {$effectiveEndExpression} IS NOT NULL AND {$effectiveEndExpression} < ? THEN 1 ELSE 0 END as is_expired", [$now])
      ->when($submissionFilter === 'app_submitted', function ($query) {
        return $query->where(function ($builder) {
          $builder->whereNotNull('events.owner_identity_id')
            ->orWhereNotNull('events.venue_identity_id');
        });
      })
      ->when($submissionFilter === 'admin_authored', function ($query) {
        return $query->whereNull('events.owner_identity_id')
          ->whereNull('events.venue_identity_id');
      })
      ->when($lifecycle === 'current', function ($query) use ($effectiveEndExpression, $now) {
        return $query->whereRaw("({$effectiveEndExpression} IS NULL OR {$effectiveEndExpression} >= ?)", [$now]);
      })
      ->when($lifecycle === 'expired', function ($query) use ($effectiveEndExpression, $now) {
        return $query->whereRaw("{$effectiveEndExpression} < ?", [$now]);
      })
      ->when($sortBy === 'timeline', function ($query) use ($effectiveEndExpression, $now) {
        return $query
          ->orderByRaw("CASE WHEN {$effectiveEndExpression} IS NOT NULL AND {$effectiveEndExpression} < ? THEN 1 ELSE 0 END ASC", [$now])
          ->orderByRaw("CASE WHEN {$effectiveEndExpression} IS NULL OR {$effectiveEndExpression} >= ? THEN COALESCE({$effectiveEndExpression}, '9999-12-31 23:59:59') END ASC", [$now])
          ->orderByRaw("CASE WHEN {$effectiveEndExpression} < ? THEN {$effectiveEndExpression} END DESC", [$now])
          ->orderByDesc('events.id');
      })
      ->when($sortBy === 'newest', function ($query) {
        return $query
          ->orderByDesc('events.created_at')
          ->orderByDesc('events.id');
      })
      ->when($sortBy === 'oldest', function ($query) {
        return $query
          ->orderBy('events.created_at')
          ->orderBy('events.id');
      })
      ->when($sortBy === 'title_asc', function ($query) {
        return $query
          ->orderBy('event_contents.title')
          ->orderByDesc('events.id');
      })
      ->when($sortBy === 'title_desc', function ($query) {
        return $query
          ->orderByDesc('event_contents.title')
          ->orderByDesc('events.id');
      })
      ->paginate(10);

    if ($this->eventCollaboratorSplitService->supportsCollaboratorEconomy()) {
      $events->getCollection()->transform(function ($event) {
        $summary = $this->eventCollaboratorSplitService->eventSummary((int) $event->id);
        $activity = collect($summary['activity'] ?? [])
          ->sortByDesc('occurred_at')
          ->values();

        $event->collaboration_summary_preview = [
          'claimable_count' => (int) ($summary['claimable_count'] ?? 0),
          'reserved_for_collaborators' => round((float) ($summary['reserved_for_collaborators'] ?? 0), 2),
          'distributable_amount' => round((float) ($summary['distributable_amount'] ?? 0), 2),
          'latest_activity' => $activity->first(),
          'has_activity' => $activity->isNotEmpty(),
        ];

        return $event;
      });
    }

    $information['events'] = $events;
    $information['statusFilter'] = $statusFilter;
    $information['submissionFilter'] = $submissionFilter;
    $information['sortBy'] = $sortBy;
    $information['featuredOnly'] = $featuredOnly;
    $information['viewMode'] = $viewMode;
    $information['gridColumns'] = $gridColumns;
    $information['gridDensity'] = $gridDensity;
    $information['getCurrencyInfo'] = $this->getCurrencyInfo();
    return view('backend.event.index', $information);
  }
  //choose_event_type
  public function choose_event_type()
  {
    return view('backend.event.event_type');
  }
  //online_event
  public function add_event()
  {
    $information = [];
    $languages = Language::get();
    $information['languages'] = $languages;
    // $countries = Country::get();
    // $information['countries'] = $countries;
    $organizers = Organizer::get();
    $information['organizers'] = $organizers;

    $artists = Artist::where('status', 1)->get();
    $information['artists'] = $artists;

    $information['getCurrencyInfo'] = $this->getCurrencyInfo();
    return view('backend.event.create', $information);
  }

  public function gallerystore(Request $request)
  {

    $rules = [
      'file' => 'required|image|mimes:jpg,jpeg,png'
    ];
    $messages = [
      'file.required' => 'Please upload an image file.',
      'file.image' => 'The uploaded file must be an image.',
      'file.mimes' => 'Only jpg, jpeg, and png files are allowed.'
    ];

    $validator = Validator::make($request->all(), $rules, $messages);
    if ($validator->fails()) {
      $validator->getMessageBag()->add('error', 'true');
      return response()->json($validator->errors(), 422);
    }

    $img = $request->file('file');
    list($width, $height) = getimagesize($img->getPathname());

    if ($width != 1170 || $height != 570) {
      return response()->json([
        'status' => 'error',
        'msg' => 'The image dimensions must be exactly 1170x570 pixels.'
      ]);
    }

    $filename = uniqid() . '.jpg';
    $uploadPath = public_path('assets/admin/img/event-gallery/');
    if (!file_exists($uploadPath)) {
      @mkdir($uploadPath, 0775, true);
    }
    $img->move($uploadPath, $filename);

    $pi = new EventImage;
    $pi->event_id = $request->event_id ?? null;
    $pi->image = $filename;
    $pi->save();

    return response()->json([
      'status' => 'success',
      'file_id' => $pi->id
    ]);
  }


  public function imagermv(Request $request)
  {
    $pi = EventImage::where('id', $request->fileid)->first();
    @unlink(public_path('assets/admin/img/event-gallery/') . $pi->image);
    $pi->delete();
    return $pi->id;
  }

  public function store(StoreRequest $request)
  {

    //calculate duration
    if ($request->date_type == 'single') {
      $start = Carbon::parse($request->start_date . $request->start_time);
      $end = Carbon::parse($request->end_date . $request->end_time);
      $diffent = DurationCalulate($start, $end);
    }
    //calculate duration end

    $in = $request->all();
    $in['duration'] = $request->date_type == 'single' ? $diffent : '';

    $img = $request->file('thumbnail');

    $in['organizer_id'] = $request->organizer_id;

    // Link to Identity from Organizer (if present)
    if ($request->filled('organizer_id')) {
      $identity = \App\Models\Identity::where('type', 'organizer')
        ->where('meta->id', $request->organizer_id)
        ->first();
      if ($identity) {
        $in['owner_identity_id'] = $identity->id;
      }
    }

    // Link to Identity from Venue (if present)
    if ($request->filled('venue_id')) {
      $vIdentity = \App\Models\Identity::where('type', 'venue')
        ->where('meta->id', $request->venue_id)
        ->first();
      if ($vIdentity) {
        $in['venue_identity_id'] = $vIdentity->id;
      }
    }

    if ($request->hasFile('thumbnail')) {
      $filename = time() . '.' . $img->getClientOriginalExtension();
      $directory = public_path('assets/admin/img/event/thumbnail/');
      @mkdir($directory, 0775, true);
      $request->file('thumbnail')->move($directory, $filename);
      $in['thumbnail'] = $filename;
    }
    $in['f_price'] = $request->price;
    $in['end_date_time'] = Carbon::parse($request->end_date . ' ' . $request->end_time);
    $event = Event::create($in);

    if ($request->filled('artist_ids')) {
      $event->artists()->sync($request->artist_ids);
    }

    if ($request->date_type == 'multiple') {
      $i = 1;
      foreach ($request->m_start_date as $key => $date) {
        $start = Carbon::parse($date . $request->m_start_time[$key]);
        $end = Carbon::parse($request->m_end_date[$key] . $request->m_end_time[$key]);
        $diffent = DurationCalulate($start, $end);

        EventDates::create([
          'event_id' => $event->id,
          'start_date' => $date,
          'start_time' => $request->m_start_time[$key],
          'end_date' => $request->m_end_date[$key],
          'end_time' => $request->m_end_time[$key],
          'duration' => $diffent,
          'start_date_time' => $start,
          'end_date_time' => $end,
        ]);
        if ($i == 1) {
          $event->update([
            'duration' => $diffent
          ]);
        }
        $i++;
      }
      //update event date time
      $event_date = EventDates::where('event_id', $event->id)->orderBy('end_date_time', 'desc')->first();

      $event->end_date_time = $event_date->end_date_time;
      $event->save();
    }


    $in['event_id'] = $event->id;
    if ($request->event_type == 'online') {
      if (!$request->pricing_type) {
        $in['pricing_type'] = 'normal';
      }
      $in['early_bird_discount'] = $request->early_bird_discount_type;
      $in['early_bird_discount_type'] = $request->discount_type;
      Ticket::create($in);
    }

    //event slider-images
    $slders = $request->slider_images;
    foreach ($slders as $key => $id) {
      $event_image = EventImage::where('id', $id)->first();
      if ($event_image) {
        $event_image->event_id = $event->id;
        $event_image->save();
      }
    }

    //event content
    $languages = Language::all();
    foreach ($languages as $language) {
      $event_content = new EventContent();
      $event_content->language_id = $language->id;
      $event_content->event_category_id = $request[$language->code . '_category_id'];
      $event_content->event_id = $event->id;
      $event_content->title = $request[$language->code . '_title'];
      if ($request->event_type == 'venue') {
        $event_content->address = $request[$language->code . '_address'];
        $event_content->country_id = $request[$language->code . '_country'];
        $event_content->city_id = $request[$language->code . '_city'];
        $event_content->state_id = $request[$language->code . '_state'];
        $event_content->zip_code = $request[$language->code . '_zip_code'];
      }
      $event_content->slug = createSlug($request[$language->code . '_title']);
      $event_content->description = Purifier::clean($request[$language->code . '_description'], 'youtube');
      $event_content->refund_policy = $request[$language->code . '_refund_policy'];
      $event_content->meta_keywords = $request[$language->code . '_meta_keywords'];
      $event_content->meta_description = $request[$language->code . '_meta_description'];
      $event_content->save();
    }

    Session::flash('success', 'Added Successfully');
    return response()->json(['status' => 'success'], 200);
  }

  /**
   * delete events dates
   */
  public function deleteDate($id)
  {
    $date = EventDates::where('id', $id)->first();
    $date->delete();
    return 'success';
  }
  /**
   * Update status (active/DeActive) of a specified resource.
   *
   * @param  \Illuminate\Http\Request  $request
   * @param  int  $id
   * @return \Illuminate\Http\RedirectResponse
   */
  public function updateStatus(Request $request, $id)
  {
    $event = Event::with(['information', 'ownerIdentity.owner', 'venueIdentity.owner'])->findOrFail($id);
    $previousStatus = (int) $event->status;
    $nextStatus = (int) $request->input('status');
    $reviewAction = $request->input('review_action');
    $reviewNotes = trim((string) $request->input('review_notes', ''));
    $isProfessionalSubmission = !empty($event->owner_identity_id) || !empty($event->venue_identity_id);

    $updates = [
      'status' => $nextStatus,
    ];

    $resolvedReviewStatus = $event->review_status;
    if ($isProfessionalSubmission) {
      if ($nextStatus === 1) {
        $resolvedReviewStatus = 'approved';
      } else {
        $resolvedReviewStatus = in_array($reviewAction, ['changes_requested', 'rejected', 'pending'], true)
          ? $reviewAction
          : 'changes_requested';
      }

      $updates['review_status'] = $resolvedReviewStatus;
      $updates['review_notes'] = $reviewNotes !== '' ? $reviewNotes : null;
      $updates['reviewed_at'] = now();
      $updates['reviewed_by_admin_id'] = Auth::guard('admin')->id();
    }

    $event->update($updates);

    if ($previousStatus !== $nextStatus) {
      $event->refresh();
      $this->notifyProfessionalEventStatusChange(
        $event,
        $nextStatus,
        $resolvedReviewStatus,
        $reviewNotes
      );
    } elseif ($isProfessionalSubmission && $reviewAction !== null) {
      $event->refresh();
      $this->notifyProfessionalEventStatusChange(
        $event,
        $nextStatus,
        $resolvedReviewStatus,
        $reviewNotes
      );
    }

    Session::flash('success', 'Updated Successfully');

    return redirect()->back();
  }

  protected function notifyProfessionalEventStatusChange(
    Event $event,
    int $nextStatus,
    ?string $reviewStatus = null,
    ?string $reviewNotes = null
  ): void
  {
    if (empty($event->owner_identity_id) && empty($event->venue_identity_id)) {
      return;
    }

    $title = data_get($event, 'information.title') ?: ('Event #' . $event->id);
    $resolvedReviewStatus = $reviewStatus ?: ($nextStatus === 1 ? 'approved' : 'changes_requested');
    [$messageTitle, $messageBody] = match ($resolvedReviewStatus) {
      'approved' => [
        'Duty: event approved',
        'Your event "' . $title . '" has been approved and is now live.',
      ],
      'rejected' => [
        'Duty: event rejected',
        'Your event "' . $title . '" was rejected by the Duty review team.' . ($reviewNotes ? ' Reason: ' . $reviewNotes : ''),
      ],
      'changes_requested' => [
        'Duty: changes requested',
        'Your event "' . $title . '" needs updates before approval.' . ($reviewNotes ? ' Notes: ' . $reviewNotes : ''),
      ],
      default => [
        'Duty: event updated by review',
        'Your event "' . $title . '" changed review status to ' . $resolvedReviewStatus . '.',
      ],
    };

    $recipientUsers = collect([
      optional($event->ownerIdentity)->owner,
      optional($event->venueIdentity)->owner,
    ])
      ->filter()
      ->unique('id')
      ->values();

    if ($recipientUsers->isEmpty()) {
      return;
    }

    $identityId = $event->owner_identity_id ?: $event->venue_identity_id;
    $identityType = null;
    if ($event->ownerIdentity instanceof Identity) {
      $identityType = $event->ownerIdentity->type;
    } elseif ($event->venueIdentity instanceof Identity) {
      $identityType = $event->venueIdentity->type;
    }

    foreach ($recipientUsers as $user) {
      $this->notificationService->notifyUser($user, $messageTitle, $messageBody, [
        'type' => 'event_review_status',
        'event_id' => (string) $event->id,
        'identity_id' => (string) ($identityId ?? ''),
        'identity_type' => (string) ($identityType ?? ''),
        'status' => (string) $nextStatus,
        'action' => (string) $resolvedReviewStatus,
        'review_status' => (string) $resolvedReviewStatus,
        'review_notes' => (string) ($reviewNotes ?? ''),
      ]);
    }
  }
  /**
   * Update featured status of a specified resource.
   *
   * @param  \Illuminate\Http\Request  $request
   * @param  int  $id
   * @return \Illuminate\Http\RedirectResponse
   */
  public function updateFeatured(Request $request, $id)
  {
    $event = Event::find($id);

    if ($request['is_featured'] == 'yes') {
      $event->is_featured = 'yes';
      $event->save();

      Session::flash('success', 'Updated Successfully');
    } else {
      $event->is_featured = 'no';
      $event->save();

      Session::flash('success', 'Updated Successfully');
    }

    return redirect()->back();
  }

  public function edit($id)
  {
    $event = Event::with(['ticket', 'artists'])->findOrFail($id);
    $information['event'] = $event;

    $mapStatus = DB::table('basic_settings')->pluck('google_map_status')->first();
    $defaultLang = Language::where('is_default', 1)->first();
    if ($mapStatus == 1) {
      $information['event_address'] = EventContent::select('address')
        ->where(['event_id' => $id, 'language_id' => $defaultLang->id])
        ->first();
    }

    $information['languages'] = Language::all();
    $organizers = Organizer::get();
    $information['organizers'] = $organizers;

    $artists = Artist::where('status', 1)->get();
    $information['artists'] = $artists;

    $information['getCurrencyInfo'] = $this->getCurrencyInfo();

    $collaborationSummary = $this->eventCollaboratorSplitService->eventSummary($event);
    $collaborationActivityFilter = request()->input('collaboration_activity', 'all');
    $collaborationActivityFrom = request()->input('collaboration_activity_from');
    $collaborationActivityTo = request()->input('collaboration_activity_to');
    [$collaborationActivityFilter, $collaborationActivityFilters, $filteredCollaborationActivity] = $this->resolveCollaborationActivityFilters(
      collect($collaborationSummary['activity'] ?? []),
      $collaborationActivityFilter,
      $collaborationActivityFrom,
      $collaborationActivityTo
    );

    $information['collaborationSummary'] = $collaborationSummary;
    $information['collaborationActivityFilter'] = $collaborationActivityFilter;
    $information['collaborationActivityFrom'] = $collaborationActivityFrom;
    $information['collaborationActivityTo'] = $collaborationActivityTo;
    $information['collaborationActivityFilters'] = $collaborationActivityFilters;
    $information['collaborationActivityItems'] = $filteredCollaborationActivity->all();

    return view('backend.event.edit', $information);
  }

  public function exportCollaborationActivity(Request $request, $id)
  {
    $event = Event::findOrFail($id);
    $collaborationSummary = $this->eventCollaboratorSplitService->eventSummary($event);
    $requestedFilter = $request->input('collaboration_activity', 'all');
    $from = $request->input('collaboration_activity_from');
    $to = $request->input('collaboration_activity_to');

    [$resolvedFilter, $collaborationActivityFilters, $filteredCollaborationActivity] = $this->resolveCollaborationActivityFilters(
      collect($collaborationSummary['activity'] ?? []),
      $requestedFilter,
      $from,
      $to
    );

    $selectedFilterLabel = collect($collaborationActivityFilters)
      ->firstWhere('key', $resolvedFilter)['label'] ?? __('All activity');

    $filename = 'event-collaboration-activity-' . $event->id . '-' . now()->format('Ymd-His') . '.csv';

    return response()->streamDownload(function () use ($filteredCollaborationActivity, $event, $selectedFilterLabel, $from, $to) {
      $handle = fopen('php://output', 'w');
      fputcsv($handle, ['Event ID', $event->id]);
      fputcsv($handle, ['Filter', $selectedFilterLabel]);
      fputcsv($handle, ['From', $from ?: '']);
      fputcsv($handle, ['To', $to ?: '']);
      fputcsv($handle, []);
      fputcsv($handle, ['Type', 'Title', 'Subtitle', 'Amount', 'Automatic', 'Occurred At']);

      foreach ($filteredCollaborationActivity as $activityItem) {
        fputcsv($handle, [
          data_get($activityItem, 'type'),
          data_get($activityItem, 'title'),
          data_get($activityItem, 'subtitle'),
          number_format((float) data_get($activityItem, 'amount', 0), 2, '.', ''),
          data_get($activityItem, 'is_automatic') ? 'yes' : 'no',
          data_get($activityItem, 'occurred_at'),
        ]);
      }

      fclose($handle);
    }, $filename, [
      'Content-Type' => 'text/csv; charset=UTF-8',
    ]);
  }

  public function qr($id, EventQrCodeService $qrCodeService)
  {
    $event = Event::findOrFail($id);
    $defaultLanguage = Language::query()->where('is_default', 1)->first();

    return view('backend.event.qr-preview', [
      'layout' => 'backend.layout',
      'dashboardRoute' => route('admin.dashboard'),
      'listingRoute' => route('admin.event_management.event', ['language' => $defaultLanguage?->code]),
      'editRoute' => route('admin.event_management.edit_event', ['id' => $event->id]),
      'downloadSvgUrl' => route('admin.event_management.qr_download', ['id' => $event->id]),
      'eventTitle' => $qrCodeService->resolveTitle($event),
      'eventRecord' => $event,
      'qrSvgUrl' => $qrCodeService->svgUrl($event),
      'scanLink' => $qrCodeService->buildScanUrl($event),
      'workspaceLabel' => __('Admin workspace'),
      'workspaceKicker' => __('Event QR'),
    ]);
  }

  public function downloadQr($id, EventQrCodeService $qrCodeService)
  {
    $event = Event::findOrFail($id);
    $path = $qrCodeService->ensureSvg($event);

    return response()->download($path, $qrCodeService->downloadFilename($event), [
      'Content-Type' => 'image/svg+xml',
    ]);
  }

  public function imagedbrmv(Request $request)
  {
    $pi = EventImage::where('id', $request->fileid)->first();
    $event_id = $pi->event_id;
    $image_count = EventImage::where('event_id', $event_id)->get()->count();
    if ($image_count > 1) {
      @unlink(public_path('assets/admin/img/event-gallery/') . $pi->image);
      $pi->delete();
      return $pi->id;
    } else {
      return 'false';
    }
  }
  public function images($portid)
  {
    $images = EventImage::where('event_id', $portid)->get();
    return $images;
  }

  public function update(UpdateRequest $request)
  {
    //calculate duration
    if ($request->date_type == 'single') {
      $start = Carbon::parse($request->start_date . $request->start_time);
      $end = Carbon::parse($request->end_date . $request->end_time);
      $diffent = DurationCalulate($start, $end);
    }
    //calculate duration end
    $img = $request->file('thumbnail');

    $in = $request->all();

    $event = Event::where('id', $request->event_id)->first();
    if ($request->hasFile('thumbnail')) {
      @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);
      $filename = time() . '.' . $img->getClientOriginalExtension();
      @mkdir(public_path('assets/admin/img/event/thumbnail/'), 0775, true);
      $request->file('thumbnail')->move(public_path('assets/admin/img/event/thumbnail/'), $filename);
      $in['thumbnail'] = $filename;
    }

    $languages = Language::all();

    $i = 1;
    foreach ($languages as $language) {
      $event_content = EventContent::where('event_id', $event->id)->where('language_id', $language->id)->first();
      if (!$event_content) {
        $event_content = new EventContent();
      }
      $event_content->language_id = $language->id;
      $event_content->event_category_id = $request[$language->code . '_category_id'];
      $event_content->event_id = $event->id;
      $event_content->title = $request[$language->code . '_title'];
      if ($request->event_type == 'venue') {
        $event_content->address = $request[$language->code . '_address'];
        $event_content->country_id = $request[$language->code . '_country'];
        $event_content->state_id = $request[$language->code . '_state'];
        $event_content->city_id = $request[$language->code . '_city'];
        $event_content->zip_code = $request[$language->code . '_zip_code'];
      }
      $event_content->slug = createSlug($request[$language->code . '_title']);
      $event_content->description = Purifier::clean($request[$language->code . '_description'], 'youtube');
      $event_content->refund_policy = $request[$language->code . '_refund_policy'];
      $event_content->meta_keywords = $request[$language->code . '_meta_keywords'];
      $event_content->meta_description = $request[$language->code . '_meta_description'];
      $event_content->save();
    }
    if ($request->event_type == 'online') {
      if (!$request->pricing_type) {
        $pricing_type = 'normal';
      } else {
        $pricing_type = $request->pricing_type;
      }
      Ticket::where('event_id', $request->event_id)->update([
        'price' => $request->price,
        'f_price' => $request->price,
        'pricing_type' => $pricing_type,
        'ticket_available_type' => $request->ticket_available_type,
        'ticket_available' => $request->ticket_available_type == 'limited' ? $request->ticket_available : null,
        'max_ticket_buy_type' => $request->max_ticket_buy_type,
        'max_buy_ticket' => $request->max_ticket_buy_type == 'limited' ? $request->max_buy_ticket : null,
        'early_bird_discount' => $request->early_bird_discount_type,
        'early_bird_discount_type' => $request->discount_type,
        'early_bird_discount_amount' => $request->early_bird_discount_amount,
        'early_bird_discount_date' => $request->early_bird_discount_date,
        'early_bird_discount_time' => $request->early_bird_discount_time,
      ]);
    }

    $event = Event::where('id', $event->id)->first();

    if ($request->date_type == 'multiple') {
      $i = 1;
      foreach ($request->m_start_date as $key => $date) {
        $start = Carbon::parse($date . $request->m_start_time[$key]);
        $end = Carbon::parse($request->m_end_date[$key] . $request->m_end_time[$key]);
        $diffent = DurationCalulate($start, $end);

        if (!empty($request->date_ids[$key])) {
          $event_date = EventDates::where('id', $request->date_ids[$key])->first();
          $event_date->start_date = $date;
          $event_date->start_time = $request->m_start_time[$key];
          $event_date->end_date = $request->m_end_date[$key];
          $event_date->end_time = $request->m_end_time[$key];
          $event_date->duration = $diffent;
          $event_date->start_date_time = $start;
          $event_date->end_date_time = $end;
          $event_date->save();
        } else {
          EventDates::create([
            'event_id' => $event->id,
            'start_date' => $date,
            'start_time' => $request->m_start_time[$key],
            'end_date' => $request->m_end_date[$key],
            'end_time' => $request->m_end_time[$key],
            'duration' => $diffent,
            'start_date_time' => $start,
            'end_date_time' => $end,
          ]);
        }
        if ($i == 1) {
          $event->update([
            'duration' => $diffent
          ]);
        }
        $i++;
      }
    }

    if ($request->date_type == 'single') {
      $in['end_date_time'] = Carbon::parse($request->end_date . ' ' . $request->end_time);
      $in['duration'] = $diffent;
    } else {
      //update event date time
      $event_date = EventDates::where('event_id', $event->id)->orderBy('end_date_time', 'desc')->first();

      $in['end_date_time'] = $event_date->end_date_time;
    }


    // Link to Identity from Organizer (if present)
    if ($request->filled('organizer_id')) {
      $identity = \App\Models\Identity::where('type', 'organizer')
        ->where('meta->id', $request->organizer_id)
        ->first();
      if ($identity) {
        $in['owner_identity_id'] = $identity->id;
      }
    }

    // Link to Identity from Venue (if present)
    if ($request->filled('venue_id')) {
      $vIdentity = \App\Models\Identity::where('type', 'venue')
        ->where('meta->id', $request->venue_id)
        ->first();
      if ($vIdentity) {
        $in['venue_identity_id'] = $vIdentity->id;
      }
    }

    $event->update($in);

    if ($request->filled('artist_ids')) {
      $event->artists()->sync($request->artist_ids);
    } else {
      $event->artists()->detach();
    }

    Session::flash('success', 'Updated Successfully');

    return response()->json(['status' => 'success'], 200);
  }
  /**
   * Remove the specified resource from storage.
   *
   * @param  int  $id
   * @return \Illuminate\Http\RedirectResponse
   */
  public function destroy($id)
  {
    $event = Event::find($id);

    @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);

    $event_contents = EventContent::where('event_id', $event->id)->get();
    foreach ($event_contents as $event_content) {
      $event_content->delete();
    }
    $event_images = EventImage::where('event_id', $event->id)->get();
    foreach ($event_images as $event_image) {
      @unlink(public_path('assets/admin/img/event-gallery/') . $event_image->image);
      $event_image->delete();
    }

    //bookings
    $bookings = $event->booking()->get();
    foreach ($bookings as $booking) {
      // first, delete the attachment
      @unlink(public_path('assets/admin/file/attachments/') . $booking->attachment);

      // second, delete the invoice
      @unlink(public_path('assets/admin/file/invoices/') . $booking->invoice);

      $booking->delete();
    }

    //tickets
    $tickets = $event->tickets()->get();
    foreach ($tickets as $ticket) {
      $ticket->delete();
    }
    //wishlists
    $wishlists = $event->wishlists()->get();
    foreach ($wishlists as $wishlist) {
      $wishlist->delete();
    }

    //dates
    $dates = $event->dates()->get();
    foreach ($dates as $date) {
      $date->delete();
    }

    // finally delete the event
    $event->delete();

    return redirect()->back()->with('success', 'Deleted Successfully');
  }
  //bulk_delete
  public function bulk_delete(Request $request)
  {
    foreach ($request->ids as $id) {
      $event = Event::find($id);

      @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);

      $event_contents = EventContent::where('event_id', $event->id)->get();
      foreach ($event_contents as $event_content) {
        $event_content->delete();
      }
      $event_images = EventImage::where('event_id', $event->id)->get();
      foreach ($event_images as $event_image) {
        @unlink(public_path('assets/admin/img/event-gallery/') . $event_image->image);
        $event_image->delete();
      }

      //bookings
      $bookings = $event->booking()->get();
      foreach ($bookings as $booking) {
        // first, delete the attachment
        @unlink(public_path('assets/admin/file/attachments/') . $booking->attachment);

        // second, delete the invoice
        @unlink(public_path('assets/admin/file/invoices/') . $booking->invoice);

        $booking->delete();
      }

      //tickets
      $tickets = $event->tickets()->get();
      foreach ($tickets as $ticket) {
        $ticket->delete();
      }

      //wishlists
      $wishlists = $event->wishlists()->get();
      foreach ($wishlists as $wishlist) {
        $wishlist->delete();
      }

      //dates
      $dates = $event->dates()->get();
      foreach ($dates as $date) {
        $date->delete();
      }
      // finally delete the event
      $event->delete();
    }
    Session::flash('success', 'Deleted Successfully');
    return response()->json(['status' => 'success'], 200);
  }
  public function editTicketSetting($id)
  {
    $event = Event::with('ticket')->findOrFail($id);
    $information['event'] = $event;
    return view('backend.event.ticket-settings', $information);
  }
  public function updateTicketSetting(TicketSettingRequest $request)
  {
    $ticket_image = $request->file('ticket_image');
    $ticket_slot_image = $request->file('ticket_slot_image');
    $ticket_logo = $request->file('ticket_logo');
    $in = $request->all();
    $instructions = Purifier::clean($request->instructions);
    $event = Event::where('id', $request->event_id)->first();
    if ($request->hasFile('ticket_image')) {
      @unlink(public_path('assets/admin/img/event_ticket/') . $event->ticket_image);
      $filename = time() . rand(111, 999) . '.' . $ticket_image->getClientOriginalExtension();
      @mkdir(public_path('assets/admin/img/event_ticket/'), 0775, true);
      $request->file('ticket_image')->move(public_path('assets/admin/img/event_ticket/'), $filename);
      $in['ticket_image'] = $filename;
    }
    if ($request->hasFile('ticket_slot_image')) {
      @unlink(public_path('assets/admin/img/event_ticket/') . $event->ticket_slot_image);
      $filename = time() . rand(111, 999) . '.' . $ticket_slot_image->getClientOriginalExtension();
      @mkdir(public_path('assets/admin/img/event_ticket/'), 0775, true);
      $request->file('ticket_slot_image')->move(public_path('assets/admin/img/event_ticket/'), $filename);
      $in['ticket_slot_image'] = $filename;
    }
    if ($request->hasFile('ticket_logo')) {
      @unlink(public_path('assets/admin/img/event_ticket_logo/') . $event->ticket_logo);
      $filename = time() . rand(111, 999) . '.' . $ticket_logo->getClientOriginalExtension();
      @mkdir(public_path('assets/admin/img/event_ticket_logo/'), 0775, true);
      $request->file('ticket_logo')->move(public_path('assets/admin/img/event_ticket_logo/'), $filename);
      $in['ticket_logo'] = $filename;
    }
    $in['instructions'] = $instructions;

    $event->update($in);
    Session::flash('success', 'Updated Successfully');

    return response()->json(['status' => 'success'], 200);
  }
  //search country
  public function getCountry(Request $request)
  {
    $search = $request->input('search');
    $page = $request->input('page', 1);
    $pageSize = 10;

    $query = EventCountry::where('language_id', $request->lang);

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

    $country_id = $request->country;

    $query = EventState::where('language_id', $request->lang)
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

    $state_id = $request->state;

    $query = EventCity::where('language_id', $request->lang)
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

  private function collaborationActivityFilterMap(): array
  {
    return [
      'all' => [
        'label' => __('All activity'),
        'types' => null,
      ],
      'configurations' => [
        'label' => __('Configurations'),
        'types' => ['split_configured'],
      ],
      'mode_changes' => [
        'label' => __('Mode changes'),
        'types' => ['mode_changed'],
      ],
      'manual_payouts' => [
        'label' => __('Manual payouts'),
        'types' => ['manual_claim_completed'],
      ],
      'auto_release' => [
        'label' => __('Auto release'),
        'types' => ['auto_release_completed'],
      ],
    ];
  }

  private function resolveCollaborationActivityFilters(
    \Illuminate\Support\Collection $activities,
    ?string $requestedFilter,
    ?string $from,
    ?string $to
  ): array {
    $activityFilterMap = $this->collaborationActivityFilterMap();
    $resolvedFilter = array_key_exists((string) $requestedFilter, $activityFilterMap)
      ? (string) $requestedFilter
      : 'all';

    $dateFilteredActivities = $activities->values();

    if (!empty($from)) {
      try {
        $fromDate = Carbon::parse($from)->startOfDay();
        $dateFilteredActivities = $dateFilteredActivities
          ->filter(function (array $activityItem) use ($fromDate) {
            $occurredAt = data_get($activityItem, 'occurred_at');
            if (empty($occurredAt)) {
              return false;
            }

            return Carbon::parse($occurredAt)->greaterThanOrEqualTo($fromDate);
          })
          ->values();
      } catch (\Throwable $th) {
      }
    }

    if (!empty($to)) {
      try {
        $toDate = Carbon::parse($to)->endOfDay();
        $dateFilteredActivities = $dateFilteredActivities
          ->filter(function (array $activityItem) use ($toDate) {
            $occurredAt = data_get($activityItem, 'occurred_at');
            if (empty($occurredAt)) {
              return false;
            }

            return Carbon::parse($occurredAt)->lessThanOrEqualTo($toDate);
          })
          ->values();
      } catch (\Throwable $th) {
      }
    }

    $filteredActivities = $dateFilteredActivities;
    $activeFilterConfig = $activityFilterMap[$resolvedFilter];

    if (is_array($activeFilterConfig['types'])) {
      $filteredActivities = $dateFilteredActivities
        ->whereIn('type', $activeFilterConfig['types'])
        ->values();
    }

    $filters = collect($activityFilterMap)->map(
      function (array $config, string $key) use ($dateFilteredActivities): array {
        $count = is_array($config['types'])
          ? $dateFilteredActivities->whereIn('type', $config['types'])->count()
          : $dateFilteredActivities->count();

        return [
          'key' => $key,
          'label' => $config['label'],
          'count' => $count,
        ];
      }
    )->values();

    return [$resolvedFilter, $filters, $filteredActivities];
  }
}
