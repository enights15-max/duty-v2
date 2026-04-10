<?php

namespace App\Http\Controllers\BackEnd\Organizer;

use App\Http\Controllers\Controller;
use App\Models\Event\EventContent;
use App\Models\Language;
use App\Models\Reservation\TicketReservation;
use App\Services\AdminReservationManagementService;
use App\Services\AdminReservationRefundService;
use App\Services\ProfessionalCatalogBridgeService;
use App\Services\ReservationAuditService;
use App\Services\ReservationStatusNotificationService;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;

class ReservationController extends Controller
{
    public function __construct(
        private AdminReservationManagementService $managementService,
        private AdminReservationRefundService $refundService,
        private ProfessionalCatalogBridgeService $catalogBridge,
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
        $refundState = $this->normalizeRefundStateFilter((string) $request->query('refund_state', 'all'));
        $dueState = $this->normalizeDueStateFilter((string) $request->query('due_state', 'all'));
        $organizerId = (int) Auth::guard('organizer')->id();
        $eventIds = $this->resolveEventIdsByTitle($eventTitle);

        $reservations = $this->buildScopedQuery($organizerId, $status, $queryText, $eventIds, $refundState, $dueState)
            ->with($this->reservationListRelations())
            ->orderByRaw($this->statusOrderSql())
            ->orderByRaw("CASE WHEN status = 'active' THEN COALESCE(expires_at, final_due_date, created_at) END ASC")
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        $reservations->setCollection($this->decorateReservationCollection($reservations->getCollection()));

        $metrics = $this->buildMetrics($organizerId);

        return view('organizer.event.reservation.index', compact(
            'defaultLang',
            'reservations',
            'status',
            'queryText',
            'eventTitle',
            'refundState',
            'dueState',
            'metrics'
        ));
    }

    public function export(Request $request)
    {
        $status = $this->normalizeStatusFilter((string) $request->query('status', 'active'));
        $queryText = trim((string) $request->query('q', ''));
        $eventTitle = trim((string) $request->query('event_title', ''));
        $refundState = $this->normalizeRefundStateFilter((string) $request->query('refund_state', 'all'));
        $dueState = $this->normalizeDueStateFilter((string) $request->query('due_state', 'all'));
        $organizerId = (int) Auth::guard('organizer')->id();
        $eventIds = $this->resolveEventIdsByTitle($eventTitle);

        $reservations = $this->decorateReservationCollection(
            $this->buildScopedQuery($organizerId, $status, $queryText, $eventIds, $refundState, $dueState)
                ->with($this->reservationListRelations())
                ->orderByRaw($this->statusOrderSql())
                ->orderByRaw("CASE WHEN status = 'active' THEN COALESCE(expires_at, final_due_date, created_at) END ASC")
                ->orderByDesc('id')
                ->get()
        );

        $filename = 'organizer-reservations-' . now()->format('Ymd_His') . '.csv';

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
        $reservation = $this->findScopedReservationOrFail((int) $id);
        $reservation->load([
            'customer',
            'ticket',
            'event',
            'event.information',
            'payments',
            'actionLogs',
            'bookings.paymentAllocations',
            'bookings.organizer',
            'bookings.customerInfo',
        ]);

        $refundState = $this->refundService->summarize($reservation);
        $paymentSummary = $refundState['collection_summary'];
        $refundSummary = $refundState['refund_summary'];
        $financials = $refundState['financials'];
        $refundableSummary = $refundState['refundable_summary'];

        $actions = [
            'can_extend' => $reservation->status === 'active',
            'can_cancel' => !in_array($reservation->status, ['completed', 'cancelled'], true),
            'can_default' => !in_array($reservation->status, ['completed', 'defaulted'], true),
            'can_reactivate' => in_array($reservation->status, ['expired', 'defaulted', 'cancelled'], true)
                && (float) $reservation->remaining_balance > 0,
            'can_convert' => $reservation->status === 'completed'
                && empty($reservation->booking_order_number)
                && $reservation->bookings->isEmpty(),
        ];

        return view('organizer.event.reservation.details', compact(
            'defaultLang',
            'reservation',
            'paymentSummary',
            'refundSummary',
            'financials',
            'actions',
            'refundableSummary'
        ));
    }

