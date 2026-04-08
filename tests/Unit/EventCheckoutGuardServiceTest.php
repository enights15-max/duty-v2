<?php

namespace Tests\Unit;

use App\Models\BasicSettings\Basic;
use App\Models\Customer;
use App\Services\EventCheckoutGuardService;
use Carbon\Carbon;
use Tests\TestCase;

class EventCheckoutGuardServiceTest extends TestCase
{
    public function test_guest_checkout_policy_blocks_when_requested_but_disabled(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $basic = new Basic();
        $basic->event_guest_checkout_status = 0;

        $result = $service->enforceGuestCheckoutPolicy(1, $basic);

        $this->assertIsArray($result);
        $this->assertFalse($result['success']);
        $this->assertSame('login Required', $result['message']);
    }

    public function test_guest_checkout_policy_passes_when_not_requested_or_enabled(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $basicDisabled = new Basic();
        $basicDisabled->event_guest_checkout_status = 0;
        $this->assertNull($service->enforceGuestCheckoutPolicy(0, $basicDisabled));

        $basicEnabled = new Basic();
        $basicEnabled->event_guest_checkout_status = 1;
        $this->assertNull($service->enforceGuestCheckoutPolicy(1, $basicEnabled));
    }

    public function test_customer_verification_skips_for_guest_customer(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $result = $service->enforceCustomerVerification(null);

        $this->assertNull($result);
    }

    public function test_customer_verification_requires_email_first(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $customer = new Customer();
        $customer->email_verified_at = null;
        $customer->phone_verified_at = Carbon::now();

        $result = $service->enforceCustomerVerification($customer);

        $this->assertIsArray($result);
        $this->assertFalse($result['success']);
        $this->assertSame('email_verification_required', $result['message']);
    }

    public function test_customer_verification_requires_phone_when_email_is_verified(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $customer = new Customer();
        $customer->email_verified_at = Carbon::now();
        $customer->phone_verified_at = null;

        $result = $service->enforceCustomerVerification($customer);

        $this->assertIsArray($result);
        $this->assertFalse($result['success']);
        $this->assertSame('phone_verification_required', $result['message']);
    }

    public function test_customer_verification_passes_when_email_and_phone_are_verified(): void
    {
        $service = app(EventCheckoutGuardService::class);

        $customer = new Customer();
        $customer->email_verified_at = Carbon::now();
        $customer->phone_verified_at = Carbon::now();

        $result = $service->enforceCustomerVerification($customer);

        $this->assertNull($result);
    }
}
