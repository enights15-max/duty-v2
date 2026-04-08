<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Language;
use App\Services\SocialFeedService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SocialFeedController extends Controller
{
    public function __construct(
        private SocialFeedService $socialFeedService
    ) {
    }

    public function index(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer instanceof \App\Models\Customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized or invalid user type',
            ], 401);
        }

        $locale = $request->header('Accept-Language');
        $language = $locale
            ? Language::query()->where('code', $locale)->first()
            : Language::query()->where('is_default', 1)->first();

        return response()->json([
            'success' => true,
            'data' => $this->socialFeedService->build($customer, $language?->id),
        ]);
    }
}
