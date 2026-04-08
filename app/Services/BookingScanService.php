<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event\Booking;

class BookingScanService
{
    public function __construct(
        protected LoyaltyService $loyaltyService,
        protected TicketJourneyService $ticketJourneyService,
        protected EventTicketRewardService $eventTicketRewardService,
    )
    {
    }

    public function setTicketScanStatus(Booking $booking, string|int $ticketId, bool $shouldBeScanned): array
    {
        $ticketKey = (string) $ticketId;
        $scannedTickets = $this->normalizeScannedTickets($booking->scanned_tickets);

        $hadAttendance = !empty($scannedTickets) || (int) ($booking->scan_status ?? 0) === 1;
        $alreadyScanned = in_array($ticketKey, $scannedTickets, true);

        if ($shouldBeScanned) {
            if (!$alreadyScanned) {
                $scannedTickets[] = $ticketKey;
            }
        } else {
            $scannedTickets = array_values(array_filter(
                $scannedTickets,
                static fn ($existingTicketId): bool => $existingTicketId !== $ticketKey
            ));
        }

        $scannedTickets = array_values(array_unique($scannedTickets));
        $hasAttendance = !empty($scannedTickets);

        $booking->scanned_tickets = $hasAttendance ? json_encode($scannedTickets) : null;
        $booking->scan_status = $hasAttendance ? 1 : 0;
        $booking->save();

        if ($shouldBeScanned && !$alreadyScanned) {
            $this->ticketJourneyService->record($booking, 'scanned', [
                'actor_customer_id' => is_numeric((string) ($booking->customer_id ?? null))
                    ? (int) $booking->customer_id
                    : null,
                'target_customer_id' => is_numeric((string) ($booking->customer_id ?? null))
                    ? (int) $booking->customer_id
                    : null,
                'metadata' => [
                    'ticket_key' => $ticketKey,
                ],
            ]);

            $this->eventTicketRewardService->activateForTicketScan($booking, $ticketKey);
        }

        $loyaltyTransaction = null;
        if (!$hadAttendance && $hasAttendance) {
            $loyaltyTransaction = $this->awardAttendanceIfEligible($booking);
        }

        return [
            'changed' => $shouldBeScanned ? !$alreadyScanned : $alreadyScanned,
            'scan_status' => $booking->scan_status,
            'scanned_tickets' => $scannedTickets,
            'loyalty_transaction_id' => $loyaltyTransaction?->id,
        ];
    }

    protected function awardAttendanceIfEligible(Booking $booking)
    {
        if (!$this->isAttendanceEligible($booking)) {
            return null;
        }

        $customer = Customer::find((int) $booking->customer_id);
        if (!$customer) {
            return null;
        }

        return $this->loyaltyService->awardFromRule(
            $customer,
            'attendance_confirmed',
            'booking_attendance',
            (string) ($booking->order_number ?: $booking->booking_id ?: $booking->id),
            [
                'event_id' => (int) ($booking->event_id ?? 0),
                'booking_id' => (int) $booking->id,
            ]
        );
    }

    protected function isAttendanceEligible(Booking $booking): bool
    {
        $customerId = $booking->customer_id;
        if (empty($customerId) || !is_numeric((string) $customerId)) {
            return false;
        }

        $paymentStatus = strtolower(trim((string) ($booking->paymentStatus ?? '')));

        return in_array($paymentStatus, ['completed', 'free'], true)
            || $booking->paymentStatus === 1
            || $booking->paymentStatus === true;
    }

    protected function normalizeScannedTickets(mixed $rawValue): array
    {
        if (empty($rawValue)) {
            return [];
        }

        $decoded = is_array($rawValue) ? $rawValue : json_decode((string) $rawValue, true);
        if (!is_array($decoded)) {
            return [];
        }

        return array_values(array_map(
            static fn ($value): string => (string) $value,
            array_filter($decoded, static fn ($value): bool => $value !== null && $value !== '')
        ));
    }
}
