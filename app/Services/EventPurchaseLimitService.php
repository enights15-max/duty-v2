<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Ticket;
use App\Models\TicketTransfer;

class EventPurchaseLimitService
{
    public function summarize(?Customer $customer, Event $event, Ticket $ticket, ?string $variationName = null): array
    {
        $variation = $variationName !== null ? $this->resolveVariation($ticket, $variationName) : null;
        $maxAllowed = $this->resolveMaxAllowed($ticket, $variation);
        $alreadyPurchased = $customer
            ? $this->countPurchasedQuantity($customer, $event, $ticket, $variationName)
            : 0;
        $remainingAllowed = $maxAllowed === null ? null : max(0, $maxAllowed - $alreadyPurchased);

        return [
            'has_limit' => $maxAllowed !== null,
            'max_allowed' => $maxAllowed,
            'already_purchased' => $alreadyPurchased,
            'remaining_allowed' => $remainingAllowed,
            'limit_reached' => $maxAllowed !== null && $alreadyPurchased >= $maxAllowed,
            'label' => $variationName ?: ($ticket->title ?: ('Ticket #' . $ticket->id)),
        ];
    }

    public function validateSelection(
        ?Customer $customer,
        ?Event $event,
        array $rawSelections,
        ?int $fallbackQuantity = null,
        array $recipientAssignments = []
    ): ?array
    {
        if (!$event) {
            return null;
        }

        $normalizedSelections = $this->normalizeSelections($event, $rawSelections, $fallbackQuantity);
        if (empty($normalizedSelections)) {
            return null;
        }

        $recipientAssignments = $this->normalizeRecipientAssignments($recipientAssignments);
        $holderSelections = $this->groupSelectionsByFinalHolder(
            $customer,
            $normalizedSelections,
            $recipientAssignments
        );

        foreach ($holderSelections as $holderSelection) {
            /** @var Customer|null $holder */
            $holder = $holderSelection['customer'];
            $holderLabel = $this->holderLabel($holder, $customer);

            foreach ($holderSelection['ticket_groups'] as $selection) {
            /** @var Ticket $ticket */
            $ticket = $selection['ticket'];
            $requestedQty = (int) $selection['qty'];
            if ($requestedQty <= 0) {
                continue;
            }

            $summary = $this->summarize($holder, $event, $ticket, $selection['variation_name']);
            if (!$summary['has_limit']) {
                continue;
            }

            if (!$holder) {
                return [
                    'status' => false,
                    'message' => 'Debes iniciar sesión para comprar entradas con límite por usuario.',
                    'error_type' => 'purchase_limit_login_required',
                    'status_code' => 403,
                    'limit_context' => [
                        'ticket_id' => $ticket->id,
                        'ticket_label' => $summary['label'],
                        'max_allowed' => $summary['max_allowed'],
                        'already_purchased' => 0,
                        'requested_quantity' => $requestedQty,
                        'remaining_allowed' => $summary['max_allowed'],
                    ],
                ];
            }

            $remainingAllowed = (int) ($summary['remaining_allowed'] ?? 0);
            if ($requestedQty > $remainingAllowed) {
                $message = $remainingAllowed <= 0
                    ? sprintf(
                        '%s ya alcanzó el máximo de %d entrada(s) por usuario para %s.',
                        $holderLabel,
                        (int) $summary['max_allowed'],
                        $summary['label']
                    )
                    : sprintf(
                        '%s solo puede recibir %d entrada(s) más para %s. Ya tiene %d de %d permitidas.',
                        $holderLabel,
                        $remainingAllowed,
                        $summary['label'],
                        (int) $summary['already_purchased'],
                        (int) $summary['max_allowed']
                    );

                return [
                    'status' => false,
                    'message' => $message,
                    'error_type' => 'purchase_limit_reached',
                    'status_code' => 422,
                    'limit_context' => [
                        'ticket_id' => $ticket->id,
                        'ticket_label' => $summary['label'],
                        'max_allowed' => $summary['max_allowed'],
                        'already_purchased' => $summary['already_purchased'],
                        'requested_quantity' => $requestedQty,
                        'remaining_allowed' => $remainingAllowed,
                        'holder_id' => $holder?->id,
                        'holder_label' => $holderLabel,
                    ],
                ];
            }
        }
        }

        return null;
    }

