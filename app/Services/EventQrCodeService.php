<?php

namespace App\Services;

use App\Models\Event;
use Illuminate\Support\Facades\File;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class EventQrCodeService
{
    public function resolveTitle(Event $event): string
    {
        return $event->information?->title ?: ('Event #' . $event->id);
    }

    public function buildScanUrl(Event $event): string
    {
        return url('/admin/pwa/scanner?event=' . $event->id);
    }

    public function ensureSvg(Event $event): string
    {
        $directory = public_path('assets/admin/qr/');
        File::ensureDirectoryExists($directory);

        $path = $directory . 'event-' . $event->id . '.svg';
        if (!File::exists($path)) {
            File::put($path, QrCode::format('svg')->size(320)->generate($this->buildScanUrl($event)));
        }

        return $path;
    }

    public function svgUrl(Event $event): string
    {
        $this->ensureSvg($event);

        return asset('assets/admin/qr/event-' . $event->id . '.svg');
    }

    public function downloadFilename(Event $event): string
    {
        return 'event-' . $event->id . '-qr.svg';
    }
}
