<?php

namespace App\Services;

use App\Models\Artist;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Identity;
use App\Models\Language;
use App\Models\Venue;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Mews\Purifier\Facades\Purifier;

class EventAuthoringService
{
    public function applyVenueSelection(
        Request $request,
        array $attributes,
        ?Venue $forcedVenue = null,
        ?Identity $forcedVenueIdentity = null
    ): array {
        if (($request->input('event_type') ?? $attributes['event_type'] ?? null) !== 'venue') {
            return $this->clearVenueSelection($attributes);
        }

        $venueSource = $request->input('venue_source');
        if ($forcedVenue) {
            $venueSource = 'registered';
        }

        if (!$venueSource) {
            $venueSource = $request->filled('venue_id') ? 'registered' : 'manual';
        }

        return match ($venueSource) {
            'registered' => $this->applyRegisteredVenue(
                $attributes,
                $forcedVenue ?: Venue::find($request->input('venue_id')),
                $forcedVenueIdentity,
                $request
            ),
            'external' => $this->applyExternalVenue($attributes, $request),
            default => $this->applyManualVenue($attributes, $request),
        };
    }

    public function syncLocalizedContent(Event $event, Request $request, iterable $languages): void
    {
        foreach ($languages as $language) {
            $language = $language instanceof Language ? $language : Language::findOrFail($language);
            $eventContent = EventContent::firstOrNew([
                'event_id' => $event->id,
                'language_id' => $language->id,
            ]);

            $eventContent->event_id = $event->id;
            $eventContent->language_id = $language->id;
            $eventContent->event_category_id = $request->input($language->code . '_category_id');
            $eventContent->title = $request->input($language->code . '_title');
            $eventContent->slug = createSlug($request->input($language->code . '_title'));
            $eventContent->description = Purifier::clean((string) $request->input($language->code . '_description'), 'youtube');
            $eventContent->refund_policy = $request->input($language->code . '_refund_policy');
            $eventContent->meta_keywords = $request->input($language->code . '_meta_keywords');
            $eventContent->meta_description = $request->input($language->code . '_meta_description');

            if ($event->event_type === 'venue') {
                $location = $this->resolveLocalizedVenueFields($event, $request, $language->code, $language->id);
                $eventContent->address = $location['address'];
                $eventContent->country = $location['country'];
                $eventContent->state = $location['state'];
                $eventContent->city = $location['city'];
                $eventContent->zip_code = $location['zip_code'];
                $eventContent->country_id = $location['country_id'];
                $eventContent->state_id = $location['state_id'];
                $eventContent->city_id = $location['city_id'];
            } else {
                $eventContent->address = null;
                $eventContent->country = null;
                $eventContent->state = null;
                $eventContent->city = null;
                $eventContent->zip_code = null;
                $eventContent->country_id = null;
                $eventContent->state_id = null;
                $eventContent->city_id = null;
            }

            $eventContent->save();
        }
    }

