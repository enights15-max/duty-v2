<?php

namespace App\Http\Controllers\BackEnd;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event;
use App\Models\Organizer;
use App\Models\Review;
use App\Services\ReviewModerationTransitionService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class ReviewManagementController extends Controller
{
    public function __construct(protected ReviewModerationTransitionService $transitionService)
    {
    }

    public function index(Request $request)
    {
        $status = $this->normalizeStatusFilter((string) $request->query('status', 'pending_moderation'));
        $targetType = $this->normalizeTargetTypeFilter((string) $request->query('target_type', ''));
        $queryText = trim((string) $request->query('q', ''));

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
            ->paginate(20)
            ->withQueryString();

        $metrics = $this->buildDashboardMetrics();

        return view('backend.end-user.review.index', compact(
            'reviews',
            'status',
            'targetType',
            'queryText',
            'metrics'
        ));
    }

    public function show($id)
    {
        $review = Review::with([
            'customer:id,fname,lname,username,email,photo',
            'event:id,organizer_id,owner_identity_id,thumbnail',
            'event.information:id,event_id,title',
            'booking:id,event_id,customer_id,organizer_id,organizer_identity_id,paymentStatus,scan_status,created_at',
        ])->findOrFail($id);

        $meta = is_array($review->meta) ? $review->meta : [];
        $history = is_array($meta['moderation_history'] ?? null) ? $meta['moderation_history'] : [];

        return view('backend.end-user.review.show', compact('review', 'history'));
    }

    public function publish(Request $request, $id)
    {
        $review = Review::findOrFail($id);
        $note = trim((string) $request->input('note', ''));

        try {
            $this->transitionService->apply($review, 'publish', auth('admin')->id(), [
                'note' => $note,
            ]);
            $review->save();
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Review published successfully.');
        return redirect()->back();
    }

    public function hide(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
        ]);

        if ($validator->fails()) {
            Session::flash('warning', 'Hide reason is required.');
            return redirect()->back();
        }

        $review = Review::findOrFail($id);

        try {
            $this->transitionService->apply($review, 'hide', auth('admin')->id(), [
                'reason' => $request->reason,
            ]);
            $review->save();
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Review hidden successfully.');
        return redirect()->back();
    }

    public function reject(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
        ]);

        if ($validator->fails()) {
            Session::flash('warning', 'Reject reason is required.');
            return redirect()->back();
        }

        $review = Review::findOrFail($id);

        try {
            $this->transitionService->apply($review, 'reject', auth('admin')->id(), [
                'reason' => $request->reason,
            ]);
            $review->save();
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Review rejected.');
        return redirect()->back();
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
