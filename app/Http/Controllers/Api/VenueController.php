<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Language;
use App\Models\Venue;
use App\Services\VenuePublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

    public function profile(Request $request, int|string $id)
    {
        $target = $this->venuePublicProfileService->resolveByPublicId($id);
        if (!$target) {
            return response()->json([
                'success' => false,
                'message' => 'Venue profile not found.',
            ], 404);
        }

        $viewer = Auth::guard('sanctum')->user();

        return response()->json([
            'success' => true,
            'data' => $this->venuePublicProfileService->buildPublicPayload(
                $target,
                $viewer instanceof Customer ? $viewer : null,
                $this->resolveLanguageId($request)
            ),
        ]);
    }

    private function resolveLanguageId(Request $request): ?int
    {
        $locale = trim((string) $request->header('Accept-Language', ''));
        $language = $locale !== ''
            ? Language::query()->where('code', $locale)->first()
            : Language::query()->where('is_default', 1)->first();

        return $language?->id;
    }
}
