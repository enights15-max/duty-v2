<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\ReviewFlowException;
use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Customer;
use App\Services\ArtistTipService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ArtistTipController extends Controller
{
    public function __construct(protected ArtistTipService $artistTipService)
    {
    }

    public function store(Request $request, Artist $artist)
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid authenticated actor.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|integer|min:1',
            'amount' => 'required|numeric|min:1',
            'apply_wallet_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $tip = $this->artistTipService->submit($customer, $artist, $validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Artist tip processed successfully.',
                'data' => [
                    'tip' => $tip,
                    'payment_summary' => $tip->meta['payment_summary'] ?? null,
                ],
            ]);
        } catch (ReviewFlowException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], $exception->status());
        }
    }
}
