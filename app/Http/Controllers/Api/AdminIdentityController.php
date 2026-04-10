<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Identity;
use App\Services\IdentityModerationNotificationService;
use App\Services\IdentityModerationTransitionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use InvalidArgumentException;
use RuntimeException;

class AdminIdentityController extends Controller
{
    public function __construct(
        private IdentityModerationNotificationService $notificationService,
        private IdentityModerationTransitionService $transitionService
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        if ($response = $this->authorizeIdentityManagement($request)) {
            return $response;
        }

        $perPage = max(1, min((int) $request->query('per_page', 20), 100));
        $status = $request->query('status');
        $type = $request->query('type');
        $ownerId = $request->query('owner_id');
        $search = trim((string) $request->query('q', ''));

        $query = Identity::query()->with('owner');

        if (!empty($status)) {
            $query->where('status', $status);
        }

        if (!empty($type)) {
            $query->where('type', $type);
        }

        if (!empty($ownerId)) {
            $query->where('owner_user_id', (int) $ownerId);
        }

        if ($search !== '') {
            $query->where(function ($builder) use ($search) {
                $builder
                    ->where('display_name', 'like', '%' . $search . '%')
                    ->orWhere('slug', 'like', '%' . $search . '%')
                    ->orWhereHas('owner', function ($ownerQuery) use ($search) {
                        $ownerQuery
                            ->where('email', 'like', '%' . $search . '%')
                            ->orWhere('username', 'like', '%' . $search . '%')
                            ->orWhere('first_name', 'like', '%' . $search . '%')
                            ->orWhere('last_name', 'like', '%' . $search . '%');
                    });
            });
        }

        $identities = $query->latest('id')->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'identities' => $identities,
        ]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        if ($response = $this->authorizeIdentityManagement($request)) {
            return $response;
        }

        $identity = Identity::query()
            ->with(['owner', 'members.user'])
            ->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'identity' => $identity,
        ]);
    }

    public function approve(Request $request, int $id): JsonResponse
    {
        return $this->handleModerationAction($request, $id, 'approve', 'approved');
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => $validator->errors(),
            ], 422);
        }

        return $this->handleModerationAction($request, $id, 'reject', 'rejected');
    }

    public function requestInfo(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
            'fields' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => $validator->errors(),
            ], 422);
        }

        return $this->handleModerationAction($request, $id, 'request_info', 'request_info');
    }

    public function suspend(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => $validator->errors(),
            ], 422);
        }

        return $this->handleModerationAction($request, $id, 'suspend', 'suspended');
    }

    public function reactivate(Request $request, int $id): JsonResponse
    {
        return $this->handleModerationAction($request, $id, 'reactivate', 'reactivated');
    }

    private function handleModerationAction(Request $request, int $id, string $action, string $notificationAction): JsonResponse
    {
        if ($response = $this->authorizeIdentityManagement($request)) {
            return $response;
        }

        $identity = Identity::query()->findOrFail($id);
        $adminId = (int) ($request->user()?->id ?? 0) ?: null;

        try {
            $context = $this->transitionService->apply($identity, $action, $adminId, $request->all());
        } catch (InvalidArgumentException $exception) {
            return response()->json([
                'status' => 'validation_error',
                'errors' => ['action' => [$exception->getMessage()]],
            ], 422);
        } catch (RuntimeException $exception) {
            return response()->json([
                'status' => 'error',
                'message' => $exception->getMessage(),
            ], 400);
        }

        $identity->save();
        $identity->refresh();

        $this->notificationService->notifyOwner($identity, $notificationAction, $context);

        return response()->json([
            'status' => 'success',
            'message' => $this->successMessageFor($notificationAction),
            'identity' => $identity,
        ]);
    }

    private function authorizeIdentityManagement(Request $request): ?JsonResponse
    {
        $admin = $request->user('admin_sanctum') ?: $request->user();

        if (!$admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthenticated.',
            ], 401);
        }

        if ($admin->role_id === null) {
            return null;
        }

        $role = $admin->role()->first();
        if (!$role) {
            return response()->json([
                'status' => 'error',
                'message' => 'Forbidden.',
            ], 403);
        }

        $permissions = json_decode((string) $role->permissions, true);
        if (!is_array($permissions)) {
            $permissions = [];
        }

        if (in_array('Identity Management', $permissions, true) || in_array('Customer Management', $permissions, true)) {
            return null;
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden.',
        ], 403);
    }

    private function successMessageFor(string $action): string
    {
        return match ($action) {
            'approved' => 'Identity approved successfully.',
            'rejected' => 'Identity rejected.',
            'request_info' => 'Revision request sent successfully.',
            'suspended' => 'Identity suspended successfully.',
            'reactivated' => 'Identity reactivated successfully.',
            default => 'Identity updated successfully.',
        };
    }
}
