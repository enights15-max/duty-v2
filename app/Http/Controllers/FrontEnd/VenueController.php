<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use App\Models\Event\EventCategory;
use App\Models\Event;
use App\Services\VenuePublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class VenueController extends Controller
{
    public function __construct(
        private VenuePublicProfileService $venuePublicProfileService
    ) {
    }

    public function details(Request $request, $id, $name = null)
    {
        try {
            $language = $this->getLanguage();
            $information = [];
            $information['basicSettings'] = DB::table('basic_settings')->select('google_recaptcha_status')->first();

            $venue = Venue::findOrFail($id);
            $information['venue'] = $venue;

            $information['events'] = Event::where('venue_id', $id)->with([
                'tickets',
                'information' => function ($query) use ($language) {
                    return $query->where('language_id', $language->id);
                }
            ])->get();

            $information['categories'] = EventCategory::where('status', 1)
                ->where('language_id', $language->id)
                ->orderBy('serial_number', 'asc')->get();

            return view('frontend.venue.details', $information);
        } catch (\Exception $e) {
            return view('errors.404');
        }
    }
}
