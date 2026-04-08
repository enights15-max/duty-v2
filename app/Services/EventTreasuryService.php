<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\EventFinancialEntry;
use App\Models\EventSettlementSetting;
use App\Models\EventTreasury;
use App\Models\IdentityBalanceTransaction;
use App\Models\Reservation\ReservationPayment;
use App\Models\Reservation\TicketReservation;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class EventTreasuryService
{
    public function __construct(
        private FeeEngine $feeEngine,
        private ProfessionalBalanceService $professionalBalanceService,
        private EventCollaboratorSplitService $collaboratorSplitService
    )
    {
    }

    public function supportsTreasury(): bool
    {
        return Schema::hasTable('event_treasuries') && Schema::hasTable('event_financial_entries');
    }

    public function supportsSettlementSettings(): bool
    {
        return Schema::hasTable('event_settlement_settings');
    }

    public function shouldReserveOwnerShare(mixed $booking): bool
    {
        if (!$this->supportsTreasury()) {
            return false;
        }

        if (!bookingHasProfessionalOwner($booking)) {
            return false;
        }

        $eventId = (int) data_get($booking, 'event_id', 0);
        if ($eventId <= 0) {
            return false;
        }

        if ($this->isReservationConversionBooking($booking)) {
            return false;
        }

        return $this->resolveEvent($booking, $eventId) !== null;
    }

    public function shouldHandleBookingThroughTreasury(mixed $booking): bool
    {
        if (!$this->supportsTreasury() || !bookingHasProfessionalOwner($booking)) {
            return false;
        }

        if ($this->isReservationConversionBooking($booking)) {
            return true;
        }

        return $this->shouldReserveOwnerShare($booking);
    }

    public function shouldReserveReservationRevenue(TicketReservation $reservation): bool
    {
        if (!$this->supportsTreasury()) {
            return false;
        }

        if (!$reservation->event instanceof Event) {
            $reservation->loadMissing('event');
        }

        return bookingHasProfessionalOwner($reservation);
    }

    public function ensureTreasury(Event|int|null $event): ?EventTreasury
    {
        if (!$this->supportsTreasury()) {
            return null;
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return null;
        }

        $settings = $this->ensureSettlementSettings($eventModel);

        $treasury = EventTreasury::query()->firstOrCreate(
            ['event_id' => $eventModel->id],
            [
                'hold_until' => $this->resolveDefaultHoldUntil($eventModel, $settings),
                'settlement_status' => EventTreasury::STATUS_COLLECTING,
                'auto_payout_enabled' => $this->shouldAutoPayout($settings),
                'auto_payout_delay_hours' => $settings?->grace_period_hours,
            ]
        );

        return $this->refreshSettlementState($treasury);
    }

    public function refreshSettlementState(
        EventTreasury|Event|int|null $subject,
        ?Carbon $now = null
    ): ?EventTreasury {
        if (!$this->supportsTreasury()) {
            return null;
        }

        [$treasury, $eventModel] = $this->resolveTreasuryContext($subject);

        if (!$treasury || !$eventModel) {
            return null;
        }

        $now = $now ?: now();
        if ($this->collaboratorSplitService->supportsCollaboratorEconomy()) {
            $this->collaboratorSplitService->syncEventCollaboratorEarnings($eventModel, $now);
            $treasury = $treasury->fresh();
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        $nextStatus = $this->determineSettlementStatus($treasury, $eventModel, $settings, $now);

        if ($treasury->settlement_status !== $nextStatus) {
            $treasury->settlement_status = $nextStatus;
            $treasury->save();
        }

        if ($nextStatus === EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT
            || $nextStatus === EventTreasury::STATUS_SETTLED) {
            $releaseSummary = $this->collaboratorSplitService->autoReleaseEligibleEarnings($eventModel, $now);
            if (($releaseSummary['released_count'] ?? 0) > 0) {
                $treasury = $treasury->fresh() ?: $treasury;
                $finalStatus = $this->determineSettlementStatus($treasury, $eventModel, $settings, $now);
                if ($treasury->settlement_status !== $finalStatus) {
                    $treasury->settlement_status = $finalStatus;
                    $treasury->save();
                }
            }
        }

        return $treasury->fresh();
    }

    public function settlementSnapshot(
        EventTreasury|Event|int|null $subject,
        ?Carbon $now = null
    ): ?array {
        if (!$this->supportsTreasury()) {
            $eventModel = $subject instanceof EventTreasury
                ? ($subject->relationLoaded('event')
                    ? $subject->getRelation('event')
                    : ($subject->event_id ? Event::query()->find($subject->event_id) : null))
                : ($subject instanceof Event
                    ? $subject
                    : ($subject ? Event::query()->find($subject) : null));

            if (!$eventModel) {
                return null;
            }

            $settings = $this->supportsSettlementSettings()
                ? $this->ensureSettlementSettings($eventModel)
                : null;
            $now = $now ?: now();
            $eventEndedAt = $this->resolveEventEndedAt($eventModel);
            $eventCompleted = $eventEndedAt ? $now->greaterThanOrEqualTo($eventEndedAt) : false;

            return [
                'status' => $eventCompleted ? EventTreasury::STATUS_SETTLED : EventTreasury::STATUS_COLLECTING,
                'event_completed' => $eventCompleted,
                'event_ended_at' => $eventEndedAt?->toIso8601String(),
                'hold_until' => null,
                'remaining_hold_hours' => null,
                'admin_release_approved_at' => null,
                'admin_release_approved_by_admin_id' => null,
                'requires_admin_approval' => (bool) ($settings?->require_admin_approval ?? false),
                'needs_admin_approval' => (bool) ($settings?->require_admin_approval ?? false),
                'auto_payout_enabled' => (bool) ($settings?->auto_release_owner_share ?? false),
                'gross_collected' => 0.0,
                'refunded_amount' => 0.0,
                'net_collected' => 0.0,
                'platform_fee_total' => 0.0,
                'reserved_for_owner' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'released_to_wallet' => 0.0,
                'available_for_settlement' => 0.0,
                'claimable_amount' => 0.0,
                'can_release_now' => false,
            ];
        }

        [$treasury, $eventModel] = $this->resolveTreasuryContext($subject);

        if (!$eventModel) {
            return null;
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        $now = $now ?: now();

        if ($treasury) {
            $treasury = $this->refreshSettlementState($treasury, $now) ?: $treasury;
        }

        $eventEndedAt = $this->resolveEventEndedAt($eventModel);
        $eventCompleted = $eventEndedAt ? $now->greaterThanOrEqualTo($eventEndedAt) : false;
        $holdUntil = $treasury?->hold_until;
        $remainingHoldHours = null;

        if ($holdUntil instanceof Carbon && $holdUntil->greaterThan($now)) {
            $remainingHoldHours = (int) ceil($now->diffInMinutes($holdUntil) / 60);
        }

        $claimableAmount = $treasury?->claimable_amount ?? 0.0;
        $status = $treasury?->settlement_status
            ?? ($eventCompleted ? EventTreasury::STATUS_SETTLED : EventTreasury::STATUS_COLLECTING);

        return [
            'status' => $status,
            'event_completed' => $eventCompleted,
            'event_ended_at' => $eventEndedAt?->toIso8601String(),
            'hold_until' => $holdUntil?->toIso8601String(),
            'remaining_hold_hours' => $remainingHoldHours,
            'admin_release_approved_at' => $treasury?->admin_release_approved_at?->toIso8601String(),
            'admin_release_approved_by_admin_id' => $treasury?->admin_release_approved_by_admin_id,
            'requires_admin_approval' => (bool) ($settings?->require_admin_approval ?? false),
            'needs_admin_approval' => (bool) ($settings?->require_admin_approval ?? false)
                && $treasury?->admin_release_approved_at === null,
            'auto_payout_enabled' => (bool) ($treasury?->auto_payout_enabled ?? $this->shouldAutoPayout($settings)),
            'gross_collected' => round((float) ($treasury?->gross_collected ?? 0), 2),
            'refunded_amount' => round((float) ($treasury?->refunded_amount ?? 0), 2),
            'net_collected' => round(max(0, (float) ($treasury?->gross_collected ?? 0) - (float) ($treasury?->refunded_amount ?? 0)), 2),
            'platform_fee_total' => round((float) ($treasury?->platform_fee_total ?? 0), 2),
            'reserved_for_owner' => round((float) ($treasury?->reserved_for_owner ?? 0), 2),
            'reserved_for_collaborators' => round((float) ($treasury?->reserved_for_collaborators ?? 0), 2),
            'released_to_wallet' => round((float) ($treasury?->released_to_wallet ?? 0), 2),
            'available_for_settlement' => round((float) ($treasury?->available_for_settlement ?? 0), 2),
            'claimable_amount' => round((float) $claimableAmount, 2),
            'can_release_now' => $status === EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT && $claimableAmount > 0,
        ];
    }

    public function buildSettlementReportData(
        EventTreasury|Event|int|null $subject,
        ?Carbon $now = null,
        int $timelineLimit = 12
    ): ?array {
        if (!$this->supportsTreasury()) {
            return null;
        }

        [$treasury, $eventModel] = $this->resolveTreasuryContext($subject);
        if (!$eventModel) {
            return null;
        }

        $snapshot = $this->settlementSnapshot($treasury ?: $eventModel, $now) ?? [];
        $collaboratorReconciliation = $this->collaboratorSplitService->supportsCollaboratorEconomy()
            ? $this->collaboratorSplitService->buildEventReconciliation($eventModel, $now)
            : [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'claimable_amount' => 0.0,
                'pending_amount' => 0.0,
                'claimed_amount' => 0.0,
                'unreleased_amount' => 0.0,
                'released_to_wallet' => 0.0,
                'basis_breakdown' => [],
                'configured_release_mode_breakdown' => [],
                'effective_release_mode_breakdown' => [],
                'split_allocations' => [],
            ];
        $rawEntries = collect();

        if ($treasury) {
            $rawEntries = EventFinancialEntry::query()
                ->where('treasury_id', $treasury->id)
                ->orderByDesc('occurred_at')
                ->limit(max(1, $timelineLimit))
                ->get();
        }

        $timelineEntries = $rawEntries
            ->map(fn (EventFinancialEntry $entry) => $this->serializeSettlementTimelineEntry($entry))
            ->values()
            ->all();

        $grossCollected = round((float) ($snapshot['gross_collected'] ?? 0), 2);
        $refundedAmount = round((float) ($snapshot['refunded_amount'] ?? 0), 2);
        $collectedAfterRefunds = round(max(0, $grossCollected - $refundedAmount), 2);
        $platformFeeTotal = round((float) ($snapshot['platform_fee_total'] ?? 0), 2);
        $netAfterPlatformFees = round(max(0, $collectedAfterRefunds - $platformFeeTotal), 2);
        $availableForSettlement = round((float) ($snapshot['available_for_settlement'] ?? 0), 2);
        $reservedForCollaborators = round((float) ($snapshot['reserved_for_collaborators'] ?? 0), 2);
        $releasedToWallet = round((float) ($snapshot['released_to_wallet'] ?? 0), 2);
        $ownerReservedUnreleased = round(max(0, $availableForSettlement - $reservedForCollaborators - $releasedToWallet), 2);
        $claimableAmount = round((float) ($snapshot['claimable_amount'] ?? 0), 2);
        $releasableNow = (bool) ($snapshot['can_release_now'] ?? false) ? $claimableAmount : 0.0;
        $blockedReleaseAmount = round(max(0, $ownerReservedUnreleased - $releasableNow), 2);
        $collaboratorClaimableAmount = round((float) ($collaboratorReconciliation['claimable_amount'] ?? 0), 2);
        $collaboratorPendingAmount = round((float) ($collaboratorReconciliation['pending_amount'] ?? 0), 2);
        $collaboratorClaimedAmount = round((float) ($collaboratorReconciliation['claimed_amount'] ?? 0), 2);
        $collaboratorReleasedToWallet = round((float) ($collaboratorReconciliation['released_to_wallet'] ?? 0), 2);
        $ownerReleasedToWallet = round(max(0, $releasedToWallet - $collaboratorReleasedToWallet), 2);
        $totalUnreleasedAmount = round(max(0, $availableForSettlement - $releasedToWallet), 2);
        $unreleasedBalanceDelta = round($totalUnreleasedAmount - ($reservedForCollaborators + $ownerReservedUnreleased), 2);
        $blockReason = $this->resolveSettlementBlockReason($snapshot);

        return [
            'snapshot' => $snapshot,
            'reconciliation' => [
                'gross_collected' => $grossCollected,
                'refunded_amount' => $refundedAmount,
                'collected_after_refunds' => $collectedAfterRefunds,
                'platform_fee_total' => $platformFeeTotal,
                'net_after_platform_fees' => $netAfterPlatformFees,
                'available_for_settlement' => $availableForSettlement,
                'reserved_for_collaborators' => $reservedForCollaborators,
                'owner_reserved_unreleased' => $ownerReservedUnreleased,
                'released_to_wallet' => $releasedToWallet,
                'owner_released_to_wallet' => $ownerReleasedToWallet,
                'collaborator_released_to_wallet' => $collaboratorReleasedToWallet,
                'owner_claimable_amount' => $claimableAmount,
                'claimable_amount' => $claimableAmount,
                'collaborator_claimable_amount' => $collaboratorClaimableAmount,
                'collaborator_pending_amount' => $collaboratorPendingAmount,
                'collaborator_claimed_amount' => $collaboratorClaimedAmount,
                'total_unreleased_amount' => $totalUnreleasedAmount,
                'unreleased_balance_delta' => $unreleasedBalanceDelta,
                'releasable_now' => round($releasableNow, 2),
                'blocked_release_amount' => $blockedReleaseAmount,
                'block_reason' => $blockReason['key'],
                'block_reason_label' => $blockReason['label'],
                'can_release_now' => (bool) ($snapshot['can_release_now'] ?? false),
            ],
            'collaborator_reconciliation' => $collaboratorReconciliation,
            'timeline_entries' => $timelineEntries,
        ];
    }

    public function claimOwnerShareToWallet(
        Event|int|null $event,
        ?Carbon $now = null,
        bool $syncLegacyMirror = true,
        array $entryMetadata = []
    ): array {
        if (!$this->supportsTreasury()) {
            throw new \RuntimeException('Event treasury is not available in this environment.');
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            throw new \RuntimeException('Event not found for treasury claim.');
        }

        $settlement = resolveSettlementProfessionalTarget($eventModel);
        if (!in_array($settlement['actor_type'], ['organizer', 'venue'], true)) {
            throw new \RuntimeException('This event does not have a professional owner to receive treasury funds.');
        }

        $now = $now ?: now();

        return DB::transaction(function () use ($eventModel, $settlement, $now, $syncLegacyMirror, $entryMetadata) {
            $treasury = EventTreasury::query()
                ->where('event_id', $eventModel->id)
                ->lockForUpdate()
                ->first();

            if (!$treasury) {
                throw new \RuntimeException('No treasury was found for this event.');
            }

            if ($this->collaboratorSplitService->supportsCollaboratorEconomy()) {
                $this->collaboratorSplitService->syncEventCollaboratorEarnings($eventModel, $now);
                $treasury = EventTreasury::query()
                    ->where('event_id', $eventModel->id)
                    ->lockForUpdate()
                    ->first();
            }

            $settings = $this->ensureSettlementSettings($eventModel);
            $treasury->settlement_status = $this->determineSettlementStatus($treasury, $eventModel, $settings, $now);
            $treasury->save();

            $claimableAmount = $treasury->claimable_amount;

            if ($treasury->settlement_status !== EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT || $claimableAmount <= 0) {
                throw new \RuntimeException('This event is not ready to release funds yet.');
            }

            $idempotencyKey = implode('_', [
                'event_treasury_claim',
                $eventModel->id,
                (int) round(((float) $treasury->released_to_wallet) * 100),
                (int) round(((float) $treasury->available_for_settlement) * 100),
            ]);

            $existingEntry = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existingEntry) {
                $existingBalanceTransaction = IdentityBalanceTransaction::query()
                    ->where('reference_type', 'event_treasury_release')
                    ->where('reference_id', $idempotencyKey)
                    ->first();

                return [
                    'treasury' => $treasury->fresh(),
                    'entry' => $existingEntry,
                    'balance_transaction' => $existingBalanceTransaction,
                    'claimed_amount' => round((float) data_get($existingEntry, 'metadata.claimed_amount', $claimableAmount), 2),
                ];
            }

            $balanceMutation = match ($settlement['actor_type']) {
                'organizer' => $this->professionalBalanceService->creditOrganizerBalance(
                    $settlement['organizer_identity_id'],
                    $settlement['organizer_id'],
                    $claimableAmount,
                    $syncLegacyMirror
                ),
                'venue' => $this->professionalBalanceService->creditVenueBalance(
                    $settlement['venue_identity_id'],
                    $settlement['venue_id'],
                    $claimableAmount,
                    $syncLegacyMirror
                ),
                default => throw new \RuntimeException('Unsupported professional owner type for treasury claim.'),
            };

            $ownerIdentityId = $settlement['organizer_identity_id'] ?? $settlement['venue_identity_id'];
            $balanceTransaction = IdentityBalanceTransaction::query()->create([
                'identity_id' => $ownerIdentityId,
                'type' => 'credit',
                'amount' => $claimableAmount,
                'description' => 'Event treasury claim',
                'reference_type' => 'event_treasury_release',
                'reference_id' => $idempotencyKey,
                'balance_before' => $balanceMutation['pre_balance'] ?? 0,
                'balance_after' => $balanceMutation['after_balance'] ?? 0,
                'meta' => [
                    'event_id' => $eventModel->id,
                    'actor_type' => $settlement['actor_type'],
                    'sync_legacy_mirror' => $syncLegacyMirror,
                    'release_source' => $entryMetadata['release_source'] ?? 'owner_claim',
                    'approved_by_admin_id' => $entryMetadata['approved_by_admin_id'] ?? null,
                ],
            ]);

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $eventModel->id,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
                'reference_type' => 'identity_balance_transaction',
                'reference_id' => (string) $balanceTransaction->id,
                'owner_identity_id' => $ownerIdentityId,
                'owner_identity_type' => $settlement['actor_type'],
                'organizer_id' => $settlement['organizer_id'],
                'venue_id' => $settlement['venue_id'],
                'gross_amount' => 0,
                'fee_amount' => 0,
                'net_amount' => -$claimableAmount,
                'currency' => 'DOP',
                'status' => 'released',
                'metadata' => array_merge([
                    'balance_before' => $balanceMutation['pre_balance'] ?? 0,
                    'balance_after' => $balanceMutation['after_balance'] ?? 0,
                    'claimed_amount' => round($claimableAmount, 2),
                    'release_source' => $entryMetadata['release_source'] ?? 'owner_claim',
                ], $entryMetadata),
                'occurred_at' => $now,
            ]);

            $treasury->released_to_wallet = round((float) $treasury->released_to_wallet + $claimableAmount, 2);
            $treasury->save();
            $treasury = $this->refreshSettlementState($treasury, $now) ?: $treasury->fresh();

            return [
                'treasury' => $treasury,
                'entry' => $entry,
                'balance_transaction' => $balanceTransaction,
                'claimed_amount' => round($claimableAmount, 2),
            ];
        });
    }

    public function approveOwnerRelease(
        Event|int|null $event,
        int $adminId,
        ?Carbon $now = null
    ): array {
        if (!$this->supportsTreasury()) {
            throw new \RuntimeException('Event treasury is not available in this environment.');
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            throw new \RuntimeException('Event not found for settlement approval.');
        }

        $now = $now ?: now();

        return DB::transaction(function () use ($eventModel, $adminId, $now) {
            $treasury = EventTreasury::query()
                ->where('event_id', $eventModel->id)
                ->lockForUpdate()
                ->first();

            if (!$treasury) {
                throw new \RuntimeException('No treasury was found for this event.');
            }

            $settings = $this->ensureSettlementSettings($eventModel);

            if (!$settings?->require_admin_approval) {
                $treasury = $this->refreshSettlementState($treasury, $now) ?: $treasury->fresh();

                return [
                    'treasury' => $treasury,
                    'entry' => null,
                    'already_approved' => false,
                ];
            }

            if ($treasury->admin_release_approved_at !== null) {
                $treasury = $this->refreshSettlementState($treasury, $now) ?: $treasury->fresh();
                $entry = EventFinancialEntry::query()
                    ->where('event_id', $eventModel->id)
                    ->where('entry_type', EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED)
                    ->latest('occurred_at')
                    ->first();

                return [
                    'treasury' => $treasury,
                    'entry' => $entry,
                    'already_approved' => true,
                ];
            }

            $treasury->admin_release_approved_at = $now;
            $treasury->admin_release_approved_by_admin_id = $adminId;
            $treasury->save();

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $eventModel->id,
                'idempotency_key' => sprintf(
                    'event_treasury_admin_approval_%d_%d_%d',
                    $eventModel->id,
                    (int) round((float) $treasury->released_to_wallet * 100),
                    $now->getTimestamp()
                ),
                'entry_type' => EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED,
                'reference_type' => 'admin',
                'reference_id' => (string) $adminId,
                'owner_identity_id' => $eventModel->owner_identity_id ?: $eventModel->venue_identity_id,
                'owner_identity_type' => $eventModel->owner_identity_id ? 'organizer' : 'venue',
                'organizer_id' => $eventModel->organizer_id,
                'venue_id' => $eventModel->venue_id,
                'gross_amount' => 0,
                'fee_amount' => 0,
                'net_amount' => 0,
                'currency' => 'DOP',
                'status' => 'approved',
                'metadata' => [
                    'approved_by_admin_id' => $adminId,
                    'previous_status' => $treasury->settlement_status,
                ],
                'occurred_at' => $now,
            ]);

            $treasury = $this->refreshSettlementState($treasury, $now) ?: $treasury->fresh();

            return [
                'treasury' => $treasury,
                'entry' => $entry,
                'already_approved' => false,
            ];
        });
    }

    public function releaseOwnerShareByAdmin(
        Event|int|null $event,
        int $adminId,
        ?Carbon $now = null,
        bool $syncLegacyMirror = true
    ): array {
        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            throw new \RuntimeException('Event not found for admin settlement release.');
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        $now = $now ?: now();
        $approval = null;

        if ($settings?->require_admin_approval) {
            $approval = $this->approveOwnerRelease($eventModel, $adminId, $now);
        }

        $treasury = $this->refreshSettlementState($eventModel, $now);
        if (!$treasury) {
            throw new \RuntimeException('No treasury was found for this event.');
        }

        if ($treasury->settlement_status !== EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT || $treasury->claimable_amount <= 0) {
            throw new \RuntimeException('This event is not ready to release funds yet.');
        }

        $claim = $this->claimOwnerShareToWallet(
            $eventModel,
            $now,
            $syncLegacyMirror,
            [
                'release_source' => 'admin_release',
                'approved_by_admin_id' => $adminId,
            ]
        );

        return [
            'approval' => $approval,
            'claim' => $claim,
            'treasury' => data_get($claim, 'treasury'),
        ];
    }

    public function ensureSettlementSettings(Event|int|null $event): ?EventSettlementSetting
    {
        if (!$this->supportsSettlementSettings()) {
            return null;
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return null;
        }

        return EventSettlementSetting::query()->firstOrCreate(
            ['event_id' => $eventModel->id],
            EventSettlementSetting::defaultAttributes()
        );
    }

    public function upsertSettlementSettings(Event|int|null $event, array $attributes = []): ?EventSettlementSetting
    {
        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel || !$this->supportsSettlementSettings()) {
            return null;
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        if (!$settings) {
            return null;
        }

        $settings->fill($attributes);
        $settings->save();

        $this->syncTreasuryWithSettlementSettings($eventModel, $settings);

        return $settings->fresh();
    }

    public function syncTreasuryWithSettlementSettings(
        Event|int|null $event,
        ?EventSettlementSetting $settings = null
    ): ?EventTreasury {
        if (!$this->supportsTreasury()) {
            return null;
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return null;
        }

        $treasury = EventTreasury::query()->where('event_id', $eventModel->id)->first();
        if (!$treasury) {
            return null;
        }

        $settings = $settings ?: $this->ensureSettlementSettings($eventModel);

        $treasury->hold_until = $this->resolveDefaultHoldUntil($eventModel, $settings);
        $treasury->auto_payout_enabled = $this->shouldAutoPayout($settings);
        $treasury->auto_payout_delay_hours = $settings?->grace_period_hours;
        if (!($settings?->require_admin_approval ?? false)) {
            $treasury->admin_release_approved_at = null;
            $treasury->admin_release_approved_by_admin_id = null;
        }
        $treasury->save();

        return $this->refreshSettlementState($treasury);
    }

    public function markSettlementHold(
        Event|int|null $event,
        string $reason = 'manual_hold',
        ?Carbon $holdUntil = null,
        array $metadata = [],
        ?string $idempotencyKey = null
    ): ?EventFinancialEntry {
        if (!$this->supportsTreasury()) {
            return null;
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return null;
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        $treasury = $this->ensureTreasury($eventModel);
        if (!$treasury) {
            return null;
        }

        $resolvedHoldUntil = $holdUntil;
        if (!$resolvedHoldUntil) {
            $hours = max(1, (int) ($settings?->refund_window_hours ?? EventSettlementSetting::DEFAULT_REFUND_WINDOW_HOURS));
            $resolvedHoldUntil = now()->addHours($hours);
        }

        $idempotencyKey = $idempotencyKey ?: implode('_', [
            'event_settlement_hold',
            $eventModel->id,
            $reason,
            md5(json_encode($metadata)),
        ]);

        return DB::transaction(function () use (
            $eventModel,
            $treasury,
            $resolvedHoldUntil,
            $reason,
            $metadata,
            $idempotencyKey
        ) {
            $existing = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existing) {
                return $existing;
            }

            if ($treasury->hold_until === null || $resolvedHoldUntil->greaterThan($treasury->hold_until)) {
                $treasury->hold_until = $resolvedHoldUntil;
            }
            $treasury->admin_release_approved_at = null;
            $treasury->admin_release_approved_by_admin_id = null;
            $treasury->settlement_status = EventTreasury::STATUS_SETTLEMENT_HOLD;
            $treasury->save();

            return EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $eventModel->id,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED,
                'reference_type' => 'event',
                'reference_id' => (string) $eventModel->id,
                'gross_amount' => 0,
                'fee_amount' => 0,
                'net_amount' => 0,
                'currency' => 'DOP',
                'status' => 'hold',
                'metadata' => array_merge($metadata, [
                    'reason' => $reason,
                    'hold_until' => $resolvedHoldUntil->toIso8601String(),
                ]),
                'occurred_at' => now(),
            ]);
        });
    }

    public function openRefundWindowForScheduleChange(
        Event|int|null $event,
        array $metadata = []
    ): ?EventFinancialEntry {
        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return null;
        }

        $settings = $this->ensureSettlementSettings($eventModel);
        $hours = max(1, (int) ($settings?->refund_window_hours ?? EventSettlementSetting::DEFAULT_REFUND_WINDOW_HOURS));
        $holdUntil = now()->addHours($hours);
        $idempotencyKey = implode('_', [
            'event_refund_window',
            $eventModel->id,
            md5(json_encode($metadata)),
        ]);

        $entry = $this->markSettlementHold(
            $eventModel,
            'refund_window_for_schedule_change',
            $holdUntil,
            array_merge($metadata, [
                'refund_window_hours' => $hours,
            ]),
            $idempotencyKey
        );

        if (!$entry) {
            return null;
        }

        if ($entry->entry_type !== EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED) {
            $entry->entry_type = EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED;
            $entry->save();
        }

        return $entry->fresh();
    }

    public function syncReservationRevenue(TicketReservation $reservation): void
    {
        if (!$this->shouldReserveReservationRevenue($reservation)) {
            return;
        }

        $reservation->loadMissing(['event', 'payments']);
        $settlement = resolveSettlementProfessionalTarget($reservation);

        foreach ($reservation->payments as $payment) {
            if (!$payment instanceof ReservationPayment || $payment->status !== 'completed') {
                continue;
            }

            $this->reserveReservationPayment($reservation, $payment, $settlement);
        }
    }

    public function syncReservationRefunds(
        TicketReservation $reservation,
        ?Collection $refundRows = null
    ): void {
        if (!$this->shouldReserveReservationRevenue($reservation)) {
            return;
        }

        $reservation->loadMissing(['event', 'payments']);
        $settlement = resolveSettlementProfessionalTarget($reservation);
        $refundRows = $refundRows ?: $reservation->payments;

        foreach ($refundRows as $payment) {
            if (
                !$payment instanceof ReservationPayment
                || $payment->status !== 'reversed'
                || !str_ends_with((string) $payment->source_type, '_refund')
            ) {
                continue;
            }

            $this->applyReservationRefund($reservation, $payment, $settlement);
        }
    }

    public function reserveOwnerShare(mixed $booking): ?EventFinancialEntry
    {
        if (!$this->shouldReserveOwnerShare($booking)) {
            return null;
        }

        $eventId = (int) data_get($booking, 'event_id', 0);
        $bookingId = data_get($booking, 'id');
        $idempotencyKey = 'event_treasury_owner_share_booking_' . $bookingId;
        $event = $this->resolveEvent($booking, $eventId);
        $settlement = resolveSettlementProfessionalTarget($booking);

        $grossAmount = round((float) data_get($booking, 'price', 0), 2);
        $feeAmount = round((float) data_get($booking, 'commission', 0), 2);
        $netAmount = round(max(0, $grossAmount - $feeAmount), 2);

        return DB::transaction(function () use (
            $event,
            $eventId,
            $booking,
            $bookingId,
            $idempotencyKey,
            $settlement,
            $grossAmount,
            $feeAmount,
            $netAmount
        ) {
            $existing = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existing) {
                return $existing;
            }

            $treasury = $this->ensureTreasury($event ?: $eventId);
            if (!$treasury) {
                return null;
            }

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $eventId,
                'booking_id' => $bookingId,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RESERVED,
                'reference_type' => 'booking',
                'reference_id' => isset($bookingId) ? (string) $bookingId : null,
                'actor_customer_id' => data_get($booking, 'customer_id'),
                'owner_identity_id' => $settlement['organizer_identity_id'] ?? $settlement['venue_identity_id'],
                'owner_identity_type' => $settlement['actor_type'],
                'organizer_id' => $settlement['organizer_id'],
                'venue_id' => $settlement['venue_id'],
                'gross_amount' => $grossAmount,
                'fee_amount' => $feeAmount,
                'net_amount' => $netAmount,
                'currency' => data_get($booking, 'currencyText', 'DOP'),
                'status' => 'reserved',
                'metadata' => [
                    'ticket_id' => data_get($booking, 'ticket_id'),
                    'payment_status' => data_get($booking, 'paymentStatus'),
                    'acquisition_source' => data_get($booking, 'acquisition_source'),
                    'organizer_identity_id' => $settlement['organizer_identity_id'],
                    'venue_identity_id' => $settlement['venue_identity_id'],
                ],
                'occurred_at' => now(),
            ]);

            $treasury->gross_collected = round((float) $treasury->gross_collected + $grossAmount, 2);
            $treasury->platform_fee_total = round((float) $treasury->platform_fee_total + $feeAmount, 2);
            $treasury->reserved_for_owner = round((float) $treasury->reserved_for_owner + $netAmount, 2);
            $treasury->available_for_settlement = round((float) $treasury->available_for_settlement + $netAmount, 2);
            $treasury->settlement_status = $treasury->settlement_status ?: EventTreasury::STATUS_COLLECTING;
            if (!$treasury->hold_until) {
                $settings = $this->ensureSettlementSettings($event);
                $treasury->hold_until = $this->resolveDefaultHoldUntil($event, $settings);
            }
            $treasury->save();

            $this->refreshSettlementState($treasury);

            return $entry;
        });
    }

    private function resolveEvent(mixed $booking, int $eventId): ?Event
    {
        if ($booking instanceof Booking && $booking->relationLoaded('evnt')) {
            return $booking->getRelation('evnt');
        }

        if (is_object($booking) && isset($booking->evnt) && $booking->evnt instanceof Event) {
            return $booking->evnt;
        }

        return $eventId > 0 ? Event::query()->find($eventId) : null;
    }

    private function reserveReservationPayment(
        TicketReservation $reservation,
        ReservationPayment $payment,
        array $settlement
    ): ?EventFinancialEntry {
        $treasury = $this->ensureTreasury($reservation->event_id);
        if (!$treasury) {
            return null;
        }

        $idempotencyKey = 'event_treasury_reservation_payment_' . $payment->id;

        return DB::transaction(function () use ($reservation, $payment, $settlement, $treasury, $idempotencyKey) {
            $existing = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existing) {
                return $existing;
            }

            $grossAmount = round((float) $payment->amount, 2);
            $processingFee = round((float) $payment->fee_amount, 2);
            $commissionQuote = $this->feeEngine->calculate(
                FeeEngine::OP_PRIMARY_TICKET_SALE,
                $grossAmount,
                [
                    'fee_base_amount' => round($grossAmount + $processingFee, 2),
                    'currency' => 'DOP',
                ]
            );
            $platformFee = round((float) ($commissionQuote['fee_amount'] ?? 0), 2);
            $netAmount = round(max(0, $grossAmount - $platformFee), 2);

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $reservation->event_id,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_RESERVATION_PAYMENT_RESERVED,
                'reference_type' => 'reservation_payment',
                'reference_id' => (string) $payment->id,
                'actor_customer_id' => $reservation->customer_id,
                'owner_identity_id' => $settlement['organizer_identity_id'] ?? $settlement['venue_identity_id'],
                'owner_identity_type' => $settlement['actor_type'],
                'organizer_id' => $settlement['organizer_id'],
                'venue_id' => $settlement['venue_id'],
                'gross_amount' => $grossAmount,
                'fee_amount' => $platformFee,
                'net_amount' => $netAmount,
                'currency' => 'DOP',
                'status' => 'reserved',
                'metadata' => [
                    'reservation_id' => $reservation->id,
                    'payment_group' => $payment->payment_group,
                    'source_type' => $payment->source_type,
                    'processing_fee_amount' => $processingFee,
                    'reference_type' => $payment->reference_type,
                    'reference_id' => $payment->reference_id,
                    'ticket_id' => $reservation->ticket_id,
                    'reservation_status' => $reservation->status,
                ],
                'occurred_at' => $payment->paid_at ?: now(),
            ]);

            $treasury->gross_collected = round((float) $treasury->gross_collected + $grossAmount, 2);
            $treasury->platform_fee_total = round((float) $treasury->platform_fee_total + $platformFee, 2);
            $treasury->reserved_for_owner = round((float) $treasury->reserved_for_owner + $netAmount, 2);
            $treasury->available_for_settlement = round((float) $treasury->available_for_settlement + $netAmount, 2);
            $treasury->save();

            $this->refreshSettlementState($treasury);

            return $entry;
        });
    }

    private function applyReservationRefund(
        TicketReservation $reservation,
        ReservationPayment $payment,
        array $settlement
    ): ?EventFinancialEntry {
        $treasury = $this->ensureTreasury($reservation->event_id);
        if (!$treasury) {
            return null;
        }

        $idempotencyKey = 'event_treasury_reservation_refund_' . $payment->id;

        return DB::transaction(function () use ($reservation, $payment, $settlement, $treasury, $idempotencyKey) {
            $existing = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existing) {
                return $existing;
            }

            $grossRefund = round(abs((float) $payment->amount), 2);
            $processingFeeRefund = round(abs((float) $payment->fee_amount), 2);
            $commissionQuote = $this->feeEngine->calculate(
                FeeEngine::OP_PRIMARY_TICKET_SALE,
                $grossRefund,
                [
                    'fee_base_amount' => round($grossRefund + $processingFeeRefund, 2),
                    'currency' => 'DOP',
                ]
            );
            $platformFeeReversal = round((float) ($commissionQuote['fee_amount'] ?? 0), 2);
            $netReduction = round(max(0, $grossRefund - $platformFeeReversal), 2);

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $reservation->event_id,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED,
                'reference_type' => 'reservation_payment_refund',
                'reference_id' => (string) $payment->id,
                'actor_customer_id' => $reservation->customer_id,
                'owner_identity_id' => $settlement['organizer_identity_id'] ?? $settlement['venue_identity_id'],
                'owner_identity_type' => $settlement['actor_type'],
                'organizer_id' => $settlement['organizer_id'],
                'venue_id' => $settlement['venue_id'],
                'gross_amount' => -$grossRefund,
                'fee_amount' => -$platformFeeReversal,
                'net_amount' => -$netReduction,
                'currency' => 'DOP',
                'status' => 'refunded',
                'metadata' => [
                    'reservation_id' => $reservation->id,
                    'payment_group' => $payment->payment_group,
                    'source_type' => $payment->source_type,
                    'processing_fee_refunded' => $processingFeeRefund,
                    'reference_type' => $payment->reference_type,
                    'reference_id' => $payment->reference_id,
                    'ticket_id' => $reservation->ticket_id,
                    'reservation_status' => $reservation->status,
                ],
                'occurred_at' => $payment->paid_at ?: now(),
            ]);

            $treasury->refunded_amount = round((float) $treasury->refunded_amount + $grossRefund, 2);
            $treasury->platform_fee_total = round(max(0, (float) $treasury->platform_fee_total - $platformFeeReversal), 2);
            $treasury->reserved_for_owner = round(max(0, (float) $treasury->reserved_for_owner - $netReduction), 2);
            $treasury->available_for_settlement = round(max(0, (float) $treasury->available_for_settlement - $netReduction), 2);
            $treasury->settlement_status = EventTreasury::STATUS_SETTLEMENT_HOLD;
            $treasury->save();

            $this->refreshSettlementState($treasury);

            return $entry;
        });
    }

    private function resolveTreasuryContext(EventTreasury|Event|int|null $subject): array
    {
        if ($subject instanceof EventTreasury) {
            $event = $subject->relationLoaded('event')
                ? $subject->getRelation('event')
                : ($subject->event_id ? Event::query()->find($subject->event_id) : null);

            return [$subject, $event];
        }

        $eventModel = $subject instanceof Event
            ? $subject
            : ($subject ? Event::query()->find($subject) : null);

        if (!$eventModel) {
            return [null, null];
        }

        $treasury = $eventModel->relationLoaded('treasury')
            ? $eventModel->getRelation('treasury')
            : EventTreasury::query()->where('event_id', $eventModel->id)->first();

        return [$treasury, $eventModel];
    }

    private function serializeSettlementTimelineEntry(EventFinancialEntry $entry): array
    {
        [$entryLabel, $entrySummary, $tone] = match ($entry->entry_type) {
            EventFinancialEntry::TYPE_OWNER_SHARE_RESERVED => ['Owner share reserved', 'Primary sale revenue reserved for the professional owner.', 'primary'],
            EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET => ['Owner share released', 'Owner treasury balance was credited to the professional wallet.', 'success'],
            EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RESERVED => ['Collaborator share reserved', 'Part of the event treasury was reserved for collaborators.', 'warning'],
            EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET => ['Collaborator payout released', 'Collaborator earning was credited to a professional wallet.', 'success'],
            EventFinancialEntry::TYPE_RESERVATION_PAYMENT_RESERVED => ['Reservation revenue reserved', 'A reservation payment increased the event treasury.', 'primary'],
            EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED => ['Reservation refund processed', 'A reservation refund reduced the event treasury.', 'danger'],
            EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED => ['Settlement hold opened', 'The event treasury was explicitly blocked from payout.', 'danger'],
            EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED => ['Refund window opened', 'Schedule changes or refund rules opened a protected hold window.', 'warning'],
            EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED => ['Settlement release approved', 'Admin approved owner release for this treasury.', 'warning'],
            default => [
                str($entry->entry_type)->replace('_', ' ')->title()->toString(),
                'Treasury activity recorded for this event.',
                'primary',
            ],
        };

        return [
            'entry_type' => $entry->entry_type,
            'entry_label' => $entryLabel,
            'entry_summary' => $entrySummary,
            'status' => $entry->status,
            'status_label' => str((string) $entry->status)->replace('_', ' ')->title()->toString(),
            'tone' => $tone,
            'gross_amount' => round((float) $entry->gross_amount, 2),
            'fee_amount' => round((float) $entry->fee_amount, 2),
            'net_amount' => round((float) $entry->net_amount, 2),
            'reference_type' => $entry->reference_type,
            'reference_id' => $entry->reference_id,
            'occurred_at' => optional($entry->occurred_at)->format('Y-m-d H:i'),
            'metadata' => (array) $entry->metadata,
        ];
    }

    private function resolveSettlementBlockReason(array $snapshot): array
    {
        if ((bool) ($snapshot['can_release_now'] ?? false)) {
            return ['key' => null, 'label' => null];
        }

        if ((bool) ($snapshot['needs_admin_approval'] ?? false)) {
            return ['key' => 'admin_approval_required', 'label' => 'Admin approval required'];
        }

        return match ($snapshot['status'] ?? null) {
            EventTreasury::STATUS_COLLECTING => ['key' => 'event_not_completed', 'label' => 'Event has not completed yet'],
            EventTreasury::STATUS_AWAITING_SETTLEMENT => ['key' => 'grace_period_active', 'label' => 'Grace period still active'],
            EventTreasury::STATUS_SETTLEMENT_HOLD => ['key' => 'settlement_hold_active', 'label' => 'Settlement hold still active'],
            EventTreasury::STATUS_SETTLED => ['key' => 'already_settled', 'label' => 'Treasury already settled'],
            default => ['key' => 'not_releasable_yet', 'label' => 'Funds are not releasable yet'],
        };
    }

    private function determineSettlementStatus(
        EventTreasury $treasury,
        Event $event,
        ?EventSettlementSetting $settings,
        Carbon $now
    ): string {
        $eventEndedAt = $this->resolveEventEndedAt($event);
        $claimableAmount = $treasury->claimable_amount;
        $requiresAdminApproval = (bool) ($settings?->require_admin_approval ?? false);
        $hasAdminApproval = $treasury->admin_release_approved_at !== null;
        $hasExplicitHold = $treasury->settlement_status === EventTreasury::STATUS_SETTLEMENT_HOLD;

        if ($hasExplicitHold && ($treasury->hold_until === null || $now->lt($treasury->hold_until))) {
            return EventTreasury::STATUS_SETTLEMENT_HOLD;
        }

        if (!$eventEndedAt || $now->lt($eventEndedAt)) {
            return EventTreasury::STATUS_COLLECTING;
        }

        if ($requiresAdminApproval && !$hasAdminApproval) {
            return EventTreasury::STATUS_SETTLEMENT_HOLD;
        }

        if ($hasExplicitHold && $treasury->hold_until instanceof Carbon && $now->greaterThanOrEqualTo($treasury->hold_until)) {
            return $claimableAmount > 0
                ? EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT
                : EventTreasury::STATUS_SETTLED;
        }

        if ($treasury->hold_until instanceof Carbon && $now->lt($treasury->hold_until)) {
            return EventTreasury::STATUS_AWAITING_SETTLEMENT;
        }

        if ($claimableAmount > 0) {
            return EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT;
        }

        return EventTreasury::STATUS_SETTLED;
    }

    private function resolveEventEndedAt(Event $event): ?Carbon
    {
        $rawEnd = $event->end_date_time ?? $event->end_date ?? null;
        if (!$rawEnd) {
            return null;
        }

        try {
            return Carbon::parse($rawEnd);
        } catch (\Throwable) {
            return null;
        }
    }

    private function isReservationConversionBooking(mixed $booking): bool
    {
        return !empty(data_get($booking, 'reservation_id'))
            || data_get($booking, 'acquisition_source') === 'reservation_conversion';
    }

    private function resolveDefaultHoldUntil(
        ?Event $event,
        ?EventSettlementSetting $settings = null
    ): ?Carbon
    {
        if (!$event) {
            return null;
        }

        $settings = $settings ?: $this->ensureSettlementSettings($event);
        if (($settings?->hold_mode ?? EventSettlementSetting::HOLD_MODE_AUTO_AFTER_GRACE_PERIOD)
            === EventSettlementSetting::HOLD_MODE_MANUAL_ADMIN) {
            return null;
        }

        $rawEnd = $event->end_date_time ?? $event->end_date ?? null;
        if (!$rawEnd) {
            return null;
        }

        try {
            return Carbon::parse($rawEnd)->addHours(
                max(1, (int) ($settings?->grace_period_hours ?? EventSettlementSetting::DEFAULT_GRACE_PERIOD_HOURS))
            );
        } catch (\Throwable) {
            return null;
        }
    }

    private function shouldAutoPayout(?EventSettlementSetting $settings): bool
    {
        if (!$settings) {
            return false;
        }

        return $settings->hold_mode === EventSettlementSetting::HOLD_MODE_AUTO_AFTER_GRACE_PERIOD
            && (bool) $settings->auto_release_owner_share;
    }
}
