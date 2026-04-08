<?php

namespace Tests\Unit;

use App\Models\BasicSettings\Basic;
use App\Services\EventPaymentVerificationService;
use Tests\TestCase;

class EventPaymentVerificationServiceTest extends TestCase
{
    public function test_unsupported_gateway_is_rejected(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'DOP',
            'base_currency_rate' => 58,
        ]);

        $result = $service->verify('unsupported_gateway', 100, $currencyInfo);

        $this->assertFalse($result['success']);
        $this->assertSame('Unsupported payment gateway. Supported gateways: stripe, mixed, wallet, bonus, offline.', $result['message']);
    }

    public function test_stripe_converts_non_dop_amount(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'USD',
            'base_currency_rate' => 58,
        ]);

        $result = $service->verify('stripe', 580, $currencyInfo);

        $this->assertTrue($result['success']);
        $this->assertSame('', $result['message']);
        $this->assertSame(10.0, $result['paidAmount']);
        $this->assertSame('stripe', $result['gateway']);
        $this->assertSame('stripe_card', $result['gateway_family']);
        $this->assertSame('online_card_capture', $result['verification_strategy']);
    }

    public function test_mixed_gateway_uses_stripe_remainder_strategy(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'USD',
            'base_currency_rate' => 58,
        ]);

        $result = $service->verify('mixed', 580, $currencyInfo);

        $this->assertTrue($result['success']);
        $this->assertSame(10.0, $result['paidAmount']);
        $this->assertSame('mixed', $result['gateway']);
        $this->assertSame('stripe_card', $result['gateway_family']);
        $this->assertSame('mixed_with_stripe_remainder', $result['verification_strategy']);
    }

    public function test_wallet_gateway_keeps_nominal_amount(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'USD',
            'base_currency_rate' => 58,
        ]);

        $result = $service->verify('wallet', 99.8, $currencyInfo);

        $this->assertTrue($result['success']);
        $this->assertSame('', $result['message']);
        $this->assertSame(99.8, $result['paidAmount']);
        $this->assertSame('wallet', $result['gateway']);
        $this->assertSame('internal_balance', $result['gateway_family']);
        $this->assertSame('wallet_balance', $result['verification_strategy']);
    }

    public function test_bonus_wallet_alias_is_normalized(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'DOP',
            'base_currency_rate' => 1,
        ]);

        $result = $service->verify('bonus-wallet', 45, $currencyInfo);

        $this->assertTrue($result['success']);
        $this->assertSame(45.0, $result['paidAmount']);
        $this->assertSame('bonus_wallet', $result['gateway']);
        $this->assertSame('internal_balance', $result['gateway_family']);
        $this->assertSame('bonus_balance', $result['verification_strategy']);
    }

    public function test_offline_gateway_keeps_nominal_amount(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'USD',
            'base_currency_rate' => 58,
        ]);

        $result = $service->verify('offline', 150, $currencyInfo);

        $this->assertTrue($result['success']);
        $this->assertSame(150.0, $result['paidAmount']);
        $this->assertSame('offline', $result['gateway']);
        $this->assertSame('offline', $result['gateway_family']);
        $this->assertSame('manual_collection', $result['verification_strategy']);
    }

    public function test_stripe_rejects_invalid_currency_rate_for_non_dop_amounts(): void
    {
        $service = app(EventPaymentVerificationService::class);
        $currencyInfo = new Basic([
            'base_currency_text' => 'USD',
            'base_currency_rate' => 0,
        ]);

        $result = $service->verify('stripe', 580, $currencyInfo);

        $this->assertFalse($result['success']);
        $this->assertSame('Unable to verify payment amount because the configured currency rate is invalid.', $result['message']);
    }
}
