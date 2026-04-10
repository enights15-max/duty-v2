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
    private const DEFAULT_RULE_POINTS = [
        'attendance_confirmed' => 40,
        'event_purchase' => 100,
        'marketplace_purchase' => 60,
        'published_review' => 25,
        'follow_accept' => 10,
    ];

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
        $currentPoints = $this->hasColumn($this->loyaltyTransactionColumns(), 'balance_after')
            ? (int) ((clone $history)->latest('id')->value('balance_after') ?? 0)
            : (int) (
                (clone $history)->where('type', 'credit')->sum('points')
                - (clone $history)->where('type', 'debit')->sum('points')
            );

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
        if (!Schema::hasTable('loyalty_point_transactions')) {
            return null;
        }

        $transactionColumns = $this->loyaltyTransactionColumns();
        $rule = $this->resolveAwardRule($ruleCode);
        if (!$rule || (int) $rule->points <= 0) {
            return null;
        }

        $customerId = (int) $customer->id;
        $referenceId = (string) $referenceId;
        $points = (int) $rule->points;
        $idempotencyKey = 'loyalty_' . $ruleCode . '_' . $referenceType . '_' . $referenceId;

        $existingQuery = DB::table('loyalty_point_transactions')
            ->where('customer_id', $customerId);

        if ($this->hasColumn($transactionColumns, 'idempotency_key')) {
            $existingQuery->where('idempotency_key', $idempotencyKey);
        } elseif ($this->hasColumn($transactionColumns, 'rule_key')) {
            $existingQuery
                ->where('rule_key', $ruleCode)
                ->where('reference_type', $referenceType)
                ->where('reference_id', $referenceId);
        } elseif ($this->hasColumn($transactionColumns, 'rule_id') && isset($rule->id)) {
            $existingQuery
                ->where('rule_id', $rule->id)
                ->where('reference_type', $referenceType)
                ->where('reference_id', $referenceId);
        } else {
            $existingQuery
                ->where('reference_type', $referenceType)
                ->where('reference_id', $referenceId)
                ->where('points', $points);
        }

        $existing = $existingQuery->first();
        if ($existing) {
            return LoyaltyPointTransaction::query()->find($existing->id);
        }

        $currentBalance = 0;
        if ($this->hasColumn($transactionColumns, 'balance_after')) {
            $currentBalance = (int) (DB::table('loyalty_point_transactions')
                ->where('customer_id', $customerId)
                ->orderByDesc('id')
                ->value('balance_after') ?? 0);
        }

        $payload = [
            'customer_id' => $customerId,
            'type' => 'credit',
            'points' => $points,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'created_at' => now(),
            'updated_at' => now(),
        ];

        if ($this->hasColumn($transactionColumns, 'rule_id')) {
            $payload['rule_id'] = $rule->id ?? null;
        }

        if ($this->hasColumn($transactionColumns, 'rule_key')) {
            $payload['rule_key'] = $ruleCode;
        }

        if ($this->hasColumn($transactionColumns, 'balance_after')) {
            $payload['balance_after'] = $currentBalance + $points;
        }

        if ($this->hasColumn($transactionColumns, 'idempotency_key')) {
            $payload['idempotency_key'] = $idempotencyKey;
        }

        if ($this->hasColumn($transactionColumns, 'meta')) {
            $payload['meta'] = json_encode(array_merge($meta, [
                'rule_code' => $rule->code ?? $ruleCode,
                'rule_label' => $rule->label ?? $ruleCode,
            ]));
        }

        $transactionId = DB::table('loyalty_point_transactions')->insertGetId($payload);

        return LoyaltyPointTransaction::query()->find($transactionId);
    }

    private function resolveAwardRule(string $ruleKey): object
    {
        if (Schema::hasTable('loyalty_rules')) {
            $ruleColumns = $this->loyaltyRuleColumns();
            $configuredRuleQuery = DB::table('loyalty_rules');

            if ($this->hasColumn($ruleColumns, 'code')) {
                $configuredRuleQuery->where('code', $ruleKey);
            } elseif ($this->hasColumn($ruleColumns, 'rule_key')) {
                $configuredRuleQuery->where('rule_key', $ruleKey);
            }

            if ($this->hasColumn($ruleColumns, 'is_active')) {
                $configuredRuleQuery->where('is_active', true);
            }

            $configuredRule = $configuredRuleQuery->first();

            if ($configuredRule) {
                if (!isset($configuredRule->code) && isset($configuredRule->rule_key)) {
                    $configuredRule->code = $configuredRule->rule_key;
                }

                return $configuredRule;
            }
        }

        return (object) [
            'id' => null,
            'code' => $ruleKey,
            'label' => $ruleKey,
            'points' => self::DEFAULT_RULE_POINTS[$ruleKey] ?? 0,
        ];
    }

    private function loyaltyTransactionColumns(): array
    {
        static $columns;

        if ($columns === null) {
            $columns = Schema::getColumnListing('loyalty_point_transactions');
        }

        return $columns;
    }

    private function loyaltyRuleColumns(): array
    {
        static $columns;

        if ($columns === null) {
            $columns = Schema::getColumnListing('loyalty_rules');
        }

        return $columns;
    }

    private function hasColumn(array $columns, string $column): bool
    {
        return in_array($column, $columns, true);
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
