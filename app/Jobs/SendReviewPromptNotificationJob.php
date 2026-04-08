<?php

namespace App\Jobs;

use App\Services\ReviewPromptNotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendReviewPromptNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public int $customerId,
        public array $prompt,
        public ?int $deliveryId = null
    ) {
    }

    public function handle(ReviewPromptNotificationService $notificationService): void
    {
        $notificationService->notifyCustomerNowById(
            $this->customerId,
            $this->prompt,
            $this->deliveryId
        );
    }
}
