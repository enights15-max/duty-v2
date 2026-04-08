<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
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
use App\Traits\HasIdentityActor;

class EventController extends Controller
{
    use HasIdentityActor;
    public function index(Request $request)
    {
        $information['langs'] = Language::all();
        $language = Language::where('code', $request->language)->first() ?? Language::where('is_default', 1)->first();
        $information['language'] = $language;

        $title = $request->input('title');
        $venueId = $this->getVenueId();

        $events = Event::join('event_contents', 'event_contents.event_id', '=', 'events.id')
            ->join('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
            ->where('event_contents.language_id', '=', $language->id)
            ->where('events.venue_id', '=', $venueId)
            ->whereNull('events.organizer_id')
            ->when($title, function ($query) use ($title) {
                return $query->where('event_contents.title', 'like', '%' . $title . '%');
            })
            ->select('events.*', 'event_contents.id as eventInfoId', 'event_contents.title', 'event_contents.slug', 'event_categories.name as category')
            ->orderByDesc('events.id')
            ->paginate(10);

        $information['events'] = $events;
        return view('venue.event.index', $information);
    }

    public function choose_event_type()
    {
        return view('venue.event.event_type');
    }

    public function add_event()
    {
        $information['languages'] = Language::get();
        return view('venue.event.create', $information);
    }

    public function store(StoreRequest $request)
    {
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

        $languages = Language::all();
        foreach ($languages as $language) {
            $event_content = new EventContent();
            $event_content->language_id = $language->id;
            $event_content->event_category_id = $request[$language->code . '_category_id'];
            $event_content->event_id = $event->id;
            $event_content->title = $request[$language->code . '_title'];
            $event_content->slug = createSlug($request[$language->code . '_title']);
            $event_content->description = Purifier::clean($request[$language->code . '_description'], 'youtube');
            $event_content->save();
        }

        Session::flash('success', 'Event added successfully!');
        return response()->json(['status' => 'success'], 200);
    }

    public function edit($id)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        $information['event'] = $event;
        $information['languages'] = Language::all();
        return view('venue.event.edit', $information);
    }

    public function update(UpdateRequest $request)
    {
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

        $languages = Language::all();
        foreach ($languages as $language) {
            $event_content = EventContent::where('event_id', $event->id)->where('language_id', $language->id)->first() ?? new EventContent();
            $event_content->language_id = $language->id;
            $event_content->event_category_id = $request[$language->code . '_category_id'];
            $event_content->event_id = $event->id;
            $event_content->title = $request[$language->code . '_title'];
            $event_content->slug = createSlug($request[$language->code . '_title']);
            $event_content->description = Purifier::clean($request[$language->code . '_description'], 'youtube');
            $event_content->save();
        }

        if ($request->date_type == 'single') {
            $in['end_date_time'] = Carbon::parse($request->end_date . ' ' . $request->end_time);
            $in['duration'] = $diffent;
        }

        $event->update($in);
        Session::flash('success', 'Event updated successfully!');
        return response()->json(['status' => 'success'], 200);
    }

    public function destroy($id)
    {
        $event = Event::where('id', $id)->where('venue_id', $this->getVenueId())->firstOrFail();
        @unlink(public_path('assets/admin/img/event/thumbnail/') . $event->thumbnail);
        $event->delete();
        return redirect()->back()->with('success', 'Deleted Successfully');
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
