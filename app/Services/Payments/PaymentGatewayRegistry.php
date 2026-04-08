<?php

namespace App\Services\Payments;

use App\Models\BasicSettings\Basic;
use App\Services\Payments\Contracts\PaymentGatewayProvider;
use Exception;

class PaymentGatewayRegistry
{
    /**
     * @var array<int, PaymentGatewayProvider>
     */
    private array $providers;

    public function __construct(
        StripePaymentGatewayProvider $stripeProvider,
        InternalBalancePaymentGatewayProvider $internalProvider,
        OfflinePaymentGatewayProvider $offlineProvider
    ) {
        $this->providers = [
            $stripeProvider,
            $internalProvider,
            $offlineProvider,
        ];
    }

    /**
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    public function describe(string $gateway): array
    {
        $provider = $this->providerFor($gateway);
        if (!$provider) {
            return [
                'supported' => false,
                'gateway' => $this->normalizeGateway($gateway),
                'gateway_family' => null,
                'verification_strategy' => null,
            ];
        }

        return $provider->describe($gateway);
    }

    /**
     * @param float|int|string $amount
     * @return array<string, mixed>
     */
    public function verify(string $gateway, $amount, Basic $currencyInfo): array
    {
        $provider = $this->providerFor($gateway);
        if (!$provider) {
            return [
                'success' => false,
                'message' => 'Unsupported payment gateway. Supported gateways: stripe, mixed, wallet, bonus, offline.',
            ];
        }

        return $provider->verify(round((float) $amount, 2), $currencyInfo, $gateway);
    }

    /**
     * @return array<string, string|null>
     */
    public function buildGatewayContract(string $requestedGateway, ?string $effectiveGateway = null): array
    {
        $requested = $this->describe($requestedGateway);
        $effective = $this->describe($effectiveGateway ?: $requestedGateway);

        return [
            'requested_gateway' => $requested['gateway'] ?? null,
            'requested_gateway_family' => $requested['gateway_family'] ?? null,
            'requested_verification_strategy' => $requested['verification_strategy'] ?? null,
            'gateway' => $effective['gateway'] ?? null,
            'gateway_family' => $effective['gateway_family'] ?? null,
            'verification_strategy' => $effective['verification_strategy'] ?? null,
        ];
    }

    /**
     * @return mixed
     */
    public function chargeSavedCard(string $gateway, $actor, float $amount, string $currency, string $description, string $paymentMethodId, array $metadata = [])
    {
        $provider = $this->providerFor($gateway);
        if (!$provider) {
            throw new Exception('Unsupported payment gateway for saved card charge.');
        }

        if (!$provider->supportsSavedCardCharge()) {
            throw new Exception('Selected payment gateway does not support saved card charges.');
        }

        return $provider->chargeSavedCard($actor, $amount, $currency, $description, $paymentMethodId, $metadata);
    }

    /**
     * @return mixed
     */
    public function refund(string $gateway, string $referenceId, ?float $amount = null, array $metadata = [])
    {
        $provider = $this->providerFor($gateway);
        if (!$provider) {
            throw new Exception('Unsupported payment gateway for refund.');
        }

        if (!$provider->supportsRefunds()) {
            throw new Exception('Selected payment gateway does not support provider-managed refunds.');
        }

        return $provider->refund($referenceId, $amount, $metadata);
    }

    public function providerFor(string $gateway): ?PaymentGatewayProvider
    {
        foreach ($this->providers as $provider) {
            if ($provider->supports($gateway)) {
                return $provider;
            }
        }

        return null;
    }

    private function normalizeGateway(string $gateway): string
    {
        return strtolower(trim($gateway));
    }
}
