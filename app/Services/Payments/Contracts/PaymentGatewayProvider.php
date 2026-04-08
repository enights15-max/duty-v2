<?php

namespace App\Services\Payments\Contracts;

use App\Models\BasicSettings\Basic;

interface PaymentGatewayProvider
{
    public function supports(string $gateway): bool;

    public function normalizeGateway(string $gateway): string;

    /**
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    public function describe(string $gateway): array;

    /**
     * @param float $amount
     * @return array<string, mixed>
     */
    public function verify(float $amount, Basic $currencyInfo, string $gateway): array;

    public function supportsSavedCardCharge(): bool;

    public function supportsRefunds(): bool;

    /**
     * @return mixed
     */
    public function chargeSavedCard($actor, float $amount, string $currency, string $description, string $paymentMethodId, array $metadata = []);

    /**
     * @return mixed
     */
    public function refund(string $referenceId, ?float $amount = null, array $metadata = []);
}
