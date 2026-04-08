@extends('frontend.layout')

@php
    $pageTitle = !empty($pageHeading) ? ($pageHeading->event_page_title ?? __('Events')) : __('Events');
    $metaKeywords = !empty($seo->meta_keyword_event) ? $seo->meta_keyword_event : '';
    $metaDescription = !empty($seo->meta_description_event) ? $seo->meta_description_event : '';
    $events = $information['events'];
    $signals = $information['eventSignals'] ?? ['result_count' => 0, 'active_categories' => 0, 'active_filters' => 0];
    $selectedCategory = collect($information['categories'] ?? [])->firstWhere('slug', request()->input('category'));
    $activeFilters = array_filter([
        request()->filled('search-input') ? __('Search') . ': ' . request()->input('search-input') : null,
        request()->filled('category') ? __('Category') . ': ' . ($selectedCategory->name ?? request()->input('category')) : null,
        request()->filled('event') ? __('Mode') . ': ' . ucfirst(request()->input('event')) : null,
        request()->filled('location') ? __('Location') . ': ' . request()->input('location') : null,
        request()->filled('dates') ? __('Dates') . ': ' . request()->input('dates') : null,
        request()->filled('country') ? __('Country') . ': ' . request()->input('country') : null,
        request()->filled('state') ? __('State') . ': ' . request()->input('state') : null,
        request()->filled('city') ? __('City') . ': ' . request()->input('city') : null,
    ]);
@endphp

@section('pageHeading')
    {{ $pageTitle }}
@endsection
@section('meta-keywords', $metaKeywords)
@section('meta-description', $metaDescription)

@section('hero-section')
    <section class="event-discovery-hero">
        <div class="event-discovery-hero__backdrop"></div>
        <div class="container event-discovery-hero__container">
            <div class="event-discovery-hero__grid">
                <div class="event-discovery-hero__main">
                    <div class="event-discovery-hero__eyebrow">{{ __('Event discovery') }}</div>
                    <h1>{{ $pageTitle }}</h1>
                    <p class="event-discovery-hero__summary">
                        {{ __('Move through the full catalog with the same scene-first visual language as the app: stronger cards, clearer filters and better social context around every event.') }}
                    </p>
                    <div class="event-discovery-hero__chips">
                        <span>
                            <i class="fas fa-sparkles"></i>
                            {{ $signals['result_count'] ?? 0 }} {{ __('results') }}
                        </span>
                        <span>
                            <i class="fas fa-sliders-h"></i>
                            {{ $signals['active_filters'] ?? 0 }} {{ __('active filters') }}
                        </span>
                        <span>
                            <i class="fas fa-th-large"></i>
                            {{ $signals['active_categories'] ?? 0 }} {{ __('categories') }}
                        </span>
                    </div>
                </div>

                <aside class="event-discovery-hero__card">
                    <span class="event-discovery-hero__card-kicker">{{ __('Discovery state') }}</span>
                    <h3>{{ __('Curated for the moment, not just dumped in a grid.') }}</h3>
                    @if (!empty($activeFilters))
                        <div class="event-discovery-hero__filter-stack">
                            @foreach ($activeFilters as $filter)
                                <span>{{ $filter }}</span>
                            @endforeach
                        </div>
                    @else
                        <p>{{ __('Browse all upcoming events or start narrowing the catalog with location, category, date and price.') }}</p>
                    @endif
                </aside>
            </div>
        </div>
    </section>
@endsection

