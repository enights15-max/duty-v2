<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ProfessionalCatalogBridgeService;
use App\Services\ReviewService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Exceptions\ReviewFlowException;

class OrganizerReviewController extends Controller
{
    public function __construct(
        protected ReviewService $reviewService,
        protected ProfessionalCatalogBridgeService $catalogBridge
    )
    {
    }

    /**
     * Store or update an organizer review.
     */
    public function store(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.'
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'organizer_id' => 'nullable|numeric',
            'organizer_identity_id' => 'nullable|numeric',
            'event_id' => 'nullable|integer|min:1',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails() || (!$request->filled('organizer_id') && !$request->filled('organizer_identity_id'))) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()->merge([
                    'organizer_target' => ['Either organizer_id or organizer_identity_id is required.'],
                ])
            ], 422);
        }

        $organizerLegacyId = $request->filled('organizer_id')
            ? (int) $request->organizer_id
            : null;

        if ($organizerLegacyId === null && $request->filled('organizer_identity_id')) {
            $identity = \App\Models\Identity::query()->find((int) $request->organizer_identity_id);
            $resolvedLegacyId = $identity
                ? $this->catalogBridge->legacyIdForIdentity($identity, 'organizer')
                : null;
            $organizerLegacyId = is_numeric($resolvedLegacyId) ? (int) $resolvedLegacyId : null;
        }

        if ($organizerLegacyId === null) {
            return response()->json([
                'success' => false,
                'message' => 'Organizer review target not found.'
            ], 404);
        }

        try {
            $review = $this->reviewService->submit($customer, [
                'target_type' => 'organizer',
                'target_id' => $organizerLegacyId,
                'event_id' => $request->input('event_id'),
                'rating' => (int) $request->rating,
                'comment' => $request->comment,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Review saved successfully.',
                'data' => $review->load('customer:id,fname,lname,photo')
            ]);
        } catch (ReviewFlowException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], $exception->status());
        }
    }
}
