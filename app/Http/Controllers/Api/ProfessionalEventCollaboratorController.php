<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventCollaboratorSplit;
use App\Models\Identity;
use App\Services\EventCollaboratorSplitService;
use App\Services\ProfessionalCatalogBridgeService;
use App\Traits\HasIdentityActor;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class ProfessionalEventCollaboratorController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private EventCollaboratorSplitService $collaboratorSplitService,
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function index(int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $event = $this->managedEventsQuery($identity->id, $identity->type)->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $this->collaboratorSplitService->eventSummary($event),
        ]);
    }

    public function store(Request $request, int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $event = $this->managedEventsQuery($identity->id, $identity->type)->findOrFail($id);

        $validated = $request->validate([
            'splits' => ['required', 'array'],
            'splits.*.identity_id' => ['required', 'integer'],
            'splits.*.role_type' => ['required', Rule::in(['artist', 'venue', 'organizer'])],
            'splits.*.split_type' => ['nullable', Rule::in([
                EventCollaboratorSplit::TYPE_PERCENTAGE,
                EventCollaboratorSplit::TYPE_FIXED,
            ])],
            'splits.*.basis' => ['nullable', Rule::in([
                EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
                EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES,
            ])],
            'splits.*.release_mode' => ['nullable', Rule::in([
                EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED,
                EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE,
                EventCollaboratorSplit::RELEASE_MODE_INHERIT,
            ])],
            'splits.*.split_value' => ['required', 'numeric', 'min:0.0001'],
            'splits.*.requires_claim' => ['nullable', 'boolean'],
            'splits.*.auto_release' => ['nullable', 'boolean'],
            'splits.*.notes' => ['nullable', 'string', 'max:1000'],
        ]);

        $splits = collect($validated['splits'] ?? []);
        $basisCount = $splits
            ->map(fn (array $row) => (string) ($row['basis'] ?? EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE))
            ->unique()
            ->count();

        if ($basisCount > 1) {
            return response()->json([
                'status' => 'error',
                'message' => 'All collaborator splits for an event must use the same calculation basis.',
            ], 422);
        }

        $percentageSplitTotal = round((float) $splits
            ->filter(fn (array $row) => ($row['split_type'] ?? EventCollaboratorSplit::TYPE_PERCENTAGE) === EventCollaboratorSplit::TYPE_PERCENTAGE)
            ->sum(fn (array $row) => (float) ($row['split_value'] ?? 0)), 4);

        if ($percentageSplitTotal > 100.0) {
            return response()->json([
                'status' => 'error',
                'message' => 'Percentage collaborator splits cannot exceed 100% of the remaining event net revenue.',
            ], 422);
        }

        foreach ($splits as $row) {
            $splitType = (string) ($row['split_type'] ?? EventCollaboratorSplit::TYPE_PERCENTAGE);
            $splitValue = (float) ($row['split_value'] ?? 0);

            if ($splitType === EventCollaboratorSplit::TYPE_PERCENTAGE && $splitValue > 100.0) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Percentage collaborator splits cannot exceed 100%.',
                ], 422);
            }
        }

        $managerIdentityId = $event->owner_identity_id ?: $event->venue_identity_id;
        $identityIds = $splits->pluck('identity_id')->map(fn ($value) => (int) $value)->unique()->values();
        $identities = Identity::query()
            ->whereIn('id', $identityIds->all())
            ->get()
            ->keyBy('id');

        foreach ($splits as $row) {
            $targetIdentity = $identities->get((int) $row['identity_id']);
            if (!$targetIdentity instanceof Identity || !in_array($targetIdentity->type, ['artist', 'venue', 'organizer'], true)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Each collaborator split must target an active professional identity.',
                ], 422);
            }

            if ($managerIdentityId !== null && (int) $targetIdentity->id === (int) $managerIdentityId) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'The event owner cannot be added as a separate collaborator split.',
                ], 422);
            }
        }

        DB::transaction(function () use ($event, $splits, $identities): void {
            $keepKeys = [];

            foreach ($splits as $row) {
                $targetIdentity = $identities->get((int) $row['identity_id']);
                if (!$targetIdentity instanceof Identity) {
                    continue;
                }

                $legacyId = $this->catalogBridge->legacyIdForIdentity($targetIdentity, $targetIdentity->type);
                $legacyId = is_numeric($legacyId) ? (int) $legacyId : null;
                $roleType = (string) $row['role_type'];

                $split = EventCollaboratorSplit::query()->updateOrCreate(
                    [
                        'event_id' => $event->id,
                        'identity_id' => (int) $targetIdentity->id,
                        'role_type' => $roleType,
                    ],
                    [
                        'identity_type' => $targetIdentity->type,
                        'legacy_id' => $legacyId,
                        'split_type' => (string) ($row['split_type'] ?? EventCollaboratorSplit::TYPE_PERCENTAGE),
                        'split_value' => round((float) $row['split_value'], 4),
                        'basis' => (string) ($row['basis'] ?? EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE),
                        'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
                        'release_mode' => $this->resolveReleaseMode(
                            $row['release_mode'] ?? null,
                            $row['requires_claim'] ?? null,
                            $row['auto_release'] ?? null
                        ),
                        'requires_claim' => $this->resolveStoredRequiresClaim(
                            $row['release_mode'] ?? null,
                            $row['requires_claim'] ?? null,
                            $row['auto_release'] ?? null
                        ),
                        'auto_release' => $this->resolveStoredAutoRelease(
                            $row['release_mode'] ?? null,
                            $row['requires_claim'] ?? null,
                            $row['auto_release'] ?? null
                        ),
                        'notes' => trim((string) ($row['notes'] ?? '')) ?: null,
                    ]
                );

                $keepKeys[] = $split->id;
            }

            if ($keepKeys === []) {
                EventCollaboratorSplit::query()
                    ->where('event_id', $event->id)
                    ->update(['status' => EventCollaboratorSplit::STATUS_CANCELLED]);
            } else {
                EventCollaboratorSplit::query()
                    ->where('event_id', $event->id)
                    ->whereNotIn('id', $keepKeys)
                    ->update(['status' => EventCollaboratorSplit::STATUS_CANCELLED]);
            }
        });

        $summary = $this->collaboratorSplitService->eventSummary($event->fresh(['treasury', 'collaboratorSplits.identity', 'lineups.artist']));

        return response()->json([
            'status' => 'success',
            'message' => 'Event collaborators were updated.',
            'data' => $summary,
        ]);
    }

    private function managedEventsQuery(int $identityId, string $identityType): Builder
    {
        return Event::query()
            ->when(
                $identityType === 'organizer',
                fn (Builder $query) => $query->ownedByOrganizerActor($identityId, $this->getOrganizerId()),
                fn (Builder $query) => $query->ownedByVenueActor($identityId, $this->getVenueId())
            );
    }

    private function resolveReleaseMode(mixed $releaseMode, mixed $requiresClaim, mixed $autoRelease): string
    {
        if (is_string($releaseMode) && $releaseMode !== '') {
            return $releaseMode;
        }

        return filter_var($autoRelease ?? false, FILTER_VALIDATE_BOOLEAN)
            ? EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE
            : EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED;
    }

    private function resolveStoredRequiresClaim(mixed $releaseMode, mixed $requiresClaim, mixed $autoRelease): bool
    {
        return match ($this->resolveReleaseMode($releaseMode, $requiresClaim, $autoRelease)) {
            EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE => false,
            default => true,
        };
    }

    private function resolveStoredAutoRelease(mixed $releaseMode, mixed $requiresClaim, mixed $autoRelease): bool
    {
        return $this->resolveReleaseMode($releaseMode, $requiresClaim, $autoRelease)
            === EventCollaboratorSplit::RELEASE_MODE_AUTO_RELEASE;
    }
}
