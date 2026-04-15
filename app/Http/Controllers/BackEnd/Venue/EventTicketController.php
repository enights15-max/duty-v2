<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Event\Ticket;
use App\Models\Language;
use App\Traits\HasIdentityActor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class EventTicketController extends Controller
{
    use HasIdentityActor;

    public function index(Request $request)
    {
        $event = Event::where('id', $request->event_id)
            ->where('venue_id', $this->getVenueId())
            ->firstOrFail();

        $languages = Language::all();
        $defaultLang = Language::where('is_default', 1)->first();
        $language = $request->language
            ? Language::where('code', $request->language)->first() ?? $defaultLang
            : $defaultLang;

        $eventContent = EventContent::where('event_id', $event->id)
            ->where('language_id', $language->id)
            ->first()
            ?? EventContent::where('event_id', $event->id)->first();

        $tickets = Ticket::where('event_id', $event->id)->orderBy('id', 'desc')->get();

        $information = [
            'event'    => $eventContent,
            'tickets'  => $tickets,
            'language' => $language,
        ];

        // Reuse the organizer ticket index view — venue uses the same ticket model/structure.
        // A dedicated venue.event.ticket.* view set can replace this when created.
        return view('organizer.event.ticket.index', compact('information', 'languages'));
    }
}
