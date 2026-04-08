<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Services\VenuePublicProfileService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class VenueController extends Controller
{
    public function __construct(
        private readonly VenuePublicProfileService $venuePublicProfileService
    ) {
    }

    public function details(Request $request, $id, $name = null)
    {
        try {
            $language = $this->getLanguage();
            $information = [];
            $information['basicSettings'] = DB::table('basic_settings')->select('google_recaptcha_status')->first();
            $target = $this->venuePublicProfileService->resolveByPublicId($id);
            if (!$target) {
                throw new \RuntimeException('Venue not found.');
            }

            $payload = $this->venuePublicProfileService->buildPublicPayload($target, null, $language?->id);
            $venue = (object) [
                'name' => $payload['name'],
                'username' => $target['legacy']?->username ?? $payload['identity']['slug'] ?? null,
                'details' => $payload['description'],
                'photo_url' => $payload['image'],
                'facebook' => $payload['socials']['facebook'] ?? null,
                'twitter' => $payload['socials']['twitter'] ?? null,
                'linkedin' => $payload['socials']['linkedin'] ?? null,
                'created_at' => $target['created_at'],
                'address' => $payload['address'] ?? null,
                'city' => $payload['city'] ?? null,
                'state' => $payload['state'] ?? null,
                'country' => $payload['country'] ?? null,
                'zip_code' => $payload['zip_code'] ?? null,
                'followers_count' => (int) ($payload['followers_count'] ?? 0),
                'review_count' => (int) ($payload['review_count'] ?? 0),
                'average_rating' => $payload['average_rating'] ?? '0.0',
                'latitude' => $payload['latitude'] ?? null,
                'longitude' => $payload['longitude'] ?? null,
            ];

            $upcomingEvents = $this->mapVenueEvents(collect($payload['events'] ?? []), $payload, false);
            $pastEvents = $this->mapVenueEvents(collect($payload['past_events'] ?? []), $payload, true);

            $information['venue'] = $venue;
            $information['venueProfile'] = $payload;
            $information['upcomingEvents'] = $upcomingEvents;
            $information['pastEvents'] = $pastEvents;
            $information['events'] = $upcomingEvents->concat($pastEvents)->values();
            $information['locationSummary'] = collect([
                $venue->city,
                $venue->state,
                $venue->country,
            ])->filter()->implode(', ');
            $information['mapsUrl'] = $this->mapsUrlForVenue($venue);

            return view('frontend.venue.details', $information);
        } catch (\Exception $e) {
            return view('errors.404');
        }
    }

    private function mapVenueEvents(Collection $events, array $payload, bool $isPast): Collection
    {
        return $events
            ->map(function (array $event) use ($payload, $isPast) {
                $slug = $event['slug'] ?: Str::slug((string) ($event['title'] ?? 'event'));
                $eventDate = !empty($event['date']) ? Carbon::parse($event['date']) : null;
                $startPrice = (float) ($event['start_price'] ?? 0);

                return (object) [
                    'id' => (int) $event['id'],
                    'title' => $event['title'] ?? ('Event #' . $event['id']),
                    'slug' => $slug !== '' ? $slug : 'event',
                    'event_url' => route('event.details', [$slug !== '' ? $slug : 'event', $event['id']]),
                    'thumbnail_url' => $event['thumbnail'] ?: asset('assets/front/images/profile.jpg'),
                    'date' => $event['date'] ?? null,
                    'date_badge' => $eventDate ? $eventDate->translatedFormat('M d') : __('Date TBD'),
                    'date_full' => $eventDate ? $eventDate->translatedFormat('D, M d') : __('Date TBD'),
                    'time_badge' => !empty($event['time']) ? Carbon::parse($event['time'])->translatedFormat('h:i A') : __('Time TBD'),
                    'location' => $event['address'] ?? $payload['address'] ?? __('Venue'),
                    'status_label' => $isPast ? __('Past event') : __('Upcoming'),
                    'status_class' => $isPast ? 'past' : 'upcoming',
                    'price_display' => $startPrice > 0 ? symbolPrice($startPrice) : __('Free'),
                    'price_hint' => $startPrice > 0 ? __('Starting ticket') : __('Open access'),
                    'is_past' => $isPast,
                ];
            })
            ->values();
    }

    private function mapsUrlForVenue(object $venue): ?string
    {
        if (!empty($venue->latitude) && !empty($venue->longitude)) {
            return 'https://www.google.com/maps/search/?api=1&query=' . $venue->latitude . ',' . $venue->longitude;
        }

        $address = collect([
            $venue->address,
            $venue->city,
            $venue->state,
            $venue->country,
        ])->filter()->implode(', ');

        if ($address === '') {
            return null;
        }

        return 'https://www.google.com/maps/search/?api=1&query=' . urlencode($address);
    }
}
