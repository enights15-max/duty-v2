<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Event\EventDates;
use App\Models\Event\EventImage;
use App\Models\Event\Ticket;
use App\Models\Language;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use Mews\Purifier\Facades\Purifier;
use App\Http\Requests\Event\StoreRequest;
use App\Http\Requests\Event\UpdateRequest;
use App\Services\EventAuthoringService;
use App\Services\EventQrCodeService;
use App\Traits\HasIdentityActor;

class EventController extends Controller
{
    use HasIdentityActor;
    public function index(Request $request)
    {
        $information['langs'] = Language::all();
        $defaultLang = Language::where('is_default', 1)->first();
        $language = Language::where('code', $request->language)->first() ?? $defaultLang;
        $information['language'] = $language;
        $information['defaultLang'] = $defaultLang;

        $lifecycle = $request->input('lifecycle', 'all');
        $statusFilter = $request->input('status_filter', 'all');
        $statusFilter = in_array($statusFilter, ['all', 'active', 'inactive'], true) ? $statusFilter : 'all';
        $viewMode = $request->filled('view_mode')
            ? $request->input('view_mode')
            : Session::get('venue.events.index.view_mode', 'list');
        $viewMode = in_array($viewMode, ['list', 'grid'], true) ? $viewMode : 'list';

        $gridColumns = $request->filled('grid_columns')
            ? (int) $request->input('grid_columns')
            : (int) Session::get('venue.events.index.grid_columns', 3);
        $gridColumns = in_array($gridColumns, [2, 3, 4], true) ? $gridColumns : 3;

        $gridDensity = $request->filled('grid_density')
            ? $request->input('grid_density')
            : Session::get('venue.events.index.grid_density', 'comfortable');
        $gridDensity = in_array($gridDensity, ['comfortable', 'compact'], true) ? $gridDensity : 'comfortable';

        $sortBy = $request->filled('sort_by')
            ? $request->input('sort_by')
            : Session::get('venue.events.index.sort_by', 'timeline');
        $sortBy = in_array($sortBy, ['timeline', 'newest', 'oldest', 'title_asc', 'title_desc'], true) ? $sortBy : 'timeline';

        Session::put('venue.events.index.view_mode', $viewMode);
        Session::put('venue.events.index.grid_columns', $gridColumns);
        Session::put('venue.events.index.grid_density', $gridDensity);
        Session::put('venue.events.index.sort_by', $sortBy);

        $title = $request->filled('title') ? $request->input('title') : null;
        $eventType = $request->filled('event_type') ? $request->input('event_type') : null;
        $venueId = $this->getVenueId();
        $now = Carbon::now()->toDateTimeString();
        $effectiveEndExpression = "COALESCE((SELECT MAX(event_dates.end_date_time) FROM event_dates WHERE event_dates.event_id = events.id), events.end_date_time)";

        $baseQuery = Event::join('event_contents', 'event_contents.event_id', '=', 'events.id')
            ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
            ->where('event_contents.language_id', '=', $language->id)
            ->where('events.venue_id', '=', $venueId)
            ->whereNull('events.organizer_id')
            ->when($title, function ($query) use ($title) {
                return $query->where('event_contents.title', 'like', '%' . $title . '%');
            })
            ->when($eventType, function ($query) use ($eventType) {
                return $query->where('events.event_type', $eventType);
            })
            ->when($statusFilter === 'active', function ($query) {
                return $query->where('events.status', 1);
            })
            ->when($statusFilter === 'inactive', function ($query) {
                return $query->where('events.status', 0);
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

        $events = (clone $baseQuery)
            ->select('events.*', 'event_contents.id as eventInfoId', 'event_contents.title', 'event_contents.slug', 'event_categories.name as category')
            ->selectRaw("{$effectiveEndExpression} as effective_end_date_time")
            ->selectRaw("CASE WHEN {$effectiveEndExpression} IS NOT NULL AND {$effectiveEndExpression} < ? THEN 1 ELSE 0 END as is_expired", [$now])
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
                return $query->orderByDesc('events.created_at')->orderByDesc('events.id');
            })
            ->when($sortBy === 'oldest', function ($query) {
                return $query->orderBy('events.created_at')->orderBy('events.id');
            })
            ->when($sortBy === 'title_asc', function ($query) {
                return $query->orderBy('event_contents.title')->orderByDesc('events.id');
            })
            ->when($sortBy === 'title_desc', function ($query) {
                return $query->orderByDesc('event_contents.title')->orderByDesc('events.id');
            })
            ->paginate(10);

        $information['events'] = $events;
        $information['statusFilter'] = $statusFilter;
        $information['sortBy'] = $sortBy;
        $information['viewMode'] = $viewMode;
        $information['gridColumns'] = $gridColumns;
        $information['gridDensity'] = $gridDensity;
        return view('venue.event.index', $information);
    }

