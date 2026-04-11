<?php

namespace App\Services;

use App\Models\BonusTransaction;
use App\Models\BonusWallet;
use App\Models\Customer;
use App\Models\User;
use Carbon\CarbonInterface;
use Exception;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class BonusWalletService
{
    private ?bool $hasExpirationColumns = null;

    public function getOrCreateWallet($actor): BonusWallet
    {
        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        $wallet = BonusWallet::firstOrCreate(
            ['actor_type' => $actorType, 'actor_id' => $actorId],
            [
                'user_id' => $legacyUserId,
                'balance' => 0.00,
                'currency' => 'DOP',
                'status' => 'active',
            ]
        );

        if (empty($wallet->user_id) && !empty($legacyUserId)) {
            $wallet->user_id = $legacyUserId;
            $wallet->save();
        }

        return $this->supportsExpirationColumns()
            ? $this->expireWallet($wallet)
            : $wallet;
    }

    public function credit(
        $actor,
        float $amount,
        string $refType,
        string $refId,
        string $idempotencyKey,
        string $type = 'credit',
        CarbonInterface|string|null $expiresAt = null
    ): BonusTransaction
    {
        if ($amount <= 0) {
            throw new Exception('Credit amount must be positive.');
        }

        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        return DB::transaction(function () use ($amount, $refType, $refId, $idempotencyKey, $type, $expiresAt, $actorId, $actorType, $legacyUserId, $actor) {
            $existing = BonusTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            if (!$wallet) {
                $wallet = $this->getOrCreateWallet($actor);
                $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            }

            if ($wallet->status !== 'active') {
                throw new Exception('Bonus wallet is not active.');
            }

            $transactionData = [
                'bonus_wallet_id' => $wallet->id,
                'type' => $type,
                'amount' => $amount,
                'reference_type' => $refType,
                'reference_id' => $refId,
                'idempotency_key' => $idempotencyKey,
                'status' => 'completed',
            ];

            if ($this->supportsExpirationColumns()) {
                $transactionData['consumed_amount'] = 0;
                $transactionData['expired_amount'] = 0;
                $transactionData['expires_at'] = $type === 'credit'
                    ? $this->normalizeExpiration($expiresAt)
                    : null;
            }

            $transaction = BonusTransaction::create($transactionData);

            $wallet->balance += $amount;
            $wallet->save();

            return $transaction;
        });
    }

    public function debit($actor, float $amount, string $refType, string $refId, string $idempotencyKey): BonusTransaction
    {
        if ($amount <= 0) {
            throw new Exception('Debit amount must be positive.');
        }

        [$actorId, $actorType, $legacyUserId] = $this->resolveActor($actor);

        return DB::transaction(function () use ($amount, $refType, $refId, $idempotencyKey, $actorId, $actorType, $legacyUserId, $actor) {
            $existing = BonusTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            if (!$wallet) {
                $wallet = $this->getOrCreateWallet($actor);
                $wallet = $this->findWalletForUpdate($actorId, $actorType, $legacyUserId);
            }

            if ($wallet->status !== 'active') {
                throw new Exception('Bonus wallet is not active.');
            }

            if ($this->supportsExpirationColumns()) {
                $wallet = $this->expireWallet($wallet);
            }

            if ($wallet->balance < $amount) {
                throw new Exception("Insufficient bonus balance. Available: {$wallet->balance}, Required: {$amount}");
            }

            if ($this->supportsExpirationColumns()) {
                $this->consumeCredits($wallet, $amount);
            }

            $transactionData = [
                'bonus_wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => $amount,
                'reference_type' => $refType,
                'reference_id' => $refId,
                'idempotency_key' => $idempotencyKey,
                'status' => 'completed',
            ];

            if ($this->supportsExpirationColumns()) {
                $transactionData['consumed_amount'] = 0;
                $transactionData['expired_amount'] = 0;
                $transactionData['expires_at'] = null;
            }

            $transaction = BonusTransaction::create($transactionData);

            $wallet->balance -= $amount;
            $wallet->save();

            return $transaction;
        });
    }

    private function findWalletForUpdate(int $actorId, string $actorType, int $legacyUserId): ?BonusWallet
    {
        return BonusWallet::where('actor_type', $actorType)
            ->where('actor_id', $actorId)
            ->lockForUpdate()
            ->first();
    }

    public function expireWallet(BonusWallet $wallet): BonusWallet
    {
        if (!$this->supportsExpirationColumns()) {
            return $wallet;
        }

        $result = DB::transaction(function () use ($wallet) {
            $lockedWallet = BonusWallet::query()->whereKey($wallet->id)->lockForUpdate()->first();
            if (!$lockedWallet) {
                return null;
            }

            $expiredAmount = 0.0;

            $dueCredits = BonusTransaction::query()
                ->where('bonus_wallet_id', $lockedWallet->id)
                ->where('type', 'credit')
                ->whereNotNull('expires_at')
                ->where('expires_at', '<=', now())
                ->whereRaw('(amount - consumed_amount - expired_amount) > 0')
                ->lockForUpdate()
                ->orderBy('expires_at')
                ->orderBy('created_at')
                ->get();

            foreach ($dueCredits as $credit) {
                $remaining = $this->remainingCreditAmount($credit);
                if ($remaining <= 0) {
                    continue;
                }

                $credit->forceFill([
                    'expired_amount' => round((float) $credit->expired_amount + $remaining, 2),
                ])->save();

                BonusTransaction::create([
                    'bonus_wallet_id' => $lockedWallet->id,
                    'type' => 'debit',
                    'amount' => $remaining,
                    'consumed_amount' => 0,
                    'expired_amount' => 0,
                    'expires_at' => null,
                    'reference_type' => 'bonus_expiration',
                    'reference_id' => (string) $credit->id,
                    'idempotency_key' => 'bonus_expiration_' . $credit->id,
                    'status' => 'completed',
                ]);

                $expiredAmount += $remaining;
            }

            if ($expiredAmount > 0) {
                $lockedWallet->balance = max(0.0, round((float) $lockedWallet->balance - $expiredAmount, 2));
                $lockedWallet->save();
            }

            return $lockedWallet->fresh();
        });

        return $result instanceof BonusWallet ? $result : $wallet;
    }

    public function expireDueWallets(): array
    {
        if (!$this->supportsExpirationColumns()) {
            return [
                'wallets' => 0,
                'credits' => 0,
                'amount' => 0.0,
            ];
        }

        $walletIds = BonusTransaction::query()
            ->where('type', 'credit')
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', now())
            ->whereRaw('(amount - consumed_amount - expired_amount) > 0')
            ->distinct()
            ->pluck('bonus_wallet_id');

        $summary = [
            'wallets' => 0,
            'credits' => 0,
            'amount' => 0.0,
        ];

        foreach ($walletIds as $walletId) {
            $before = BonusTransaction::query()
                ->where('bonus_wallet_id', $walletId)
                ->where('reference_type', 'bonus_expiration')
                ->count();

            $wallet = BonusWallet::query()->find($walletId);
            if (!$wallet) {
                continue;
            }

            $walletBeforeBalance = (float) $wallet->balance;
            $refreshedWallet = $this->expireWallet($wallet);
            $walletAfterBalance = (float) $refreshedWallet->balance;
            $after = BonusTransaction::query()
                ->where('bonus_wallet_id', $walletId)
                ->where('reference_type', 'bonus_expiration')
                ->count();

            $expiredCredits = $after - $before;
            if ($expiredCredits <= 0) {
                continue;
            }

            $summary['wallets']++;
            $summary['credits'] += $expiredCredits;
            $summary['amount'] += max(0.0, round($walletBeforeBalance - $walletAfterBalance, 2));
        }

        $summary['amount'] = round((float) $summary['amount'], 2);

        return $summary;
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

        throw new Exception('Invalid actor type for bonus wallet operation.');
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

    private function supportsExpirationColumns(): bool
    {
        if ($this->hasExpirationColumns !== null) {
            return $this->hasExpirationColumns;
        }

        $this->hasExpirationColumns = Schema::hasColumn('bonus_transactions', 'expires_at')
            && Schema::hasColumn('bonus_transactions', 'consumed_amount')
            && Schema::hasColumn('bonus_transactions', 'expired_amount');

        return $this->hasExpirationColumns;
    }

    private function consumeCredits(BonusWallet $wallet, float $amount): void
    {
        $remaining = round($amount, 2);
        if ($remaining <= 0) {
            return;
        }

        $credits = BonusTransaction::query()
            ->where('bonus_wallet_id', $wallet->id)
            ->where('type', 'credit')
            ->whereRaw('(amount - consumed_amount - expired_amount) > 0')
            ->lockForUpdate()
            ->orderByRaw('CASE WHEN expires_at IS NULL THEN 1 ELSE 0 END')
            ->orderBy('expires_at')
            ->orderBy('created_at')
            ->get();

        foreach ($credits as $credit) {
            $available = $this->remainingCreditAmount($credit);
            if ($available <= 0) {
                continue;
            }

            $applied = min($remaining, $available);
            $credit->forceFill([
                'consumed_amount' => round((float) $credit->consumed_amount + $applied, 2),
            ])->save();

            $remaining = round($remaining - $applied, 2);
            if ($remaining <= 0) {
                return;
            }
        }

        if ($remaining > 0) {
            // Legacy wallets can carry aggregate balance without tracked credit buckets.
            // In that case we preserve backward compatibility and allow the debit against
            // the wallet-level balance after consuming every traceable credit first.
            return;
        }
    }

    private function remainingCreditAmount(BonusTransaction $credit): float
    {
        $remaining = (float) $credit->amount
            - (float) ($credit->consumed_amount ?? 0)
            - (float) ($credit->expired_amount ?? 0);

        return round(max(0.0, $remaining), 2);
    }

    private function normalizeExpiration(CarbonInterface|string|null $expiresAt): ?string
    {
        if ($expiresAt instanceof CarbonInterface) {
            return $expiresAt->toDateTimeString();
        }

        if (is_string($expiresAt) && trim($expiresAt) !== '') {
            return (string) now()->parse($expiresAt)->toDateTimeString();
        }

        return null;
    }
}
