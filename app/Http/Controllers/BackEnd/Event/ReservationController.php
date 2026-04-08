<?php

namespace App\Http\Controllers\BackEnd\Event;

use App\Http\Controllers\Controller;
use App\Models\Event\EventContent;
use App\Models\Language;
use App\Models\Reservation\TicketReservation;
use App\Services\AdminReservationManagementService;
use App\Services\AdminReservationRefundService;
use App\Services\ReservationAuditService;
use App\Services\ReservationStatusNotificationService;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;
use Illuminate\Validation\Rule;

class ReservationController extends Controller
{
    public function __construct(
        private AdminReservationManagementService $managementService,
        private AdminReservationRefundService $refundService,
        private ReservationAuditService $auditService,
        private ReservationStatusNotificationService $notificationService
    ) {
    }

    public function index(Request $request)
    {
        $defaultLang = Language::where('is_default', 1)->first() ?: Language::first();
        $status = $this->normalizeStatusFilter((string) $request->query('status', 'active'));
        $queryText = trim((string) $request->query('q', ''));
        $eventTitle = trim((string) $request->query('event_title', ''));
        $eventId = $request->filled('event_id') ? max(0, (int) $request->query('event_id')) : null;
        $refundState = $this->normalizeRefundStateFilter((string) $request->query('refund_state', 'all'));
        $dueState = $this->normalizeDueStateFilter((string) $request->query('due_state', 'all'));
        $refundReasonOptions = $this->refundService->refundReasonOptions();
        $refundRiskFlagOptions = $this->refundService->refundRiskFlagOptions();
        $refundReasonCode = $this->normalizeRefundReasonCodeFilter((string) $request->query('refund_reason_code', 'all'), $refundReasonOptions);
        $refundRiskFlag = $this->normalizeRefundRiskFlagFilter((string) $request->query('refund_risk_flag', 'all'), $refundRiskFlagOptions);
        $decisionPeriod = $this->normalizeDecisionPeriodFilter((string) $request->query('decision_period', '30d'));
        $eventIds = $this->resolveEventIdsFromFilter($eventId, $eventTitle);
        $filteredQuery = $this->buildFilteredQuery($status, $queryText, $eventIds, $refundState, $dueState, $refundReasonCode, $refundRiskFlag);

        $reservations = (clone $filteredQuery)
            ->with($this->reservationListRelations())
            ->orderByRaw($this->statusOrderSql())
            ->orderByRaw("CASE WHEN status = 'active' THEN COALESCE(expires_at, final_due_date, created_at) END ASC")
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        $reservations->setCollection($this->decorateReservationCollection($reservations->getCollection()));

        $metrics = $this->buildMetrics();
        $decisionInsights = $this->buildRefundDecisionInsights(clone $filteredQuery, $decisionPeriod);

        return view('backend.event.reservation.index', compact(
            'defaultLang',
            'reservations',
            'status',
            'queryText',
            'eventTitle',
            'eventId',
            'refundState',
            'dueState',
            'metrics',
            'refundReasonOptions',
            'refundRiskFlagOptions',
            'refundReasonCode',
            'refundRiskFlag',
            'decisionInsights',
            'decisionPeriod'
        ));
    }

