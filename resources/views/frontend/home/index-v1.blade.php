@extends('frontend.layout')
@section('pageHeading')
    {{ __('Home') }}
@endsection

@php
    $metaKeywords = !empty($seo->meta_keyword_home) ? $seo->meta_keyword_home : '';
    $metaDescription = !empty($seo->meta_description_home) ? $seo->meta_description_home : '';
    $backgroundAsset = $heroSection && $heroSection->background_image
        ? asset('assets/admin/img/hero-section/' . $heroSection->background_image)
        : asset('assets/front/images/hero-bg.jpg');
    $leadEvent = $featuredEvents->first();
    $organizerProfileService = app(\App\Services\OrganizerPublicProfileService::class);
    $leadOrganizer = $leadEvent
        ? $organizerProfileService->organizerPayloadForEvent(
            $leadEvent->owner_identity_id ?? null,
            $leadEvent->organizer_id ?? null,
            $currentLanguageInfo->id,
        )
        : null;
    $proTracks = collect([
        [
            'icon' => 'fas fa-wave-square',
            'eyebrow' => __('For organizers'),
            'title' => __('Launch, operate and grow the crowd from web.'),
            'copy' => __('Create events, manage bookings and use the web as your public acquisition layer.'),
            'route' => route('frontend.for_organizers'),
            'cta' => __('Explore organizer tools'),
        ],
        [
            'icon' => 'fas fa-compact-disc',
            'eyebrow' => __('For artists'),
            'title' => __('Turn appearances into followable identity.'),
            'copy' => __('Build public presence around lineups, profiles, reviews and repeat discovery.'),
            'route' => route('frontend.for_artists'),
            'cta' => __('See artist pathways'),
        ],
        [
            'icon' => 'fas fa-map-marked-alt',
            'eyebrow' => __('For venues'),
            'title' => __('Make the place part of the brand.'),
            'copy' => __('Use public venue pages and web operations while the app handles guest access.'),
            'route' => route('frontend.for_venues'),
            'cta' => __('Open venue view'),
        ],
    ]);
@endphp
@section('meta-keywords', "{{ $metaKeywords }}")
@section('meta-description', "$metaDescription")

