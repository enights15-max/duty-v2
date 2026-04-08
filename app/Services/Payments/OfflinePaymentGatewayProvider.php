<?php

namespace App\Services\Payments;

use App\Models\BasicSettings\Basic;
use App\Services\Payments\Contracts\PaymentGatewayProvider;
use BadMethodCallException;

class OfflinePaymentGatewayProvider implements PaymentGatewayProvider
{
    public function supports(string $gateway): bool
    {
        return in_array($this->normalizeGateway($gateway), ['offline', 'cash', 'manual'], true);
    }

    public function normalizeGateway(string $gateway): string
    {
        return strtolower(trim($gateway));
    }

    public function describe(string $gateway): array
    {
        return [
            'supported' => true,
            'gateway' => $this->normalizeGateway($gateway),
            'gateway_family' => 'offline',
            'verification_strategy' => 'manual_collection',
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
        throw new BadMethodCallException('Offline gateways do not support saved card charges.');
    }

    public function refund(string $referenceId, ?float $amount = null, array $metadata = [])
    {
        throw new BadMethodCallException('Offline gateways do not support external payment refunds.');
    }
}
