<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event\Booking;
use App\Models\ReviewPromptDelivery;
use Carbon\Carbon;
use Illuminate\Support\Facades\Schema;

class ReviewPromptDispatchService
{
    private const RETRY_AFTER_HOURS = 6;

    public function __construct(
        protected ReviewService $reviewService,
        protected ReviewPromptNotificationService $notificationService
    ) {
    }

    public function dispatchPendingPrompts(): array
    {
        if (!Schema::hasTable('reviews') || !Schema::hasTable('review_prompt_deliveries')) {
            return [
                'customers_scanned' => 0,
                'queued' => 0,
                'retried' => 0,
                'skipped_existing' => 0,
            ];
        }

        $customerIds = Booking::query()
            ->where('paymentStatus', 'Completed')
            ->whereNotNull('customer_id')
            ->distinct()
            ->pluck('customer_id');

        $summary = [
            'customers_scanned' => 0,
            'queued' => 0,
            'retried' => 0,
            'skipped_existing' => 0,
        ];

        foreach ($customerIds as $customerId) {
            $customer = Customer::find($customerId);
            if (!$customer) {
                continue;
            }

            $summary['customers_scanned']++;
            $prompts = $this->reviewService->pendingFor($customer);

            foreach ($prompts as $prompt) {
                $delivery = ReviewPromptDelivery::query()->firstOrNew([
                    'customer_id' => (int) $customer->id,
                    'event_id' => (int) ($prompt['event_id'] ?? 0),
                ]);

                $isRetry = $delivery->exists;
                if ($isRetry && !$this->shouldRetry($delivery)) {
                    $summary['skipped_existing']++;
                    continue;
                }

                $delivery->booking_id = (int) ($prompt['booking_id'] ?? 0) ?: $delivery->booking_id;
                $delivery->status = 'queued';
                $delivery->dispatched_at = now();
                $delivery->meta = $this->buildMeta($prompt, $delivery->meta, $isRetry);
                $delivery->save();

                $this->notificationService->notifyCustomer($customer, $prompt, $delivery);
                if ($isRetry) {
                    $summary['retried']++;
                } else {
                    $summary['queued']++;
                }
            }
        }

        return $summary;
    }

    private function shouldRetry(ReviewPromptDelivery $delivery): bool
    {
        if ($delivery->status === 'delivered') {
            return false;
        }

        if (!$delivery->dispatched_at instanceof Carbon) {
            return true;
        }

        return $delivery->dispatched_at->lte(now()->subHours(self::RETRY_AFTER_HOURS));
    }

    private function buildMeta(array $prompt, mixed $existingMeta, bool $isRetry): array
    {
        $meta = is_array($existingMeta) ? $existingMeta : [];
        $attempts = (int) ($meta['dispatch_attempts'] ?? 0);

        return array_merge($meta, [
            'event_title' => $prompt['event_title'] ?? ($meta['event_title'] ?? null),
            'event_end_at' => $prompt['event_end_at'] ?? ($meta['event_end_at'] ?? null),
            'pending_targets_count' => count($prompt['targets'] ?? []),
            'target_types' => collect($prompt['targets'] ?? [])->pluck('target_type')->values()->all(),
            'dispatch_attempts' => $attempts > 0 ? $attempts + 1 : ($isRetry ? 2 : 1),
        ]);
    }
}