<<<<<<< Updated upstream
@section('hero-section')
    <!-- Hero Section Start -->
    @if ($heroSection)
        <section class="hero-section overlay pt-105 pb-120 lazy"
            data-bg="{{ asset('assets/admin/img/hero-section/' . $heroSection->background_image) }}">
        @else
            <section class="hero-section overlay pt-105 pb-120 lazy" data-bg="{{ asset('assets/front/images/hero-bg.jpg') }}">
    @endif
    <div class="container">
        <div class="hero-content">
            <h1>
                {{ $heroSection ? $heroSection->first_title : __('Event Ticketing and Booking System') }}
            </h1>
            <p>
                {{ $heroSection
                    ? $heroSection->second_title
                    : __(
                        'This is an affordable and powerful event ticketing platform for event organisers, promoters, and managers. Easily create, promote and sell tickets to your events of every type and size.',
                    ) }}
            </p>
            <form id="event-search" class="event-search mt-35" name="event-search" action="{{ route('events') }}"
                method="get">
                <div class="search-item">
                    <label for="borwseby"><i class="fas fa-list"></i></label>
                    <select name="category" id="borwseby">
                        <option value="">{{ __('All Category') }}</option>
                        @foreach ($categories as $category)
                            <option value="{{ $category->slug }}">{{ $category->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="search-item">
                    <label for="search"><i class="fas fa-search"></i></label>
                    <input type="search" id="search" name="search-input" placeholder="{{ __('Search Anything') }}">
                </div>
                <button type="submit"
                    class="theme-btn">{{ $heroSection ? $heroSection->first_button : __('Search') }}</button>
            </form>
        </div>
    </div>
    </section>
    <!-- Hero Section End -->
@endsection
@section('content')

    <!-- Events Section Start -->
    @if ($secInfo->featured_section_status == 1)
        <section class="events-section pt-110 rpt-90 pb-90 rpb-70 bg-lighter">
            <div class="container">

                <div class="section-title text-center mb-45">
                    <h2>{{ $secTitleInfo ? $secTitleInfo->event_section_title : __('Featured Events') }}</h2>
                </div>

                @if ($eventCategories->isEmpty())
                    <p class="text-center">{{ __('No Events Found') }}</p>
                @else
                    <nav>
                        <div class="nav nav-tabs events-tabs mb-40" id="nav-tab" role="tablist">
                            <button class="nav-link active" id="nav-all-tab" data-toggle="tab" data-target="#nav-all"
                                type="button" role="tab" aria-controls="nav-all"
                                aria-selected="true">{{ __('All') }}</button>
                            @foreach ($eventCategories as $item)
                                <button class="nav-link" id="nav-{{ $item->id }}-tab" data-toggle="tab"
                                    data-target="#nav-{{ $item->id }}" type="button" role="tab"
                                    aria-controls="nav-{{ $item->id }}"
                                    aria-selected="false">{{ $item->name }}</button>
                            @endforeach
                        </div>
                    </nav>

                    <div class="tab-content" id="nav-tabContent">
                        <div class="tab-pane fade show active" id="nav-all" role="tabpanel" aria-labelledby="nav-all-tab">
                            <div class="row">
                                @php
                                    $now_time = \Carbon\Carbon::now();
                                    $eventsall = DB::table('event_contents')
                                        ->join('events', 'events.id', '=', 'event_contents.event_id')
                                        ->where([
                                            ['event_contents.language_id', '=', $currentLanguageInfo->id],
                                            ['events.status', 1],
                                            ['events.end_date_time', '>=', $now_time],
                                            ['events.is_featured', '=', 'yes'],
                                        ])
                                        ->orderBy('events.created_at', 'desc')
                                        ->get();
                                @endphp
                                @foreach ($eventsall as $event)
                                    <div class="col-lg-4 col-md-6 item  motivational">
                                        <div class="event-item">
                                            <div class="event-image">
                                                <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                    <img src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                                                        alt="Event">
                                                </a>
                                            </div>
                                            <div class="event-content">
                                                <ul class="time-info">
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
                                                        <span
                                                            title="{{ __('Event Duration') }}">{{ $event->date_type == 'multiple' ? @$event_date->duration : $event->duration }}</span>
                                                    </li>
                                                    <li>
                                                        <i class="far fa-clock"></i>
                                                        <span>
                                                            @php
                                                                $start_time = strtotime($event->start_time);
                                                            @endphp
                                                            {{ \Carbon\Carbon::parse($start_time)->timezone($websiteInfo->timezone)->translatedFormat('h:i A') }}
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
                                                        class="organizer">{{ $admin->username }}</a>
                                                @endif
                                                <h5>
                                                    <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                        @if (strlen($event->title) > 30)
                                                            {{ mb_substr($event->title, 0, 30) . '...' }}
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
                                                                @if ($ticket->price != null)
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
                                                                                        return $a[
                                                                                            'slot_seat_min_price'
                                                                                        ] < $b['slot_seat_min_price']
                                                                                            ? $a
                                                                                            : $b;
                                                                                    },
                                                                                    array_shift($slot_variations),
                                                                                );
                                                                                $price =
                                                                                    $v_slot_min_price[
                                                                                        'slot_seat_min_price'
                                                                                    ] ?? 0.0;
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
                                                                                    {{ symbolPrice($calculate_price) }}
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
                                                                                            {{ symbolPrice($ticket->price) }}
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
                                                                    <span class="price">{{ __('Free') }}
                                                                        <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                @endif
                                                            @endif
                                                        @endif
                                                    </span>
                                                </div>

                                            </div>
                                            @if (Auth::guard('customer')->check())
                                                @php
                                                    $customer_id = Auth::guard('customer')->user()->id;
                                                    $event_id = $event->id;
                                                    $checkWishList = checkWishList($event_id, $customer_id);
                                                @endphp
                                            @else
                                                @php
                                                    $checkWishList = false;
                                                @endphp
                                            @endif
                                            <a href="{{ $checkWishList == false ? route('addto.wishlist', $event->id) : route('remove.wishlist', $event->id) }}"
                                                class="wishlist-btn {{ $checkWishList == true ? 'bg-success' : '' }}">
                                                <i class="far fa-bookmark"></i>
                                            </a>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                        @foreach ($eventCategories as $item)
                            @php
                                $now_time = \Carbon\Carbon::now();
                                $events = DB::table('event_contents')
                                    ->join('events', 'events.id', '=', 'event_contents.event_id')
                                    ->where([
                                        ['event_contents.event_category_id', '=', $item->id],
                                        ['event_contents.language_id', '=', $currentLanguageInfo->id],
                                        ['events.status', 1],
                                        ['events.end_date_time', '>=', $now_time],
                                        ['events.is_featured', '=', 'yes'],
                                    ])
                                    ->orderBy('events.created_at', 'desc')
                                    ->get();
                            @endphp
                            <div class="tab-pane fade" id="nav-{{ $item->id }}" role="tabpanel"
                                aria-labelledby="nav-{{ $item->id }}-tab">
                                <div class="row">
                                    @foreach ($events as $event)
                                        <div class="col-lg-4 col-md-6 item  motivational">
                                            <div class="event-item">
                                                <div class="event-image">
                                                    <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                        <img src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                                                            alt="Event">
                                                    </a>
                                                </div>
                                                <div class="event-content">
                                                    <ul class="time-info">
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
                                                            <span
                                                                title="{{ __('Event Duration') }}">{{ $event->date_type == 'multiple' ? @$event_date->duration : $event->duration }}</span>
                                                        </li>
                                                        <li>
                                                            <i class="far fa-clock"></i>
                                                            <span>
                                                                @php
                                                                    $start_time = strtotime($event->start_time);
                                                                @endphp
                                                                {{ \Carbon\Carbon::parse($start_time)->timezone($websiteInfo->timezone)->translatedFormat('h:i A') }}
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
                                                            class="organizer">{{ $admin->username }}</a>
                                                    @endif
                                                    <h5>
                                                        <a
                                                            href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                                            @if (strlen($event->title) > 30)
                                                                {{ mb_substr($event->title, 0, 30) . '...' }}
                                                            @else
                                                                {{ $event->title }}
                                                            @endif
                                                        </a>
                                                    </h5>
                                                    @php
                                                        $desc = strip_tags($event->description);
                                                    @endphp

                                                    @if (strlen($desc) > 100)
                                                        <p class="event-description">
                                                            {{ mb_substr($desc, 0, 100) . '....' }}</p>
                                                    @else
                                                        <p class="event-description">{{ $desc }}</p>
                                                    @endif
                                                    @php
                                                        if ($event->event_type == 'online') {
                                                            $ticket = App\Models\Event\Ticket::where(
                                                                'event_id',
                                                                $event->id,
                                                            )
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
                                                                    @if ($ticket->price != null)
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
                                                                                        $calculate_price =
                                                                                            $ticket->price;
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
                                                                                            return $a[
                                                                                                'slot_seat_min_price'
                                                                                            ] <
                                                                                                $b[
                                                                                                    'slot_seat_min_price'
                                                                                                ]
                                                                                                ? $a
                                                                                                : $b;
                                                                                        },
                                                                                        array_shift($slot_variations),
                                                                                    );
                                                                                    $price =
                                                                                        $v_slot_min_price[
                                                                                            'slot_seat_min_price'
                                                                                        ] ?? 0.0;
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
                                                                                            <span><del>
                                                                                                    {{ symbolPrice($price) }}
                                                                                                </del>
                                                                                            </span>
                                                                                        @endif
                                                                                    @elseif($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                        @php
                                                                                            $p_price =
                                                                                                ($price *
                                                                                                    $ticket->early_bird_discount_amount) /
                                                                                                100;
                                                                                            $calculate_price =
                                                                                                $p_price - $price;
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
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                    @endif
                                                                                @else
                                                                                    @if ($calculate_price > 0)
                                                                                        @php
                                                                                            $calculate_price = $price;
                                                                                        @endphp
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
                                                                                    $ticket->normal_ticket_slot_enable ==
                                                                                    1
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
                                                                                                {{ symbolPrice($ticket->price) }}
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
                                                                        <span class="price">{{ __('Free') }}
                                                                            <strong>{{ $event_count > 1 ? '*' : '' }}</strong>
                                                                    @endif
                                                                @endif
                                                            @endif
                                                        </span>
                                                    </div>

                                                </div>
                                                @if (Auth::guard('customer')->check())
                                                    @php
                                                        $customer_id = Auth::guard('customer')->user()->id;
                                                        $event_id = $event->id;
                                                        $checkWishList = checkWishList($event_id, $customer_id);
                                                    @endphp
                                                @else
                                                    @php
                                                        $checkWishList = false;
                                                    @endphp
                                                @endif
                                                <a href="{{ $checkWishList == false ? route('addto.wishlist', $event->id) : route('remove.wishlist', $event->id) }}"
                                                    class="wishlist-btn {{ $checkWishList == true ? 'bg-success' : '' }}">
                                                    <i class="far fa-bookmark"></i>
                                                </a>
=======
@section('custom-style')
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Manrope:wght@400;500;600;700;800&display=swap');

        :root {
            --unified-bg: #191022;
            --unified-bg-deep: #120a1c;
            --unified-surface: rgba(45, 31, 61, 0.82);
            --unified-panel: rgba(28, 19, 40, 0.88);
            --unified-border: rgba(255, 255, 255, 0.08);
            --unified-text: #f6f1ff;
            --unified-muted: rgba(228, 220, 247, 0.72);
            --unified-primary: #8c25f4;
            --unified-accent: #ffcf5a;
            --unified-hero-shadow: 0 30px 120px rgba(8, 3, 14, 0.58);
            --unified-panel-shadow: 0 20px 80px rgba(8, 3, 14, 0.36);
        }

        body {
            background:
                radial-gradient(circle at top left, rgba(140, 37, 244, 0.18), transparent 28%),
                radial-gradient(circle at 80% 20%, rgba(255, 207, 90, 0.08), transparent 18%),
                linear-gradient(180deg, #1c1129 0%, #120a1c 52%, #191022 100%) !important;
        }

        .main-header.glass-nav {
            background: rgba(18, 10, 28, 0.74);
            backdrop-filter: blur(22px);
            -webkit-backdrop-filter: blur(22px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
            box-shadow: 0 14px 50px rgba(8, 3, 14, 0.18);
        }

        .main-header .header-upper {
            padding: 18px 0;
        }

        .main-header .navigation > li > a,
        .main-header .navigation li .fa-angle-down {
            color: rgba(246, 241, 255, 0.9) !important;
            font-family: 'Manrope', sans-serif !important;
            font-weight: 600;
            letter-spacing: 0.01em;
        }

        .main-header .menu-btn,
        .main-header .dropdown .btn,
        .main-header .menu-right select {
            background: rgba(255, 255, 255, 0.04) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            color: var(--unified-text) !important;
            border-radius: 999px !important;
            min-height: 46px;
            padding: 0 18px;
        }

        .main-header .menu-right .dropdown-menu {
            background: rgba(21, 13, 32, 0.98);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 20px;
            box-shadow: var(--unified-panel-shadow);
            overflow: hidden;
        }

        .main-header .menu-right .dropdown-item {
            color: rgba(246, 241, 255, 0.8);
        }

        .main-header .menu-right .dropdown-item:hover {
            color: #fff;
            background: rgba(140, 37, 244, 0.14);
        }

        .unified-home {
            position: relative;
            overflow: hidden;
            color: var(--unified-text);
        }

        .unified-home__orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(14px);
            opacity: 0.7;
            pointer-events: none;
        }

        .unified-home__orb--one {
            width: 320px;
            height: 320px;
            top: 110px;
            left: -80px;
            background: radial-gradient(circle, rgba(140, 37, 244, 0.32), transparent 70%);
        }

        .unified-home__orb--two {
            width: 280px;
            height: 280px;
            top: 140px;
            right: -60px;
            background: radial-gradient(circle, rgba(255, 207, 90, 0.12), transparent 68%);
        }

        .unified-home__grid {
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
            background-size: 36px 36px;
            mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.8), transparent 88%);
            opacity: 0.25;
            pointer-events: none;
        }

        .unified-home__hero {
            position: relative;
            padding: 168px 0 72px;
        }

        .unified-home__hero-stage {
            align-items: flex-start;
        }

        .unified-home__hero-copy {
            padding-right: 18px;
        }

        .unified-home__eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 10px 16px;
            margin-bottom: 22px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.82);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.18em;
        }

        .unified-home__eyebrow-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffcf5a, #8c25f4);
            box-shadow: 0 0 18px rgba(140, 37, 244, 0.5);
        }

        .unified-home__title {
            margin: 0;
            font-family: 'Outfit', sans-serif !important;
            font-size: clamp(3rem, 5vw, 5.5rem);
            line-height: 0.98;
            letter-spacing: -0.05em;
            max-width: 760px;
        }

        .unified-home__title-accent {
            display: block;
            color: #d7adff;
        }

        .unified-home__subtitle {
            max-width: 620px;
            margin: 24px 0 0;
            color: var(--unified-muted);
            font-size: 18px;
            line-height: 1.8;
            font-family: 'Manrope', sans-serif;
        }

        .unified-home__hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 30px;
        }

        .unified-home__hero-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-height: 56px;
            padding: 0 22px;
            border-radius: 20px;
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            letter-spacing: 0.01em;
            transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
        }

        .unified-home__hero-action--primary {
            color: #fff;
            background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
            box-shadow: 0 18px 34px rgba(140, 37, 244, 0.3);
        }

        .unified-home__hero-action--ghost {
            color: #fff;
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.04);
        }

        .unified-home__hero-action--line {
            color: rgba(255, 255, 255, 0.74);
            font-family: 'Manrope', sans-serif;
            font-weight: 700;
        }

        .unified-home__hero-action:hover {
            color: #fff;
            transform: translateY(-1px);
        }

        .unified-home__search {
            display: grid;
            grid-template-columns: 1.1fr 1.5fr auto;
            gap: 14px;
            padding: 16px;
            margin-top: 32px;
            border-radius: 30px;
            background: rgba(17, 11, 26, 0.84);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--unified-hero-shadow);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
        }

        .unified-home__search-group {
            position: relative;
            display: flex;
            align-items: center;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
            overflow: hidden;
        }

        .unified-home__search-group i {
            padding-left: 18px;
            color: rgba(255, 255, 255, 0.62);
        }

        .unified-home__search-group input,
        .unified-home__search-group select {
            width: 100%;
            height: 62px;
            border: 0;
            background: transparent;
            color: #fff;
            padding: 0 18px 0 14px;
            font-family: 'Manrope', sans-serif;
        }

        .unified-home__search-group select option {
            color: #111;
        }

        .unified-home__search-group input::placeholder {
            color: rgba(255, 255, 255, 0.48);
        }

        .unified-home__search-btn {
            min-width: 170px;
            height: 62px;
            border: 0;
            border-radius: 22px;
            color: #fff;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
            letter-spacing: 0.02em;
            background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
            box-shadow: 0 18px 35px rgba(140, 37, 244, 0.32);
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .unified-home__search-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 22px 42px rgba(140, 37, 244, 0.4);
        }

        .unified-home__metrics {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 18px;
        }

        .unified-home__track-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-top: 34px;
        }

        .unified-home__track-card {
            position: relative;
            padding: 22px;
            border-radius: 28px;
            background: linear-gradient(180deg, rgba(23, 15, 34, 0.92), rgba(17, 11, 25, 0.92));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--unified-panel-shadow);
            min-height: 230px;
        }

        .unified-home__track-icon {
            width: 52px;
            height: 52px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 18px;
            margin-bottom: 18px;
            background: rgba(140, 37, 244, 0.18);
            color: #fff;
            font-size: 18px;
        }

        .unified-home__track-eyebrow {
            display: inline-block;
            margin-bottom: 10px;
            color: rgba(255, 255, 255, 0.58);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .unified-home__track-title {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            font-size: 1.3rem;
            letter-spacing: -0.03em;
        }

        .unified-home__track-copy {
            margin: 14px 0 0;
            color: var(--unified-muted);
            line-height: 1.8;
            font-size: 15px;
        }

        .unified-home__track-link {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
            color: #fff;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
        }

        .unified-home__metric {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.07);
            color: rgba(255, 255, 255, 0.78);
            font-size: 14px;
        }

        .unified-home__metric strong {
            color: #fff;
            font-size: 15px;
        }

        .unified-home__lead-card {
            position: relative;
            overflow: hidden;
            min-height: 540px;
            padding: 24px;
            border-radius: 34px;
            background: linear-gradient(180deg, rgba(25, 16, 34, 0.12), rgba(25, 16, 34, 0.96)),
                url('{{ $leadEvent ? asset('assets/admin/img/event/thumbnail/' . $leadEvent->thumbnail) : $backgroundAsset }}') center/cover;
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--unified-hero-shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .unified-home__aside {
            display: grid;
            gap: 18px;
            padding-left: 18px;
        }

        .unified-home__aside-stack {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .unified-home__bridge-card {
            position: relative;
            overflow: hidden;
            min-height: 220px;
            padding: 22px;
            border-radius: 28px;
            background: linear-gradient(180deg, rgba(25, 16, 34, 0.94), rgba(15, 10, 23, 0.94));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--unified-panel-shadow);
        }

        .unified-home__bridge-card::before {
            position: absolute;
            inset: 0;
            content: '';
            background:
                radial-gradient(circle at top right, rgba(140, 37, 244, 0.18), transparent 36%),
                linear-gradient(180deg, rgba(255, 255, 255, 0.02), transparent);
            pointer-events: none;
        }

        .unified-home__bridge-card > * {
            position: relative;
            z-index: 1;
        }

        .unified-home__bridge-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 14px;
            color: rgba(255, 255, 255, 0.58);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .unified-home__bridge-title {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            font-size: 1.55rem;
            letter-spacing: -0.03em;
            line-height: 1.05;
        }

        .unified-home__bridge-copy {
            margin: 12px 0 0;
            color: var(--unified-muted);
            line-height: 1.75;
            font-size: 14px;
        }

        .unified-home__bridge-list {
            display: grid;
            gap: 10px;
            margin: 18px 0 0;
        }

        .unified-home__bridge-item {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: rgba(255, 255, 255, 0.84);
            font-size: 13px;
            font-weight: 700;
        }

        .unified-home__bridge-item i {
            width: 28px;
            height: 28px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: rgba(140, 37, 244, 0.18);
            color: #fff;
            font-size: 12px;
        }

        .unified-home__bridge-metrics {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-top: 18px;
        }

        .unified-home__bridge-stat {
            padding: 14px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .unified-home__bridge-stat strong {
            display: block;
            color: #fff;
            font-family: 'Outfit', sans-serif;
            font-size: 1.35rem;
            letter-spacing: -0.03em;
        }

        .unified-home__bridge-stat span {
            display: block;
            margin-top: 4px;
            color: rgba(255, 255, 255, 0.66);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .unified-home__hero-trackrail {
            margin-top: 26px;
        }

        .unified-home__lead-top,
        .unified-home__lead-bottom,
        .unified-home__scene-card > *,
        .unified-home__feature-card > * {
            position: relative;
            z-index: 1;
        }

        .unified-home__lead-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
        }

        .unified-home__pill,
        .unified-home__lead-price,
        .unified-home__category-chip,
        .unified-home__host-stat {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border-radius: 999px;
            padding: 9px 14px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(9, 5, 16, 0.42);
            color: rgba(255, 255, 255, 0.86);
            backdrop-filter: blur(12px);
        }

        .unified-home__lead-price {
            color: #fff1c4;
            letter-spacing: 0.02em;
        }

        .unified-home__lead-title,
        .unified-home__card-title,
        .unified-home__feature-title,
        .unified-home__host-name,
        .unified-home__story-title,
        .unified-home__step-title {
            margin: 0;
            font-family: 'Outfit', sans-serif !important;
            color: #fff !important;
            letter-spacing: -0.03em;
        }

        .unified-home__lead-title {
            margin: 16px 0 10px;
            max-width: 360px;
            font-size: clamp(2rem, 3vw, 2.85rem);
            line-height: 1.02;
            letter-spacing: -0.04em;
        }

        .unified-home__lead-copy {
            max-width: 360px;
            color: rgba(255, 255, 255, 0.76);
            line-height: 1.75;
        }

        .unified-home__lead-meta {
            display: grid;
            gap: 10px;
            margin-top: 18px;
            color: rgba(255, 255, 255, 0.82);
            font-size: 14px;
        }

        .unified-home__lead-meta-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .unified-home__lead-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding-top: 18px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
        }

        .unified-home__lead-organizer {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .unified-home__lead-avatar {
            width: 48px;
            height: 48px;
            border-radius: 16px;
            flex: 0 0 48px;
            object-fit: cover;
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.08);
        }

        .unified-home__section-copy,
        .unified-home__card-meta,
        .unified-home__host-copy,
        .unified-home__story-copy,
        .unified-home__step-copy,
        .unified-home__lead-organizer small {
            color: var(--unified-muted);
        }

        .unified-home__lead-button,
        .unified-home__ghost-link,
        .unified-home__card-action,
        .unified-home__host-link {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none !important;
            transition: transform 0.25s ease, color 0.25s ease;
        }

        .unified-home__lead-button {
            padding: 14px 18px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.08);
            color: #fff;
            font-weight: 700;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .unified-home__lead-button:hover,
        .unified-home__ghost-link:hover,
        .unified-home__card-action:hover,
        .unified-home__host-link:hover {
            color: #fff;
            transform: translateX(2px);
        }

        .unified-home__shell {
            position: relative;
            padding: 12px 0 96px;
        }

        .unified-home__section {
            padding: 32px 0 0;
        }

        .unified-home__section-header {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 26px;
        }

        .unified-home__section-kicker {
            display: inline-block;
            margin-bottom: 12px;
            color: #c79cff;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .unified-home__section-title {
            margin: 0;
            font-family: 'Outfit', sans-serif !important;
            font-size: clamp(2rem, 3vw, 2.9rem);
            line-height: 1.02;
            letter-spacing: -0.04em;
        }

        .unified-home__section-copy {
            max-width: 520px;
            margin: 10px 0 0;
            line-height: 1.8;
        }

        .unified-home__ghost-link {
            padding: 12px 16px;
            border-radius: 16px;
            color: rgba(255, 255, 255, 0.84);
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.03);
            font-weight: 700;
            white-space: nowrap;
        }

        .unified-home__category-row {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 22px;
        }

        .unified-home__category-chip {
            text-transform: none;
            letter-spacing: 0;
            font-size: 14px;
            padding: 12px 16px;
            color: rgba(255, 255, 255, 0.82);
            text-decoration: none !important;
        }

        .unified-home__category-chip strong {
            color: #fff;
        }

        .unified-home__scene-grid,
        .unified-home__host-grid,
        .unified-home__step-grid {
            display: grid;
            gap: 18px;
        }

        .unified-home__scene-grid {
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .unified-home__scene-card,
        .unified-home__host-card,
        .unified-home__story-card,
        .unified-home__step-card,
        .unified-home__feature-card {
            position: relative;
            overflow: hidden;
            border-radius: 28px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: var(--unified-panel);
            box-shadow: var(--unified-panel-shadow);
        }

        .unified-home__scene-card,
        .unified-home__feature-card {
            background-size: cover;
            background-position: center;
        }

        .unified-home__scene-card::before,
        .unified-home__feature-card::before {
            position: absolute;
            inset: 0;
            content: '';
            background: linear-gradient(180deg, rgba(16, 10, 23, 0.12) 0%, rgba(16, 10, 23, 0.92) 100%);
        }

        .unified-home__scene-card {
            min-height: 420px;
            display: flex;
            flex-direction: column;
            justify-content: end;
            padding: 22px;
        }

        .unified-home__card-title {
            font-size: 30px;
            line-height: 1.05;
            max-width: 280px;
            margin-top: 16px;
        }

        .unified-home__card-copy {
            margin: 14px 0 0;
            color: rgba(255, 255, 255, 0.72);
            line-height: 1.75;
        }

        .unified-home__card-meta {
            display: grid;
            gap: 8px;
            margin-top: 16px;
            font-size: 14px;
        }

        .unified-home__card-action {
            margin-top: 18px;
            color: #fff;
            font-weight: 700;
        }

        .unified-home__feature-layout {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 18px;
        }

        .unified-home__feature-main,
        .unified-home__feature-stack {
            display: grid;
            gap: 18px;
        }

        .unified-home__feature-stack {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            align-content: start;
        }

        .unified-home__feature-card {
            min-height: 260px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            justify-content: end;
        }

        .unified-home__feature-card--main {
            min-height: 540px;
        }

        .unified-home__feature-title {
            font-size: 34px;
            line-height: 1.02;
            max-width: 360px;
            margin-top: 16px;
        }

        .unified-home__feature-card--compact .unified-home__feature-title {
            font-size: 24px;
            max-width: 240px;
        }

        .unified-home__feature-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-top: 18px;
        }

        .unified-home__feature-price {
            color: #fff;
            font-weight: 800;
            font-size: 16px;
        }

        .unified-home__host-grid {
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .unified-home__host-card {
            padding: 22px;
            min-height: 280px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .unified-home__host-top {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .unified-home__host-avatar {
            width: 68px;
            height: 68px;
            border-radius: 22px;
            object-fit: cover;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.06);
        }

        .unified-home__host-name {
            font-size: 24px;
            line-height: 1.05;
        }

        .unified-home__host-copy {
            margin: 18px 0 0;
            line-height: 1.75;
        }

        .unified-home__host-stats {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
        }

        .unified-home__host-stat {
            text-transform: none;
            letter-spacing: 0;
            font-size: 13px;
            padding: 10px 13px;
        }

        .unified-home__host-link {
            margin-top: 18px;
            color: #fff;
            font-weight: 700;
        }

        .unified-home__story-wrap {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 18px;
        }

        .unified-home__story-card--visual {
            min-height: 460px;
            background:
                linear-gradient(180deg, rgba(19, 11, 30, 0.12), rgba(19, 11, 30, 0.86)),
                url('{{ !empty($aboutUsSection?->image) ? asset('assets/admin/img/about-us-section/' . $aboutUsSection->image) : $backgroundAsset }}') center/cover;
        }

        .unified-home__story-card--copy {
            padding: 28px;
        }

        .unified-home__story-title {
            font-size: 38px;
            line-height: 1.02;
            margin-bottom: 18px;
        }

        .unified-home__story-copy,
        .unified-home__story-card--copy p,
        .unified-home__story-card--copy li,
        .unified-home__story-card--copy span {
            line-height: 1.85;
        }

        .unified-home__step-grid {
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .unified-home__step-card {
            padding: 22px;
        }

        .unified-home__step-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            margin-bottom: 18px;
            border-radius: 18px;
            background: linear-gradient(135deg, rgba(140, 37, 244, 0.3), rgba(255, 207, 90, 0.18));
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: #fff;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
        }

        .unified-home__step-title {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .unified-home__step-copy {
            line-height: 1.75;
        }

        .unified-home__empty {
            padding: 24px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px dashed rgba(255, 255, 255, 0.12);
            color: rgba(255, 255, 255, 0.68);
            text-align: center;
        }

        @media (max-width: 1199.98px) {
            .unified-home__hero {
                padding-top: 150px;
            }

            .unified-home__hero-copy,
            .unified-home__aside {
                padding-right: 0;
                padding-left: 0;
            }

            .unified-home__search,
            .unified-home__feature-layout,
            .unified-home__story-wrap {
                grid-template-columns: minmax(0, 1fr);
            }

            .unified-home__scene-grid,
            .unified-home__host-grid,
            .unified-home__step-grid,
            .unified-home__track-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 991.98px) {
            .unified-home__lead-card {
                margin-top: 26px;
                min-height: 480px;
            }

            .unified-home__aside-stack {
                grid-template-columns: minmax(0, 1fr);
            }

            .unified-home__feature-stack {
                grid-template-columns: minmax(0, 1fr);
            }

            .unified-home__hero-actions {
                flex-direction: column;
                align-items: stretch;
            }
        }

        @media (max-width: 767.98px) {
            .unified-home__hero {
                padding-top: 138px;
                padding-bottom: 54px;
            }

            .unified-home__section-header,
            .unified-home__lead-footer {
                flex-direction: column;
                align-items: flex-start;
            }

            .unified-home__search,
            .unified-home__scene-grid,
            .unified-home__host-grid,
            .unified-home__step-grid,
            .unified-home__track-grid {
                grid-template-columns: minmax(0, 1fr);
            }

            .unified-home__lead-card,
            .unified-home__feature-card--main,
            .unified-home__scene-card,
            .unified-home__story-card--visual {
                min-height: 380px;
            }

            .unified-home__title {
                font-size: 3.1rem;
            }

            .unified-home__card-title,
            .unified-home__feature-title,
            .unified-home__story-title {
                max-width: none;
            }
        }
    </style>
@endsection

@section('hero-section')
    <div class="unified-home">
        <div class="unified-home__orb unified-home__orb--one"></div>
        <div class="unified-home__orb unified-home__orb--two"></div>
        <div class="unified-home__grid"></div>

        <section class="unified-home__hero">
            <div class="container">
                <div class="row unified-home__hero-stage">
                    <div class="col-xl-7">
                        <div class="unified-home__hero-copy">
                        <span class="unified-home__eyebrow">
                            <span class="unified-home__eyebrow-dot"></span>
                            {{ __('The web sets the scene. The app carries the experience.') }}
                        </span>
                        <h1 class="unified-home__title">
                            {{ __('Discover the scene on web. Unlock the full flow in the app.') }}
                            <span class="unified-home__title-accent">{{ __('Built for fans, organizers, artists and venues.') }}</span>
                        </h1>
                        <p class="unified-home__subtitle">
                            {{ __('Duty web is the public layer: discover events, meet the people behind the scene and understand the product. Duty app is where ticket access, follow signals, reminders and entry are designed to live.') }}
                        </p>

                        <div class="unified-home__hero-actions">
                            <a href="{{ route('frontend.download_app') }}" class="unified-home__hero-action unified-home__hero-action--primary">
                                {{ __('Download the app') }}
                                <i class="fas fa-arrow-right"></i>
                            </a>
                            <a href="{{ route('frontend.for_organizers') }}" class="unified-home__hero-action unified-home__hero-action--ghost">
                                {{ __('For organizers') }}
                            </a>
                            <a href="{{ route('frontend.for_artists') }}" class="unified-home__hero-action unified-home__hero-action--line">
                                {{ __('Artists & DJs') }}
                            </a>
                            <a href="{{ route('frontend.for_venues') }}" class="unified-home__hero-action unified-home__hero-action--line">
                                {{ __('Venues') }}
                            </a>
                        </div>

                        <form class="unified-home__search" action="{{ route('events') }}" method="get">
                            <div class="unified-home__search-group">
                                <i class="fas fa-list"></i>
                                <select name="category" aria-label="{{ __('Browse by category') }}">
                                    <option value="">{{ __('All categories') }}</option>
                                    @foreach ($categories as $category)
                                        <option value="{{ $category->slug }}">{{ $category->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="unified-home__search-group">
                                <i class="fas fa-search"></i>
                                <input type="search" name="search-input" placeholder="{{ __('Search artists, venues, parties or cities') }}">
                            </div>
                            <button type="submit" class="unified-home__search-btn">
                                {{ __('Explore public events') }}
                            </button>
                        </form>

                        <div class="unified-home__metrics">
                            <span class="unified-home__metric"><strong>{{ number_format($socialSnapshot['upcoming_events'] ?? 0) }}</strong> {{ __('upcoming events') }}</span>
                            <span class="unified-home__metric"><strong>{{ number_format($socialSnapshot['categories'] ?? 0) }}</strong> {{ __('featured categories') }}</span>
                            <span class="unified-home__metric"><strong>{{ number_format($socialSnapshot['hosts'] ?? 0) }}</strong> {{ __('hosts in focus') }}</span>
                            <span class="unified-home__metric"><strong>{{ number_format($socialSnapshot['featured_events'] ?? 0) }}</strong> {{ __('editorial picks') }}</span>
                        </div>
                    </div>
                        </div>

                    <div class="col-xl-5">
                        <div class="unified-home__aside" data-aos="fade-left" data-aos-delay="120">
                            <div class="unified-home__lead-card">
                                @if ($leadEvent)
                                    @php
                                        $leadDate = $leadEvent->date_type === 'multiple'
                                            ? strtotime(optional(eventLatestDates($leadEvent->id))->start_date)
                                            : strtotime($leadEvent->start_date);
                                    @endphp
                                    <div class="unified-home__lead-top">
                                        <span class="unified-home__pill">{{ $leadEvent->categoryName ?? __('Featured event') }}</span>
                                        @if (!empty($leadEvent->price_display))
                                            <span class="unified-home__lead-price">{{ $leadEvent->price_display }}</span>
                                        @endif
                                    </div>
                                    <div class="unified-home__lead-bottom">
                                        <h2 class="unified-home__lead-title">{{ \Illuminate\Support\Str::limit($leadEvent->title, 52) }}</h2>
                                        <p class="unified-home__lead-copy">
                                            {{ \Illuminate\Support\Str::limit(strip_tags($leadEvent->description ?? __('A standout event picked from what is live and worth discovering right now.')), 135) }}
                                        </p>
                                        <div class="unified-home__lead-meta">
                                            <div class="unified-home__lead-meta-item">
                                                <i class="far fa-calendar-alt"></i>
                                                <span>{{ $leadDate ? \Carbon\Carbon::parse($leadDate)->translatedFormat('D, M d') : __('Date TBA') }} · {{ $leadEvent->start_time ? \Carbon\Carbon::parse(strtotime($leadEvent->start_time))->translatedFormat('h:i A') : __('Time TBA') }}</span>
                                            </div>
                                            <div class="unified-home__lead-meta-item">
                                                <i class="fas fa-map-marker-alt"></i>
                                                <span>{{ $leadEvent->event_type === 'online' ? __('Online experience') : ($leadEvent->address ?: __('Location to be announced')) }}</span>
>>>>>>> Stashed changes
                                            </div>
                                        </div>
                                        <div class="unified-home__lead-footer">
                                            <div class="unified-home__lead-organizer">
                                                <img class="unified-home__lead-avatar"
                                                    src="{{ $leadOrganizer['photo'] ?? asset('assets/front/images/user.png') }}"
                                                    alt="{{ $leadOrganizer['organizer_name'] ?? ($leadOrganizer['username'] ?? __('Organizer')) }}">
                                                <div>
                                                    <small>{{ __('Hosted by') }}</small>
                                                    <div>{{ $leadOrganizer['organizer_name'] ?? ($leadOrganizer['username'] ?? __('Duty host')) }}</div>
                                                </div>
                                            </div>
                                            <a class="unified-home__lead-button" href="{{ route('event.details', [$leadEvent->slug, $leadEvent->id]) }}">
                                                {{ __('View event page') }}
                                                <i class="fas fa-arrow-right"></i>
                                            </a>
                                        </div>
                                    </div>
                                @else
                                    <div class="unified-home__lead-bottom">
                                        <span class="unified-home__pill">{{ __('App-first landing') }}</span>
                                        <h2 class="unified-home__lead-title">{{ __('The web tells the story. The app holds the ticket.') }}</h2>
                                        <p class="unified-home__lead-copy">{{ __('As more events go live, this spotlight becomes the public bridge that moves visitors into the mobile experience.') }}</p>
                                    </div>
                                @endif
                            </div>

                            <div class="unified-home__aside-stack">
                                <article class="unified-home__bridge-card">
                                    <span class="unified-home__bridge-kicker">{{ __('App access layer') }}</span>
                                    <h3 class="unified-home__bridge-title">{{ __('Tickets live better in the app.') }}</h3>
                                    <p class="unified-home__bridge-copy">{{ __('Use web to discover, then move into mobile for saved tickets, reminders and entry access.') }}</p>
                                    <div class="unified-home__bridge-list">
                                        <span class="unified-home__bridge-item"><i class="fas fa-ticket-alt"></i> {{ __('Saved ticket access') }}</span>
                                        <span class="unified-home__bridge-item"><i class="fas fa-bell"></i> {{ __('Scene reminders') }}</span>
                                        <span class="unified-home__bridge-item"><i class="fas fa-qrcode"></i> {{ __('Entry-ready flow') }}</span>
                                    </div>
                                </article>

                                <article class="unified-home__bridge-card">
                                    <span class="unified-home__bridge-kicker">{{ __('Pro momentum') }}</span>
                                    <h3 class="unified-home__bridge-title">{{ __('The web works as your public storefront.') }}</h3>
                                    <p class="unified-home__bridge-copy">{{ __('Organizers, artists and venues can own presence here while the guest journey continues in the app.') }}</p>
                                    <div class="unified-home__bridge-metrics">
                                        <div class="unified-home__bridge-stat">
                                            <strong>{{ number_format($socialSnapshot['hosts'] ?? 0) }}</strong>
                                            <span>{{ __('hosts') }}</span>
                                        </div>
                                        <div class="unified-home__bridge-stat">
                                            <strong>{{ number_format($socialSnapshot['categories'] ?? 0) }}</strong>
                                            <span>{{ __('categories') }}</span>
                                        </div>
                                    </div>
                                </article>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="unified-home__hero-trackrail">
                    <div class="unified-home__track-grid">
                        @foreach ($proTracks as $track)
                            <article class="unified-home__track-card">
                                <span class="unified-home__track-icon"><i class="{{ $track['icon'] }}"></i></span>
                                <span class="unified-home__track-eyebrow">{{ $track['eyebrow'] }}</span>
                                <h3 class="unified-home__track-title">{{ $track['title'] }}</h3>
                                <p class="unified-home__track-copy">{{ $track['copy'] }}</p>
                                <a href="{{ $track['route'] }}" class="unified-home__track-link">
                                    {{ $track['cta'] }}
                                    <i class="fas fa-arrow-right"></i>
                                </a>
                            </article>
                        @endforeach
                    </div>
                </div>
            </div>
        </section>
@endsection

@section('content')
        <div class="unified-home__shell">
            <div class="container">
                @if ($categorySignals->isNotEmpty())
                    <section class="unified-home__section" data-aos="fade-up">
                        <div class="unified-home__category-row">
                            @foreach ($categorySignals as $category)
                                <a href="{{ route('events', ['category' => $category->slug]) }}" class="unified-home__category-chip">
                                    <i class="{{ $category->icon ?: 'fas fa-bolt' }}"></i>
                                    <span>{{ $category->name }}</span>
                                    <strong>{{ number_format($category->event_count) }}</strong>
                                </a>
                            @endforeach
                        </div>
                    </section>
                @endif

                <section class="unified-home__section" data-aos="fade-up">
                    <div class="unified-home__section-header">
                        <div>
                            <span class="unified-home__section-kicker">{{ __('Your scene') }}</span>
                            <h2 class="unified-home__section-title">{{ __('Public discovery on web. App-first conversion underneath.') }}</h2>
                            <p class="unified-home__section-copy">{{ __('Use the web to understand the scene and the people behind it, then move into the app when you are ready to unlock tickets and access.') }}</p>
                        </div>
                        <a href="{{ route('events') }}" class="unified-home__ghost-link">
                            {{ __('See all events') }}
                            <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>

                    @if ($sceneEvents->isNotEmpty())
                        <div class="unified-home__scene-grid">
                            @foreach ($sceneEvents as $event)
                                @php
                                    $eventOrganizer = $organizerProfileService->organizerPayloadForEvent(
                                        $event->owner_identity_id ?? null,
                                        $event->organizer_id ?? null,
                                        $currentLanguageInfo->id,
                                    );
                                    $sceneDate = $event->date_type === 'multiple'
                                        ? strtotime(optional(eventLatestDates($event->id))->start_date)
                                        : strtotime($event->start_date);
                                @endphp
                                <article class="unified-home__scene-card"
                                    style="background-image: linear-gradient(180deg, rgba(25, 16, 34, 0.08), rgba(25, 16, 34, 0.92)), url('{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}');">
                                    <span class="unified-home__pill">{{ $event->categoryName ?? __('For you') }}</span>
                                    <h3 class="unified-home__card-title">{{ \Illuminate\Support\Str::limit($event->title, 46) }}</h3>
                                    <p class="unified-home__card-copy">{{ \Illuminate\Support\Str::limit(strip_tags($event->description ?? __('Hand-picked from what is active in your orbit.')), 110) }}</p>
                                    <div class="unified-home__card-meta">
                                        <span><i class="far fa-calendar-alt"></i> {{ $sceneDate ? \Carbon\Carbon::parse($sceneDate)->translatedFormat('D, M d') : __('Date TBA') }}</span>
                                        <span><i class="fas fa-map-marker-alt"></i> {{ $event->event_type === 'online' ? __('Online experience') : ($event->address ?: __('Venue TBA')) }}</span>
                                        <span><i class="far fa-user-circle"></i> {{ $eventOrganizer['organizer_name'] ?? ($eventOrganizer['username'] ?? __('Duty host')) }}</span>
                                    </div>
                                    <a href="{{ route('event.details', [$event->slug, $event->id]) }}" class="unified-home__card-action">
                                        {{ __('View event page') }}
                                        <i class="fas fa-arrow-right"></i>
                                    </a>
                                </article>
                            @endforeach
                        </div>
                    @else
                        <div class="unified-home__empty">{{ __('As soon as your scene fills up, this rail will surface the strongest social and editorial picks.') }}</div>
                    @endif
                </section>

                @if ($secInfo->featured_section_status == 1)
                    <section class="unified-home__section" data-aos="fade-up">
                        <div class="unified-home__section-header">
                            <div>
                                <span class="unified-home__section-kicker">{{ __('Editorial picks') }}</span>
                                <h2 class="unified-home__section-title">{{ $secTitleInfo ? $secTitleInfo->event_section_title : __('Featured Events') }}</h2>
                                <p class="unified-home__section-copy">{{ __('Featured events should persuade on the web and then hand off naturally into the mobile product, not force the whole experience into a browser.') }}</p>
                            </div>
                        </div>

                        @if ($featuredEvents->isNotEmpty())
                            <div class="unified-home__feature-layout">
                                <div class="unified-home__feature-main">
                                    @php
                                        $featuredLead = $featuredEvents->first();
                                        $featuredLeadOrganizer = $featuredLead
                                            ? $organizerProfileService->organizerPayloadForEvent(
                                                $featuredLead->owner_identity_id ?? null,
                                                $featuredLead->organizer_id ?? null,
                                                $currentLanguageInfo->id,
                                            )
                                            : null;
                                        $featuredLeadDate = $featuredLead && $featuredLead->date_type === 'multiple'
                                            ? strtotime(optional(eventLatestDates($featuredLead->id))->start_date)
                                            : ($featuredLead ? strtotime($featuredLead->start_date) : null);
                                    @endphp
                                    @if ($featuredLead)
                                        <article class="unified-home__feature-card unified-home__feature-card--main"
                                            style="background-image: linear-gradient(180deg, rgba(17, 11, 25, 0.08), rgba(17, 11, 25, 0.92)), url('{{ asset('assets/admin/img/event/thumbnail/' . $featuredLead->thumbnail) }}');">
                                            <span class="unified-home__pill">{{ $featuredLead->categoryName ?? __('Featured') }}</span>
                                            <h3 class="unified-home__feature-title">{{ \Illuminate\Support\Str::limit($featuredLead->title, 58) }}</h3>
                                            <p class="unified-home__card-copy">{{ \Illuminate\Support\Str::limit(strip_tags($featuredLead->description ?? __('A headline experience worth front-page placement.')), 160) }}</p>
                                            <div class="unified-home__feature-footer">
                                                <div>
                                                    <div class="unified-home__card-meta">
                                                        <span><i class="far fa-calendar-alt"></i> {{ $featuredLeadDate ? \Carbon\Carbon::parse($featuredLeadDate)->translatedFormat('D, M d') : __('Date TBA') }}</span>
                                                        <span><i class="far fa-user-circle"></i> {{ $featuredLeadOrganizer['organizer_name'] ?? ($featuredLeadOrganizer['username'] ?? __('Duty host')) }}</span>
                                                    </div>
                                                </div>
                                                @if (!empty($featuredLead->price_display))
                                                    <span class="unified-home__feature-price">{{ $featuredLead->price_display }}</span>
                                                @endif
                                            </div>
                                            <a href="{{ route('event.details', [$featuredLead->slug, $featuredLead->id]) }}" class="unified-home__card-action">
                                                {{ __('See event page') }}
                                                <i class="fas fa-arrow-right"></i>
                                            </a>
                                        </article>
                                    @endif
                                </div>
                                <div class="unified-home__feature-stack">
                                    @foreach ($featuredEvents->slice(1, 4) as $event)
                                        @php
                                            $eventDate = $event->date_type === 'multiple'
                                                ? strtotime(optional(eventLatestDates($event->id))->start_date)
                                                : strtotime($event->start_date);
                                        @endphp
                                        <article class="unified-home__feature-card unified-home__feature-card--compact"
                                            style="background-image: linear-gradient(180deg, rgba(17, 11, 25, 0.08), rgba(17, 11, 25, 0.92)), url('{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}');">
                                            <span class="unified-home__pill">{{ $event->categoryName ?? __('Featured') }}</span>
                                            <h3 class="unified-home__feature-title">{{ \Illuminate\Support\Str::limit($event->title, 42) }}</h3>
                                            <div class="unified-home__feature-footer">
                                                <span class="unified-home__card-meta">{{ $eventDate ? \Carbon\Carbon::parse($eventDate)->translatedFormat('M d') : __('TBA') }}</span>
                                                @if (!empty($event->price_display))
                                                    <span class="unified-home__feature-price">{{ $event->price_display }}</span>
                                                @endif
                                            </div>
                                            <a href="{{ route('event.details', [$event->slug, $event->id]) }}" class="unified-home__card-action">
                                                {{ __('View') }}
                                                <i class="fas fa-arrow-right"></i>
                                            </a>
                                        </article>
                                    @endforeach
                                </div>
                            </div>
<<<<<<< Updated upstream
                        @endforeach
                    </div>
                @endif

            </div>
            @if (!empty(showAd(3)))
                <div class="text-center mt-4">
                    {!! showAd(3) !!}
                </div>
            @endif
        </section>
    @endif
    <!-- Events Section End -->

    <!-- Category Section Start -->
    @if ($secInfo->categories_section_status == 1)
        <section class="category-section pt-110 rpt-90 pb-80 rpb-60">
            <div class="container">
                <div class="section-title mb-60">
                    <h2>{{ $secTitleInfo ? $secTitleInfo->category_section_title : __('Categories') }}</h2>
                </div>
                <div class="category-wrap text-white">
                    @if (count($eventCategories) > 0)
                        @foreach ($eventCategories as $item)
                            <a href="{{ route('events', ['category' => $item->slug]) }}" class="category-item">
                                <img class="lazy"
                                    data-src="{{ asset('assets/admin/img/event-category/' . $item->image) }}"
                                    alt="Category">
                                <div class="category-content">
                                    <h5>{{ $item->name }}</h5>
                                </div>
                            </a>
                        @endforeach
                    @else
                        <h3 class="text-dark">{{ __('No Category Found') }}</h3>
                    @endif


                </div>
            </div>
        </section>
    @endif
    <!-- Category Section End -->

    <!-- About Section Start -->
    @if ($secInfo->about_section_status == 1)
        <section class="about-section pb-120 rpb-95">
            <div class="container">
                @if (is_null($aboutUsSection))
                    <h2 class="text-center">{{ __('No data found for about section') }}</h2>
                @endif
                <div class="row align-items-center">
                    <div class="col-lg-6">
                        <div class="about-image-part pt-10 rmb-55">
                            @if (!is_null($aboutUsSection))
                                <img class="lazy"
                                    data-src="{{ asset('assets/admin/img/about-us-section/' . $aboutUsSection->image) }}"
                                    alt="About">
                            @endif
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="about-content">
                            <div class="section-title mb-30">
                                <h2>{{ $aboutUsSection ? $aboutUsSection->title : '' }}</h2>
                            </div>
                            <p>{{ $aboutUsSection ? $aboutUsSection->subtitle : '' }}</p>
                            <div>
                                {!! $aboutUsSection ? $aboutUsSection->text : '' !!}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    @endif
    <!-- About Section End -->


    <!-- Feature Section Start -->
    <section class="feature-section pt-110 rpt-90 bg-lighter">
        @if ($secInfo->features_section_status == 1)
            <div class="container pb-90 rpb-70">
                <div class="section-title text-center mb-55">
                    <h2>{{ $featureEventSection ? $featureEventSection->title : '' }}</h2>
                    <p>{{ $featureEventSection ? $featureEventSection->text : '' }}</p>
                    @if (count($featureEventItems) < 1)
                        <h2>{{ __('No data found for features section') }}</h2>
                    @endif
                </div>
                <div class="row justify-content-center">
                    @foreach ($featureEventItems as $item)
                        <div class="col-xl-4 col-md-6">
                            <div class="feature-item">
                                <i class="{{ $item->icon }}"></i>
                                <div class="feature-content">
                                    <h5>{{ $item->title }}</h5>
                                    <p>{{ $item->text }}</p>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>

            </div>
        @endif
        @if ($secInfo->how_work_section_status == 1)
            @if ($howWork)
                <div class="work-process text-center">
                    <div class="container">
                        <div class="work-process-inner pt-110 rpt-90 pb-80 rpb-60">

                            <div class="section-title mb-60">
                                <h2>{{ $howWork->title }}</h2>
                                <p>{{ $howWork->text }}</p>
                            </div>
                            <div class="row justify-content-center">
                                @foreach ($howWorkItems as $item)
                                    <div class="col-xl-3 col-md-6">
                                        <div class="work-process-item">
                                            <div class="icon">
                                                <span class="number">{{ $item->serial_number }}</span>
                                                <i class="{{ $item->icon }}"></i>
                                            </div>
                                            <div class="content">
                                                <h4>{{ $item->title }}</h4>
                                                <p>{{ $item->text }}</p>
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                </div>
            @else
                <div class="work-process text-center">
                    <div class="container">
                        <h2>{{ __('No Data Found for how work section') }}</h2>
                    </div>
                </div>
            @endif
        @endif
    </section>
    <!-- Feature Section End -->


    <!-- Testimonial Section Start -->
    @if ($secInfo->testimonials_section_status == 1)
        <section class="testimonial-section pt-120 rpt-80">
            <div class="container">
                <div class="row pb-75 rpb-55">
                    <div class="col-lg-4">
                        <div class="testimonial-content pt-10 rmb-55">
                            <div class="section-title mb-30">
                                <h2>{{ $testimonialData ? $testimonialData->title : __('What say our client about us') }}
                                </h2>
                            </div>
                            <p>{{ $testimonialData ? $testimonialData->text : '' }}</p>
                            <div class="total-client-reviews mt-40 bg-lighter">
                                <div class="review-images mb-30">
                                    @if (!is_null($testimonialData))
                                        <img class="lazy"
                                            data-src="{{ asset('assets/admin/img/testimonial/' . $testimonialData->image) }}"
                                            alt="Reviewer">
                                    @else
                                        <img class="lazy"
                                            data-src="{{ asset('assets/admin/img/testimonial/clients.png') }}"
                                            alt="Reviewer">
                                    @endif
                                    <span class="pluse"><i class="fas fa-plus"></i></span>
                                </div>
                                <h6>{{ $testimonialData ? $testimonialData->review_text : __('0 Clients Reviews') }}</h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="testimonial-wrap">
                            @if (count($testimonials) > 0)
                                <div class="row">
                                    @foreach ($testimonials as $item)
                                        <div class="col-md-6">
                                            <div class="testimonial-item">
                                                <div class="author">
                                                    <img class="lazy"
                                                        data-src="{{ asset('assets/admin/img/clients/' . $item->image) }}"
                                                        alt="Author">
                                                    <div class="content">
                                                        <h5>{{ $item->name }}</h5>
                                                        <span>{{ $item->occupation }}</span>
                                                        <div class="ratting">
                                                            @for ($i = 1; $i <= $item->rating; $i++)
                                                                <i class="fas fa-star"></i>
                                                            @endfor
                                                        </div>
                                                    </div>
                                                </div>
                                                <p>{{ $item->comment }}</p>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            @else
                                <h4 class="text-center">{{ __('No Review Found') }}</h4>
                            @endif
                        </div>
                    </div>
                </div>
                <hr>
            </div>

        </section>
    @endif
    <!-- Testimonial Section End -->

    <!-- Client Logo Start -->
    @if ($secInfo->partner_section_status == 1)
        <section class="client-logo-area text-center pt-95 rpt-80 pb-90 rpb-70">
            <div class="container">
                <div class="section-title mb-55">
                    <h2>{{ $partnerInfo ? $partnerInfo->title : __('Our Partner') }}</h2>
                    <p>{{ $partnerInfo ? $partnerInfo->text : '' }}</p>
                </div>
                <div class="client-logo-wrap">
                    @if (count($partners) > 0)
                        @foreach ($partners as $item)
                            <div class="client-logo-item">
                                <a href="{{ $item->url }}" target="_blank"><img class="lazy"
                                        data-src="{{ asset('assets/admin/img/partner/' . $item->image) }}"
                                        alt="Client Logo"></a>
                            </div>
                        @endforeach
                    @else
                        <h5>{{ __('No Partner Found') }}</h5>
                    @endif
                </div>
            </div>
        </section>
    @endif
    <!-- Client Logo End -->
=======
                        @else
                            <div class="unified-home__empty">{{ __('No featured events are live yet.') }}</div>
                        @endif
                    </section>
                @endif

                @if ($hostSpotlights->isNotEmpty())
                    <section class="unified-home__section" data-aos="fade-up">
                        <div class="unified-home__section-header">
                            <div>
                                <span class="unified-home__section-kicker">{{ __('Hosts in focus') }}</span>
                                <h2 class="unified-home__section-title">{{ __('People drive the scene. The web should make that obvious.') }}</h2>
                                <p class="unified-home__section-copy">{{ __('Use these public profiles to give organizers a face, credibility and a reason to be remembered before the app closes the loop.') }}</p>
                            </div>
                        </div>
                        <div class="unified-home__host-grid">
                            @foreach ($hostSpotlights as $host)
                                <article class="unified-home__host-card">
                                    <div>
                                        <div class="unified-home__host-top">
                                            <img class="unified-home__host-avatar"
                                                src="{{ $host['photo'] ?: asset('assets/front/images/user.png') }}"
                                                alt="{{ $host['name'] }}">
                                            <div>
                                                <h3 class="unified-home__host-name">{{ $host['name'] }}</h3>
                                                <div class="unified-home__host-copy">{{ $host['designation'] ?: ($host['city'] ?: __('Event host')) }}</div>
                                            </div>
                                        </div>
                                        <p class="unified-home__host-copy">{{ __('Followers, reviews and active events now surface visually so discovery feels more social and less directory-like.') }}</p>
                                        <div class="unified-home__host-stats">
                                            <span class="unified-home__host-stat">{{ number_format($host['followers_count']) }} {{ __('followers') }}</span>
                                            <span class="unified-home__host-stat">{{ number_format($host['events_count']) }} {{ __('events') }}</span>
                                            <span class="unified-home__host-stat">{{ number_format($host['review_count']) }} {{ __('reviews') }}</span>
                                        </div>
                                    </div>
                                    <a href="{{ $host['route'] }}" class="unified-home__host-link">
                                        {{ __('View profile') }}
                                        <i class="fas fa-arrow-right"></i>
                                    </a>
                                </article>
                            @endforeach
                        </div>
                    </section>
                @endif

                @if ($secInfo->how_work_section_status == 1 && $howWork)
                    <section class="unified-home__section" data-aos="fade-up">
                        <div class="unified-home__section-header">
                            <div>
                                <span class="unified-home__section-kicker">{{ __('How it moves') }}</span>
                                <h2 class="unified-home__section-title">{{ $howWork->title }}</h2>
                                <p class="unified-home__section-copy">{{ $howWork->text }}</p>
                            </div>
                        </div>
                        <div class="unified-home__step-grid">
                            @foreach ($howWorkItems as $item)
                                <article class="unified-home__step-card">
                                    <span class="unified-home__step-number">{{ str_pad($item->serial_number, 2, '0', STR_PAD_LEFT) }}</span>
                                    <h3 class="unified-home__step-title">{{ $item->title }}</h3>
                                    <p class="unified-home__step-copy">{{ $item->text }}</p>
                                </article>
                            @endforeach
                        </div>
                    </section>
                @endif

                @if ($secInfo->about_section_status == 1 && !empty($aboutUsSection))
                    <section class="unified-home__section" data-aos="fade-up">
                        <div class="unified-home__story-wrap">
                            <div class="unified-home__story-card unified-home__story-card--visual"></div>
                            <article class="unified-home__story-card unified-home__story-card--copy">
                                <span class="unified-home__section-kicker">{{ __('Why this direction') }}</span>
                                <h2 class="unified-home__story-title">{{ $aboutUsSection->title }}</h2>
                                @if (!empty($aboutUsSection->subtitle))
                                    <p class="unified-home__story-copy">{{ $aboutUsSection->subtitle }}</p>
                                @endif
                                <div class="unified-home__story-copy">{!! $aboutUsSection->text !!}</div>
                            </article>
                        </div>
                    </section>
                @endif
            </div>
        </div>
    </div>
>>>>>>> Stashed changes
@endsection
