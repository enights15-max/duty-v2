<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventController;
use Illuminate\Http\Request;
use Tests\TestCase;

class EventBookingContractSmokeTest extends TestCase
{
    public function test_store_booking_requires_minimum_payload(): void
    {
        $request = Request::create('/api/event-booking', 'POST', []);
        $response = app(EventController::class)->store_booking($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertArrayHasKey('validation_errors', $payload);
        $this->assertArrayHasKey('event_id', $payload['validation_errors']);
        $this->assertArrayHasKey('gateway', $payload['validation_errors']);
    }

    public function test_verify_payment_requires_gateway_and_total(): void
    {
        $request = Request::create('/api/event/verify-payment', 'POST', []);
        $response = app(EventController::class)->verifyPayment($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertArrayHasKey('validation_errors', $payload);
        $this->assertArrayHasKey('gateway', $payload['validation_errors']);
        $this->assertArrayHasKey('total', $payload['validation_errors']);
    }

    public function test_checkout_verify_requires_minimum_payload(): void
    {
        $request = Request::create('/api/event/checkout-verify', 'POST', []);
        $response = app(EventController::class)->checkoutVerify($request);
        $payload = $response->getData(true);

        $this->assertFalse($payload['status']);
        $this->assertArrayHasKey('validation_errors', $payload);
        $this->assertArrayHasKey('event_id', $payload['validation_errors']);
        $this->assertArrayHasKey('quantity', $payload['validation_errors']);
        $this->assertArrayHasKey('pricing_type', $payload['validation_errors']);
    }
}
