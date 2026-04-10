<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event;
use App\Models\Organizer;
use App\Models\Review;
use App\Services\ReviewModerationTransitionService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminReviewController extends Controller
{
    public function __construct(protected ReviewModerationTransitionService $transitionService)
    {
    }

    public function index(Request $request)
    {
        if ($response = $this->authorizeReviewManagement($request)) {
            return $response;
        }

        $status = $this->normalizeStatusFilter((string) $request->query('status', 'pending_moderation'));
        $targetType = $this->normalizeTargetTypeFilter((string) $request->query('target_type', ''));
        $queryText = trim((string) $request->query('q', ''));
        $perPage = max(1, min((int) $request->query('per_page', 20), 100));

        $reviews = $this->buildFilteredQuery($status, $targetType, $queryText)
            ->with([
                'customer:id,fname,lname,username,email,photo',
                'event:id,organizer_id,owner_identity_id,thumbnail',
                'event.information:id,event_id,title',
                'booking:id,event_id,customer_id,organizer_id,organizer_identity_id,paymentStatus,scan_status',
            ])
            ->orderByRaw("CASE WHEN status = 'pending_moderation' THEN 0 ELSE 1 END")
            ->orderByDesc('submitted_at')
            ->orderByDesc('id')
            ->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'reviews' => $reviews,
            'metrics' => $this->buildDashboardMetrics(),
        ]);
    }

    public function show(Request $request, $id)
    {
        if ($response = $this->authorizeReviewManagement($request)) {
            return $response;
        }

        $review = Review::with([
            'customer:id,fname,lname,username,email,photo',
            'event:id,organizer_id,owner_identity_id,thumbnail',
            'event.information:id,event_id,title',
            'booking:id,event_id,customer_id,organizer_id,organizer_identity_id,paymentStatus,scan_status,created_at',
        ])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'review' => $review,
        ]);
    }

    public function publish(Request $request, $id)
    {
        if ($response = $this->authorizeReviewManagement($request)) {
            return $response;
        }

        $review = Review::findOrFail($id);
        $admin = $this->resolveAdminId($request);
        $note = trim((string) $request->input('note', ''));

        try {
            $this->transitionService->apply($review, 'publish', $admin, ['note' => $note]);
            $review->save();
            if ($review->customer) {
                app(\App\Services\LoyaltyService::class)->awardFromRule(
                    $review->customer,
                    'published_review',
                    'review',
                    (string) $review->id,
                    [
                        'event_id' => (int) $review->event_id,
                        'moderated_publish' => true,
                    ]
                );
            }
        } catch (\RuntimeException $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        } catch (\InvalidArgumentException $e) {
            return response()->json(['status' => 'validation_error', 'message' => $e->getMessage()], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Review published successfully.',
            'review' => $review,
        ]);
    }

    public function hide(Request $request, $id)
    {
        if ($response = $this->authorizeReviewManagement($request)) {
            return $response;
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
        }

        $review = Review::findOrFail($id);
        $admin = $this->resolveAdminId($request);

        try {
            $this->transitionService->apply($review, 'hide', $admin, $validator->validated());
            $review->save();
        } catch (\RuntimeException $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        } catch (\InvalidArgumentException $e) {
            return response()->json(['status' => 'validation_error', 'message' => $e->getMessage()], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Review hidden successfully.',
            'review' => $review,
        ]);
    }

    public function reject(Request $request, $id)
    {
        if ($response = $this->authorizeReviewManagement($request)) {
            return $response;
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
        }

        $review = Review::findOrFail($id);
        $admin = $this->resolveAdminId($request);

        try {
            $this->transitionService->apply($review, 'reject', $admin, $validator->validated());
            $review->save();
        } catch (\RuntimeException $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        } catch (\InvalidArgumentException $e) {
            return response()->json(['status' => 'validation_error', 'message' => $e->getMessage()], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Review rejected.',
            'review' => $review,
        ]);
    }

    private function resolveAdminId(Request $request): ?int
    {
        return optional($request->user('admin_sanctum'))->id;
    }

    private function authorizeReviewManagement(Request $request): ?JsonResponse
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

    private function buildFilteredQuery(?string $status, ?string $targetType, string $queryText): Builder
    {
        $query = Review::query();

        if (!empty($status) && $status !== 'all') {
            $query->where('status', $status);
        }

        $reviewableType = $this->mapTargetTypeToClass($targetType);
        if ($reviewableType !== null) {
            $query->where('reviewable_type', $reviewableType);
        }

        if ($queryText !== '') {
            $query->where(function (Builder $builder) use ($queryText) {
                $builder->where('comment', 'LIKE', '%' . $queryText . '%')
                    ->orWhereHas('customer', function (Builder $customerQuery) use ($queryText) {
                        $customerQuery->where('fname', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('lname', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('username', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('email', 'LIKE', '%' . $queryText . '%');
                    })
                    ->orWhereHas('event.information', function (Builder $eventContentQuery) use ($queryText) {
                        $eventContentQuery->where('title', 'LIKE', '%' . $queryText . '%');
                    });
            });
        }

        return $query;
    }

    private function buildDashboardMetrics(): array
    {
        $query = Review::query();

        return [
            'total' => (clone $query)->count(),
            'pending_moderation' => (clone $query)->where('status', 'pending_moderation')->count(),
            'published' => (clone $query)->where('status', 'published')->count(),
            'hidden' => (clone $query)->where('status', 'hidden')->count(),
            'rejected' => (clone $query)->where('status', 'rejected')->count(),
            'average_rating' => number_format((float) ((clone $query)->avg('rating') ?? 0), 1, '.', ''),
        ];
    }

    private function normalizeStatusFilter(string $status): ?string
    {
        $allowed = ['all', 'published', 'pending_moderation', 'hidden', 'rejected'];
        return in_array($status, $allowed, true) ? $status : 'pending_moderation';
    }

    private function normalizeTargetTypeFilter(string $targetType): ?string
    {
        $allowed = ['', 'event', 'organizer', 'artist'];
        return in_array($targetType, $allowed, true) ? $targetType : '';
    }

    private function mapTargetTypeToClass(?string $targetType): ?string
    {
        return match ($targetType) {
            'event' => Event::class,
            'organizer' => Organizer::class,
            'artist' => Artist::class,
            default => null,
        };
    }
}
