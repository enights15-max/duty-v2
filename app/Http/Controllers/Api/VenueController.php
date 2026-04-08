<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use Illuminate\Http\Request;

class VenueController extends Controller
{
    public function __construct(
        private VenuePublicProfileService $venuePublicProfileService
    ) {
    }

    public function index()
    {
        $venues = Venue::where('status', 1)->get();
        return response()->json(['status' => 'success', 'data' => $venues]);
    }

    public function details($id)
    {
        $venue = Venue::with([
            'events' => function ($query) {
                $query->where('status', 1)->with('information');
            }
        ])->find($id);

        if (!$venue) {
            return response()->json(['status' => 'error', 'message' => 'Venue not found'], 404);
        }

        return response()->json(['status' => 'success', 'data' => $venue]);
    }
}
