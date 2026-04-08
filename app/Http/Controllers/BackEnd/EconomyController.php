<?php

namespace App\Http\Controllers\BackEnd;

use App\Exports\EconomyRevenueExport;
use App\Http\Controllers\Controller;
use App\Models\BasicSettings\Basic;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\EventFinancialEntry;
use App\Models\EventTreasury;
use App\Models\FeePolicy;
use App\Models\FeePolicyAuditLog;
use App\Models\Language;
use App\Models\PlatformRevenueEvent;
use App\Models\Reservation\TicketReservation;
use App\Services\EventCollaboratorSplitService;
use App\Services\EventTreasuryService;
use App\Services\FeeEngine;
use App\Services\FeePolicyAuditService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Maatwebsite\Excel\Facades\Excel;

class EconomyController extends Controller
{
    public function __construct(
        private FeeEngine $feeEngine,
        private FeePolicyAuditService $feePolicyAuditService,
        private EventTreasuryService $eventTreasuryService,
        private EventCollaboratorSplitService $eventCollaboratorSplitService
    ) {
    }

    public function feePolicies(Request $request)
    {
        $policies = FeePolicy::query()
            ->orderBy('operation_key')
            ->get();

        $auditQuery = FeePolicyAuditLog::query()
            ->with(['policy:id,label,operation_key', 'admin:id,first_name,last_name,username'])
            ->latest()
            ->limit(30);

        if ($request->filled('audit_policy_id')) {
            $auditQuery->where('fee_policy_id', (int) $request->query('audit_policy_id'));
        }

        $auditLogs = $auditQuery->get();

        return view('backend.economy.fee-policies', [
            'policies' => $policies,
            'auditLogs' => $auditLogs,
            'selectedAuditPolicyId' => $request->query('audit_policy_id'),
            'feeTypes' => [
                FeePolicy::TYPE_PERCENTAGE => 'Percentage',
                FeePolicy::TYPE_FIXED => 'Fixed',
                FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED => 'Percentage + Fixed',
            ],
            'chargedToOptions' => [
                FeePolicy::CHARGED_TO_BUYER => 'Buyer',
                FeePolicy::CHARGED_TO_SELLER => 'Seller',
                FeePolicy::CHARGED_TO_SPLIT => 'Split',
                FeePolicy::CHARGED_TO_PLATFORM => 'Platform Absorbed',
            ],
        ]);
    }

    public function updateFeePolicies(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'policies' => ['required', 'array'],
            'policies.*.fee_type' => ['required', Rule::in([
                FeePolicy::TYPE_PERCENTAGE,
                FeePolicy::TYPE_FIXED,
                FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
            ])],
            'policies.*.percentage_value' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'policies.*.fixed_value' => ['nullable', 'numeric', 'min:0'],
            'policies.*.minimum_fee' => ['nullable', 'numeric', 'min:0'],
            'policies.*.maximum_fee' => ['nullable', 'numeric', 'min:0'],
            'policies.*.charged_to' => ['required', Rule::in([
                FeePolicy::CHARGED_TO_BUYER,
                FeePolicy::CHARGED_TO_SELLER,
                FeePolicy::CHARGED_TO_SPLIT,
                FeePolicy::CHARGED_TO_PLATFORM,
            ])],
            'policies.*.currency' => ['nullable', 'string', 'max:8'],
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $adminId = Auth::guard('admin')->id();

        DB::transaction(function () use ($request, $adminId): void {
            foreach ((array) $request->input('policies', []) as $policyId => $payload) {
                $policy = FeePolicy::query()->find($policyId);
                if (!$policy) {
                    continue;
                }

                $before = Arr::only($policy->toArray(), [
                    'fee_type',
                    'percentage_value',
                    'fixed_value',
                    'minimum_fee',
                    'maximum_fee',
                    'charged_to',
                    'currency',
                    'is_active',
                ]);

                $newState = [
                    'fee_type' => $payload['fee_type'],
                    'percentage_value' => $payload['percentage_value'] !== '' ? $payload['percentage_value'] : null,
                    'fixed_value' => $payload['fixed_value'] !== '' ? $payload['fixed_value'] : null,
                    'minimum_fee' => $payload['minimum_fee'] !== '' ? $payload['minimum_fee'] : null,
                    'maximum_fee' => $payload['maximum_fee'] !== '' ? $payload['maximum_fee'] : null,
                    'charged_to' => $payload['charged_to'],
                    'currency' => $payload['currency'] ?: 'DOP',
                    'is_active' => isset($payload['is_active']) && (string) $payload['is_active'] === '1',
                ];

                $policy->update($newState);

                $after = Arr::only($policy->fresh()->toArray(), array_keys($before));
                $changedFields = collect($after)
                    ->filter(fn ($value, $key) => Arr::get($before, $key) != $value)
                    ->keys()
                    ->values()
                    ->all();

                if (!empty($changedFields)) {
                    $this->feePolicyAuditService->log(
                        $policy->fresh(),
                        'updated',
                        $adminId,
                        $before,
                        $after,
                        [
                            'changed_fields' => $changedFields,
                            'ip' => $request->ip(),
                            'user_agent' => (string) $request->userAgent(),
                        ]
                    );
                }
            }

            $this->syncLegacyBasicSettingsFromPolicies();
        });

        $request->session()->flash('success', 'Fee policies updated successfully.');

        return redirect()->back();
    }

    public function dashboard()
    {
        $request = request();
        $filterState = $this->resolveFilterState($request);
        $baseQuery = PlatformRevenueEvent::query();
        $this->applyFilters($baseQuery, $filterState);

        $summary = (clone $baseQuery)
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(gross_amount), 0) as gross_amount')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->selectRaw('COALESCE(SUM(net_amount), 0) as net_amount')
            ->first();

        $last30 = (clone $baseQuery)
            ->where('occurred_at', '>=', now()->subDays(30))
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->first();

