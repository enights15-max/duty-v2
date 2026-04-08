<?php

namespace App\Services;

use App\Models\Event\TicketContent;
use App\Models\Language;

class EventTicketNameResolverService
{
    public function resolve(int $ticketId, ?string $fallbackTitle = null, ?int $languageId = null): string
    {
        $preferredLanguageId = $languageId ?? $this->resolveDefaultLanguageId();

        if (!empty($preferredLanguageId)) {
            $preferredContent = TicketContent::where([
                ['ticket_id', $ticketId],
                ['language_id', (int) $preferredLanguageId],
            ])->first();

            if (!empty($preferredContent?->title)) {
                return (string) $preferredContent->title;
            }
        }

        $anyContent = TicketContent::where('ticket_id', $ticketId)->first();
        if (!empty($anyContent?->title)) {
            return (string) $anyContent->title;
        }

        if (!empty($fallbackTitle)) {
            return (string) $fallbackTitle;
        }

        return 'Ticket #' . $ticketId;
    }

    private function resolveDefaultLanguageId(): ?int
    {
        $id = Language::where('is_default', 1)->value('id');
        return $id ? (int) $id : null;
    }
}
