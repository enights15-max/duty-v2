<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PrivacySettingsController extends Controller
{
    public function show(): JsonResponse
    {
        $customer = Auth::guard('sanctum')->user();

        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'data' => $this->payload($customer),
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $customer = Auth::guard('sanctum')->user();

        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $validated = $request->validate([
            'is_private' => 'sometimes|boolean',
            'show_interested_events' => 'sometimes|boolean',
            'show_attended_events' => 'sometimes|boolean',
            'show_upcoming_attendance' => 'sometimes|boolean',
        ]);

        if (!empty($validated)) {
            $customer->fill($validated);
            $customer->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Privacy settings updated successfully.',
            'data' => $this->payload($customer->fresh()),
        ]);
    }

    private function payload($customer): array
    {
        return [
            'is_private' => (bool) ($customer->is_private ?? false),
            'show_interested_events' => $customer->show_interested_events === null ? true : (bool) $customer->show_interested_events,
            'show_attended_events' => $customer->show_attended_events === null ? true : (bool) $customer->show_attended_events,
            'show_upcoming_attendance' => $customer->show_upcoming_attendance === null ? true : (bool) $customer->show_upcoming_attendance,
        ];
    }
}
