<?php

namespace App\Services;

use App\Models\EventCollaboratorEarning;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class CollaborationPayoutNotificationService
{
    public function __construct(private NotificationService $notificationService)
    {
    }

    public function notifyAutoReleased(EventCollaboratorEarning $earning, float $claimedAmount): bool
    {
        $earning->loadMissing([
            'event.information',
            'identity.owner',
        ]);

        $identity = $earning->identity;
        $owner = $identity?->owner;

        if (!$owner) {
            return false;
        }

        if (!Schema::hasTable('fcm_tokens')) {
            return false;
        }

        $eventTitle = trim((string) ($earning->event?->information?->title ?? '')) ?: ('Evento #' . $earning->event_id);
        $displayName = trim((string) ($identity?->display_name ?? '')) ?: 'tu perfil profesional';
        $amountLabel = 'RD$' . number_format($claimedAmount, 2);

        try {
            return (bool) $this->notificationService->notifyUser(
                $owner,
                'Duty: ganancia acreditada',
                "Acreditamos {$amountLabel} a {$displayName} por la colaboración en {$eventTitle}.",
                [
                    'type' => 'collaboration_auto_release',
                    'event_id' => (string) $earning->event_id,
                    'earning_id' => (string) $earning->id,
                    'identity_id' => (string) $earning->identity_id,
                    'screen' => 'professional_collaborations',
                ]
            );
        } catch (\Throwable $e) {
            Log::warning('Collaboration auto-release notification failed.', [
                'earning_id' => $earning->id,
                'event_id' => $earning->event_id,
                'identity_id' => $earning->identity_id,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }
}
