<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Reservation\TicketReservation;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class ReservationStatusNotificationService
{
    public function __construct(private NotificationService $notificationService)
    {
    }

    public function notifyCustomer(TicketReservation $reservation, string $action, array $context = []): bool
    {
        try {
            return $this->notifyCustomerNow($reservation, $action, $context);
        } catch (\Throwable $e) {
            Log::warning('Reservation status notification failed.', [
                'reservation_id' => $reservation->id,
                'action' => $action,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    public function notifyCustomerNow(TicketReservation $reservation, string $action, array $context = []): bool
    {
        $reservation->loadMissing('customer', 'event.information');

        $customer = $reservation->customer;
        if (!$customer instanceof Customer) {
            return false;
        }

        [$title, $body, $data] = $this->buildMessage($reservation, $action, $context);

        $emailSent = $this->sendEmailFallback($customer, $action, $title, $body);
        $pushSent = false;

        try {
            $pushSent = $this->notificationService->notifyUser($customer, $title, $body, $data);
        } catch (\Throwable $e) {
            Log::warning('Reservation push notification failed.', [
                'customer_id' => $customer->id,
                'reservation_id' => $reservation->id,
                'action' => $action,
                'error' => $e->getMessage(),
            ]);
        }

        return $emailSent || $pushSent;
    }

    protected function buildMessage(TicketReservation $reservation, string $action, array $context): array
    {
        $eventTitle = trim((string) optional($reservation->event?->information)->title) ?: ('Evento #' . $reservation->event_id);
        $reservationCode = trim((string) $reservation->reservation_code) ?: ('RSV-' . $reservation->id);
        $expiresAt = $this->formatDate($context['expires_at'] ?? $reservation->expires_at);
        $finalDueDate = $this->formatDate($context['final_due_date'] ?? $reservation->final_due_date);
        $grossAmount = isset($context['gross_amount']) ? number_format((float) $context['gross_amount'], 2) : null;
        $bookingCount = (int) ($context['booking_count'] ?? 0);

        [$title, $body] = match ($action) {
            'extended' => [
                'Duty: reserva actualizada',
                "Tu reserva {$reservationCode} para {$eventTitle} fue extendida. Nuevo vencimiento: {$expiresAt}.",
            ],
            'cancelled' => [
                'Duty: reserva cancelada',
                "Tu reserva {$reservationCode} para {$eventTitle} fue cancelada. Si aplica un reembolso, el equipo lo procesará por separado.",
            ],
            'marked_defaulted' => [
                'Duty: reserva vencida',
                "Tu reserva {$reservationCode} para {$eventTitle} fue marcada como incumplida y el cupo fue liberado.",
            ],
            'reactivated' => [
                'Duty: reserva reactivada',
                "Tu reserva {$reservationCode} para {$eventTitle} volvió a estar activa. Completa el pago antes de {$expiresAt}.",
            ],
            'payment_due_reminder_24h' => [
                'Duty: tu reserva vence pronto',
                "Tu reserva {$reservationCode} para {$eventTitle} vence en menos de 24 horas. Completa el pago antes de {$expiresAt}.",
            ],
            'payment_due_reminder_2h' => [
                'Duty: último aviso de reserva',
                "Tu reserva {$reservationCode} para {$eventTitle} vence en menos de 2 horas. Completa el pago antes de {$expiresAt}.",
            ],
            'converted_to_bookings' => [
                'Duty: boletas emitidas',
                "Tu reserva {$reservationCode} para {$eventTitle} fue convertida en {$bookingCount} booking(s). Ya puedes revisar tus boletas.",
            ],
            'refund_processed' => [
                'Duty: reembolso procesado',
                "Procesamos un reembolso de \${$grossAmount} para tu reserva {$reservationCode} de {$eventTitle}.",
            ],
            default => [
                'Duty: actualización de reserva',
                "Tu reserva {$reservationCode} para {$eventTitle} cambió a estado {$reservation->status}.",
            ],
        };

        return [
            $title,
            $body,
            [
                'type' => 'reservation_update',
                'action' => (string) $action,
                'reservation_id' => (string) $reservation->id,
                'reservation_code' => (string) $reservationCode,
                'event_id' => (string) $reservation->event_id,
                'status' => (string) $reservation->status,
                'screen' => 'reservations',
                'expires_at' => $expiresAt,
                'final_due_date' => $finalDueDate,
                'gross_amount' => (string) ($grossAmount ?? ''),
            ],
        ];
    }

    protected function formatDate(mixed $value): string
    {
        if (empty($value)) {
            return 'sin fecha definida';
        }

        try {
            return Carbon::parse($value)->format('Y-m-d H:i');
        } catch (\Throwable) {
            return (string) $value;
        }
    }

    protected function sendEmailFallback(Customer $customer, string $action, string $title, string $body): bool
    {
        if (!$this->shouldSendEmailFallback($action) || empty($customer->email)) {
            return false;
        }

        try {
            Mail::raw($body, function ($message) use ($customer, $title) {
                $message->to($customer->email)->subject($title);
            });
            return true;
        } catch (\Throwable $e) {
            Log::warning('Reservation email notification failed.', [
                'customer_id' => $customer->id,
                'action' => $action,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    protected function shouldSendEmailFallback(string $action): bool
    {
        return in_array($action, [
            'cancelled',
            'marked_defaulted',
            'refund_processed',
            'payment_due_reminder_24h',
            'payment_due_reminder_2h',
        ], true);
    }
}
