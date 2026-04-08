<?php

namespace App\Services\Payments;

use App\Models\BasicSettings\Basic;
use App\Services\Payments\Contracts\PaymentGatewayProvider;
use App\Services\StripeService;
use Exception;

class StripePaymentGatewayProvider implements PaymentGatewayProvider
{
    public function __construct(
        private StripeService $stripeService
    ) {
    }

    public function supports(string $gateway): bool
    {
        return in_array($this->normalizeGateway($gateway), ['stripe', 'card', 'mixed'], true);
    }

    public function normalizeGateway(string $gateway): string
    {
        $gateway = strtolower(trim($gateway));

        return match ($gateway) {
            'stripe_card' => 'card',
            default => $gateway,
        };
    }

    public function describe(string $gateway): array
    {
        $normalized = $this->normalizeGateway($gateway);

        return [
            'supported' => true,
            'gateway' => $normalized,
            'gateway_family' => 'stripe_card',
            'verification_strategy' => $normalized === 'mixed'
                ? 'mixed_with_stripe_remainder'
                : 'online_card_capture',
        ];
    }

    public function verify(float $amount, Basic $currencyInfo, string $gateway): array
    {
        $descriptor = $this->describe($gateway);
        $paidAmount = round($amount, 2);

        if ($currencyInfo->base_currency_text !== 'DOP') {
            $rate = (float) $currencyInfo->base_currency_rate;
            if ($rate <= 0) {
                return [
                    'success' => false,
                    'message' => 'Unable to verify payment amount because the configured currency rate is invalid.',
                ];
            }

            $paidAmount = round(($paidAmount / $rate), 2);
        }

        return [
            'success' => true,
            'message' => '',
            'paidAmount' => $paidAmount,
            'gateway' => $descriptor['gateway'],
            'gateway_family' => $descriptor['gateway_family'],
            'verification_strategy' => $descriptor['verification_strategy'],
        ];
    }

    public function supportsSavedCardCharge(): bool
    {
        return true;
    }

    public function supportsRefunds(): bool
    {
        return true;
    }

    public function chargeSavedCard($actor, float $amount, string $currency, string $description, string $paymentMethodId, array $metadata = [])
    {
        return $this->stripeService->chargeSavedCard(
            $actor,
            $amount,
            $currency,
            $description,
            $paymentMethodId,
            $metadata
        );
    }

    public function refund(string $referenceId, ?float $amount = null, array $metadata = [])
    {
        return $this->stripeService->refundPaymentIntent($referenceId, $amount, $metadata);
    }
}
