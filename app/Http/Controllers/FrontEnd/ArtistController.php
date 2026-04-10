<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event\EventCategory;
use App\Services\ArtistPublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

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
            $target = $this->artistPublicProfileService->resolveByPublicId($id);
            if (!$target) {
                abort(404);
            }

            $payload = $this->artistPublicProfileService->buildPublicPayload(
                $target,
                auth('customer')->user()
            );

            $information = [];
            $information['basicInfo'] = $this->basicInfo();
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
                'followers_count' => $payload['followers_count'] ?? 0,
                'average_rating' => $payload['average_rating'] ?? '0.0',
                'review_count' => $payload['review_count'] ?? 0,
            ];
            $information['events'] = collect($payload['events'] ?? [])
                ->map(function (array $event) {
                    $slug = $event['slug'] ?? null;

                    return (object) [
                        'id' => $event['id'] ?? null,
                        'title' => $event['title'] ?? null,
                        'slug' => $slug,
                        'thumbnail_url' => $event['thumbnail'] ?? null,
                        'date' => $event['date'] ?? null,
                        'location' => $event['address'] ?? null,
                        'is_past' => (bool) ($event['is_past'] ?? false),
                        'event_url' => $slug ? route('event.details', [$slug, $event['id']]) : '#',
                    ];
                })
                ->values();
            $information['categories'] = EventCategory::where('status', 1)
                ->where('language_id', $language->id)
                ->orderBy('serial_number', 'asc')
                ->get();

            return view('frontend.artist.details', $information);
        } catch (\Exception $e) {
            if (app()->environment('testing')) {
                throw $e;
            }

            return view('errors.404');
        }
    }

    private function basicInfo(): object
    {
        if (!Schema::hasTable('basic_settings')) {
            return (object) [
                'breadcrumb' => null,
                'google_recaptcha_status' => 0,
            ];
        }

        $columns = collect(['breadcrumb', 'google_recaptcha_status'])
            ->filter(fn (string $column) => Schema::hasColumn('basic_settings', $column))
            ->values()
            ->all();

        $basicInfo = !empty($columns)
            ? DB::table('basic_settings')->select($columns)->first()
            : null;

        return (object) array_merge([
            'breadcrumb' => null,
            'google_recaptcha_status' => 0,
        ], (array) $basicInfo);
    }
}
