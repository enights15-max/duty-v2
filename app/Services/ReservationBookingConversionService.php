<?php

namespace App\Services;

use App\Models\BasicSettings\Basic;
use App\Models\Earning;
use App\Models\Event\Booking;
use App\Models\Event\BookingPaymentAllocation;
use App\Models\Reservation\TicketReservation;
use App\Models\Transaction;
use Exception;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ReservationBookingConversionService
{
    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService,
        private TicketJourneyService $ticketJourneyService,
        private EventTreasuryService $eventTreasuryService,
    ) {
    }

    /**
     * @return Collection<int, Booking>
     */
    public function convert(TicketReservation $reservation): Collection
    {
        $reservation->load(['event', 'ticket', 'payments']);

        if ($reservation->status !== 'completed') {
            throw new Exception('Only completed reservations can be converted to bookings.');
        }

        if (!empty($reservation->booking_order_number)) {
            return Booking::query()
                ->where('order_number', $reservation->booking_order_number)
                ->orderBy('id')
                ->with('paymentAllocations')
                ->get();
        }

        if (!Schema::hasTable('bookings')) {
            throw new Exception('Bookings table is not available for reservation conversion.');
        }

        $event = $reservation->event;
        if (!$event) {
            throw new Exception('Reservation event not found.');
        }

        $settings = $this->resolveBasicSettings();
        $feeTotal = round((float) $reservation->payments->sum('fee_amount'), 2);
        $grossTotal = round((float) $reservation->total_amount + $feeTotal, 2);
        $commissionPercent = (float) ($settings['commission'] ?? 0);
        $commissionTotal = round(($grossTotal * $commissionPercent) / 100, 2);
        $orderNumber = 'RSVBOOK-' . $reservation->reservation_code;

        return DB::transaction(function () use ($reservation, $event, $settings, $feeTotal, $commissionTotal, $orderNumber) {
            $bookings = collect();
            $priceParts = $this->splitAmount((float) $reservation->total_amount, (int) $reservation->quantity);
            $feeParts = $this->splitAmount($feeTotal, (int) $reservation->quantity);
            $commissionParts = $this->splitAmount($commissionTotal, (int) $reservation->quantity);

            for ($index = 0; $index < (int) $reservation->quantity; $index++) {
                $payload = [
                    'customer_id' => $reservation->customer_id,
                    'booking_id' => uniqid(),
                    'order_number' => $orderNumber,
                    'fname' => $reservation->fname,
                    'lname' => $reservation->lname,
                    'email' => $reservation->email,
                    'phone' => $reservation->phone,
                    'country' => $reservation->country,
                    'state' => $reservation->state,
                    'city' => $reservation->city,
                    'zip_code' => $reservation->zip_code,
                    'address' => $reservation->address,
                    'event_id' => $reservation->event_id,
                    'organizer_id' => $event->organizer_id,
                    'variation' => null,
                    'price' => $priceParts[$index],
                    'tax' => $feeParts[$index],
                    'commission' => $commissionParts[$index],
                    'tax_percentage' => (float) ($settings['tax'] ?? 0),
                    'commission_percentage' => (float) ($settings['commission'] ?? 0),
                    'quantity' => 1,
                    'discount' => 0,
                    'early_bird_discount' => 0,
                    'currencyText' => $settings['base_currency_text'] ?? 'DOP',
                    'currencyTextPosition' => $settings['base_currency_text_position'] ?? 'right',
                    'currencySymbol' => $settings['base_currency_symbol'] ?? '$',
                    'currencySymbolPosition' => $settings['base_currency_symbol_position'] ?? 'left',
                    'paymentMethod' => $reservation->payment_method ?: 'reservation',
                    'gatewayType' => 'online',
                    'paymentStatus' => 'completed',
                    'invoice' => null,
                    'attachmentFile' => null,
                    'event_date' => $reservation->event_date,
                    'scan_status' => 0,
                    'conversation_id' => null,
                    'fcm_token' => null,
                    'is_transferable' => true,
                    'is_listed' => false,
                    'listing_price' => 0,
                    'transfer_status' => null,
                ];

                if (Schema::hasColumn('bookings', 'reservation_id')) {
                    $payload['reservation_id'] = $reservation->id;
                }

                if (Schema::hasColumn('bookings', 'ticket_id')) {
                    $payload['ticket_id'] = $reservation->ticket_id;
                }

                if (Schema::hasColumn('bookings', 'is_resellable')) {
                    $payload['is_resellable'] = true;
                }

                if (Schema::hasColumn('bookings', 'resale_restriction_reason')) {
                    $payload['resale_restriction_reason'] = null;
                }

                if (Schema::hasColumn('bookings', 'acquisition_source')) {
                    $payload['acquisition_source'] = 'reservation_conversion';
                }

                if (Schema::hasColumn('bookings', 'coupon_code')) {
                    $payload['coupon_code'] = null;
                }

                $bookings->push(Booking::create($payload));
            }

            $this->copyPaymentAllocations($reservation, $bookings);
            $reservation->booking_order_number = $orderNumber;
            $reservation->save();
            $this->eventTreasuryService->syncReservationRevenue($reservation->fresh(['event', 'payments']));
            $this->recordFinancialSideEffects($bookings);

            return Booking::query()
                ->where('order_number', $orderNumber)
                ->orderBy('id')
                ->with('paymentAllocations')
                ->get();
        });
    }

    /**
     * @param Collection<int, Booking> $bookings
     */
    private function copyPaymentAllocations(TicketReservation $reservation, Collection $bookings): void
    {
        if (!Schema::hasTable('booking_payment_allocations')) {
            return;
        }

        foreach ($reservation->payments as $payment) {
            $amountParts = $this->splitAmount((float) $payment->amount, $bookings->count());
            $feeParts = $this->splitAmount((float) $payment->fee_amount, $bookings->count());

            foreach ($bookings->values() as $index => $booking) {
                if (($amountParts[$index] ?? 0) <= 0 && ($feeParts[$index] ?? 0) <= 0) {
                    continue;
                }

                BookingPaymentAllocation::create([
                    'booking_id' => $booking->id,
                    'source_type' => $payment->source_type,
                    'amount' => $amountParts[$index] ?? 0,
                    'fee_amount' => $feeParts[$index] ?? 0,
                    'total_amount' => round(($amountParts[$index] ?? 0) + ($feeParts[$index] ?? 0), 2),
                    'reference_type' => $payment->reference_type,
                    'reference_id' => $payment->reference_id,
                    'meta' => array_merge(
                        is_array($payment->meta) ? $payment->meta : [],
                        [
                            'source_amount' => round((float) ($amountParts[$index] ?? 0), 2),
                            'source_fee_amount' => round((float) ($feeParts[$index] ?? 0), 2),
                        ]
                    ),
                ]);
            }
        }
    }

    /**
     * @param Collection<int, Booking> $bookings
     */
    private function recordFinancialSideEffects(Collection $bookings): void
    {
        foreach ($bookings as $booking) {
            if (Schema::hasTable('earnings')) {
                $earning = Earning::query()->first();
                if ($earning) {
                    $earning->total_revenue = (float) $earning->total_revenue + (float) $booking->price + (float) $booking->tax;
                    if (bookingHasProfessionalOwner($booking)) {
                        $earning->total_earning = (float) $earning->total_earning + (float) $booking->tax + (float) $booking->commission;
                    } else {
                        $earning->total_earning = (float) $earning->total_earning + (float) $booking->price + (float) $booking->tax;
                    }
                    $earning->save();
                }
            }

            if (Schema::hasTable('transactions')) {
                $booking->paymentStatus = 1;
                $booking->transcation_type = 1;
                storeTranscation($booking);
            }

            if (bookingHasProfessionalOwner($booking)) {
                storeProfessionalOwner($booking);
            }

            $this->ticketJourneyService->record($booking, 'reservation_conversion', [
                'actor_customer_id' => is_numeric((string) ($booking->customer_id ?? null))
                    ? (int) $booking->customer_id
                    : null,
                'target_customer_id' => is_numeric((string) ($booking->customer_id ?? null))
                    ? (int) $booking->customer_id
                    : null,
                'price' => (float) ($booking->price ?? 0),
                'metadata' => [
                    'payment_status' => $booking->paymentStatus,
                    'source' => 'reservation_conversion',
                ],
            ]);
        }
    }

    /**
     * @return array<int, float>
     */
    private function splitAmount(float $amount, int $parts): array
    {
        $parts = max(1, $parts);
        $base = round($amount / $parts, 2);
        $result = array_fill(0, $parts, $base);
        $allocated = round(array_sum(array_slice($result, 0, $parts - 1)), 2);
        $result[$parts - 1] = round($amount - $allocated, 2);

        return $result;
    }

    /**
     * @return array<string, mixed>
     */
    private function resolveBasicSettings(): array
    {
        if (!Schema::hasTable('basic_settings')) {
            return [
                'base_currency_text' => 'DOP',
                'base_currency_text_position' => 'right',
                'base_currency_symbol' => '$',
                'base_currency_symbol_position' => 'left',
                'tax' => 0,
                'commission' => 0,
            ];
        }

        $basic = Basic::query()->select([
            'base_currency_text',
            'base_currency_text_position',
            'base_currency_symbol',
            'base_currency_symbol_position',
            'tax',
            'commission',
        ])->first();

        if (!$basic) {
            return [
                'base_currency_text' => 'DOP',
                'base_currency_text_position' => 'right',
                'base_currency_symbol' => '$',
                'base_currency_symbol_position' => 'left',
                'tax' => 0,
                'commission' => 0,
            ];
        }

        return $basic->toArray();
    }
}