    public function choose_event_type()
    {
        return view('venue.event.event_type');
    }

    public function add_event()
    {
        $information['languages'] = Language::get();
        $information['artists'] = Artist::where('status', 1)->get();
        return view('venue.event.create', $information);
    }

    public function store(StoreRequest $request)
    {
        $authoring = app(EventAuthoringService::class);
        if ($request->date_type == 'single') {
            $start = Carbon::parse($request->start_date . $request->start_time);
            $end = Carbon::parse($request->end_date . $request->end_time);
            $diffent = DurationCalulate($start, $end);
        }

        $in = $request->all();
        $in['duration'] = $request->date_type == 'single' ? $diffent : '';
        $in['venue_id'] = $this->getVenueId();
        $in['venue_identity_id'] = $this->getActiveIdentity()?->id;
        $in['organizer_id'] = null;
        $in = $authoring->applyVenueSelection(
            $request,
            $in,
            \App\Models\Venue::find($this->getVenueId()),
            $this->getActiveIdentity()
        );

        if ($request->hasFile('thumbnail')) {
            $img = $request->file('thumbnail');
            $filename = time() . '.' . $img->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/event/thumbnail/');
            @mkdir($directory, 0775, true);
            $img->move($directory, $filename);
            $in['thumbnail'] = $filename;
        }

        $in['end_date_time'] = Carbon::parse($request->end_date . ' ' . $request->end_time);
        $event = Event::create($in);
        $authoring->syncLineup($event, $request);

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
                    $event->update(['duration' => $diffent]);
                }
                $i++;
            }
            $event_date = EventDates::where('event_id', $event->id)->orderBy('end_date_time', 'desc')->first();
            $event->end_date_time = $event_date->end_date_time;
            $event->save();
        }

        $slders = $request->slider_images;
        if ($slders) {
            foreach ($slders as $id) {
                $event_image = EventImage::where('id', $id)->first();
                if ($event_image) {
                    $event_image->event_id = $event->id;
                    $event_image->save();
                }
            }
        }

        $authoring->syncLocalizedContent($event, $request, Language::all());
        app(EventQrCodeService::class)->ensureSvg($event);

        Session::flash('success', 'Event added successfully!');
        return response()->json(['status' => 'success'], 200);
    }

    public function edit($id)
    {
        $event = Event::with(['artists', 'lineups.artist'])->where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        $information['event'] = $event;
        $information['languages'] = Language::all();
        $information['artists'] = Artist::where('status', 1)->get();
        return view('venue.event.edit', $information);
    }

    public function qr($id, EventQrCodeService $qrCodeService)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        $defaultLanguage = Language::query()->where('is_default', 1)->first();

        return view('backend.event.qr-preview', [
            'layout' => 'venue.layout',
            'dashboardRoute' => route('venue.dashboard'),
            'listingRoute' => route('venue.event_management.event', ['language' => $defaultLanguage?->code]),
            'editRoute' => route('venue.event_management.edit_event', ['id' => $event->id]),
            'downloadSvgUrl' => route('venue.event_management.qr_download', ['id' => $event->id]),
            'eventTitle' => $qrCodeService->resolveTitle($event),
            'eventRecord' => $event,
            'qrSvgUrl' => $qrCodeService->svgUrl($event),
            'scanLink' => $qrCodeService->buildScanUrl($event),
            'workspaceLabel' => __('Venue workspace'),
            'workspaceKicker' => __('Event QR'),
        ]);
    }

    public function downloadQr($id, EventQrCodeService $qrCodeService)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        $path = $qrCodeService->ensureSvg($event);

        return response()->download($path, $qrCodeService->downloadFilename($event), [
            'Content-Type' => 'image/svg+xml',
        ]);
    }

    public function update(UpdateRequest $request)
    {
        $authoring = app(EventAuthoringService::class);
        $event = Event::where('id', $request->event_id)->where('venue_id', $this->getVenueId())->firstOrFail();

        if ($request->date_type == 'single') {
            $start = Carbon::parse($request->start_date . $request->start_time);
            $end = Carbon::parse($request->end_date . $request->end_time);
            $diffent = DurationCalulate($start, $end);
        }

        $in = $request->all();
        if ($request->hasFile('thumbnail')) {
            @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);
            $img = $request->file('thumbnail');
            $filename = time() . '.' . $img->getClientOriginalExtension();
            $img->move(public_path('assets/admin/img/event/thumbnail/'), $filename);
            $in['thumbnail'] = $filename;
        }

        if ($request->date_type == 'single') {
            $in['end_date_time'] = Carbon::parse($request->end_date . ' ' . $request->end_time);
            $in['duration'] = $diffent;
        }

        $in['venue_id'] = $this->getVenueId();
        $in['venue_identity_id'] = $this->getActiveIdentity()?->id;
        $in['organizer_id'] = null;
        $in = $authoring->applyVenueSelection(
            $request,
            $in,
            \App\Models\Venue::find($this->getVenueId()),
            $this->getActiveIdentity()
        );

        $event->update($in);
        $event->refresh();
        $authoring->syncLocalizedContent($event, $request, Language::all());
        $authoring->syncLineup($event, $request);
        app(EventQrCodeService::class)->ensureSvg($event);
        Session::flash('success', 'Event updated successfully!');
        return response()->json(['status' => 'success'], 200);
    }

    public function destroy($id)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        app(EventQrCodeService::class)->delete($event);
        @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);
        $event->delete();
        return redirect()->back()->with('success', 'Deleted Successfully');
    }

    public function updateStatus(Request $request, $id)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        $event->update([
            'status' => $request['status']
        ]);

        Session::flash('success', 'Updated Successfully');
        return redirect()->back();
    }

    public function bulk_delete(Request $request)
    {
        foreach ($request->ids as $id) {
            $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->first();
            if (empty($event)) {
                continue;
            }
            app(EventQrCodeService::class)->delete($event);

            @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);

            $eventContents = EventContent::where('event_id', $event->id)->get();
            foreach ($eventContents as $eventContent) {
                $eventContent->delete();
            }

            $eventImages = EventImage::where('event_id', $event->id)->get();
            foreach ($eventImages as $eventImage) {
                @unlink(public_path('assets/admin/img/event-gallery/') . $eventImage->image);
                $eventImage->delete();
            }

            $bookings = $event->booking()->get();
            foreach ($bookings as $booking) {
                @unlink(public_path('assets/admin/file/attachments/') . $booking->attachment);
                @unlink(public_path('assets/admin/file/invoices/') . $booking->invoice);
                $booking->delete();
            }

            $tickets = $event->tickets()->get();
            foreach ($tickets as $ticket) {
                $ticket->delete();
            }

            $wishlists = $event->wishlists()->get();
            foreach ($wishlists as $wishlist) {
                $wishlist->delete();
            }

            $event->delete();
        }

        Session::flash('success', 'Deleted Successfully');
        return response()->json(['status' => 'success'], 200);
    }

    // Additional methods (gallerystore, imagermv, etc.) can be copied from Organizer/EventController
    public function gallerystore(Request $request)
    {
        $img = $request->file('file');
        $filename = uniqid() . '.jpg';
        $uploadPath = public_path('assets/admin/img/event-gallery/');
        @mkdir($uploadPath, 0775, true);
        $img->move($uploadPath, $filename);

        $pi = new EventImage;
        $pi->event_id = $request->event_id ?? null;
        $pi->image = $filename;
        $pi->save();

        return response()->json(['status' => 'success', 'file_id' => $pi->id]);
    }

    public function imagermv(Request $request)
    {
        $pi = EventImage::where('id', $request->fileid)->first();
        @unlink(public_path('assets/admin/img/event-gallery/') . $pi->image);
        $pi->delete();
        return $pi->id;
    }
}
