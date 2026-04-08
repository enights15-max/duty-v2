<?php

namespace App\Services;

class ReviewModerationService
{
    public function evaluate(?string $comment): array
    {
        $comment = trim((string) $comment);
        if ($comment === '') {
            return [
                'status' => 'published',
                'meta' => [
                    'moderation' => [
                        'mode' => 'rating_only',
                    ],
                ],
            ];
        }

        $patterns = [
            'external_contact' => '/https?:\/\/|www\.|telegram|whatsapp|t\.me|contact me|call me|dm me/i',
            'personal_data' => '/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}|\+?\d[\d\-\s\(\)]{7,}\d/i',
        ];

        foreach ($patterns as $reason => $pattern) {
            if (preg_match($pattern, $comment) === 1) {
                return [
                    'status' => 'pending_moderation',
                    'meta' => [
                        'moderation' => [
                            'mode' => 'rule_flagged',
                            'reason' => $reason,
                        ],
                    ],
                ];
            }
        }

        return [
            'status' => 'published',
            'meta' => [
                'moderation' => [
                    'mode' => 'auto_pass',
                ],
            ],
        ];
    }
}
