<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use App\Models\Event\EventCategory;
use App\Models\Event;
use App\Services\VenuePublicProfileService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class VenueController extends Controller
{
    public function __construct(
        private VenuePublicProfileService $venuePublicProfileService
    ) {
    }

    public function details(Request $request, $id, $name = null)
    {
        try {
            $language = $this->getLanguage();
            $information = [];
            $information['basicInfo'] = $this->basicInfo();

            $target = $this->venuePublicProfileService->resolveByPublicId($id);
            if (!$target) {
                abort(404);
            }

            $payload = $this->venuePublicProfileService->buildPublicPayload(
                $target,
                auth('customer')->user(),
                $language->id
            );
            $legacyVenue = $target['legacy'] ?? null;

            $information['venue'] = (object) [
                'id' => $payload['id'],
                'name' => $payload['name'],
                'slug' => $payload['slug'],
                'username' => $legacyVenue?->username ?? $payload['slug'],
                'photo' => $legacyVenue?->photo ?? $legacyVenue?->image ?? null,
                'details' => $payload['description'],
                'facebook' => $payload['socials']['facebook'] ?? null,
                'linkedin' => $payload['socials']['linkedin'] ?? null,
                'twitter' => $payload['socials']['twitter'] ?? null,
                'created_at' => $target['created_at'],
            ];

            $identityId = $target['identity']?->id;
            $legacyId = $target['legacy_id'];
            $relations = [
                'information' => function ($query) use ($language) {
                    return $query->where('language_id', $language->id);
                },
            ];
            if (Schema::hasTable('tickets')) {
                $relations[] = 'tickets';
            }

            $information['events'] = Event::query()->with($relations)->where(function ($query) use ($identityId, $legacyId) {
                if ($identityId !== null) {
                    $query->where('venue_identity_id', $identityId);

                    if ($legacyId !== null) {
                        $query->orWhere(function ($fallback) use ($legacyId) {
                            $fallback->whereNull('venue_identity_id')
                                ->where('venue_id', $legacyId);
                        });
                    }

                    return;
                }

                if ($legacyId !== null) {
                    $query->where('venue_id', $legacyId);
                    return;
                }

                $query->whereRaw('1 = 0');
            })->orderByRaw(
                'CASE WHEN end_date_time >= ? THEN 0 ELSE 1 END',
                [now()->toDateTimeString()]
            )->orderBy('start_date')->get()
                ->each(function (Event $event) {
                    $event->setAttribute('title', $event->information?->title);
                    $event->setAttribute('event_url', $event->information?->slug
                        ? route('event.details', [$event->information->slug, $event->id])
                        : '#');
                });

            $information['categories'] = EventCategory::where('status', 1)
                ->where('language_id', $language->id)
                ->orderBy('serial_number', 'asc')->get();

            return view('frontend.venue.details', $information);
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
