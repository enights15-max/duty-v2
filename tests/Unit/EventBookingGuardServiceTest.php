<?php

namespace Tests\Unit;

use App\Models\Customer;
use App\Models\Event;
use App\Services\EventBookingGuardService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class EventBookingGuardServiceTest extends TestCase
{
    private EventBookingGuardService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = app(EventBookingGuardService::class);
    }

    public function test_resolve_authenticated_booking_customer_rejects_customer_id_without_authenticated_customer(): void
    {
        $guard = \Mockery::mock();
        $guard->shouldReceive('user')->once()->andReturn(null);

        Auth::shouldReceive('guard')
            ->once()
            ->with('sanctum')
            ->andReturn($guard);

        $request = Request::create('/api/event-booking', 'POST', ['customer_id' => 999]);
        $result = $this->service->resolveAuthenticatedBookingCustomer($request);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(401, $result->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertSame('Authentication required when customer_id is provided.', $payload['message']);
    }

    public function test_resolve_authenticated_booking_customer_rejects_customer_id_mismatch(): void
    {
        $customer = new Customer();
        $customer->id = 88;

        $guard = \Mockery::mock();
        $guard->shouldReceive('user')->once()->andReturn($customer);

        Auth::shouldReceive('guard')
            ->once()
            ->with('sanctum')
            ->andReturn($guard);

        $request = Request::create('/api/event-booking', 'POST', ['customer_id' => 99]);
        $result = $this->service->resolveAuthenticatedBookingCustomer($request);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(403, $result->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertSame('customer_id does not match the authenticated account.', $payload['message']);
    }

    public function test_resolve_authenticated_booking_customer_binds_authenticated_customer_id(): void
    {
        $customer = new Customer();
        $customer->id = 77;

        $guard = \Mockery::mock();
        $guard->shouldReceive('user')->once()->andReturn($customer);

        Auth::shouldReceive('guard')
            ->once()
            ->with('sanctum')
            ->andReturn($guard);

        $request = Request::create('/api/event-booking', 'POST', ['customer_id' => 'guest']);
        $result = $this->service->resolveAuthenticatedBookingCustomer($request);

        $this->assertIsArray($result);
        $this->assertSame(77, $result['authCustomer']->id);
        $this->assertSame(77, (int) $request->input('customer_id'));
    }

    public function test_validate_event_date_window_rejects_past_single_event(): void
    {
        $event = new Event();
        $event->date_type = 'single';
        $event->start_date = Carbon::now()->subDay()->toDateString();

        $result = $this->service->validateEventDateWindow($event);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(422, $result->getStatusCode());
        $this->assertSame('event_expired', $payload['error_type']);
    }

    public function test_validate_event_age_restriction_requires_login_when_event_is_restricted(): void
    {
        $event = new Event();
        $event->age_limit = 18;

        $result = $this->service->validateEventAgeRestriction($event, null);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(403, $result->getStatusCode());
        $this->assertSame('login_required', $payload['error_type']);
    }

    public function test_validate_event_age_restriction_requires_date_of_birth(): void
    {
        $event = new Event();
        $event->age_limit = 18;

        $customer = new Customer();
        $customer->date_of_birth = null;

        $result = $this->service->validateEventAgeRestriction($event, $customer);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(403, $result->getStatusCode());
        $this->assertSame('dob_required', $payload['error_type']);
    }

    public function test_validate_event_age_restriction_rejects_underage_customer(): void
    {
        $event = new Event();
        $event->age_limit = 18;

        $customer = new Customer();
        $customer->date_of_birth = Carbon::now()->subYears(15)->toDateString();

        $result = $this->service->validateEventAgeRestriction($event, $customer);

        $this->assertInstanceOf(JsonResponse::class, $result);
        $payload = $result->getData(true);
        $this->assertSame(403, $result->getStatusCode());
        $this->assertSame('age_restricted', $payload['error_type']);
    }

    public function test_validate_event_age_restriction_passes_for_eligible_customer(): void
    {
        $event = new Event();
        $event->age_limit = 18;

        $customer = new Customer();
        $customer->date_of_birth = Carbon::now()->subYears(25)->toDateString();

        $result = $this->service->validateEventAgeRestriction($event, $customer);

        $this->assertNull($result);
    }
}
