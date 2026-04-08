<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Reservation\TicketReservation;
use App\Services\TicketReservationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TicketReservationController extends Controller
{
    public function __construct(private TicketReservationService $ticketReservationService)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $reservations = TicketReservation::query()
            ->where('customer_id', $customer->id)
            ->with(['ticket', 'event', 'payments', 'bookings.paymentAllocations'])
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'success' => true,
            'reservations' => $reservations,
        ]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $reservation = TicketReservation::query()
            ->where('customer_id', $customer->id)
            ->with(['ticket', 'event', 'payments', 'bookings.paymentAllocations'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'reservation' => $reservation,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $validated = $request->validate([
            'ticket_id' => 'required|integer|exists:tickets,id',
            'quantity' => 'required|integer|min:1',
            'event_date' => 'nullable|string|max:255',
            'payment_amount' => 'nullable|numeric|min:0.01',
            'gateway' => 'required|string',
            'apply_wallet_balance' => 'nullable|boolean',
            'apply_bonus_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
            'fname' => 'nullable|string|max:255',
            'lname' => 'nullable|string|max:255',
            'email' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
            'country' => 'nullable|string|max:255',
            'state' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:255',
            'zip_code' => 'nullable|string|max:255',
            'address' => 'nullable|string|max:255',
        ]);

        try {
            $reservation = $this->ticketReservationService->createReservation($customer, $validated);
        } catch (\Throwable $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'reservation' => $reservation,
        ], 201);
    }

    public function previewStore(Request $request): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $validated = $request->validate([
            'ticket_id' => 'required|integer|exists:tickets,id',
            'quantity' => 'required|integer|min:1',
            'event_date' => 'nullable|string|max:255',
            'payment_amount' => 'required|numeric|min:0.01',
            'gateway' => 'required|string',
            'apply_wallet_balance' => 'nullable|boolean',
            'apply_bonus_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
        ]);

        try {
            $preview = $this->ticketReservationService->previewCreateReservation($customer, $validated);
        } catch (\Throwable $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'data' => $preview,
        ]);
    }

    public function pay(Request $request, int $id): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $reservation = TicketReservation::findOrFail($id);
        $validated = $request->validate([
            'payment_amount' => 'required|numeric|min:0.01',
            'gateway' => 'required|string',
            'apply_wallet_balance' => 'nullable|boolean',
            'apply_bonus_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
        ]);

        try {
            $reservation = $this->ticketReservationService->payReservation($customer, $reservation, $validated);
        } catch (\Throwable $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'reservation' => $reservation,
        ]);
    }

    public function previewPay(Request $request, int $id): JsonResponse
    {
        $customer = $request->user();
        if (!$customer instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $reservation = TicketReservation::findOrFail($id);
        $validated = $request->validate([
            'payment_amount' => 'required|numeric|min:0.01',
            'gateway' => 'required|string',
            'apply_wallet_balance' => 'nullable|boolean',
            'apply_bonus_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
        ]);

        try {
            $preview = $this->ticketReservationService->previewReservationPayment($customer, $reservation, $validated);
        } catch (\Throwable $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'data' => $preview,
        ]);
    }
}