    public function syncLineup(Event $event, Request $request): void
    {
        $artistIds = collect($request->input('artist_ids', []))
            ->filter(fn ($value) => filled($value))
            ->map(fn ($value) => (int) $value)
            ->unique()
            ->values();

        $event->artists()->sync($artistIds->all());

        $manualNames = $this->manualArtistNames($request);
        $artists = Artist::whereIn('id', $artistIds)->get()->keyBy('id');
        $orderedItems = $this->resolveOrderedLineupItems(
            $artistIds,
            $manualNames,
            $artists,
            $request
        );

        DB::table('event_lineups')->where('event_id', $event->id)->delete();

        $rows = [];
        $headlinerKey = $this->resolveHeadlinerKey($orderedItems, $request->input('headliner_key'));

        foreach ($orderedItems as $index => $item) {
            $rows[] = [
                'event_id' => $event->id,
                'artist_id' => $item['artist_id'],
                'source_type' => $item['source_type'],
                'display_name' => $item['display_name'],
                'sort_order' => $index + 1,
                'is_headliner' => $item['key'] === $headlinerKey,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        if ($rows !== []) {
            DB::table('event_lineups')->insert($rows);
        }
    }

    public function manualArtistNames(Request $request): Collection
    {
        $fromArray = collect($request->input('manual_artists', []))
            ->filter(fn ($value) => is_string($value) && trim($value) !== '')
            ->map(fn ($value) => trim($value));

        $fromText = collect(preg_split('/[\r\n,]+/', (string) $request->input('manual_artists_text', '')))
            ->filter(fn ($value) => is_string($value) && trim($value) !== '')
            ->map(fn ($value) => trim($value));

        return $fromArray
            ->merge($fromText)
            ->map(fn ($value) => preg_replace('/\s+/', ' ', (string) $value))
            ->filter()
            ->unique()
            ->values();
    }

    public function lineupKey(string $sourceType, string|int $value): string
    {
        return $sourceType . ':' . trim((string) $value);
    }

    private function resolveOrderedLineupItems(
        Collection $artistIds,
        Collection $manualNames,
        Collection $artists,
        Request $request
    ): Collection {
        $items = collect();

        foreach ($artistIds as $artistId) {
            $artist = $artists->get($artistId);
            if (!$artist) {
                continue;
            }

            $items->push([
                'key' => $this->lineupKey('artist', $artistId),
                'artist_id' => $artistId,
                'source_type' => 'artist',
                'display_name' => $artist->username ?: $artist->name ?: ('Artist #' . $artistId),
            ]);
        }

        foreach ($manualNames as $name) {
            $items->push([
                'key' => $this->lineupKey('manual', $name),
                'artist_id' => null,
                'source_type' => 'manual',
                'display_name' => $name,
            ]);
        }

        $requestedOrder = collect($request->input('lineup_order', []))
            ->map(fn ($value) => trim((string) $value))
            ->filter()
            ->unique()
            ->values();

        if ($requestedOrder->isEmpty()) {
            return $items->values();
        }

        $itemMap = $items->keyBy('key');
        $ordered = $requestedOrder
            ->map(fn (string $key) => $itemMap->get($key))
            ->filter()
            ->values();

        $remaining = $items
            ->filter(fn (array $item) => !$requestedOrder->contains($item['key']))
            ->values();

        return $ordered->concat($remaining)->values();
    }

    private function resolveHeadlinerKey(Collection $orderedItems, mixed $requestedKey): ?string
    {
        $requested = trim((string) $requestedKey);
        if ($requested !== '' && $orderedItems->contains(fn (array $item) => $item['key'] === $requested)) {
            return $requested;
        }

        return $orderedItems->first()['key'] ?? null;
    }

    private function applyRegisteredVenue(array $attributes, ?Venue $venue, ?Identity $forcedVenueIdentity, Request $request): array
    {
        if (!$venue) {
            throw ValidationException::withMessages([
                'venue_id' => 'A valid venue is required when using a registered venue.',
            ]);
        }

        $identity = $forcedVenueIdentity ?: Identity::findForLegacy('venue', $venue->id);

        $attributes['venue_source'] = 'registered';
        $attributes['venue_id'] = $venue->id;
        $attributes['venue_identity_id'] = $identity?->id;
        $attributes['venue_name_snapshot'] = $venue->name ?: $venue->username;
        $attributes['venue_address_snapshot'] = $venue->address;
        $attributes['venue_city_snapshot'] = $venue->city;
        $attributes['venue_state_snapshot'] = $venue->state;
        $attributes['venue_country_snapshot'] = $venue->country;
        $attributes['venue_postal_code_snapshot'] = $venue->zip_code;
        $attributes['venue_google_place_id'] = $request->input('venue_google_place_id');
        $attributes['latitude'] = $venue->latitude ?: $request->input('latitude');
        $attributes['longitude'] = $venue->longitude ?: $request->input('longitude');

        return $attributes;
    }

    private function applyExternalVenue(array $attributes, Request $request): array
    {
        $attributes['venue_source'] = 'external';
        $attributes['venue_id'] = null;
        $attributes['venue_identity_id'] = null;
        $attributes['venue_name_snapshot'] = $request->input('venue_name');
        $attributes['venue_address_snapshot'] = $request->input('venue_address');
        $attributes['venue_city_snapshot'] = $request->input('venue_city');
        $attributes['venue_state_snapshot'] = $request->input('venue_state');
        $attributes['venue_country_snapshot'] = $request->input('venue_country');
        $attributes['venue_postal_code_snapshot'] = $request->input('venue_postal_code');
        $attributes['venue_google_place_id'] = $request->input('venue_google_place_id');
        $attributes['latitude'] = $request->input('latitude');
        $attributes['longitude'] = $request->input('longitude');

        return $attributes;
    }

    private function applyManualVenue(array $attributes, Request $request): array
    {
        $defaultLanguage = Language::where('is_default', 1)->first() ?: Language::first();
        $code = $defaultLanguage?->code ?? 'en';
        $defaultLanguageId = $defaultLanguage?->id ?? 0;

        $attributes['venue_source'] = 'manual';
        $attributes['venue_id'] = null;
        $attributes['venue_identity_id'] = null;
        $attributes['venue_name_snapshot'] = $request->input('venue_name')
            ?: $request->input('title')
            ?: $request->input($code . '_title');
        $attributes['venue_address_snapshot'] = $request->input('venue_address')
            ?: $request->input($code . '_address');
        $attributes['venue_city_snapshot'] = $request->input('venue_city')
            ?: $this->lookupName('event_cities', $request->input($code . '_city'), $defaultLanguageId);
        $attributes['venue_state_snapshot'] = $request->input('venue_state')
            ?: $this->lookupName('event_states', $request->input($code . '_state'), $defaultLanguageId);
        $attributes['venue_country_snapshot'] = $request->input('venue_country')
            ?: $this->lookupName('event_countries', $request->input($code . '_country'), $defaultLanguageId);
        $attributes['venue_postal_code_snapshot'] = $request->input('venue_postal_code')
            ?: $request->input($code . '_zip_code');
        $attributes['venue_google_place_id'] = $request->input('venue_google_place_id');
        $attributes['latitude'] = $request->input('latitude');
        $attributes['longitude'] = $request->input('longitude');

        return $attributes;
    }

    private function clearVenueSelection(array $attributes): array
    {
        $attributes['venue_source'] = null;
        $attributes['venue_id'] = null;
        $attributes['venue_identity_id'] = null;
        $attributes['venue_name_snapshot'] = null;
        $attributes['venue_address_snapshot'] = null;
        $attributes['venue_city_snapshot'] = null;
        $attributes['venue_state_snapshot'] = null;
        $attributes['venue_country_snapshot'] = null;
        $attributes['venue_postal_code_snapshot'] = null;
        $attributes['venue_google_place_id'] = null;

        return $attributes;
    }

    private function resolveLocalizedVenueFields(Event $event, Request $request, string $languageCode, int $languageId): array
    {
        if (in_array($event->venue_source, ['registered', 'external'], true)
            || ($event->venue_source === 'manual' && $this->hasManualVenueSnapshot($event))) {
            return [
                'address' => $event->venue_address_snapshot,
                'country' => $event->venue_country_snapshot,
                'state' => $event->venue_state_snapshot,
                'city' => $event->venue_city_snapshot,
                'zip_code' => $event->venue_postal_code_snapshot,
                'country_id' => null,
                'state_id' => null,
                'city_id' => null,
            ];
        }

        $countryId = $request->input($languageCode . '_country');
        $stateId = $request->input($languageCode . '_state');
        $cityId = $request->input($languageCode . '_city');

        return [
            'address' => $request->input($languageCode . '_address'),
            'country' => $this->lookupName('event_countries', $countryId, $languageId),
            'state' => $this->lookupName('event_states', $stateId, $languageId),
            'city' => $this->lookupName('event_cities', $cityId, $languageId),
            'zip_code' => $request->input($languageCode . '_zip_code'),
            'country_id' => $countryId ?: null,
            'state_id' => $stateId ?: null,
            'city_id' => $cityId ?: null,
        ];
    }

    private function hasManualVenueSnapshot(Event $event): bool
    {
        return filled($event->venue_name_snapshot)
            || filled($event->venue_address_snapshot)
            || filled($event->venue_city_snapshot)
            || filled($event->venue_state_snapshot)
            || filled($event->venue_country_snapshot)
            || filled($event->venue_postal_code_snapshot);
    }

    private function lookupName(string $table, $id, int $languageId): ?string
    {
        if (!filled($id) || !DB::getSchemaBuilder()->hasTable($table)) {
            return null;
        }

        return DB::table($table)
            ->where('id', $id)
            ->where('language_id', $languageId)
            ->value('name');
    }
}
