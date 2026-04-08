<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Services\POSService;
use App\Models\PosTerminal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class POSController extends Controller
{
    protected $posService;

    public function __construct(POSService $posService)
    {
        $this->posService = $posService;
    }

    /**
     * Authorize a new terminal (Organizer Action).
     */
    public function authorizeTerminal(Request $request)
    {
        $actor = $request->user();
        if (!$actor instanceof Customer) {
            return response()->json(['status' => 'error', 'message' => 'Invalid authenticated actor.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'terminal_uuid' => 'required|string|unique:pos_terminals',
            'name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $terminal = $this->posService->authorizeTerminal(
            $request->terminal_uuid,
            $actor,
            $request->name
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Terminal authorized successfully.',
            'data' => $terminal
        ]);
    }

    /**
     * Capture payment from NFC tap (Terminal Action).
     */
    public function capture(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'terminal_uuid' => 'required|string|exists:pos_terminals,terminal_uuid',
            'uid_raw' => 'required|string',
            'amount' => 'required|numeric|min:0.01',
            'pin' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $terminal = PosTerminal::where('terminal_uuid', $request->terminal_uuid)->first();

        if ($terminal->status !== 'active') {
            return response()->json(['status' => 'error', 'message' => 'Terminal is revoked or inactive.'], 403);
        }

        try {
            $transaction = $this->posService->capturePayment(
                $terminal,
                $request->uid_raw,
                $request->amount,
                $request->pin
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Payment captured successfully.',
                'transaction_id' => $transaction->id,
                'amount' => $transaction->amount
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