@section('content')
    <section class="event-discovery-shell py-120 rpy-100">
        <div class="container container-custom">
            <div class="event-discovery-layout">
                <aside class="event-discovery-sidebar">
                    @includeIf('frontend.event.event-sidebar')
                </aside>

                <div class="event-discovery-main">
                    <div class="event-discovery-toolbar">
                        <div>
                            <span class="event-discovery-toolbar__kicker">{{ __('Catalog') }}</span>
                            <h2>{{ __('Curated results') }}</h2>
                        </div>
                        <div class="event-discovery-toolbar__meta">
                            <strong>{{ $signals['result_count'] ?? 0 }}</strong>
                            <span>{{ __('events visible right now') }}</span>
                        </div>
                    </div>

                    @if (!empty($activeFilters))
                        <div class="event-discovery-active-filters">
                            @foreach ($activeFilters as $filter)
                                <span>{{ $filter }}</span>
                            @endforeach
                        </div>
                    @endif

                    <div class="row">
                        @forelse ($events as $event)
                            <div class="col-xl-6 col-md-6">
                                <article class="event-discovery-card">
                                    <div class="event-discovery-card__media">
                                        <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                            <img src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}" alt="{{ $event->title }}">
                                        </a>
                                        <div class="event-discovery-card__overlay"></div>
                                        <div class="event-discovery-card__topline">
                                            <span class="event-discovery-card__badge">{{ $event->listing_badge }}</span>
                                            <span class="event-discovery-card__price">{{ $event->price_display }}</span>
                                        </div>
                                        @if (Auth::guard('customer')->check())
                                            @php
                                                $checkWishList = checkWishList($event->id, Auth::guard('customer')->id());
                                            @endphp
                                        @else
                                            @php
                                                $checkWishList = false;
                                            @endphp
                                        @endif
                                        <a href="{{ $checkWishList ? route('remove.wishlist', $event->id) : route('addto.wishlist', $event->id) }}"
                                            class="event-discovery-card__bookmark {{ $checkWishList ? 'is-active' : '' }}">
                                            <i class="{{ $checkWishList ? 'fas' : 'far' }} fa-bookmark"></i>
                                        </a>
                                    </div>
                                    <div class="event-discovery-card__body">
                                        <div class="event-discovery-card__eyebrow">
                                            <span>{{ $event->status_label }}</span>
                                            <span>{{ $event->date_badge }}</span>
                                        </div>
                                        <h3>
                                            <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                {{ $event->title }}
                                            </a>
                                        </h3>
                                        <a href="{{ $event->organizer_route }}" class="event-discovery-card__organizer">
                                            {{ __('By') }} {{ $event->organizer_name }}
                                        </a>
                                        <p>{{ $event->short_description }}</p>

                                        <div class="event-discovery-card__meta-grid">
                                            <div>
                                                <span>{{ __('Starts') }}</span>
                                                <strong>{{ $event->date_full }}</strong>
                                            </div>
