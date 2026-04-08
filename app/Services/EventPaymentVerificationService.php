<?php

namespace App\Services;

use App\Models\BasicSettings\Basic;
use App\Services\Payments\PaymentGatewayRegistry;

class EventPaymentVerificationService
{
    public function __construct(
        private PaymentGatewayRegistry $gatewayRegistry
    ) {
    }

    /**
     * Verify and normalize payable amount by gateway/currency rules.
     *
     * Stripe-backed gateways normalize the payable amount using base currency
     * conversion rules. Internal balance and offline flows pass the nominal
     * amount through unchanged.
     *
     * @param string $gateway
     * @param float|int|string $amount
     * @param Basic $currencyInfo
     * @return array<string, mixed>
     */
    public function verify(string $gateway, $amount, Basic $currencyInfo): array
    {
        return $this->gatewayRegistry->verify($gateway, $amount, $currencyInfo);
    }

    /**
     * Describe the normalized gateway contract used across payment flows.
     *
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    public function describeGateway(string $gateway): array
    {
        return $this->gatewayRegistry->describe($gateway);
    }

    /**
     * Build a normalized gateway contract payload that can be persisted in
     * historical records without each module inventing its own keys.
     *
     * @return array<string, string|null>
     */
    public function buildGatewayContract(string $requestedGateway, ?string $effectiveGateway = null): array
    {
        return $this->gatewayRegistry->buildGatewayContract($requestedGateway, $effectiveGateway);
    }
}