    public function countPurchasedQuantity(Customer $customer, Event $event, Ticket $ticket, ?string $variationName = null): int
    {
        return $this->countCurrentHeldQuantity($customer, $event, $ticket, $variationName)
            + $this->countPendingIncomingGiftQuantity($customer, $event, $ticket, $variationName);
    }

    private function countCurrentHeldQuantity(Customer $customer, Event $event, Ticket $ticket, ?string $variationName = null): int
    {
        $bookings = Booking::query()
            ->where('customer_id', $customer->id)
            ->where('event_id', $event->id)
            ->where('paymentStatus', '!=', 'rejected')
            ->get();

        $pendingOutgoingBookingIds = TicketTransfer::query()
            ->pending()
            ->where('from_customer_id', $customer->id)
            ->whereHas('booking', function ($query) use ($event): void {
                $query->where('event_id', $event->id)
                    ->where('paymentStatus', '!=', 'rejected');
            })
            ->pluck('booking_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $ticketIdsForEvent = $event->ticket()->pluck('id')->map(fn ($id) => (int) $id)->all();
        $singleTicketEvent = count($ticketIdsForEvent) === 1 && (int) ($ticketIdsForEvent[0] ?? 0) === (int) $ticket->id;

        $qty = 0;
        foreach ($bookings as $booking) {
            if (in_array((int) $booking->id, $pendingOutgoingBookingIds, true)) {
                continue;
            }

            if ($variationName !== null) {
                $qty += $this->countVariationBookingQuantity($booking->variation, (int) $ticket->id, $variationName);
                continue;
            }

            if ((int) ($booking->ticket_id ?? 0) === (int) $ticket->id) {
                $qty += max(1, (int) ($booking->quantity ?? 1));
                continue;
            }

            $variationQty = $this->countVariationBookingQuantity($booking->variation, (int) $ticket->id, null);
            if ($variationQty > 0) {
                $qty += $variationQty;
                continue;
            }

            if ($singleTicketEvent && empty($booking->variation) && empty($booking->ticket_id)) {
                $qty += max(1, (int) ($booking->quantity ?? 1));
            }
        }

        return $qty;
    }

    private function countPendingIncomingGiftQuantity(Customer $customer, Event $event, Ticket $ticket, ?string $variationName = null): int
    {
        $transfers = TicketTransfer::query()
            ->pending()
            ->where('to_customer_id', $customer->id)
            ->where(function ($query): void {
                $query->whereNull('flow')
                    ->orWhere('flow', 'owner_offer');
            })
            ->with('booking')
            ->whereHas('booking', function ($query) use ($event): void {
                $query->where('event_id', $event->id)
                    ->where('paymentStatus', '!=', 'rejected');
            })
            ->get();

        $qty = 0;
        foreach ($transfers as $transfer) {
            $booking = $transfer->booking;
            if (!$booking) {
                continue;
            }

            $qty += $this->countBookingQuantityForTicket(
                $booking,
                $event,
                $ticket,
                $variationName
            );
        }

        return $qty;
    }

    private function normalizeSelections(Event $event, array $rawSelections, ?int $fallbackQuantity = null): array
    {
        $normalized = [];

        if (empty($rawSelections)) {
            $defaultTicket = $event->ticket()->first();
            if ($defaultTicket && (int) $fallbackQuantity > 0) {
                $normalized[] = [
                    'ticket' => $defaultTicket,
                    'qty' => (int) $fallbackQuantity,
                    'variation_name' => null,
                ];
            }

            return $normalized;
        }

        foreach ($rawSelections as $selection) {
            if (!is_array($selection)) {
                continue;
            }

            $ticketId = (int) ($selection['ticket_id'] ?? 0);
            $qty = max(0, (int) ($selection['qty'] ?? 0));
            if ($ticketId <= 0 || $qty <= 0) {
                continue;
            }

            $ticket = Ticket::find($ticketId);
            if (!$ticket || (int) $ticket->event_id !== (int) $event->id) {
                continue;
            }

            $normalized[] = [
                'ticket' => $ticket,
                'qty' => $qty,
                'variation_name' => isset($selection['name']) ? trim((string) $selection['name']) : null,
            ];
        }

        return $normalized;
    }

    private function normalizeRecipientAssignments(array $recipientAssignments): array
    {
        $normalized = [];
        foreach ($recipientAssignments as $assignment) {
            if (!is_array($assignment)) {
                continue;
            }

            $slotKey = trim((string) ($assignment['slot_key'] ?? ''));
            $recipientId = (int) ($assignment['recipient_id'] ?? 0);
            if ($slotKey === '' || $recipientId <= 0) {
                continue;
            }

            $normalized[$slotKey] = [
                'slot_key' => $slotKey,
                'recipient_id' => $recipientId,
            ];
        }

        return $normalized;
    }

    private function groupSelectionsByFinalHolder(
        ?Customer $buyer,
        array $normalizedSelections,
        array $recipientAssignments
    ): array {
        $unitSelections = $this->buildUnitSelections($normalizedSelections);
        if (empty($unitSelections)) {
            return [];
        }

        $recipientIds = collect($recipientAssignments)
            ->pluck('recipient_id')
            ->map(fn ($id) => (int) $id)
            ->filter(fn ($id) => $id > 0)
            ->unique()
            ->values();

        $recipients = $recipientIds->isEmpty()
            ? collect()
            : Customer::query()->whereIn('id', $recipientIds->all())->get()->keyBy('id');

        $holderGroups = [];
        foreach ($unitSelections as $unitSelection) {
            $assignment = $recipientAssignments[$unitSelection['slot_key']] ?? null;
            $holder = $buyer;

            if ($assignment) {
                $resolvedRecipient = $recipients->get((int) $assignment['recipient_id']);
                if ($resolvedRecipient instanceof Customer) {
                    $holder = $resolvedRecipient;
                }
            }

            $holderKey = $holder ? 'customer:' . (int) $holder->id : 'guest';
            if (!isset($holderGroups[$holderKey])) {
                $holderGroups[$holderKey] = [
                    'customer' => $holder,
                    'ticket_groups' => [],
                ];
            }

            $groupKey = $this->ticketGroupKey(
                $unitSelection['ticket'],
                $unitSelection['variation_name']
            );

            if (!isset($holderGroups[$holderKey]['ticket_groups'][$groupKey])) {
                $holderGroups[$holderKey]['ticket_groups'][$groupKey] = [
                    'ticket' => $unitSelection['ticket'],
                    'variation_name' => $unitSelection['variation_name'],
                    'qty' => 0,
                ];
            }

            $holderGroups[$holderKey]['ticket_groups'][$groupKey]['qty']++;
        }

        return array_map(function (array $group): array {
            $group['ticket_groups'] = array_values($group['ticket_groups']);
            return $group;
        }, array_values($holderGroups));
    }

    private function buildUnitSelections(array $normalizedSelections): array
    {
        $unitSelections = [];
        $selectionCountsByTicket = [];
        foreach ($normalizedSelections as $selection) {
            $ticketId = (int) ($selection['ticket']->id ?? 0);
            $qty = max(0, (int) ($selection['qty'] ?? 0));
            if ($ticketId <= 0 || $qty <= 0) {
                continue;
            }

            $selectionCountsByTicket[$ticketId] = ($selectionCountsByTicket[$ticketId] ?? 0) + 1;
        }

        $selectionIndex = 0;
        foreach ($normalizedSelections as $selection) {
            $ticketId = (int) $selection['ticket']->id;
            $qty = max(0, (int) ($selection['qty'] ?? 0));
            if ($ticketId <= 0 || $qty <= 0) {
                continue;
            }

            $selectionIndex++;
            $variationName = isset($selection['variation_name'])
                ? trim((string) $selection['variation_name'])
                : null;
            $requiresScopedSlotKey = ($selectionCountsByTicket[$ticketId] ?? 0) > 1
                || $variationName !== null && $variationName !== '';
            for ($unitIndex = 1; $unitIndex <= $qty; $unitIndex++) {
                $unitSelections[] = [
                    'slot_key' => $requiresScopedSlotKey
                        ? $ticketId . ':' . $selectionIndex . ':' . $unitIndex
                        : $ticketId . ':' . $unitIndex,
                    'ticket' => $selection['ticket'],
                    'variation_name' => $selection['variation_name'] ?? null,
                ];
            }
        }

        return $unitSelections;
    }

    private function ticketGroupKey(Ticket $ticket, ?string $variationName = null): string
    {
        return (int) $ticket->id . '|' . trim((string) $variationName);
    }

    private function holderLabel(?Customer $holder, ?Customer $buyer): string
    {
        if (!$holder) {
            return 'Este usuario';
        }

        if ($buyer && (int) $holder->id === (int) $buyer->id) {
            return 'Tu cuenta';
        }

        $username = trim((string) ($holder->username ?? ''));
        if ($username !== '') {
            return '@' . ltrim($username, '@');
        }

        $name = trim((string) (($holder->fname ?? '') . ' ' . ($holder->lname ?? '')));
        if ($name !== '') {
            return $name;
        }

        return 'Este usuario';
    }

    private function resolveMaxAllowed(Ticket $ticket, ?array $variation = null): ?int
    {
        if ($ticket->pricing_type === 'variation' && $variation !== null) {
            $variationType = strtolower((string) ($variation['max_ticket_buy_type'] ?? ''));
            $variationMax = (int) ($variation['v_max_ticket_buy'] ?? 0);
            if ($variationType === 'limited' && $variationMax > 0) {
                return $variationMax;
            }

            return null;
        }

        $ticketLimitType = strtolower((string) ($ticket->max_ticket_buy_type ?? ''));
        $ticketMax = (int) ($ticket->max_buy_ticket ?? 0);
        if ($ticketLimitType === 'limited' && $ticketMax > 0) {
            return $ticketMax;
        }

        return null;
    }

    private function resolveVariation(Ticket $ticket, string $variationName): ?array
    {
        $variations = json_decode((string) $ticket->variations, true);
        if (!is_array($variations)) {
            return null;
        }

        foreach ($variations as $variation) {
            if (!is_array($variation)) {
                continue;
            }

            if (trim((string) ($variation['name'] ?? '')) === trim($variationName)) {
                return $variation;
            }
        }

        return null;
    }

    private function countVariationBookingQuantity($bookingVariationJson, int $ticketId, ?string $variationName = null): int
    {
        $variationRows = json_decode((string) $bookingVariationJson, true);
        if (!is_array($variationRows)) {
            return 0;
        }

        $qty = 0;
        foreach ($variationRows as $variationRow) {
            if (!is_array($variationRow)) {
                continue;
            }

            if ((int) ($variationRow['ticket_id'] ?? 0) !== $ticketId) {
                continue;
            }

            if ($variationName !== null && trim((string) ($variationRow['name'] ?? '')) !== trim($variationName)) {
                continue;
            }

            $qty += max(1, (int) ($variationRow['qty'] ?? 1));
        }

        return $qty;
    }

    private function countBookingQuantityForTicket(Booking $booking, Event $event, Ticket $ticket, ?string $variationName = null): int
    {
        $ticketIdsForEvent = $event->tickets()->pluck('id')->map(fn ($id) => (int) $id)->all();
        $singleTicketEvent = count($ticketIdsForEvent) === 1 && (int) ($ticketIdsForEvent[0] ?? 0) === (int) $ticket->id;

        if ($variationName !== null) {
            return $this->countVariationBookingQuantity($booking->variation, (int) $ticket->id, $variationName);
        }

        if ((int) ($booking->ticket_id ?? 0) === (int) $ticket->id) {
            return max(1, (int) ($booking->quantity ?? 1));
        }

        $variationQty = $this->countVariationBookingQuantity($booking->variation, (int) $ticket->id, null);
        if ($variationQty > 0) {
            return $variationQty;
        }

        if ($singleTicketEvent && empty($booking->variation) && empty($booking->ticket_id)) {
            return max(1, (int) ($booking->quantity ?? 1));
        }

        return 0;
    }
}
