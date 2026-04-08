<?php

namespace App\Services;

class EventCheckoutPricingService
{
    public function __construct(private FeeEngine $feeEngine)
    {
    }

    /**
     * @param float|int|string $subtotal
     * @return array{subtotal: float, total_to_charge: float, processing_fee: float, is_wallet: bool}
     */
    public function quote($subtotal, string $gateway): array
    {
        $normalizedSubtotal = (float) $subtotal;
        $isWallet = strtolower(trim($gateway)) === 'wallet';

        if ($isWallet) {
            return [
                'subtotal' => $normalizedSubtotal,
                'total_to_charge' => $normalizedSubtotal,
                'processing_fee' => 0.0,
                'is_wallet' => true,
            ];
        }

        $pricing = $this->quoteCardProcessing($normalizedSubtotal);

        return [
            'subtotal' => $normalizedSubtotal,
            'total_to_charge' => $pricing['total_to_charge'],
            'processing_fee' => $pricing['processing_fee'],
            'is_wallet' => false,
        ];
    }

    /**
     * @return array{total_to_charge: float, processing_fee: float}
     */
    private function quoteCardProcessing(float $subtotal): array
    {
        $quote = $this->feeEngine->quoteBuyerChargeForNet(
            FeeEngine::OP_CHECKOUT_CARD_PROCESSING,
            $subtotal,
            ['currency' => 'DOP']
        );

        return [
            'total_to_charge' => (float) ($quote['total_charge_amount'] ?? $subtotal),
            'processing_fee' => (float) ($quote['fee_amount'] ?? 0),
        ];
    }
}
