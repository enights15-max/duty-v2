<?php

namespace App\Services\Payments;

use App\Models\BasicSettings\Basic;
use App\Services\Payments\Contracts\PaymentGatewayProvider;
use BadMethodCallException;

class InternalBalancePaymentGatewayProvider implements PaymentGatewayProvider
{
    public function supports(string $gateway): bool
    {
        return in_array($this->normalizeGateway($gateway), ['wallet', 'bonus', 'bonus_wallet'], true);
    }

    public function normalizeGateway(string $gateway): string
    {
        $gateway = strtolower(trim($gateway));

        return match ($gateway) {
            'bonus-wallet' => 'bonus_wallet',
            default => $gateway,
        };
    }

    public function describe(string $gateway): array
    {
        $normalized = $this->normalizeGateway($gateway);

        return [
            'supported' => true,
            'gateway' => $normalized,
            'gateway_family' => 'internal_balance',
            'verification_strategy' => in_array($normalized, ['bonus', 'bonus_wallet'], true)
                ? 'bonus_balance'
                : 'wallet_balance',
        ];
    }

    public function verify(float $amount, Basic $currencyInfo, string $gateway): array
    {
        $descriptor = $this->describe($gateway);

        return [
            'success' => true,
            'message' => '',
            'paidAmount' => round($amount, 2),
            'gateway' => $descriptor['gateway'],
            'gateway_family' => $descriptor['gateway_family'],
            'verification_strategy' => $descriptor['verification_strategy'],
        ];
    }

    public function supportsSavedCardCharge(): bool
    {
        return false;
    }

    public function supportsRefunds(): bool
    {
        return false;
    }

    public function chargeSavedCard($actor, float $amount, string $currency, string $description, string $paymentMethodId, array $metadata = [])
    {
        throw new BadMethodCallException('Internal balance gateways do not support saved card charges.');
    }

    public function refund(string $referenceId, ?float $amount = null, array $metadata = [])
    {
        throw new BadMethodCallException('Internal balance gateways do not support external payment refunds.');
    }
}
