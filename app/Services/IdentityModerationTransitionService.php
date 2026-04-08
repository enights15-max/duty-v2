<?php

namespace App\Services;

use App\Models\Identity;
use Carbon\Carbon;
use RuntimeException;
use InvalidArgumentException;
use Illuminate\Support\Str;

class IdentityModerationTransitionService
{
    /**
     * Allowed actions by current status.
     */
    protected array $allowedActions = [
        'pending' => ['approve', 'reject', 'request_info'],
        'active' => ['suspend'],
        'suspended' => ['reactivate'],
    ];

    /**
     * Apply a moderation action to an identity.
     *
     * @throws RuntimeException
     * @throws InvalidArgumentException
     */
    public function apply(Identity $identity, string $action, ?int $adminId = null, array $payload = []): array
    {
        $normalizedAction = strtolower(trim($action));
        $currentStatus = strtolower(trim((string) $identity->status));

        if (!$this->isKnownAction($normalizedAction)) {
            throw new InvalidArgumentException('Unsupported moderation action.');
        }

        if (!$this->canTransition($currentStatus, $normalizedAction)) {
            throw new RuntimeException($this->buildInvalidTransitionMessage($normalizedAction));
        }

        $meta = is_array($identity->meta) ? $identity->meta : [];
        $context = [];
        $nowIso = Carbon::now()->toIso8601String();

        switch ($normalizedAction) {
            case 'approve':
                $note = $this->sanitizeText($payload['note'] ?? null);
                unset($meta['rejection_reason'], $meta['revision_request']);
                $meta['approved_at'] = $nowIso;
                $meta['approved_by_admin_id'] = $adminId;
                $actionId = $this->appendModerationHistory($meta, 'approved', $adminId, [
                    'note' => $note !== '' ? $note : null,
                ]);

                $identity->status = 'active';
                $context = [
                    'note' => $note,
                    'action_id' => $actionId,
                ];
                break;

            case 'reject':
                $reason = $this->requireReason($payload['reason'] ?? null, 'Reject reason is required.');
                $meta['rejection_reason'] = $reason;
                $meta['rejected_at'] = $nowIso;
                $meta['rejected_by_admin_id'] = $adminId;
                $actionId = $this->appendModerationHistory($meta, 'rejected', $adminId, [
                    'reason' => $reason,
                ]);

                $identity->status = 'rejected';
                $context = [
                    'reason' => $reason,
                    'action_id' => $actionId,
                ];
                break;

            case 'request_info':
                $reason = $this->requireReason($payload['reason'] ?? null, 'Reason is required to request additional information.');
                $fields = $payload['fields'] ?? [];
                if (!is_array($fields)) {
                    $fields = [];
                }

                $meta['revision_request'] = [
                    'reason' => $reason,
                    'fields' => $fields,
                    'requested_at' => $nowIso,
                    'requested_by_admin_id' => $adminId,
                ];
                $actionId = $this->appendModerationHistory($meta, 'request_info', $adminId, [
                    'reason' => $reason,
                    'fields' => $fields,
                ]);

                // Keep identity in pending status.
                $identity->status = 'pending';
                $context = [
                    'reason' => $reason,
                    'fields' => $fields,
                    'action_id' => $actionId,
                ];
                break;

            case 'suspend':
                $reason = $this->requireReason($payload['reason'] ?? null, 'Suspension reason is required.');
                $meta['suspension_reason'] = $reason;
                $meta['suspended_at'] = $nowIso;
                $meta['suspended_by_admin_id'] = $adminId;
                $actionId = $this->appendModerationHistory($meta, 'suspended', $adminId, [
                    'reason' => $reason,
                ]);

                $identity->status = 'suspended';
                $context = [
                    'reason' => $reason,
                    'action_id' => $actionId,
                ];
                break;

            case 'reactivate':
                $note = $this->sanitizeText($payload['note'] ?? null);
                $meta['reactivated_at'] = $nowIso;
                $meta['reactivated_by_admin_id'] = $adminId;
                $actionId = $this->appendModerationHistory($meta, 'reactivated', $adminId, [
                    'note' => $note !== '' ? $note : null,
                ]);

                $identity->status = 'active';
                $context = [
                    'note' => $note,
                    'action_id' => $actionId,
                ];
                break;
        }

        $identity->meta = $meta;

        return $context;
    }

    public function canTransition(string $currentStatus, string $action): bool
    {
        $normalizedStatus = strtolower(trim($currentStatus));
        $normalizedAction = strtolower(trim($action));
        $allowed = $this->allowedActions[$normalizedStatus] ?? [];

        return in_array($normalizedAction, $allowed, true);
    }

    protected function isKnownAction(string $action): bool
    {
        foreach ($this->allowedActions as $actions) {
            if (in_array($action, $actions, true)) {
                return true;
            }
        }

        return false;
    }

    protected function appendModerationHistory(array &$meta, string $action, ?int $adminId, array $details = []): string
    {
        $history = $meta['moderation_history'] ?? [];
        if (!is_array($history)) {
            $history = [];
        }

        $actionId = (string) Str::ulid();
        $history[] = [
            'action_id' => $actionId,
            'action' => $action,
            'admin_id' => $adminId,
            'at' => Carbon::now()->toIso8601String(),
            'details' => $details,
        ];

        $meta['moderation_history'] = $history;

        return $actionId;
    }

    protected function requireReason($value, string $message): string
    {
        $reason = $this->sanitizeText($value);
        if ($reason === '') {
            throw new InvalidArgumentException($message);
        }

        return $reason;
    }

    protected function sanitizeText($value): string
    {
        return trim((string) ($value ?? ''));
    }

    protected function buildInvalidTransitionMessage(string $action): string
    {
        return match ($action) {
            'approve' => 'Only pending identities can be approved.',
            'reject' => 'Only pending identities can be rejected.',
            'request_info' => 'Additional information can only be requested for pending identities.',
            'suspend' => 'Only active identities can be suspended.',
            'reactivate' => 'Only suspended identities can be reactivated.',
            default => 'Invalid moderation transition.',
        };
    }
}