    public function export(Request $request)
    {
        $status = $this->normalizeStatusFilter((string) $request->query('status', 'active'));
        $queryText = trim((string) $request->query('q', ''));
        $eventTitle = trim((string) $request->query('event_title', ''));
        $eventId = $request->filled('event_id') ? max(0, (int) $request->query('event_id')) : null;
        $refundState = $this->normalizeRefundStateFilter((string) $request->query('refund_state', 'all'));
        $dueState = $this->normalizeDueStateFilter((string) $request->query('due_state', 'all'));
        $refundReasonCode = $this->normalizeRefundReasonCodeFilter(
            (string) $request->query('refund_reason_code', 'all'),
            $this->refundService->refundReasonOptions()
        );
        $refundRiskFlag = $this->normalizeRefundRiskFlagFilter(
            (string) $request->query('refund_risk_flag', 'all'),
            $this->refundService->refundRiskFlagOptions()
        );
        $eventIds = $this->resolveEventIdsFromFilter($eventId, $eventTitle);

        $reservations = $this->decorateReservationCollection(
            $this->buildFilteredQuery($status, $queryText, $eventIds, $refundState, $dueState, $refundReasonCode, $refundRiskFlag)
                ->with($this->reservationListRelations())
                ->orderByRaw($this->statusOrderSql())
                ->orderByRaw("CASE WHEN status = 'active' THEN COALESCE(expires_at, final_due_date, created_at) END ASC")
                ->orderByDesc('id')
                ->get()
        );

        $filename = 'admin-reservations-' . now()->format('Ymd_His') . '.csv';

        return response()->streamDownload(function () use ($reservations) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, [
                'Reservation Code',
                'Status',
                'Event',
                'Customer',
                'Quantity',
                'Total',
                'Paid',
                'Gross Paid',
                'Refunded',
                'Refundable',
                'Latest Refund Reason',
                'Latest Refund Risk Flags',
                'Latest Refund Admin',
                'Latest Refund Note',
                'Latest Refund At',
                'Remaining',
                'Last Action',
                'Last Action At',
                'Bookings',
                'Final Due Date',
                'Expires At',
                'Created At',
            ]);

            foreach ($reservations as $reservation) {
                $eventTitle = optional($reservation->event?->information)->title ?: ('Event #' . $reservation->event_id);
                $customerLabel = trim((string) ($reservation->customer?->fname . ' ' . $reservation->customer?->lname));
                if ($customerLabel === '') {
                    $customerLabel = trim((string) ($reservation->fname . ' ' . $reservation->lname));
                }
                if ($customerLabel === '') {
                    $customerLabel = $reservation->email ?: '-';
                }

                $lastAction = $reservation->actionLogs->first();
                $refundFinancials = $reservation->refund_financials ?? [];
                $refundRefundable = $reservation->refund_refundable_summary ?? [];
                $latestRefundDecision = $reservation->latest_refund_decision ?? [];
                $grossPaid = round((float) $reservation->payments->sum('total_amount'), 2);

                fputcsv($handle, [
                    $reservation->reservation_code,
                    $reservation->status,
                    $eventTitle,
                    $customerLabel,
                    $reservation->quantity,
                    number_format((float) $reservation->total_amount, 2, '.', ''),
                    number_format((float) $reservation->amount_paid, 2, '.', ''),
                    number_format($grossPaid, 2, '.', ''),
                    number_format((float) ($refundFinancials['refunded_gross'] ?? 0), 2, '.', ''),
                    number_format((float) ($refundRefundable['gross_amount'] ?? 0), 2, '.', ''),
                    data_get($latestRefundDecision, 'reason_label'),
                    collect((array) data_get($latestRefundDecision, 'risk_flag_labels', []))->implode('; '),
                    data_get($latestRefundDecision, 'admin_label'),
                    data_get($latestRefundDecision, 'admin_note'),
                    data_get($latestRefundDecision, 'occurred_at'),
                    number_format((float) $reservation->remaining_balance, 2, '.', ''),
                    $lastAction ? str_replace('_', ' ', (string) $lastAction->action) : '',
                    $lastAction?->created_at?->toDateTimeString() ?: '',
                    $reservation->bookings->count(),
                    optional($reservation->final_due_date)->toDateTimeString() ?: '',
                    optional($reservation->expires_at)->toDateTimeString() ?: '',
                    optional($reservation->created_at)->toDateTimeString() ?: '',
                ]);
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }

    public function show($id)
    {
        $defaultLang = Language::where('is_default', 1)->first() ?: Language::first();
        $reservation = TicketReservation::with([
            'customer',
            'ticket',
            'event',
            'event.information',
            'payments',
            'actionLogs',
            'bookings.paymentAllocations',
            'bookings.organizer',
            'bookings.customerInfo',
        ])->findOrFail($id);

        $refundState = $this->refundService->summarize($reservation);
        $paymentSummary = $refundState['collection_summary'];
        $refundSummary = $refundState['refund_summary'];
        $financials = $refundState['financials'];
        $refundableSummary = $refundState['refundable_summary'];
        $refundReasonOptions = $this->refundService->refundReasonOptions();
        $refundRiskFlagOptions = $this->refundService->refundRiskFlagOptions();
        $refundGovernanceRules = $this->refundService->refundGovernanceRules();

        $actions = [
            'can_extend' => $reservation->status === 'active',
            'can_cancel' => !in_array($reservation->status, ['completed', 'cancelled'], true),
            'can_default' => !in_array($reservation->status, ['completed', 'defaulted'], true),
            'can_reactivate' => in_array($reservation->status, ['expired', 'defaulted', 'cancelled'], true)
                && (float) $reservation->remaining_balance > 0,
            'can_convert' => $reservation->status === 'completed'
                && empty($reservation->booking_order_number)
                && $reservation->bookings->isEmpty(),
            'can_refund' => in_array($reservation->status, ['cancelled', 'defaulted'], true)
                && (float) ($refundableSummary['gross_amount'] ?? 0) > 0,
        ];

        return view('backend.event.reservation.details', compact(
            'defaultLang',
            'reservation',
            'paymentSummary',
            'refundSummary',
            'financials',
            'actions',
            'refundableSummary',
            'refundReasonOptions',
            'refundRiskFlagOptions',
            'refundGovernanceRules'
        ));
    }

    public function extend(Request $request, $id)
    {
        $validated = $request->validate([
            'expires_at' => 'required|date|after:now',
            'final_due_date' => 'nullable|date|after_or_equal:expires_at',
        ]);

        $reservation = TicketReservation::findOrFail($id);

        try {
            $updatedReservation = $this->managementService->extend(
                $reservation,
                Carbon::parse($validated['expires_at']),
                !empty($validated['final_due_date']) ? Carbon::parse($validated['final_due_date']) : null
            );
            $this->audit('extended', $updatedReservation, [
                'expires_at' => optional($updatedReservation->expires_at)->toDateTimeString(),
                'final_due_date' => optional($updatedReservation->final_due_date)->toDateTimeString(),
            ]);
            $this->notificationService->notifyCustomer($updatedReservation, 'extended', [
                'expires_at' => optional($updatedReservation->expires_at)->toDateTimeString(),
                'final_due_date' => optional($updatedReservation->final_due_date)->toDateTimeString(),
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Reservation timeline updated.');
        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    public function cancel($id)
    {
        $reservation = TicketReservation::findOrFail($id);

        try {
            $updatedReservation = $this->managementService->cancel($reservation);
            $this->audit('cancelled', $updatedReservation, [
                'status' => $updatedReservation->status,
            ]);
            $this->notificationService->notifyCustomer($updatedReservation, 'cancelled', [
                'status' => $updatedReservation->status,
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Reservation cancelled. Inventory was released when applicable. No automatic refund was created.');
        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    public function markDefaulted($id)
    {
        $reservation = TicketReservation::findOrFail($id);

        try {
            $updatedReservation = $this->managementService->markDefaulted($reservation);
            $this->audit('marked_defaulted', $updatedReservation, [
                'status' => $updatedReservation->status,
            ]);
            $this->notificationService->notifyCustomer($updatedReservation, 'marked_defaulted', [
                'status' => $updatedReservation->status,
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Reservation marked as defaulted. Inventory was released when applicable.');
        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    public function reactivate(Request $request, $id)
    {
        $validated = $request->validate([
            'expires_at' => 'required|date|after:now',
            'final_due_date' => 'nullable|date|after_or_equal:expires_at',
        ]);

        $reservation = TicketReservation::findOrFail($id);

        try {
            $updatedReservation = $this->managementService->reactivate(
                $reservation,
                Carbon::parse($validated['expires_at']),
                !empty($validated['final_due_date']) ? Carbon::parse($validated['final_due_date']) : null
            );
            $this->audit('reactivated', $updatedReservation, [
                'expires_at' => optional($updatedReservation->expires_at)->toDateTimeString(),
                'final_due_date' => optional($updatedReservation->final_due_date)->toDateTimeString(),
            ]);
            $this->notificationService->notifyCustomer($updatedReservation, 'reactivated', [
                'expires_at' => optional($updatedReservation->expires_at)->toDateTimeString(),
                'final_due_date' => optional($updatedReservation->final_due_date)->toDateTimeString(),
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        Session::flash('success', 'Reservation reactivated and inventory was re-allocated.');
        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    public function convert($id)
    {
        $reservation = TicketReservation::findOrFail($id);

        try {
            $bookings = $this->managementService->convert($reservation);
            $updatedReservation = $reservation->fresh();
            $this->audit('converted_to_bookings', $updatedReservation, [
                'booking_count' => $bookings->count(),
            ]);
            $this->notificationService->notifyCustomer($updatedReservation, 'converted_to_bookings', [
                'booking_count' => $bookings->count(),
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        $count = $bookings->count();
        Session::flash('success', "Reservation converted into {$count} booking(s).");
        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    public function refund(Request $request, $id)
    {
        $validated = $request->validate([
            'refund_bonus_wallet' => 'nullable|numeric|min:0',
            'refund_wallet' => 'nullable|numeric|min:0',
            'refund_card' => 'nullable|numeric|min:0',
            'refund_reason_code' => ['required', 'string', Rule::in(array_keys($this->refundService->refundReasonOptions()))],
            'refund_admin_note' => ['required', 'string', 'max:1000'],
            'refund_risk_flags' => ['nullable', 'array'],
            'refund_risk_flags.*' => ['string', Rule::in(array_keys($this->refundService->refundRiskFlagOptions()))],
        ]);

        $reservation = TicketReservation::findOrFail($id);
        $adminId = Auth::guard('admin')->id();

        try {
            $result = $this->refundService->refund($reservation, [
                'bonus_wallet' => $validated['refund_bonus_wallet'] ?? null,
                'wallet' => $validated['refund_wallet'] ?? null,
                'card' => $validated['refund_card'] ?? null,
            ], [
                'reason_code' => $validated['refund_reason_code'],
                'admin_note' => $validated['refund_admin_note'],
                'risk_flags' => $validated['refund_risk_flags'] ?? [],
                'processed_by_admin_id' => $adminId ? (int) $adminId : null,
            ]);
            $this->audit('refund_processed', $reservation->fresh(), [
                'gross_amount' => (float) ($result['gross_amount'] ?? 0),
                'base_amount' => (float) ($result['base_amount'] ?? 0),
                'fee_amount' => (float) ($result['fee_amount'] ?? 0),
                'sources' => $result['sources'] ?? [],
                'refund_reason_code' => data_get($result, 'decision.reason_code'),
                'refund_reason_label' => data_get($result, 'decision.reason_label'),
                'refund_admin_note' => data_get($result, 'decision.admin_note'),
                'refund_risk_flags' => data_get($result, 'decision.risk_flags', []),
                'refund_risk_flag_labels' => data_get($result, 'decision.risk_flag_labels', []),
            ]);
            $this->notificationService->notifyCustomer($reservation->fresh(), 'refund_processed', [
                'gross_amount' => (float) ($result['gross_amount'] ?? 0),
                'base_amount' => (float) ($result['base_amount'] ?? 0),
                'fee_amount' => (float) ($result['fee_amount'] ?? 0),
                'sources' => $result['sources'] ?? [],
            ]);
        } catch (\Throwable $exception) {
            Session::flash('warning', $exception->getMessage());
            return redirect()->back();
        }

        $formattedTotal = number_format((float) ($result['gross_amount'] ?? 0), 2);
        Session::flash('success', "Refund processed successfully. Total returned: \${$formattedTotal}.");

        return redirect()->route('admin.event_reservation.details', ['id' => $id]);
    }

    private function buildFilteredQuery(
        string $status,
        string $queryText,
        array $eventIds,
        string $refundState,
        string $dueState,
        string $refundReasonCode = 'all',
        string $refundRiskFlag = 'all'
    ): Builder
    {
        $query = TicketReservation::query()
            ->when($status !== 'all', function (Builder $query) use ($status) {
                $query->where('status', $status);
            })
            ->when($queryText !== '', function (Builder $query) use ($queryText) {
                $query->where(function (Builder $builder) use ($queryText) {
                    $builder->where('reservation_code', 'LIKE', '%' . $queryText . '%')
                        ->orWhere('booking_order_number', 'LIKE', '%' . $queryText . '%')
                        ->orWhere('fname', 'LIKE', '%' . $queryText . '%')
                        ->orWhere('lname', 'LIKE', '%' . $queryText . '%')
                        ->orWhere('email', 'LIKE', '%' . $queryText . '%')
                        ->orWhereHas('customer', function (Builder $customerQuery) use ($queryText) {
                            $customerQuery->where('fname', 'LIKE', '%' . $queryText . '%')
                                ->orWhere('lname', 'LIKE', '%' . $queryText . '%')
                                ->orWhere('username', 'LIKE', '%' . $queryText . '%')
                                ->orWhere('email', 'LIKE', '%' . $queryText . '%');
                        });
                });
            })
            ->when($eventIds !== [], function (Builder $query) use ($eventIds) {
                $query->whereIn('event_id', $eventIds);
            });

        $query = $this->applyRefundStateFilter($query, $refundState);
        $query = $this->applyRefundDecisionFilters($query, $refundReasonCode, $refundRiskFlag);

        return $this->applyDueStateFilter($query, $dueState);
    }

    private function buildMetrics(): array
    {
        $query = TicketReservation::query();

        return [
            'total' => (clone $query)->count(),
            'active' => (clone $query)->where('status', 'active')->count(),
            'completed' => (clone $query)->where('status', 'completed')->count(),
            'expired' => (clone $query)->where('status', 'expired')->count(),
            'defaulted' => (clone $query)->where('status', 'defaulted')->count(),
            'cancelled' => (clone $query)->where('status', 'cancelled')->count(),
            'active_remaining_total' => round((float) (clone $query)->where('status', 'active')->sum('remaining_balance'), 2),
            'due_24h' => $this->applyDueStateFilter((clone $query), 'due_24h')->count(),
            'due_2h' => $this->applyDueStateFilter((clone $query), 'due_2h')->count(),
        ];
    }

    private function normalizeStatusFilter(string $status): string
    {
        $allowed = ['all', 'active', 'completed', 'expired', 'defaulted', 'cancelled'];

        return in_array($status, $allowed, true) ? $status : 'active';
    }

    private function normalizeRefundStateFilter(string $refundState): string
    {
        $allowed = ['all', 'refundable', 'refunded'];

        return in_array($refundState, $allowed, true) ? $refundState : 'all';
    }

    private function normalizeDueStateFilter(string $dueState): string
    {
        $allowed = ['all', 'due_24h', 'due_2h'];

        return in_array($dueState, $allowed, true) ? $dueState : 'all';
    }

    private function normalizeRefundReasonCodeFilter(string $refundReasonCode, array $options): string
    {
        return $refundReasonCode === 'all' || array_key_exists($refundReasonCode, $options)
            ? $refundReasonCode
            : 'all';
    }

    private function normalizeRefundRiskFlagFilter(string $refundRiskFlag, array $options): string
    {
        return $refundRiskFlag === 'all' || array_key_exists($refundRiskFlag, $options)
            ? $refundRiskFlag
            : 'all';
    }

    private function normalizeDecisionPeriodFilter(string $decisionPeriod): string
    {
        $allowed = ['7d', '30d', '90d', 'all'];

        return in_array($decisionPeriod, $allowed, true) ? $decisionPeriod : '30d';
    }

    private function resolveEventIdsFromFilter(?int $eventId, string $eventTitle): array
    {
        if ($eventId && $eventId > 0) {
            return [$eventId];
        }

        if ($eventTitle === '') {
            return [];
        }

        $eventIds = EventContent::query()
            ->where('title', 'LIKE', '%' . $eventTitle . '%')
            ->pluck('event_id')
            ->unique()
            ->values()
            ->all();

        return $eventIds === [] ? [-1] : $eventIds;
    }

    private function reservationListRelations(): array
    {
        return [
            'customer:id,fname,lname,username,email',
            'ticket:id,title,event_id',
            'event:id,organizer_id,owner_identity_id,thumbnail,end_date_time',
            'event.information:id,event_id,title,slug',
            'payments:id,reservation_id,source_type,amount,fee_amount,total_amount,status,paid_at,payment_group,reference_type,reference_id',
            'actionLogs:id,reservation_id,actor_type,actor_id,action,meta,created_at',
            'bookings:id,reservation_id,booking_id,order_number,paymentStatus,organizer_id,organizer_identity_id,event_id',
        ];
    }

    private function decorateReservationCollection($reservations)
    {
        $latestRefundLogs = $reservations
            ->map(fn (TicketReservation $reservation) => $reservation->actionLogs
                ->where('action', 'refund_processed')
                ->sortByDesc('created_at')
                ->first())
            ->filter();

        $adminLabels = $this->resolveAdminLabels(
            $latestRefundLogs
                ->filter(fn ($log) => (string) $log->actor_type === 'admin' && (int) $log->actor_id > 0)
                ->pluck('actor_id')
                ->map(fn ($id) => (int) $id)
                ->unique()
                ->values()
                ->all()
        );

        return $reservations->map(function (TicketReservation $reservation) use ($adminLabels) {
            $refundState = $this->refundService->summarize($reservation);
            $reservation->setAttribute('refund_financials', $refundState['financials']);
            $reservation->setAttribute('refund_collection_summary', $refundState['collection_summary']);
            $reservation->setAttribute('refund_refundable_summary', $refundState['refundable_summary']);
            $reservation->setAttribute('due_at_resolved', $this->resolveDueAt($reservation));
            $reservation->setAttribute('due_state_badge', $this->resolveDueStateBadge($reservation));
            $reservation->setAttribute('latest_refund_decision', $this->resolveLatestRefundDecision(
                $reservation,
                $adminLabels
            ));

            return $reservation;
        });
    }

    private function resolveLatestRefundDecision(TicketReservation $reservation, array $adminLabels = []): ?array
    {
        $latestRefundLog = $reservation->actionLogs
            ->where('action', 'refund_processed')
            ->sortByDesc('created_at')
            ->first();

        if (!$latestRefundLog || empty($latestRefundLog->meta)) {
            return null;
        }

        $adminId = (string) $latestRefundLog->actor_type === 'admin' ? (int) $latestRefundLog->actor_id : 0;
        $reasonCode = (string) data_get($latestRefundLog->meta, 'refund_reason_code', '');
        $reasonOptions = $this->refundService->refundReasonOptions();
        $riskFlags = array_values(array_filter((array) data_get($latestRefundLog->meta, 'refund_risk_flags', [])));
        $riskFlagOptions = $this->refundService->refundRiskFlagOptions();
        $riskFlagLabels = (array) data_get($latestRefundLog->meta, 'refund_risk_flag_labels', []);

        if ($riskFlagLabels === [] && $riskFlags !== []) {
            $riskFlagLabels = collect($riskFlags)
                ->map(fn (string $flag) => $riskFlagOptions[$flag] ?? str($flag)->replace('_', ' ')->title()->toString())
                ->values()
                ->all();
        }

        return [
            'reason_code' => $reasonCode !== '' ? $reasonCode : null,
            'reason_label' => data_get($latestRefundLog->meta, 'refund_reason_label')
                ?: ($reasonCode !== '' ? ($reasonOptions[$reasonCode] ?? str($reasonCode)->replace('_', ' ')->title()->toString()) : null),
            'admin_note' => data_get($latestRefundLog->meta, 'refund_admin_note'),
            'risk_flags' => $riskFlags,
            'risk_flag_labels' => $riskFlagLabels,
            'admin_label' => $adminId > 0
                ? ($adminLabels[$adminId] ?? ('Admin #' . $adminId))
                : null,
            'occurred_at' => optional($latestRefundLog->created_at)->toDateTimeString(),
        ];
    }

    private function resolveAdminLabels(array $adminIds): array
    {
        if ($adminIds === [] || !Schema::hasTable('admins')) {
            return [];
        }

        return DB::table('admins')
            ->whereIn('id', $adminIds)
            ->get(['id', 'first_name', 'last_name', 'username', 'email'])
            ->mapWithKeys(function ($admin) {
                $name = trim((string) (($admin->first_name ?? '') . ' ' . ($admin->last_name ?? '')));

                if ($name === '') {
                    $name = (string) ($admin->username ?: $admin->email ?: ('Admin #' . $admin->id));
                }

                return [(int) $admin->id => $name];
            })
            ->all();
    }

    private function applyRefundStateFilter(Builder $query, string $refundState): Builder
    {
        return match ($refundState) {
            'refunded' => $query->whereHas('payments', function (Builder $paymentQuery) {
                $paymentQuery->where('status', 'reversed')
                    ->where('source_type', 'LIKE', '%_refund');
            }),
            'refundable' => $query
                ->whereIn('status', ['cancelled', 'defaulted'])
                ->whereRaw("(
                    COALESCE((
                        SELECT SUM(rp.total_amount)
                        FROM reservation_payments rp
                        WHERE rp.reservation_id = ticket_reservations.id
                          AND rp.status = 'completed'
                          AND rp.source_type IN ('bonus_wallet', 'wallet', 'card')
                    ), 0)
                    +
                    COALESCE((
                        SELECT SUM(rp.total_amount)
                        FROM reservation_payments rp
                        WHERE rp.reservation_id = ticket_reservations.id
                          AND rp.status = 'reversed'
                          AND rp.source_type LIKE '%_refund'
                    ), 0)
                ) > 0"),
            default => $query,
        };
    }

    private function applyRefundDecisionFilters(Builder $query, string $refundReasonCode, string $refundRiskFlag): Builder
    {
        return $query
            ->when($refundReasonCode !== 'all', function (Builder $reservationQuery) use ($refundReasonCode) {
                $reservationQuery->whereHas('actionLogs', function (Builder $actionLogQuery) use ($refundReasonCode) {
                    $actionLogQuery->where('action', 'refund_processed');
                    $this->applyActionLogJsonScalarFilter($actionLogQuery, 'refund_reason_code', $refundReasonCode);
                });
            })
            ->when($refundRiskFlag !== 'all', function (Builder $reservationQuery) use ($refundRiskFlag) {
                $reservationQuery->whereHas('actionLogs', function (Builder $actionLogQuery) use ($refundRiskFlag) {
                    $actionLogQuery->where('action', 'refund_processed');
                    $this->applyActionLogJsonArrayFilter($actionLogQuery, 'refund_risk_flags', $refundRiskFlag);
                });
            });
    }

    private function applyActionLogJsonScalarFilter(Builder $query, string $key, string $expectedValue): void
    {
        $driver = $query->getConnection()->getDriverName();

        if ($driver === 'sqlite') {
            $query->whereRaw("json_extract(meta, '$.\"{$key}\"') = ?", [$expectedValue]);
            return;
        }

        $query->whereRaw("JSON_UNQUOTE(JSON_EXTRACT(meta, '$.\"{$key}\"')) = ?", [$expectedValue]);
    }

    private function applyActionLogJsonArrayFilter(Builder $query, string $key, string $expectedValue): void
    {
        $driver = $query->getConnection()->getDriverName();

        if ($driver === 'sqlite') {
            $query->whereRaw("json_extract(meta, '$.\"{$key}\"') LIKE ?", ['%"' . $expectedValue . '"%']);
            return;
        }

        $query->whereRaw("JSON_SEARCH(JSON_EXTRACT(meta, '$.\"{$key}\"'), 'one', ?) IS NOT NULL", [$expectedValue]);
    }

    private function buildRefundDecisionInsights(Builder $reservationQuery, string $decisionPeriod = '30d'): array
    {
        if (!Schema::hasTable('ticket_reservation_action_logs')) {
            return $this->emptyRefundDecisionInsights();
        }

        $reservationIds = (clone $reservationQuery)
            ->select('ticket_reservations.id')
            ->pluck('ticket_reservations.id')
            ->map(fn ($id) => (int) $id)
            ->filter(fn (int $id) => $id > 0)
            ->values()
            ->all();

        if ($reservationIds === []) {
            return $this->emptyRefundDecisionInsights();
        }

        $logsQuery = DB::table('ticket_reservation_action_logs')
            ->where('action', 'refund_processed')
            ->whereIn('reservation_id', $reservationIds)
            ->orderByDesc('created_at');

        if ($decisionPeriod !== 'all') {
            $cutoff = match ($decisionPeriod) {
                '7d' => now()->subDays(7),
                '90d' => now()->subDays(90),
                default => now()->subDays(30),
            };

            $logsQuery->where('created_at', '>=', $cutoff);
        }

        $logs = $logsQuery->get(['reservation_id', 'actor_type', 'actor_id', 'meta', 'created_at'])
            ->map(function ($log) {
                $meta = is_array($log->meta) ? $log->meta : json_decode((string) $log->meta, true);

                return [
                    'reservation_id' => (int) $log->reservation_id,
                    'actor_type' => (string) ($log->actor_type ?? ''),
                    'actor_id' => (int) ($log->actor_id ?? 0),
                    'meta' => is_array($meta) ? $meta : [],
                    'gross_amount' => round((float) data_get(is_array($meta) ? $meta : [], 'gross_amount', 0), 2),
                    'created_at' => $log->created_at ? Carbon::parse($log->created_at) : null,
                ];
            })
            ->values();

        if ($logs->isEmpty()) {
            return $this->emptyRefundDecisionInsights();
        }

        $reasonOptions = $this->refundService->refundReasonOptions();
        $riskFlagOptions = $this->refundService->refundRiskFlagOptions();
        $adminLabels = $this->resolveAdminLabels(
            $logs
                ->filter(fn (array $log) => $log['actor_type'] === 'admin' && $log['actor_id'] > 0)
                ->pluck('actor_id')
                ->unique()
                ->values()
                ->all()
        );

        $reasonCounts = [];
        $riskCounts = [];
        $adminCounts = [];
        $decisionsWithRiskFlags = 0;
        $treasuryImpactCount = 0;
        $gatewayRefundCount = 0;
        $totalRefundedGross = 0.0;
        $treasuryImpactGross = 0.0;

        foreach ($logs as $log) {
            $meta = $log['meta'];
            $reasonCode = (string) ($meta['refund_reason_code'] ?? '');
            $riskFlags = array_values(array_filter((array) ($meta['refund_risk_flags'] ?? [])));
            $grossAmount = round((float) ($log['gross_amount'] ?? 0), 2);

            $totalRefundedGross += $grossAmount;

            if ($reasonCode !== '') {
                $reasonCounts[$reasonCode] = ($reasonCounts[$reasonCode] ?? 0) + 1;
            }

            if ($riskFlags !== []) {
                $decisionsWithRiskFlags++;
            }

            foreach ($riskFlags as $flag) {
                $riskCounts[$flag] = ($riskCounts[$flag] ?? 0) + 1;
            }

            if (in_array(AdminReservationRefundService::RISK_TREASURY_IMPACT, $riskFlags, true)) {
                $treasuryImpactCount++;
                $treasuryImpactGross += $grossAmount;
            }

            if (in_array(AdminReservationRefundService::RISK_GATEWAY_REFUND, $riskFlags, true)) {
                $gatewayRefundCount++;
            }

            if ($log['actor_type'] === 'admin' && $log['actor_id'] > 0) {
                $adminCounts[$log['actor_id']] = ($adminCounts[$log['actor_id']] ?? 0) + 1;
            }
        }

        arsort($reasonCounts);
        arsort($riskCounts);
        arsort($adminCounts);

        return [
            'supported' => true,
            'selected_period' => $decisionPeriod,
            'selected_period_label' => $this->decisionPeriodLabel($decisionPeriod),
            'total_refund_decisions' => $logs->count(),
            'total_refunded_gross' => round($totalRefundedGross, 2),
            'unique_admins_count' => count($adminCounts),
            'decisions_with_risk_flags_count' => $decisionsWithRiskFlags,
            'treasury_impact_count' => $treasuryImpactCount,
            'treasury_impact_gross' => round($treasuryImpactGross, 2),
            'gateway_refund_count' => $gatewayRefundCount,
            'latest_decision_at' => optional($logs->first()['created_at'] ?? null)?->format('Y-m-d H:i'),
            'top_reasons' => collect($reasonCounts)->map(function (int $count, string $code) use ($reasonOptions) {
                return [
                    'code' => $code,
                    'label' => $reasonOptions[$code] ?? str($code)->replace('_', ' ')->title()->toString(),
                    'count' => $count,
                ];
            })->values()->take(5)->all(),
            'top_risk_flags' => collect($riskCounts)->map(function (int $count, string $code) use ($riskFlagOptions) {
                return [
                    'code' => $code,
                    'label' => $riskFlagOptions[$code] ?? str($code)->replace('_', ' ')->title()->toString(),
                    'count' => $count,
                ];
            })->values()->take(5)->all(),
            'top_admins' => collect($adminCounts)->map(function (int $count, int $adminId) use ($adminLabels) {
                return [
                    'admin_id' => $adminId,
                    'label' => $adminLabels[$adminId] ?? ('Admin #' . $adminId),
                    'count' => $count,
                ];
            })->values()->take(5)->all(),
        ];
    }

    private function emptyRefundDecisionInsights(): array
    {
        return [
            'supported' => false,
            'selected_period' => '30d',
            'selected_period_label' => 'Last 30 days',
            'total_refund_decisions' => 0,
            'total_refunded_gross' => 0.0,
            'unique_admins_count' => 0,
            'decisions_with_risk_flags_count' => 0,
            'treasury_impact_count' => 0,
            'treasury_impact_gross' => 0.0,
            'gateway_refund_count' => 0,
            'latest_decision_at' => null,
            'top_reasons' => [],
            'top_risk_flags' => [],
            'top_admins' => [],
        ];
    }

    private function decisionPeriodLabel(string $decisionPeriod): string
    {
        return match ($decisionPeriod) {
            '7d' => 'Last 7 days',
            '90d' => 'Last 90 days',
            'all' => 'All time',
            default => 'Last 30 days',
        };
    }

    private function applyDueStateFilter(Builder $query, string $dueState): Builder
    {
        if ($dueState === 'all') {
            return $query;
        }

        $now = now();
        $cutoff = $dueState === 'due_2h' ? now()->addHours(2) : now()->addHours(24);

        return $query
            ->where('status', 'active')
            ->where('remaining_balance', '>', 0)
            ->where(function (Builder $dateQuery) use ($now, $cutoff) {
                $dateQuery->whereBetween('expires_at', [$now, $cutoff])
                    ->orWhereBetween('final_due_date', [$now, $cutoff]);
            });
    }

    private function resolveDueAt(TicketReservation $reservation): ?Carbon
    {
        $dates = collect([$reservation->expires_at, $reservation->final_due_date])
            ->filter()
            ->map(fn ($value) => $value instanceof Carbon ? $value->copy() : Carbon::parse($value))
            ->sort();

        return $dates->first();
    }

    private function resolveDueStateBadge(TicketReservation $reservation): ?array
    {
        if ($reservation->status !== 'active' || (float) $reservation->remaining_balance <= 0) {
            return null;
        }

        $dueAt = $this->resolveDueAt($reservation);
        if (!$dueAt) {
            return null;
        }

        if ($dueAt->lte(now()->addHours(2))) {
            return [
                'tone' => 'danger',
                'label' => __('Due <2h'),
                'meta' => $dueAt->diffForHumans(),
            ];
        }

        if ($dueAt->lte(now()->addHours(24))) {
            return [
                'tone' => 'warning',
                'label' => __('Due <24h'),
                'meta' => $dueAt->diffForHumans(),
            ];
        }

        return null;
    }

    private function statusOrderSql(): string
    {
        return "CASE status
            WHEN 'active' THEN 0
            WHEN 'completed' THEN 1
            WHEN 'expired' THEN 2
            WHEN 'defaulted' THEN 3
            WHEN 'cancelled' THEN 4
            ELSE 5
        END";
    }

    private function audit(string $action, TicketReservation $reservation, array $meta = []): void
    {
        $adminId = Auth::guard('admin')->id();

        $this->auditService->log(
            $reservation,
            $action,
            'admin',
            $adminId ? (int) $adminId : null,
            $meta
        );
    }
}
