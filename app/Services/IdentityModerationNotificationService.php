<?php

namespace App\Services;

use App\Jobs\SendIdentityModerationNotificationJob;
use App\Models\Identity;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class IdentityModerationNotificationService
{
    protected NotificationService $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function notifyOwner(Identity $identity, string $action, array $context = []): void
    {
        try {
            SendIdentityModerationNotificationJob::dispatch((int) $identity->id, $action, $context);
            return;
        } catch (\Throwable $e) {
            Log::warning('Identity moderation notification dispatch failed; using sync fallback.', [
                'identity_id' => $identity->id,
                'action' => $action,
                'error' => $e->getMessage(),
            ]);
        }

        $this->notifyOwnerNow($identity, $action, $context);
    }

    public function notifyOwnerNowById(int $identityId, string $action, array $context = []): void
    {
        $identity = Identity::with('owner')->find($identityId);
        if (!$identity) {
            return;
        }

        $this->notifyOwnerNow($identity, $action, $context);
    }

    public function notifyOwnerNow(Identity $identity, string $action, array $context = []): void
    {
        $owner = $identity->relationLoaded('owner')
            ? $identity->owner
            : $identity->owner()->first();

        if (!$owner) {
            return;
        }

        [$title, $body] = $this->buildMessage($identity, $action, $context);

        if (!empty($owner->email)) {
            try {
                Mail::raw($body, function ($message) use ($owner, $title) {
                    $message->to($owner->email)->subject($title);
                });
            } catch (\Throwable $e) {
                Log::warning('Identity moderation email notification failed.', [
                    'identity_id' => $identity->id,
                    'owner_user_id' => $owner->id,
                    'action' => $action,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        try {
            $this->notificationService->notifyUser($owner, $title, $body, [
                'type' => 'identity_moderation',
                'identity_id' => (string) $identity->id,
                'identity_type' => (string) $identity->type,
                'action' => (string) $action,
                'status' => (string) $identity->status,
            ]);
        } catch (\Throwable $e) {
            Log::warning('Identity moderation push notification failed.', [
                'identity_id' => $identity->id,
                'owner_user_id' => $owner->id,
                'action' => $action,
                'error' => $e->getMessage(),
            ]);
        }
    }

    protected function buildMessage(Identity $identity, string $action, array $context): array
    {
        $displayName = $identity->display_name ?: ('Identity #' . $identity->id);
        $type = strtoupper((string) $identity->type);

        return match ($action) {
            'approved' => [
                "Duty: $type profile approved",
                "Your $type profile \"$displayName\" has been approved and is now active.",
            ],
            'rejected' => [
                "Duty: $type profile rejected",
                "Your $type profile \"$displayName\" was rejected. Reason: " . (($context['reason'] ?? '') ?: 'No reason provided.'),
            ],
            'request_info' => [
                "Duty: more information required",
                "Your $type profile \"$displayName\" needs more information. Request: " . (($context['reason'] ?? '') ?: 'Please review your profile details.'),
            ],
            'suspended' => [
                "Duty: $type profile suspended",
                "Your $type profile \"$displayName\" has been suspended. Reason: " . (($context['reason'] ?? '') ?: 'No reason provided.'),
            ],
            'reactivated' => [
                "Duty: $type profile reactivated",
                "Your $type profile \"$displayName\" has been reactivated and is active again.",
            ],
            default => [
                "Duty: profile status updated",
                "Your profile \"$displayName\" has a new status: {$identity->status}.",
            ],
        };
    }
}
