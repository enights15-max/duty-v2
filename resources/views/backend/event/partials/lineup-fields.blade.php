@php
    $eventModel = $event ?? null;
    $selectedArtists = collect(old('artist_ids', $eventModel?->artists?->pluck('id')->all() ?? []))->map(fn ($id) => (int) $id)->all();
    $manualLineup = old(
        'manual_artists_text',
        $eventModel
            ? $eventModel->lineups()->where('source_type', 'manual')->orderBy('sort_order')->pluck('display_name')->implode(PHP_EOL)
            : ''
    );
    $existingLineupItems = $eventModel
        ? $eventModel->lineups()->orderBy('sort_order')->get()->map(function ($lineup) {
            $value = $lineup->source_type === 'artist' ? (int) $lineup->artist_id : $lineup->display_name;

            return [
                'key' => $lineup->source_type . ':' . trim((string) $value),
                'is_headliner' => (bool) $lineup->is_headliner,
            ];
        })->values()
        : collect();
    $existingLineupOrder = old('lineup_order', $existingLineupItems->pluck('key')->all());
    $existingHeadlinerKey = old(
        'headliner_key',
        optional($existingLineupItems->firstWhere('is_headliner', true))['key'] ?? ($existingLineupOrder[0] ?? null)
    );
@endphp

<div class="row">
    <div class="col-lg-6">
        <div class="form-group">
            <label for="">{{ __('Registered Artists') }}</label>
            <select name="artist_ids[]" class="form-control js-example-basic-single" multiple="multiple">
                @foreach ($artists as $artist)
                    <option value="{{ $artist->id }}" {{ in_array((int) $artist->id, $selectedArtists, true) ? 'selected' : '' }}>
                        {{ $artist->username ?: $artist->name }}
                    </option>
                @endforeach
            </select>
            <p class="text-warning mb-0">{{ __('These artists link to real profiles inside Duty.') }}</p>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="form-group">
            <label for="">{{ __('Manual Artist Names') }}</label>
            <textarea name="manual_artists_text" rows="4" class="form-control"
                placeholder="{{ __('One artist per line. These entries do not create profiles.') }}">{{ $manualLineup }}</textarea>
            <p class="text-warning mb-0">{{ __('Use this for guest artists without a registered profile.') }}</p>
        </div>
    </div>
</div>

<div
    id="lineupBuilder"
    class="card mt-3"
    data-initial-order='@json($existingLineupOrder)'
    data-initial-headliner="{{ $existingHeadlinerKey }}"
>
    <div class="card-body">
        <div class="d-flex justify-content-between align-items-start mb-3">
            <div>
                <h5 class="mb-1">{{ __('Lineup Order') }}</h5>
                <p class="text-muted mb-0">{{ __('Define the exact running order and choose one headliner.') }}</p>
            </div>
            <span class="badge badge-light">{{ __('Mixed lineup') }}</span>
        </div>

        <div class="lineup-builder-empty alert alert-secondary d-none mb-3">
            {{ __('Add at least one registered or manual artist to build the lineup order.') }}
        </div>

        <div class="lineup-builder-list"></div>
        <div class="lineup-builder-hidden-inputs"></div>
        <input type="hidden" name="headliner_key" value="{{ $existingHeadlinerKey }}">
    </div>
</div>
