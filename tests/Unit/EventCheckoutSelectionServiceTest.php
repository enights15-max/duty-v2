<?php

namespace Tests\Unit;

use App\Services\EventCheckoutSelectionService;
use Illuminate\Http\Request;
use Tests\TestCase;

class EventCheckoutSelectionServiceTest extends TestCase
{
    public function test_build_context_normalizes_scalar_quantity_and_empty_seats(): void
    {
        $service = app(EventCheckoutSelectionService::class);
        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'quantity' => 2,
            'seat_data' => null,
        ]);

        $context = $service->buildContext($request);

        $this->assertSame([2], $context['quantity_list']);
        $this->assertSame(2.0, $context['quantity_scalar']);
        $this->assertSame([], $context['selected_seats']);
        $this->assertSame([], $context['selected_slot_seat']);
    }

    public function test_build_context_groups_seats_by_slot_id(): void
    {
        $service = app(EventCheckoutSelectionService::class);
        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'quantity' => [0, 0],
            'seat_data' => [
                [
                    'id' => 10,
                    'name' => 'A1',
                    'slot_id' => 7,
                    'slot_name' => 'Main',
                    'event_id' => 55,
                    'ticket_id' => 3,
                    'slot_unique_id' => 7001,
                    's_type' => 'vip',
                    'discount' => 2,
                    'price' => 25,
                    'payable_price' => 23,
                ],
                [
                    'id' => 11,
                    'name' => 'A2',
                    'slot_id' => 7,
                    'slot_name' => 'Main',
                    'event_id' => 55,
                    'ticket_id' => 3,
                    'slot_unique_id' => 7001,
                    's_type' => 'vip',
                    'discount' => 2,
                    'price' => 25,
                    'payable_price' => 23,
                ],
            ],
        ]);

        $context = $service->buildContext($request);

        $this->assertCount(1, $context['selected_slot_seat']);
        $this->assertSame(7, $context['selected_slot_seat'][0]['slot_id']);
        $this->assertSame(2, $context['selected_slot_seat'][0]['seat_count']);
        $this->assertSame(46, (int) $context['selected_slot_seat'][0]['seats_price']);
    }

    public function test_has_any_selection_for_venue_requires_quantity_or_seat_selection(): void
    {
        $service = app(EventCheckoutSelectionService::class);

        $this->assertFalse($service->hasAnySelection('venue', 'variation', [0, 0], 0.0, []));
        $this->assertTrue($service->hasAnySelection('venue', 'variation', [0, 1], 1.0, []));
        $this->assertTrue($service->hasAnySelection('venue', 'variation', [0, 0], 0.0, [['slot_id' => 1]]));
    }

    public function test_has_any_selection_preserves_legacy_free_behavior_for_online_events(): void
    {
        $service = app(EventCheckoutSelectionService::class);

        $this->assertTrue($service->hasAnySelection('online', 'free', [0], 0.0, []));
    }

    public function test_has_any_selection_for_normal_and_variation_online_events(): void
    {
        $service = app(EventCheckoutSelectionService::class);

        $this->assertFalse($service->hasAnySelection('online', 'normal', [0], 0.0, []));
        $this->assertTrue($service->hasAnySelection('online', 'normal', [0], 0.0, [['slot_id' => 1]]));
        $this->assertFalse($service->hasAnySelection('online', 'variation', [0, 0], 0.0, []));
        $this->assertTrue($service->hasAnySelection('online', 'variation', [0, 2], 2.0, []));
    }
}