<<<<<<< Updated upstream
                                            <div class="event-content">
                                                <ul class="time-info" dir="ltr">
                                                    @php
                                                        if ($event->date_type == 'multiple') {
                                                            $event_date = eventLatestDates($event->id);
                                                            $date = strtotime(@$event_date->start_date);
                                                        } else {
                                                            $date = strtotime($event->start_date);
                                                        }
                                                    @endphp
                                                    <li>
                                                        <i class="far fa-calendar-alt"></i>
                                                        <span>
                                                            {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->translatedFormat('d M') }}
                                                        </span>
                                                    </li>

                                                    <li>
                                                        <i class="far fa-hourglass"></i>
                                                        <span title="Event Duration">
                                                            {{ $event->date_type == 'multiple' ? @$event_date->duration : $event->duration }}
                                                        </span>
                                                    </li>
                                                    <li>
                                                        <i class="far fa-clock"></i>
                                                        <span>
                                                            @php
                                                                $start_time = strtotime($event->start_time);
                                                            @endphp
                                                            {{ \Carbon\Carbon::parse($start_time)->timezone($websiteInfo->timezone)->translatedFormat('h:s A') }}
                                                        </span>
                                                    </li>
                                                </ul>
                                                @if ($event->organizer_id != null)
                                                    @php
                                                        $organizer = App\Models\Organizer::where(
                                                            'id',
                                                            $event->organizer_id,
                                                        )->first();
                                                    @endphp
                                                    @if ($organizer)
                                                        <a href="{{ route('frontend.organizer.details', [$organizer->id, str_replace(' ', '-', $organizer->username)]) }}"
                                                            class="organizer">{{ __('By') }}&nbsp;&nbsp;{{ @$organizer->organizer_info->name }}</a>
                                                    @endif
                                                @else
                                                    @php
                                                        $admin = App\Models\Admin::first();
                                                    @endphp
                                                    <a href="{{ route('frontend.organizer.details', [$admin->id, str_replace(' ', '-', $admin->username), 'admin' => 'true']) }}"
                                                        class="organizer">{{ __('By') }} {{ $admin->username }}</a>
                                                @endif
                                                <h5>
                                                    <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                        @if (strlen($event->title) > 70)
                                                            {{ mb_substr($event->title, 0, 70) . '...' }}
                                                        @else
                                                            {{ $event->title }}
                                                        @endif
                                                    </a>
                                                </h5>
                                                @php
                                                    $desc = strip_tags($event->description);
                                                @endphp

                                                @if (strlen($desc) > 100)
                                                    <p class="event-description">{{ mb_substr($desc, 0, 100) . '....' }}
                                                    </p>
                                                @else
                                                    <p class="event-description">{{ $desc }}</p>
                                                @endif
                                                @php
                                                    if ($event->event_type == 'online') {
                                                        $ticket = App\Models\Event\Ticket::where('event_id', $event->id)
                                                            ->orderBy('price', 'asc')
                                                            ->first();
                                                    } else {
                                                        $ticket = App\Models\Event\Ticket::where([
                                                            ['event_id', $event->id],
                                                            ['price', '!=', null],
                                                        ])
                                                            ->orderBy('price', 'asc')
                                                            ->first();
                                                        if (empty($ticket)) {
                                                            $ticket = App\Models\Event\Ticket::where([
                                                                ['event_id', $event->id],
                                                                ['f_price', '!=', null],
                                                            ])
                                                                ->orderBy('price', 'asc')
                                                                ->first();
                                                        }
                                                    }
                                                    $event_count = DB::table('tickets')
                                                        ->where('event_id', $event->id)
                                                        ->get()
                                                        ->count();
                                                @endphp
                                                @if ($basicInfo->google_map_status == 1 && request()->input('location'))
                                                    <span class="font-sm icon-start d-block">
                                                        <i class="fas fa-map-signs"></i>
                                                        {{ number_format($event->distance / 1000, 2) }}
                                                        {{ __('km') }}
                                                    </span>
                                                @endif
                                                <div class="price-remain">
                                                    <div class="location">
                                                        @if ($event->event_type == 'venue')
                                                            <i class="fas fa-map-marker-alt"></i>
                                                            <span>
                                                                {{ $event->address }}
                                                            </span>
                                                        @else
                                                            <i class="fas fa-map-marker-alt"></i>
                                                            <span>{{ __('Online') }}</span>
                                                        @endif
                                                    </div>
                                                    <span>

                                                        @if ($ticket)
                                                            @if ($ticket->event_type == 'online')
                                                                @if ($ticket->pricing_type != 'free')
                                                                    <span class="price" dir="ltr">
                                                                        @if ($ticket->early_bird_discount == 'enable')
                                                                            @php
                                                                                $discount_date = Carbon\Carbon::parse(
                                                                                    $ticket->early_bird_discount_date .
                                                                                        $ticket->early_bird_discount_time,
                                                                                );
                                                                            @endphp

                                                                            @if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast())
                                                                                @php
                                                                                    $calculate_price =
                                                                                        $ticket->price -
                                                                                        $ticket->early_bird_discount_amount;
                                                                                @endphp
                                                                                {{ symbolPrice($calculate_price) }}
                                                                                <span>
                                                                                    <del>
                                                                                        {{ symbolPrice($ticket->price) }}
                                                                                    </del>
                                                                                </span>
                                                                            @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                @php
                                                                                    $p_price =
                                                                                        ($ticket->price *
                                                                                            $ticket->early_bird_discount_amount) /
                                                                                        100;
                                                                                    $calculate_price =
                                                                                        $ticket->price - $p_price;
                                                                                @endphp

                                                                                {{ symbolPrice($calculate_price) }}
                                                                                <span>
                                                                                    <del>
                                                                                        {{ symbolPrice($ticket->price) }}
                                                                                    </del>
                                                                                </span>
                                                                            @else
                                                                                @php
                                                                                    $calculate_price = $ticket->price;
                                                                                @endphp
                                                                                {{ symbolPrice($calculate_price) }}
                                                                            @endif
                                                                        @else
                                                                            @php
                                                                                $calculate_price = $ticket->price;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}
                                                                        @endif

                                                                    </span>
                                                                @else
                                                                    <span class="price">{{ __('Free') }}</span>
                                                                @endif
                                                            @endif
                                                            @if ($ticket->event_type == 'venue')
                                                                @if ($ticket->pricing_type == 'variation')
                                                                    <span class="price" dir="ltr">
                                                                        @php
                                                                            $variation = json_decode(
                                                                                $ticket->variations,
                                                                                true,
                                                                            );

                                                                            $v_min_price = array_reduce(
                                                                                $variation,
                                                                                function ($a, $b) {
                                                                                    return $a['price'] < $b['price']
                                                                                        ? $a
                                                                                        : $b;
                                                                                },
                                                                                array_shift($variation),
                                                                            );

                                                                            if ($v_min_price['slot_enable'] == 1) {
                                                                                $slot_variations = json_decode(
                                                                                    $ticket->variations,
                                                                                    true,
                                                                                );

                                                                                $v_slot_min_price = array_reduce(
                                                                                    $slot_variations,
                                                                                    function ($a, $b) {
                                                                                        return $a['slot_seat_min_price'] < $b['slot_seat_min_price']
                                                                                            ? $a
                                                                                            : $b;
                                                                                    },
                                                                                    array_shift($slot_variations),
                                                                                );
                                                                                $price = $v_slot_min_price['slot_seat_min_price'] ?? 0.0;
                                                                            } else {
                                                                                $price = $v_min_price['price'];
                                                                            }
                                                                        @endphp
                                                                        <span class="price">
                                                                            @if ($currentLanguageInfo->direction == 1)
                                                                                <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                            @endif
                                                                            @if ($ticket->early_bird_discount == 'enable')
                                                                                @php
                                                                                    $discount_date = Carbon\Carbon::parse(
                                                                                        $ticket->early_bird_discount_date .
                                                                                            $ticket->early_bird_discount_time,
                                                                                    );
                                                                                @endphp
                                                                                @if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast())
                                                                                    @php
                                                                                        $calculate_price =
                                                                                            $price -
                                                                                            $ticket->early_bird_discount_amount;
                                                                                    @endphp
                                                                                    @if ($calculate_price > 0)
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                        <span>
                                                                                            <del>
                                                                                                {{ symbolPrice($price) }}
                                                                                            </del>
                                                                                        </span>
                                                                                    @endif
                                                                                @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                    @php
                                                                                        $p_price =
                                                                                            ($price *
                                                                                                $ticket->early_bird_discount_amount) /
                                                                                            100;
                                                                                        $calculate_price =
                                                                                            $price - $p_price;
                                                                                    @endphp

                                                                                    @if ($calculate_price > 0)
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                        <span>
                                                                                            <del>
                                                                                                {{ symbolPrice($price) }}
                                                                                            </del>
                                                                                        </span>
                                                                                    @endif
                                                                                @else
                                                                                    @php
                                                                                        $calculate_price = $price;
                                                                                    @endphp
                                                                                    @if ($calculate_price > 0)
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                    @endif
                                                                                @endif
                                                                            @else
                                                                                @php
                                                                                    $calculate_price = $price;
                                                                                @endphp
                                                                                @if ($calculate_price > 0)
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                @endif
                                                                            @endif
                                                                            @if ($currentLanguageInfo->direction != 1)
                                                                                <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                            @endif
                                                                        </span>
                                                                    </span>
                                                                @elseif($ticket->pricing_type == 'normal')
                                                                    <span class="price" dir="ltr">
                                                                        @if ($currentLanguageInfo->direction == 1)
                                                                            <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                        @endif
                                                                        @php
                                                                            if (
                                                                                $ticket->normal_ticket_slot_enable == 1
                                                                            ) {
                                                                                $ticketPrice =
                                                                                    $ticket->slot_seat_min_price;
                                                                            } else {
                                                                                $ticketPrice = $ticket->price;
                                                                            }
                                                                        @endphp

                                                                        @if ($ticket->early_bird_discount == 'enable')
                                                                            {{-- check discount date over or not --}}
                                                                            @php
                                                                                $discount_date = Carbon\Carbon::parse(
                                                                                    $ticket->early_bird_discount_date .
                                                                                        $ticket->early_bird_discount_time,
                                                                                );
                                                                            @endphp

                                                                            @if ($ticket->early_bird_discount_type == 'fixed' && !$discount_date->isPast())
                                                                                @php
                                                                                    $calculate_price =
                                                                                        $ticketPrice -
                                                                                        $ticket->early_bird_discount_amount;
                                                                                @endphp
                                                                                @if ($calculate_price > 0)
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                    <span>
                                                                                        <del>
                                                                                            {{ symbolPrice($ticketPrice) }}
                                                                                        </del>
                                                                                    </span>
                                                                                @endif
                                                                            @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                @php
                                                                                    $p_price =
                                                                                        ($ticketPrice *
                                                                                            $ticket->early_bird_discount_amount) /
                                                                                        100;
                                                                                    $calculate_price =
                                                                                        $ticketPrice - $p_price;
                                                                                @endphp
                                                                                @if ($calculate_price > 0)
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                    <span>
                                                                                        <del>
                                                                                            {{ symbolPrice($ticketPrice) }}
                                                                                        </del>
                                                                                    </span>
                                                                                @endif
                                                                            @else
                                                                                @php
                                                                                    $calculate_price = $ticketPrice;
                                                                                @endphp
                                                                                @if ($calculate_price > 0)
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                @endif
                                                                            @endif
                                                                        @else
                                                                            @php
                                                                                $calculate_price = $ticketPrice;
                                                                            @endphp
                                                                            @if ($calculate_price > 0)
                                                                                {{ symbolPrice($calculate_price) }}
                                                                            @endif
                                                                        @endif
                                                                        @if ($currentLanguageInfo->direction != 1)
                                                                            <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                        @endif
                                                                    </span>
                                                                @else
                                                                    <span class="price">
                                                                        {{ __('Free') }}
                                                                        <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                    </span>
                                                                @endif
                                                            @endif
                                                        @endif
                                                    </span>
                                                </div>
