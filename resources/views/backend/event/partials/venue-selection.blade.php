@php
    $currentEvent = $event ?? null;
    $currentVenueSource = old('venue_source', optional($currentEvent)->venue_source ?? (optional($currentEvent)->venue_id ? 'registered' : 'external'));
    $currentVenueId = old('venue_id', optional($currentEvent)->venue_id ?? '');
@endphp

<div class="row event-venue-authoring">
    <div class="col-lg-12">
        <div class="form-group mt-1">
            <label for="">{{ __('Venue Source') }}</label>
            <div class="selectgroup w-100">
                <label class="selectgroup-item">
                    <input type="radio" name="venue_source" value="registered"
                        class="selectgroup-input venueSourceToggle" {{ $currentVenueSource === 'registered' ? 'checked' : '' }}>
                    <span class="selectgroup-button">{{ __('Registered Venue') }}</span>
                </label>
                <label class="selectgroup-item">
                    <input type="radio" name="venue_source" value="external"
                        class="selectgroup-input venueSourceToggle" {{ $currentVenueSource !== 'registered' ? 'checked' : '' }}>
                    <span class="selectgroup-button">{{ __('Google Maps / External') }}</span>
                </label>
            </div>
            <p class="text-warning mb-0">{{ __('Choose an existing venue or capture a new location via Google Maps.') }}</p>
        </div>
    </div>

    <div class="col-lg-12 venue-source-section venue-source-registered {{ $currentVenueSource === 'registered' ? '' : 'd-none' }}">
        <div class="form-group">
            <label for="">{{ __('Registered Venue') }}</label>
            <select name="venue_id" class="form-control js-example-basic-single">
                <option value="">{{ __('Select Venue') }}</option>
                @foreach ($venues as $venue)
                    <option value="{{ $venue->id }}" {{ (string) $currentVenueId === (string) $venue->id ? 'selected' : '' }}>
                        {{ $venue->name ?: $venue->username }}
                    </option>
                @endforeach
            </select>
        </div>
    </div>

    <div class="col-lg-12 venue-source-section venue-source-external {{ $currentVenueSource === 'registered' ? 'd-none' : '' }}">
        <div class="row">
            <div class="col-lg-6">
                <div class="form-group">
                    <label for="">{{ __('Venue Name') }}</label>
                    <input type="text" name="venue_name" class="form-control"
                        value="{{ old('venue_name', optional($currentEvent)->venue_name_snapshot ?? '') }}"
                        placeholder="{{ __('Enter venue name') }}">
                </div>
            </div>
            <div class="col-lg-6">
                <div class="form-group">
                    <label for="">{{ __('Venue Address') }}</label>
                    <input type="text" name="venue_address" id="venue-search-address" class="form-control"
                        value="{{ old('venue_address', optional($currentEvent)->venue_address_snapshot ?? '') }}"
                        placeholder="{{ __('Search address in Google Maps') }}">
                    <input type="hidden" name="venue_google_place_id"
                        value="{{ old('venue_google_place_id', optional($currentEvent)->venue_google_place_id ?? '') }}">
                    @if ($settings->google_map_status == 1)
                        <a href="" class="btn btn-secondary mt-2 btn-sm" data-toggle="modal" data-target="#GoogleMapModal">
                            <i class="fas fa-eye"></i>
                            {{ __('Show Map') }}
                        </a>
                    @endif
                </div>
            </div>
            <div class="col-lg-3">
                <div class="form-group">
                    <label for="">{{ __('City') }}</label>
                    <input type="text" name="venue_city" class="form-control"
                        value="{{ old('venue_city', optional($currentEvent)->venue_city_snapshot ?? '') }}">
                </div>
            </div>
            <div class="col-lg-3">
                <div class="form-group">
                    <label for="">{{ __('State') }}</label>
                    <input type="text" name="venue_state" class="form-control"
                        value="{{ old('venue_state', optional($currentEvent)->venue_state_snapshot ?? '') }}">
                </div>
            </div>
            <div class="col-lg-3">
                <div class="form-group">
                    <label for="">{{ __('Country') }}</label>
                    <input type="text" name="venue_country" class="form-control"
                        value="{{ old('venue_country', optional($currentEvent)->venue_country_snapshot ?? '') }}">
                </div>
            </div>
            <div class="col-lg-3">
                <div class="form-group">
                    <label for="">{{ __('Postal Code') }}</label>
                    <input type="text" name="venue_postal_code" class="form-control"
                        value="{{ old('venue_postal_code', optional($currentEvent)->venue_postal_code_snapshot ?? '') }}">
                </div>
            </div>
        </div>
    </div>
</div>
