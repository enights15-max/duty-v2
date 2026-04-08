<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Services\EventInventorySummaryService;
use App\Services\EventWaitlistService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class EventWaitlistController extends Controller
{
    public function __construct(
        private EventInventorySummaryService $inventorySummaryService,
        private EventWaitlistService $eventWaitlistService,
    ) {
    }

    public function store(int $id): JsonResponse
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized.',
            ], 401);
        }

        $event = Event::query()->findOrFail($id);
        $eligibility = $this->eventWaitlistService->eligibilityForEvent($event);
        if (!($eligibility['can_join'] ?? false)) {
            $message = match ((string) ($eligibility['reason'] ?? '')) {
                'event_ended' => 'La waitlist no está disponible para eventos finalizados.',
                'marketplace_inventory_available' => 'Ya hay entradas disponibles en blackmarket para este evento.',
                default => 'La waitlist solo está disponible cuando la taquilla oficial está agotada.',
            };

            return response()->json([
                'status' => 'error',
                'message' => $message,
            ], 409);
        }

        $this->eventWaitlistService->subscribe($event, $customer);
        $summary = $this->eventWaitlistService->summaryForEvent($event, $customer);

        return response()->json([
            'status' => 'success',
            'message' => 'Te avisaremos si vuelven a aparecer entradas para este evento.',
            'data' => $summary,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized.',
            ], 401);
        }

        $event = Event::query()->findOrFail($id);
        $this->eventWaitlistService->unsubscribe($event, $customer);
        $summary = $this->eventWaitlistService->summaryForEvent($event, $customer);

        return response()->json([
            'status' => 'success',
            'message' => 'Ya no estás en la waitlist de este evento.',
            'data' => $summary,
        ]);
    }
}