=======
                                            <div>
                                                <span>{{ __('Time') }}</span>
                                                <strong>{{ $event->time_badge }}</strong>
>>>>>>> Stashed changes
                                            </div>
                                            <div>
                                                <span>{{ __('Duration') }}</span>
                                                <strong>{{ $event->duration_badge }}</strong>
                                            </div>
                                            <div>
                                                <span>{{ __('Location') }}</span>
                                                <strong>{{ $event->location_badge }}</strong>
                                            </div>
                                        </div>

                                        <div class="event-discovery-card__footer">
                                            <div class="event-discovery-card__signals">
                                                <span>{{ $event->price_hint }}</span>
                                                @if ($event->ticket_count > 0)
                                                    <span>{{ $event->ticket_count }} {{ __('ticket tiers') }}</span>
                                                @endif
                                                @if ($event->distance_km)
                                                    <span>{{ $event->distance_km }} {{ __('km away') }}</span>
                                                @endif
                                            </div>
                                            <a href="{{ route('event.details', [$event->slug, $event->id]) }}" class="event-discovery-card__cta">
                                                {{ __('Open event') }}
                                                <i class="fas fa-arrow-right"></i>
                                            </a>
                                        </div>
                                    </div>
                                </article>
                            </div>
                        @empty
                            <div class="col-12">
                                <div class="event-discovery-empty-state">
                                    <h3>{{ __('No events found') }}</h3>
                                    <p>{{ __('Try widening the date window, changing the location, or clearing one of the filters to reopen the catalog.') }}</p>
                                </div>
                            </div>
                        @endforelse
                    </div>

                    @if (method_exists($events, 'links'))
                        <div class="event-discovery-pagination">
                            {{ $events->links() }}
                        </div>
                    @endif

                    @if (!empty(showAd(3)))
                        <div class="event-discovery-ad text-center mt-4">
                            {!! showAd(3) !!}
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </section>

    <form id="filtersForm" class="d-none" action="{{ route('events') }}" method="GET">
        <input type="hidden" id="category-id" name="category" value="{{ request()->input('category') ?? '' }}">
        <input type="hidden" id="event" name="event" value="{{ request()->input('event') ?? '' }}">
        <input type="hidden" id="min-id" name="min" value="{{ request()->input('min') ?? '' }}">
        <input type="hidden" id="max-id" name="max" value="{{ request()->input('max') ?? '' }}">
        <input type="hidden" name="search-input" value="{{ request()->input('search-input') ?? '' }}">
        <input type="hidden" name="location" value="{{ request()->input('location') ?? '' }}">
        <input type="hidden" id="dates-id" name="dates" value="{{ request()->input('dates') ?? '' }}">
        <button type="submit" id="submitBtn"></button>
    </form>

    <style>
        .event-discovery-hero {
            position: relative;
            overflow: hidden;
            padding: 144px 0 88px;
            color: #f7f0ff;
        }

        .event-discovery-hero__backdrop {
            position: absolute;
            inset: 0;
            background:
                radial-gradient(circle at 12% 18%, rgba(140, 37, 244, 0.22), transparent 24%),
                radial-gradient(circle at 88% 20%, rgba(41, 143, 255, 0.18), transparent 26%),
                linear-gradient(180deg, rgba(13, 10, 20, 0.96), rgba(20, 14, 28, 0.98));
        }

        .event-discovery-hero__container {
            position: relative;
            z-index: 1;
        }

        .event-discovery-hero__grid {
            display: grid;
            grid-template-columns: minmax(0, 1.6fr) minmax(320px, 0.9fr);
            gap: 28px;
        }

        .event-discovery-hero__main,
        .event-discovery-hero__card,
        .event-discovery-card,
        .event-filter-card,
        .event-discovery-empty-state {
            background: linear-gradient(180deg, rgba(45, 31, 61, 0.84), rgba(20, 14, 28, 0.96));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 24px 60px rgba(7, 4, 14, 0.32);
            backdrop-filter: blur(18px);
        }

        .event-discovery-hero__main,
        .event-discovery-hero__card {
            border-radius: 34px;
            padding: 34px 36px;
        }

        .event-discovery-hero__eyebrow,
        .event-discovery-toolbar__kicker,
        .event-filter-card__head span {
            display: inline-flex;
            align-items: center;
            font-size: 0.82rem;
            letter-spacing: 0.24em;
            text-transform: uppercase;
            color: rgba(236, 220, 255, 0.68);
            margin-bottom: 14px;
        }

        .event-discovery-hero h1,
        .event-discovery-toolbar h2,
        .event-discovery-card h3,
        .event-filter-card__head strong {
            font-family: 'Outfit', sans-serif;
        }

        .event-discovery-hero h1 {
            margin: 0;
            font-size: clamp(2.8rem, 4vw, 4.4rem);
            line-height: 0.96;
            max-width: 10ch;
        }

        .event-discovery-hero__summary,
        .event-discovery-hero__card p,
        .event-discovery-card p,
        .event-discovery-empty-state p {
            color: rgba(236, 229, 244, 0.78);
            line-height: 1.75;
        }

        .event-discovery-hero__summary {
            margin: 18px 0 0;
            max-width: 62ch;
            font-size: 1.02rem;
        }

        .event-discovery-hero__chips,
        .event-discovery-hero__filter-stack,
        .event-discovery-active-filters,
        .event-discovery-card__eyebrow,
        .event-discovery-card__signals,
        .event-filter-radio-group,
        .event-discovery-layout {
            display: flex;
            flex-wrap: wrap;
        }

        .event-discovery-hero__chips,
        .event-discovery-hero__filter-stack,
        .event-discovery-active-filters {
            gap: 12px;
            margin-top: 24px;
        }

        .event-discovery-hero__chips span,
        .event-discovery-hero__filter-stack span,
        .event-discovery-active-filters span,
        .event-discovery-card__signals span {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.06);
            color: rgba(247, 240, 255, 0.82);
            font-size: 0.9rem;
        }

        .event-discovery-hero__card h3 {
            margin: 0;
            font-size: 1.36rem;
            color: #fff;
        }

        .event-discovery-shell {
            background: radial-gradient(circle at top, rgba(140, 37, 244, 0.08), transparent 28%), #120a1c;
        }

        .event-discovery-layout {
            gap: 28px;
            align-items: start;
        }

        .event-discovery-sidebar {
            width: 336px;
            position: sticky;
            top: 112px;
        }

        .event-discovery-main {
            flex: 1 1 0;
            min-width: 0;
        }

        .event-discovery-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 18px;
            margin-bottom: 24px;
        }

        .event-discovery-toolbar h2 {
            margin: 0;
            font-size: 2rem;
            color: #fff;
        }

        .event-discovery-toolbar__meta {
            text-align: right;
        }

        .event-discovery-toolbar__meta strong {
            display: block;
            color: #fff;
            font-size: 1.8rem;
            line-height: 1;
        }

        .event-discovery-toolbar__meta span {
            color: rgba(236, 229, 244, 0.68);
        }

        .event-discovery-card {
            border-radius: 28px;
            overflow: hidden;
            margin-bottom: 24px;
        }

        .event-discovery-card__media {
            position: relative;
            aspect-ratio: 16 / 10;
            overflow: hidden;
        }

        .event-discovery-card__media img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .event-discovery-card:hover .event-discovery-card__media img {
            transform: scale(1.04);
        }

        .event-discovery-card__overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(13, 10, 20, 0.08), rgba(13, 10, 20, 0.7));
        }

        .event-discovery-card__topline {
            position: absolute;
            top: 18px;
            left: 18px;
            right: 18px;
            z-index: 1;
            display: flex;
            justify-content: space-between;
            gap: 12px;
        }

        .event-discovery-card__badge,
        .event-discovery-card__price,
        .event-discovery-card__bookmark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            backdrop-filter: blur(14px);
        }

        .event-discovery-card__badge,
        .event-discovery-card__price {
            padding: 9px 14px;
            background: rgba(255, 255, 255, 0.12);
            color: #fff;
            font-size: 0.84rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        .event-discovery-card__bookmark {
            position: absolute;
            top: 18px;
            right: 18px;
            z-index: 1;
            width: 44px;
            height: 44px;
            background: rgba(16, 11, 24, 0.54);
            color: #fff;
        }

        .event-discovery-card__bookmark.is-active {
            background: rgba(58, 175, 111, 0.8);
        }

        .event-discovery-card__body {
            padding: 24px;
        }

        .event-discovery-card__eyebrow {
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
            color: rgba(231, 217, 244, 0.72);
            font-size: 0.84rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .event-discovery-card h3 {
            margin: 0;
            font-size: 1.4rem;
            line-height: 1.16;
        }

        .event-discovery-card h3 a,
        .event-discovery-card__organizer,
        .event-discovery-card__cta {
            color: #fff;
        }

        .event-discovery-card__organizer {
            display: inline-flex;
            margin-top: 12px;
            color: rgba(219, 203, 236, 0.78);
            font-weight: 600;
        }

        .event-discovery-card p {
            margin: 14px 0 0;
        }

        .event-discovery-card__meta-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
            margin-top: 20px;
        }

        .event-discovery-card__meta-grid > div,
        .event-filter-card,
        .event-discovery-empty-state {
            border-radius: 24px;
        }

        .event-discovery-card__meta-grid > div {
            padding: 14px 16px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .event-discovery-card__meta-grid span,
        .event-filter-card__head strong {
            display: block;
        }

        .event-discovery-card__meta-grid span {
            color: rgba(224, 210, 238, 0.62);
            font-size: 0.78rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .event-discovery-card__meta-grid strong {
            margin-top: 5px;
            color: #fff;
            font-size: 1rem;
            font-weight: 700;
        }

        .event-discovery-card__footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            margin-top: 22px;
        }

        .event-discovery-card__signals {
            gap: 10px;
        }

        .event-discovery-card__cta {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            font-weight: 700;
        }

        .event-discovery-empty-state {
            padding: 56px 28px;
            text-align: center;
        }

        .event-discovery-empty-state h3 {
            color: #fff;
            margin-bottom: 10px;
            font-family: 'Outfit', sans-serif;
        }

        .event-discovery-pagination {
            margin-top: 10px;
        }

        .event-discovery-pagination .pagination {
            justify-content: flex-start;
            gap: 10px;
        }

        .event-discovery-pagination .page-item .page-link {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: #fff;
            border-radius: 14px;
            min-width: 46px;
            min-height: 46px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .event-discovery-pagination .page-item.active .page-link {
            background: linear-gradient(135deg, rgba(140, 37, 244, 0.92), rgba(178, 104, 255, 0.88));
            border-color: transparent;
            box-shadow: 0 12px 28px rgba(109, 23, 190, 0.32);
        }

        .event-filter-shell {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .event-filter-card {
            padding: 22px;
        }

        .event-filter-card__head {
            margin-bottom: 14px;
        }

        .event-filter-card__head strong {
            font-size: 1.15rem;
            color: #fff;
            line-height: 1.2;
        }

        .event-filter-form,
        .event-filter-form--stacked {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .event-filter-input-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }

        .event-filter-input-wrap input,
        .event-filter-card select,
        .price-btn input {
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.04);
            color: #fff;
            border-radius: 18px;
            min-height: 54px;
            padding: 0 18px;
        }

        .event-filter-input-wrap input::placeholder,
        .event-filter-card select,
        .price-btn input {
            color: rgba(236, 229, 244, 0.52);
        }

        .event-filter-input-wrap--location input {
            padding-right: 62px;
        }

        .event-search-button,
        .current-location {
            position: absolute;
            right: 8px;
            width: 40px;
            height: 40px;
            border: 0;
            border-radius: 14px;
            background: linear-gradient(135deg, rgba(140, 37, 244, 0.92), rgba(178, 104, 255, 0.88));
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .event-filter-radio-group {
            gap: 12px;
        }

        .event-filter-radio {
            flex: 1 1 100%;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
            color: rgba(239, 232, 247, 0.82);
            cursor: pointer;
        }

        .event-filter-radio.is-active {
            background: rgba(140, 37, 244, 0.14);
            border-color: rgba(178, 104, 255, 0.36);
            color: #fff;
        }

        .event-filter-radio input {
            accent-color: #b268ff;
        }

        .price-slider-range {
            margin: 8px 4px 18px;
        }

        .price-btn {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .event-filter-ad,
        .event-discovery-ad {
            border-radius: 24px;
            overflow: hidden;
        }

        @media (max-width: 1199px) {
            .event-discovery-layout {
                flex-direction: column;
            }

            .event-discovery-sidebar {
                width: 100%;
                position: static;
            }
        }

        @media (max-width: 991px) {
            .event-discovery-hero {
                padding: 124px 0 72px;
            }

            .event-discovery-hero__grid {
                grid-template-columns: 1fr;
            }

            .event-discovery-toolbar {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (max-width: 767px) {
            .event-discovery-hero__main,
            .event-discovery-hero__card,
            .event-filter-card,
            .event-discovery-card {
                padding: 22px;
                border-radius: 24px;
            }

            .event-discovery-hero h1 {
                max-width: none;
                font-size: 2.6rem;
            }

            .event-discovery-card__meta-grid {
                grid-template-columns: 1fr;
            }

            .event-discovery-card__footer {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
@endsection

@section('custom-script')
    <script type="text/javascript" src="{{ asset('assets/front/js/moment.min.js') }}"></script>
    <script type="text/javascript" src="{{ asset('assets/front/js/daterangepicker.min.js') }}"></script>

    <script>
        let min_price = {!! htmlspecialchars($information['min']) !!};
        let max_price = {!! htmlspecialchars($information['max']) !!};
        let symbol = "{!! htmlspecialchars($basicInfo->base_currency_symbol) !!}";
        let position = "{!! htmlspecialchars($basicInfo->base_currency_symbol_position) !!}";
        let curr_min = {!! !empty(request()->input('min')) ? htmlspecialchars(request()->input('min')) : 5 !!};
        let curr_max = {!! !empty(request()->input('max')) ? htmlspecialchars(request()->input('max')) : 800 !!};
        const countryUrl = "{{ route('frontend.get_country') }}";
        const stateUrl = "{{ route('frontend.get_state') }}";
        const cityUrl = "{{ route('frontend.get_city') }}";
    </script>

    <script src="{{ asset('assets/front/js/custom_script.js') }}"></script>
    <script src="{{ asset('assets/admin/js/event.js') }}"></script>
    @if ($basicInfo->google_map_status == 1)
        <script src="{{ asset('assets/front/js/geo-search.js') }}"></script>
    @endif
@endsection
