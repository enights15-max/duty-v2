<?php

namespace App\Services;

use App\Models\PosTerminal;
use App\Models\PosTransaction;
use App\Models\Customer;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class POSService
{
    protected $nfcService;
    protected $walletService;

    public function __construct(NFCService $nfcService, WalletService $walletService)
    {
        $this->nfcService = $nfcService;
        $this->walletService = $walletService;
    }

    /**
     * Authorize a physical terminal for an organizer.
     */
    public function authorizeTerminal(string $uuid, Customer $customer, string $name = null): PosTerminal
    {
        return PosTerminal::updateOrCreate(
            ['terminal_uuid' => $uuid],
            [
                // "organizer_id" is legacy column name; currently bound to authenticated customer actor.
                'organizer_id' => $customer->id,
                'name' => $name ?? "Terminal " . substr($uuid, 0, 8),
                'status' => 'active',
                'last_active_at' => now(),
            ]
        );
    }

    /**
     * Process a payment capture from a POS terminal.
     */
    public function capturePayment(PosTerminal $terminal, string $uidRaw, float $amount, string $pin = null): PosTransaction
    {
        return DB::transaction(function () use ($terminal, $uidRaw, $amount, $pin) {
            // 1. Validate Token
            $token = $this->nfcService->validateToken($uidRaw);
            if (!$token) {
                throw new \Exception("Invalid or inactive NFC token.");
            }

            // 2. Verify PIN if applicable
            if (!$this->nfcService->verifyPin($token, $pin)) {
                throw new \Exception("Incorrect PIN.");
            }

            // 3. Check Daily Limits
            if (($token->daily_spent + $amount) > $token->daily_limit) {
                throw new \Exception("Daily spending limit exceeded.");
            }

            // 4. Debit Wallet (using pessimistic locking)
            $user = $token->user;
            if (!$user) {
                throw new \Exception("NFC token is not linked to an active customer.");
            }
            $walletTx = $this->walletService->debit(
                $user,
                $amount,
                'pos_sale',
                $terminal->id,
                'pos_' . $terminal->id . '_' . Str::random(10) // Idempotency
            );

            // 5. Update Token stats
            $token->increment('daily_spent', $amount);
            $token->update(['last_used_at' => now()]);

            // 6. Record POS Transaction
            return PosTransaction::create([
                'pos_terminal_id' => $terminal->id,
                'wallet_transaction_id' => $walletTx->id,
                'amount' => $amount,
                'currency' => 'DOP',
                'status' => 'success',
                'metadata' => [
                    'token_id' => $token->id,
                    'terminal_uuid' => $terminal->terminal_uuid,
                ]
            ]);
        });
    }
}
