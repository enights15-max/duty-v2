<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Event\ProfessionalTicketRequest;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Ticket;
use App\Models\Event\TicketContent;
use App\Models\Language;
use App\Models\Reservation\TicketReservation;
use App\Services\EventInventorySummaryService;
use App\Services\EventWaitlistService;
use App\Services\TicketPriceScheduleService;
use App\Traits\HasIdentityActor;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ProfessionalEventTicketController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        protected TicketPriceScheduleService $ticketPriceScheduleService,
        protected EventInventorySummaryService $eventInventorySummaryService,
        protected EventWaitlistService $eventWaitlistService,
    ) {
    }

    public function index(int $eventId): JsonResponse
    {
        [$identity, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $defaultLanguage = $this->defaultLanguage();
        $analytics = $this->buildTicketAnalytics($event);
        $tickets = Ticket::query()
            ->with('priceSchedules')
            ->where('event_id', $event->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn (Ticket $ticket) => $this->serializeTicket($ticket, $defaultLanguage, $analytics))
            ->values()
            ->all();

        return response()->json([
            'status' => 'success',
            'data' => [
                'event' => [
                    'id' => (int) $event->id,
                    'title' => $this->eventTitle($event),
                    'event_type' => $event->event_type,
                    'review_status' => $event->review_status,
                    'status' => (int) ($event->status ?? 0),
                    'management_summary' => [
                        'managed_by_type' => $event->owner_identity_id !== null || $event->organizer_id !== null
                            ? 'organizer'
                            : (($event->venue_identity_id !== null || $event->venue_id !== null) ? 'venue' : null),
                        'managed_by_identity_id' => $event->owner_identity_id !== null || $event->organizer_id !== null
                            ? $event->owner_identity_id
                            : $event->venue_identity_id,
                    ],
                    'hosting_venue_summary' => [
                        'venue_id' => $event->venue_id,
                        'venue_identity_id' => $event->venue_identity_id,
                        'name' => $event->venue_name_snapshot,
                    ],
                ],
                'tickets' => $tickets,
                'permissions' => [
                    'identity_type' => $identity->type,
                    'can_manage_ticketing' => true,
                ],
            ],
        ]);
    }

    public function store(ProfessionalTicketRequest $request, int $eventId): JsonResponse
    {
        [, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $beforeInventory = $this->eventInventorySummaryService->summarizeEvent($event->fresh('tickets'));

        $ticket = DB::transaction(function () use ($request, $event) {
            $ticket = new Ticket();
            $this->fillTicketFromRequest($ticket, $request, null);
            $ticket->event_id = $event->id;
            $ticket->event_type = $event->event_type;
            $ticket->save();

            $this->syncDefaultTicketContent($ticket, $request->string('title')->toString(), $request->input('description'));
            $this->syncTicketPriceSchedules($ticket, $request);

            return $ticket->fresh('priceSchedules');
        });

        $this->notifyIfPrimaryInventoryReopened($event, $beforeInventory);

        return response()->json([
            'status' => 'success',
            'message' => 'Ticket creado correctamente.',
            'data' => $this->serializeTicket($ticket, $this->defaultLanguage(), $this->buildTicketAnalytics($event)),
        ], 201);
    }

    public function update(ProfessionalTicketRequest $request, int $eventId, int $ticketId): JsonResponse
    {
        [, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $ticket = Ticket::query()->where('event_id', $event->id)->findOrFail($ticketId);
        $beforeInventory = $this->eventInventorySummaryService->summarizeEvent($event->fresh('tickets'));

        $guardError = $this->validateInventoryGuardrails($ticket, $request);
        if ($guardError) {
            return $guardError;
        }

        $ticket = DB::transaction(function () use ($request, $ticket) {
            $this->fillTicketFromRequest($ticket, $request, $ticket);
            $ticket->save();

            $this->syncDefaultTicketContent($ticket, $request->string('title')->toString(), $request->input('description'));
            $this->syncTicketPriceSchedules($ticket, $request);

            return $ticket->fresh('priceSchedules');
        });

        $this->notifyIfPrimaryInventoryReopened($event, $beforeInventory);

        return response()->json([
            'status' => 'success',
            'message' => 'Ticket actualizado correctamente.',
            'data' => $this->serializeTicket($ticket, $this->defaultLanguage(), $this->buildTicketAnalytics($event)),
        ]);
    }

    public function duplicate(Request $request, int $eventId, int $ticketId): JsonResponse
    {
        [, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $source = Ticket::query()->with('priceSchedules')->where('event_id', $event->id)->findOrFail($ticketId);
        $sourceContent = $this->defaultTicketContent($source);
        $beforeInventory = $this->eventInventorySummaryService->summarizeEvent($event->fresh('tickets'));

        $ticket = DB::transaction(function () use ($source, $sourceContent, $event) {
            $clone = $source->replicate([
                'sale_status',
                'archived_at',
                'created_at',
                'updated_at',
            ]);
            $clone->event_id = $event->id;
            $clone->event_type = $event->event_type;
            $clone->sale_status = 'paused';
            $clone->archived_at = null;
            $clone->title = $this->copyTitle($sourceContent?->title ?: $source->title ?: 'Ticket');
            $clone->save();

            $this->syncDefaultTicketContent(
                $clone,
                $clone->title,
                $sourceContent?->description ?? null
            );

            $this->ticketPriceScheduleService->syncSchedules(
                $clone,
                $source->priceSchedules->map(fn ($schedule) => [
                    'label' => $schedule->label,
                    'effective_from' => optional($schedule->effective_from)->toIso8601String(),
                    'price' => (float) $schedule->price,
                    'sort_order' => (int) $schedule->sort_order,
                    'is_active' => (bool) $schedule->is_active,
                ])->all()
            );

            return $clone->fresh('priceSchedules');
        });

        $this->notifyIfPrimaryInventoryReopened($event, $beforeInventory);

        return response()->json([
            'status' => 'success',
            'message' => 'Ticket duplicado y dejado en pausa para revisión.',
            'data' => $this->serializeTicket($ticket, $this->defaultLanguage(), $this->buildTicketAnalytics($event)),
        ], 201);
    }

    public function status(Request $request, int $eventId, int $ticketId): JsonResponse
    {
        [, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $validated = $request->validate([
            'sale_status' => 'required|in:active,paused,hidden,archived',
        ]);

        $ticket = Ticket::query()->where('event_id', $event->id)->findOrFail($ticketId);
        $beforeInventory = $this->eventInventorySummaryService->summarizeEvent($event->fresh('tickets'));
        $ticket->sale_status = $validated['sale_status'];
        $ticket->archived_at = $validated['sale_status'] === 'archived' ? now() : null;
        $ticket->save();

        $this->notifyIfPrimaryInventoryReopened($event, $beforeInventory);

        return response()->json([
            'status' => 'success',
            'message' => 'Estado de ticket actualizado.',
            'data' => $this->serializeTicket($ticket, $this->defaultLanguage(), $this->buildTicketAnalytics($event)),
        ]);
    }

    public function issueTicketManual(Request $request, int $eventId, int $ticketId): JsonResponse
    {
        [, $event, $errorResponse] = $this->resolveManagedEvent($eventId);
        if ($errorResponse) {
            return $errorResponse;
        }

        $validated = $request->validate([
            'email' => 'required|email|max:255',
            'fname' => 'nullable|string|max:255',
            'lname' => 'nullable|string|max:255',
            'quantity' => 'nullable|integer|min:1|max:50',
        ]);

        $ticket = Ticket::query()->where('event_id', $event->id)->findOrFail($ticketId);
        $quantity = $validated['quantity'] ?? 1;

        if ($ticket->ticket_available_type === 'limited' && $ticket->ticket_available !== null && $ticket->ticket_available < $quantity) {
            return response()->json([
                'status' => 'error',
                'message' => 'No hay suficiente disponibilidad para emitir esta cantidad.',
            ], 400);
        }

        $customer = \App\Models\Customer::firstOrCreate(
            ['email' => $validated['email']],
            [
                'fname' => $validated['fname'] ?? 'Guest',
                'lname' => $validated['lname'] ?? '',
                'password' => bcrypt(uniqid()),
            ]
        );

        $bookingId = uniqid('GUEST_');

        DB::transaction(function () use ($event, $ticket, $customer, $quantity, $bookingId) {
            for ($i = 0; $i < $quantity; $i++) {
                $booking = new Booking();
                $booking->customer_id = $customer->id;
                $booking->booking_id = $bookingId;
                $booking->order_number = strtoupper(uniqid());
                $booking->event_id = $event->id;
                $booking->organizer_id = $event->organizer_id;
                $booking->ticket_id = $ticket->id;
                $booking->fname = $customer->fname;
                $booking->lname = $customer->lname;
                $booking->email = $customer->email;
                $booking->price = 0;
                $booking->tax = 0;
                $booking->commission = 0;
                $booking->quantity = 1;
                $booking->paymentStatus = '1';
                $booking->paymentMethod = 'manual_guestlist';
                $booking->save();
            }

            if ($ticket->ticket_available_type === 'limited' && $ticket->ticket_available !== null) {
                $ticket->decrement('ticket_available', $quantity);
            }
        });

        if ($ticket->ticket_available_type === 'limited' && $ticket->ticket_available !== null && $ticket->ticket_available <= 0) {
            $gatedTickets = Ticket::where('event_id', $event->id)
                ->where('gate_ticket_id', $ticket->id)
                ->where('gate_trigger', 'sold_out')
                ->where('sale_status', 'paused')
                ->get();

            foreach ($gatedTickets as $gatedTicket) {
                $gatedTicket->sale_status = 'active';
                $gatedTicket->save();
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Tickets emitidos y enviados a la cuenta exitosamente.',
        ]);
    }

    private function resolveManagedEvent(int $eventId): array
    {
        $identity = $this->getActiveIdentity();
        if (!$identity || !in_array($identity->type, ['organizer', 'venue'], true)) {
            return [
                null,
                null,
                response()->json([
                    'status' => 'error',
                    'message' => 'An active organizer or venue identity is required.',
                ], 403),
            ];
        }

        $event = $this->professionalEventsQuery($identity->id, $identity->type)->find($eventId);
        if (!$event) {
            return [
                $identity,
                null,
                response()->json([
                    'status' => 'error',
                    'message' => 'Event not found for the active profile.',
                ], 404),
            ];
        }

        return [$identity, $event, null];
    }

    private function professionalEventsQuery(int $identityId, string $identityType)
    {
        return Event::query()
            ->when($identityType === 'organizer', function ($query) use ($identityId) {
                $query->ownedByOrganizerActor($identityId, $this->getOrganizerId());
            })
            ->when($identityType === 'venue', function ($query) use ($identityId) {
                $query->ownedByVenueActor($identityId, $this->getVenueId());
            });
    }

    private function notifyIfPrimaryInventoryReopened(Event $event, array $beforeInventory): void
    {
        $refreshedEvent = $event->fresh('tickets');
        if (!$refreshedEvent) {
            return;
        }

        $afterInventory = $this->eventInventorySummaryService->summarizeEvent($refreshedEvent);

        if (($beforeInventory['primary_sold_out'] ?? false) && !($afterInventory['primary_sold_out'] ?? false)) {
            $this->eventWaitlistService->notifyPrimaryInventoryAvailability($refreshedEvent);
        }
    }

    private function fillTicketFromRequest(
        Ticket $ticket,
        ProfessionalTicketRequest $request,
        ?Ticket $existingTicket = null,
    ): void {
        $pricingType = (string) $request->input('pricing_type', 'normal');
        $ticket->title = $request->string('title')->toString();
        $ticket->description = $request->input('description');
        $ticket->pricing_type = $pricingType;
        $ticket->event_type = $ticket->event_type ?: 'venue';
        $ticket->ticket_available_type = $request->input('ticket_available_type', 'unlimited');
        $ticket->ticket_available = $ticket->ticket_available_type === 'limited'
            ? (int) $request->input('ticket_available', 0)
            : null;
        $ticket->max_ticket_buy_type = $request->input('max_ticket_buy_type', 'unlimited');
        $ticket->max_buy_ticket = $ticket->max_ticket_buy_type === 'limited'
            ? (int) $request->input('max_buy_ticket', 0)
            : null;
        $ticket->early_bird_discount = $request->input('early_bird_discount_type', 'disable');
        $ticket->early_bird_discount_type = $request->input('discount_type', 'fixed');
        $ticket->early_bird_discount_amount = $ticket->early_bird_discount === 'enable'
            ? (float) $request->input('early_bird_discount_amount', 0)
            : null;
        $ticket->early_bird_discount_date = $ticket->early_bird_discount === 'enable'
            ? $request->input('early_bird_discount_date')
            : null;
        $ticket->early_bird_discount_time = $ticket->early_bird_discount === 'enable'
            ? $request->input('early_bird_discount_time')
            : null;
        $ticket->reservation_enabled = $pricingType === 'variation'
            ? false
            : filter_var($request->input('reservation_enabled', false), FILTER_VALIDATE_BOOLEAN);
        $ticket->reservation_deposit_type = $ticket->reservation_enabled
            ? $request->input('reservation_deposit_type')
            : null;
        $ticket->reservation_deposit_value = $ticket->reservation_enabled
            ? (float) $request->input('reservation_deposit_value', 0)
            : null;
        $ticket->reservation_final_due_date = $ticket->reservation_enabled
            ? $request->input('reservation_final_due_date')
            : null;
        $ticket->reservation_min_installment_amount = $ticket->reservation_enabled
            ? ($request->filled('reservation_min_installment_amount')
                ? (float) $request->input('reservation_min_installment_amount')
                : null)
            : null;
        if (Schema::hasColumn($ticket->getTable(), 'allow_promotional_resale')) {
            $ticket->allow_promotional_resale = filter_var(
                $request->input('allow_promotional_resale', true),
                FILTER_VALIDATE_BOOLEAN,
            );
        }
        $ticket->sale_status = $request->input('sale_status', $existingTicket?->sale_status ?: 'active');
        $ticket->archived_at = $ticket->sale_status === 'archived' ? now() : null;

        // Ticket gating: block this ticket until another ticket sells out or a date arrives.
        if ($request->filled('gate_ticket_id')) {
            $ticket->gate_ticket_id = (int) $request->input('gate_ticket_id');
            $ticket->gate_trigger = $request->input('gate_trigger', 'sold_out');
            $ticket->gate_trigger_date = $request->input('gate_trigger_date');
            // Force paused status when gated — the system will auto-activate it.
            if ($ticket->gate_ticket_id && $ticket->sale_status === 'active') {
                $ticket->sale_status = 'paused';
            }
        } elseif ($request->exists('gate_ticket_id') && $request->input('gate_ticket_id') === null) {
            // Explicitly clearing the gate
            $ticket->gate_ticket_id = null;
            $ticket->gate_trigger = 'sold_out';
            $ticket->gate_trigger_date = null;
        }

        if ($pricingType === 'free') {
            $ticket->price = 0;
            $ticket->f_price = 0;
            $ticket->variations = null;
        } elseif ($pricingType === 'normal') {
            $price = round((float) $request->input('price', 0), 2);
            $ticket->price = $price;
            $ticket->f_price = $price;
            $ticket->variations = null;
        } else {
            $variations = $this->normalizeVariations(
                (array) $request->input('variations', []),
                $existingTicket,
            );
            $ticket->variations = json_encode($variations);
            $ticket->price = null;
            $ticket->f_price = collect($variations)
                ->pluck('price')
                ->filter(fn ($value) => is_numeric($value))
                ->map(fn ($value) => round((float) $value, 2))
                ->max() ?: 0;
        }

        $ticket->normal_ticket_slot_enable = $existingTicket?->normal_ticket_slot_enable ?? 0;
        $ticket->normal_ticket_slot_unique_id = $existingTicket?->normal_ticket_slot_unique_id ?? random_int(100000, 999999);
        $ticket->free_tickete_slot_enable = $existingTicket?->free_tickete_slot_enable ?? 0;
        $ticket->free_tickete_slot_unique_id = $existingTicket?->free_tickete_slot_unique_id ?? random_int(100000, 999999);
        $ticket->slot_seat_min_price = $existingTicket?->slot_seat_min_price ?? 0;
    }

    private function normalizeVariations(array $rows, ?Ticket $existingTicket = null): array
    {
        $existingByName = collect(json_decode((string) ($existingTicket?->variations ?? '[]'), true) ?: [])
            ->filter(fn ($row) => is_array($row) && !empty($row['name']))
            ->keyBy(fn ($row) => trim((string) $row['name']));

        return collect($rows)
            ->filter(fn ($row) => is_array($row) && trim((string) ($row['name'] ?? '')) !== '')
            ->values()
            ->map(function (array $row, int $index) use ($existingByName) {
                $name = trim((string) $row['name']);
                $existing = $existingByName->get($name, []);
                $ticketAvailableType = ($row['ticket_available_type'] ?? 'limited') === 'unlimited'
                    ? 'unlimited'
                    : 'limited';
                $maxBuyType = ($row['max_ticket_buy_type'] ?? 'limited') === 'unlimited'
                    ? 'unlimited'
                    : 'limited';

                return [
                    'name' => $name,
                    'price' => round((float) ($row['price'] ?? 0), 2),
                    'ticket_available_type' => $ticketAvailableType,
                    'ticket_available' => $ticketAvailableType === 'limited'
                        ? max(0, (int) ($row['ticket_available'] ?? 0))
                        : null,
                    'max_ticket_buy_type' => $maxBuyType,
                    'v_max_ticket_buy' => $maxBuyType === 'limited'
                        ? max(1, (int) ($row['max_buy_ticket'] ?? 1))
                        : null,
                    'slot_enable' => (int) ($existing['slot_enable'] ?? 0),
                    'slot_unique_id' => (int) ($existing['slot_unique_id'] ?? random_int(100000, 999999)),
                    'slot_seat_min_price' => (float) ($existing['slot_seat_min_price'] ?? 0),
                    'sort_order' => (int) ($row['sort_order'] ?? $index),
                ];
            })
            ->sortBy('sort_order')
            ->values()
            ->all();
    }

    private function syncDefaultTicketContent(Ticket $ticket, string $title, ?string $description): void
    {
        $language = $this->defaultLanguage();
        if (!$language) {
            return;
        }

        TicketContent::query()->updateOrCreate(
            [
                'ticket_id' => $ticket->id,
                'language_id' => $language->id,
            ],
            [
                'title' => $title,
                'description' => $description,
            ],
        );
    }

    private function syncTicketPriceSchedules(Ticket $ticket, ProfessionalTicketRequest $request): void
    {
        $pricingType = (string) $request->input('pricing_type', 'normal');
        $rows = $pricingType === 'normal'
            ? (array) $request->input('price_schedules', [])
            : [];

        $this->ticketPriceScheduleService->syncSchedules($ticket, $rows);
    }

    private function serializeTicket(Ticket $ticket, ?Language $defaultLanguage, array $analytics): array
    {
        $content = $this->defaultTicketContent($ticket, $defaultLanguage);
        $pricing = $this->ticketPriceScheduleService->resolveForTicket($ticket);
        $variationRows = json_decode((string) ($ticket->variations ?? '[]'), true) ?: [];
        $ticketAnalytics = $analytics['tickets'][(int) $ticket->id] ?? [
            'sold' => 0,
            'reserved' => 0,
        ];

        $variationPayload = [];
        $variationAvailableTotal = 0;
        $variationAvailableKnown = false;
        $variationSoldTotal = 0;
        $variationReservedTotal = 0;

        foreach ($variationRows as $index => $variation) {
            if (!is_array($variation)) {
                continue;
            }

            $name = trim((string) ($variation['name'] ?? 'Variación ' . ($index + 1)));
            $key = (int) $ticket->id . '::' . $name;
            $sold = (int) ($analytics['variations'][$key]['sold'] ?? 0);
            $reserved = (int) ($analytics['variations'][$key]['reserved'] ?? 0);
            $available = (($variation['ticket_available_type'] ?? 'limited') === 'limited')
                ? max(0, (int) ($variation['ticket_available'] ?? 0))
                : null;
            $variationSoldTotal += $sold;
            $variationReservedTotal += $reserved;
            if ($available !== null) {
                $variationAvailableKnown = true;
                $variationAvailableTotal += $available;
            }

            $variationPayload[] = [
                'key' => 'variation:' . $ticket->id . ':' . $index,
                'name' => $name,
                'price' => round((float) ($variation['price'] ?? 0), 2),
                'ticket_available_type' => $variation['ticket_available_type'] ?? 'limited',
                'ticket_available' => $available,
                'max_ticket_buy_type' => $variation['max_ticket_buy_type'] ?? 'limited',
                'max_buy_ticket' => isset($variation['v_max_ticket_buy'])
                    ? (int) $variation['v_max_ticket_buy']
                    : null,
                'sold' => $sold,
                'reserved' => $reserved,
                'mobile_editing_supported' => ((int) ($variation['slot_enable'] ?? 0)) !== 1,
            ];
        }

        $inventoryLimited = ($ticket->ticket_available_type ?? 'unlimited') === 'limited';
        $available = $ticket->pricing_type === 'variation'
            ? ($variationAvailableKnown ? $variationAvailableTotal : null)
            : ($inventoryLimited ? max(0, (int) ($ticket->ticket_available ?? 0)) : null);
        $sold = $ticket->pricing_type === 'variation'
            ? $variationSoldTotal
            : (int) ($ticketAnalytics['sold'] ?? 0);
        $reserved = $ticket->pricing_type === 'variation'
            ? $variationReservedTotal
            : (int) ($ticketAnalytics['reserved'] ?? 0);
        $totalInventory = $available === null ? null : max(0, $available + $sold);
        $sellThrough = ($totalInventory && $totalInventory > 0)
            ? round(($sold / $totalInventory) * 100, 1)
            : null;
        $mobileEditingSupported = $ticket->pricing_type !== 'variation'
            ? ((int) ($ticket->normal_ticket_slot_enable ?? 0)) !== 1
            : collect($variationPayload)->every(fn ($row) => $row['mobile_editing_supported'] == true);

        return [
            'id' => (int) $ticket->id,
            'title' => $content?->title ?: ($ticket->title ?: ('Ticket #' . $ticket->id)),
            'description' => $content?->description ?: $ticket->description,
            'pricing_type' => $ticket->pricing_type ?: 'normal',
            'price' => $ticket->price !== null ? round((float) $ticket->price, 2) : null,
            'current_price' => round((float) ($pricing['effective_price'] ?? ($ticket->price ?? $ticket->f_price ?? 0)), 2),
            'base_price' => round((float) ($pricing['base_price'] ?? ($ticket->price ?? $ticket->f_price ?? 0)), 2),
            'current_schedule' => $pricing['current_schedule'] ?? null,
            'next_schedule' => $pricing['next_schedule'] ?? null,
            'ticket_available_type' => $ticket->ticket_available_type ?: 'unlimited',
            'ticket_available' => $ticket->ticket_available !== null ? (int) $ticket->ticket_available : null,
            'max_ticket_buy_type' => $ticket->max_ticket_buy_type ?: 'unlimited',
            'max_buy_ticket' => $ticket->max_buy_ticket !== null ? (int) $ticket->max_buy_ticket : null,
            'early_bird_discount_type' => $ticket->early_bird_discount ?: 'disable',
            'discount_type' => $ticket->early_bird_discount_type ?: 'fixed',
            'early_bird_discount_amount' => $ticket->early_bird_discount_amount !== null
                ? round((float) $ticket->early_bird_discount_amount, 2)
                : null,
            'early_bird_discount_date' => $ticket->early_bird_discount_date,
            'early_bird_discount_time' => $ticket->early_bird_discount_time,
            'reservation_enabled' => (bool) ($ticket->reservation_enabled ?? false),
            'reservation_deposit_type' => $ticket->reservation_deposit_type,
            'reservation_deposit_value' => $ticket->reservation_deposit_value !== null
                ? round((float) $ticket->reservation_deposit_value, 2)
                : null,
            'reservation_final_due_date' => $ticket->reservation_final_due_date,
            'reservation_min_installment_amount' => $ticket->reservation_min_installment_amount !== null
                ? round((float) $ticket->reservation_min_installment_amount, 2)
                : null,
            'allow_promotional_resale' => Schema::hasColumn($ticket->getTable(), 'allow_promotional_resale')
                ? (bool) ($ticket->allow_promotional_resale ?? true)
                : true,
            'sale_status' => $ticket->sale_status ?: 'active',
            'archived_at' => optional($ticket->archived_at)->toIso8601String(),
            'gate_ticket_id' => $ticket->gate_ticket_id ? (int) $ticket->gate_ticket_id : null,
            'gate_trigger' => $ticket->gate_ticket_id ? ($ticket->gate_trigger ?: 'sold_out') : null,
            'gate_trigger_date' => $ticket->gate_ticket_id
                ? optional($ticket->gate_trigger_date)->toIso8601String()
                : null,
            'analytics' => [
                'available' => $available,
                'sold' => $sold,
                'reserved' => $reserved,
                'total_inventory' => $totalInventory,
                'sell_through_percent' => $sellThrough,
            ],
            'variations' => $variationPayload,
            'price_schedules' => $ticket->priceSchedules->map(fn ($schedule) => [
                'id' => (int) $schedule->id,
                'label' => $schedule->label,
                'effective_from' => optional($schedule->effective_from)->toIso8601String(),
                'price' => round((float) $schedule->price, 2),
                'sort_order' => (int) $schedule->sort_order,
                'is_active' => (bool) $schedule->is_active,
            ])->values()->all(),
            'mobile_editing_supported' => $mobileEditingSupported,
            'mobile_editing_reason' => $mobileEditingSupported
                ? null
                : 'Este ticket usa seating/slots avanzados y por ahora solo se puede ajustar desde el panel web.',
        ];
    }

    private function buildTicketAnalytics(Event $event): array
    {
        $ticketSold = [];
        $ticketReserved = TicketReservation::query()
            ->where('event_id', (int) $event->id)
            ->whereIn('status', ['active', 'completed'])
            ->selectRaw('ticket_id, COALESCE(SUM(quantity), 0) as aggregate')
            ->groupBy('ticket_id')
            ->pluck('aggregate', 'ticket_id')
            ->map(fn ($value) => (int) $value)
            ->all();
        $variationSold = [];

        $bookings = Booking::query()
            ->where('event_id', (int) $event->id)
            ->where('paymentStatus', '!=', 'rejected')
            ->get(['ticket_id', 'quantity', 'variation']);

        foreach ($bookings as $booking) {
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
                        $key = $variationTicketId . '::' . $variationName;
                        $variationSold[$key]['sold'] = (int) (($variationSold[$key]['sold'] ?? 0) + $variationQty);
                    }
                }
                continue;
            }

            if ($ticketId > 0) {
                $ticketSold[$ticketId]['sold'] = (int) (($ticketSold[$ticketId]['sold'] ?? 0) + $quantity);
            }
        }

        foreach ($ticketReserved as $ticketId => $reserved) {
            $ticketSold[(int) $ticketId]['reserved'] = $reserved;
        }

        return [
            'tickets' => $ticketSold,
            'variations' => $variationSold,
        ];
    }

    private function validateInventoryGuardrails(Ticket $ticket, ProfessionalTicketRequest $request): ?JsonResponse
    {
        if ($ticket->pricing_type !== 'variation' && $request->input('pricing_type') !== 'variation') {
            if ($request->input('ticket_available_type') === 'limited') {
                $reserved = (int) TicketReservation::query()
                    ->where('ticket_id', (int) $ticket->id)
                    ->whereIn('status', ['active', 'completed'])
                    ->sum('quantity');
                $nextAvailable = (int) $request->input('ticket_available', 0);
                if ($nextAvailable < $reserved) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'No puedes dejar disponibles por debajo de las reservas activas de este ticket.',
                        'errors' => [
                            'ticket_available' => [
                                "Este ticket ya tiene {$reserved} boleta(s) reservadas y no puede quedar por debajo de ese colchón.",
                            ],
                        ],
                    ], 422);
                }
            }
            return null;
        }

        if ($request->input('pricing_type') === 'variation') {
            $existingRows = collect(json_decode((string) ($ticket->variations ?? '[]'), true) ?: []);
            $requestedRows = collect((array) $request->input('variations', []))
                ->filter(fn ($row) => is_array($row) && trim((string) ($row['name'] ?? '')) !== '')
                ->keyBy(fn ($row) => trim((string) $row['name']));

            foreach ($existingRows as $existing) {
                if (!is_array($existing)) {
                    continue;
                }
                $name = trim((string) ($existing['name'] ?? ''));
                if ($name === '' || !$requestedRows->has($name)) {
                    continue;
                }
                $next = $requestedRows->get($name);
                if (($next['ticket_available_type'] ?? 'limited') !== 'limited') {
                    continue;
                }
                $nextAvailable = max(0, (int) ($next['ticket_available'] ?? 0));
                if ($nextAvailable < 0) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'La disponibilidad de variaciones no puede ser negativa.',
                    ], 422);
                }
            }
        }

        return null;
    }

    private function defaultLanguage(): ?Language
    {
        return Language::query()->where('is_default', 1)->first()
            ?: Language::query()->first();
    }

    private function defaultTicketContent(Ticket $ticket, ?Language $language = null): ?TicketContent
    {
        $language = $language ?: $this->defaultLanguage();
        if (!$language) {
            return null;
        }

        return TicketContent::query()
            ->where('ticket_id', $ticket->id)
            ->where('language_id', $language->id)
            ->first()
            ?: TicketContent::query()->where('ticket_id', $ticket->id)->first();
    }

    private function eventTitle(Event $event): string
    {
        $language = $this->defaultLanguage();
        if ($language) {
            $content = DB::table('event_contents')
                ->where('event_id', $event->id)
                ->where('language_id', $language->id)
                ->value('title');
            if ($content) {
                return (string) $content;
            }
        }

        return (string) (DB::table('event_contents')->where('event_id', $event->id)->value('title') ?: 'Evento');
    }

    private function copyTitle(string $title): string
    {
        if (str_ends_with(mb_strtolower($title), '(copia)')) {
            return $title;
        }

        return $title . ' (copia)';
    }
}
