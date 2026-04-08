<?php

namespace App\Services;

class CheckoutFundingAllocatorService
{
    public function __construct(private EventCheckoutPricingService $pricingService)
    {
    }

    /**
     * @param array{gateway:string, wallet_balance?:float|int|string, bonus_balance?:float|int|string, apply_wallet_balance?:bool, apply_bonus_balance?:bool} $context
     * @return array<string, mixed>
     */
    public function allocate($subtotal, array $context): array
    {
        $subtotal = round((float) $subtotal, 2);
        $gateway = strtolower(trim((string) ($context['gateway'] ?? 'stripe')));
        $applyWallet = (bool) ($context['apply_wallet_balance'] ?? false);
        $applyBonus = (bool) ($context['apply_bonus_balance'] ?? false);
        $walletBalance = max(0.0, round((float) ($context['wallet_balance'] ?? 0), 2));
        $bonusBalance = max(0.0, round((float) ($context['bonus_balance'] ?? 0), 2));

        if ($applyWallet || $applyBonus || $gateway === 'mixed') {
            return $this->allocateMixed($subtotal, $applyBonus, $bonusBalance, $applyWallet, $walletBalance);
        }

        if ($gateway === 'wallet') {
            $covered = min($subtotal, $walletBalance);

            return [
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'subtotal' => $subtotal,
                'processing_fee' => 0.0,
                'total_to_charge' => $subtotal,
                'bonus_amount' => 0.0,
                'wallet_amount' => $covered,
                'card_amount' => 0.0,
                'card_processing_fee' => 0.0,
                'card_total_charge' => 0.0,
                'remaining_amount' => round(max(0.0, $subtotal - $covered), 2),
                'requires_card' => false,
                'is_fully_covered' => $covered >= $subtotal,
            ];
        }

        if ($gateway === 'bonus') {
            $covered = min($subtotal, $bonusBalance);

            return [
                'mode' => 'bonus',
                'payment_method' => 'bonus',
                'subtotal' => $subtotal,
                'processing_fee' => 0.0,
                'total_to_charge' => $subtotal,
                'bonus_amount' => $covered,
                'wallet_amount' => 0.0,
                'card_amount' => 0.0,
                'card_processing_fee' => 0.0,
                'card_total_charge' => 0.0,
                'remaining_amount' => round(max(0.0, $subtotal - $covered), 2),
                'requires_card' => false,
                'is_fully_covered' => $covered >= $subtotal,
            ];
        }

        $pricing = $this->pricingService->quote($subtotal, $gateway);

        return [
            'mode' => 'card',
            'payment_method' => 'stripe',
            'subtotal' => $subtotal,
            'processing_fee' => round((float) $pricing['processing_fee'], 2),
            'total_to_charge' => round((float) $pricing['total_to_charge'], 2),
            'bonus_amount' => 0.0,
            'wallet_amount' => 0.0,
            'card_amount' => $subtotal,
            'card_processing_fee' => round((float) $pricing['processing_fee'], 2),
            'card_total_charge' => round((float) $pricing['total_to_charge'], 2),
            'remaining_amount' => 0.0,
            'requires_card' => true,
            'is_fully_covered' => true,
        ];
    }

    private function allocateMixed(
        float $subtotal,
        bool $applyBonus,
        float $bonusBalance,
        bool $applyWallet,
        float $walletBalance
    ): array {
        $remaining = $subtotal;
        $bonusAmount = 0.0;
        $walletAmount = 0.0;

        if ($applyBonus) {
            $bonusAmount = min($remaining, $bonusBalance);
            $remaining = round($remaining - $bonusAmount, 2);
        }

        if ($applyWallet) {
            $walletAmount = min($remaining, $walletBalance);
            $remaining = round($remaining - $walletAmount, 2);
        }

        $cardAmount = max(0.0, round($remaining, 2));
        $isFullyCovered = $cardAmount <= 0.0;

        $sourcesUsed = collect([
            $bonusAmount > 0 ? 'bonus' : null,
            $walletAmount > 0 ? 'wallet' : null,
            $cardAmount > 0 ? 'stripe' : null,
        ])->filter()->values();

        $paymentMethod = $sourcesUsed->count() <= 1
            ? ($sourcesUsed->first() ?? 'mixed')
            : 'mixed';

        return [
            'mode' => 'mixed',
            'payment_method' => $paymentMethod,
            'subtotal' => $subtotal,
            'processing_fee' => 0.0,
            'total_to_charge' => $subtotal,
            'bonus_amount' => round($bonusAmount, 2),
            'wallet_amount' => round($walletAmount, 2),
            'card_amount' => $cardAmount,
            'card_processing_fee' => 0.0,
            'card_total_charge' => $cardAmount,
            'remaining_amount' => $cardAmount,
            'requires_card' => !$isFullyCovered,
            'is_fully_covered' => $isFullyCovered,
        ];
    }
}
