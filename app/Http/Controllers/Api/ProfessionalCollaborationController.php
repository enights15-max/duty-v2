<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\EventCollaboratorSplitService;
use App\Traits\HasIdentityActor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfessionalCollaborationController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private EventCollaboratorSplitService $collaboratorSplitService
    ) {
    }

    public function index(): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active professional identity is required.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data' => $this->collaboratorSplitService->identitySummary($identity),
        ]);
    }

    public function claim(int $earningId): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active professional identity is required.',
            ], 403);
        }

        try {
            $claim = $this->collaboratorSplitService->claimEarningToWallet($earningId, $identity);
        } catch (\RuntimeException $exception) {
            return response()->json([
                'status' => 'error',
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Collaboration earning released to your professional wallet.',
            'data' => $this->collaboratorSplitService->identitySummary($identity),
            'claim' => [
                'claimed_amount' => $claim['claimed_amount'] ?? 0,
                'balance_before' => data_get($claim, 'balance_transaction.balance_before'),
                'balance_after' => data_get($claim, 'balance_transaction.balance_after'),
                'reference_id' => data_get($claim, 'balance_transaction.id'),
            ],
        ]);
    }

    public function updateMode(Request $request, int $earningId): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active professional identity is required.',
            ], 403);
        }

        $validated = $request->validate([
            'auto_release' => ['required', 'boolean'],
        ]);

        try {
            $result = $this->collaboratorSplitService->updateEarningReleaseMode(
                $earningId,
                $identity,
                filter_var($validated['auto_release'], FILTER_VALIDATE_BOOLEAN)
            );
        } catch (\RuntimeException $exception) {
            return response()->json([
                'status' => 'error',
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => ($result['auto_release'] ?? false)
                ? 'La colaboración quedó en auto release.'
                : 'La colaboración quedó en reclamo manual.',
            'data' => $this->collaboratorSplitService->identitySummary($identity),
            'earning' => $result['earning']
                ? [
                    'id' => $result['earning']->id,
                    'event_id' => $result['earning']->event_id,
                    'status' => $result['earning']->status,
                    'claimable_amount' => $result['earning']->claimable_amount,
                    'release_mode' => $result['release_mode'] ?? null,
                    'effective_release_mode' => $result['effective_release_mode'] ?? null,
                    'requires_claim' => $result['requires_claim'] ?? true,
                    'auto_release' => $result['auto_release'] ?? false,
                    'claimed_at' => $result['earning']->claimed_at?->toIso8601String(),
                  ]
                : null,
        ]);
    }
}
