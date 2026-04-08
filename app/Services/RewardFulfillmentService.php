<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event\Coupon;
use App\Models\RewardCatalog;
use App\Models\RewardRedemption;
use Carbon\Carbon;
use Illuminate\Support\Str;
use RuntimeException;

class RewardFulfillmentService
{
    public function __construct(protected BonusWalletService $bonusWalletService)
    {
    }

    public function fulfill(Customer $customer, RewardCatalog $reward, RewardRedemption $redemption): array
    {
        return match ($reward->reward_type) {
            'bonus_credit' => $this->fulfillBonusCredit($customer, $reward, $redemption),
            'perk' => $this->fulfillPerk($reward, $redemption),
            'event_coupon' => $this->fulfillEventCoupon($reward, $redemption),
            default => throw new RuntimeException('Unsupported reward type: ' . $reward->reward_type),
        };
    }

    private function fulfillBonusCredit(Customer $customer, RewardCatalog $reward, RewardRedemption $redemption): array
    {
        $rewardMeta = $reward->meta ?? [];
        $bonusAmount = (float) ($reward->bonus_amount ?? 0);
        if ($bonusAmount <= 0) {
            throw new RuntimeException('Bonus reward is not configured correctly.');
        }

        $configuredDays = array_key_exists('bonus_expires_in_days', $rewardMeta)
            ? (int) $rewardMeta['bonus_expires_in_days']
            : 90;
        $expiresAt = $configuredDays > 0 ? now()->addDays($configuredDays) : null;

        $bonusTransaction = $this->bonusWalletService->credit(
            $customer,
            $bonusAmount,
            'loyalty_reward_bonus',
            (string) $redemption->id,
            'loyalty_reward_bonus_' . $redemption->id,
            'credit',
            $expiresAt
        );

        return [
            'status' => 'completed',
            'fulfilled_at' => now(),
            'bonus_transaction_id' => $bonusTransaction->id,
            'meta' => [
                'fulfillment' => [
                    'mode' => 'bonus_credit',
                    'bonus_amount' => round($bonusAmount, 2),
                    'currency' => 'DOP',
                    'instructions' => 'Disponible en checkout mixto como bono interno.',
                    'expires_at' => $expiresAt?->toIso8601String(),
                ],
            ],
        ];
    }

    private function fulfillPerk(RewardCatalog $reward, RewardRedemption $redemption): array
    {
        $rewardMeta = $reward->meta ?? [];
        $claimPrefix = $this->normalizeCodePrefix($rewardMeta['claim_code_prefix'] ?? 'PERK');
        $claimCode = sprintf(
            '%s-%06d-%s',
            $claimPrefix,
            (int) $redemption->id,
            Str::upper(Str::random(4))
        );

        $expiresAt = now()->addDays(max(1, (int) ($rewardMeta['claim_expires_in_days'] ?? 45)));

        return [
            'status' => 'completed',
            'fulfilled_at' => now(),
            'meta' => [
                'fulfillment' => [
                    'mode' => 'claim_code',
                    'claim_code' => $claimCode,
                    'instructions' => $rewardMeta['instructions']
                        ?? 'Presenta este codigo al organizer o al staff para reclamar el benefit.',
                    'delivery_channel' => $rewardMeta['delivery_channel'] ?? 'in_person',
                    'expires_at' => $expiresAt->toIso8601String(),
                ],
            ],
        ];
    }

    private function fulfillEventCoupon(RewardCatalog $reward, RewardRedemption $redemption): array
    {
        $rewardMeta = $reward->meta ?? [];
        $couponType = strtolower((string) ($rewardMeta['coupon_type'] ?? 'fixed'));
        $couponType = $couponType === 'percent' ? 'percentage' : $couponType;
        if (!in_array($couponType, ['fixed', 'percentage'], true)) {
            throw new RuntimeException('Reward coupon type is invalid.');
        }

        $couponValue = (float) ($rewardMeta['coupon_value'] ?? $reward->bonus_amount ?? 0);
        if ($couponValue <= 0) {
            throw new RuntimeException('Reward coupon value is invalid.');
        }

        $eventIds = array_values(array_filter(array_map(
            static fn ($value) => (int) $value,
            is_array($rewardMeta['event_ids'] ?? null) ? $rewardMeta['event_ids'] : []
        )));

        $startAt = isset($rewardMeta['start_at'])
            ? Carbon::parse((string) $rewardMeta['start_at'])
            : now();
        $expiresAt = isset($rewardMeta['expires_at'])
            ? Carbon::parse((string) $rewardMeta['expires_at'])
            : $startAt->copy()->addDays(max(1, (int) ($rewardMeta['coupon_expires_in_days'] ?? 30)));

        $couponCode = sprintf(
            'DRW-%06d-%s',
            (int) $redemption->id,
            Str::upper(Str::random(5))
        );

        $coupon = Coupon::create([
            'name' => $rewardMeta['coupon_name'] ?? $reward->title,
            'code' => $couponCode,
            'type' => $couponType,
            'value' => $couponValue,
            'events' => $eventIds === [] ? json_encode([]) : json_encode($eventIds),
            'start_date' => $startAt->toDateTimeString(),
            'end_date' => $expiresAt->toDateTimeString(),
        ]);

        return [
            'status' => 'completed',
            'fulfilled_at' => now(),
            'meta' => [
                'fulfillment' => [
                    'mode' => 'event_coupon',
                    'coupon_id' => $coupon->id,
                    'coupon_code' => $coupon->code,
                    'coupon_type' => $couponType,
                    'coupon_value' => round($couponValue, 2),
                    'event_ids' => $eventIds,
                    'instructions' => $rewardMeta['instructions']
                        ?? 'Aplica este codigo en checkout para descontar la compra elegible.',
                    'expires_at' => $expiresAt->toIso8601String(),
                ],
            ],
        ];
    }

    private function normalizeCodePrefix(mixed $value): string
    {
        $normalized = strtoupper((string) $value);
        $normalized = preg_replace('/[^A-Z0-9]/', '', $normalized) ?? 'PERK';
        $normalized = substr($normalized, 0, 8);

        return $normalized !== '' ? $normalized : 'PERK';
    }
}
