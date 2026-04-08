<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Event\Slot;
use App\Models\Event\SlotImage;
use App\Models\Event\Ticket;
use App\Models\Event\TicketContent;
use App\Models\Event\TicketPriceSchedule;
use App\Models\Event\VariationContent;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class EventCloneService
{
    public function duplicate(Event $sourceEvent): Event
    {
        $sourceEvent->loadMissing([
            'galleries',
            'dates',
            'lineups',
            'artists',
            'tickets',
        ]);

        return DB::transaction(function () use ($sourceEvent) {
            $clonedEvent = $sourceEvent->replicate();
            $clonedEvent->status = 0;
            $clonedEvent->is_featured = 'no';
            $clonedEvent->thumbnail = $this->duplicatePublicFile('assets/admin/img/event/thumbnail', $sourceEvent->thumbnail);
            $clonedEvent->ticket_image = $this->duplicatePublicFile('assets/admin/img/event_ticket', $sourceEvent->ticket_image);
            $clonedEvent->ticket_slot_image = $this->duplicatePublicFile('assets/admin/img/event_ticket', $sourceEvent->ticket_slot_image);
            $clonedEvent->ticket_logo = $this->duplicatePublicFile('assets/admin/img/event_ticket_logo', $sourceEvent->ticket_logo);
            $clonedEvent->created_at = now();
            $clonedEvent->updated_at = now();
            $clonedEvent->save();

            $this->duplicateLocalizedContents($sourceEvent, $clonedEvent);
            $this->duplicateDates($sourceEvent, $clonedEvent);
            $this->duplicateGallery($sourceEvent, $clonedEvent);
            $this->duplicateArtistsAndLineup($sourceEvent, $clonedEvent);
            $this->duplicateTickets($sourceEvent, $clonedEvent);

            return $clonedEvent->fresh();
        });
    }

    private function duplicateLocalizedContents(Event $sourceEvent, Event $clonedEvent): void
    {
        $contents = EventContent::where('event_id', $sourceEvent->id)->get();

        foreach ($contents as $content) {
            $clone = $content->replicate();
            [$title, $slug] = $this->nextClonedTitle(
                (string) ($content->title ?: 'Event'),
                (int) $content->language_id
            );

            $clone->event_id = $clonedEvent->id;
            $clone->title = $title;
            $clone->slug = $slug;
            $clone->google_calendar_id = null;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateDates(Event $sourceEvent, Event $clonedEvent): void
    {
        foreach ($sourceEvent->dates as $date) {
            $clone = $date->replicate();
            $clone->event_id = $clonedEvent->id;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateGallery(Event $sourceEvent, Event $clonedEvent): void
    {
        foreach ($sourceEvent->galleries as $gallery) {
            $copiedImage = $this->duplicatePublicFile('assets/admin/img/event-gallery', $gallery->image);

            if (!$copiedImage) {
                continue;
            }

            $clone = $gallery->replicate();
            $clone->event_id = $clonedEvent->id;
            $clone->image = $copiedImage;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateArtistsAndLineup(Event $sourceEvent, Event $clonedEvent): void
    {
        $artistIds = $sourceEvent->artists()->pluck('artists.id')->all();
        if ($artistIds !== []) {
            $clonedEvent->artists()->sync($artistIds);
        }

        foreach ($sourceEvent->lineups as $lineup) {
            $clone = $lineup->replicate();
            $clone->event_id = $clonedEvent->id;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateTickets(Event $sourceEvent, Event $clonedEvent): void
    {
        $tickets = Ticket::where('event_id', $sourceEvent->id)->orderBy('id')->get();

        foreach ($tickets as $ticket) {
            $slotMap = $this->buildSlotUniqueMap($ticket);
            $ticketClone = $ticket->replicate();
            $ticketClone->event_id = $clonedEvent->id;
            $ticketClone->normal_ticket_slot_unique_id = $this->mappedSlotUniqueId($ticket->normal_ticket_slot_unique_id, $slotMap);
            $ticketClone->free_tickete_slot_unique_id = $this->mappedSlotUniqueId($ticket->free_tickete_slot_unique_id, $slotMap);
            $ticketClone->variations = $this->cloneVariationsPayload($ticket->variations, $slotMap);
            $ticketClone->created_at = now();
            $ticketClone->updated_at = now();
            $ticketClone->save();

            $this->duplicateTicketContents($ticket, $ticketClone);
            $this->duplicateVariationContents($ticket, $ticketClone);
            $this->duplicatePriceSchedules($ticket, $ticketClone);
            $this->duplicateSlots($sourceEvent, $clonedEvent, $ticket, $ticketClone, $slotMap);
        }
    }

    private function duplicateTicketContents(Ticket $sourceTicket, Ticket $clonedTicket): void
    {
        $contents = TicketContent::where('ticket_id', $sourceTicket->id)->get();

        foreach ($contents as $content) {
            $clone = $content->replicate();
            $clone->ticket_id = $clonedTicket->id;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateVariationContents(Ticket $sourceTicket, Ticket $clonedTicket): void
    {
        $variationContents = VariationContent::where('ticket_id', $sourceTicket->id)->get();

        foreach ($variationContents as $variationContent) {
            $clone = $variationContent->replicate();
            $clone->ticket_id = $clonedTicket->id;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicatePriceSchedules(Ticket $sourceTicket, Ticket $clonedTicket): void
    {
        $schedules = TicketPriceSchedule::where('ticket_id', $sourceTicket->id)->get();

        foreach ($schedules as $schedule) {
            $clone = $schedule->replicate();
            $clone->ticket_id = $clonedTicket->id;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function duplicateSlots(
        Event $sourceEvent,
        Event $clonedEvent,
        Ticket $sourceTicket,
        Ticket $clonedTicket,
        array $slotMap
    ): void {
        $sourceSlots = Slot::with('seats')
            ->where('event_id', $sourceEvent->id)
            ->where('ticket_id', $sourceTicket->id)
            ->get();

        foreach ($sourceSlots as $sourceSlot) {
            $clone = $sourceSlot->replicate();
            $clone->event_id = $clonedEvent->id;
            $clone->ticket_id = $clonedTicket->id;
            $clone->slot_unique_id = $this->mappedSlotUniqueId($sourceSlot->slot_unique_id, $slotMap);
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();

            foreach ($sourceSlot->seats as $seat) {
                $seatClone = $seat->replicate();
                $seatClone->slot_id = $clone->id;
                $seatClone->save();
            }
        }

        $sourceSlotImages = SlotImage::query()
            ->where('event_id', $sourceEvent->id)
            ->where('ticket_id', $sourceTicket->id)
            ->get();

        foreach ($sourceSlotImages as $sourceSlotImage) {
            $copiedImage = $this->duplicatePublicFile('assets/admin/img/map-image', $sourceSlotImage->image);

            if (!$copiedImage) {
                continue;
            }

            $clone = $sourceSlotImage->replicate();
            $clone->event_id = $clonedEvent->id;
            $clone->ticket_id = $clonedTicket->id;
            $clone->slot_unique_id = $this->mappedSlotUniqueId($sourceSlotImage->slot_unique_id, $slotMap);
            $clone->image = $copiedImage;
            $clone->created_at = now();
            $clone->updated_at = now();
            $clone->save();
        }
    }

    private function buildSlotUniqueMap(Ticket $ticket): array
    {
        $map = [];

        if ($ticket->normal_ticket_slot_unique_id) {
            $map[(string) $ticket->normal_ticket_slot_unique_id] = $this->generateSlotUniqueId();
        }

        if ($ticket->free_tickete_slot_unique_id) {
            $map[(string) $ticket->free_tickete_slot_unique_id] = $this->generateSlotUniqueId();
        }

        $variations = json_decode((string) $ticket->variations, true);
        if (is_array($variations)) {
            foreach ($variations as $variation) {
                $slotUniqueId = data_get($variation, 'slot_unique_id');
                if (!$slotUniqueId) {
                    continue;
                }

                $slotKey = (string) $slotUniqueId;
                if (!array_key_exists($slotKey, $map)) {
                    $map[$slotKey] = $this->generateSlotUniqueId();
                }
            }
        }

        return $map;
    }

    private function cloneVariationsPayload(?string $variationsJson, array $slotMap): ?string
    {
        if (!$variationsJson) {
            return $variationsJson;
        }

        $variations = json_decode($variationsJson, true);
        if (!is_array($variations)) {
            return $variationsJson;
        }

        foreach ($variations as $index => $variation) {
            $slotUniqueId = data_get($variation, 'slot_unique_id');
            if (!$slotUniqueId) {
                continue;
            }

            $variations[$index]['slot_unique_id'] = $this->mappedSlotUniqueId($slotUniqueId, $slotMap);
        }

        return json_encode($variations);
    }

    private function mappedSlotUniqueId(mixed $sourceSlotUniqueId, array $slotMap): mixed
    {
        if (!$sourceSlotUniqueId) {
            return $sourceSlotUniqueId;
        }

        return $slotMap[(string) $sourceSlotUniqueId] ?? $sourceSlotUniqueId;
    }

    private function nextClonedTitle(string $sourceTitle, int $languageId): array
    {
        $baseTitle = trim($sourceTitle) !== '' ? trim($sourceTitle) : 'Event';
        $suffix = __('Copy');
        $counter = 1;

        do {
            $candidateTitle = $counter === 1
                ? "{$baseTitle} ({$suffix})"
                : "{$baseTitle} ({$suffix} {$counter})";
            $candidateSlug = createSlug($candidateTitle);
            $exists = EventContent::where('language_id', $languageId)
                ->where('slug', $candidateSlug)
                ->exists();
            $counter++;
        } while ($exists);

        return [$candidateTitle, $candidateSlug];
    }

    private function duplicatePublicFile(string $directory, ?string $filename): ?string
    {
        if (!$filename) {
            return null;
        }

        $sourcePath = public_path(trim($directory, '/') . '/' . $filename);
        if (!is_file($sourcePath)) {
            return null;
        }

        $extension = pathinfo($filename, PATHINFO_EXTENSION);
        $name = pathinfo($filename, PATHINFO_FILENAME);
        $clonedFilename = $name . '-copy-' . Str::lower(Str::random(8)) . ($extension ? '.' . $extension : '');
        $targetPath = public_path(trim($directory, '/') . '/' . $clonedFilename);

        File::ensureDirectoryExists(dirname($targetPath));
        copy($sourcePath, $targetPath);

        return $clonedFilename;
    }

    private function generateSlotUniqueId(): int
    {
        do {
            $candidate = random_int(100000, 999999);
            $exists = Slot::where('slot_unique_id', $candidate)->exists()
                || SlotImage::where('slot_unique_id', $candidate)->exists();
        } while ($exists);

        return $candidate;
    }
}
