<?php

namespace App\Services;

use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class EventCheckoutSelectionService
{
    /**
     * Normalize checkout input into a stable shape consumed by checkoutVerify.
     *
     * @return array{
     *   quantity_list: array<int, mixed>,
     *   quantity_scalar: float,
     *   selected_seats: array<int, array<string, mixed>>,
     *   selected_slot_seat: array<int, array<string, mixed>>
     * }
     */
    public function buildContext(Request $request): array
    {
        $seatData = $request->input('seat_data');
        $quantity = $request->input('quantity');

        $quantityList = is_array($quantity) ? $quantity : [$quantity];
        $quantityScalar = is_array($quantity)
            ? array_sum(array_map(static fn($qty) => (float) $qty, $quantity))
            : (float) $quantity;

        $selectedSeats = !empty($seatData) ? $seatData : [];
        $selectedSlotSeat = $this->groupSeatsBySlot(collect($selectedSeats))->toArray();

        return [
            'quantity_list' => $quantityList,
            'quantity_scalar' => $quantityScalar,
            'selected_seats' => $selectedSeats,
            'selected_slot_seat' => $selectedSlotSeat,
        ];
    }

    /**
     * Replicates existing selection semantics in checkoutVerify.
     */
    public function hasAnySelection(
        string $eventType,
        string $pricingType,
        array $quantityList,
        float $quantityScalar,
        array $selectedSlotSeat
    ): bool {
        if ($eventType === 'venue') {
            foreach ($quantityList as $qty) {
                if ((float) $qty > 0) {
                    return true;
                }
            }
            return count($selectedSlotSeat) > 0;
        }

        if ($pricingType === 'free') {
            // Legacy behavior: free pricing is considered selected even when quantity is zero.
            return true;
        }

        if ($pricingType === 'normal') {
            return $quantityScalar > 0 || count($selectedSlotSeat) > 0;
        }

        foreach ($quantityList as $qty) {
            if ((float) $qty > 0) {
                return true;
            }
        }

        return false;
    }

    private function groupSeatsBySlot(Collection $selectedSeats): Collection
    {
        return $selectedSeats
            ->groupBy('slot_id')
            ->map(function ($group) {
                $first = $group->first();

                return [
                    'slot_id' => $first['slot_id'],
                    'slot_name' => $first['slot_name'],
                    'event_id' => $first['event_id'],
                    'ticket_id' => $first['ticket_id'],
                    'slot_unique_id' => $first['slot_unique_id'],
                    'slot_type' => $first['s_type'],
                    'seats' => collect($group)->map(function ($seat) {
                        return [
                            'seat_id' => $seat['id'],
                            'seat_name' => $seat['name'],
                            'discount' => $seat['discount'],
                            'price' => $seat['price'],
                            'payable_price' => $seat['payable_price'],
                        ];
                    })->values()->toArray(),
                ];
            })
            ->map(function ($slot) {
                $slot['seat_count'] = count($slot['seats']);
                $slot['seats_price'] = collect($slot['seats'])->sum('payable_price');
                return $slot;
            })
            ->values();
    }
}
