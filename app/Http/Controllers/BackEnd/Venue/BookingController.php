<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\EventContent;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        $venueId = Auth::guard('venue')->id();
        $bookingId = $request->input('booking_id');
        $paymentStatus = $request->input('status');
        $eventTitle = $request->input('event_title');

        $eventIds = [];
        if ($eventTitle) {
            $eventIds = EventContent::where('title', 'like', '%' . $eventTitle . '%')
                ->pluck('event_id')
                ->toArray();
        }

        $bookings = Booking::join('events', 'events.id', '=', 'bookings.event_id')
            ->where('events.venue_id', $venueId)
            ->whereNull('events.organizer_id')
            ->when($bookingId, function ($query, $bookingId) {
                return $query->where('bookings.booking_id', 'like', '%' . $bookingId . '%');
            })
            ->when($eventIds, function ($query) use ($eventIds) {
                return $query->whereIn('bookings.event_id', $eventIds);
            })
            ->when($paymentStatus, function ($query, $paymentStatus) {
                return $query->where('bookings.paymentStatus', $paymentStatus);
            })
            ->select('bookings.*')
            ->orderByDesc('bookings.id')
            ->paginate(10);

        return view('venue.event.booking.index', compact('bookings'));
    }

    public function details($id)
    {
        $venueId = Auth::guard('venue')->id();
        $booking = Booking::join('events', 'events.id', '=', 'bookings.event_id')
            ->where('events.venue_id', $venueId)
            ->whereNull('events.organizer_id')
            ->where('bookings.id', $id)
            ->select('bookings.*')
            ->firstOrFail();

        return view('venue.event.booking.details', compact('booking'));
    }

    public function report(Request $request)
    {
        // Implementation for report view, similar to index but with date filters
        return view('venue.event.booking.report');
    }
}
