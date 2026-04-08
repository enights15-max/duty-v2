<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\ReviewFlowException;
use App\Http\Controllers\Controller;
use App\Services\ReviewService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    public function __construct(protected ReviewService $reviewService)
    {
    }

    public function pending(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'items' => $this->reviewService->pendingFor($customer),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'target_type' => 'required|in:event,organizer,artist',
            'target_id' => 'required|integer|min:1',
            'event_id' => 'nullable|integer|min:1',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $review = $this->reviewService->submit($customer, $validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Review saved successfully.',
                'data' => $review->load('customer:id,fname,lname,photo'),
            ]);
        } catch (ReviewFlowException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], $exception->status());
        }
    }
}
