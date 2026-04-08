<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    protected $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * List all active subscription plans.
     */
    public function index()
    {
        $plans = SubscriptionPlan::where('status', 'active')->get();

        return response()->json([
            'status' => 'success',
            'data' => $plans
        ]);
    }

    /**
     * Create a checkout session for a subscription.
     */
    public function subscribe(Request $request)
    {
        $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
            'success_url' => 'required|url',
            'cancel_url' => 'required|url',
        ]);

        $plan = SubscriptionPlan::find($request->plan_id);
        $user = $request->user();

        try {
            $checkoutUrl = $this->subscriptionService->createCheckoutSession(
                $user,
                $plan,
                $request->success_url,
                $request->cancel_url
            );

            return response()->json([
                'status' => 'success',
                'checkout_url' => $checkoutUrl
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
