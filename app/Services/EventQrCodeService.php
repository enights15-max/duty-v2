<?php

namespace App\Services;

use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Language;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class EventQrCodeService
{
    private const DIRECTORY = 'assets/admin/event-qrcodes';

    public function buildScanUrl(Event $event): string
    {
        return route('frontend.open_event', [
            'id' => $event->id,
            'slug' => $this->resolveSlug($event),
            'source' => 'event-qr',
        ]);
    }

    public function ensureSvg(Event $event): string
    {
        $path = $this->svgPath($event);

        $this->ensureDirectoryExists();

        QrCode::size(420)
            ->margin(1)
            ->generate($this->buildScanUrl($event), $path);

        return $path;
    }

    public function svgPath(Event $event): string
    {
        return public_path($this->relativeSvgPath($event));
    }

    public function svgUrl(Event $event): string
    {
        $this->ensureSvg($event);

        return asset($this->relativeSvgPath($event));
    }

    public function relativeSvgPath(Event $event): string
    {
        return self::DIRECTORY . '/event_' . $event->id . '.svg';
    }

    public function downloadFilename(Event $event): string
    {
        $title = $this->resolveTitle($event);
        $suffix = Str::slug($title ?: 'event');

        return 'duty-event-qr-' . $event->id . '-' . $suffix . '.svg';
    }

    public function delete(Event $event): void
    {
        $path = $this->svgPath($event);

        if (is_file($path)) {
            @unlink($path);
        }
    }

    public function resolveTitle(Event $event): string
    {
        $defaultLanguageId = Language::query()->where('is_default', 1)->value('id');

        $content = EventContent::query()
            ->where('event_id', $event->id)
            ->when($defaultLanguageId, function ($query) use ($defaultLanguageId) {
                return $query->orderByRaw('language_id = ? desc', [$defaultLanguageId]);
            })
            ->orderBy('id')
            ->first(['title']);

        return $content?->title ?: ('Event #' . $event->id);
    }

    private function resolveSlug(Event $event): ?string
    {
        $defaultLanguageId = Language::query()->where('is_default', 1)->value('id');

        $content = EventContent::query()
            ->where('event_id', $event->id)
            ->when($defaultLanguageId, function ($query) use ($defaultLanguageId) {
                return $query->orderByRaw('language_id = ? desc', [$defaultLanguageId]);
            })
            ->orderBy('id')
            ->first(['slug']);

        return $content?->slug;
    }

    private function ensureDirectoryExists(): void
    {
        $directory = public_path(self::DIRECTORY);

        if (!is_dir($directory)) {
            @mkdir($directory, 0775, true);
        }
    }
}
