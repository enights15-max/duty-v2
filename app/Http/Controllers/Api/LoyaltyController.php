<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\RewardCatalog;
use App\Models\RewardRedemption;
use App\Services\LoyaltyService;
use Illuminate\Http\Request;

class LoyaltyController extends Controller
{
    public function __construct(protected LoyaltyService $loyaltyService)
    {
    }

    public function summary(Request $request)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $this->loyaltyService->summaryFor($customer),
        ]);
    }

    public function history(Request $request)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'items' => $this->loyaltyService->historyFor($customer),
            ],
        ]);
    }

    public function rewards(Request $request)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'current_points' => $this->loyaltyService->summaryFor($customer)['current_points'] ?? 0,
                'items' => $this->loyaltyService->rewards(),
            ],
        ]);
    }

    public function redeem(Request $request, RewardCatalog $reward)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        try {
            $redemption = $this->loyaltyService->redeemReward($customer, $reward);
        } catch (\RuntimeException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Reward redeemed successfully.',
            'data' => [
                'redemption' => $redemption->load('reward:id,title,reward_type,bonus_amount,points_cost,meta'),
                'summary' => $this->loyaltyService->summaryFor($customer),
            ],
        ]);
    }

    public function redemptions(Request $request)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'items' => RewardRedemption::query()
                    ->with('reward:id,title,reward_type,bonus_amount,points_cost,meta')
                    ->where('customer_id', $customer->id)
                    ->latest('id')
                    ->get(),
            ],
        ]);
    }
}
