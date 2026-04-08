<?php

namespace App\Services;

use App\Models\Review;
use RuntimeException;
use InvalidArgumentException;

class ReviewModerationTransitionService
{
    public function apply(Review $review, string $action, ?int $adminId, array $payload = []): array
    {
        return match ($action) {
            'publish' => $this->transition(
                $review,
                action: 'publish',
                toStatus: 'published',
                adminId: $adminId,
                details: $this->normalizePayload(['note' => $payload['note'] ?? null]),
                allowedFrom: ['pending_moderation', 'hidden', 'rejected']
            ),
            'hide' => $this->transition(
                $review,
                action: 'hide',
                toStatus: 'hidden',
                adminId: $adminId,
                details: $this->normalizeRequiredReasonPayload($payload),
                allowedFrom: ['published', 'pending_moderation']
            ),
            'reject' => $this->transition(
                $review,
                action: 'reject',
                toStatus: 'rejected',
                adminId: $adminId,
                details: $this->normalizeRequiredReasonPayload($payload),
                allowedFrom: ['published', 'pending_moderation', 'hidden']
            ),
            default => throw new InvalidArgumentException('Unsupported moderation action.'),
        };
    }

    private function transition(
        Review $review,
        string $action,
        string $toStatus,
        ?int $adminId,
        array $details,
        array $allowedFrom
    ): array {
        $fromStatus = (string) $review->status;

        if ($fromStatus === $toStatus) {
            throw new RuntimeException('Review is already ' . str_replace('_', ' ', $toStatus) . '.');
        }

        if (!in_array($fromStatus, $allowedFrom, true)) {
            throw new RuntimeException(
                sprintf(
                    'Review cannot be moved from %s to %s.',
                    str_replace('_', ' ', $fromStatus),
                    str_replace('_', ' ', $toStatus)
                )
            );
        }

        $meta = is_array($review->meta) ? $review->meta : [];
        $moderation = is_array($meta['moderation'] ?? null) ? $meta['moderation'] : [];
        $history = is_array($meta['moderation_history'] ?? null) ? $meta['moderation_history'] : [];
        $timestamp = now()->toIso8601String();

        $historyEntry = [
            'action' => $action,
            'from' => $fromStatus,
            'to' => $toStatus,
            'admin_id' => $adminId,
            'at' => $timestamp,
            'details' => $details,
        ];

        $history[] = $historyEntry;

        $moderation['last_action'] = $action;
        $moderation['last_action_at'] = $timestamp;
        $moderation['last_action_by_admin_id'] = $adminId;

        if ($details !== []) {
            $moderation['last_action_details'] = $details;
        }

        $meta['moderation'] = $moderation;
        $meta['moderation_history'] = $history;

        if ($action === 'publish') {
            $meta['published_at'] = $timestamp;
            $meta['published_by_admin_id'] = $adminId;
            if (!empty($details['note'])) {
                $meta['publish_note'] = $details['note'];
            }
        }

        if ($action === 'hide') {
            $meta['hidden_at'] = $timestamp;
            $meta['hidden_by_admin_id'] = $adminId;
            $meta['hidden_reason'] = $details['reason'];
        }

        if ($action === 'reject') {
            $meta['rejected_at'] = $timestamp;
            $meta['rejected_by_admin_id'] = $adminId;
            $meta['rejection_reason'] = $details['reason'];
        }

        $review->status = $toStatus;
        $review->meta = $meta;

        return $historyEntry;
    }

    private function normalizePayload(array $payload): array
    {
        $details = [];

        if (filled($payload['note'] ?? null)) {
            $details['note'] = trim((string) $payload['note']);
        }

        return $details;
    }

    private function normalizeRequiredReasonPayload(array $payload): array
    {
        $reason = trim((string) ($payload['reason'] ?? ''));
        if ($reason === '') {
            throw new InvalidArgumentException('Reason is required for this moderation action.');
        }

        return ['reason' => $reason];
    }
}
