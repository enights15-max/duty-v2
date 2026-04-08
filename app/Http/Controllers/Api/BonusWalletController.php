<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BonusTransaction;
use App\Models\Customer;
use App\Services\BonusWalletService;
use Illuminate\Http\Request;

class BonusWalletController extends Controller
{
    public function __construct(private BonusWalletService $bonusWalletService)
    {
    }

    public function getWallet(Request $request)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $wallet = $this->bonusWalletService->getOrCreateWallet($user);

        return response()->json([
            'success' => true,
            'wallet' => [
                'id' => $wallet->id,
                'balance' => round((float) $wallet->balance, 2),
                'currency' => $wallet->currency,
                'status' => $wallet->status,
            ],
        ]);
    }

    public function getHistory(Request $request)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $wallet = $this->bonusWalletService->getOrCreateWallet($user);
        $transactions = BonusTransaction::where('bonus_wallet_id', $wallet->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'transactions' => $transactions,
        ]);
    }
}
