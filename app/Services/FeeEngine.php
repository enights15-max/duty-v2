<?php

namespace App\Services;

use App\Models\BasicSettings\Basic;
use App\Models\FeePolicy;
use Illuminate\Support\Facades\Schema;

class FeeEngine
{
    public const OP_PRIMARY_TICKET_SALE = 'primary_ticket_sale';
    public const OP_CHECKOUT_CARD_PROCESSING = 'checkout_card_processing';
    public const OP_MARKETPLACE_RESALE = 'marketplace_resale';
    public const OP_MARKETPLACE_CARD_PROCESSING = 'marketplace_card_processing';
    public const OP_TICKET_TRANSFER = 'ticket_transfer';
    public const OP_GIFT_TRANSFER = 'gift_transfer';
    public const OP_RESERVATION_PAYMENT = 'reservation_payment';
    public const OP_RESERVATION_CONVERSION = 'reservation_conversion';
    public const OP_WALLET_TOPUP = 'wallet_topup';
    public const OP_WALLET_TRANSFER = 'wallet_transfer';
    public const OP_WALLET_WITHDRAWAL = 'wallet_withdrawal';
    public const OP_ARTIST_TIP = 'artist_tip';
    public const OP_PROMO_TICKET_ISSUE = 'promo_ticket_issue';
    public const OP_SUBSCRIPTION_PURCHASE = 'subscription_purchase';

    public function calculate(string $operationKey, float $grossAmount, array $context = []): array
    {
        $grossAmount = $this->normalizeMoney($grossAmount);
        $feeBaseAmount = $this->normalizeMoney($context['fee_base_amount'] ?? $grossAmount);
        $policy = $this->resolvePolicy($operationKey);
        $chargedTo = (string) ($context['charged_to'] ?? ($policy['charged_to'] ?? FeePolicy::CHARGED_TO_SELLER));
        $currency = (string) ($context['currency'] ?? ($policy['currency'] ?? 'DOP'));

        $feeAmount = 0.0;
        if (($policy['is_active'] ?? false) && $feeBaseAmount > 0) {
            $feeAmount = match ($policy['fee_type'] ?? FeePolicy::TYPE_PERCENTAGE) {
                FeePolicy::TYPE_FIXED => $this->normalizeMoney($policy['fixed_value'] ?? 0),
                FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED => $this->normalizeMoney(
                    ($feeBaseAmount * ((float) ($policy['percentage_value'] ?? 0) / 100))
                    + (float) ($policy['fixed_value'] ?? 0)
                ),
                default => $this->normalizeMoney(
                    $feeBaseAmount * ((float) ($policy['percentage_value'] ?? 0) / 100)
                ),
            };

            if (($policy['minimum_fee'] ?? null) !== null) {
                $feeAmount = max($feeAmount, $this->normalizeMoney($policy['minimum_fee']));
            }

            if (($policy['maximum_fee'] ?? null) !== null) {
                $feeAmount = min($feeAmount, $this->normalizeMoney($policy['maximum_fee']));
            }
        }

        if ($chargedTo !== FeePolicy::CHARGED_TO_BUYER) {
            $feeAmount = min($feeAmount, $grossAmount);
        }

        $netAmount = $chargedTo === FeePolicy::CHARGED_TO_BUYER
            ? $grossAmount
            : $this->normalizeMoney(max(0, $grossAmount - $feeAmount));

        $totalChargeAmount = array_key_exists('total_charge_amount', $context)
            ? $this->normalizeMoney($context['total_charge_amount'])
            : ($chargedTo === FeePolicy::CHARGED_TO_BUYER
                ? $this->normalizeMoney($grossAmount + $feeAmount)
                : $grossAmount);

        return [
            'policy_id' => $policy['id'] ?? null,
            'policy_source' => $policy['source'] ?? 'fallback',
            'operation_key' => $operationKey,
            'label' => $policy['label'] ?? $operationKey,
            'description' => $policy['description'] ?? null,
            'is_active' => (bool) ($policy['is_active'] ?? false),
            'fee_type' => $policy['fee_type'] ?? FeePolicy::TYPE_PERCENTAGE,
            'percentage_value' => $policy['percentage_value'] !== null ? (float) $policy['percentage_value'] : null,
            'fixed_value' => $policy['fixed_value'] !== null ? (float) $policy['fixed_value'] : null,
            'minimum_fee' => $policy['minimum_fee'] !== null ? (float) $policy['minimum_fee'] : null,
            'maximum_fee' => $policy['maximum_fee'] !== null ? (float) $policy['maximum_fee'] : null,
            'charged_to' => $chargedTo,
            'currency' => $currency,
            'gross_amount' => $grossAmount,
            'fee_base_amount' => $feeBaseAmount,
            'fee_amount' => $feeAmount,
            'net_amount' => $netAmount,
            'total_charge_amount' => $totalChargeAmount,
        ];
    }

