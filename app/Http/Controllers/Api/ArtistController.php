<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Services\ArtistPublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ArtistController extends Controller
{
    public function __construct(
        private ArtistPublicProfileService $artistPublicProfileService
    ) {
    }

    public function profile(Request $request, int|string $id)
    {
        $target = $this->artistPublicProfileService->resolveByPublicId($id);
        if (!$target) {
            return response()->json([
                'success' => false,
                'message' => 'Artist profile not found.',
            ], 404);
        }

        $viewer = Auth::guard('sanctum')->user();

        return response()->json([
            'success' => true,
            'data' => $this->artistPublicProfileService->buildPublicPayload(
                $target,
                $viewer instanceof Customer ? $viewer : null
            ),
        ]);
    }
}