    public function extend(Request $request, $id)
    {
        $validated = $request->validate([
            'expires_at' => 'required|date|after:now',
            'final_due_date' => 'nullable|date|after_or_equal:expires_at',
        ]);

        $reservation = $this->findScopedReservationOrFail((int) $id);

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
        return redirect()->route('organizer.event_booking.details', ['id' => $id]);
    }

    public function cancel($id)
    {
        $reservation = $this->findScopedReservationOrFail((int) $id);

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

        Session::flash('success', 'Reservation cancelled. Inventory was released when applicable. Refunds remain admin-managed.');
        return redirect()->route('organizer.event_booking.details', ['id' => $id]);
    }

    public function markDefaulted($id)
    {
        $reservation = $this->findScopedReservationOrFail((int) $id);

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
        return redirect()->route('organizer.event_booking.details', ['id' => $id]);
    }

    public function reactivate(Request $request, $id)
    {
        $validated = $request->validate([
            'expires_at' => 'required|date|after:now',
            'final_due_date' => 'nullable|date|after_or_equal:expires_at',
        ]);

        $reservation = $this->findScopedReservationOrFail((int) $id);

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
        return redirect()->route('organizer.event_booking.details', ['id' => $id]);
    }

    public function convert($id)
    {
        $reservation = $this->findScopedReservationOrFail((int) $id);

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
        return redirect()->route('organizer.event_booking.details', ['id' => $id]);
    }

    private function buildScopedQuery(int $organizerId, string $status, string $queryText, array $eventIds, string $refundState, string $dueState): Builder
    {
        $identityId = $this->resolveOrganizerIdentityId($organizerId);

        $query = TicketReservation::query()
            ->ownedByOrganizerActor($identityId, $organizerId)
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

        return $this->applyDueStateFilter($query, $dueState);
    }

    private function buildMetrics(int $organizerId): array
    {
        $identityId = $this->resolveOrganizerIdentityId($organizerId);

        $query = TicketReservation::query()
            ->ownedByOrganizerActor($identityId, $organizerId);

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

    private function resolveEventIdsByTitle(string $eventTitle): array
    {
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
            'actionLogs:id,reservation_id,actor_type,actor_id,action,created_at',
            'bookings:id,reservation_id,booking_id,order_number,paymentStatus,organizer_id,organizer_identity_id,event_id',
        ];
    }

    private function decorateReservationCollection($reservations)
    {
        return $reservations->map(function (TicketReservation $reservation) {
            $refundState = $this->refundService->summarize($reservation);
            $reservation->setAttribute('refund_financials', $refundState['financials']);
            $reservation->setAttribute('refund_refundable_summary', $refundState['refundable_summary']);
            $reservation->setAttribute('due_at_resolved', $this->resolveDueAt($reservation));
            $reservation->setAttribute('due_state_badge', $this->resolveDueStateBadge($reservation));

            return $reservation;
        });
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

    private function findScopedReservationOrFail(int $id): TicketReservation
    {
        $organizerId = (int) Auth::guard('organizer')->id();
        $identityId = $this->resolveOrganizerIdentityId($organizerId);

        return TicketReservation::query()
            ->with('event')
            ->whereKey($id)
            ->ownedByOrganizerActor($identityId, $organizerId)
            ->firstOrFail();
    }

    private function resolveOrganizerIdentityId(int $legacyOrganizerId): ?int
    {
        if (!Schema::hasTable('identities')) {
            return null;
        }

        return $this->catalogBridge->findIdentityForLegacy('organizer', $legacyOrganizerId)?->id;
    }

    private function audit(string $action, TicketReservation $reservation, array $meta = []): void
    {
        $organizerId = Auth::guard('organizer')->id();

        $this->auditService->log(
            $reservation,
            $action,
            'organizer',
            $organizerId ? (int) $organizerId : null,
            $meta
        );
    }
}
