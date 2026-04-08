<?php

namespace App\Services;

use App\Jobs\SendReviewPromptNotificationJob;
use App\Models\Customer;
use App\Models\ReviewPromptDelivery;
use Illuminate\Support\Facades\Log;

class ReviewPromptNotificationService
{
    public function __construct(protected NotificationService $notificationService)
    {
    }

    public function notifyCustomer(Customer $customer, array $prompt, ?ReviewPromptDelivery $delivery = null): void
    {
        try {
            SendReviewPromptNotificationJob::dispatch((int) $customer->id, $prompt, $delivery?->id);
            return;
        } catch (\Throwable $e) {
            Log::warning('Review prompt notification dispatch failed; using sync fallback.', [
                'customer_id' => $customer->id,
                'event_id' => $prompt['event_id'] ?? null,
                'delivery_id' => $delivery?->id,
                'error' => $e->getMessage(),
            ]);
        }

        $this->notifyCustomerNowById((int) $customer->id, $prompt, $delivery?->id);
    }

    public function notifyCustomerNowById(int $customerId, array $prompt, ?int $deliveryId = null): void
    {
        $customer = Customer::find($customerId);
        $delivery = $deliveryId ? ReviewPromptDelivery::find($deliveryId) : null;

        if (!$customer) {
            $this->markDelivery($delivery, 'failed', [
                'error' => 'Customer not found.',
            ]);
            return;
        }

        [$title, $body, $data] = $this->buildMessage($prompt);

        try {
            $sent = $this->notificationService->notifyUser($customer, $title, $body, $data);

            $this->markDelivery(
                $delivery,
                $sent ? 'delivered' : 'no_device_token',
                [
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'data' => $data,
                    ],
                ],
                $sent
            );
        } catch (\Throwable $e) {
            Log::warning('Review prompt push notification failed.', [
                'customer_id' => $customer->id,
                'event_id' => $prompt['event_id'] ?? null,
                'delivery_id' => $delivery?->id,
                'error' => $e->getMessage(),
            ]);

            $this->markDelivery($delivery, 'failed', [
                'error' => $e->getMessage(),
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                    'data' => $data,
                ],
            ]);
        }
    }

    protected function buildMessage(array $prompt): array
    {
        $eventTitle = trim((string) ($prompt['event_title'] ?? 'your recent event')) ?: 'your recent event';
        $targetsCount = count($prompt['targets'] ?? []);
        $title = 'Duty: comparte tu experiencia';
        $body = $targetsCount > 1
            ? "Cuéntanos cómo estuvo {$eventTitle}. Tienes {$targetsCount} reviews pendientes."
            : "Cuéntanos cómo estuvo {$eventTitle}. Tienes 1 review pendiente.";

        return [
            $title,
            $body,
            [
                'type' => 'review_prompt',
                'event_id' => (string) ($prompt['event_id'] ?? ''),
                'booking_id' => (string) ($prompt['booking_id'] ?? ''),
                'screen' => 'reviews_pending',
            ],
        ];
    }

    protected function markDelivery(
        ?ReviewPromptDelivery $delivery,
        string $status,
        array $context = [],
        bool $markDeliveredAt = false
    ): void {
        if (!$delivery) {
            return;
        }

        $meta = is_array($delivery->meta) ? $delivery->meta : [];
        $meta = array_replace_recursive($meta, $context);

        $delivery->status = $status;
        $delivery->meta = $meta;

        if ($markDeliveredAt) {
            $delivery->delivered_at = now();
        }

        $delivery->save();
    }
}
