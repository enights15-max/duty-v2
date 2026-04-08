<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event\EventCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ArtistController extends Controller
{
    public function __construct(
        private ArtistPublicProfileService $artistPublicProfileService
    ) {
    }

    public function details(Request $request, $id, $name)
    {
        try {
            $language = $this->getLanguage();
            $information = [];
            $information['basicSettings'] = DB::table('basic_settings')->select('google_recaptcha_status')->first();

            $payload = $this->artistPublicProfileService->buildPublicPayload($target);
            $information['artist'] = (object) [
                'name' => $payload['name'],
                'username' => $payload['username'],
                'details' => $payload['details'],
                'photo_url' => $payload['photo'],
                'cover_photo_url' => $payload['cover_photo'] ?? null,
                'genres' => $payload['genres'] ?? [],
                'city' => $payload['city'] ?? null,
                'country' => $payload['country'] ?? null,
                'gallery' => $payload['gallery'] ?? [],
                'booking_notes' => $payload['booking_notes'] ?? null,
                'facebook' => $payload['socials']['facebook'] ?? null,
                'instagram' => $payload['socials']['instagram'] ?? null,
                'tiktok' => $payload['socials']['tiktok'] ?? null,
                'spotify' => $payload['socials']['spotify'] ?? null,
                'youtube' => $payload['socials']['youtube'] ?? null,
                'soundcloud' => $payload['socials']['soundcloud'] ?? null,
                'twitter' => $payload['socials']['twitter'] ?? null,
                'linkedin' => $payload['socials']['linkedin'] ?? null,
                'created_at' => $target['created_at'],
            ];
            $information['events'] = collect($payload['events'] ?? [])
                ->map(function (array $event) {
                    $slug = $event['slug'] ?: Str::slug((string) ($event['title'] ?? 'event'));

            $information['events'] = $artist->events()->with([
                'tickets',
                'information' => function ($query) use ($language) {
                    return $query->where('language_id', $language->id);
                }
            ])->get();

            $information['categories'] = EventCategory::where('status', 1)
                ->where('language_id', $language->id)
                ->orderBy('serial_number', 'asc')->get();

            return view('frontend.artist.details', $information);
        } catch (\Exception $e) {
            return view('errors.404');
        }
    }
}
