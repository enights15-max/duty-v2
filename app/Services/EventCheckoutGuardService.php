<?php

namespace App\Services;

use App\Models\BasicSettings\Basic;
use App\Models\Customer;

class EventCheckoutGuardService
{
    /**
     * Enforces guest checkout policy against global basic settings.
     *
     * @param int|string|null $requestedGuestCheckoutStatus
     * @return array<string, mixed>|null
     */
    public function enforceGuestCheckoutPolicy($requestedGuestCheckoutStatus, ?Basic $basic): ?array
    {
        if ((int) $requestedGuestCheckoutStatus !== 1) {
            return null;
        }

        $isGuestCheckoutEnabled = (int) ($basic->event_guest_checkout_status ?? 0) === 1;
        if ($isGuestCheckoutEnabled) {
            return null;
        }

        return [
            'success' => false,
            'message' => 'login Required',
        ];
    }

    /**
     * Enforces customer email/phone verification policy when logged in.
     *
     * @return array<string, mixed>|null
     */
    public function enforceCustomerVerification(?Customer $customer): ?array
    {
        if (!$customer) {
            return null;
        }

        if (is_null($customer->email_verified_at)) {
            return [
                'success' => false,
                'message' => 'email_verification_required',
            ];
        }

        if (is_null($customer->phone_verified_at)) {
            return [
                'success' => false,
                'message' => 'phone_verification_required',
            ];
        }

        return null;
    }
}
