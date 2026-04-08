<?php

namespace App\Jobs;

use App\Services\IdentityModerationNotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendIdentityModerationNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $identityId;
    public string $action;
    public array $context;

    public function __construct(int $identityId, string $action, array $context = [])
    {
        $this->identityId = $identityId;
        $this->action = $action;
        $this->context = $context;
    }

    public function handle(IdentityModerationNotificationService $notificationService): void
    {
        $notificationService->notifyOwnerNowById(
            $this->identityId,
            $this->action,
            $this->context
        );
    }
}