    public function quoteBuyerChargeForNet(string $operationKey, float $netAmount, array $context = []): array
    {
        $netAmount = $this->normalizeMoney($netAmount);
        $policy = $this->resolvePolicy($operationKey);
        $chargedTo = (string) ($context['charged_to'] ?? ($policy['charged_to'] ?? FeePolicy::CHARGED_TO_SELLER));
        $currency = (string) ($context['currency'] ?? ($policy['currency'] ?? 'DOP'));

        if (
            $netAmount <= 0
            || !($policy['is_active'] ?? false)
            || $chargedTo !== FeePolicy::CHARGED_TO_BUYER
        ) {
            return [
                'policy_id' => $policy['id'] ?? null,
                'policy_source' => $policy['source'] ?? 'fallback',
                'operation_key' => $operationKey,
                'label' => $policy['label'] ?? $operationKey,
                'description' => $policy['description'] ?? null,
                'is_active' => (bool) ($policy['is_active'] ?? false),
                'fee_type' => $policy['fee_type'] ?? FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => $policy['percentage_value'] !== null ? (float) $policy['percentage_value'] : null,
                'fixed_value' => $policy['fixed_value'] !== null ? (float) $policy['fixed_value'] : null,
                'minimum_fee' => $policy['minimum_fee'] !== null ? (float) $policy['minimum_fee'] : null,
                'maximum_fee' => $policy['maximum_fee'] !== null ? (float) $policy['maximum_fee'] : null,
                'charged_to' => $chargedTo,
                'currency' => $currency,
                'gross_amount' => $netAmount,
                'fee_base_amount' => $netAmount,
                'fee_amount' => 0.0,
                'net_amount' => $netAmount,
                'total_charge_amount' => $netAmount,
            ];
        }

        $feeType = $policy['fee_type'] ?? FeePolicy::TYPE_PERCENTAGE;
        $percentage = max(0.0, ((float) ($policy['percentage_value'] ?? 0)) / 100);
        $fixed = max(0.0, (float) ($policy['fixed_value'] ?? 0));

        $totalChargeAmount = match ($feeType) {
            FeePolicy::TYPE_FIXED => $netAmount + $fixed,
            FeePolicy::TYPE_PERCENTAGE => $percentage >= 1
                ? $netAmount
                : ($netAmount / (1 - $percentage)),
            FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED => $percentage >= 1
                ? $netAmount
                : (($netAmount + $fixed) / (1 - $percentage)),
            default => $netAmount,
        };

        $feeAmount = max(0.0, $this->normalizeMoney($totalChargeAmount - $netAmount));

        if (($policy['minimum_fee'] ?? null) !== null) {
            $feeAmount = max($feeAmount, $this->normalizeMoney($policy['minimum_fee']));
            $totalChargeAmount = $this->normalizeMoney($netAmount + $feeAmount);
        }

        if (($policy['maximum_fee'] ?? null) !== null) {
            $feeAmount = min($feeAmount, $this->normalizeMoney($policy['maximum_fee']));
            $totalChargeAmount = $this->normalizeMoney($netAmount + $feeAmount);
        }

        return [
            'policy_id' => $policy['id'] ?? null,
            'policy_source' => $policy['source'] ?? 'fallback',
            'operation_key' => $operationKey,
            'label' => $policy['label'] ?? $operationKey,
            'description' => $policy['description'] ?? null,
            'is_active' => (bool) ($policy['is_active'] ?? false),
            'fee_type' => $feeType,
            'percentage_value' => $policy['percentage_value'] !== null ? (float) $policy['percentage_value'] : null,
            'fixed_value' => $policy['fixed_value'] !== null ? (float) $policy['fixed_value'] : null,
            'minimum_fee' => $policy['minimum_fee'] !== null ? (float) $policy['minimum_fee'] : null,
            'maximum_fee' => $policy['maximum_fee'] !== null ? (float) $policy['maximum_fee'] : null,
            'charged_to' => $chargedTo,
            'currency' => $currency,
            'gross_amount' => $netAmount,
            'fee_base_amount' => $netAmount,
            'fee_amount' => $feeAmount,
            'net_amount' => $netAmount,
            'total_charge_amount' => $this->normalizeMoney($totalChargeAmount),
        ];
    }

