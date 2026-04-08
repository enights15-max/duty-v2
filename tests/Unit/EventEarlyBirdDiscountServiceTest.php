<?php

namespace Tests\Unit;

use App\Services\EventEarlyBirdDiscountService;
use Carbon\Carbon;
use stdClass;
use Tests\TestCase;

class EventEarlyBirdDiscountServiceTest extends TestCase
{
    public function test_calculate_returns_zero_when_discount_is_disabled(): void
    {
        $service = app(EventEarlyBirdDiscountService::class);

        $ticket = new stdClass();
        $ticket->early_bird_discount = 'disable';
        $ticket->early_bird_discount_type = 'fixed';
        $ticket->early_bird_discount_amount = 10;
        $ticket->early_bird_discount_date = '2026-03-10';
        $ticket->early_bird_discount_time = ' 23:59:59';

        $result = $service->calculate($ticket, 100.0, Carbon::parse('2026-03-10 12:00:00'));

        $this->assertSame(0.0, $result);
    }

    public function test_calculate_returns_fixed_discount_when_active(): void
    {
        $service = app(EventEarlyBirdDiscountService::class);

        $ticket = new stdClass();
        $ticket->early_bird_discount = 'enable';
        $ticket->early_bird_discount_type = 'fixed';
        $ticket->early_bird_discount_amount = 15;
        $ticket->early_bird_discount_date = '2026-03-10';
        $ticket->early_bird_discount_time = ' 23:59:59';

        $result = $service->calculate($ticket, 100.0, Carbon::parse('2026-03-10 12:00:00'));

        $this->assertSame(15.0, $result);
    }

    public function test_calculate_returns_percentage_discount_when_active(): void
    {
        $service = app(EventEarlyBirdDiscountService::class);

        $ticket = new stdClass();
        $ticket->early_bird_discount = 'enable';
        $ticket->early_bird_discount_type = 'percentage';
        $ticket->early_bird_discount_amount = 20;
        $ticket->early_bird_discount_date = '2026-03-10';
        $ticket->early_bird_discount_time = ' 23:59:59';

        $result = $service->calculate($ticket, 150.0, Carbon::parse('2026-03-10 12:00:00'));

        $this->assertSame(30.0, $result);
    }

    public function test_calculate_returns_zero_when_discount_is_expired(): void
    {
        $service = app(EventEarlyBirdDiscountService::class);

        $ticket = new stdClass();
        $ticket->early_bird_discount = 'enable';
        $ticket->early_bird_discount_type = 'fixed';
        $ticket->early_bird_discount_amount = 15;
        $ticket->early_bird_discount_date = '2026-03-10';
        $ticket->early_bird_discount_time = ' 10:00:00';

        $result = $service->calculate($ticket, 100.0, Carbon::parse('2026-03-10 10:00:01'));

        $this->assertSame(0.0, $result);
    }
}
