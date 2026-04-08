<?php

namespace App\Services;

use Illuminate\Contracts\Auth\Authenticatable;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\Customer;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Exception;

class WalletService
{
    private ?bool $hasActorColumns = null;

    /**
     * Get or create a wallet for a user or customer.
     */
    public function getOrCreateWallet($actor): Wallet
    {
        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        if ($this->supportsActorColumns()) {
            $wallet = Wallet::firstOrCreate(
                ['actor_type' => $actorType, 'actor_id' => $actorId],
                [
                    'user_id' => $legacyUserId,
                    'balance' => 0.00,
                    'currency' => 'DOP',
                    'status' => 'active'
                ]
            );

            // Keep legacy column in sync for backward compatibility.
            if (empty($wallet->user_id) && !empty($legacyUserId)) {
                $wallet->user_id = $legacyUserId;
                $wallet->save();
            }

            return $wallet;
        }

        return Wallet::firstOrCreate(
            ['user_id' => $legacyUserId],
            ['balance' => 0.00, 'currency' => 'DOP', 'status' => 'active']
        );
    }

    /**
     * Credit funds to a user's wallet.
     * Uses pessimistic locking to prevent race conditions.
     */
    public function credit($actor, float $amount, string $refType, string $refId, string $idempotencyKey, float $fee = 0, float $totalAmount = 0, ?array $meta = null): WalletTransaction
    {
        if ($amount <= 0) {
            throw new Exception("Credit amount must be positive.");
        }

        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        return DB::transaction(function () use ($amount, $refType, $refId, $idempotencyKey, $actorId, $actorType, $legacyUserId, $actor, $fee, $totalAmount, $meta) {
            // Check idempotency first before locking to save DB resources
            $existing = WalletTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            // Lock the wallet row
            $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);

            if (!$wallet) {
                $wallet = $this->getOrCreateWallet($actor);
                // Re-fetch with lock
                $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            }

            if ($wallet->status !== 'active') {
                throw new Exception("Wallet is not active.");
            }

            // Create Immutable Ledger Entry
            $transaction = WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'credit',
                'amount' => $amount,
                'reference_type' => $refType,
                'reference_id' => $refId,
                'idempotency_key' => $idempotencyKey,
                'status' => 'completed',
                'meta' => $meta,
            ]);

            // Update cache balance
            $wallet->balance += $amount;
            $wallet->save();

            return $transaction;
        });
    }

    /**
     * Debit funds from a user's wallet.
     * Throws exception if insufficient funds.
     */
    public function debit($actor, float $amount, string $refType, string $refId, string $idempotencyKey, float $fee = 0, float $totalAmount = 0, ?array $meta = null): WalletTransaction
    {
        if ($amount <= 0) {
            throw new Exception("Debit amount must be positive.");
        }

        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        return DB::transaction(function () use ($amount, $refType, $refId, $idempotencyKey, $actorId, $actorType, $legacyUserId, $actor, $fee, $totalAmount, $meta) {
            // Check idempotency first
            $existing = WalletTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            // Lock the wallet row
            $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);

            if (!$wallet) {
                $wallet = $this->getOrCreateWallet($actor);
                $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            }

            if ($wallet->status !== 'active') {
                throw new Exception("Wallet is not active. Status: {$wallet->status}");
            }

            if ($wallet->balance < $amount) {
                throw new Exception("Insufficient funds. Available: {$wallet->balance}, Required: {$amount}");
            }

            // Create Immutable Ledger Entry
            $transaction = WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => $amount,
                'reference_type' => $refType,
                'reference_id' => $refId,
                'idempotency_key' => $idempotencyKey,
                'status' => 'completed',
                'meta' => $meta,
            ]);

            // Update cache balance
            $wallet->balance -= $amount;
            $wallet->save();

            return $transaction;
        });
    }

    private function findWalletForUpdate(int $actorId, string $actorType, int $legacyUserId): ?Wallet
    {
        if ($this->supportsActorColumns()) {
            return Wallet::where('actor_type', $actorType)
                ->where('actor_id', $actorId)
                ->lockForUpdate()
                ->first();
        }

        return Wallet::where('user_id', $legacyUserId)
            ->lockForUpdate()
            ->first();
    }

    private function resolveActor($actor): array
    {
        if ($actor instanceof Authenticatable) {
            $id = (int) $actor->getAuthIdentifier();
            $type = $this->normalizeActorType(get_class($actor));

            return [$id, $type, $id];
        }

        if (is_numeric($actor)) {
            $id = (int) $actor;
            return [$id, 'customer', $id];
        }

        throw new Exception('Invalid actor type for wallet operation.');
    }

    private function normalizeActorType(string $type): string
    {
        $normalized = strtolower(trim($type));

        if ($normalized === strtolower(User::class) || $normalized === 'user') {
            return 'user';
        }

        if ($normalized === strtolower(Customer::class) || $normalized === 'customer') {
            return 'customer';
        }

        return 'customer';
    }

    private function supportsActorColumns(): bool
    {
        if ($this->hasActorColumns !== null) {
            return $this->hasActorColumns;
        }

        $this->hasActorColumns = Wallet::supportsActorColumns();
        return $this->hasActorColumns;
    }
}