        $byOperation = (clone $baseQuery)
            ->select('operation_key')
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(gross_amount), 0) as gross_amount')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->selectRaw('COALESCE(SUM(net_amount), 0) as net_amount')
            ->groupBy('operation_key')
            ->orderByDesc('fee_amount')
            ->get();

        $topEvents = (clone $baseQuery)
            ->whereNotNull('event_id')
            ->select('event_id')
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('event_id')
            ->orderByDesc('fee_amount')
            ->limit(10)
            ->get();

        $eventNames = $this->eventTitleMapForIds($topEvents->pluck('event_id')->filter()->all());

        $topEvents = $topEvents->map(function ($row) use ($eventNames) {
            $row->label = $eventNames[$row->event_id] ?? ('Event #' . $row->event_id);
            return $row;
        });

        $topOrganizers = (clone $baseQuery)
            ->where(function ($query) {
                $query->where('owner_identity_type', 'organizer')
                    ->orWhere(function ($fallback) {
                        $fallback->whereNull('owner_identity_type')
                            ->whereNotNull('organizer_id');
                    });
            })
            ->select('owner_identity_id', 'organizer_id')
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('owner_identity_id', 'organizer_id')
            ->orderByDesc('fee_amount')
            ->limit(10)
            ->get();

        $topOrganizers = $this->attachOrganizerLabels($topOrganizers);

        $topVenues = (clone $baseQuery)
            ->where(function ($query) {
                $query->whereNotNull('venue_identity_id')
                    ->orWhereNotNull('venue_id');
            })
            ->select('venue_identity_id', 'venue_id')
            ->selectRaw('COUNT(*) as operation_count')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('venue_identity_id', 'venue_id')
            ->orderByDesc('fee_amount')
            ->limit(10)
            ->get();

        $topVenues = $this->attachVenueLabels($topVenues);

        $trendRows = (clone $baseQuery)
            ->selectRaw('DATE(occurred_at) as day')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        $recentEvents = (clone $baseQuery)
            ->orderByDesc('occurred_at')
            ->limit(50)
            ->get();

        $recentEvents = $this->attachEventLabels($recentEvents);
        $recentEvents = $this->attachOrganizerLabels($recentEvents);
        $recentEvents = $this->attachVenueLabels($recentEvents);
        $gatewayTelemetry = $this->buildGatewayTelemetry($filterState);

        $filters = [
            'date_from' => $filterState['date_from'],
            'date_to' => $filterState['date_to'],
            'preset' => $filterState['preset'],
            'operation_key' => $filterState['operation_key'],
            'event_id' => $filterState['event_id'],
            'organizer_ref' => $filterState['organizer_ref'],
            'venue_ref' => $filterState['venue_ref'],
        ];

        return view('backend.economy.dashboard', [
            'summary' => $summary,
            'last30' => $last30,
            'avgTakeRate' => (float) ($summary->gross_amount ?? 0) > 0
                ? round(((float) $summary->fee_amount / (float) $summary->gross_amount) * 100, 2)
                : 0,
            'filters' => $filters,
            'presetOptions' => [
                'today' => __('Today'),
                '7d' => __('Last 7 days'),
                '30d' => __('Last 30 days'),
                'month' => __('This month'),
            ],
            'operationOptions' => FeePolicy::query()->orderBy('operation_key')->pluck('label', 'operation_key'),
            'eventOptions' => $this->buildEventOptions(),
            'organizerOptions' => $this->buildOrganizerOptions(),
            'venueOptions' => $this->buildVenueOptions(),
            'byOperation' => $byOperation,
            'topEvents' => $topEvents,
            'topOrganizers' => $topOrganizers,
            'topVenues' => $topVenues,
            'recentEvents' => $recentEvents,
            'gatewayTelemetry' => $gatewayTelemetry,
            'trendLabels' => $trendRows->pluck('day')->map(fn ($day) => Carbon::parse($day)->format('M d'))->values(),
            'trendValues' => $trendRows->pluck('fee_amount')->map(fn ($value) => round((float) $value, 2))->values(),
            'operationChartLabels' => $byOperation->pluck('operation_key')->map(fn ($value) => str($value)->replace('_', ' ')->title())->values(),
            'operationChartValues' => $byOperation->pluck('fee_amount')->map(fn ($value) => round((float) $value, 2))->values(),
        ]);
    }

    public function export(Request $request)
    {
        $filterState = $this->resolveFilterState($request);
        $query = PlatformRevenueEvent::query();
        $this->applyFilters($query, $filterState);

        $rows = $query->orderByDesc('occurred_at')->get();
        $rows = $this->attachEventLabels($rows);
        $rows = $this->attachOrganizerLabels($rows);
        $rows = $this->attachVenueLabels($rows);

        $format = strtolower((string) $request->query('format', 'csv'));
        $filenameBase = 'duty-economy-' . now()->format('Ymd_His');

        if ($format === 'xlsx') {
            return Excel::download(new EconomyRevenueExport($rows), $filenameBase . '.xlsx');
        }

        $filename = $filenameBase . '.csv';

        return response()->streamDownload(function () use ($rows) {
            $handle = fopen('php://output', 'w');

            fputcsv($handle, [
                'Occurred At',
                'Operation',
                'Event',
                'Organizer',
                'Venue',
                'Gross Amount',
                'Fee Amount',
                'Net Amount',
                'Charged To',
                'Reference Type',
                'Reference ID',
                'Booking ID',
                'Transfer ID',
                'Status',
            ]);

            foreach ($rows as $row) {
                fputcsv($handle, [
                    optional($row->occurred_at)->format('Y-m-d H:i:s'),
                    $row->operation_key,
                    $row->event_label ?? '',
                    $row->organizer_label ?? '',
                    $row->venue_label ?? '',
                    number_format((float) $row->gross_amount, 2, '.', ''),
                    number_format((float) $row->fee_amount, 2, '.', ''),
                    number_format((float) $row->net_amount, 2, '.', ''),
                    $row->charged_to,
                    $row->reference_type,
                    $row->reference_id,
                    $row->booking_id,
                    $row->transfer_id,
                    $row->status,
                ]);
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    public function settlements(Request $request)
    {
        return view('backend.economy.settlements', $this->buildSettlementViewData($request));
    }

    public function settlementShow(Request $request, int $eventId)
    {
        return view('backend.economy.settlements', $this->buildSettlementViewData($request, $eventId));
    }

    public function exportSettlements(Request $request)
    {
        $filters = $this->resolveSettlementFilterState($request);
        $rows = $this->buildSettlementBaseQuery($filters)
            ->orderByRaw("CASE settlement_status
                WHEN 'settlement_hold' THEN 0
                WHEN 'eligible_for_payout' THEN 1
                WHEN 'awaiting_settlement' THEN 2
                WHEN 'collecting' THEN 3
                ELSE 4
            END ASC")
            ->orderByDesc('updated_at')
            ->get()
            ->map(fn (EventTreasury $treasury) => $this->serializeSettlementTreasury($treasury, true))
            ->values();

        $filename = 'duty-settlement-queue-' . now()->format('Ymd_His') . '.csv';

        return response()->streamDownload(function () use ($rows) {
            $handle = fopen('php://output', 'w');

            fputcsv($handle, [
                'Event ID',
                'Event',
                'Owner Type',
                'Owner',
                'Host Venue',
                'Status',
                'Gross Collected',
                'Refunded Amount',
                'Platform Fees',
                'Available For Settlement',
                'Reserved For Collaborators',
                'Released To Wallet',
                'Claimable Amount',
                'Releasable Now',
                'Blocked Release Amount',
                'Block Reason',
                'Latest Refund Reason',
                'Latest Refund Risk Flags',
                'Latest Refund Admin',
                'Latest Refund Note',
                'Latest Refund At',
                'Requires Admin Approval',
                'Needs Admin Approval',
                'Hold Until',
            ]);

            foreach ($rows as $row) {
                fputcsv($handle, [
                    $row['event_id'],
                    $row['title'],
                    $row['owner_type'],
                    $row['owner_label'],
                    $row['host_venue_label'],
                    data_get($row, 'snapshot.status'),
                    number_format((float) data_get($row, 'detail.reconciliation.gross_collected', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.refunded_amount', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.platform_fee_total', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.available_for_settlement', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.reserved_for_collaborators', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.released_to_wallet', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.claimable_amount', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.releasable_now', 0), 2, '.', ''),
                    number_format((float) data_get($row, 'detail.reconciliation.blocked_release_amount', 0), 2, '.', ''),
                    data_get($row, 'detail.reconciliation.block_reason_label'),
                    data_get($row, 'detail.refund_operations.latest_refund_decision.reason_label'),
                    collect((array) data_get($row, 'detail.refund_operations.latest_refund_decision.risk_flag_labels', []))->implode('; '),
                    data_get($row, 'detail.refund_operations.latest_refund_decision.admin_label'),
                    data_get($row, 'detail.refund_operations.latest_refund_decision.admin_note'),
                    data_get($row, 'detail.refund_operations.latest_refund_decision.occurred_at'),
                    data_get($row, 'detail.settlement_settings.require_admin_approval') ? 'yes' : 'no',
                    data_get($row, 'snapshot.needs_admin_approval') ? 'yes' : 'no',
                    data_get($row, 'snapshot.hold_until'),
                ]);
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    public function exportSettlementEvent(Request $request, int $eventId)
    {
        $treasury = EventTreasury::query()
            ->with([
                'event.information',
                'event.ownerIdentity',
                'event.venueIdentity',
                'event.organizer',
                'event.venue',
                'event.settlementSettings',
            ])
            ->where('event_id', $eventId)
            ->firstOrFail();

        $settlement = $this->serializeSettlementTreasury($treasury, true);
        $filename = 'duty-settlement-event-' . $eventId . '-' . now()->format('Ymd_His') . '.csv';

        return response()->streamDownload(function () use ($settlement) {
            $handle = fopen('php://output', 'w');

            fputcsv($handle, [
                'Section',
                'Item',
                'Primary Value',
                'Secondary Value',
                'Notes',
                'Occurred At',
                'Reference Type',
                'Reference ID',
            ]);

            $write = function (
                string $section,
                string $item,
                mixed $primary = null,
                mixed $secondary = null,
                mixed $notes = null,
                mixed $occurredAt = null,
                mixed $referenceType = null,
                mixed $referenceId = null
            ) use ($handle): void {
                fputcsv($handle, [
                    $section,
                    $item,
                    $primary,
                    $secondary,
                    $notes,
                    $occurredAt,
                    $referenceType,
                    $referenceId,
                ]);
            };

            $write('summary', 'event', $settlement['title'], $settlement['event_id']);
            $write('summary', 'owner', $settlement['owner_label'], $settlement['owner_type']);
            $write('summary', 'host_venue', $settlement['host_venue_label']);
            $write('summary', 'status', data_get($settlement, 'snapshot.status'), $settlement['status_label']);
            $write('summary', 'hold_until', data_get($settlement, 'snapshot.hold_until'));
            $write('summary', 'needs_admin_approval', data_get($settlement, 'snapshot.needs_admin_approval') ? 'yes' : 'no');
            $write('summary', 'refund_window_open', data_get($settlement, 'detail.refund_operations.has_open_refund_window') ? 'yes' : 'no');
            $write('summary', 'refund_window_until', data_get($settlement, 'detail.refund_operations.refund_window_until'));
            $write('summary', 'hold_reason', data_get($settlement, 'detail.refund_operations.hold_reason_label'));

            foreach ((array) data_get($settlement, 'detail.reconciliation', []) as $key => $value) {
                $write(
                    'reconciliation',
                    str($key)->replace('_', ' ')->title()->toString(),
                    is_bool($value) ? ($value ? 'yes' : 'no') : $value
                );
            }

            foreach ((array) data_get($settlement, 'detail.collaborator_reconciliation', []) as $key => $value) {
                if (in_array($key, [
                    'basis_breakdown',
                    'configured_release_mode_breakdown',
                    'effective_release_mode_breakdown',
                    'split_allocations',
                ], true)) {
                    continue;
                }

                $write(
                    'collaborator_reconciliation',
                    str($key)->replace('_', ' ')->title()->toString(),
                    is_bool($value) ? ($value ? 'yes' : 'no') : $value
                );
            }

            foreach ((array) data_get($settlement, 'detail.collaborator_reconciliation.basis_breakdown', []) as $basisRow) {
                $write(
                    'collaborator_basis',
                    data_get($basisRow, 'label', data_get($basisRow, 'basis')),
                    data_get($basisRow, 'reserved_amount'),
                    data_get($basisRow, 'split_count'),
                    'Claimable: ' . data_get($basisRow, 'claimable_amount', 0)
                        . '; Claimed: ' . data_get($basisRow, 'claimed_amount', 0)
                        . '; Unreleased: ' . data_get($basisRow, 'unreleased_amount', 0)
                        . '; Basis amount: ' . data_get($basisRow, 'max_basis_amount', 0)
                );
            }

            foreach ((array) data_get($settlement, 'detail.collaborator_reconciliation.effective_release_mode_breakdown', []) as $modeRow) {
                $write(
                    'collaborator_release_mode',
                    data_get($modeRow, 'label', data_get($modeRow, 'release_mode')),
                    data_get($modeRow, 'reserved_amount'),
                    data_get($modeRow, 'split_count'),
                    'Claimable: ' . data_get($modeRow, 'claimable_amount', 0)
                        . '; Claimed: ' . data_get($modeRow, 'claimed_amount', 0)
                        . '; Unreleased: ' . data_get($modeRow, 'unreleased_amount', 0)
                );
            }

            foreach ((array) data_get($settlement, 'detail.collaborator_reconciliation.split_allocations', []) as $splitRow) {
                $write(
                    'collaborator_split',
                    data_get($splitRow, 'display_name', 'Split'),
                    data_get($splitRow, 'amount_reserved'),
                    data_get($splitRow, 'status'),
                    collect([
                        data_get($splitRow, 'role_type'),
                        data_get($splitRow, 'split_type'),
                        data_get($splitRow, 'split_value'),
                        data_get($splitRow, 'basis_label'),
                        data_get($splitRow, 'effective_release_mode_label'),
                        'Claimed: ' . data_get($splitRow, 'amount_claimed', 0),
                        'Claimable: ' . data_get($splitRow, 'claimable_amount', 0),
                    ])->filter()->implode(' · '),
                    null,
                    'event_collaborator_split',
                    data_get($splitRow, 'split_id')
                );
            }

            foreach ((array) data_get($settlement, 'detail.refund_operations', []) as $key => $value) {
                if (in_array($key, ['all_queue_url', 'refundable_queue_url', 'refunded_queue_url', 'cases', 'latest_refund_decision'], true)) {
                    continue;
                }

                $write(
                    'refund_operations',
                    str($key)->replace('_', ' ')->title()->toString(),
                    is_bool($value) ? ($value ? 'yes' : 'no') : $value
                );
            }

            foreach ((array) data_get($settlement, 'detail.refund_operations.latest_refund_decision', []) as $key => $value) {
                $write(
                    'refund_decision',
                    str($key)->replace('_', ' ')->title()->toString(),
                    is_array($value) ? collect($value)->implode('; ') : $value
                );
            }

            foreach ((array) data_get($settlement, 'detail.settlement_actions', []) as $action) {
                $write(
                    'settlement_action',
                    data_get($action, 'action_label', 'Action'),
                    data_get($action, 'amount'),
                    data_get($action, 'admin_label'),
                    data_get($action, 'release_source'),
                    data_get($action, 'occurred_at')
                );
            }

            foreach ((array) data_get($settlement, 'detail.recent_entries', []) as $entry) {
                $write(
                    'timeline',
                    data_get($entry, 'entry_label', 'Entry'),
                    data_get($entry, 'net_amount'),
                    data_get($entry, 'status_label'),
                    data_get($entry, 'entry_summary'),
                    data_get($entry, 'occurred_at'),
                    data_get($entry, 'reference_type'),
                    data_get($entry, 'reference_id')
                );
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    public function approveSettlement(Request $request, int $eventId)
    {
        try {
            $result = $this->eventTreasuryService->approveOwnerRelease(
                $eventId,
                (int) Auth::guard('admin')->id()
            );

            $request->session()->flash(
                'success',
                ($result['already_approved'] ?? false)
                    ? 'Settlement release was already approved for this event.'
                    : 'Settlement release approved successfully.'
            );
        } catch (\Throwable $exception) {
            $request->session()->flash('warning', $exception->getMessage());
        }

        return redirect()->route('admin.event_booking.economy.settlements.show', array_merge(
            $request->query(),
            ['event' => $eventId]
        ));
    }

    public function releaseSettlement(Request $request, int $eventId)
    {
        try {
            $result = $this->eventTreasuryService->releaseOwnerShareByAdmin(
                $eventId,
                (int) Auth::guard('admin')->id()
            );

            $claimedAmount = (float) data_get($result, 'claim.claimed_amount', 0);
            $request->session()->flash(
                'success',
                'Settlement released successfully to the owner wallet for RD$ ' . number_format($claimedAmount, 2)
            );
        } catch (\Throwable $exception) {
            $request->session()->flash('warning', $exception->getMessage());
        }

        return redirect()->route('admin.event_booking.economy.settlements.show', array_merge(
            $request->query(),
            ['event' => $eventId]
        ));
    }

    private function syncLegacyBasicSettingsFromPolicies(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            return;
        }

        $primaryPolicy = FeePolicy::query()->where('operation_key', FeeEngine::OP_PRIMARY_TICKET_SALE)->first();
        $marketplacePolicy = FeePolicy::query()->where('operation_key', FeeEngine::OP_MARKETPLACE_RESALE)->first();

        if (!$primaryPolicy && !$marketplacePolicy) {
            return;
        }

        $payload = [];
        if ($primaryPolicy) {
            $payload['commission'] = $primaryPolicy->percentage_value;
        }
        if ($marketplacePolicy) {
            $payload['marketplace_commission'] = $marketplacePolicy->percentage_value;
        }

        if (!empty($payload)) {
            Basic::query()->update($payload);
        }
    }

    private function attachOrganizerLabels(Collection $rows): Collection
    {
        $identityNames = collect();
        if (Schema::hasTable('identities')) {
            $identityNames = DB::table('identities')
                ->whereIn('id', $rows->pluck('owner_identity_id')->filter()->all())
                ->pluck('display_name', 'id');
        }

        $organizerNames = collect();
        if (Schema::hasTable('organizer_infos')) {
            $organizerNames = DB::table('organizer_infos')
                ->whereIn('organizer_id', $rows->pluck('organizer_id')->filter()->all())
                ->select('organizer_id', DB::raw('MAX(name) as name'))
                ->groupBy('organizer_id')
                ->pluck('name', 'organizer_id');
        }

        return $rows->map(function ($row) use ($identityNames, $organizerNames) {
            $label = $row->owner_identity_id
                ? ($identityNames[$row->owner_identity_id] ?? ('Organizer identity #' . $row->owner_identity_id))
                : ($organizerNames[$row->organizer_id] ?? ('Organizer #' . $row->organizer_id));
            $row->label = $label;
            $row->organizer_label = $label;
            return $row;
        });
    }

    private function attachVenueLabels(Collection $rows): Collection
    {
        $identityNames = collect();
        if (Schema::hasTable('identities')) {
            $identityNames = DB::table('identities')
                ->whereIn('id', $rows->pluck('venue_identity_id')->filter()->all())
                ->pluck('display_name', 'id');
        }

        $venueNames = collect();
        if (Schema::hasTable('venues')) {
            $venueNames = DB::table('venues')
                ->whereIn('id', $rows->pluck('venue_id')->filter()->all())
                ->pluck('name', 'id');
        }

        return $rows->map(function ($row) use ($identityNames, $venueNames) {
            $label = $row->venue_identity_id
                ? ($identityNames[$row->venue_identity_id] ?? ('Venue identity #' . $row->venue_identity_id))
                : ($venueNames[$row->venue_id] ?? ('Venue #' . $row->venue_id));
            $row->label = $label;
            $row->venue_label = $label;
            return $row;
        });
    }

    private function attachEventLabels(Collection $rows): Collection
    {
        $eventNames = $this->eventTitleMapForIds($rows->pluck('event_id')->filter()->all());

        return $rows->map(function ($row) use ($eventNames) {
            $row->event_label = $row->event_id
                ? ($eventNames[$row->event_id] ?? ('Event #' . $row->event_id))
                : null;
            return $row;
        });
    }

    private function applyFilters($query, Request $request): void
    {
        if ($request->filled('date_from')) {
            $query->where('occurred_at', '>=', Carbon::parse($request->query('date_from'))->startOfDay());
        }

        if ($request->filled('date_to')) {
            $query->where('occurred_at', '<=', Carbon::parse($request->query('date_to'))->endOfDay());
        }

        if ($request->filled('operation_key')) {
            $query->where('operation_key', $request->query('operation_key'));
        }

        if ($request->filled('event_id')) {
            $query->where('event_id', (int) $request->query('event_id'));
        }

        if ($request->filled('organizer_ref')) {
            [$type, $id] = array_pad(explode(':', (string) $request->query('organizer_ref'), 2), 2, null);
            if ($type === 'identity' && is_numeric($id)) {
                $query->where('owner_identity_type', 'organizer')
                    ->where('owner_identity_id', (int) $id);
            } elseif ($type === 'legacy' && is_numeric($id)) {
                $query->where('organizer_id', (int) $id);
            }
        }

        if ($request->filled('venue_ref')) {
            [$type, $id] = array_pad(explode(':', (string) $request->query('venue_ref'), 2), 2, null);
            if ($type === 'identity' && is_numeric($id)) {
                $query->where('venue_identity_id', (int) $id);
            } elseif ($type === 'legacy' && is_numeric($id)) {
                $query->where('venue_id', (int) $id);
            }
        }
    }

    private function resolveFilterState(Request $request): Request
    {
        $preset = (string) $request->query('preset', '');
        $dateFrom = $request->query('date_from');
        $dateTo = $request->query('date_to');

        if ($preset !== '' && !$request->filled('date_from') && !$request->filled('date_to')) {
            [$dateFrom, $dateTo] = match ($preset) {
                'today' => [now()->toDateString(), now()->toDateString()],
                '7d' => [now()->subDays(6)->toDateString(), now()->toDateString()],
                '30d' => [now()->subDays(29)->toDateString(), now()->toDateString()],
                'month' => [now()->startOfMonth()->toDateString(), now()->endOfMonth()->toDateString()],
                default => [$dateFrom, $dateTo],
            };
        }

        $resolved = new Request([
            'preset' => $preset,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'operation_key' => $request->query('operation_key'),
            'event_id' => $request->query('event_id'),
            'organizer_ref' => $request->query('organizer_ref'),
            'venue_ref' => $request->query('venue_ref'),
        ]);

        return $resolved;
    }

    private function buildEventOptions(): array
    {
        $rows = PlatformRevenueEvent::query()
            ->whereNotNull('event_id')
            ->select('event_id')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('event_id')
            ->orderByDesc('fee_amount')
            ->limit(100)
            ->get();

        $eventNames = $this->eventTitleMapForIds($rows->pluck('event_id')->all());

        $options = [];
        foreach ($rows as $row) {
            $options[$row->event_id] = $eventNames[$row->event_id] ?? ('Event #' . $row->event_id);
        }

        return $options;
    }

    private function buildGatewayTelemetry(Request $filters): array
    {
        $rows = collect()
            ->concat($this->buildReservationPaymentGatewayRows($filters))
            ->concat($this->buildBookingAllocationGatewayRows($filters))
            ->concat($this->buildRevenueLedgerGatewayRows($filters))
            ->filter(function (array $row) {
                return !empty($row['gateway']) || !empty($row['requested_gateway']) || !empty($row['gateway_family']);
            })
            ->values();

        if ($rows->isEmpty()) {
            return [
                'summary' => [
                    'total_records' => 0,
                    'source_count' => 0,
                    'gateway_family_count' => 0,
                    'mixed_requested_records' => 0,
                ],
                'by_source' => [],
                'by_gateway_family' => [],
                'recent_records' => [],
                'scope_note' => 'Uses the current date range and event/entity filters where gateway metadata is event-scoped.',
            ];
        }

        $recentRecords = $rows
            ->sortByDesc(fn (array $row) => data_get($row, 'occurred_at_timestamp', 0))
            ->take(25)
            ->values();

        $eventNames = $this->eventTitleMapForIds($recentRecords->pluck('event_id')->filter()->all());
        $recentRecords = $recentRecords->map(function (array $row) use ($eventNames) {
            $eventId = (int) ($row['event_id'] ?? 0);
            $row['event_label'] = $eventId > 0
                ? ($eventNames[$eventId] ?? ('Event #' . $eventId))
                : 'Non-event scoped';
            $row['gateway_label'] = $this->formatGatewayLabel($row['gateway'] ?? null);
            $row['requested_gateway_label'] = $this->formatGatewayLabel($row['requested_gateway'] ?? null);
            $row['gateway_family_label'] = $this->formatGatewayFamilyLabel($row['gateway_family'] ?? null);
            $row['verification_strategy_label'] = $this->formatVerificationStrategyLabel($row['verification_strategy'] ?? null);

            return $row;
        })->all();

        $bySource = $rows
            ->groupBy('source_key')
            ->map(function (Collection $group) {
                $topFamily = $group
                    ->groupBy(fn (array $row) => (string) ($row['gateway_family'] ?? 'unknown'))
                    ->sortByDesc(fn (Collection $familyRows) => $familyRows->count())
                    ->keys()
                    ->first();

                return [
                    'source_key' => (string) data_get($group->first(), 'source_key'),
                    'source_label' => (string) data_get($group->first(), 'source_label'),
                    'record_count' => $group->count(),
                    'tracked_amount' => round((float) $group->sum('amount'), 2),
                    'latest_at' => (($latestAt = data_get($group->sortByDesc('occurred_at_timestamp')->first(), 'occurred_at')) instanceof Carbon)
                        ? $latestAt->format('Y-m-d H:i')
                        : null,
                    'top_gateway_family' => $topFamily,
                    'top_gateway_family_label' => $this->formatGatewayFamilyLabel($topFamily),
                ];
            })
            ->sortByDesc('record_count')
            ->values()
            ->all();

        $byGatewayFamily = $rows
            ->groupBy(fn (array $row) => (string) ($row['gateway_family'] ?? 'unknown'))
            ->map(function (Collection $group, string $family) {
                return [
                    'gateway_family' => $family,
                    'label' => $this->formatGatewayFamilyLabel($family),
                    'record_count' => $group->count(),
                    'tracked_amount' => round((float) $group->sum('amount'), 2),
                    'source_count' => $group->pluck('source_key')->filter()->unique()->count(),
                ];
            })
            ->sortByDesc('record_count')
            ->values()
            ->all();

        return [
            'summary' => [
                'total_records' => $rows->count(),
                'source_count' => $rows->pluck('source_key')->filter()->unique()->count(),
                'gateway_family_count' => $rows->pluck('gateway_family')->filter()->unique()->count(),
                'mixed_requested_records' => $rows->where('requested_gateway', 'mixed')->count(),
            ],
            'by_source' => $bySource,
            'by_gateway_family' => $byGatewayFamily,
            'recent_records' => $recentRecords,
            'scope_note' => 'Uses the current date range and event/entity filters where gateway metadata is event-scoped.',
        ];
    }

    private function buildReservationPaymentGatewayRows(Request $filters): Collection
    {
        if (!Schema::hasTable('reservation_payments') || !Schema::hasTable('ticket_reservations') || !Schema::hasTable('events')) {
            return collect();
        }

        $driver = DB::connection()->getDriverName();
        $requestedGatewaySql = $this->jsonTextSql('rp.meta', 'requested_gateway', $driver);
        $gatewaySql = $this->jsonCoalesceTextSql('rp.meta', ['source_gateway', 'gateway'], $driver);
        $gatewayFamilySql = $this->jsonCoalesceTextSql('rp.meta', ['source_gateway_family', 'gateway_family'], $driver);
        $strategySql = $this->jsonCoalesceTextSql('rp.meta', ['source_verification_strategy', 'verification_strategy'], $driver);
        $occurredAtSql = 'COALESCE(rp.paid_at, rp.created_at)';

        $query = DB::table('reservation_payments as rp')
            ->join('ticket_reservations as tr', 'tr.id', '=', 'rp.reservation_id')
            ->join('events as e', 'e.id', '=', 'tr.event_id')
            ->whereNotNull('rp.meta')
            ->where('rp.status', 'completed')
            ->where('rp.total_amount', '>', 0)
            ->whereIn('rp.source_type', ['bonus_wallet', 'wallet', 'card']);

        $this->applyGatewayTelemetryDateFilters($query, $filters, $occurredAtSql);
        $this->applyGatewayTelemetryEventFilters($query, $filters, 'tr.event_id', 'e');

        return $query
            ->selectRaw("'reservation_payment' as source_key")
            ->selectRaw("'Reservation payments' as source_label")
            ->selectRaw('tr.event_id as event_id')
            ->selectRaw("{$occurredAtSql} as occurred_at")
            ->selectRaw('rp.total_amount as amount')
            ->selectRaw('rp.reference_type as reference_type')
            ->selectRaw('rp.reference_id as reference_id')
            ->selectRaw("{$requestedGatewaySql} as requested_gateway")
            ->selectRaw("{$gatewaySql} as gateway")
            ->selectRaw("{$gatewayFamilySql} as gateway_family")
            ->selectRaw("{$strategySql} as verification_strategy")
            ->get()
            ->map(fn ($row) => $this->normalizeGatewayTelemetryRow($row))
            ->values();
    }

    private function buildBookingAllocationGatewayRows(Request $filters): Collection
    {
        if (!Schema::hasTable('booking_payment_allocations') || !Schema::hasTable('bookings') || !Schema::hasTable('events')) {
            return collect();
        }

        $driver = DB::connection()->getDriverName();
        $requestedGatewaySql = $this->jsonTextSql('bpa.meta', 'requested_gateway', $driver);
        $gatewaySql = $this->jsonCoalesceTextSql('bpa.meta', ['source_gateway', 'gateway'], $driver);
        $gatewayFamilySql = $this->jsonCoalesceTextSql('bpa.meta', ['source_gateway_family', 'gateway_family'], $driver);
        $strategySql = $this->jsonCoalesceTextSql('bpa.meta', ['source_verification_strategy', 'verification_strategy'], $driver);

        $query = DB::table('booking_payment_allocations as bpa')
            ->join('bookings as b', 'b.id', '=', 'bpa.booking_id')
            ->join('events as e', 'e.id', '=', 'b.event_id')
            ->whereNotNull('bpa.meta')
            ->where('bpa.total_amount', '>', 0);

        $this->applyGatewayTelemetryDateFilters($query, $filters, 'bpa.created_at');
        $this->applyGatewayTelemetryEventFilters($query, $filters, 'b.event_id', 'e');

        return $query
            ->selectRaw("'booking_allocation' as source_key")
            ->selectRaw("'Booking allocations' as source_label")
            ->selectRaw('b.event_id as event_id')
            ->selectRaw('bpa.created_at as occurred_at')
            ->selectRaw('bpa.total_amount as amount')
            ->selectRaw('bpa.reference_type as reference_type')
            ->selectRaw('bpa.reference_id as reference_id')
            ->selectRaw("{$requestedGatewaySql} as requested_gateway")
            ->selectRaw("{$gatewaySql} as gateway")
            ->selectRaw("{$gatewayFamilySql} as gateway_family")
            ->selectRaw("{$strategySql} as verification_strategy")
            ->get()
            ->map(fn ($row) => $this->normalizeGatewayTelemetryRow($row))
            ->values();
    }

    private function buildRevenueLedgerGatewayRows(Request $filters): Collection
    {
        if (!Schema::hasTable('platform_revenue_events')) {
            return collect();
        }

        $driver = DB::connection()->getDriverName();
        $requestedGatewaySql = $this->jsonTextSql('platform_revenue_events.metadata', 'requested_gateway', $driver);
        $gatewaySql = $this->jsonCoalesceTextSql('platform_revenue_events.metadata', ['source_gateway', 'gateway'], $driver);
        $gatewayFamilySql = $this->jsonCoalesceTextSql('platform_revenue_events.metadata', ['source_gateway_family', 'gateway_family'], $driver);
        $strategySql = $this->jsonCoalesceTextSql('platform_revenue_events.metadata', ['source_verification_strategy', 'verification_strategy'], $driver);

        $query = PlatformRevenueEvent::query()
            ->whereNotNull('metadata')
            ->where(function ($builder) use ($requestedGatewaySql, $gatewaySql, $gatewayFamilySql) {
                $builder->whereRaw("{$requestedGatewaySql} IS NOT NULL")
                    ->orWhereRaw("{$gatewaySql} IS NOT NULL")
                    ->orWhereRaw("{$gatewayFamilySql} IS NOT NULL");
            });

        $dateScopedFilters = new Request([
            'date_from' => $filters->query('date_from'),
            'date_to' => $filters->query('date_to'),
            'event_id' => $filters->query('event_id'),
            'organizer_ref' => $filters->query('organizer_ref'),
            'venue_ref' => $filters->query('venue_ref'),
        ]);

        $this->applyFilters($query, $dateScopedFilters);

        return $query
            ->selectRaw("'revenue_ledger' as source_key")
            ->selectRaw("'Revenue ledger' as source_label")
            ->selectRaw('event_id as event_id')
            ->selectRaw('occurred_at as occurred_at')
            ->selectRaw('total_charge_amount as amount')
            ->selectRaw('reference_type as reference_type')
            ->selectRaw('reference_id as reference_id')
            ->selectRaw("{$requestedGatewaySql} as requested_gateway")
            ->selectRaw("{$gatewaySql} as gateway")
            ->selectRaw("{$gatewayFamilySql} as gateway_family")
            ->selectRaw("{$strategySql} as verification_strategy")
            ->get()
            ->map(fn ($row) => $this->normalizeGatewayTelemetryRow($row))
            ->values();
    }

    private function applyGatewayTelemetryDateFilters($query, Request $filters, string $occurredAtSql): void
    {
        if ($filters->filled('date_from')) {
            $query->whereRaw("{$occurredAtSql} >= ?", [Carbon::parse($filters->query('date_from'))->startOfDay()]);
        }

        if ($filters->filled('date_to')) {
            $query->whereRaw("{$occurredAtSql} <= ?", [Carbon::parse($filters->query('date_to'))->endOfDay()]);
        }
    }

    private function applyGatewayTelemetryEventFilters($query, Request $filters, string $eventIdColumn, string $eventAlias = 'e'): void
    {
        if ($filters->filled('event_id')) {
            $query->where($eventIdColumn, (int) $filters->query('event_id'));
        }

        if ($filters->filled('organizer_ref')) {
            [$type, $id] = array_pad(explode(':', (string) $filters->query('organizer_ref'), 2), 2, null);
            if ($type === 'identity' && is_numeric($id)) {
                $query->where($eventAlias . '.owner_identity_id', (int) $id);
            } elseif ($type === 'legacy' && is_numeric($id)) {
                $query->where($eventAlias . '.organizer_id', (int) $id);
            }
        }

        if ($filters->filled('venue_ref')) {
            [$type, $id] = array_pad(explode(':', (string) $filters->query('venue_ref'), 2), 2, null);
            if ($type === 'identity' && is_numeric($id)) {
                $query->where($eventAlias . '.venue_identity_id', (int) $id);
            } elseif ($type === 'legacy' && is_numeric($id)) {
                $query->where($eventAlias . '.venue_id', (int) $id);
            }
        }
    }

    private function normalizeGatewayTelemetryRow(object $row): array
    {
        $occurredAt = !empty($row->occurred_at) ? Carbon::parse((string) $row->occurred_at) : null;

        return [
            'source_key' => (string) ($row->source_key ?? ''),
            'source_label' => (string) ($row->source_label ?? ''),
            'event_id' => !empty($row->event_id) ? (int) $row->event_id : null,
            'occurred_at' => $occurredAt,
            'occurred_at_timestamp' => $occurredAt?->timestamp ?? 0,
            'amount' => round((float) ($row->amount ?? 0), 2),
            'reference_type' => $row->reference_type ?? null,
            'reference_id' => $row->reference_id ?? null,
            'requested_gateway' => $this->normalizeNullableString($row->requested_gateway ?? null),
            'gateway' => $this->normalizeNullableString($row->gateway ?? null),
            'gateway_family' => $this->normalizeNullableString($row->gateway_family ?? null),
            'verification_strategy' => $this->normalizeNullableString($row->verification_strategy ?? null),
        ];
    }

    private function jsonTextSql(string $column, string $key, string $driver): string
    {
        $path = '$."' . str_replace('"', '\\"', $key) . '"';

        if ($driver === 'sqlite') {
            return "json_extract({$column}, '{$path}')";
        }

        return "JSON_UNQUOTE(JSON_EXTRACT({$column}, '{$path}'))";
    }

    private function jsonCoalesceTextSql(string $column, array $keys, string $driver): string
    {
        $expressions = collect($keys)
            ->map(fn (string $key) => $this->jsonTextSql($column, $key, $driver))
            ->implode(', ');

        return 'COALESCE(' . $expressions . ')';
    }

    private function normalizeNullableString(mixed $value): ?string
    {
        $value = trim((string) $value);

        return $value === '' ? null : $value;
    }

    private function formatGatewayLabel(?string $gateway): string
    {
        return $gateway ? str($gateway)->replace('_', ' ')->title()->toString() : 'Unknown';
    }

    private function formatGatewayFamilyLabel(?string $family): string
    {
        return match ($family) {
            'stripe_card' => 'Stripe card',
            'internal_balance' => 'Internal balance',
            'offline' => 'Offline/manual',
            'unknown', null, '' => 'Unknown',
            default => str($family)->replace('_', ' ')->title()->toString(),
        };
    }

    private function formatVerificationStrategyLabel(?string $strategy): string
    {
        return $strategy ? str($strategy)->replace('_', ' ')->title()->toString() : 'Unknown';
    }

    private function buildOrganizerOptions(): array
    {
        $rows = PlatformRevenueEvent::query()
            ->where(function ($query) {
                $query->where('owner_identity_type', 'organizer')
                    ->orWhereNotNull('organizer_id');
            })
            ->select('owner_identity_id', 'organizer_id')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('owner_identity_id', 'organizer_id')
            ->orderByDesc('fee_amount')
            ->limit(100)
            ->get();

        $rows = $this->attachOrganizerLabels($rows);

        $options = [];
        foreach ($rows as $row) {
            $key = $row->owner_identity_id ? 'identity:' . $row->owner_identity_id : 'legacy:' . $row->organizer_id;
            $options[$key] = $row->organizer_label;
        }

        return $options;
    }

    private function buildVenueOptions(): array
    {
        $rows = PlatformRevenueEvent::query()
            ->where(function ($query) {
                $query->whereNotNull('venue_identity_id')
                    ->orWhereNotNull('venue_id');
            })
            ->select('venue_identity_id', 'venue_id')
            ->selectRaw('COALESCE(SUM(fee_amount), 0) as fee_amount')
            ->groupBy('venue_identity_id', 'venue_id')
            ->orderByDesc('fee_amount')
            ->limit(100)
            ->get();

        $rows = $this->attachVenueLabels($rows);

        $options = [];
        foreach ($rows as $row) {
            $key = $row->venue_identity_id ? 'identity:' . $row->venue_identity_id : 'legacy:' . $row->venue_id;
            $options[$key] = $row->venue_label;
        }

        return $options;
    }

    private function eventTitleMapForIds(array $eventIds): Collection
    {
        $eventIds = array_values(array_unique(array_filter(array_map('intval', $eventIds))));
        if (empty($eventIds) || !Schema::hasTable('event_contents')) {
            return collect();
        }

        $defaultLanguageId = (int) (Language::query()->where('is_default', 1)->value('id')
            ?? Language::query()->min('id')
            ?? 1);

        $titles = EventContent::query()
            ->whereIn('event_id', $eventIds)
            ->where('language_id', $defaultLanguageId)
            ->pluck('title', 'event_id');

        $missingEventIds = array_values(array_diff($eventIds, $titles->keys()->map(fn ($id) => (int) $id)->all()));
        if (!empty($missingEventIds)) {
            $fallbackTitles = EventContent::query()
                ->whereIn('event_id', $missingEventIds)
                ->orderBy('id')
                ->get(['event_id', 'title'])
                ->groupBy('event_id')
                ->map(fn ($group) => optional($group->first())->title)
                ->filter();

            $titles = $titles->merge($fallbackTitles);
        }

        return $titles;
    }

    private function buildSettlementViewData(Request $request, ?int $selectedEventId = null): array
    {
        $filters = $this->resolveSettlementFilterState($request);
        $selectedEventId = $selectedEventId ?: ($request->filled('selected_event') ? (int) $request->query('selected_event') : null);
        $baseQuery = $this->buildSettlementBaseQuery($filters);

        $treasuryCountsQuery = clone $baseQuery;

        $treasuries = (clone $baseQuery)
            ->orderByRaw("CASE settlement_status
                WHEN 'settlement_hold' THEN 0
                WHEN 'eligible_for_payout' THEN 1
                WHEN 'awaiting_settlement' THEN 2
                WHEN 'collecting' THEN 3
                ELSE 4
            END ASC")
            ->orderByDesc('updated_at')
            ->paginate(12)
            ->withQueryString();

        $treasuries->getCollection()->transform(function (EventTreasury $treasury) {
            return (object) $this->serializeSettlementTreasury($treasury);
        });

        $selectedTreasury = null;
        if ($selectedEventId) {
            $selectedTreasury = EventTreasury::query()
                ->with([
                    'event.information',
                    'event.ownerIdentity',
                    'event.venueIdentity',
                    'event.organizer',
                    'event.venue',
                    'event.settlementSettings',
                ])
                ->where('event_id', $selectedEventId)
                ->first();
        }

        $selectedSettlement = $selectedTreasury
            ? $this->serializeSettlementTreasury($selectedTreasury, true)
            : null;

        return [
            'filters' => $filters,
            'statusOptions' => [
                'all' => 'All statuses',
                EventTreasury::STATUS_COLLECTING => 'Collecting',
                EventTreasury::STATUS_AWAITING_SETTLEMENT => 'Awaiting settlement',
                EventTreasury::STATUS_SETTLEMENT_HOLD => 'Settlement hold',
                EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT => 'Eligible for payout',
                EventTreasury::STATUS_SETTLED => 'Settled',
            ],
            'approvalOptions' => [
                'all' => 'All approval states',
                'required' => 'Needs admin approval',
                'approved' => 'Approved by admin',
                'not_required' => 'No admin approval required',
            ],
            'ownerTypeOptions' => [
                'all' => 'All owners',
                'organizer' => 'Organizer-managed',
                'venue' => 'Venue-managed',
            ],
            'treasuries' => $treasuries,
            'selectedSettlement' => $selectedSettlement,
            'summaryCards' => [
                'total_events' => (clone $treasuryCountsQuery)->count(),
                'holding_count' => (clone $treasuryCountsQuery)
                    ->where('settlement_status', EventTreasury::STATUS_SETTLEMENT_HOLD)
                    ->count(),
                'ready_count' => (clone $treasuryCountsQuery)
                    ->where('settlement_status', EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT)
                    ->whereRaw('(available_for_settlement - reserved_for_collaborators - released_to_wallet) > 0')
                    ->count(),
                'needs_approval_count' => (clone $treasuryCountsQuery)
                    ->whereHas('event.settlementSettings', function ($query) {
                        $query->where('require_admin_approval', true);
                    })
                    ->whereNull('admin_release_approved_at')
                    ->count(),
                'claimable_total' => round((float) ((clone $treasuryCountsQuery)
                    ->selectRaw('COALESCE(SUM(CASE WHEN (available_for_settlement - reserved_for_collaborators - released_to_wallet) > 0 THEN (available_for_settlement - reserved_for_collaborators - released_to_wallet) ELSE 0 END), 0) as total')
                    ->value('total') ?? 0), 2),
            ],
            'currencyInfo' => $this->getCurrencyInfo(),
        ];
    }

    private function buildSettlementBaseQuery(array $filters)
    {
        $baseQuery = EventTreasury::query()
            ->with([
                'event.information',
                'event.ownerIdentity',
                'event.venueIdentity',
                'event.organizer',
                'event.venue',
                'event.settlementSettings',
            ]);

        $this->applySettlementFilters($baseQuery, $filters);

        return $baseQuery;
    }

    private function resolveSettlementFilterState(Request $request): array
    {
        $status = (string) $request->query('status', 'all');
        $approval = (string) $request->query('approval', 'all');
        $ownerType = (string) $request->query('owner_type', 'all');

        return [
            'search' => trim((string) $request->query('search', '')),
            'status' => in_array($status, [
                'all',
                EventTreasury::STATUS_COLLECTING,
                EventTreasury::STATUS_AWAITING_SETTLEMENT,
                EventTreasury::STATUS_SETTLEMENT_HOLD,
                EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT,
                EventTreasury::STATUS_SETTLED,
            ], true) ? $status : 'all',
            'approval' => in_array($approval, ['all', 'required', 'approved', 'not_required'], true) ? $approval : 'all',
            'owner_type' => in_array($ownerType, ['all', 'organizer', 'venue'], true) ? $ownerType : 'all',
        ];
    }

    private function applySettlementFilters($query, array $filters): void
    {
        if ($filters['status'] !== 'all') {
            $query->where('settlement_status', $filters['status']);
        }

        if ($filters['approval'] === 'required') {
            $query->whereHas('event.settlementSettings', function ($builder) {
                $builder->where('require_admin_approval', true);
            })->whereNull('admin_release_approved_at');
        } elseif ($filters['approval'] === 'approved') {
            $query->whereHas('event.settlementSettings', function ($builder) {
                $builder->where('require_admin_approval', true);
            })->whereNotNull('admin_release_approved_at');
        } elseif ($filters['approval'] === 'not_required') {
            $query->where(function ($builder) {
                $builder->whereHas('event.settlementSettings', function ($settings) {
                    $settings->where('require_admin_approval', false);
                })->orWhereDoesntHave('event.settlementSettings');
            });
        }

        if ($filters['owner_type'] === 'organizer') {
            $query->whereHas('event', function ($builder) {
                $builder->where(function ($query) {
                    $query->whereNotNull('owner_identity_id')
                        ->orWhereNotNull('organizer_id');
                });
            });
        } elseif ($filters['owner_type'] === 'venue') {
            $query->whereHas('event', function ($builder) {
                $builder->whereNull('owner_identity_id')
                    ->whereNull('organizer_id')
                    ->where(function ($query) {
                        $query->whereNotNull('venue_identity_id')
                            ->orWhereNotNull('venue_id');
                    });
            });
        }

        if ($filters['search'] !== '') {
            $search = '%' . $filters['search'] . '%';

            $query->whereHas('event', function ($builder) use ($search) {
                $builder->whereHas('information', function ($infoQuery) use ($search) {
                    $infoQuery->where('title', 'like', $search);
                });
            });
        }
    }

    private function serializeSettlementTreasury(EventTreasury $treasury, bool $withDetail = false): array
    {
        $event = $treasury->event;
        $report = $this->eventTreasuryService->buildSettlementReportData($treasury) ?? [];
        $snapshot = $report['snapshot'] ?? ($this->eventTreasuryService->settlementSnapshot($treasury) ?? []);
        $owner = $event instanceof Event ? resolveSettlementProfessionalTarget($event) : [
            'actor_type' => null,
            'organizer_identity_id' => null,
            'organizer_id' => null,
            'venue_identity_id' => null,
            'venue_id' => null,
        ];

        $ownerLabel = $event instanceof Event
            ? $this->resolveSettlementOwnerLabel($event, $owner)
            : 'Unassigned owner';

        $hostVenueLabel = $event instanceof Event ? $this->resolveEventHostVenueLabel($event) : null;
        $title = $event?->information?->title ?: ('Event #' . $treasury->event_id);

        $payload = [
            'treasury_id' => $treasury->id,
            'event_id' => $treasury->event_id,
            'title' => $title,
            'owner_type' => $owner['actor_type'],
            'owner_label' => $ownerLabel,
            'host_venue_label' => $hostVenueLabel,
            'snapshot' => $snapshot,
            'status_label' => str((string) ($snapshot['status'] ?? $treasury->settlement_status))->replace('_', ' ')->title()->toString(),
            'status_tone' => match ($snapshot['status'] ?? $treasury->settlement_status) {
                EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT => 'success',
                EventTreasury::STATUS_SETTLEMENT_HOLD => 'danger',
                EventTreasury::STATUS_AWAITING_SETTLEMENT => 'warning',
                EventTreasury::STATUS_SETTLED => 'dark',
                default => 'primary',
            },
            'review_url' => route('admin.event_booking.economy.settlements.show', ['event' => $treasury->event_id]),
        ];

        if (!$withDetail) {
            return $payload;
        }
        $recentEntries = $report['timeline_entries'] ?? [];

        $settlementActionLog = $this->buildSettlementActionLog($treasury);

        $collaborationSummary = $this->eventCollaboratorSplitService->supportsCollaboratorEconomy() && $event
            ? $this->eventCollaboratorSplitService->eventSummary($event->id)
            : [
                'reserved_for_collaborators' => 0,
                'claimable_count' => 0,
                'activity' => [],
            ];

        $refundOperations = $event
            ? $this->summarizeRefundOperations($event, $snapshot, $recentEntries)
            : $this->emptyRefundOperations();

        $payload['detail'] = [
            'settlement_settings' => [
                'hold_mode' => $event?->settlementSettings?->hold_mode ?? 'auto_after_grace_period',
                'grace_period_hours' => $event?->settlementSettings?->grace_period_hours,
                'refund_window_hours' => $event?->settlementSettings?->refund_window_hours,
                'auto_release_owner_share' => (bool) ($event?->settlementSettings?->auto_release_owner_share ?? false),
                'require_admin_approval' => (bool) ($event?->settlementSettings?->require_admin_approval ?? false),
                'notes' => $event?->settlementSettings?->notes,
            ],
            'reconciliation' => $report['reconciliation'] ?? [
                'gross_collected' => round((float) ($snapshot['gross_collected'] ?? 0), 2),
                'refunded_amount' => round((float) ($snapshot['refunded_amount'] ?? 0), 2),
                'collected_after_refunds' => round((float) ($snapshot['net_collected'] ?? 0), 2),
                'platform_fee_total' => round((float) ($snapshot['platform_fee_total'] ?? 0), 2),
                'net_after_platform_fees' => round(max(0, (float) ($snapshot['net_collected'] ?? 0) - (float) ($snapshot['platform_fee_total'] ?? 0)), 2),
                'available_for_settlement' => round((float) ($snapshot['available_for_settlement'] ?? 0), 2),
                'reserved_for_collaborators' => round((float) ($snapshot['reserved_for_collaborators'] ?? 0), 2),
                'owner_reserved_unreleased' => round((float) ($snapshot['claimable_amount'] ?? 0), 2),
                'released_to_wallet' => round((float) ($snapshot['released_to_wallet'] ?? 0), 2),
                'claimable_amount' => round((float) ($snapshot['claimable_amount'] ?? 0), 2),
                'releasable_now' => (bool) ($snapshot['can_release_now'] ?? false)
                    ? round((float) ($snapshot['claimable_amount'] ?? 0), 2)
                    : 0.0,
                'blocked_release_amount' => (bool) ($snapshot['can_release_now'] ?? false)
                    ? 0.0
                    : round((float) ($snapshot['claimable_amount'] ?? 0), 2),
                'block_reason' => null,
                'block_reason_label' => null,
                'can_release_now' => (bool) ($snapshot['can_release_now'] ?? false),
            ],
            'settlement_actions' => $settlementActionLog,
            'recent_entries' => $recentEntries,
            'collaboration_summary' => [
                'reserved_for_collaborators' => round((float) ($collaborationSummary['reserved_for_collaborators'] ?? 0), 2),
                'claimable_count' => (int) ($collaborationSummary['claimable_count'] ?? 0),
                'activity' => collect($collaborationSummary['activity'] ?? [])
                    ->sortByDesc('occurred_at')
                    ->take(6)
                    ->values()
                    ->all(),
            ],
            'collaborator_reconciliation' => $report['collaborator_reconciliation'] ?? [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => round((float) ($collaborationSummary['reserved_for_collaborators'] ?? 0), 2),
                'claimable_count' => (int) ($collaborationSummary['claimable_count'] ?? 0),
                'claimable_amount' => 0.0,
                'pending_amount' => 0.0,
                'claimed_amount' => 0.0,
                'unreleased_amount' => round((float) ($collaborationSummary['reserved_for_collaborators'] ?? 0), 2),
                'released_to_wallet' => 0.0,
                'basis_breakdown' => [],
                'configured_release_mode_breakdown' => [],
                'effective_release_mode_breakdown' => [],
                'split_allocations' => [],
            ],
            'refund_operations' => $refundOperations,
        ];

        return $payload;
    }

    private function buildSettlementActionLog(EventTreasury $treasury): array
    {
        $entries = EventFinancialEntry::query()
            ->where('treasury_id', $treasury->id)
            ->whereIn('entry_type', [
                EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED,
                EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
            ])
            ->orderByDesc('occurred_at')
            ->limit(10)
            ->get();

        if ($entries->isEmpty()) {
            return [];
        }

        $adminIds = $entries
            ->map(function (EventFinancialEntry $entry) {
                return (int) (data_get($entry->metadata, 'approved_by_admin_id')
                    ?: data_get($entry->metadata, 'released_by_admin_id')
                    ?: $entry->reference_id);
            })
            ->filter(fn ($id) => $id > 0)
            ->unique()
            ->values()
            ->all();

        $adminLabels = $this->resolveAdminLabels($adminIds);

        return $entries
            ->map(function (EventFinancialEntry $entry) use ($adminLabels) {
                $adminId = (int) (data_get($entry->metadata, 'approved_by_admin_id')
                    ?: data_get($entry->metadata, 'released_by_admin_id')
                    ?: $entry->reference_id);

                $actionType = $entry->entry_type === EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED
                    ? 'approval'
                    : 'release';

                $releaseSource = (string) data_get($entry->metadata, 'release_source', '');
                $amount = $actionType === 'release'
                    ? round(abs((float) data_get($entry->metadata, 'claimed_amount', $entry->net_amount)), 2)
                    : 0.0;

                return [
                    'action_type' => $actionType,
                    'action_label' => $actionType === 'approval'
                        ? 'Owner release approved'
                        : 'Owner wallet payout released',
                    'tone' => $actionType === 'approval' ? 'warning' : 'success',
                    'occurred_at' => optional($entry->occurred_at)->format('Y-m-d H:i'),
                    'admin_id' => $adminId ?: null,
                    'admin_label' => $adminId > 0
                        ? ($adminLabels[$adminId] ?? ('Admin #' . $adminId))
                        : 'System',
                    'amount' => $amount,
                    'release_source' => $releaseSource !== '' ? str($releaseSource)->replace('_', ' ')->title()->toString() : null,
                ];
            })
            ->values()
            ->all();
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

    private function emptyRefundOperations(): array
    {
        return [
            'supported' => false,
            'has_open_refund_window' => false,
            'refund_window_until' => null,
            'hold_reason_label' => null,
            'latest_refund_decision' => null,
            'total_reservations' => 0,
            'refundable_reservations_count' => 0,
            'refunded_reservations_count' => 0,
            'refundable_gross' => 0.0,
            'refunded_gross' => 0.0,
            'all_queue_url' => null,
            'refundable_queue_url' => null,
            'refunded_queue_url' => null,
            'cases' => [],
        ];
    }

    private function summarizeRefundOperations(Event $event, array $snapshot, array $recentEntries): array
    {
        if (!Schema::hasTable('ticket_reservations') || !Schema::hasTable('reservation_payments')) {
            return $this->emptyRefundOperations();
        }

        $reservations = TicketReservation::query()
            ->with(['payments:id,reservation_id,source_type,total_amount,status,paid_at'])
            ->where('event_id', $event->id)
            ->orderByDesc('id')
            ->get([
                'id',
                'event_id',
                'reservation_code',
                'status',
                'remaining_balance',
                'final_due_date',
                'expires_at',
                'created_at',
            ]);

        $cases = [];
        $refundableCount = 0;
        $refundedCount = 0;
        $refundableGross = 0.0;
        $refundedGross = 0.0;

        foreach ($reservations as $reservation) {
            $completedGross = round((float) $reservation->payments
                ->where('status', 'completed')
                ->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])
                ->sum('total_amount'), 2);

            $reservationRefundedGross = round((float) abs($reservation->payments
                ->where('status', 'reversed')
                ->filter(fn ($payment) => str_ends_with((string) $payment->source_type, '_refund'))
                ->sum('total_amount')), 2);

            $reservationRefundableGross = round(max(
                0,
                in_array($reservation->status, ['cancelled', 'defaulted'], true)
                    ? $completedGross - $reservationRefundedGross
                    : 0
            ), 2);

            $isRefundable = $reservationRefundableGross > 0;
            $isRefunded = $reservationRefundedGross > 0;

            if ($isRefundable) {
                $refundableCount++;
                $refundableGross += $reservationRefundableGross;
            }

            if ($isRefunded) {
                $refundedCount++;
                $refundedGross += $reservationRefundedGross;
            }

            if (!$isRefundable && !$isRefunded) {
                continue;
            }

            $cases[] = [
                'reservation_id' => $reservation->id,
                'reservation_code' => $reservation->reservation_code,
                'status' => $reservation->status,
                'status_label' => str($reservation->status)->replace('_', ' ')->title()->toString(),
                'refundable_gross' => $reservationRefundableGross,
                'refunded_gross' => $reservationRefundedGross,
                'detail_url' => route('admin.event_reservation.details', ['id' => $reservation->id]),
                'tone' => $isRefundable ? 'warning' : 'success',
                'sort_weight' => $isRefundable ? 2 : 1,
                'last_paid_at' => optional($reservation->payments->sortByDesc('paid_at')->first()?->paid_at)->format('Y-m-d H:i'),
            ];
        }

        usort($cases, function (array $left, array $right) {
            return [$right['sort_weight'], $right['refundable_gross'], $right['refunded_gross'], $right['reservation_id']]
                <=> [$left['sort_weight'], $left['refundable_gross'], $left['refunded_gross'], $left['reservation_id']];
        });

        $latestRefundEntry = collect($recentEntries)->first(function (array $entry) {
            return in_array($entry['entry_type'] ?? null, [
                EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED,
                EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED,
                EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED,
            ], true);
        });

        $latestRefundDecisionEntry = collect($recentEntries)->first(function (array $entry) {
            return in_array($entry['entry_type'] ?? null, [
                EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED,
                EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED,
            ], true) && !empty(data_get($entry, 'metadata.refund_reason_code'));
        });

        $holdReason = data_get($latestRefundEntry, 'metadata.reason');
        $processedByAdminId = (int) data_get($latestRefundDecisionEntry, 'metadata.processed_by_admin_id', 0);
        $adminLabels = $processedByAdminId > 0 ? $this->resolveAdminLabels([$processedByAdminId]) : [];

        return [
            'supported' => true,
            'has_open_refund_window' => ($latestRefundEntry['entry_type'] ?? null) === EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED
                && !empty($snapshot['remaining_hold_hours']),
            'refund_window_until' => $snapshot['hold_until'] ?? null,
            'hold_reason_label' => $holdReason
                ? str((string) $holdReason)->replace('_', ' ')->title()->toString()
                : null,
            'latest_refund_decision' => $latestRefundDecisionEntry ? [
                'reason_code' => data_get($latestRefundDecisionEntry, 'metadata.refund_reason_code'),
                'reason_label' => data_get($latestRefundDecisionEntry, 'metadata.refund_reason_label'),
                'admin_note' => data_get($latestRefundDecisionEntry, 'metadata.refund_admin_note'),
                'risk_flags' => data_get($latestRefundDecisionEntry, 'metadata.refund_risk_flags', []),
                'risk_flag_labels' => data_get($latestRefundDecisionEntry, 'metadata.refund_risk_flag_labels', []),
                'processed_by_admin_id' => $processedByAdminId ?: null,
                'admin_label' => $processedByAdminId > 0
                    ? ($adminLabels[$processedByAdminId] ?? ('Admin #' . $processedByAdminId))
                    : null,
                'occurred_at' => data_get($latestRefundDecisionEntry, 'occurred_at'),
                'entry_label' => data_get($latestRefundDecisionEntry, 'entry_label'),
            ] : null,
            'total_reservations' => $reservations->count(),
            'refundable_reservations_count' => $refundableCount,
            'refunded_reservations_count' => $refundedCount,
            'refundable_gross' => round($refundableGross, 2),
            'refunded_gross' => round($refundedGross, 2),
            'all_queue_url' => route('admin.event_reservation.index', [
                'status' => 'all',
                'event_id' => $event->id,
                'refund_state' => 'all',
                'due_state' => 'all',
            ]),
            'refundable_queue_url' => route('admin.event_reservation.index', [
                'status' => 'all',
                'event_id' => $event->id,
                'refund_state' => 'refundable',
                'due_state' => 'all',
            ]),
            'refunded_queue_url' => route('admin.event_reservation.index', [
                'status' => 'all',
                'event_id' => $event->id,
                'refund_state' => 'refunded',
                'due_state' => 'all',
            ]),
            'cases' => collect($cases)
                ->take(5)
                ->values()
                ->map(function (array $case) {
                    unset($case['sort_weight']);
                    return $case;
                })
                ->all(),
        ];
    }

    private function resolveSettlementOwnerLabel(Event $event, array $owner): string
    {
        if (($owner['actor_type'] ?? null) === 'organizer') {
            if ($event->ownerIdentity?->display_name) {
                return $event->ownerIdentity->display_name;
            }

            if (Schema::hasTable('organizer_infos') && $event->organizer_id) {
                $name = DB::table('organizer_infos')
                    ->where('organizer_id', $event->organizer_id)
                    ->value('name');

                if ($name) {
                    return (string) $name;
                }
            }

            return 'Organizer #' . ($event->organizer_id ?: $event->owner_identity_id);
        }

        if ($event->venueIdentity?->display_name) {
            return $event->venueIdentity->display_name;
        }

        if ($event->venue?->name) {
            return $event->venue->name;
        }

        return 'Venue #' . ($event->venue_id ?: $event->venue_identity_id);
    }

    private function resolveEventHostVenueLabel(Event $event): ?string
    {
        if ($event->venueIdentity?->display_name) {
            return $event->venueIdentity->display_name;
        }

        if ($event->venue?->name) {
            return $event->venue->name;
        }

        return null;
    }
}
