<?php

namespace App\Services;

use App\Models\Event\Booking;
use App\Models\EventRewardClaimLog;
use App\Models\EventRewardDefinition;
use App\Models\EventRewardInstance;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class EventTicketRewardService
{
    public function issueForBookings(iterable $bookings): Collection
    {
        if (!$this->rewardTablesAvailable()) {
            return collect();
        }

        $bookingCollection = collect($bookings)
            ->filter(fn ($booking) => $booking instanceof Booking)
            ->values();

        if ($bookingCollection->isEmpty()) {
            return collect();
        }

        // Eager load promoter split if available without assuming an Eloquent collection wrapper.
        if (Schema::hasTable('event_collaborator_splits')) {
            $bookingCollection->each(function (Booking $booking): void {
                $booking->loadMissing('promoterSplit');
            });
        }

        $definitionsByEvent = EventRewardDefinition::query()
            ->whereIn('event_id', $bookingCollection->pluck('event_id')->filter()->unique()->all())
            ->where('status', EventRewardDefinition::STATUS_ACTIVE)
            ->orderBy('id')
            ->get()
            ->groupBy('event_id');
        $supportsPromoterIdentityId = Schema::hasColumn('event_reward_instances', 'promoter_identity_id');
        $supportsSponsorIdentityId = Schema::hasColumn('event_reward_instances', 'sponsor_identity_id');

        $issuedInstances = collect();

        foreach ($bookingCollection as $booking) {
            if (!$this->bookingCanIssueRewards($booking)) {
                continue;
            }

            $definitions = $definitionsByEvent->get((int) $booking->event_id, collect());
            foreach ($definitions as $definition) {
                if (!$this->definitionAppliesToBooking($definition, $booking)) {
                    continue;
                }

                $unitKey = $this->resolveBookingTicketUnitKey($booking);
                $requestedQuantity = max(1, (int) ($definition->per_ticket_quantity ?? 1));
                $issuableQuantity = $this->resolveIssuableQuantity($definition, $booking, $unitKey, $requestedQuantity);

                for ($instanceIndex = 1; $instanceIndex <= $issuableQuantity; $instanceIndex++) {
                    $createPayload = [
                        'event_id' => (int) $booking->event_id,
                        'ticket_id' => $booking->ticket_id ?: null,
                        'customer_id' => $this->normalizeCustomerId($booking->customer_id),
                        'claim_code' => $this->buildClaimCode($definition, $booking, $instanceIndex),
                        'claim_qr_payload' => null,
                        'status' => EventRewardInstance::STATUS_RESERVED,
                        'meta' => [
                            'reward_type' => $definition->reward_type,
                            'trigger_mode' => $definition->trigger_mode,
                            'fulfillment_mode' => $definition->fulfillment_mode,
                        ],
                    ];

                    if ($supportsPromoterIdentityId) {
                        $createPayload['promoter_identity_id'] = $booking->promoterSplit?->identity_id;
                    }

                    if ($supportsSponsorIdentityId) {
                        $createPayload['sponsor_identity_id'] = $definition->sponsor_identity_id;
                    }

                    $instance = EventRewardInstance::query()->firstOrCreate(
                        [
                            'reward_definition_id' => $definition->id,
                            'booking_id' => $booking->id,
                            'ticket_unit_key' => $unitKey,
                            'instance_index' => $instanceIndex,
                        ],
                        $createPayload
                    );

                    if ($instance->wasRecentlyCreated) {
                        $instance->claim_qr_payload = $this->buildClaimQrPayload($instance->claim_code);
                        $instance->save();

                        $this->recordLog($instance, 'issued', [
                            'trigger_mode' => $definition->trigger_mode,
                            'booking_id' => $booking->id,
                            'ticket_unit_key' => $unitKey,
                        ]);
                    }

                    if ($definition->trigger_mode === EventRewardDefinition::TRIGGER_ON_BOOKING_COMPLETED) {
                        $this->activateInstance($instance, [
                            'activation_source' => 'booking_completed',
                            'booking_id' => $booking->id,
                        ]);
                    }

                    $issuedInstances->push($instance->fresh());
                }
            }
        }

        return $issuedInstances;
    }

    public function activateForTicketScan(Booking $booking, string|int $ticketKey): Collection
    {
        if (!$this->rewardTablesAvailable()) {
            return collect();
        }

        $query = EventRewardInstance::query()
            ->where('booking_id', $booking->id)
            ->where('status', EventRewardInstance::STATUS_RESERVED)
            ->whereHas('definition', function ($builder) {
                $builder->where('status', EventRewardDefinition::STATUS_ACTIVE)
                    ->where('trigger_mode', EventRewardDefinition::TRIGGER_ON_TICKET_SCAN);
            });

        $candidateKeys = collect([
            (string) $ticketKey,
            $this->resolveBookingTicketUnitKey($booking),
        ])->filter()->unique()->values();

        if ($this->bookingHasVariationUnitKey($booking)) {
            $query->whereIn('ticket_unit_key', $candidateKeys->all());
        }

        $instances = $query->get();

        return $instances->map(function (EventRewardInstance $instance) use ($ticketKey) {
            $this->activateInstance($instance, [
                'activation_source' => 'ticket_scan',
                'ticket_key' => (string) $ticketKey,
            ]);

            return $instance->fresh();
        });
    }

    public function resolveBookingTicketUnitKey(Booking $booking): string
    {
        $variation = $booking->variation;
        $decoded = is_array($variation) ? $variation : json_decode((string) $variation, true);
        if (is_array($decoded) && !empty($decoded[0]['unique_id'])) {
            return (string) $decoded[0]['unique_id'];
        }

        return '1';
    }

    public function getRewardsForBooking(Booking $booking): Collection
    {
        if (!$this->rewardTablesAvailable()) {
            return collect();
        }

        return EventRewardInstance::with(['definition', 'sponsorIdentity'])
            ->where('booking_id', $booking->id)
            ->get();
    }

    public function claimByCode(string $claimCode, array $actorInfo = []): array
    {
        if (!$this->rewardTablesAvailable()) {
            return ['status' => 'error', 'message' => 'Reward system not available'];
        }

        $instance = EventRewardInstance::where('claim_code', $claimCode)->first();

        if (!$instance) {
            return ['status' => 'error', 'message' => 'Invalid reward code'];
        }

        if ($instance->status === EventRewardInstance::STATUS_CLAIMED) {
            return ['status' => 'error', 'message' => 'Reward already claimed'];
        }

        if ($instance->status !== EventRewardInstance::STATUS_ACTIVATED) {
            return ['status' => 'error', 'message' => 'Reward not activated yet. Verify ticket entry first.'];
        }

        // Check ownership if actorInfo is provided
        if (!empty($actorInfo)) {
            $instance->loadMissing('event');
            if ($instance->event && !$instance->event->isOwnedByOrganizerActor($actorInfo['identity_id'], $actorInfo['legacy_id'])) {
                return ['status' => 'error', 'message' => 'You do not have permission to claim this reward'];
            }
        }

        $instance->status = EventRewardInstance::STATUS_CLAIMED;
        $instance->claimed_at = now();
        $instance->claimed_by_identity_id = $actorInfo['identity_id'] ?? null;

        $meta = is_array($instance->meta) ? $instance->meta : [];
        $instance->meta = array_merge($meta, [
            'claim_details' => [
                'actor_legacy_id' => $actorInfo['legacy_id'] ?? null,
                'claimed_at' => now()->toIso8601String(),
            ]
        ]);

        $instance->save();

        $this->recordLog($instance, 'claimed', $actorInfo);

        return [
            'status' => 'success',
            'message' => 'Reward claimed successfully',
            'instance' => $instance->fresh(['definition']),
        ];
    }

    private function rewardTablesAvailable(): bool
    {
        return Schema::hasTable('event_reward_definitions')
            && Schema::hasTable('event_reward_instances')
            && Schema::hasTable('event_reward_claim_logs');
    }

    private function bookingCanIssueRewards(Booking $booking): bool
    {
        $status = strtolower(trim((string) ($booking->paymentStatus ?? '')));

        return in_array($status, ['completed', 'free'], true)
            || $booking->paymentStatus === 1
            || $booking->paymentStatus === true;
    }

    private function definitionAppliesToBooking(EventRewardDefinition $definition, Booking $booking): bool
    {
        $eligibleTicketIds = collect($definition->eligible_ticket_ids ?? [])
            ->filter(fn ($ticketId) => is_numeric((string) $ticketId))
            ->map(fn ($ticketId) => (int) $ticketId)
            ->values();

        if (!$eligibleTicketIds->isEmpty() && !$eligibleTicketIds->contains((int) ($booking->ticket_id ?? 0))) {
            return false;
        }

        // Check promoter exclusivity
        if ($definition->exclusive_promoter_split_id) {
            return (int) $booking->promoter_split_id === (int) $definition->exclusive_promoter_split_id;
        }

        return true;
    }

    private function resolveIssuableQuantity(
        EventRewardDefinition $definition,
        Booking $booking,
        string $unitKey,
        int $requestedQuantity
    ): int {
        $existingCount = EventRewardInstance::query()
            ->where('reward_definition_id', $definition->id)
            ->where('booking_id', $booking->id)
            ->where('ticket_unit_key', $unitKey)
            ->count();

        $remainingForBooking = max(0, $requestedQuantity - $existingCount);
        if ($remainingForBooking === 0) {
            return 0;
        }

        $inventoryLimit = (int) ($definition->inventory_limit ?? 0);
        if ($inventoryLimit <= 0) {
            return $remainingForBooking;
        }

        $alreadyIssued = EventRewardInstance::query()
            ->where('reward_definition_id', $definition->id)
            ->where('status', '!=', EventRewardInstance::STATUS_CANCELLED)
            ->count();

        return max(0, min($remainingForBooking, $inventoryLimit - $alreadyIssued));
    }

    private function activateInstance(EventRewardInstance $instance, array $meta = []): void
    {
        if ($instance->status !== EventRewardInstance::STATUS_RESERVED) {
            return;
        }

        $instanceMeta = is_array($instance->meta) ? $instance->meta : [];
        $activationMeta = is_array($instanceMeta['activation'] ?? null) ? $instanceMeta['activation'] : [];

        $instance->status = EventRewardInstance::STATUS_ACTIVATED;
        $instance->activated_at = now();
        $instance->meta = array_merge($instanceMeta, [
            'activation' => array_merge($activationMeta, $meta),
        ]);
        $instance->save();

        $this->recordLog($instance, 'activated', $meta);
    }

    private function recordLog(EventRewardInstance $instance, string $action, array $meta = []): void
    {
        if (!Schema::hasTable('event_reward_claim_logs')) {
            return;
        }

        EventRewardClaimLog::query()->create([
            'reward_instance_id' => $instance->id,
            'action' => $action,
            'meta' => $meta,
            'occurred_at' => now(),
        ]);
    }

    private function buildClaimCode(EventRewardDefinition $definition, Booking $booking, int $instanceIndex): string
    {
        $prefix = strtoupper(Str::substr(
            preg_replace('/[^A-Za-z0-9]/', '', (string) ($definition->meta['claim_code_prefix'] ?? $definition->title)) ?: 'RWD',
            0,
            6
        ));

        return sprintf(
            '%s-%s-%02d-%s',
            $prefix,
            Str::upper(Str::padLeft(dechex((int) $booking->id), 6, '0')),
            $instanceIndex,
            Str::upper(Str::random(4))
        );
    }

    private function buildClaimQrPayload(string $claimCode): string
    {
        return 'duty://event-reward-claim?code=' . urlencode($claimCode);
    }

    private function bookingHasVariationUnitKey(Booking $booking): bool
    {
        $variation = $booking->variation;
        $decoded = is_array($variation) ? $variation : json_decode((string) $variation, true);

        return is_array($decoded) && !empty($decoded[0]['unique_id']);
    }

    private function normalizeCustomerId(mixed $customerId): ?int
    {
        return is_numeric((string) $customerId) ? (int) $customerId : null;
    }
}
