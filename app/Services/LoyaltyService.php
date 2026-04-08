<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\LoyaltyPointTransaction;
use App\Models\LoyaltyRule;
use App\Models\RewardCatalog;
use App\Models\RewardRedemption;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use RuntimeException;

class LoyaltyService
{
    public function __construct(protected RewardFulfillmentService $rewardFulfillmentService)
    {
    }

    public function isAvailable(): bool
    {
        return Schema::hasTable('loyalty_rules')
            && Schema::hasTable('loyalty_point_transactions')
            && Schema::hasTable('reward_catalog')
            && Schema::hasTable('reward_redemptions');
    }

    public function summaryFor(Customer $customer): array
    {
        if (!$this->isAvailable()) {
            return [
                'current_points' => 0,
                'lifetime_points' => 0,
                'redeemed_points' => 0,
                'available_rewards' => 0,
            ];
        }

        $history = LoyaltyPointTransaction::query()->where('customer_id', $customer->id);
        $currentPoints = (int) ((clone $history)->latest('id')->value('balance_after') ?? 0);

        return [
            'current_points' => $currentPoints,
            'lifetime_points' => (int) ((clone $history)->where('type', 'credit')->sum('points') ?? 0),
            'redeemed_points' => (int) ((clone $history)->where('type', 'debit')->sum('points') ?? 0),
            'available_rewards' => RewardCatalog::query()
                ->where('is_active', true)
                ->where('points_cost', '<=', $currentPoints)
                ->count(),
        ];
    }

    public function historyFor(Customer $customer, int $limit = 50): Collection
    {
        if (!$this->isAvailable()) {
            return collect();
        }

        return LoyaltyPointTransaction::query()
            ->with('rule:id,code,label')
            ->where('customer_id', $customer->id)
            ->latest('id')
            ->limit($limit)
            ->get();
    }

    public function rewards(): Collection
    {
        if (!$this->isAvailable()) {
            return collect();
        }

        return RewardCatalog::query()
            ->where('is_active', true)
            ->orderByDesc('is_featured')
            ->orderBy('points_cost')
            ->get();
    }

    public function awardFromRule(Customer $customer, string $ruleCode, string $referenceType, string|int $referenceId, array $meta = []): ?LoyaltyPointTransaction
    {
        if (!$this->isAvailable()) {
            return null;
        }

        $rule = LoyaltyRule::query()
            ->where('code', $ruleCode)
            ->where('is_active', true)
            ->first();

        if (!$rule || (int) $rule->points <= 0) {
            return null;
        }

        return $this->creditPoints(
            $customer,
            (int) $rule->points,
            $rule,
            $referenceType,
            (string) $referenceId,
            'loyalty_' . $ruleCode . '_' . $referenceType . '_' . $referenceId,
            $meta
        );
    }

    public function redeemReward(Customer $customer, RewardCatalog $reward): RewardRedemption
    {
        if (!$this->isAvailable()) {
            throw new RuntimeException('Loyalty is not available.');
        }

        if (!$reward->is_active) {
            throw new RuntimeException('Reward is not active.');
        }

        $redemption = RewardRedemption::create([
            'customer_id' => $customer->id,
            'reward_id' => $reward->id,
            'reward_type' => $reward->reward_type,
            'points_cost' => (int) $reward->points_cost,
            'status' => 'processing',
            'meta' => [
                'reward_title' => $reward->title,
            ],
        ]);

        try {
            DB::transaction(function () use ($customer, $reward, $redemption): void {
                $pointsTransaction = $this->debitPoints(
                    $customer,
                    (int) $reward->points_cost,
                    'reward_redemption',
                    (string) $redemption->id,
                    'loyalty_reward_redemption_' . $redemption->id,
                    [
                        'reward_id' => $reward->id,
                        'reward_type' => $reward->reward_type,
                    ]
                );

                $fulfillment = $this->rewardFulfillmentService->fulfill($customer, $reward, $redemption);

                $redemption->forceFill([
                    'loyalty_transaction_id' => $pointsTransaction->id,
                    'bonus_transaction_id' => $fulfillment['bonus_transaction_id'] ?? null,
                    'status' => $fulfillment['status'] ?? 'completed',
                    'meta' => array_merge($redemption->meta ?? [], $fulfillment['meta'] ?? []),
                    'fulfilled_at' => $fulfillment['fulfilled_at'] ?? now(),
                ])->save();
            });

            return $redemption->fresh(['reward']);
        } catch (\Throwable $exception) {
            $redemption->forceFill([
                'status' => 'failed',
                'meta' => array_merge($redemption->meta ?? [], [
                    'failure_reason' => $exception->getMessage(),
                ]),
            ])->save();

            throw $exception;
        }
    }

    private function creditPoints(
        Customer $customer,
        int $points,
        ?LoyaltyRule $rule,
        string $referenceType,
        string $referenceId,
        string $idempotencyKey,
        array $meta = []
    ): LoyaltyPointTransaction {
        return DB::transaction(function () use ($customer, $points, $rule, $referenceType, $referenceId, $idempotencyKey, $meta) {
            $existing = LoyaltyPointTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            Customer::query()->whereKey($customer->id)->lockForUpdate()->first();
            $currentBalance = (int) (LoyaltyPointTransaction::query()
                ->where('customer_id', $customer->id)
                ->latest('id')
                ->value('balance_after') ?? 0);

            return LoyaltyPointTransaction::create([
                'customer_id' => $customer->id,
                'rule_id' => $rule?->id,
                'type' => 'credit',
                'points' => $points,
                'balance_after' => $currentBalance + $points,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'idempotency_key' => $idempotencyKey,
                'meta' => array_merge($meta, [
                    'rule_code' => $rule?->code,
                    'rule_label' => $rule?->label,
                ]),
            ]);
        });
    }

    private function debitPoints(
        Customer $customer,
        int $points,
        string $referenceType,
        string $referenceId,
        string $idempotencyKey,
        array $meta = []
    ): LoyaltyPointTransaction {
        if ($points <= 0) {
            throw new RuntimeException('Points to redeem must be greater than zero.');
        }

        return DB::transaction(function () use ($customer, $points, $referenceType, $referenceId, $idempotencyKey, $meta) {
            $existing = LoyaltyPointTransaction::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            Customer::query()->whereKey($customer->id)->lockForUpdate()->first();
            $currentBalance = (int) (LoyaltyPointTransaction::query()
                ->where('customer_id', $customer->id)
                ->latest('id')
                ->value('balance_after') ?? 0);

            if ($currentBalance < $points) {
                throw new RuntimeException('Insufficient loyalty points.');
            }

            return LoyaltyPointTransaction::create([
                'customer_id' => $customer->id,
                'rule_id' => null,
                'type' => 'debit',
                'points' => $points,
                'balance_after' => $currentBalance - $points,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'idempotency_key' => $idempotencyKey,
                'meta' => $meta,
            ]);
        });
    }
}
