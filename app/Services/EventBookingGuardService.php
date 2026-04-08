<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EventBookingGuardService
{
    /**
     * Ensure customer ownership is aligned with sanctum actor and block spoofing.
     *
     * @return array{authCustomer: Customer|null}|JsonResponse
     */
    public function resolveAuthenticatedBookingCustomer(Request $request): array|JsonResponse
    {
        $authActor = Auth::guard('sanctum')->user();
        $authCustomer = $authActor instanceof Customer ? $authActor : null;
        $requestedCustomerId = $request->input('customer_id');

        if ($authCustomer) {
            if (!empty($requestedCustomerId) && $requestedCustomerId !== 'guest' && (int) $requestedCustomerId !== (int) $authCustomer->id) {
                return response()->json([
                    'status' => false,
                    'message' => 'customer_id does not match the authenticated account.',
                ], 403);
            }

            // Always bind booking ownership to authenticated customer.
            $request->merge(['customer_id' => $authCustomer->id]);
        } elseif (!empty($requestedCustomerId) && $requestedCustomerId !== 'guest') {
            return response()->json([
                'status' => false,
                'message' => 'Authentication required when customer_id is provided.',
            ], 401);
        }

        return ['authCustomer' => $authCustomer];
    }

    public function validateEventDateWindow(?Event $event): ?JsonResponse
    {
        if (!$event) {
            return null;
        }

        if ($event->date_type === 'single' && Carbon::parse($event->start_date)->endOfDay()->isPast()) {
            return response()->json([
                'status' => false,
                'message' => 'Este evento ya ha pasado y no se pueden comprar boletos.',
                'error_type' => 'event_expired',
            ], 422);
        }

        if ($event->date_type === 'multiple' && Carbon::parse($event->end_date_time)->endOfDay()->isPast()) {
            return response()->json([
                'status' => false,
                'message' => 'Este evento ya ha terminado y no se pueden comprar boletos.',
                'error_type' => 'event_expired',
            ], 422);
        }

        return null;
    }

    public function validateEventAgeRestriction(?Event $event, ?Customer $authCustomer): ?JsonResponse
    {
        if (!$event || (int) $event->age_limit <= 0) {
            return null;
        }

        if (!$authCustomer) {
            return response()->json([
                'status' => false,
                'message' => 'Login required for age restricted events',
                'error_type' => 'login_required',
            ], 403);
        }

        if (!$authCustomer->date_of_birth) {
            return response()->json([
                'status' => false,
                'message' => 'Date of birth required',
                'error_type' => 'dob_required',
            ], 403);
        }

        if ($authCustomer->age < $event->age_limit) {
            return response()->json([
                'status' => false,
                'message' => 'No cumples con la edad mínima para este evento.',
                'error_type' => 'age_restricted',
            ], 403);
        }

        return null;
    }
}
