<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Services\NFCService;
use App\Models\NfcToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class NFCController extends Controller
{
    protected $nfcService;

    public function __construct(NFCService $nfcService)
    {
        $this->nfcService = $nfcService;
    }

    /**
     * Link a new NFC tag to the authenticated user.
     */
    public function link(Request $request)
    {
        $actor = $request->user();
        if (!$actor instanceof Customer) {
            return response()->json(['status' => 'error', 'message' => 'Invalid authenticated actor.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'uid_raw' => 'required|string',
            'pin' => 'nullable|string|min:4|max:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $token = $this->nfcService->linkToken(
            $actor,
            $request->uid_raw,
            $request->pin
        );

        return response()->json([
            'status' => 'success',
            'message' => 'NFC token linked successfully.',
            'data' => [
                'id' => $token->id,
                'status' => $token->status,
                'daily_limit' => $token->daily_limit
            ]
        ]);
    }

    /**
     * Update/Set the PIN for the user's token.
     */
    public function setPin(Request $request)
    {
        $actor = $request->user();
        if (!$actor instanceof Customer) {
            return response()->json(['status' => 'error', 'message' => 'Invalid authenticated actor.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'pin' => 'required|string|min:4|max:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $token = NfcToken::forActor($actor)->first();

        if (!$token) {
            return response()->json(['status' => 'error', 'message' => 'No linked token found.'], 404);
        }

        $token->update(['pin_hash' => Hash::make($request->pin)]);

        return response()->json([
            'status' => 'success',
            'message' => 'PIN updated successfully.'
        ]);
    }

    /**
     * Block the user's token (Lost/Stolen).
     */
    public function block(Request $request)
    {
        $actor = $request->user();
        if (!$actor instanceof Customer) {
            return response()->json(['status' => 'error', 'message' => 'Invalid authenticated actor.'], 403);
        }

        $token = NfcToken::forActor($actor)->first();

        if (!$token) {
            return response()->json(['status' => 'error', 'message' => 'No linked token found.'], 404);
        }

        $token->update(['status' => 'locked']);

        return response()->json([
            'status' => 'success',
            'message' => 'Token has been locked/blocked.'
        ]);
    }
}
