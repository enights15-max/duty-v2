<?php

namespace Tests\Unit;

use App\Services\CheckoutFundingAllocatorService;
use Tests\TestCase;

class CheckoutFundingAllocatorServiceTest extends TestCase
{
    public function test_allocate_keeps_pure_card_fee_logic_when_no_internal_balance_is_applied(): void
    {
        $service = app(CheckoutFundingAllocatorService::class);

        $plan = $service->allocate(1000, [
            'gateway' => 'stripe',
        ]);

        $this->assertSame('card', $plan['mode']);
        $this->assertSame('stripe', $plan['payment_method']);
        $this->assertSame(0.0, $plan['wallet_amount']);
        $this->assertSame(0.0, $plan['bonus_amount']);
        $this->assertSame(1000.0, $plan['card_amount']);
        $this->assertGreaterThan(0.0, $plan['card_processing_fee']);
        $this->assertGreaterThan(1000.0, $plan['card_total_charge']);
    }

    public function test_allocate_combines_bonus_wallet_and_card_without_extra_card_fee(): void
    {
        $service = app(CheckoutFundingAllocatorService::class);

        $plan = $service->allocate(1000, [
            'gateway' => 'mixed',
            'apply_bonus_balance' => true,
            'bonus_balance' => 300,
            'apply_wallet_balance' => true,
            'wallet_balance' => 500,
        ]);

        $this->assertSame('mixed', $plan['mode']);
        $this->assertSame('mixed', $plan['payment_method']);
        $this->assertSame(300.0, $plan['bonus_amount']);
        $this->assertSame(500.0, $plan['wallet_amount']);
        $this->assertSame(200.0, $plan['card_amount']);
        $this->assertSame(0.0, $plan['card_processing_fee']);
        $this->assertSame(200.0, $plan['card_total_charge']);
        $this->assertTrue($plan['requires_card']);
    }

    public function test_allocate_can_fully_cover_total_with_bonus_and_wallet_only(): void
    {
        $service = app(CheckoutFundingAllocatorService::class);

        $plan = $service->allocate(250, [
            'gateway' => 'mixed',
            'apply_bonus_balance' => true,
            'bonus_balance' => 50,
            'apply_wallet_balance' => true,
            'wallet_balance' => 300,
        ]);

        $this->assertSame(50.0, $plan['bonus_amount']);
        $this->assertSame(200.0, $plan['wallet_amount']);
        $this->assertSame(0.0, $plan['card_amount']);
        $this->assertFalse($plan['requires_card']);
        $this->assertTrue($plan['is_fully_covered']);
    }
}
