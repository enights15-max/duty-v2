<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\StripeService;
use App\Models\PaymentMethod;
use Illuminate\Support\Facades\Auth;

class PaymentMethodController extends Controller
{
    protected $stripeService;

    public function __construct(StripeService $stripeService)
    {
        $this->stripeService = $stripeService;
    }

    /**
     * List saved payment methods for the authenticated user.
     */
    public function index()
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $methods = PaymentMethod::forActor($user)
            ->where('status', 'active')
            ->orderBy('is_default', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $methods
        ]);
    }

    /**
     * Create a SetupIntent client_secret for adding a new card.
     */
    public function setup()
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        try {
            $clientSecret = $this->stripeService->createSetupIntent($user);

            return response()->json([
                'status' => 'success',
                'client_secret' => $clientSecret
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