    public function resolvePolicy(string $operationKey): array
    {
        if (Schema::hasTable('fee_policies')) {
            $policy = FeePolicy::query()
                ->where('operation_key', $operationKey)
                ->latest('id')
                ->first();

            if ($policy) {
                $data = $policy->toArray();
                $data['source'] = 'database';
                return $data;
            }
        }

        return $this->legacyFallbackPolicy($operationKey);
    }

    public function catalog(): array
    {
        $basic = Schema::hasTable('basic_settings')
            ? Basic::query()->select('commission', 'marketplace_commission')->first()
            : null;

        return [
            self::OP_PRIMARY_TICKET_SALE => [
                'label' => 'Primary ticket sale',
                'description' => 'Platform commission on official ticket sales.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => (float) ($basic->commission ?? 0),
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => true,
            ],
            self::OP_CHECKOUT_CARD_PROCESSING => [
                'label' => 'Checkout card processing',
                'description' => 'Buyer-paid processing fee for pure card checkouts.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
                'percentage_value' => 5,
                'fixed_value' => 15,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => true,
            ],
            self::OP_MARKETPLACE_RESALE => [
                'label' => 'Marketplace resale',
                'description' => 'Platform fee on blackmarket resale operations.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => (float) ($basic->marketplace_commission ?? 5),
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => true,
            ],
            self::OP_MARKETPLACE_CARD_PROCESSING => [
                'label' => 'Marketplace card processing',
                'description' => 'Buyer-paid processing fee when a resale purchase needs card fallback.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
                'percentage_value' => 5,
                'fixed_value' => 15,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => true,
            ],
            self::OP_TICKET_TRANSFER => [
                'label' => 'Ticket transfer',
                'description' => 'Optional fee for non-marketplace ticket transfers.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_GIFT_TRANSFER => [
                'label' => 'Gift transfer',
                'description' => 'Optional fee for gifted tickets.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_RESERVATION_PAYMENT => [
                'label' => 'Reservation payment',
                'description' => 'Optional fee on reservation deposits.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_RESERVATION_CONVERSION => [
                'label' => 'Reservation conversion',
                'description' => 'Optional fee when reservation converts into booking.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_WALLET_TOPUP => [
                'label' => 'Wallet topup',
                'description' => 'Buyer-paid processing fee for adding funds into wallet.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
                'percentage_value' => 5,
                'fixed_value' => 15,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => true,
            ],
            self::OP_WALLET_TRANSFER => [
                'label' => 'Wallet transfer',
                'description' => 'Optional fee for wallet-to-wallet transfers.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_WALLET_WITHDRAWAL => [
                'label' => 'Wallet withdrawal',
                'description' => 'Optional fee for payouts/withdrawals.',
                'fee_type' => FeePolicy::TYPE_FIXED,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_ARTIST_TIP => [
                'label' => 'Artist tip',
                'description' => 'Optional fee on artist tip transactions.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_SELLER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_PROMO_TICKET_ISSUE => [
                'label' => 'Promotional ticket issue',
                'description' => 'Internal policy for promotional/granted tickets.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_PLATFORM,
                'currency' => 'DOP',
                'is_active' => false,
            ],
            self::OP_SUBSCRIPTION_PURCHASE => [
                'label' => 'Subscription purchase',
                'description' => 'Optional fee for subscription products.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => false,
            ],
        ];
    }

    private function legacyFallbackPolicy(string $operationKey): array
    {
        $catalog = $this->catalog();
        $fallback = $catalog[$operationKey] ?? [
            'label' => $operationKey,
            'description' => null,
            'fee_type' => FeePolicy::TYPE_PERCENTAGE,
            'percentage_value' => 0,
            'fixed_value' => 0,
            'minimum_fee' => null,
            'maximum_fee' => null,
            'charged_to' => FeePolicy::CHARGED_TO_SELLER,
            'currency' => 'DOP',
            'is_active' => false,
        ];

        return $fallback + [
            'id' => null,
            'operation_key' => $operationKey,
            'source' => 'fallback',
        ];
    }

    private function normalizeMoney(mixed $value): float
    {
        return round((float) $value, 2);
    }
}
