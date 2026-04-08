<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Event\StoreRequest;
use App\Http\Requests\Event\UpdateRequest;
use App\Models\Event;
use App\Models\Event\EventDates;
use App\Models\Event\EventContent;
use App\Models\Event\EventImage;
use App\Models\Event\Booking;
use App\Models\Event\Ticket;
use App\Models\EventRewardDefinition;
use App\Models\Language;
use App\Models\Reservation\TicketReservation;
use App\Models\Venue;
use App\Services\EventAuthoringService;
use App\Services\EventCollaboratorSplitService;
use App\Services\EventInventorySummaryService;
use App\Services\EventTreasuryService;
use App\Services\EventWaitlistService;
use App\Services\TicketJourneyService;
use App\Services\TicketPriceScheduleService;
use App\Traits\HasIdentityActor;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Schema;

class ProfessionalEventController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        protected EventAuthoringService $authoring,
        protected TicketPriceScheduleService $ticketPriceScheduleService,
        protected EventInventorySummaryService $eventInventorySummaryService,
        protected EventCollaboratorSplitService $eventCollaboratorSplitService,
        protected EventTreasuryService $eventTreasuryService,
        protected EventWaitlistService $eventWaitlistService,
        protected TicketJourneyService $ticketJourneyService,
    )
    {
    }

    public function index(): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer, venue, or artist identity is required.',
            ], 403);
        }

        $events = $this->professionalEventsQuery($identity->id, $identity->type)
            ->orderByDesc('start_date')
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $events->map(fn (Event $event) => $this->serializeEvent($event))->values()->all(),
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer, venue, or artist identity is required.',
            ], 403);
        }

        $event = $this->professionalEventsQuery($identity->id, $identity->type)->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $this->serializeEvent($event, true),
        ]);
    }

    public function inventory(int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer, venue, or artist identity is required.',
            ], 403);
        }

        $event = $this->professionalEventsQuery($identity->id, $identity->type)->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $this->serializeInventoryDetail($event),
        ]);
    }

    public function claimTreasury(int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue', 'artist'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer, venue, or artist identity is required.',
            ], 403);
        }

        $event = $this->professionalEventsQuery($identity->id, $identity->type)->findOrFail($id);

        try {
            $claim = $this->eventTreasuryService->claimOwnerShareToWallet($event);
        } catch (\RuntimeException $exception) {
            return response()->json([
                'status' => 'error',
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Event funds were released to your professional wallet.',
            'data' => $this->serializeEvent($event->fresh([
                'lineups.artist',
                'ownerIdentity',
                'venueIdentity',
                'galleries',
                'venue',
                'ticket',
                'dates',
                'treasury',
                'settlementSettings',
            ]), true),
            'claim' => [
                'claimed_amount' => $claim['claimed_amount'] ?? 0,
                'balance_before' => data_get($claim, 'balance_transaction.balance_before'),
                'balance_after' => data_get($claim, 'balance_transaction.balance_after'),
                'reference_id' => data_get($claim, 'balance_transaction.id'),
            ],
        ]);
    }

    public function store(StoreRequest $request): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $attributes = $request->all();
        $attributes = array_merge($attributes, $this->resolveDateSummaryAttributes($request));
        $attributes['status'] = 0;
        $attributes['review_status'] = 'pending';
        $attributes['review_notes'] = null;
        $attributes['reviewed_at'] = null;
        $attributes['reviewed_by_admin_id'] = null;
        $attributes['is_featured'] = 'no';
        $attributes['owner_identity_id'] = $identity->type === 'organizer' ? $identity->id : null;
        $attributes['organizer_id'] = $identity->type === 'organizer' ? $this->getOrganizerId() : null;

        if ($request->hasFile('thumbnail')) {
            $attributes['thumbnail'] = $this->storeEventImageVariant(
                $request->file('thumbnail'),
                public_path('assets/admin/img/event/thumbnail/'),
                'event-thumb',
                320,
                230
            );
        }

        if ($identity->type === 'venue') {
            $attributes['venue_id'] = $this->getVenueId();
            $attributes['venue_identity_id'] = $identity->id;
            $attributes['organizer_id'] = null;
            $attributes = $this->authoring->applyVenueSelection(
                $request,
                $attributes,
                Venue::find($this->getVenueId()),
                $identity
            );
        } else {
            $attributes = $this->authoring->applyVenueSelection($request, $attributes);
        }

        $attributes['f_price'] = $request->price;
        $event = Event::create($attributes);

        $this->authoring->syncLineup($event, $request);
        $this->syncDates($event, $request);
        $this->syncTicket($event, $request);
        $this->syncRewardDefinitions($event, $request);
        $this->syncSettlementSettings($event, $request);
        $this->attachSliderImages($event, (array) $request->input('slider_images', []));
        $this->attachUploadedSliderFiles($event, $request->file('slider_files', []));
        $this->authoring->syncLocalizedContent($event, $request, Language::all());

        return response()->json([
            'status' => 'success',
            'message' => 'Evento enviado a revisión del equipo Duty.',
            'data' => $this->serializeEvent($event->fresh(['lineups.artist', 'ownerIdentity', 'venueIdentity', 'settlementSettings'])),
        ], 201);
    }

    public function update(UpdateRequest $request, int $id): JsonResponse
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'An active organizer or venue identity is required.',
            ], 403);
        }

        $event = Event::findOrFail($id);
        if (!$this->canManageEvent($event, $identity->id, $identity->type)) {
            return response()->json([
                'status' => 'error',
                'message' => 'You are not allowed to manage this event.',
            ], 403);
        }

        $beforeScheduleSignature = $this->buildScheduleSignature($event->loadMissing('dates'));
        $beforeInventory = $this->eventInventorySummaryService->summarizeEvent(
            $event->fresh(['tickets'])
        );

        $attributes = $request->all();
        $attributes = array_merge($attributes, $this->resolveDateSummaryAttributes($request));
        $attributes['status'] = 0;
        $attributes['review_status'] = 'pending';
        $attributes['review_notes'] = null;
        $attributes['reviewed_at'] = null;
        $attributes['reviewed_by_admin_id'] = null;
        $attributes['is_featured'] = 'no';
        if ($request->hasFile('thumbnail')) {
            $attributes['thumbnail'] = $this->storeEventImageVariant(
                $request->file('thumbnail'),
                public_path('assets/admin/img/event/thumbnail/'),
                'event-thumb',
                320,
                230,
                $event->thumbnail
            );
        }

        $attributes['owner_identity_id'] = $identity->type === 'organizer' ? $identity->id : $event->owner_identity_id;
        $attributes['organizer_id'] = $identity->type === 'organizer' ? $this->getOrganizerId() : null;

        if ($identity->type === 'venue') {
            $attributes['venue_id'] = $this->getVenueId();
            $attributes['venue_identity_id'] = $identity->id;
            $attributes['organizer_id'] = null;
            $attributes = $this->authoring->applyVenueSelection(
                $request,
                $attributes,
                Venue::find($this->getVenueId()),
                $identity
            );
        } else {
            $attributes = $this->authoring->applyVenueSelection($request, $attributes);
        }

        $event->update($attributes);
        $event->refresh();

        $this->authoring->syncLineup($event, $request);
        $this->syncDates($event, $request, true);
        $this->syncTicket($event, $request);
        $this->syncRewardDefinitions($event, $request);
        $this->syncSettlementSettings($event, $request);
        $this->attachUploadedSliderFiles($event, $request->file('slider_files', []));
        $this->authoring->syncLocalizedContent($event, $request, Language::all());

        $refreshedEvent = $event->fresh(['lineups.artist', 'ownerIdentity', 'venueIdentity', 'tickets', 'settlementSettings', 'dates']);
        $afterScheduleSignature = $this->buildScheduleSignature($refreshedEvent);
        $afterInventory = $this->eventInventorySummaryService->summarizeEvent($refreshedEvent);

        if (($beforeInventory['primary_sold_out'] ?? false) && !($afterInventory['primary_sold_out'] ?? false)) {
            $this->eventWaitlistService->notifyPrimaryInventoryAvailability($refreshedEvent);
        }

        if ($beforeScheduleSignature !== $afterScheduleSignature) {
            $this->eventTreasuryService->openRefundWindowForScheduleChange($refreshedEvent, [
                'changed_by_identity_id' => $identity->id,
                'changed_by_type' => $identity->type,
                'before' => $beforeScheduleSignature,
                'after' => $afterScheduleSignature,
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Cambios enviados a revisión del equipo Duty.',
            'data' => $this->serializeEvent($refreshedEvent),
        ]);
    }

    private function syncDates(Event $event, UpdateRequest|StoreRequest $request, bool $updating = false): void
    {
        if ($request->date_type !== 'multiple') {
            if ($updating && $event->dates()->exists()) {
                $event->dates()->delete();
            }
            return;
        }

        $slots = $this->resolveMultiDateSlots($request);
        $retainedDateIds = [];

        foreach ($slots as $slot) {
            if ($updating && !empty($slot['id'])) {
                $eventDate = EventDates::find($slot['id']);
                if ($eventDate) {
                    $eventDate->update([
                        'start_date' => $slot['start_date'],
                        'start_time' => $slot['start_time'],
                        'end_date' => $slot['end_date'],
                        'end_time' => $slot['end_time'],
                        'duration' => $slot['duration'],
                        'start_date_time' => $slot['start_at'],
                        'end_date_time' => $slot['end_at'],
                    ]);
                    $retainedDateIds[] = $eventDate->id;
                }
            } else {
                $eventDate = EventDates::create([
                    'event_id' => $event->id,
                    'start_date' => $slot['start_date'],
                    'start_time' => $slot['start_time'],
                    'end_date' => $slot['end_date'],
                    'end_time' => $slot['end_time'],
                    'duration' => $slot['duration'],
                    'start_date_time' => $slot['start_at'],
                    'end_date_time' => $slot['end_at'],
                ]);
                $retainedDateIds[] = $eventDate->id;
            }
        }

        if ($updating) {
            $event->dates()
                ->when($retainedDateIds !== [], fn ($query) => $query->whereNotIn('id', $retainedDateIds))
                ->delete();
        }

        $latestDate = $event->dates()->orderBy('end_date_time', 'desc')->first();
        $earliestDate = $event->dates()->orderBy('start_date_time')->first();
        if ($latestDate) {
            $event->update([
                'start_date' => $earliestDate?->start_date,
                'start_time' => $earliestDate?->start_time,
                'end_date' => $latestDate->end_date,
                'end_time' => $latestDate->end_time,
                'duration' => $latestDate->duration,
                'end_date_time' => $latestDate->end_date_time,
            ]);
        }
    }

    private function syncTicket(Event $event, UpdateRequest|StoreRequest $request): void
    {
        if ($request->event_type !== 'online') {
            return;
        }

        $payload = [
            'event_id' => $event->id,
            'event_type' => $request->event_type,
            'price' => $request->price,
            'f_price' => $request->price,
            'pricing_type' => $request->filled('pricing_type') ? $request->pricing_type : 'normal',
            'ticket_available_type' => $request->ticket_available_type,
            'ticket_available' => $request->ticket_available_type === 'limited' ? $request->ticket_available : null,
            'max_ticket_buy_type' => $request->max_ticket_buy_type,
            'max_buy_ticket' => $request->max_ticket_buy_type === 'limited' ? $request->max_buy_ticket : null,
            'early_bird_discount' => $request->early_bird_discount_type,
            'early_bird_discount_type' => $request->discount_type,
            'early_bird_discount_amount' => $request->early_bird_discount_amount,
            'early_bird_discount_date' => $request->early_bird_discount_date,
            'early_bird_discount_time' => $request->early_bird_discount_time,
            'meeting_url' => $request->meeting_url,
            'reservation_enabled' => filter_var($request->input('reservation_enabled', false), FILTER_VALIDATE_BOOLEAN),
            'reservation_deposit_type' => $request->reservation_deposit_type,
            'reservation_deposit_value' => $request->reservation_deposit_value,
            'reservation_final_due_date' => $request->reservation_final_due_date,
            'reservation_min_installment_amount' => $request->reservation_min_installment_amount,
        ];

        $ticket = Ticket::updateOrCreate(['event_id' => $event->id], $payload);

        if ($request->exists('price_schedules')) {
            $this->ticketPriceScheduleService->syncSchedules(
                $ticket,
                (array) $request->input('price_schedules', [])
            );
        }
    }

    private function syncRewardDefinitions(Event $event, UpdateRequest|StoreRequest $request): void
    {
        if (!$this->supportsRewardDefinitions()) {
            return;
        }

        $definitionsData = $request->input('reward_definitions', []);
        if ($request->has('reward_definitions_payload')) {
            $decoded = json_decode((string)$request->input('reward_definitions_payload'), true);
            if (is_array($decoded)) {
                $definitionsData = $decoded;
            }
        }

        $definitions = collect($definitionsData)
            ->filter(fn ($definition) => is_array($definition))
            ->values();

        $existingDefinitions = EventRewardDefinition::query()
            ->where('event_id', $event->id)
            ->orderBy('id')
            ->get()
            ->keyBy(fn (EventRewardDefinition $definition) => (int) $definition->id);

        $retainedIds = [];

        foreach ($definitions as $definitionPayload) {
            $definitionId = (int) ($definitionPayload['id'] ?? 0);
            $existingDefinition = $definitionId > 0
                ? $existingDefinitions->get($definitionId)
                : null;

            $normalized = $this->normalizeRewardDefinitionPayload(
                is_array($definitionPayload) ? $definitionPayload : [],
                $existingDefinition
            );

            if ($existingDefinition) {
                $existingDefinition->fill($normalized);
                $existingDefinition->save();
                $retainedIds[] = (int) $existingDefinition->id;
                continue;
            }

            $createdDefinition = EventRewardDefinition::query()->create(array_merge($normalized, [
                'event_id' => $event->id,
            ]));

            $retainedIds[] = (int) $createdDefinition->id;
        }

        foreach ($existingDefinitions as $existingDefinition) {
            if (in_array((int) $existingDefinition->id, $retainedIds, true)) {
                continue;
            }

            if ($this->definitionHasIssuedInstances($existingDefinition)) {
                $meta = is_array($existingDefinition->meta) ? $existingDefinition->meta : [];
                $meta['archived_from_authoring_sync'] = true;
                $existingDefinition->update([
                    'status' => EventRewardDefinition::STATUS_INACTIVE,
                    'meta' => $meta,
                ]);
                continue;
            }

            $existingDefinition->delete();
        }
    }

    private function attachSliderImages(Event $event, array $imageIds): void
    {
        foreach ($imageIds as $id) {
            $eventImage = EventImage::find($id);
            if ($eventImage) {
                $eventImage->event_id = $event->id;
                $eventImage->save();
            }
        }
    }

    private function attachUploadedSliderFiles(Event $event, array $files): void
    {
        if ($files === []) {
            return;
        }

        $directory = public_path('assets/admin/img/event-gallery/');
        @mkdir($directory, 0775, true);

        foreach ($files as $file) {
            if (!$file) {
                continue;
            }

            $filename = $this->storeEventImageVariant(
                $file,
                $directory,
                'event-gallery',
                1170,
                570
            );

            $eventImage = new EventImage();
            $eventImage->event_id = $event->id;
            $eventImage->image = $filename;
            $eventImage->save();
        }
    }

    private function storeEventImageVariant(
        UploadedFile $file,
        string $directory,
        string $prefix,
        int $targetWidth,
        int $targetHeight,
        ?string $oldFile = null
    ): string {
        @mkdir($directory, 0775, true);

        $source = $this->createImageResource($file);
        if (!$source) {
            if ($oldFile) {
                @unlink($directory . $oldFile);
            }
            $filename = uniqid($prefix . '-', true) . '.' . $file->getClientOriginalExtension();
            $file->move($directory, $filename);

            return $filename;
        }

        [$sourceWidth, $sourceHeight] = getimagesize($file->getPathname());
        $sourceWidth = max(1, (int) $sourceWidth);
        $sourceHeight = max(1, (int) $sourceHeight);
        $targetRatio = $targetWidth / $targetHeight;
        $sourceRatio = $sourceWidth / $sourceHeight;

        if ($sourceRatio > $targetRatio) {
            $cropHeight = $sourceHeight;
            $cropWidth = (int) round($sourceHeight * $targetRatio);
            $srcX = (int) round(($sourceWidth - $cropWidth) / 2);
            $srcY = 0;
        } else {
            $cropWidth = $sourceWidth;
            $cropHeight = (int) round($sourceWidth / $targetRatio);
            $srcX = 0;
            $srcY = (int) round(($sourceHeight - $cropHeight) / 2);
        }

        $canvas = imagecreatetruecolor($targetWidth, $targetHeight);
        $background = imagecolorallocate($canvas, 18, 12, 30);
        imagefill($canvas, 0, 0, $background);
        imagecopyresampled(
            $canvas,
            $source,
            0,
            0,
            $srcX,
            $srcY,
            $targetWidth,
            $targetHeight,
            $cropWidth,
            $cropHeight
        );

        if ($oldFile) {
            @unlink($directory . $oldFile);
        }

        $filename = uniqid($prefix . '-', true) . '.jpg';
        imagejpeg($canvas, $directory . $filename, 86);

        imagedestroy($canvas);
        imagedestroy($source);

        return $filename;
    }

    private function createImageResource(UploadedFile $file)
    {
        $mimeType = strtolower((string) $file->getMimeType());
        $path = $file->getPathname();

        return match ($mimeType) {
            'image/jpeg', 'image/jpg' => @imagecreatefromjpeg($path),
            'image/png' => @imagecreatefrompng($path),
            'image/gif' => @imagecreatefromgif($path),
            'image/webp' => function_exists('imagecreatefromwebp')
                ? @imagecreatefromwebp($path)
                : false,
            default => false,
        };
    }

    private function canManageEvent(Event $event, int $identityId, string $identityType): bool
    {
        if ($identityType === 'organizer') {
            return $event->isOwnedByOrganizerActor($identityId, $this->getOrganizerId());
        }

        return $event->isOwnedByVenueActor($identityId, $this->getVenueId());
    }

    private function professionalEventsQuery(int $identityId, string $identityType)
    {
        $relations = [
            'lineups.artist',
            'ownerIdentity',
            'venueIdentity',
            'galleries',
            'venue',
            'ticket',
            'dates',
        ];

        if ($this->eventTreasuryService->supportsTreasury()) {
            $relations[] = 'treasury';
        }

        if ($this->eventTreasuryService->supportsSettlementSettings()) {
            $relations[] = 'settlementSettings';
        }

        if ($this->supportsRewardDefinitions()) {
            $relations[] = 'rewardDefinitions';
        }

        return Event::query()
            ->with($relations)
            ->when($identityType === 'organizer', function ($query) use ($identityId) {
                $query->ownedByOrganizerActor($identityId, $this->getOrganizerId());
            })
            ->when($identityType === 'venue', function ($query) use ($identityId) {
                $query->ownedByVenueActor($identityId, $this->getVenueId());
            })
            ->when($identityType === 'artist', function ($query) use ($identityId) {
                $query->participatesAsArtistActor($identityId, $this->getArtistId());
            });
    }

    private function serializeEvent(Event $event, bool $detailed = false): array
    {
        $defaultLanguage = Language::query()->where('is_default', 1)->first() ?: Language::query()->first();
        $defaultContent = $defaultLanguage
            ? EventContent::query()
                ->where('event_id', $event->id)
                ->where('language_id', $defaultLanguage->id)
                ->first()
            : null;
        $ticket = $event->ticket ?: Ticket::query()->where('event_id', $event->id)->first();
        $pricing = $ticket ? $this->ticketPriceScheduleService->resolveForTicket($ticket) : null;
        $dateEntries = $event->relationLoaded('dates')
            ? $event->dates->sortBy('start_date_time')->values()
            : $event->dates()->orderBy('start_date_time')->get();
        $earliestDate = $dateEntries->first();
        $latestDate = $dateEntries->last();
        $resolvedStartDate = $event->date_type === 'multiple' && $earliestDate
            ? $earliestDate->start_date
            : $event->start_date;
        $resolvedStartTime = $event->date_type === 'multiple' && $earliestDate
            ? $earliestDate->start_time
            : $event->start_time;
        $resolvedEndDate = $event->date_type === 'multiple' && $latestDate
            ? $latestDate->end_date
            : $event->end_date;
        $resolvedEndTime = $event->date_type === 'multiple' && $latestDate
            ? $latestDate->end_time
            : $event->end_time;
        $thumbnailUrl = $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : null;
        $gallery = $event->galleries->map(fn ($image) => [
            'id' => $image->id,
            'image' => $image->image,
            'url' => $image->image ? asset('assets/admin/img/event-gallery/' . $image->image) : null,
        ])->values()->all();
        $headlinerLineup = $event->lineups->firstWhere('is_headliner', true);
        $registeredArtists = $event->lineups
            ->where('source_type', 'artist')
            ->map(fn ($lineup) => [
                'key' => $this->authoring->lineupKey('artist', (int) $lineup->artist_id),
                'id' => (int) $lineup->artist_id,
                'display_name' => $lineup->display_name,
                'name' => $lineup->artist?->name ?: $lineup->display_name,
                'username' => $lineup->artist?->username,
                'photo' => $lineup->artist?->photo,
                'sort_order' => (int) $lineup->sort_order,
                'is_headliner' => (bool) $lineup->is_headliner,
            ])
            ->values()
            ->all();
        $manualArtists = $event->lineups
            ->where('source_type', 'manual')
            ->pluck('display_name')
            ->filter()
            ->values()
            ->all();
        $mobileAuthoringSupported = ($event->event_type === 'venue'
                && in_array($event->venue_source, ['registered', 'external', 'manual'], true))
            || ($event->event_type === 'online' && $event->date_type === 'single');
        $managedByType = $event->owner_identity_id !== null || $event->organizer_id !== null
            ? 'organizer'
            : (($event->venue_identity_id !== null || $event->venue_id !== null) ? 'venue' : null);
        $managedByIdentityId = $managedByType === 'organizer'
            ? $event->owner_identity_id
            : $event->venue_identity_id;
        $managedByLegacyId = $managedByType === 'organizer'
            ? $event->organizer_id
            : $event->venue_id;
        $hostingVenueSummary = [
            'venue_id' => $event->venue_id,
            'venue_identity_id' => $event->venue_identity_id,
            'name' => $event->venue_name_snapshot,
            'address' => $event->venue_address_snapshot,
            'city' => $event->venue_city_snapshot,
            'state' => $event->venue_state_snapshot,
            'country' => $event->venue_country_snapshot,
            'postal_code' => $event->venue_postal_code_snapshot,
            'google_place_id' => $event->venue_google_place_id,
            'latitude' => $event->latitude,
            'longitude' => $event->longitude,
        ];
        $settlementSettings = $event->relationLoaded('settlementSettings')
            ? $event->getRelation('settlementSettings')
            : $event->settlementSettings()->first();
        $rewardDefinitions = $this->supportsRewardDefinitions()
            ? ($event->relationLoaded('rewardDefinitions')
                ? $event->getRelation('rewardDefinitions')->sortBy('id')->values()
                : $event->rewardDefinitions()->orderBy('id')->get())
            : collect();
        $treasurySummary = $this->eventTreasuryService->settlementSnapshot($event);
        $collaborationSummary = $this->eventCollaboratorSplitService->eventSummary($event);
        $settlementSummary = [
            'hold_mode' => $settlementSettings?->hold_mode ?? 'auto_after_grace_period',
            'grace_period_hours' => $settlementSettings?->grace_period_hours ?? 72,
            'refund_window_hours' => $settlementSettings?->refund_window_hours ?? 72,
            'auto_release_owner_share' => (bool) ($settlementSettings?->auto_release_owner_share ?? false),
            'auto_release_collaborator_shares' => (bool) ($settlementSettings?->auto_release_collaborator_shares ?? false),
            'require_admin_approval' => (bool) ($settlementSettings?->require_admin_approval ?? false),
            'notes' => $settlementSettings?->notes,
        ];

        $payload = [
            'id' => $event->id,
            'event_type' => $event->event_type,
            'date_type' => $event->date_type,
            'title' => $defaultContent?->title ?: optional($event->information)->title,
            'status' => (int) $event->status,
            'review_status' => $event->review_status,
            'review_notes' => $event->review_notes,
            'reviewed_at' => optional($event->reviewed_at)?->toIso8601String(),
            'is_featured' => (string) $event->is_featured,
            'age_limit' => $event->age_limit !== null ? (int) $event->age_limit : null,
            'start_date' => $resolvedStartDate,
            'start_time' => $resolvedStartTime,
            'end_date' => $resolvedEndDate,
            'end_time' => $resolvedEndTime,
            'thumbnail' => $event->thumbnail,
            'thumbnail_url' => $thumbnailUrl,
            'owner_identity_id' => $event->owner_identity_id,
            'venue_identity_id' => $event->venue_identity_id,
            'venue_source' => $event->venue_source,
            'management_summary' => [
                'managed_by_type' => $managedByType,
                'managed_by_identity_id' => $managedByIdentityId,
                'managed_by_legacy_id' => $managedByLegacyId,
            ],
            'settlement_settings' => $settlementSummary,
            'treasury_summary' => $treasurySummary,
            'collaboration_summary' => $collaborationSummary,
            'mobile_authoring_supported' => $mobileAuthoringSupported,
            'mobile_authoring_reason' => $mobileAuthoringSupported
                ? null
                : 'Only venue events with registered, manual or external venues, plus single-date online events, can be edited from the current mobile authoring flow.',
            'venue_summary' => $hostingVenueSummary,
            'hosting_venue_summary' => $hostingVenueSummary,
            'lineup' => $event->lineups->map(fn ($lineup) => [
                'key' => $this->authoring->lineupKey(
                    $lineup->source_type,
                    $lineup->source_type === 'artist' ? (int) $lineup->artist_id : $lineup->display_name
                ),
                'source_type' => $lineup->source_type,
                'display_name' => $lineup->display_name,
                'artist_id' => $lineup->artist_id,
                'sort_order' => $lineup->sort_order,
                'is_headliner' => (bool) $lineup->is_headliner,
            ])->values()->all(),
            'dates' => $dateEntries->map(fn ($date) => [
                'id' => $date->id,
                'start_date' => $date->start_date,
                'start_time' => $date->start_time,
                'end_date' => $date->end_date,
                'end_time' => $date->end_time,
                'start_date_time' => $date->start_date_time,
                'end_date_time' => $date->end_date_time,
                'duration' => $date->duration,
            ])->all(),
            'selected_artists' => $registeredArtists,
            'manual_artists' => $manualArtists,
            'manual_artists_text' => implode("\n", $manualArtists),
            'headliner_key' => $headlinerLineup
                ? $this->authoring->lineupKey(
                    $headlinerLineup->source_type,
                    $headlinerLineup->source_type === 'artist'
                        ? (int) $headlinerLineup->artist_id
                        : $headlinerLineup->display_name
                )
                : null,
            'gallery' => $gallery,
            'ticket_pricing' => $ticket ? [
                'ticket_id' => $ticket->id,
                'base_price' => $pricing['base_price'] ?? (float) $ticket->price,
                'current_price' => $pricing['effective_price'] ?? (float) $ticket->price,
                'current_schedule' => $pricing['current_schedule'] ?? null,
                'next_schedule' => $pricing['next_schedule'] ?? null,
            ] : null,
            'ticket_settings' => $ticket ? [
                'meeting_url' => $event->meeting_url ?: $ticket->meeting_url,
                'price' => $ticket->price !== null ? (float) $ticket->price : null,
                'pricing_type' => $ticket->pricing_type ?: 'normal',
                'ticket_available_type' => $ticket->ticket_available_type ?: 'unlimited',
                'ticket_available' => $ticket->ticket_available !== null ? (int) $ticket->ticket_available : null,
                'max_ticket_buy_type' => $ticket->max_ticket_buy_type ?: 'unlimited',
                'max_buy_ticket' => $ticket->max_buy_ticket !== null ? (int) $ticket->max_buy_ticket : null,
                'early_bird_discount_type' => $ticket->early_bird_discount ?: 'disable',
                'discount_type' => $ticket->early_bird_discount_type ?: 'fixed',
                'early_bird_discount_amount' => $ticket->early_bird_discount_amount !== null
                    ? (float) $ticket->early_bird_discount_amount
                    : null,
                'early_bird_discount_date' => $ticket->early_bird_discount_date,
                'early_bird_discount_time' => $ticket->early_bird_discount_time,
            ] : null,
            'reward_definitions' => $this->serializeRewardDefinitions($rewardDefinitions),
        ];

        if (!$detailed) {
            return $payload;
        }

        $payload['default_language_code'] = $defaultLanguage?->code ?? 'en';
        $payload['selected_venue'] = $event->venue_source === 'registered' && $event->venue
            ? [
                'id' => $event->venue->id,
                'name' => $event->venue->name ?: $event->venue->username,
                'username' => $event->venue->username,
                'address' => $event->venue->address,
                'city' => $event->venue->city,
                'state' => $event->venue->state,
                'country' => $event->venue->country,
                'postal_code' => $event->venue->zip_code,
                'latitude' => $event->venue->latitude,
                'longitude' => $event->venue->longitude,
            ]
            : null;
        $payload['form_defaults'] = [
            'event_type' => $event->event_type,
            'date_type' => $event->date_type,
            'title' => $defaultContent?->title ?? '',
            'category_id' => $defaultContent?->event_category_id,
            'description' => $defaultContent?->description ?? '',
            'refund_policy' => $defaultContent?->refund_policy ?? '',
            'meta_keywords' => $defaultContent?->meta_keywords ?? '',
            'meta_description' => $defaultContent?->meta_description ?? '',
            'meeting_url' => $event->meeting_url ?: $ticket?->meeting_url,
            'price' => $ticket?->price,
            'pricing_type' => $ticket?->pricing_type ?: 'normal',
            'ticket_available_type' => $ticket?->ticket_available_type ?: 'unlimited',
            'ticket_available' => $ticket?->ticket_available,
            'max_ticket_buy_type' => $ticket?->max_ticket_buy_type ?: 'unlimited',
            'max_buy_ticket' => $ticket?->max_buy_ticket,
            'early_bird_discount_type' => $ticket?->early_bird_discount ?: 'disable',
            'discount_type' => $ticket?->early_bird_discount_type ?: 'fixed',
            'early_bird_discount_amount' => $ticket?->early_bird_discount_amount,
            'early_bird_discount_date' => $ticket?->early_bird_discount_date,
            'early_bird_discount_time' => $ticket?->early_bird_discount_time,
            'venue_source' => $event->venue_source ?: 'registered',
            'venue_id' => $event->venue_id,
            'venue_name' => $event->venue_name_snapshot,
            'venue_address' => $event->venue_address_snapshot,
            'venue_city' => $event->venue_city_snapshot,
            'venue_state' => $event->venue_state_snapshot,
            'venue_country' => $event->venue_country_snapshot,
            'venue_postal_code' => $event->venue_postal_code_snapshot,
            'venue_google_place_id' => $event->venue_google_place_id,
            'latitude' => $event->latitude,
            'longitude' => $event->longitude,
            'manual_artists_text' => implode("\n", $manualArtists),
            'hold_mode' => $settlementSummary['hold_mode'],
            'grace_period_hours' => $settlementSummary['grace_period_hours'],
            'refund_window_hours' => $settlementSummary['refund_window_hours'],
            'auto_release_owner_share' => $settlementSummary['auto_release_owner_share'],
            'auto_release_collaborator_shares' => $settlementSummary['auto_release_collaborator_shares'],
            'require_admin_approval' => $settlementSummary['require_admin_approval'],
            'settlement_notes' => $settlementSummary['notes'] ?? '',
            'reward_definitions' => $this->serializeRewardDefinitions($rewardDefinitions),
        ];

        return $payload;
    }

    private function supportsRewardDefinitions(): bool
    {
        return Schema::hasTable('event_reward_definitions');
    }

    private function normalizeRewardDefinitionPayload(
        array $definitionPayload,
        ?EventRewardDefinition $existingDefinition = null
    ): array {
        $existingMeta = is_array($existingDefinition?->meta) ? $existingDefinition->meta : [];
        $incomingMeta = is_array($definitionPayload['meta'] ?? null) ? $definitionPayload['meta'] : [];
        $claimCodePrefix = preg_replace(
            '/[^A-Za-z0-9]/',
            '',
            (string) ($incomingMeta['claim_code_prefix'] ?? $definitionPayload['claim_code_prefix'] ?? $existingMeta['claim_code_prefix'] ?? '')
        );

        $meta = array_merge($existingMeta, $incomingMeta, [
            'authoring_source' => 'professional_event_form',
        ]);

        if ($claimCodePrefix !== '') {
            $meta['claim_code_prefix'] = strtoupper(substr($claimCodePrefix, 0, 8));
        } else {
            unset($meta['claim_code_prefix']);
        }

        return [
            'title' => trim((string) ($definitionPayload['title'] ?? '')),
            'description' => trim((string) ($definitionPayload['description'] ?? '')) ?: null,
            'reward_type' => trim((string) ($definitionPayload['reward_type'] ?? 'perk')) ?: 'perk',
            'trigger_mode' => trim((string) ($definitionPayload['trigger_mode'] ?? EventRewardDefinition::TRIGGER_ON_TICKET_SCAN))
                ?: EventRewardDefinition::TRIGGER_ON_TICKET_SCAN,
            'fulfillment_mode' => trim((string) ($definitionPayload['fulfillment_mode'] ?? 'qr_claim')) ?: 'qr_claim',
            'inventory_limit' => $definitionPayload['inventory_limit'] !== null && $definitionPayload['inventory_limit'] !== ''
                ? (int) $definitionPayload['inventory_limit']
                : null,
            'per_ticket_quantity' => max(1, (int) ($definitionPayload['per_ticket_quantity'] ?? 1)),
            'eligible_ticket_ids' => null,
            'station_scope' => is_array($definitionPayload['station_scope'] ?? null)
                ? array_values(array_filter(
                    array_map(fn ($value) => trim((string) $value), $definitionPayload['station_scope']),
                    fn ($value) => $value !== ''
                ))
                : null,
            'meta' => $meta,
            'status' => trim((string) ($definitionPayload['status'] ?? EventRewardDefinition::STATUS_ACTIVE))
                ?: EventRewardDefinition::STATUS_ACTIVE,
        ];
    }

    private function serializeRewardDefinitions($definitions): array
    {
        return collect($definitions)
            ->filter(fn ($definition) => $definition instanceof EventRewardDefinition)
            ->filter(function (EventRewardDefinition $definition) {
                $meta = is_array($definition->meta) ? $definition->meta : [];

                return !($meta['archived_from_authoring_sync'] ?? false);
            })
            ->map(function (EventRewardDefinition $definition) {
                $meta = is_array($definition->meta) ? $definition->meta : [];

                return [
                    'id' => (int) $definition->id,
                    'title' => $definition->title,
                    'description' => $definition->description,
                    'reward_type' => $definition->reward_type,
                    'trigger_mode' => $definition->trigger_mode,
                    'fulfillment_mode' => $definition->fulfillment_mode,
                    'inventory_limit' => $definition->inventory_limit !== null ? (int) $definition->inventory_limit : null,
                    'per_ticket_quantity' => (int) ($definition->per_ticket_quantity ?? 1),
                    'station_scope' => is_array($definition->station_scope) ? array_values($definition->station_scope) : [],
                    'status' => $definition->status,
                    'claim_code_prefix' => $meta['claim_code_prefix'] ?? null,
                ];
            })
            ->values()
            ->all();
    }

    private function definitionHasIssuedInstances(EventRewardDefinition $definition): bool
    {
        return Schema::hasTable('event_reward_instances')
            && $definition->instances()->exists();
    }

    private function syncSettlementSettings(Event $event, UpdateRequest|StoreRequest $request): void
    {
        if (!$this->eventTreasuryService->supportsSettlementSettings()) {
            return;
        }

        $defaults = [
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 72,
            'refund_window_hours' => 72,
            'auto_release_owner_share' => false,
            'auto_release_collaborator_shares' => false,
            'require_admin_approval' => false,
            'notes' => null,
        ];

        $existing = $this->eventTreasuryService->ensureSettlementSettings($event);

        $this->eventTreasuryService->upsertSettlementSettings($event, [
            'hold_mode' => $request->input('hold_mode', $existing?->hold_mode ?? $defaults['hold_mode']),
            'grace_period_hours' => (int) $request->input(
                'grace_period_hours',
                $existing?->grace_period_hours ?? $defaults['grace_period_hours']
            ),
            'refund_window_hours' => (int) $request->input(
                'refund_window_hours',
                $existing?->refund_window_hours ?? $defaults['refund_window_hours']
            ),
            'auto_release_owner_share' => filter_var(
                $request->input(
                    'auto_release_owner_share',
                    $existing?->auto_release_owner_share ?? $defaults['auto_release_owner_share']
                ),
                FILTER_VALIDATE_BOOLEAN
            ),
            'auto_release_collaborator_shares' => filter_var(
                $request->input(
                    'auto_release_collaborator_shares',
                    $existing?->auto_release_collaborator_shares ?? $defaults['auto_release_collaborator_shares']
                ),
                FILTER_VALIDATE_BOOLEAN
            ),
            'require_admin_approval' => filter_var(
                $request->input(
                    'require_admin_approval',
                    $existing?->require_admin_approval ?? $defaults['require_admin_approval']
                ),
                FILTER_VALIDATE_BOOLEAN
            ),
            'notes' => trim((string) $request->input('settlement_notes', $existing?->notes ?? '')) ?: null,
        ]);
    }

    private function buildScheduleSignature(Event $event): array
    {
        $dates = $event->relationLoaded('dates')
            ? $event->dates
            : $event->dates()->orderBy('start_date_time')->get();

        return [
            'date_type' => $event->date_type,
            'start_date' => $event->start_date,
            'start_time' => $event->start_time,
            'end_date' => $event->end_date,
            'end_time' => $event->end_time,
            'slots' => $dates->map(fn ($date) => [
                'start_date' => $date->start_date,
                'start_time' => $date->start_time,
                'end_date' => $date->end_date,
                'end_time' => $date->end_time,
            ])->values()->all(),
        ];
    }

    private function serializeInventoryDetail(Event $event): array
    {
        $event->loadMissing(['tickets', 'information', 'venue', 'ownerIdentity', 'venueIdentity']);

        $inventory = $this->eventInventorySummaryService->summarizeEvent($event, $event->tickets);
        $defaultPayload = $this->serializeEvent($event, false);
        $ticketBreakdown = $this->buildTicketBreakdown($event);
        $recentActivity = $this->buildRecentInventoryActivity($event);
        $circulation = $this->ticketJourneyService->summarizeForEvent($event);
        $collaboration = $this->eventCollaboratorSplitService->eventSummary($event);
        $promoLockedCount = Booking::query()
            ->where('event_id', (int) $event->id)
            ->when(
                \Illuminate\Support\Facades\Schema::hasColumn('bookings', 'is_resellable'),
                fn ($query) => $query->where('is_resellable', false)
            )
            ->when(
                \Illuminate\Support\Facades\Schema::hasColumn('bookings', 'resale_restriction_reason'),
                fn ($query) => $query->where('resale_restriction_reason', 'promotional_restriction')
            )
            ->count();

        return [
            'event' => $defaultPayload,
            'inventory' => $inventory,
            'collaboration' => $collaboration,
            'circulation' => array_merge($circulation, [
                'promo_resale_locked_count' => $promoLockedCount,
            ]),
            'ticket_breakdown' => $ticketBreakdown,
            'recent_activity' => $recentActivity,
        ];
    }

    private function buildTicketBreakdown(Event $event): array
    {
        $tickets = $event->tickets instanceof \Illuminate\Support\Collection
            ? $event->tickets
            : collect();

        $bookingRows = Booking::query()
            ->where('event_id', (int) $event->id)
            ->where('paymentStatus', '!=', 'rejected')
            ->get(['ticket_id', 'quantity', 'variation']);

        $ticketSoldCounts = [];
        $variationSoldCounts = [];

        foreach ($bookingRows as $booking) {
            $ticketId = (int) ($booking->ticket_id ?? 0);
            $quantity = max(1, (int) ($booking->quantity ?? 1));
            $variationPayload = json_decode((string) ($booking->variation ?? ''), true);

            if (is_array($variationPayload) && $variationPayload !== []) {
                foreach ($variationPayload as $variation) {
                    if (!is_array($variation)) {
                        continue;
                    }

                    $variationTicketId = (int) ($variation['ticket_id'] ?? $ticketId);
                    $variationName = trim((string) ($variation['name'] ?? ''));
                    $variationQty = max(1, (int) ($variation['qty'] ?? $quantity));

                    if ($variationName !== '') {
                        $variationKey = $variationTicketId . '::' . $variationName;
                        $variationSoldCounts[$variationKey] = (int) ($variationSoldCounts[$variationKey] ?? 0) + $variationQty;
                    }
                }

                continue;
            }

            if ($ticketId > 0) {
                $ticketSoldCounts[$ticketId] = (int) ($ticketSoldCounts[$ticketId] ?? 0) + $quantity;
            }
        }

        $reservationCounts = TicketReservation::query()
            ->where('event_id', (int) $event->id)
            ->whereIn('status', ['active', 'completed'])
            ->selectRaw('ticket_id, COALESCE(SUM(quantity), 0) as aggregate')
            ->groupBy('ticket_id')
            ->pluck('aggregate', 'ticket_id')
            ->map(fn ($value) => (int) $value)
            ->all();

        $rows = [];

        foreach ($tickets as $ticket) {
            if (!$ticket instanceof Ticket) {
                continue;
            }

            $pricingType = strtolower((string) ($ticket->pricing_type ?? 'normal'));

            if ($pricingType === 'variation') {
                $variations = json_decode((string) ($ticket->variations ?? ''), true);
                if (is_array($variations) && $variations !== []) {
                    foreach ($variations as $index => $variation) {
                        if (!is_array($variation)) {
                            continue;
                        }

                        $variationName = trim((string) ($variation['name'] ?? 'Variación ' . ($index + 1)));
                        $isLimited = strtolower((string) ($variation['ticket_available_type'] ?? 'unlimited')) === 'limited';
                        $available = $isLimited ? max(0, (int) ($variation['ticket_available'] ?? 0)) : null;
                        $sold = (int) ($variationSoldCounts[$ticket->id . '::' . $variationName] ?? 0);
                        $inventoryTotal = $available === null ? null : max(0, $available + $sold);
                        $sellThrough = ($inventoryTotal && $inventoryTotal > 0)
                            ? round(($sold / $inventoryTotal) * 100, 1)
                            : null;

                        $rows[] = [
                            'key' => 'variation:' . $ticket->id . ':' . $index,
                            'ticket_id' => (int) $ticket->id,
                            'label' => $variationName,
                            'pricing_type' => 'variation',
                            'unit_price' => round((float) ($variation['price'] ?? $ticket->price ?? 0), 2),
                            'inventory_limited' => $isLimited,
                            'available' => $available,
                            'sold' => $sold,
                            'reserved' => 0,
                            'total_inventory' => $inventoryTotal,
                            'sell_through_percent' => $sellThrough,
                            'max_per_user' => isset($variation['v_max_ticket_buy'])
                                ? (int) $variation['v_max_ticket_buy']
                                : null,
                            'reservation_enabled' => false,
                        ];
                    }

                    continue;
                }
            }

            $isLimited = strtolower((string) ($ticket->ticket_available_type ?? 'unlimited')) === 'limited';
            $available = $isLimited ? max(0, (int) ($ticket->ticket_available ?? 0)) : null;
            $sold = (int) ($ticketSoldCounts[(int) $ticket->id] ?? 0);
            $reserved = (int) ($reservationCounts[(int) $ticket->id] ?? 0);
            $inventoryTotal = $available === null ? null : max(0, $available + $sold);
            $sellThrough = ($inventoryTotal && $inventoryTotal > 0)
                ? round(($sold / $inventoryTotal) * 100, 1)
                : null;

            $rows[] = [
                'key' => 'ticket:' . $ticket->id,
                'ticket_id' => (int) $ticket->id,
                'label' => trim((string) ($ticket->title ?? 'Ticket #' . $ticket->id)),
                'pricing_type' => $pricingType,
                'unit_price' => round((float) ($ticket->price ?? $ticket->f_price ?? 0), 2),
                'inventory_limited' => $isLimited,
                'available' => $available,
                'sold' => $sold,
                'reserved' => $reserved,
                'total_inventory' => $inventoryTotal,
                'sell_through_percent' => $sellThrough,
                'max_per_user' => $ticket->max_buy_ticket !== null ? (int) $ticket->max_buy_ticket : null,
                'reservation_enabled' => (bool) ($ticket->reservation_enabled ?? false),
            ];
        }

        return $rows;
    }

    private function buildRecentInventoryActivity(Event $event): array
    {
        $sales = Booking::query()
            ->with('customerInfo')
            ->where('event_id', (int) $event->id)
            ->where('paymentStatus', 'Completed')
            ->latest()
            ->limit(8)
            ->get()
            ->map(function (Booking $booking): array {
                $customerName = trim((string) (($booking->fname ?? '') . ' ' . ($booking->lname ?? '')));
                if ($customerName === '') {
                    $customerName = trim((string) (($booking->customerInfo?->fname ?? '') . ' ' . ($booking->customerInfo?->lname ?? '')));
                }

                return [
                    'id' => 'sale:' . $booking->id,
                    'type' => 'sale',
                    'title' => 'Nueva compra',
                    'subtitle' => trim($customerName) !== ''
                        ? $customerName . ' · ' . max(1, (int) ($booking->quantity ?? 1)) . ' boleta(s)'
                        : max(1, (int) ($booking->quantity ?? 1)) . ' boleta(s)',
                    'amount' => round((float) ($booking->price ?? 0), 2),
                    'quantity' => max(1, (int) ($booking->quantity ?? 1)),
                    'status' => 'completed',
                    'occurred_at' => optional($booking->created_at)->toIso8601String(),
                    'sort_at' => optional($booking->created_at)?->timestamp ?? 0,
                ];
            });

        $reservations = TicketReservation::query()
            ->with('customer')
            ->where('event_id', (int) $event->id)
            ->whereIn('status', ['active', 'completed'])
            ->latest()
            ->limit(8)
            ->get()
            ->map(function (TicketReservation $reservation): array {
                $customerName = trim((string) (($reservation->fname ?? '') . ' ' . ($reservation->lname ?? '')));
                if ($customerName === '') {
                    $customerName = trim((string) (($reservation->customer?->fname ?? '') . ' ' . ($reservation->customer?->lname ?? '')));
                }

                return [
                    'id' => 'reservation:' . $reservation->id,
                    'type' => 'reservation',
                    'title' => $reservation->status === 'completed'
                        ? 'Reserva completada'
                        : 'Nueva reserva',
                    'subtitle' => trim($customerName) !== ''
                        ? $customerName . ' · ' . max(1, (int) ($reservation->quantity ?? 1)) . ' boleta(s)'
                        : max(1, (int) ($reservation->quantity ?? 1)) . ' boleta(s)',
                    'amount' => round((float) ($reservation->total_amount ?? 0), 2),
                    'quantity' => max(1, (int) ($reservation->quantity ?? 1)),
                    'status' => (string) $reservation->status,
                    'occurred_at' => optional($reservation->created_at)->toIso8601String(),
                    'sort_at' => optional($reservation->created_at)?->timestamp ?? 0,
                ];
            });

        return $sales
            ->concat($reservations)
            ->sortByDesc('sort_at')
            ->take(10)
            ->map(function (array $item): array {
                unset($item['sort_at']);
                return $item;
            })
            ->values()
            ->all();
    }

    /**
     * @return array{start_date:?string,start_time:?string,end_date:?string,end_time:?string,duration:string,end_date_time:mixed}
     */
    private function resolveDateSummaryAttributes(UpdateRequest|StoreRequest $request): array
    {
        if ($request->date_type === 'single') {
            $start = Carbon::parse($request->start_date . ' ' . $request->start_time);
            $end = Carbon::parse($request->end_date . ' ' . $request->end_time);

            return [
                'start_date' => $request->start_date,
                'start_time' => $request->start_time,
                'end_date' => $request->end_date,
                'end_time' => $request->end_time,
                'duration' => DurationCalulate($start, $end),
                'end_date_time' => $end,
            ];
        }

        $slots = $this->resolveMultiDateSlots($request);
        if ($slots === []) {
            return [
                'start_date' => null,
                'start_time' => null,
                'end_date' => null,
                'end_time' => null,
                'duration' => '',
                'end_date_time' => null,
            ];
        }

        $earliest = collect($slots)->sortBy('start_at')->first();
        $latest = collect($slots)->sortByDesc('end_at')->first();

        return [
            'start_date' => $earliest['start_date'],
            'start_time' => $earliest['start_time'],
            'end_date' => $latest['end_date'],
            'end_time' => $latest['end_time'],
            'duration' => $latest['duration'],
            'end_date_time' => $latest['end_at'],
        ];
    }

    /**
     * @return array<int, array{id:?int,start_date:string,start_time:string,end_date:string,end_time:string,start_at:\Carbon\Carbon,end_at:\Carbon\Carbon,duration:string}>
     */
    private function resolveMultiDateSlots(UpdateRequest|StoreRequest $request): array
    {
        $startDates = (array) $request->input('m_start_date', []);
        $startTimes = (array) $request->input('m_start_time', []);
        $endDates = (array) $request->input('m_end_date', []);
        $endTimes = (array) $request->input('m_end_time', []);
        $dateIds = (array) $request->input('date_ids', []);
        $slots = [];

        foreach ($startDates as $index => $startDate) {
            $startDate = trim((string) $startDate);
            $startTime = trim((string) ($startTimes[$index] ?? ''));
            $endDate = trim((string) ($endDates[$index] ?? ''));
            $endTime = trim((string) ($endTimes[$index] ?? ''));

            if ($startDate === '' || $startTime === '' || $endDate === '' || $endTime === '') {
                continue;
            }

            $startAt = Carbon::parse($startDate . ' ' . $startTime);
            $endAt = Carbon::parse($endDate . ' ' . $endTime);
            $slots[] = [
                'id' => !empty($dateIds[$index]) ? (int) $dateIds[$index] : null,
                'start_date' => $startDate,
                'start_time' => $startTime,
                'end_date' => $endDate,
                'end_time' => $endTime,
                'start_at' => $startAt,
                'end_at' => $endAt,
                'duration' => DurationCalulate($startAt, $endAt),
            ];
        }

        usort($slots, function (array $left, array $right): int {
            return $left['start_at']->equalTo($right['start_at'])
                ? 0
                : ($left['start_at']->lessThan($right['start_at']) ? -1 : 1);
        });

        return $slots;
    }
}
