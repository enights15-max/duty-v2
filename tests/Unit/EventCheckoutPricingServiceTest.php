<?php

namespace Tests\Unit;

use App\Services\EventCheckoutPricingService;
use Tests\TestCase;

class EventCheckoutPricingServiceTest extends TestCase
{
    public function test_quote_returns_no_processing_fee_for_wallet_gateway(): void
    {
        $service = app(EventCheckoutPricingService::class);

        $quote = $service->quote(100, 'wallet');

        $this->assertTrue($quote['is_wallet']);
        $this->assertSame(100.0, $quote['subtotal']);
        $this->assertSame(100.0, $quote['total_to_charge']);
        $this->assertSame(0.0, $quote['processing_fee']);
    }

    public function test_quote_applies_processing_fee_for_non_wallet_gateway(): void
    {
        $service = app(EventCheckoutPricingService::class);

        $quote = $service->quote(100, 'stripe');

        $this->assertFalse($quote['is_wallet']);
        $this->assertEqualsWithDelta(121.05, $quote['total_to_charge'], 0.0001);
        $this->assertEqualsWithDelta(21.05, $quote['processing_fee'], 0.0001);
    }

    public function test_quote_treats_wallet_gateway_case_insensitively(): void
    {
        $service = app(EventCheckoutPricingService::class);

        $quote = $service->quote(75, '  WALLET ');

        $this->assertTrue($quote['is_wallet']);
        $this->assertSame(75.0, $quote['total_to_charge']);
        $this->assertSame(0.0, $quote['processing_fee']);
    }
}
