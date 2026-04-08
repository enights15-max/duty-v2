<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Identity;
use Illuminate\Support\Facades\Validator;

class AdminIdentityController extends Controller
{
    /**
     * List all identities (filtered by status).
     */
    public function index(Request $request)
    {
        $status = $request->query('status');

        $query = Identity::with('owner');

        if ($status) {
            $query->where('status', $status);
        }

        $identities = $query->paginate(20);

        return response()->json([
            'status' => 'success',
            'identities' => $identities
        ]);
    }

    /**
     * Approve a pending identity.
     */
    public function approve(Request $request, $id)
    {
        $identity = Identity::findOrFail($id);

        if ($identity->status !== 'pending') {
            return response()->json(['status' => 'error', 'message' => 'Identity is not in pending status.'], 400);
        }

        $identity->status = 'active';
        $identity->save();

        // Optional: Send notification to user

        return response()->json([
            'status' => 'success',
            'message' => 'Identity approved successfully.',
            'identity' => $identity
        ]);
    }

    /**
     * Reject a pending identity.
     */
    public function reject(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
        }

        $identity = Identity::findOrFail($id);

        if ($identity->status !== 'pending') {
            return response()->json(['status' => 'error', 'message' => 'Identity is not in pending status.'], 400);
        }

        $identity->status = 'rejected';
        $meta = $identity->meta ?? [];
        $meta['rejection_reason'] = $request->reason;
        $identity->meta = $meta;
        $identity->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Identity rejected.',
            'identity' => $identity
        ]);
    }
}
