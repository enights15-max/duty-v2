<div class="event-filter-shell rmb-75">
    <div class="event-filter-card event-filter-card--search">
        <div class="event-filter-card__head">
            <span>{{ __('Search') }}</span>
            <strong>{{ __('Find a scene') }}</strong>
        </div>
        <form action="{{ route('events') }}" class="event-filter-form">
            <div class="event-filter-input-wrap">
                <input type="text" name="search-input"
                    value="{{ request()->input('search-input') ?? '' }}"
                    placeholder="{{ __('Artists, hosts, titles, vibes') }}">
                <button type="submit" class="event-search-button">
                    <i class="fas fa-search"></i>
                </button>
            </div>
            @foreach (['category', 'event', 'min', 'max', 'location', 'dates', 'country', 'state', 'city', 'sort'] as $hiddenField)
                @if (request()->filled($hiddenField))
                    <input type="hidden" name="{{ $hiddenField }}" value="{{ request()->input($hiddenField) }}">
                @endif
            @endforeach
        </form>
    </div>

    <div class="event-filter-card">
        <div class="event-filter-card__head">
            <span>{{ __('Date window') }}</span>
            <strong>{{ __('Choose your dates') }}</strong>
        </div>
        <div class="event-filter-input-wrap event-filter-input-wrap--solo">
            <input type="text" placeholder="{{ __('Start / end date') }}"
                @if (request()->filled('dates')) value="{{ request()->input('dates') }}" @endif name="daterange" />
        </div>
    </div>

    <div class="event-filter-card">
        <div class="event-filter-card__head">
            <span>{{ __('Location') }}</span>
            <strong>{{ __('Near you or far away') }}</strong>
        </div>
        <form action="{{ route('events') }}" class="event-filter-form event-filter-form--stacked" id="locationForm">
            @foreach (['search-input', 'category', 'event', 'dates', 'min', 'max'] as $hiddenField)
                @if (request()->filled($hiddenField))
                    <input type="hidden" name="{{ $hiddenField }}" value="{{ request()->input($hiddenField) }}">
                @endif
            @endforeach

            <div class="event-filter-input-wrap event-filter-input-wrap--location">
                <input type="text" name="location" value="{{ request()->input('location') }}"
                    placeholder="{{ __('Enter location') }}" id="location">
                @if ($basicInfo->google_map_status == 1)
                    <button type="button" class="current-location" onclick="getCurrentLocation()">
                        <i class="fas fa-crosshairs"></i>
                    </button>
                @else
                    <button type="submit" class="event-search-button">
                        <i class="fas fa-search"></i>
                    </button>
                @endif
            </div>
        </form>

        <form action="{{ route('events') }}" id="countryCityForm" class="event-filter-form event-filter-form--stacked mt-15">
            @if ($basicInfo->event_country_status == 1)
                <select id="countryDropdown" name="country" class="mb-15">
                    <option disabled selected>{{ __('Select Country') }}</option>
                    @foreach ($information['countries'] as $country)
                        <option {{ request()->input('country') == $country->slug ? 'selected' : '' }} value="{{ $country->slug }}">
                            {{ $country->name }}
                        </option>
                    @endforeach
                </select>
            @endif

            @if ($basicInfo->event_state_status == 1)
                <select id="stateDropdown" name="state" class="mb-15">
                    <option disabled selected>{{ __('Select State') }}</option>
                    @foreach ($information['states'] as $state)
                        <option {{ request()->input('state') == $state->slug ? 'selected' : '' }} value="{{ $state->slug }}" data-id="{{ $state->id }}">
                            {{ $state->name }}
                        </option>
                    @endforeach
                </select>
            @endif

            <select id="cityDropdown" name="city">
                <option disabled selected>{{ __('Select City') }}</option>
                @foreach ($information['cities'] as $city)
                    <option {{ request()->input('city') == $city->slug ? 'selected' : '' }} value="{{ $city->slug }}">
                        {{ $city->name }}
                    </option>
                @endforeach
            </select>

            @if (request()->filled('location'))
                <select id="event_sort" name="sort" class="mt-15 select2 {{ request()->filled('location') ? '' : 'd-none' }}">
                    <option value="close-by" @selected(request()->input('sort') == 'close-by')>
                        {{ __('Distance') . ': ' . __('Closest first') }}
                    </option>
                    <option value="distance-away" @selected(request()->input('sort') == 'distance-away')>
                        {{ __('Distance') . ': ' . __('Farthest first') }}
                    </option>
                </select>
                <input type="hidden" name="location" value="{{ request()->input('location') }}">
            @endif
        </form>
    </div>

    <div class="event-filter-card">
        <div class="event-filter-card__head">
            <span>{{ __('Category') }}</span>
            <strong>{{ __('Shape the catalog') }}</strong>
        </div>
        <form action="{{ route('events') }}" id="catForm" class="event-filter-form event-filter-form--stacked">
            @foreach (['search-input', 'location', 'event', 'min', 'max', 'dates', 'country', 'state', 'city', 'sort'] as $hiddenField)
                @if (request()->filled($hiddenField))
                    <input type="hidden" name="{{ $hiddenField }}" value="{{ request()->input($hiddenField) }}">
                @endif
            @endforeach
            <select id="category" name="category" class="widget-select">
                <option disabled>{{ __('Select category') }}</option>
                <option value="">{{ __('All') }}</option>
                @foreach ($information['categories'] as $item)
                    <option {{ request()->input('category') == $item->slug ? 'selected' : '' }} value="{{ $item->slug }}">
                        {{ $item->name }}
                    </option>
                @endforeach
            </select>
        </form>
    </div>

    <div class="event-filter-card">
        <div class="event-filter-card__head">
            <span>{{ __('Event mode') }}</span>
            <strong>{{ __('Online or venue') }}</strong>
        </div>
        <div class="event-filter-radio-group">
            <label class="event-filter-radio {{ request()->input('event') == 'online' ? 'is-active' : '' }}" for="radio1">
                <input type="radio" class="custom-control-input" {{ request()->input('event') == 'online' ? 'checked' : '' }}
                    value="online" name="event" id="radio1">
                <span>{{ __('Online events') }}</span>
            </label>
            <label class="event-filter-radio {{ request()->input('event') == 'venue' ? 'is-active' : '' }}" for="radio2">
                <input type="radio" class="custom-control-input" {{ request()->input('event') == 'venue' ? 'checked' : '' }}
                    value="venue" name="event" id="radio2">
                <span>{{ __('Venue events') }}</span>
            </label>
        </div>
    </div>

    <div class="event-filter-card">
        <div class="event-filter-card__head">
            <span>{{ __('Price') }}</span>
            <strong>{{ __('Set your range') }}</strong>
        </div>
        <div class="price-slider-range" id="range-slider"></div>
        <div class="price-btn">
            <input type="text" dir="ltr" id="price" value="{{ request()->input('min') }}" readonly>
            <button class="theme-btn" id="slider_submit">{{ __('Apply range') }}</button>
        </div>
    </div>

    @if (!empty(showAd(2)))
        <div class="event-filter-ad text-center mt-4">
            {!! showAd(2) !!}
        </div>
    @endif
</div>
