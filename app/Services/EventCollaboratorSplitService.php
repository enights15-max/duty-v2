<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\EventLineup;
use App\Models\EventCollaboratorEarning;
use App\Models\EventCollaboratorModeAuditLog;
use App\Models\EventCollaboratorSplit;
use App\Models\EventFinancialEntry;
use App\Models\EventSettlementSetting;
use App\Models\EventTreasury;
use App\Models\Identity;
use App\Models\IdentityBalanceTransaction;
use App\Models\EventRewardInstance;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class EventCollaboratorSplitService
{
    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService,
        private ProfessionalCatalogBridgeService $catalogBridge,
        private CollaborationPayoutNotificationService $collaborationPayoutNotificationService
    ) {
    }

    public function supportsCollaboratorEconomy(): bool
    {
        return Schema::hasTable('event_collaborator_splits')
            && Schema::hasTable('event_collaborator_earnings');
    }

    public function syncEventCollaboratorEarnings(
        Event|int|null $event,
        ?Carbon $now = null
    ): array {
        if (!$this->supportsCollaboratorEconomy()) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => collect(),
                'earnings' => collect(),
            ];
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => collect(),
                'earnings' => collect(),
            ];
        }

        $eventModel->loadMissing([
            'treasury',
            'settlementSettings',
            'collaboratorSplits.identity',
            'collaboratorSplits.earning',
            'collaboratorSplits.modeAuditLogs',
            'lineups.artist',
            'venueIdentity',
            'ownerIdentity',
        ]);

        $treasury = $eventModel->treasury;
        if (!$treasury instanceof EventTreasury) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => collect(),
                'earnings' => collect(),
            ];
        }

        $now = $now ?: now();

        return DB::transaction(function () use ($eventModel, $treasury, $now) {
            /** @var Collection<int, EventCollaboratorSplit> $splits */
            $splits = EventCollaboratorSplit::query()
                ->where('event_id', $eventModel->id)
                ->with(['identity', 'earning'])
                ->orderBy('created_at')
                ->lockForUpdate()
                ->get();

            $treasury = EventTreasury::query()
                ->where('id', $treasury->id)
                ->lockForUpdate()
                ->firstOrFail();

            $distributableAmount = $this->resolveDistributableAmount($treasury);
            $activeStatuses = [
                EventCollaboratorSplit::STATUS_CONFIRMED,
                EventCollaboratorSplit::STATUS_LOCKED,
            ];

            $reservedAmounts = $this->resolveReservedAmounts($splits, $treasury, $distributableAmount);
            $reservedOutstanding = 0.0;
            $claimableCount = 0;
            $earnings = collect();

            foreach ($splits as $split) {
                $reservedAmount = in_array($split->status, $activeStatuses, true)
                    ? (float) ($reservedAmounts[$split->id] ?? 0.0)
                    : 0.0;

                /** @var EventCollaboratorEarning $earning */
                $earning = EventCollaboratorEarning::query()->firstOrNew([
                    'split_id' => $split->id,
                    'identity_id' => $split->identity_id,
                ]);

                $claimedAmount = round((float) ($earning->amount_claimed ?? 0), 2);
                $claimableAmount = round(max(0, $reservedAmount - $claimedAmount), 2);
                $status = $this->resolveEarningStatus(
                    $eventModel,
                    $treasury,
                    $split,
                    $reservedAmount,
                    $claimableAmount,
                    $claimedAmount,
                    $now
                );

                $earning->event_id = $eventModel->id;
                $earning->identity_id = $split->identity_id;
                $earning->identity_type = $split->identity_type;
                $earning->role_type = $split->role_type;
                $earning->amount_reserved = $reservedAmount;
                $earning->status = $status;
                $earning->last_calculated_at = $now;
                $earning->metadata = array_merge((array) $earning->metadata, [
                    'basis' => $split->basis,
                    'split_type' => $split->split_type,
                    'split_value' => round((float) $split->split_value, 4),
                    'release_mode' => $split->release_mode ?: $this->normalizeReleaseMode($split),
                    'effective_release_mode' => $this->resolveEffectiveReleaseMode($split, $eventModel->settlementSettings),
                    'distributable_amount' => $distributableAmount,
                    'basis_amount' => $this->resolveBasisAmount($split->basis, $treasury, $distributableAmount),
                ]);

                if ($status === EventCollaboratorEarning::STATUS_CLAIMABLE && $earning->released_at === null) {
                    $earning->released_at = $now;
                }

                if ($status !== EventCollaboratorEarning::STATUS_CLAIMED && $claimableAmount > 0) {
                    $reservedOutstanding = round($reservedOutstanding + $claimableAmount, 2);
                }

                if ($status === EventCollaboratorEarning::STATUS_CLAIMABLE && $claimableAmount > 0) {
                    $claimableCount++;
                }

                $earning->save();
                $earnings->push($earning->fresh(['identity', 'split']));
            }

            if (round((float) $treasury->reserved_for_collaborators, 2) !== $reservedOutstanding) {
                $treasury->reserved_for_collaborators = $reservedOutstanding;
                $treasury->save();
            }

            return [
                'distributable_amount' => round($distributableAmount, 2),
                'reserved_for_collaborators' => round($reservedOutstanding, 2),
                'claimable_count' => $claimableCount,
                'splits' => $splits->values(),
                'earnings' => $earnings->values(),
            ];
        });
    }

    public function eventSummary(Event|int|null $event): array
    {
        if (!$this->supportsCollaboratorEconomy()) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => [],
                'suggestions' => [],
                'activity' => [],
            ];
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => [],
                'suggestions' => [],
                'activity' => [],
            ];
        }

        $eventModel->loadMissing([
            'treasury',
            'settlementSettings',
            'collaboratorSplits.identity',
            'collaboratorSplits.modeAuditLogs',
            'lineups.artist',
            'venueIdentity',
            'ownerIdentity',
            'information',
        ]);

        if (!$eventModel->treasury instanceof EventTreasury) {
            return [
                'distributable_amount' => 0.0,
                'reserved_for_collaborators' => 0.0,
                'claimable_count' => 0,
                'splits' => $eventModel->collaboratorSplits
                    ->map(fn (EventCollaboratorSplit $split) => $this->serializePendingSplit($eventModel, $split))
                    ->values()
                    ->all(),
                'suggestions' => $this->suggestCollaboratorsForEvent($eventModel),
                'activity' => $this->buildEventActivity($eventModel),
            ];
        }

        $sync = $this->syncEventCollaboratorEarnings($eventModel);
        $serializedSplits = collect($sync['earnings'] ?? [])
            ->map(fn (EventCollaboratorEarning $earning) => $this->serializeEarning($earning))
            ->values();

        if ($serializedSplits->isEmpty() && $eventModel->collaboratorSplits->isNotEmpty()) {
            $serializedSplits = $eventModel->collaboratorSplits
                ->map(fn (EventCollaboratorSplit $split) => $this->serializePendingSplit($eventModel, $split))
                ->values();
        }

        return [
            'distributable_amount' => round((float) ($sync['distributable_amount'] ?? 0), 2),
            'reserved_for_collaborators' => round((float) ($sync['reserved_for_collaborators'] ?? 0), 2),
            'claimable_count' => (int) ($sync['claimable_count'] ?? 0),
            'splits' => $serializedSplits->all(),
            'suggestions' => $this->suggestCollaboratorsForEvent($eventModel),
            'activity' => $this->buildEventActivity($eventModel),
        ];
    }

    public function buildEventReconciliation(Event|int|null $event, ?Carbon $now = null): array
    {
        $empty = [
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

        if (!$this->supportsCollaboratorEconomy()) {
            return $empty;
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return $empty;
        }

        $eventModel->loadMissing([
            'treasury',
            'settlementSettings',
            'collaboratorSplits.identity',
            'collaboratorSplits.earning',
            'collaboratorSplits.modeAuditLogs',
            'information',
        ]);

        if (!$eventModel->treasury instanceof EventTreasury) {
            return $empty;
        }

        $sync = $this->syncEventCollaboratorEarnings($eventModel, $now);
        $earnings = collect($sync['earnings'] ?? [])->values();

        $claimableAmount = 0.0;
        $pendingAmount = 0.0;
        $claimedAmount = 0.0;
        $basisBreakdown = [];
        $configuredReleaseModeBreakdown = [];
        $effectiveReleaseModeBreakdown = [];

        $splitAllocations = $earnings->map(function (EventCollaboratorEarning $earning) use (
            &$claimableAmount,
            &$pendingAmount,
            &$claimedAmount,
            &$basisBreakdown,
            &$configuredReleaseModeBreakdown,
            &$effectiveReleaseModeBreakdown
        ): array {
            $split = $earning->split;
            $basis = (string) data_get($earning->metadata, 'basis', $split?->basis ?: EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE);
            $configuredReleaseMode = (string) data_get(
                $earning->metadata,
                'release_mode',
                $split?->release_mode ?: $this->normalizeReleaseMode($split)
            );
            $effectiveReleaseMode = (string) data_get(
                $earning->metadata,
                'effective_release_mode',
                $this->resolveEffectiveReleaseMode($split, $earning->event?->settlementSettings)
            );

            $reserved = round((float) $earning->amount_reserved, 2);
            $claimed = round((float) $earning->amount_claimed, 2);
            $claimable = round((float) $earning->claimable_amount, 2);
            $unreleased = round(max(0, $reserved - $claimed), 2);
            $basisAmount = round((float) data_get($earning->metadata, 'basis_amount', 0), 2);

            if ($earning->status === EventCollaboratorEarning::STATUS_CLAIMABLE) {
                $claimableAmount = round($claimableAmount + $claimable, 2);
            } elseif (in_array($earning->status, [
                EventCollaboratorEarning::STATUS_PENDING_EVENT_COMPLETION,
                EventCollaboratorEarning::STATUS_PENDING_RELEASE,
            ], true)) {
                $pendingAmount = round($pendingAmount + $unreleased, 2);
            }

            if ($earning->status === EventCollaboratorEarning::STATUS_CLAIMED || $claimed > 0) {
                $claimedAmount = round($claimedAmount + $claimed, 2);
            }

            if (!isset($basisBreakdown[$basis])) {
                $basisBreakdown[$basis] = [
                    'basis' => $basis,
                    'label' => $this->basisLabel($basis),
                    'split_count' => 0,
                    'reserved_amount' => 0.0,
                    'claimable_amount' => 0.0,
                    'claimed_amount' => 0.0,
                    'unreleased_amount' => 0.0,
                    'max_basis_amount' => 0.0,
                ];
            }

            $basisBreakdown[$basis]['split_count']++;
            $basisBreakdown[$basis]['reserved_amount'] = round($basisBreakdown[$basis]['reserved_amount'] + $reserved, 2);
            $basisBreakdown[$basis]['claimable_amount'] = round($basisBreakdown[$basis]['claimable_amount'] + $claimable, 2);
            $basisBreakdown[$basis]['claimed_amount'] = round($basisBreakdown[$basis]['claimed_amount'] + $claimed, 2);
            $basisBreakdown[$basis]['unreleased_amount'] = round($basisBreakdown[$basis]['unreleased_amount'] + $unreleased, 2);
            $basisBreakdown[$basis]['max_basis_amount'] = max($basisBreakdown[$basis]['max_basis_amount'], $basisAmount);

            $this->accumulateReleaseModeBreakdown(
                $configuredReleaseModeBreakdown,
                $configuredReleaseMode,
                $reserved,
                $claimable,
                $claimed,
                $unreleased
            );
            $this->accumulateReleaseModeBreakdown(
                $effectiveReleaseModeBreakdown,
                $effectiveReleaseMode,
                $reserved,
                $claimable,
                $claimed,
                $unreleased
            );

            return [
                'split_id' => (int) $earning->split_id,
                'identity_id' => (int) $earning->identity_id,
                'display_name' => $earning->identity?->display_name,
                'role_type' => $earning->role_type,
                'status' => $earning->status,
                'split_type' => data_get($earning->metadata, 'split_type'),
                'split_value' => round((float) data_get($earning->metadata, 'split_value', 0), 4),
                'basis' => $basis,
                'basis_label' => $this->basisLabel($basis),
                'basis_amount' => $basisAmount,
                'release_mode' => $configuredReleaseMode,
                'release_mode_label' => $this->releaseModeLabel($configuredReleaseMode),
                'effective_release_mode' => $effectiveReleaseMode,
                'effective_release_mode_label' => $this->releaseModeLabel($effectiveReleaseMode),
                'amount_reserved' => $reserved,
                'amount_claimed' => $claimed,
                'claimable_amount' => $claimable,
                'unreleased_amount' => $unreleased,
            ];
        })->values()->all();

        return [
            'distributable_amount' => round((float) ($sync['distributable_amount'] ?? 0), 2),
            'reserved_for_collaborators' => round((float) ($sync['reserved_for_collaborators'] ?? 0), 2),
            'claimable_count' => (int) ($sync['claimable_count'] ?? 0),
            'claimable_amount' => round($claimableAmount, 2),
            'pending_amount' => round($pendingAmount, 2),
            'claimed_amount' => round($claimedAmount, 2),
            'unreleased_amount' => round(max(0, (float) ($sync['reserved_for_collaborators'] ?? 0)), 2),
            'released_to_wallet' => round($claimedAmount, 2),
            'basis_breakdown' => array_values($basisBreakdown),
            'configured_release_mode_breakdown' => array_values($configuredReleaseModeBreakdown),
            'effective_release_mode_breakdown' => array_values($effectiveReleaseModeBreakdown),
            'split_allocations' => $splitAllocations,
        ];
    }

    public function identitySummary(Identity $identity): array
    {
        if (!$this->supportsCollaboratorEconomy()) {
            return [
                'claimable_amount' => 0.0,
                'pending_amount' => 0.0,
                'claimed_amount' => 0.0,
                'items' => [],
            ];
        }

        $eventIds = EventCollaboratorSplit::query()
            ->where('identity_id', (int) $identity->id)
            ->whereIn('status', [
                EventCollaboratorSplit::STATUS_CONFIRMED,
                EventCollaboratorSplit::STATUS_LOCKED,
            ])
            ->pluck('event_id')
            ->map(fn ($value) => (int) $value)
            ->unique()
            ->values();

        foreach ($eventIds as $eventId) {
            $this->syncEventCollaboratorEarnings($eventId);
        }

        $earnings = EventCollaboratorEarning::query()
            ->with(['event.information', 'event.treasury', 'event.settlementSettings', 'split.modeAuditLogs'])
            ->where('identity_id', (int) $identity->id)
            ->orderByDesc('updated_at')
            ->get();

        $claimableAmount = 0.0;
        $pendingAmount = 0.0;
        $claimedAmount = 0.0;

        $items = $earnings->map(function (EventCollaboratorEarning $earning) use (&$claimableAmount, &$pendingAmount, &$claimedAmount) {
            $claimable = $earning->claimable_amount;
            $reserved = round((float) $earning->amount_reserved, 2);
            $claimed = round((float) $earning->amount_claimed, 2);

            if ($earning->status === EventCollaboratorEarning::STATUS_CLAIMABLE) {
                $claimableAmount = round($claimableAmount + $claimable, 2);
            } elseif (in_array($earning->status, [
                EventCollaboratorEarning::STATUS_PENDING_EVENT_COMPLETION,
                EventCollaboratorEarning::STATUS_PENDING_RELEASE,
            ], true)) {
                $pendingAmount = round($pendingAmount + max(0, $reserved - $claimed), 2);
            } elseif ($earning->status === EventCollaboratorEarning::STATUS_CLAIMED) {
                $claimedAmount = round($claimedAmount + $claimed, 2);
            }

            return $this->serializeEarning($earning);
        })->values()->all();

        return [
            'claimable_amount' => $claimableAmount,
            'pending_amount' => $pendingAmount,
            'claimed_amount' => $claimedAmount,
            'items' => $items,
            'rewards_performance' => $this->getRewardsPerformance($identity),
        ];
    }

    public function getRewardsPerformance(Identity $identity): array
    {
        if (!Schema::hasTable('event_reward_instances')) {
            return [
                'total_issued' => 0,
                'total_claimed' => 0,
                'by_event' => [],
            ];
        }

        $stats = EventRewardInstance::query()
            ->where('promoter_identity_id', (int) $identity->id)
            ->selectRaw('
                COUNT(*) as total_issued,
                SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as total_claimed,
                event_id
            ', [EventRewardInstance::STATUS_CLAIMED])
            ->groupBy('event_id')
            ->get();

        $byEvent = $stats->mapWithKeys(function ($stat) {
            return [$stat->event_id => [
                'total_issued' => (int) $stat->total_issued,
                'total_claimed' => (int) $stat->total_claimed,
            ]];
        })->all();

        return [
            'total_issued' => (int) $stats->sum('total_issued'),
            'total_claimed' => (int) $stats->sum('total_claimed'),
            'by_event' => $byEvent,
        ];
    }

    public function claimEarningToWallet(
        EventCollaboratorEarning|int|null $earning,
        Identity $activeIdentity,
        ?Carbon $now = null,
        bool $syncLegacyMirror = true,
        bool $refreshSettlementState = true,
        string $releaseSource = 'manual_claim'
    ): array {
        if (!$this->supportsCollaboratorEconomy()) {
            throw new \RuntimeException('Event collaborator earnings are not available in this environment.');
        }

        $earningModel = $earning instanceof EventCollaboratorEarning
            ? $earning
            : ($earning ? EventCollaboratorEarning::query()->find($earning) : null);

        if (!$earningModel) {
            throw new \RuntimeException('Collaborator earning not found.');
        }

        if ((int) $earningModel->identity_id !== (int) $activeIdentity->id) {
            throw new \RuntimeException('You are not allowed to claim this collaboration earning.');
        }

        $now = $now ?: now();

        return DB::transaction(function () use ($earningModel, $activeIdentity, $now, $syncLegacyMirror, $refreshSettlementState, $releaseSource) {
            /** @var EventCollaboratorEarning $earning */
            $earning = EventCollaboratorEarning::query()
                ->with(['event', 'split'])
                ->where('id', $earningModel->id)
                ->lockForUpdate()
                ->firstOrFail();

            $this->syncEventCollaboratorEarnings($earning->event_id, $now);

            $earning = EventCollaboratorEarning::query()
                ->with(['event', 'split'])
                ->where('id', $earningModel->id)
                ->lockForUpdate()
                ->firstOrFail();

            $treasury = EventTreasury::query()
                ->where('event_id', $earning->event_id)
                ->lockForUpdate()
                ->first();

            if (!$treasury) {
                throw new \RuntimeException('No treasury was found for this collaborator earning.');
            }

            $claimableAmount = $earning->claimable_amount;
            if ($earning->status !== EventCollaboratorEarning::STATUS_CLAIMABLE || $claimableAmount <= 0) {
                throw new \RuntimeException('This collaboration earning is not claimable yet.');
            }

            $legacyId = $this->catalogBridge->legacyIdForIdentity($activeIdentity, $activeIdentity->type);
            $legacyId = is_numeric($legacyId) ? (int) $legacyId : null;

            $idempotencyKey = implode('_', [
                'event_collaborator_claim',
                $earning->id,
                (int) round(((float) $earning->amount_claimed) * 100),
                (int) round($claimableAmount * 100),
            ]);

            $existingEntry = EventFinancialEntry::query()
                ->where('idempotency_key', $idempotencyKey)
                ->first();

            if ($existingEntry) {
                $existingBalanceTransaction = IdentityBalanceTransaction::query()
                    ->where('reference_type', 'event_collaborator_earning_claim')
                    ->where('reference_id', $idempotencyKey)
                    ->first();

                return [
                    'earning' => $earning->fresh(['event.information', 'identity', 'split']),
                    'entry' => $existingEntry,
                    'balance_transaction' => $existingBalanceTransaction,
                    'claimed_amount' => round($claimableAmount, 2),
                ];
            }

            $balanceMutation = match ($activeIdentity->type) {
                'organizer' => $this->professionalBalanceService->creditOrganizerBalance(
                    (int) $activeIdentity->id,
                    $legacyId,
                    $claimableAmount,
                    $syncLegacyMirror
                ),
                'venue' => $this->professionalBalanceService->creditVenueBalance(
                    (int) $activeIdentity->id,
                    $legacyId,
                    $claimableAmount,
                    $syncLegacyMirror
                ),
                'artist' => $this->professionalBalanceService->creditArtistBalance(
                    (int) $activeIdentity->id,
                    $legacyId,
                    $claimableAmount,
                    $syncLegacyMirror
                ),
                default => throw new \RuntimeException('Unsupported collaborator identity type for payout claim.'),
            };

            $balanceTransaction = IdentityBalanceTransaction::query()->create([
                'identity_id' => (int) $activeIdentity->id,
                'type' => 'credit',
                'amount' => $claimableAmount,
                'description' => 'Collaboration earning claim',
                'reference_type' => 'event_collaborator_earning_claim',
                'reference_id' => $idempotencyKey,
                'balance_before' => $balanceMutation['pre_balance'] ?? 0,
                'balance_after' => $balanceMutation['after_balance'] ?? 0,
                'meta' => [
                    'event_id' => $earning->event_id,
                    'split_id' => $earning->split_id,
                    'earning_id' => $earning->id,
                    'role_type' => $earning->role_type,
                    'sync_legacy_mirror' => $syncLegacyMirror,
                    'release_source' => $releaseSource,
                ],
            ]);

            $entry = EventFinancialEntry::query()->create([
                'treasury_id' => $treasury->id,
                'event_id' => $earning->event_id,
                'idempotency_key' => $idempotencyKey,
                'entry_type' => EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET,
                'reference_type' => 'identity_balance_transaction',
                'reference_id' => (string) $balanceTransaction->id,
                'owner_identity_id' => $earning->split?->identity_id,
                'owner_identity_type' => $earning->split?->identity_type,
                'target_identity_id' => (int) $activeIdentity->id,
                'target_identity_type' => $activeIdentity->type,
                'gross_amount' => 0,
                'fee_amount' => 0,
                'net_amount' => -$claimableAmount,
                'currency' => 'DOP',
                'status' => 'released',
                'metadata' => [
                    'split_id' => $earning->split_id,
                    'earning_id' => $earning->id,
                    'claimed_amount' => round($claimableAmount, 2),
                    'balance_before' => $balanceMutation['pre_balance'] ?? 0,
                    'balance_after' => $balanceMutation['after_balance'] ?? 0,
                    'release_source' => $releaseSource,
                ],
                'occurred_at' => $now,
            ]);

            $earning->amount_claimed = round((float) $earning->amount_claimed + $claimableAmount, 2);
            $earning->status = EventCollaboratorEarning::STATUS_CLAIMED;
            $earning->claimed_at = $now;
            $earning->save();

            $treasury->released_to_wallet = round((float) $treasury->released_to_wallet + $claimableAmount, 2);
            $treasury->save();

            $this->syncEventCollaboratorEarnings($earning->event_id, $now);
            if ($refreshSettlementState) {
                app(EventTreasuryService::class)->refreshSettlementState($earning->event_id, $now);
            }

            return [
                'earning' => $earning->fresh(['event.information', 'identity', 'split']),
                'entry' => $entry,
                'balance_transaction' => $balanceTransaction,
                'claimed_amount' => round($claimableAmount, 2),
            ];
        });
    }

    public function updateEarningReleaseMode(
        EventCollaboratorEarning|int|null $earning,
        Identity $activeIdentity,
        bool $autoRelease,
        ?Carbon $now = null
    ): array {
        if (!$this->supportsCollaboratorEconomy()) {
            throw new \RuntimeException('Event collaborator earnings are not available in this environment.');
        }

        $earningModel = $earning instanceof EventCollaboratorEarning
            ? $earning
            : ($earning ? EventCollaboratorEarning::query()->find($earning) : null);

        if (!$earningModel) {
            throw new \RuntimeException('Collaborator earning not found.');
        }

        if ((int) $earningModel->identity_id !== (int) $activeIdentity->id) {
            throw new \RuntimeException('You are not allowed to update this collaboration setting.');
        }

        $now = $now ?: now();

        return DB::transaction(function () use ($earningModel, $activeIdentity, $autoRelease, $now) {
            /** @var EventCollaboratorEarning $earning */
            $earning = EventCollaboratorEarning::query()
                ->with(['event', 'identity', 'split'])
                ->where('id', $earningModel->id)
                ->lockForUpdate()
                ->firstOrFail();

            $split = $earning->split;
            if (!$split instanceof EventCollaboratorSplit) {
                throw new \RuntimeException('No split configuration was found for this collaboration earning.');
            }

            if (in_array($earning->status, [
                EventCollaboratorEarning::STATUS_CLAIMED,
                EventCollaboratorEarning::STATUS_CANCELLED,
            ], true)) {
                throw new \RuntimeException('This collaboration can no longer change payout mode.');
            }

            $previousRequiresClaim = (bool) $split->requires_claim;
            $previousAutoRelease = (bool) $split->auto_release;
            $nextRequiresClaim = !$autoRelease;

            if ($previousRequiresClaim === $nextRequiresClaim
                && $previousAutoRelease === $autoRelease) {
                return [
                    'earning' => $earning,
                    'auto_release' => $previousAutoRelease,
                    'requires_claim' => $previousRequiresClaim,
                ];
            }

            $split->auto_release = $autoRelease;
            $split->requires_claim = $nextRequiresClaim;
            $split->release_mode = $autoRelease
                ? EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE
                : EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED;
            $split->save();

            EventCollaboratorModeAuditLog::query()->create([
                'event_id' => $earning->event_id,
                'split_id' => $split->id,
                'earning_id' => $earning->id,
                'identity_id' => $earning->identity_id,
                'actor_identity_id' => (int) $activeIdentity->id,
                'actor_identity_type' => $activeIdentity->type,
                'previous_requires_claim' => $previousRequiresClaim,
                'previous_auto_release' => $previousAutoRelease,
                'new_requires_claim' => $nextRequiresClaim,
                'new_auto_release' => $autoRelease,
                'source' => 'collaboration_mode_update',
                'metadata' => [
                    'changed_via' => 'professional_collaborations',
                ],
            ]);

            $this->syncEventCollaboratorEarnings($earning->event_id, $now);

            if ($autoRelease) {
                $this->autoReleaseEligibleEarnings($earning->event_id, $now);
            }

            app(EventTreasuryService::class)->refreshSettlementState($earning->event_id, $now);

            $updated = EventCollaboratorEarning::query()
                ->with(['event.information', 'event.settlementSettings', 'identity', 'split.modeAuditLogs'])
                ->findOrFail($earning->id);

            return [
                'earning' => $updated,
                'release_mode' => $updated->split?->release_mode,
                'effective_release_mode' => $this->resolveEffectiveReleaseMode($updated->split, $updated->event?->settlementSettings),
                'auto_release' => (bool) $updated->split?->auto_release,
                'requires_claim' => (bool) $updated->split?->requires_claim,
            ];
        });
    }

    public function autoReleaseEligibleEarnings(
        Event|int|null $event,
        ?Carbon $now = null,
        bool $syncLegacyMirror = true
    ): array {
        if (!$this->supportsCollaboratorEconomy()) {
            return [
                'released_count' => 0,
                'released_amount' => 0.0,
            ];
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return [
                'released_count' => 0,
                'released_amount' => 0.0,
            ];
        }

        $now = $now ?: now();
        $this->syncEventCollaboratorEarnings($eventModel, $now);

        $earnings = EventCollaboratorEarning::query()
            ->with(['identity', 'split', 'event.settlementSettings'])
            ->where('event_id', $eventModel->id)
            ->where('status', EventCollaboratorEarning::STATUS_CLAIMABLE)
            ->whereHas('split', function ($query) {
                $query->whereIn('status', [
                        EventCollaboratorSplit::STATUS_CONFIRMED,
                        EventCollaboratorSplit::STATUS_LOCKED,
                    ]);
            })
            ->get();

        $releasedCount = 0;
        $releasedAmount = 0.0;

        foreach ($earnings as $earning) {
            if (!$earning->identity instanceof Identity) {
                continue;
            }

            if ($this->resolveEffectiveReleaseMode($earning->split, $earning->event?->settlementSettings)
                !== EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE) {
                continue;
            }

            try {
                $claim = $this->claimEarningToWallet(
                    $earning,
                    $earning->identity,
                    $now,
                    $syncLegacyMirror,
                    false,
                    'auto_release'
                );

                $releasedCount++;
                $releasedAmount = round(
                    $releasedAmount + (float) ($claim['claimed_amount'] ?? 0),
                    2
                );

                if (($claim['earning'] ?? null) instanceof EventCollaboratorEarning
                    && (float) ($claim['claimed_amount'] ?? 0) > 0) {
                    $this->collaborationPayoutNotificationService->notifyAutoReleased(
                        $claim['earning'],
                        (float) $claim['claimed_amount']
                    );
                }
            } catch (\RuntimeException) {
                continue;
            }
        }

        if ($releasedCount > 0) {
            $this->syncEventCollaboratorEarnings($eventModel, $now);
        }

        return [
            'released_count' => $releasedCount,
            'released_amount' => round($releasedAmount, 2),
        ];
    }

    public function suggestCollaboratorsForEvent(Event|int|null $event): array
    {
        if (!$this->supportsCollaboratorEconomy()) {
            return [];
        }

        $eventModel = $event instanceof Event
            ? $event
            : ($event ? Event::query()->find($event) : null);

        if (!$eventModel) {
            return [];
        }

        $eventModel->loadMissing(['lineups.artist', 'venueIdentity', 'ownerIdentity']);

        $artistIds = $eventModel->lineups
            ->filter(fn (EventLineup $lineup) => $lineup->source_type === 'artist' && $lineup->artist_id)
            ->pluck('artist_id')
            ->map(fn ($id) => (int) $id)
            ->unique()
            ->values();

        $artistIdentityMap = $this->catalogBridge->resolveIdentityMap('artist', $artistIds);
        $suggestions = collect();

        foreach ($eventModel->lineups as $lineup) {
            if (!$lineup instanceof EventLineup || $lineup->source_type !== 'artist' || !$lineup->artist_id) {
                continue;
            }

            $artistIdentity = $artistIdentityMap->get((string) $lineup->artist_id);
            if (!$artistIdentity instanceof Identity) {
                continue;
            }

            $suggestions->push([
                'identity_id' => (int) $artistIdentity->id,
                'identity_type' => 'artist',
                'role_type' => 'artist',
                'display_name' => $artistIdentity->display_name ?: ($lineup->artist?->name ?: $lineup->display_name),
                'source' => 'event_lineup',
            ]);
        }

        if ($eventModel->venueIdentity instanceof Identity && (int) $eventModel->venueIdentity->id !== (int) ($eventModel->owner_identity_id ?? 0)) {
            $suggestions->push([
                'identity_id' => (int) $eventModel->venueIdentity->id,
                'identity_type' => 'venue',
                'role_type' => 'venue',
                'display_name' => $eventModel->venueIdentity->display_name,
                'source' => 'hosting_venue',
            ]);
        }

        return $suggestions
            ->unique(fn (array $item) => $item['role_type'] . ':' . $item['identity_id'])
            ->values()
            ->all();
    }

    private function resolveDistributableAmount(EventTreasury $treasury): float
    {
        return round(max(
            0,
            (float) $treasury->gross_collected
            - (float) $treasury->refunded_amount
            - (float) $treasury->platform_fee_total
        ), 2);
    }

    private function resolveReservedAmounts(Collection $splits, EventTreasury $treasury, float $distributableAmount): array
    {
        $allocations = [];
        $distributableAmount = round(max(0, $distributableAmount), 2);

        /** @var Collection<int, EventCollaboratorSplit> $eligibleSplits */
        $eligibleSplits = $splits
            ->filter(fn (EventCollaboratorSplit $split) => in_array($split->status, [
                EventCollaboratorSplit::STATUS_CONFIRMED,
                EventCollaboratorSplit::STATUS_LOCKED,
            ], true))
            ->filter(fn (EventCollaboratorSplit $split) => in_array($split->basis, [
                EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
                EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES,
            ], true))
            ->values();

        if ($eligibleSplits->isEmpty() || $distributableAmount <= 0) {
            return $allocations;
        }

        $rawAllocations = [];
        foreach ($eligibleSplits->groupBy(fn (EventCollaboratorSplit $split) => (string) $split->basis) as $basis => $basisSplits) {
            $basisAmount = $this->resolveBasisAmount((string) $basis, $treasury, $distributableAmount);
            $rawAllocations = array_replace(
                $rawAllocations,
                $this->resolveRawAllocationsForBasis($basisSplits->values(), $basisAmount)
            );
        }

        if ($rawAllocations === []) {
            return $allocations;
        }

        $requestedTotal = round((float) array_sum($rawAllocations), 4);
        if ($requestedTotal > 0 && $requestedTotal > $distributableAmount) {
            $scale = $distributableAmount / $requestedTotal;

            foreach ($rawAllocations as $splitId => $rawAmount) {
                $rawAllocations[$splitId] = max(0, (float) $rawAmount) * $scale;
            }
        }

        return $this->roundAllocationSet($rawAllocations, $distributableAmount);
    }

    private function resolveRawAllocationsForBasis(Collection $splits, float $basisAmount): array
    {
        $allocations = [];
        $basisAmount = round(max(0, $basisAmount), 2);

        if ($splits->isEmpty() || $basisAmount <= 0) {
            return $allocations;
        }

        $fixedSplits = $splits
            ->filter(fn (EventCollaboratorSplit $split) => $split->split_type === EventCollaboratorSplit::TYPE_FIXED)
            ->values();
        $percentageSplits = $splits
            ->filter(fn (EventCollaboratorSplit $split) => $split->split_type === EventCollaboratorSplit::TYPE_PERCENTAGE)
            ->values();

        $fixedRequestedTotal = round(
            (float) $fixedSplits->sum(fn (EventCollaboratorSplit $split) => max(0, (float) $split->split_value)),
            4
        );

        if ($fixedRequestedTotal > 0) {
            if ($fixedRequestedTotal <= $basisAmount) {
                foreach ($fixedSplits as $split) {
                    $allocations[$split->id] = max(0, (float) $split->split_value);
                }
            } else {
                $scale = $basisAmount / $fixedRequestedTotal;

                foreach ($fixedSplits as $split) {
                    $allocations[$split->id] = max(0, (float) $split->split_value) * $scale;
                }
            }
        }

        $fixedAllocatedTotal = round((float) array_sum($allocations), 4);
        $remainingAmount = round(max(0, $basisAmount - $fixedAllocatedTotal), 4);

        if ($remainingAmount <= 0 || $percentageSplits->isEmpty()) {
            return $allocations;
        }

        foreach ($percentageSplits as $split) {
            $allocations[$split->id] = $remainingAmount * (max(0, (float) $split->split_value) / 100);
        }

        return $allocations;
    }

    private function roundAllocationSet(array $rawAllocations, float $targetTotal): array
    {
        if ($rawAllocations === [] || $targetTotal <= 0) {
            return [];
        }

        $targetTotal = round(min(
            max(0, (float) array_sum(array_map(fn ($value) => max(0, (float) $value), $rawAllocations))),
            max(0, $targetTotal)
        ), 2);

        $rounded = [];
        $lastKey = array_key_last($rawAllocations);
        $runningTotal = 0.0;

        foreach ($rawAllocations as $splitId => $rawAmount) {
            if ($splitId === $lastKey) {
                $rounded[$splitId] = round(max(0, $targetTotal - $runningTotal), 2);
                continue;
            }

            $roundedAmount = round(max(0, (float) $rawAmount), 2);
            $rounded[$splitId] = $roundedAmount;
            $runningTotal = round($runningTotal + $roundedAmount, 2);
        }

        return $rounded;
    }

    private function resolveBasisAmount(string $basis, EventTreasury $treasury, float $distributableAmount): float
    {
        return match ($basis) {
            EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE => round(max(0, $distributableAmount), 2),
            EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES => round(max(0, (float) $treasury->gross_collected), 2),
            default => 0.0,
        };
    }

    private function resolveEarningStatus(
        Event $event,
        EventTreasury $treasury,
        EventCollaboratorSplit $split,
        float $reservedAmount,
        float $claimableAmount,
        float $claimedAmount,
        Carbon $now
    ): string {
        if ($split->status === EventCollaboratorSplit::STATUS_CANCELLED) {
            return EventCollaboratorEarning::STATUS_CANCELLED;
        }

        if ($reservedAmount > 0 && $claimedAmount >= $reservedAmount) {
            return EventCollaboratorEarning::STATUS_CLAIMED;
        }

        $eventEndedAt = $this->resolveEventEndedAt($event);
        $eventCompleted = $eventEndedAt ? $now->greaterThanOrEqualTo($eventEndedAt) : false;

        if (!$eventCompleted) {
            return EventCollaboratorEarning::STATUS_PENDING_EVENT_COMPLETION;
        }

        if ($treasury->settlement_status === EventTreasury::STATUS_SETTLEMENT_HOLD
            || $treasury->settlement_status === EventTreasury::STATUS_AWAITING_SETTLEMENT
            || $treasury->settlement_status === EventTreasury::STATUS_COLLECTING) {
            return EventCollaboratorEarning::STATUS_PENDING_RELEASE;
        }

        if (in_array($treasury->settlement_status, [
            EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT,
            EventTreasury::STATUS_SETTLED,
        ], true) && $claimableAmount > 0) {
            return EventCollaboratorEarning::STATUS_CLAIMABLE;
        }

        return EventCollaboratorEarning::STATUS_PENDING_RELEASE;
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

    private function serializeEarning(EventCollaboratorEarning $earning): array
    {
        $eventTitle = $earning->event?->information?->title
            ?: data_get($earning->metadata, 'event_title')
            ?: 'Evento';
        $split = $earning->split;
        $modeHistory = $this->serializeModeHistory($split);
        $effectiveReleaseMode = $this->resolveEffectiveReleaseMode($split, $earning->event?->settlementSettings);

        return [
            'id' => (int) $earning->id,
            'event_id' => (int) $earning->event_id,
            'event_title' => $eventTitle,
            'identity_id' => (int) $earning->identity_id,
            'identity_type' => $earning->identity_type,
            'display_name' => $earning->identity?->display_name,
            'role_type' => $earning->role_type,
            'status' => $earning->status,
            'split_id' => (int) $earning->split_id,
            'split_type' => data_get($earning->metadata, 'split_type'),
            'basis' => data_get($earning->metadata, 'basis'),
            'release_mode' => data_get($earning->metadata, 'release_mode', $split?->release_mode),
            'effective_release_mode' => data_get($earning->metadata, 'effective_release_mode', $effectiveReleaseMode),
            'split_value' => round((float) data_get($earning->metadata, 'split_value', 0), 4),
            'requires_claim' => $effectiveReleaseMode !== EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
            'auto_release' => $effectiveReleaseMode === EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
            'configured_requires_claim' => (bool) ($split?->requires_claim ?? true),
            'configured_auto_release' => (bool) ($split?->auto_release ?? false),
            'mode_history' => $modeHistory,
            'amount_reserved' => round((float) $earning->amount_reserved, 2),
            'amount_claimed' => round((float) $earning->amount_claimed, 2),
            'claimable_amount' => round((float) $earning->claimable_amount, 2),
            'released_at' => $earning->released_at?->toIso8601String(),
            'claimed_at' => $earning->claimed_at?->toIso8601String(),
            'last_calculated_at' => $earning->last_calculated_at?->toIso8601String(),
        ];
    }

    private function serializePendingSplit(Event $event, EventCollaboratorSplit $split): array
    {
        $eventTitle = $event->information?->title ?: 'Evento';
        $effectiveReleaseMode = $this->resolveEffectiveReleaseMode($split, $event->settlementSettings);

        return [
            'id' => 0,
            'event_id' => (int) $event->id,
            'event_title' => $eventTitle,
            'identity_id' => (int) $split->identity_id,
            'identity_type' => $split->identity_type,
            'display_name' => $split->identity?->display_name,
            'role_type' => $split->role_type,
            'status' => EventCollaboratorEarning::STATUS_PENDING_RELEASE,
            'split_id' => (int) $split->id,
            'split_type' => $split->split_type,
            'basis' => $split->basis,
            'release_mode' => $split->release_mode ?: $this->normalizeReleaseMode($split),
            'effective_release_mode' => $effectiveReleaseMode,
            'split_value' => round((float) $split->split_value, 4),
            'requires_claim' => $effectiveReleaseMode !== EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
            'auto_release' => $effectiveReleaseMode === EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
            'configured_requires_claim' => (bool) $split->requires_claim,
            'configured_auto_release' => (bool) $split->auto_release,
            'mode_history' => $this->serializeModeHistory($split),
            'amount_reserved' => 0.0,
            'amount_claimed' => 0.0,
            'claimable_amount' => 0.0,
            'released_at' => null,
            'claimed_at' => null,
            'last_calculated_at' => null,
        ];
    }

    private function buildEventActivity(Event $event): array
    {
        $event->loadMissing([
            'collaboratorSplits.identity',
            'collaboratorSplits.modeAuditLogs',
        ]);

        $activities = collect();

        foreach ($event->collaboratorSplits as $split) {
            $displayName = trim((string) ($split->identity?->display_name ?? '')) ?: $this->roleLabel($split->role_type);

            if ($split->created_at) {
                $activities->push([
                    'id' => 'split-' . $split->id,
                    'type' => 'split_configured',
                    'title' => 'Split configurado',
                    'subtitle' => $displayName . ' · ' . $this->describeSplit($split),
                    'amount' => 0.0,
                    'is_automatic' => false,
                    'occurred_at' => $split->created_at->toIso8601String(),
                ]);
            }

            foreach ($split->modeAuditLogs->sortByDesc('created_at')->take(5) as $log) {
                $activities->push([
                    'id' => 'mode-' . $log->id,
                    'type' => 'mode_changed',
                    'title' => 'Modo cambiado a ' . ($log->new_auto_release && !$log->new_requires_claim ? 'Auto release' : 'Manual'),
                    'subtitle' => $displayName . ' · ' . ($log->actor_identity_type ?: 'perfil profesional'),
                    'amount' => 0.0,
                    'is_automatic' => false,
                    'occurred_at' => optional($log->created_at)->toIso8601String(),
                ]);
            }
        }

        $entries = EventFinancialEntry::query()
            ->where('event_id', (int) $event->id)
            ->where('entry_type', EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET)
            ->orderByDesc('occurred_at')
            ->limit(10)
            ->get();

        $identityMap = Identity::query()
            ->whereIn('id', $entries->pluck('target_identity_id')->filter()->map(fn ($id) => (int) $id)->unique()->all())
            ->get()
            ->keyBy('id');

        foreach ($entries as $entry) {
            $targetIdentity = $identityMap->get((int) $entry->target_identity_id);
            $displayName = trim((string) ($targetIdentity?->display_name ?? '')) ?: $this->roleLabel($entry->target_identity_type);
            $releaseSource = (string) data_get($entry->metadata, 'release_source', 'manual_claim');
            $claimedAmount = round(abs((float) data_get($entry->metadata, 'claimed_amount', $entry->net_amount)), 2);
            $isAutomatic = $releaseSource === 'auto_release';

            $activities->push([
                'id' => 'entry-' . $entry->id,
                'type' => $isAutomatic ? 'auto_release_completed' : 'manual_claim_completed',
                'title' => $isAutomatic ? 'Ganancia auto-acreditada' : 'Ganancia reclamada',
                'subtitle' => $displayName . ' · ' . $this->roleLabel($entry->target_identity_type),
                'amount' => $claimedAmount,
                'is_automatic' => $isAutomatic,
                'occurred_at' => optional($entry->occurred_at)->toIso8601String(),
            ]);
        }

        return $activities
            ->sortByDesc('occurred_at')
            ->take(6)
            ->values()
            ->all();
    }

    private function serializeModeHistory(?EventCollaboratorSplit $split): array
    {
        if (!$split instanceof EventCollaboratorSplit) {
            return [];
        }

        $logs = $split->relationLoaded('modeAuditLogs')
            ? $split->modeAuditLogs
            : $split->modeAuditLogs()->latest()->take(5)->get();

        return $logs
            ->sortByDesc('created_at')
            ->take(5)
            ->map(function (EventCollaboratorModeAuditLog $log): array {
                return [
                    'id' => (int) $log->id,
                    'actor_identity_id' => $log->actor_identity_id ? (int) $log->actor_identity_id : null,
                    'actor_identity_type' => $log->actor_identity_type,
                    'previous_requires_claim' => (bool) $log->previous_requires_claim,
                    'previous_auto_release' => (bool) $log->previous_auto_release,
                    'new_requires_claim' => (bool) $log->new_requires_claim,
                    'new_auto_release' => (bool) $log->new_auto_release,
                    'source' => $log->source,
                    'changed_at' => $log->created_at?->toIso8601String(),
                ];
            })
            ->values()
            ->all();
    }

    private function roleLabel(?string $roleType): string
    {
        return match ($roleType) {
            'artist' => 'Artista',
            'venue' => 'Venue',
            'organizer' => 'Organizer',
            default => $roleType ?: 'Colaborador',
        };
    }

    private function describeSplit(EventCollaboratorSplit $split): string
    {
        $basisLabel = match ($split->basis) {
            EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES => 'bruto',
            default => 'neto',
        };

        return match ($split->split_type) {
            EventCollaboratorSplit::TYPE_FIXED => 'RD$' . number_format((float) $split->split_value, 2) . ' fijo sobre el ' . $basisLabel,
            default => round((float) $split->split_value, 2) . '% del ' . $basisLabel,
        };
    }

    private function basisLabel(?string $basis): string
    {
        return match ($basis) {
            EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES => 'Gross ticket sales',
            default => 'Net event revenue',
        };
    }

    private function releaseModeLabel(?string $releaseMode): string
    {
        return match ($releaseMode) {
            EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE => 'Auto release',
            EventCollaboratorSplit::RELEASE_MODE_INHERIT => 'Inherit event policy',
            default => 'Claim required',
        };
    }

    private function accumulateReleaseModeBreakdown(
        array &$bucket,
        string $mode,
        float $reserved,
        float $claimable,
        float $claimed,
        float $unreleased
    ): void {
        if (!isset($bucket[$mode])) {
            $bucket[$mode] = [
                'release_mode' => $mode,
                'label' => $this->releaseModeLabel($mode),
                'split_count' => 0,
                'reserved_amount' => 0.0,
                'claimable_amount' => 0.0,
                'claimed_amount' => 0.0,
                'unreleased_amount' => 0.0,
            ];
        }

        $bucket[$mode]['split_count']++;
        $bucket[$mode]['reserved_amount'] = round($bucket[$mode]['reserved_amount'] + $reserved, 2);
        $bucket[$mode]['claimable_amount'] = round($bucket[$mode]['claimable_amount'] + $claimable, 2);
        $bucket[$mode]['claimed_amount'] = round($bucket[$mode]['claimed_amount'] + $claimed, 2);
        $bucket[$mode]['unreleased_amount'] = round($bucket[$mode]['unreleased_amount'] + $unreleased, 2);
    }

    private function normalizeReleaseMode(?EventCollaboratorSplit $split): string
    {
        if (!$split instanceof EventCollaboratorSplit) {
            return EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED;
        }

        if ((bool) $split->auto_release && !(bool) $split->requires_claim) {
            return EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE;
        }

        if (is_string($split->release_mode)
            && in_array($split->release_mode, [
                EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED,
                EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
                EventCollaboratorSplit::RELEASE_MODE_INHERIT,
            ], true)) {
            return $split->release_mode;
        }

        return EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED;
    }

    private function resolveEffectiveReleaseMode(
        ?EventCollaboratorSplit $split,
        ?EventSettlementSetting $settings
    ): string {
        $releaseMode = $this->normalizeReleaseMode($split);

        if ($releaseMode === EventCollaboratorSplit::RELEASE_MODE_INHERIT) {
            return (bool) ($settings?->auto_release_collaborator_shares ?? false)
                ? EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE
                : EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED;
        }

        return $releaseMode;
    }
}
