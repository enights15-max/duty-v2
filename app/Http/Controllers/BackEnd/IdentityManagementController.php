<?php

namespace App\Http\Controllers\BackEnd;

use App\Http\Controllers\Controller;
use App\Models\Identity;
use App\Services\IdentityLegacyMirrorService;
use App\Services\IdentityModerationNotificationService;
use App\Services\IdentityModerationTransitionService;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class IdentityManagementController extends Controller
{
    protected array $professionalTypes = ['artist', 'organizer', 'venue'];

    protected IdentityModerationNotificationService $notificationService;
    protected IdentityModerationTransitionService $transitionService;
    protected IdentityLegacyMirrorService $legacyMirror;

    public function __construct(
        IdentityModerationNotificationService $notificationService,
        IdentityModerationTransitionService $transitionService,
        ?IdentityLegacyMirrorService $legacyMirror = null
    )
    {
        $this->notificationService = $notificationService;
        $this->transitionService = $transitionService;
        $this->legacyMirror = $legacyMirror ?? app(IdentityLegacyMirrorService::class);
    }

    public function index(Request $request)
    {
        $status = $this->normalizeStatusFilter((string) $request->query('status', ''));
        $type = $this->normalizeTypeFilter((string) $request->query('type', ''));
        $queryText = trim((string) $request->query('q', ''));
        $includePersonal = $request->boolean('include_personal') || $type === 'personal';

        $query = $this->buildFilteredQuery($status, $type, $queryText, $includePersonal)
            ->with(['owner', 'members'])
            ->orderByDesc('created_at');

        $identities = $query->paginate(20);
        $metrics = $this->buildDashboardMetrics($includePersonal);

        return view('backend.end-user.identity.index', compact(
            'identities',
            'status',
            'type',
            'queryText',
            'metrics',
            'includePersonal'
        ));
    }

    public function show($id)
    {
        $identity = Identity::with(['owner', 'members.user'])->findOrFail($id);
        $meta = $identity->meta ?? [];
        $history = $meta['moderation_history'] ?? [];
        if (!is_array($history)) {
            $history = [];
        }

        return view('backend.end-user.identity.show', compact('identity', 'history'));
    }

    public function export(Request $request)
    {
        $status = $this->normalizeStatusFilter((string) $request->query('status', ''));
        $type = $this->normalizeTypeFilter((string) $request->query('type', ''));
        $queryText = trim((string) $request->query('q', ''));
        $includePersonal = $request->boolean('include_personal') || $type === 'personal';

        $query = $this->buildFilteredQuery($status, $type, $queryText, $includePersonal)
            ->with('owner')
            ->orderBy('id');

        $fileName = 'identity-moderation-' . now()->format('Ymd_His') . '.csv';
        $headers = [
            'ID',
            'Type',
            'Status',
            'Display Name',
            'Slug',
            'Owner User ID',
            'Owner Email',
            'Owner Username',
            'Created At',
            'Updated At',
            'Approved At',
            'Rejected At',
            'Suspended At',
            'Reactivated At',
            'Last Action',
            'Last Action ID',
            'Last Action At',
            'Last Action Admin ID',
            'Rejection Reason',
            'Suspension Reason',
            'Revision Request Reason',
            'Moderation Events',
        ];

        return response()->streamDownload(function () use ($query, $headers) {
            $output = fopen('php://output', 'w');
            if ($output === false) {
                return;
            }

            fputcsv($output, $headers);

            $query->chunkById(300, function ($identities) use ($output) {
                foreach ($identities as $identity) {
                    $meta = is_array($identity->meta) ? $identity->meta : [];
                    $snapshot = $this->extractModerationSnapshot($meta);

                    fputcsv($output, [
                        $identity->id,
                        $identity->type,
                        $identity->status,
                        $identity->display_name,
                        $identity->slug,
                        $identity->owner_user_id,
                        optional($identity->owner)->email,
                        optional($identity->owner)->username,
                        optional($identity->created_at)->toDateTimeString(),
                        optional($identity->updated_at)->toDateTimeString(),
                        $meta['approved_at'] ?? '',
                        $meta['rejected_at'] ?? '',
                        $meta['suspended_at'] ?? '',
                        $meta['reactivated_at'] ?? '',
                        $snapshot['action'],
                        $snapshot['action_id'],
                        $snapshot['at'],
                        $snapshot['admin_id'],
                        $meta['rejection_reason'] ?? '',
                        $meta['suspension_reason'] ?? '',
                        data_get($meta, 'revision_request.reason', ''),
                        $snapshot['events_count'],
                    ]);
                }
            });

            fclose($output);
        }, $fileName, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }

    public function approve(Request $request, $id)
    {
        $identity = Identity::findOrFail($id);
        $note = trim((string) $request->input('note', ''));
        try {
            $context = $this->transitionService->apply($identity, 'approve', auth('admin')->id(), [
                'note' => $note,
            ]);
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        $identity->save();
        $this->legacyMirror->syncIdentity($identity);
        $this->notificationService->notifyOwner($identity, 'approved', $context);

        Session::flash('success', 'Identity approved successfully.');
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

        $identity = Identity::findOrFail($id);

        try {
            $context = $this->transitionService->apply($identity, 'reject', auth('admin')->id(), [
                'reason' => $request->reason,
            ]);
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        $identity->save();
        $this->notificationService->notifyOwner($identity, 'rejected', $context);

        Session::flash('success', 'Identity rejected.');
        return redirect()->back();
    }

    public function requestInfo(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
            'fields' => 'nullable',
        ]);

        if ($validator->fails()) {
            Session::flash('warning', 'Reason is required to request additional information.');
            return redirect()->back();
        }

        $identity = Identity::findOrFail($id);
        $reason = trim((string) $request->reason);
        $fields = $this->normalizeRequestInfoFields($request->input('fields'));

        try {
            $context = $this->transitionService->apply($identity, 'request_info', auth('admin')->id(), [
                'reason' => $reason,
                'fields' => $fields,
            ]);
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        $identity->save();
        $this->notificationService->notifyOwner($identity, 'request_info', $context);

        Session::flash('success', 'Additional information requested.');
        return redirect()->back();
    }

    public function suspend(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:2000',
        ]);

        if ($validator->fails()) {
            Session::flash('warning', 'Suspension reason is required.');
            return redirect()->back();
        }

        $identity = Identity::findOrFail($id);

        try {
            $context = $this->transitionService->apply($identity, 'suspend', auth('admin')->id(), [
                'reason' => $request->reason,
            ]);
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        $identity->save();
        $this->notificationService->notifyOwner($identity, 'suspended', $context);

        Session::flash('success', 'Identity suspended.');
        return redirect()->back();
    }

    public function reactivate(Request $request, $id)
    {
        $identity = Identity::findOrFail($id);
        $note = trim((string) $request->input('note', ''));
        try {
            $context = $this->transitionService->apply($identity, 'reactivate', auth('admin')->id(), [
                'note' => $note,
            ]);
        } catch (\Throwable $e) {
            Session::flash('warning', $e->getMessage());
            return redirect()->back();
        }

        $identity->save();
        $this->legacyMirror->syncIdentity($identity);
        $this->notificationService->notifyOwner($identity, 'reactivated', $context);

        Session::flash('success', 'Identity reactivated.');
        return redirect()->back();
    }

    protected function buildDashboardMetrics(bool $includePersonal = false): array
    {
        $baseQuery = Identity::query();
        if (!$includePersonal) {
            $baseQuery->whereIn('type', $this->professionalTypes);
        }

        $groupedStatus = (clone $baseQuery)
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $total = (int) $groupedStatus->sum();
        $pending = (int) ($groupedStatus['pending'] ?? 0);
        $active = (int) ($groupedStatus['active'] ?? 0);
        $rejected = (int) ($groupedStatus['rejected'] ?? 0);
        $suspended = (int) ($groupedStatus['suspended'] ?? 0);

        $pendingOver48h = (clone $baseQuery)
            ->where('status', 'pending')
            ->where('created_at', '<', now()->subHours(48))
            ->count();

        $approvalHours = [];
        $rejectionHours = [];

        (clone $baseQuery)
            ->whereIn('status', ['active', 'suspended', 'rejected'])
            ->select(['id', 'status', 'created_at', 'meta'])
            ->chunk(300, function ($identities) use (&$approvalHours, &$rejectionHours) {
                foreach ($identities as $identity) {
                    $meta = $identity->meta ?? [];
                    if (!is_array($meta)) {
                        continue;
                    }

                    if (in_array($identity->status, ['active', 'suspended'], true)) {
                        $hours = $this->calculateReviewHours($identity->created_at, $meta['approved_at'] ?? null);
                        if ($hours !== null) {
                            $approvalHours[] = $hours;
                        }
                        continue;
                    }

                    if ($identity->status === 'rejected') {
                        $hours = $this->calculateReviewHours($identity->created_at, $meta['rejected_at'] ?? null);
                        if ($hours !== null) {
                            $rejectionHours[] = $hours;
                        }
                    }
                }
            });

        $avgApprovalHours = empty($approvalHours) ? null : round(array_sum($approvalHours) / count($approvalHours), 2);
        $avgRejectionHours = empty($rejectionHours) ? null : round(array_sum($rejectionHours) / count($rejectionHours), 2);

        return [
            'total' => $total,
            'pending' => $pending,
            'active' => $active,
            'rejected' => $rejected,
            'suspended' => $suspended,
            'pending_over_48h' => (int) $pendingOver48h,
            'avg_approval_hours' => $avgApprovalHours,
            'avg_rejection_hours' => $avgRejectionHours,
        ];
    }

    protected function calculateReviewHours($createdAt, ?string $decisionAt): ?float
    {
        if (!$createdAt || empty($decisionAt)) {
            return null;
        }

        try {
            $createdDate = Carbon::parse($createdAt);
            $decisionDate = Carbon::parse($decisionAt);
            $hours = $createdDate->diffInSeconds($decisionDate, false) / 3600;
            return $hours >= 0 ? round($hours, 2) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    protected function buildFilteredQuery(string $status, string $type, string $queryText, bool $includePersonal = false): Builder
    {
        $query = Identity::query();

        if (!$includePersonal) {
            $query->whereIn('type', $this->professionalTypes);
        }

        if ($status !== '') {
            $query->where('status', $status);
        }

        if ($type !== '') {
            $query->where('type', $type);
        }

        if ($queryText !== '') {
            $query->where(function ($q) use ($queryText) {
                $q->where('display_name', 'LIKE', '%' . $queryText . '%')
                    ->orWhere('slug', 'LIKE', '%' . $queryText . '%')
                    ->orWhereHas('owner', function ($ownerQuery) use ($queryText) {
                        $ownerQuery->where('email', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('username', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('first_name', 'LIKE', '%' . $queryText . '%')
                            ->orWhere('last_name', 'LIKE', '%' . $queryText . '%');
                    });
            });
        }

        return $query;
    }

    protected function normalizeStatusFilter(string $status): string
    {
        $status = strtolower(trim($status));
        $allowed = ['pending', 'active', 'rejected', 'suspended'];

        return in_array($status, $allowed, true) ? $status : '';
    }

    protected function normalizeTypeFilter(string $type): string
    {
        $type = strtolower(trim($type));
        $allowed = array_merge($this->professionalTypes, ['personal']);

        return in_array($type, $allowed, true) ? $type : '';
    }

    protected function normalizeRequestInfoFields($value): array
    {
        $items = [];

        if (is_array($value)) {
            $items = $value;
        } elseif (is_string($value)) {
            $normalized = str_replace(["\r\n", "\n", ";"], ',', $value);
            $items = explode(',', $normalized);
        } elseif (!is_null($value)) {
            $items = [(string) $value];
        }

        $result = [];
        foreach ($items as $item) {
            $field = trim((string) $item);
            if ($field === '') {
                continue;
            }
            if (strlen($field) > 120) {
                $field = substr($field, 0, 120);
            }
            $result[] = $field;
        }

        return array_values(array_unique($result));
    }

    protected function extractModerationSnapshot(array $meta): array
    {
        $history = $meta['moderation_history'] ?? [];
        if (!is_array($history) || empty($history)) {
            return [
                'action' => '',
                'action_id' => '',
                'at' => '',
                'admin_id' => '',
                'events_count' => 0,
            ];
        }

        $last = end($history);
        if (!is_array($last)) {
            return [
                'action' => '',
                'action_id' => '',
                'at' => '',
                'admin_id' => '',
                'events_count' => count($history),
            ];
        }

        return [
            'action' => (string) ($last['action'] ?? ''),
            'action_id' => (string) ($last['action_id'] ?? ''),
            'at' => (string) ($last['at'] ?? ''),
            'admin_id' => (string) ($last['admin_id'] ?? ''),
            'events_count' => count($history),
        ];
    }
}
