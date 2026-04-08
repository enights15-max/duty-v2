@extends('frontend.layout')

@php
    $profile = $organizerProfile ?? [];
    $displayName = $profile['name'] ?? @$organizer_info->name ?? $organizer->username;
    $displayUsername = $profile['username'] ?? $organizer->username;
    $displayDetails = $profile['details'] ?? @$organizer_info->details ?? $organizer->details;
    $displayDesignation = $profile['designation'] ?? @$organizer_info->designation;
    $displayCity = $profile['city'] ?? @$organizer_info->city;
    $displayState = $profile['state'] ?? @$organizer_info->state;
    $displayCountry = $profile['country'] ?? @$organizer_info->country;
    $displayAddress = $profile['address'] ?? @$organizer_info->address;
    $displayPhone = $profile['phone'] ?? null;
    $displayEmail = $profile['email'] ?? null;
    $profilePhoto = $profile['photo'] ?? asset('assets/front/images/user.png');
    $heroBackdrop = $profilePhoto ?: asset('assets/admin/img/' . $basicInfo->breadcrumb);
    $reviewItems = collect($profile['reviews'] ?? [])->take(3);
    $socialLinks = array_filter([
        'facebook' => $profile['facebook'] ?? $organizer->facebook ?? null,
        'twitter' => $profile['twitter'] ?? $organizer->twitter ?? null,
        'linkedin' => $profile['linkedin'] ?? $organizer->linkedin ?? null,
    ]);
    $eventsByCategory = $events->groupBy('category_slug');
    $contactOrganizerId = $profile['legacy_organizer_id'] ?? null;
    $memberSince = !empty($organizer->created_at) ? \Carbon\Carbon::parse($organizer->created_at)->translatedFormat('M Y') : null;
    $summaryLocation = collect([$displayCity, $displayState, $displayCountry])->filter()->implode(', ');
    $hasContactAction = !empty($profile['supports_contact']) && !empty($contactOrganizerId);
    $hasReviews = !empty($profile['supports_reviews']) && (int) ($profile['review_count'] ?? 0) > 0;
@endphp

@section('pageHeading')
    {{ $displayName }}
@endsection
@section('meta-keywords', $displayName . ', organizer profile, events')
@section('meta-description', $displayDetails ? strip_tags($displayDetails) : $displayName)

@section('hero-section')
<<<<<<< Updated upstream
    <!-- Page Banner Start -->
    <section class="page-banner overlay pt-120 pb-125 rpt-90 rpb-95 lazy"
        data-bg="{{ asset('assets/admin/img/' . $basicInfo->breadcrumb) }}">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <div class="banner-inner banner-author">
                        <div class="author mb-3">
                            <figure class="author-img mb-0">
                                <a href="javaScript:void(0)">
                                    @if ($admin == true)
                                        <img class="rounded-lg lazy"
                                            data-src="{{ asset('assets/admin/img/admins/' . $organizer->image) }}"
                                            alt="Author">
                                    @else
                                        @if ($organizer->photo == null)
                                            <img class="rounded-lg lazy"
                                                data-src="{{ asset('assets/front/images/user.png') }}" alt="image">
                                        @else
                                            <img class="rounded-lg lazy"
                                                data-src="{{ asset('assets/admin/img/organizer-photo/' . $organizer->photo) }}"
                                                alt="image">
                                        @endif
                                    @endif
                                </a>
                            </figure>
                            <div class="author-info">
                                <h3 class="mb-1 text-white">{{ @$organizer_info->name }}</h3>
                                <h6 class="mb-1 text-white">{{ $organizer->username }}</h6>
                                <span>{{ __('Member since') }} {{ date('M Y', strtotime($organizer->created_at)) }}</span>
                            </div>
=======
    <section class="organizer-profile-hero">
        <div class="organizer-profile-hero__backdrop" style="background-image: linear-gradient(135deg, rgba(10, 7, 18, 0.86), rgba(25, 16, 34, 0.94)), url('{{ $heroBackdrop }}');"></div>
        <div class="container organizer-profile-hero__container">
            <div class="organizer-profile-hero__grid">
                <div class="organizer-profile-hero__main">
                    <div class="organizer-profile-hero__eyebrow">{{ __('Organizer profile') }}</div>
                    <h1>{{ $displayName }}</h1>
                    <div class="organizer-profile-hero__identity">
                        <span>@ {{ $displayUsername }}</span>
                        @if ($displayDesignation)
                            <span>{{ $displayDesignation }}</span>
                        @endif
                        @if ($memberSince)
                            <span>{{ __('Member since') }} {{ $memberSince }}</span>
                        @endif
                    </div>
                    @if ($displayDetails)
                        <p class="organizer-profile-hero__summary">
                            {{ mb_strlen(strip_tags($displayDetails)) > 210 ? mb_substr(strip_tags($displayDetails), 0, 210) . '...' : strip_tags($displayDetails) }}
                        </p>
                    @endif

                    <div class="organizer-profile-hero__chips">
                        <span>
                            <i class="fas fa-calendar-alt"></i>
                            {{ (int) ($profile['events_count'] ?? $events->count()) }} {{ __('events') }}
                        </span>
                        <span>
                            <i class="fas fa-users"></i>
                            {{ (int) ($profile['followers_count'] ?? 0) }} {{ __('followers') }}
                        </span>
                        <span>
                            <i class="fas fa-star"></i>
                            {{ $profile['average_rating'] ?? '0.0' }} / 5
                        </span>
                        @if ($summaryLocation)
                            <span>
                                <i class="fas fa-map-pin"></i>
                                {{ $summaryLocation }}
                            </span>
                        @endif
                    </div>

                    <div class="organizer-profile-hero__actions">
                        <a href="#organizer-events" class="theme-btn theme-btn--wide">
                            {{ __('Browse events') }}
                        </a>
                        @if ($hasContactAction)
                            <button type="button" class="theme-btn theme-btn--ghost" data-toggle="modal" data-target="#contactModal">
                                {{ __('Contact host') }}
                            </button>
                        @endif
                    </div>
                </div>

                <aside class="organizer-profile-hero__card">
                    <div class="organizer-profile-hero__photo-wrap">
                        <img src="{{ $profilePhoto }}" alt="{{ $displayName }}">
                    </div>
                    <div class="organizer-profile-hero__card-copy">
                        <p>{{ __('Scene snapshot') }}</p>
                        <h3>{{ __('Hosting experiences with a sharper social layer.') }}</h3>
                    </div>
                    <div class="organizer-profile-hero__stats-grid">
                        <div>
                            <span>{{ __('Upcoming') }}</span>
                            <strong>{{ $events->where('status_class', '!=', 'over')->count() }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Reviews') }}</span>
                            <strong>{{ (int) ($profile['review_count'] ?? 0) }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Followers') }}</span>
                            <strong>{{ (int) ($profile['followers_count'] ?? 0) }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Rating') }}</span>
                            <strong>{{ $profile['average_rating'] ?? '0.0' }}</strong>
>>>>>>> Stashed changes
                        </div>
                    </div>
                    @if (!empty($socialLinks))
                        <div class="organizer-profile-hero__socials">
                            @foreach ($socialLinks as $network => $url)
                                <a href="{{ $url }}" target="_blank" rel="noopener">
                                    <i class="fab fa-{{ $network === 'linkedin' ? 'linkedin-in' : $network }}"></i>
                                </a>
                            @endforeach
                        </div>
                    @endif
                </aside>
            </div>
        </div>
    </section>
@endsection

@section('content')
    <section class="organizer-profile-shell py-120 rpy-100">
        <div class="container">
            <div class="organizer-profile-layout">
                <div class="organizer-profile-main">
                    <div class="organizer-profile-panel organizer-profile-panel--story">
                        <div class="organizer-profile-panel__head">
                            <div>
                                <span class="organizer-panel-kicker">{{ __('Profile story') }}</span>
                                <h2>{{ __('What defines this host') }}</h2>
                            </div>
                        </div>
                        <div class="organizer-profile-story-grid">
                            <article>
                                <h3>{{ __('About') }}</h3>
                                <p>{!! nl2br(e($displayDetails ?: __('This organizer is building their public story.'))) !!}</p>
                            </article>
                            <article>
                                <h3>{{ __('Signals') }}</h3>
                                <ul class="organizer-profile-signal-list">
                                    <li>
                                        <span>{{ __('Followers') }}</span>
                                        <strong>{{ (int) ($profile['followers_count'] ?? 0) }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Published reviews') }}</span>
                                        <strong>{{ (int) ($profile['review_count'] ?? 0) }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Average rating') }}</span>
                                        <strong>{{ $profile['average_rating'] ?? '0.0' }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Visible events') }}</span>
                                        <strong>{{ $events->count() }}</strong>
                                    </li>
                                </ul>
                            </article>
                        </div>
                    </div>
<<<<<<< Updated upstream
                    <div class="tab-content mb-50">
                        <div class="tab-pane fade show active" id="all">
                            <div class="row">
                                @if (count($events) > 0)
                                    @foreach ($events as $event)
                                        @if (!empty($event->information))
                                            <div class="col-md-6">
                                                <div class="event-item">
                                                    <div class="event-image">
                                                        <a
                                                            href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
                                                            <img class="lazy"
                                                                data-src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                                                                alt="Event">
                                                        </a>
                                                    </div>
                                                    <div class="event-content">
                                                        <ul class="time-info" dir="ltr">
                                                            @php
                                                                if ($event->date_type == 'multiple') {
                                                                    $event_date = eventLatestDates($event->id);
                                                                    $date = strtotime(@$event_date->start_date);
                                                                } else {
                                                                    $date = strtotime(@$event->start_date);
                                                                }
                                                            @endphp
                                                            <li>
                                                                <i class="far fa-calendar-alt"></i>
                                                                <span>
                                                                    {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->timezone($websiteInfo->timezone)->translatedFormat('d M') }}
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
                                                                class="organizer">{{ $admin->username }}</a>
                                                        @endif
                                                        <h5>
                                                            <a
                                                                href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
                                                                @if (strlen($event->information->title) > 45)
                                                                    {{ mb_substr($event->information->title, 0, 50) . '....' }}
                                                                @else
                                                                    {{ $event->information->title }}
                                                                @endif
                                                            </a>
                                                        </h5>
                                                        @php
                                                            $desc = strip_tags(@$event->information->description);
                                                        @endphp

                                                        @if (strlen($desc) > 100)
                                                            <p class="event-description">
                                                                {{ mb_substr($desc, 0, 100) . '....' }}</p>
                                                        @else
                                                            <p class="event-description">{{ $desc }}</p>
                                                        @endif
                                                        @php
                                                            $ticket = DB::table('tickets')
                                                                ->where('event_id', $event->id)
                                                                ->first();
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
                                                                        {{ @$event->information->address }}
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

                                                                                @if ($ticket->early_bird_discount == 'enable' && $ticket->early_bird_discount_type == 'fixed')
                                                                                    @php
                                                                                        $calculate_price =
                                                                                            $ticket->price -
                                                                                            $ticket->early_bird_discount_amount;
                                                                                    @endphp
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                    <del>
                                                                                        {{ symbolPrice($ticket->price) }}
                                                                                    </del>
                                                                                @elseif ($ticket->early_bird_discount == 'enable' && $ticket->early_bird_discount_type == 'percentage')
                                                                                    @php
                                                                                        $p_price =
                                                                                            ($ticket->price *
                                                                                                $ticket->early_bird_discount_amount) /
                                                                                            100;
                                                                                        $calculate_price =
                                                                                            $ticket->price - $p_price;
                                                                                    @endphp
                                                                                    {{ symbolPrice($calculate_price) }}
                                                                                    <del>
                                                                                        {{ symbolPrice($ticket->price) }}
                                                                                    </del>
                                                                                @else
                                                                                    @php
                                                                                        $calculate_price =
                                                                                            $ticket->price;
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
                                                                                            return $a['price'] <
                                                                                                $b['price']
                                                                                                ? $a
                                                                                                : $b;
                                                                                        },
                                                                                        array_shift($variation),
                                                                                    );
                                                                                    if (
                                                                                        $v_min_price['slot_enable'] == 1
                                                                                    ) {
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
                                                                                            array_shift(
                                                                                                $slot_variations,
                                                                                            ),
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
                                                                                            @elseif
                                                                                            ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
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
                                                                                        @elseif
                                                                                        ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
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

                    <div class="organizer-profile-panel organizer-profile-panel--events" id="organizer-events">
                        <div class="organizer-profile-panel__head organizer-profile-panel__head--stacked">
                            <div>
                                <span class="organizer-panel-kicker">{{ __('Events') }}</span>
                                <h2>{{ __('Hosted by this organizer') }}</h2>
                            </div>
                            <p>{{ __('Browse the full catalog and move between categories without losing the profile context.') }}</p>
                        </div>

                        <div class="organizer-event-tabs mb-30">
                            <ul class="nav nav-pills">
                                <li class="nav-item">
                                    <button class="nav-link active" type="button" data-toggle="tab" data-target="#organizer-all-events">
                                        {{ __('All') }}
                                        <span>{{ $events->count() }}</span>
                                    </button>
                                </li>
                                @foreach ($categoryTabs as $category)
                                    <li class="nav-item">
                                        <button class="nav-link" type="button" data-toggle="tab" data-target="#organizer-category-{{ $category->slug }}">
                                            {{ $category->name }}
                                            <span>{{ $category->event_count }}</span>
                                        </button>
                                    </li>
                                @endforeach
                            </ul>
                        </div>

                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="organizer-all-events">
                                <div class="row">
                                    @forelse ($events as $event)
                                        <div class="col-xl-6">
                                            <article class="organizer-event-card organizer-event-card--featured">
                                                <div class="organizer-event-card__media">
                                                    <a href="{{ $event->event_url }}">
                                                        <img src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}" alt="{{ $event->information->title }}">
                                                    </a>
                                                    <div class="organizer-event-card__overlay"></div>
                                                    <div class="organizer-event-card__topline">
                                                        <span class="organizer-event-card__status organizer-event-card__status--{{ $event->status_class }}">{{ $event->status_label }}</span>
                                                        <span class="organizer-event-card__price">{{ $event->price_display }}</span>
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                                                    <a href="{{ $checkWishList == false ? route('addto.wishlist', $event->id) : route('remove.wishlist', $event->id) }}"
                                                        class="wishlist-btn {{ $checkWishList == true ? 'bg-success' : '' }}">
                                                        <i
                                                            class="{{ $checkWishList == true ? 'fas ' : 'far ' }} fa-bookmark"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        @endif
                                    @endforeach
                                @else
                                    <div class="col-md-12">
                                        <h5 class="text-center">{{ __('No Event Found') }}</h5>
                                    </div>
                                @endif
                            </div>
                        </div>
                        @foreach ($categories as $category)
                            <div class="tab-pane fade" id="{{ $category->slug }}">
                                <div class="row">
                                    @php
                                        $language_id = $currentLanguageInfo->id;
                                        if (request()->filled('admin') && request()->input('admin') == 'true') {
                                            $c_events = adminCategoryWiseEvents(
                                                $category->id,
                                                $language_id,
                                                $organizer->id,
                                            );
                                        } else {
                                            $c_events = categoryWiseEvents($category->id, $language_id, $organizer->id);
                                        }
                                    @endphp
                                    @if (count($c_events) > 0)
                                        @foreach ($c_events as $event)
                                            @if (!empty($event->information))
                                                <div class="col-md-6">
                                                    <div class="event-item">
                                                        <div class="event-image">
                                                            <a
                                                                href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
                                                                <img class="lazy"
                                                                    data-src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                                                                    alt="Event">
                                                            </a>
                                                        </div>
                                                        <div class="event-content">
                                                            <ul class="time-info" dir="ltr">
                                                                <li>
                                                                    <i class="far fa-calendar-alt"></i>
                                                                    <span>
                                                                        @php
                                                                            $date = strtotime($event->start_date);
                                                                        @endphp
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
                                                                    class="organizer">{{ $admin->username }}</a>
                                                            @endif
                                                            <h5>
                                                                <a
                                                                    href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
                                                                    @if (strlen($event->information->title) > 45)
                                                                        {{ mb_substr($event->information->title, 0, 50) . '....' }}
                                                                    @else
                                                                        {{ $event->information->title }}
                                                                    @endif
                                                                </a>
                                                            </h5>
                                                            @php
                                                                $desc = strip_tags(@$event->information->description);
                                                            @endphp

                                                            @if (strlen($desc) > 100)
                                                                <p class="event-description">
                                                                    {{ mb_substr($desc, 0, 100) . '....' }}</p>
                                                            @else
                                                                <p class="event-description">{{ $desc }}</p>
                                                            @endif
                                                            @php
                                                                $ticket = DB::table('tickets')
                                                                    ->where('event_id', $event->id)
                                                                    ->first();
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
                                                                            {{ @$event->information->address }}
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

                                                                                    @if ($ticket->early_bird_discount == 'enable' && $ticket->early_bird_discount_type == 'fixed')
                                                                                        @php
                                                                                            $calculate_price =
                                                                                                $ticket->price -
                                                                                                $ticket->early_bird_discount_amount;
                                                                                        @endphp
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                        <del>
                                                                                            {{ symbolPrice($ticket->price) }}
                                                                                        </del>
                                                                                        @elseif
                                                                                        ($ticket->early_bird_discount == 'enable' && $ticket->early_bird_discount_type == 'percentage')
                                                                                        @php
                                                                                            $p_price =
                                                                                                ($ticket->price *
                                                                                                    $ticket->early_bird_discount_amount) /
                                                                                                100;
                                                                                            $calculate_price =
                                                                                                $ticket->price -
                                                                                                $p_price;
                                                                                        @endphp
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                        <del>
                                                                                            {{ symbolPrice($ticket->price) }}
                                                                                        </del>
                                                                                    @else
                                                                                        @php
                                                                                            $calculate_price =
                                                                                                $ticket->price;
                                                                                        @endphp
                                                                                        {{ symbolPrice($calculate_price) }}
                                                                                    @endif
                                                                                </span>
                                                                            @else
                                                                                <span
                                                                                    class="price">{{ __('Free') }}</span>
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
                                                                                                return $a['price'] <
                                                                                                    $b['price']
                                                                                                    ? $a
                                                                                                    : $b;
                                                                                            },
                                                                                            array_shift($variation),
                                                                                        );
                                                                                        if (
                                                                                            $v_min_price[
                                                                                                'slot_enable'
                                                                                            ] == 1
                                                                                        ) {
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
                                                                                                array_shift(
                                                                                                    $slot_variations,
                                                                                                ),
                                                                                            );
                                                                                            $price =
                                                                                                $v_slot_min_price[
                                                                                                    'slot_seat_min_price'
                                                                                                ] ?? 0.0;
                                                                                        } else {
                                                                                            $price =
                                                                                                $v_min_price['price'];
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
                                                                                                @elseif
                                                                                                ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                                @php
                                                                                                    $p_price =
                                                                                                        ($price *
                                                                                                            $ticket->early_bird_discount_amount) /
                                                                                                        100;
                                                                                                    $calculate_price =
                                                                                                        $price -
                                                                                                        $p_price;
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
                                                                                            $ticket->normal_ticket_slot_enable ==
                                                                                            1
                                                                                        ) {
                                                                                            $ticketPrice =
                                                                                                $ticket->slot_seat_min_price;
                                                                                        } else {
                                                                                            $ticketPrice =
                                                                                                $ticket->price;
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
                                                                                            @elseif
                                                                                            ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                            @php
                                                                                                $p_price =
                                                                                                    ($ticketPrice *
                                                                                                        $ticket->early_bird_discount_amount) /
                                                                                                    100;
                                                                                                $calculate_price =
                                                                                                    $ticketPrice -
                                                                                                    $p_price;
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
                                                    <a href="{{ $checkWishList ? route('remove.wishlist', $event->id) : route('addto.wishlist', $event->id) }}"
                                                        class="organizer-event-card__bookmark {{ $checkWishList ? 'is-active' : '' }}">
                                                        <i class="{{ $checkWishList ? 'fas' : 'far' }} fa-bookmark"></i>
                                                    </a>
                                                </div>
                                                <div class="organizer-event-card__body">
                                                    <div class="organizer-event-card__eyebrow">
                                                        <span>{{ $event->category_name }}</span>
                                                        <span>{{ $event->date_badge }}</span>
                                                    </div>
                                                    <h3>
                                                        <a href="{{ $event->event_url }}">{{ $event->information->title }}</a>
                                                    </h3>
                                                    <p>{{ $event->short_description }}</p>
                                                    <div class="organizer-event-card__meta-grid">
                                                        <div>
                                                            <span>{{ __('Starts') }}</span>
                                                            <strong>{{ $event->date_full }}</strong>
                                                        </div>
                                                        <div>
                                                            <span>{{ __('Time') }}</span>
                                                            <strong>{{ $event->time_badge }}</strong>
                                                        </div>
                                                        <div>
                                                            <span>{{ __('Location') }}</span>
                                                            <strong>{{ $event->location_badge }}</strong>
                                                        </div>
                                                        <div>
                                                            <span>{{ __('Duration') }}</span>
                                                            <strong>{{ $event->duration_badge }}</strong>
                                                        </div>
                                                    </div>
                                                    <div class="organizer-event-card__footer">
                                                        <div class="organizer-event-card__signals">
                                                            <span>{{ $event->ticket_count }} {{ __('ticket tiers') }}</span>
                                                            @if ($event->lineup_count > 0)
                                                                <span>{{ $event->lineup_count }} {{ __('artists') }}</span>
                                                            @endif
                                                            <span>{{ $event->price_hint }}</span>
                                                        </div>
                                                        <a href="{{ $event->event_url }}" class="organizer-event-card__cta">
                                                            {{ __('Open event') }}
                                                            <i class="fas fa-arrow-right"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    @empty
                                        <div class="col-12">
                                            <div class="organizer-empty-state">
                                                <h3>{{ __('No events found yet') }}</h3>
                                                <p>{{ __('This organizer has not published visible events yet. Check back soon.') }}</p>
                                            </div>
                                        </div>
                                    @endforelse
                                </div>
                            </div>

                            @foreach ($categoryTabs as $category)
                                <div class="tab-pane fade" id="organizer-category-{{ $category->slug }}">
                                    <div class="row">
                                        @forelse ($eventsByCategory->get($category->slug, collect()) as $event)
                                            <div class="col-xl-6">
                                                <article class="organizer-event-card">
                                                    <div class="organizer-event-card__media">
                                                        <a href="{{ $event->event_url }}">
                                                            <img src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}" alt="{{ $event->information->title }}">
                                                        </a>
                                                        <div class="organizer-event-card__overlay"></div>
                                                        <div class="organizer-event-card__topline">
                                                            <span class="organizer-event-card__status organizer-event-card__status--{{ $event->status_class }}">{{ $event->status_label }}</span>
                                                            <span class="organizer-event-card__price">{{ $event->price_display }}</span>
                                                        </div>
                                                    </div>
                                                    <div class="organizer-event-card__body">
                                                        <div class="organizer-event-card__eyebrow">
                                                            <span>{{ $event->category_name }}</span>
                                                            <span>{{ $event->date_badge }}</span>
                                                        </div>
                                                        <h3>
                                                            <a href="{{ $event->event_url }}">{{ $event->information->title }}</a>
                                                        </h3>
                                                        <p>{{ $event->short_description }}</p>
                                                        <div class="organizer-event-card__meta-grid">
                                                            <div>
                                                                <span>{{ __('Starts') }}</span>
                                                                <strong>{{ $event->date_full }}</strong>
                                                            </div>
                                                            <div>
                                                                <span>{{ __('Location') }}</span>
                                                                <strong>{{ $event->location_badge }}</strong>
                                                            </div>
                                                        </div>
                                                        <div class="organizer-event-card__footer">
                                                            <div class="organizer-event-card__signals">
                                                                <span>{{ $event->ticket_count }} {{ __('ticket tiers') }}</span>
                                                                <span>{{ $event->price_hint }}</span>
                                                            </div>
                                                            <a href="{{ $event->event_url }}" class="organizer-event-card__cta">
                                                                {{ __('Open event') }}
                                                                <i class="fas fa-arrow-right"></i>
                                                            </a>
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                                                </div>
                                            @endif
                                        @endforeach
                                    @else
                                        <div class="col-md-12">
                                            <h5 class="text-center">{{ __('No Event Found') }}</h5>
                                        </div>
                                    @endif
                                </div>
                            </div>
                        @endforeach
                    </div>

                    @if (!empty(showAd(3)))
                        <div class="text-center mt-4">
                            {!! showAd(3) !!}
                        </div>
                    @endif
                </div>

                <div class="col-lg-4">
                    <aside class="sidebar-widget-area">
                        <div class="widget widget-author-details border mb-30">
                            <div class="author mb-20">
                                <figure class="author-img">
                                    @if ($admin == true)
                                        <img class="rounded-lg lazy"
                                            data-src="{{ asset('assets/admin/img/admins/' . $organizer->image) }}"
                                            alt="Author">
                                    @else
                                        @if ($organizer->photo == null)
                                            <img class="rounded-lg lazy"
                                                data-src="{{ asset('assets/front/images/user.png') }}" alt="image">
                                        @else
                                            <img class="rounded-lg lazy"
                                                data-src="{{ asset('assets/admin/img/organizer-photo/' . $organizer->photo) }}"
                                                alt="image">
                                        @endif
                                    @endif
                                </figure>
                                <div class="author-info">
                                    <h6 class="mb-1">{{ @$organizer_info->name }}</h6>
                                    <span class="icon-start">{{ $organizer->username }}</span>
                                </div>
                            </div>
                            @if ($admin == true && $organizer_info)
                                @if ($organizer_info->details != null)
                                    <div class="font-sm">
                                        <div class="click-show">
                                            <div class="show-content">
                                                <b>{{ __('About') }} : </b>{{ $organizer_info->details }}
                                            </div>
                                            <div class="read-more-btn">
                                                <span>{{ __('Read more') }}</span>
                                                <span>{{ __('Read less') }}</span>
                                            </div>
                                        </div>
                                    </div>
                                @endif

                            @endif
                            @if (@$organizer_info->details != null)
                                <div class="font-sm">
                                    <div class="click-show">
                                        <div class="show-content">
                                            <b>{{ __('About') }} : </b>{{ @$organizer_info->details }}
                                        </div>
                                        <div class="read-more-btn">
                                            <span>{{ __('Read more') }}</span>
                                            <span>{{ __('Read less') }}</span>
                                        </div>
                                    </div>
                                </div>
                            @endif
                            <ul class="toggle-list list-unstyled mt-15 font-sm">
                                <li>
                                    <span class="first">{{ __('Total Events') }}</span>
                                    <span class="last font-sm">
                                        @if ($admin == true)
                                            {{ OrganizerEventCount($organizer->id, true) }}
                                        @else
                                            {{ OrganizerEventCount($organizer->id) }}
                                        @endif
                                    </span>
                                </li>
                                @if ($organizer->email != null)
                                    <li>
                                        <span class="first">{{ __('Email') }}</span>
                                        <span class="last font-sm"><a href="mailto:{{ $organizer->email }}"
                                                title="{{ $organizer->email }}">{{ $organizer->email }}</a></span>
                                    </li>
                                @endif

                                @if ($organizer->phone != null)
                                    <li>
                                        <span class="first">{{ __('Phone') }}</span>
                                        <span class="last font-sm"><a href="tel:{{ $organizer->phone }}"
                                                title="{{ $organizer->phone }}">{{ $organizer->phone }}</a></span>
                                    </li>
                                @endif
                                @if (@$organizer_info->city != null)
                                    <li>
                                        <span class="first">{{ __('City') }}</span>
                                        <span class="last font-sm"><a href="tel:{{ @$organizer_info->city }}"
                                                title="{{ @$organizer_info->city }}">{{ @$organizer_info->city }}</a></span>
                                    </li>
                                @endif

                                @if (@$organizer_info->state != null)
                                    <li>
                                        <span class="first">{{ __('State') }}</span>
                                        <span class="last font-sm"><a href="tel:{{ @$organizer_info->state }}"
                                                title="{{ @$organizer_info->state }}">{{ @$organizer_info->state }}</a></span>
                                    </li>
                                @endif
                                @if (@$organizer_info->country != null)
                                    <li>
                                        <span class="first">{{ __('Country') }}</span>
                                        <span class="last font-sm"><a href="tel:{{ @$organizer_info->country }}"
                                                title="{{ @$organizer_info->country }}">{{ @$organizer_info->country }}</a></span>
                                    </li>
                                @endif

                                @if (@$organizer_info->address != null)
                                    <li>
                                        <span class="first">{{ __('Address') }}</span>
                                        <span class="last font-sm">{{ @$organizer_info->address }}</span>
                                    </li>
                                @endif

                                @if ($admin == true && $organizer->address != null)
                                    <li>
                                        <span class="first">{{ __('Address') }}</span>
                                        <span class="last font-sm">{{ $organizer->address }}</span>
                                    </li>
                                @endif

                            </ul>
                            <div class="btn-groups text-center mt-20">
                                <button type="button" class="theme-btn w-100 mb-10" title="Title" data-toggle="modal"
                                    data-target="#contactModal">{{ __('Contact Now') }}</button>
                            </div>
                        </div>

                        <div class="widget widget-business-days mb-30">
                            @if (!empty(showAd(1)))
                                <div class="text-center mt-4">
                                    {!! showAd(1) !!}
                                </div>
                            @endif
                            @if (!empty(showAd(2)))
                                <div class="text-center mt-4">
                                    {!! showAd(2) !!}
                                </div>
                            @endif
                        </div>
                    </aside>
=======
                                                </article>
                                            </div>
                                        @empty
                                            <div class="col-12">
                                                <div class="organizer-empty-state organizer-empty-state--compact">
                                                    <h3>{{ __('Nothing here yet') }}</h3>
                                                    <p>{{ __('There are no visible events in this category for now.') }}</p>
                                                </div>
                                            </div>
                                        @endforelse
                                    </div>
                                </div>
                            @endforeach
                        </div>

                        @if (!empty(showAd(3)))
                            <div class="organizer-profile-ad organizer-profile-ad--inline">
                                {!! showAd(3) !!}
                            </div>
                        @endif
                    </div>
>>>>>>> Stashed changes
                </div>

                <aside class="organizer-profile-sidebar">
                    <div class="organizer-profile-panel organizer-profile-panel--compact">
                        <div class="organizer-profile-panel__head">
                            <div>
                                <span class="organizer-panel-kicker">{{ __('Direct lines') }}</span>
                                <h2>{{ __('Connect') }}</h2>
                            </div>
                        </div>
                        <ul class="organizer-contact-list">
                            @if ($displayEmail)
                                <li>
                                    <span>{{ __('Email') }}</span>
                                    <a href="mailto:{{ $displayEmail }}">{{ $displayEmail }}</a>
                                </li>
                            @endif
                            @if ($displayPhone)
                                <li>
                                    <span>{{ __('Phone') }}</span>
                                    <a href="tel:{{ $displayPhone }}">{{ $displayPhone }}</a>
                                </li>
                            @endif
                            @if ($summaryLocation)
                                <li>
                                    <span>{{ __('Scene') }}</span>
                                    <strong>{{ $summaryLocation }}</strong>
                                </li>
                            @endif
                            @if ($displayAddress)
                                <li>
                                    <span>{{ __('Address') }}</span>
                                    <strong>{{ $displayAddress }}</strong>
                                </li>
                            @endif
                        </ul>
                        @if ($hasContactAction)
                            <button type="button" class="theme-btn theme-btn--wide mt-20" data-toggle="modal" data-target="#contactModal">
                                {{ __('Contact this organizer') }}
                            </button>
                        @endif
                    </div>

                    @if ($hasReviews)
                        <div class="organizer-profile-panel organizer-profile-panel--compact">
                            <div class="organizer-profile-panel__head">
                                <div>
                                    <span class="organizer-panel-kicker">{{ __('Reviews') }}</span>
                                    <h2>{{ __('Audience notes') }}</h2>
                                </div>
                            </div>
                            <div class="organizer-review-stack">
                                @foreach ($reviewItems as $review)
                                    @php
                                        $customer = $review->customer;
                                        $reviewerName = trim(($customer->fname ?? '') . ' ' . ($customer->lname ?? '')) ?: __('Guest');
                                        $reviewPhoto = !empty($customer->photo)
                                            ? asset('assets/admin/img/customer-profile/' . $customer->photo)
                                            : asset('assets/front/images/user.png');
                                    @endphp
                                    <article class="organizer-review-card">
                                        <div class="organizer-review-card__head">
                                            <img src="{{ $reviewPhoto }}" alt="{{ $reviewerName }}">
                                            <div>
                                                <strong>{{ $reviewerName }}</strong>
                                                <span>
                                                    @for ($i = 0; $i < (int) $review->rating; $i++)
                                                        <i class="fas fa-star"></i>
                                                    @endfor
                                                </span>
                                            </div>
                                        </div>
                                        <p>{{ $review->comment ?: __('No written note, just a rating.') }}</p>
                                    </article>
                                @endforeach
                            </div>
                        </div>
                    @endif

                    @if (!empty($socialLinks))
                        <div class="organizer-profile-panel organizer-profile-panel--compact">
                            <div class="organizer-profile-panel__head">
                                <div>
                                    <span class="organizer-panel-kicker">{{ __('Elsewhere') }}</span>
                                    <h2>{{ __('Follow the signal') }}</h2>
                                </div>
                            </div>
                            <div class="organizer-social-grid">
                                @foreach ($socialLinks as $network => $url)
                                    <a href="{{ $url }}" target="_blank" rel="noopener">
                                        <i class="fab fa-{{ $network === 'linkedin' ? 'linkedin-in' : $network }}"></i>
                                        <span>{{ ucfirst($network) }}</span>
                                    </a>
                                @endforeach
                            </div>
                        </div>
                    @endif

                    @if (!empty(showAd(1)) || !empty(showAd(2)))
                        <div class="organizer-profile-panel organizer-profile-panel--compact organizer-profile-panel--ads">
                            <div class="organizer-profile-panel__head">
                                <div>
                                    <span class="organizer-panel-kicker">{{ __('Partner spots') }}</span>
                                    <h2>{{ __('Recommended placements') }}</h2>
                                </div>
                            </div>
                            @if (!empty(showAd(1)))
                                <div class="organizer-profile-ad">{!! showAd(1) !!}</div>
                            @endif
                            @if (!empty(showAd(2)))
                                <div class="organizer-profile-ad">{!! showAd(2) !!}</div>
                            @endif
                        </div>
                    @endif
                </aside>
            </div>
        </div>
<<<<<<< Updated upstream
    </div>
    <!-- Author-single-area start -->

    <!-- Contact Modal -->
    <div class="contact-modal modal fade" id="contactModal" tabindex="-1" role="dialog"
        aria-labelledby="contactModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="contactModalLabel">{{ __('Contact Now') }}</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="contact-wrapper">
                        <div class="contact-form m-0">
                            <form action="{{ route('organizer.contact.send_mail') }}" method="POST"
                                id="vendorContactForm">
                                @csrf
                                <input type="hidden" name="id" value="{{ $organizer->id }}">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <div class="form_group mb-20">
                                            <input type="text" class="form_control"
                                                placeholder="{{ __('Enter Your Full Name') }}" name="name">
                                            <p class="text-danger em mt_1" id="Error_name"></p>
=======
    </section>

    @if ($hasContactAction)
        <div class="contact-modal modal fade organizer-contact-modal" id="contactModal" tabindex="-1" role="dialog"
            aria-labelledby="contactModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="contactModalLabel">{{ __('Contact host') }}</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="contact-wrapper">
                            <div class="contact-form m-0">
                                <form action="{{ route('organizer.contact.send_mail') }}" method="POST" id="vendorContactForm">
                                    @csrf
                                    <input type="hidden" name="id" value="{{ $contactOrganizerId }}">
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form_group mb-20">
                                                <input type="text" class="form_control" placeholder="{{ __('Enter Your Full Name') }}" name="name">
                                                <p class="text-danger em mt_1" id="Error_name"></p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form_group mb-20">
                                                <input type="email" class="form_control" placeholder="{{ __('Enter Your Email') }}" name="email">
                                                <p class="text-danger em mt_1" id="Error_email"></p>
                                            </div>
                                        </div>
                                        <div class="col-lg-12">
                                            <div class="form_group mb-20">
                                                <input type="text" class="form_control" placeholder="{{ __('Enter Subject') }}" name="subject">
                                                <p class="text-danger em mt_1" id="Error_subject"></p>
                                            </div>
                                        </div>
                                        <div class="col-lg-12">
                                            <div class="form_group mb-20">
                                                <textarea name="message" class="form_control" placeholder="{{ __('Comment') }}"></textarea>
                                                <p class="text-danger em mt_1" id="Error_message"></p>
                                            </div>
                                        </div>
                                        <div class="col-lg-12">
                                            @if ($basicInfos->google_recaptcha_status == 1)
                                                <div class="form_group">
                                                    {!! NoCaptcha::renderJs() !!}
                                                    {!! NoCaptcha::display() !!}
                                                    <p class="text-danger em" id="Error_g-recaptcha-response"></p>
                                                </div>
                                            @endif
                                        </div>
                                        <div class="col-lg-12 text-center">
                                            <button class="theme-btn theme-btn--wide" type="submit">{{ __('Send message') }}</button>
>>>>>>> Stashed changes
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <div class="form_group mb-20">
                                            <input type="email" class="form_control"
                                                placeholder="{{ __('Enter Your Email') }}" name="email">
                                            <p class="text-danger em mt_1" id="Error_email"></p>
                                        </div>
                                    </div>
                                    <div class="col-lg-12">
                                        <div class="form_group mb-20">
                                            <input type="text" class="form_control"
                                                placeholder="{{ __('Enter Subject') }}" name="subject">
                                            <p class="text-danger em mt_1" id="Error_subject"></p>
                                        </div>
                                    </div>
                                    <div class="col-lg-12">
                                        <div class="form_group mb-20">
                                            <textarea name="message" class="form_control" placeholder="{{ __('Comment') }}"></textarea>
                                            <p class="text-danger em mt_1" id="Error_message"></p>
                                        </div>
                                    </div>
                                    <div class="col-lg-12">
                                        @if ($basicInfos->google_recaptcha_status == 1)
                                            <div class="form_group">
                                                {!! NoCaptcha::renderJs() !!}
                                                {!! NoCaptcha::display() !!}

                                                <p class="text-danger em" id="Error_g-recaptcha-response"></p>
                                            </div>
                                        @endif
                                    </div>
                                    <div class="col-lg-12 text-center">
                                        <button class="theme-btn" type="submit"
                                            title="Submit">{{ __('Submit') }}</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
<<<<<<< Updated upstream
    </div>
    <!-- Contact Modal -->
=======
    @endif

    <style>
        .organizer-profile-hero {
            position: relative;
            overflow: hidden;
            padding: 144px 0 88px;
            color: #f8f1ff;
        }

        .organizer-profile-hero__backdrop {
            position: absolute;
            inset: 0;
            background-size: cover;
            background-position: center;
            filter: saturate(1.05);
        }

        .organizer-profile-hero::after {
            content: '';
            position: absolute;
            inset: auto 0 0;
            height: 220px;
            background: linear-gradient(180deg, rgba(18, 10, 28, 0) 0%, rgba(18, 10, 28, 0.92) 78%, rgba(18, 10, 28, 1) 100%);
        }

        .organizer-profile-hero__container {
            position: relative;
            z-index: 1;
        }

        .organizer-profile-hero__grid {
            display: grid;
            grid-template-columns: minmax(0, 1.6fr) minmax(320px, 0.95fr);
            gap: 28px;
            align-items: stretch;
        }

        .organizer-profile-hero__main,
        .organizer-profile-hero__card,
        .organizer-profile-panel,
        .organizer-event-card,
        .organizer-empty-state,
        .organizer-contact-modal .modal-content {
            background: linear-gradient(180deg, rgba(45, 31, 61, 0.84), rgba(24, 16, 35, 0.94));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 24px 60px rgba(8, 4, 14, 0.32);
            backdrop-filter: blur(18px);
        }

        .organizer-profile-hero__main {
            border-radius: 34px;
            padding: 36px 38px;
        }

        .organizer-profile-hero__card {
            border-radius: 34px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            gap: 22px;
        }

        .organizer-profile-hero__eyebrow,
        .organizer-panel-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.82rem;
            letter-spacing: 0.24em;
            text-transform: uppercase;
            color: rgba(236, 220, 255, 0.68);
            margin-bottom: 14px;
        }

        .organizer-profile-hero h1,
        .organizer-profile-panel__head h2,
        .organizer-profile-story-grid h3,
        .organizer-event-card h3 {
            font-family: 'Outfit', sans-serif;
        }

        .organizer-profile-hero h1 {
            margin: 0;
            font-size: clamp(2.6rem, 4vw, 4.3rem);
            line-height: 0.96;
            max-width: 11ch;
        }

        .organizer-profile-hero__identity,
        .organizer-profile-hero__chips,
        .organizer-profile-hero__actions,
        .organizer-profile-hero__stats-grid,
        .organizer-profile-hero__socials,
        .organizer-profile-layout,
        .organizer-profile-story-grid,
        .organizer-contact-list,
        .organizer-social-grid,
        .organizer-event-card__eyebrow,
        .organizer-event-card__meta-grid,
        .organizer-event-card__footer,
        .organizer-event-card__signals,
        .organizer-review-card__head {
            display: flex;
            flex-wrap: wrap;
        }

        .organizer-profile-hero__identity {
            gap: 12px;
            margin-top: 18px;
        }

        .organizer-profile-hero__identity span,
        .organizer-profile-hero__chips span {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.06);
            color: rgba(247, 240, 255, 0.82);
            font-size: 0.95rem;
        }

        .organizer-profile-hero__summary {
            margin: 22px 0 0;
            max-width: 62ch;
            color: rgba(243, 236, 251, 0.8);
            font-size: 1.02rem;
            line-height: 1.75;
        }

        .organizer-profile-hero__chips {
            gap: 12px;
            margin-top: 24px;
        }

        .organizer-profile-hero__actions {
            gap: 14px;
            margin-top: 30px;
        }

        .theme-btn--wide {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            min-width: 180px;
        }

        .theme-btn--ghost {
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #f8f1ff;
            box-shadow: none;
        }

        .theme-btn--ghost:hover {
            color: #fff;
            border-color: rgba(255, 255, 255, 0.18);
            transform: translateY(-2px);
        }

        .organizer-profile-hero__photo-wrap {
            position: relative;
            overflow: hidden;
            border-radius: 26px;
            aspect-ratio: 1 / 1.03;
            background: rgba(255, 255, 255, 0.05);
        }

        .organizer-profile-hero__photo-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .organizer-profile-hero__card-copy p,
        .organizer-profile-panel__head--stacked p,
        .organizer-event-card p,
        .organizer-review-card p,
        .organizer-empty-state p,
        .organizer-profile-story-grid p,
        .organizer-contact-list strong,
        .organizer-contact-list a {
            color: rgba(236, 229, 244, 0.76);
        }

        .organizer-profile-hero__card-copy h3 {
            margin: 8px 0 0;
            font-size: 1.32rem;
            color: #fff;
        }

        .organizer-profile-hero__stats-grid {
            gap: 12px;
        }

        .organizer-profile-hero__stats-grid > div {
            flex: 1 1 calc(50% - 12px);
            min-width: 120px;
            padding: 16px 18px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.05);
        }

        .organizer-profile-hero__stats-grid span,
        .organizer-event-card__meta-grid span,
        .organizer-contact-list span,
        .organizer-profile-signal-list span {
            display: block;
            color: rgba(224, 210, 238, 0.62);
            font-size: 0.8rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .organizer-profile-hero__stats-grid strong,
        .organizer-event-card__meta-grid strong,
        .organizer-contact-list strong,
        .organizer-profile-signal-list strong {
            display: block;
            margin-top: 5px;
            color: #fff;
            font-size: 1.05rem;
            font-weight: 700;
        }

        .organizer-profile-hero__socials {
            gap: 12px;
        }

        .organizer-profile-hero__socials a,
        .organizer-social-grid a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.06);
            color: #f4e9ff;
            transition: transform 0.2s ease, background 0.2s ease;
        }

        .organizer-profile-hero__socials a:hover,
        .organizer-social-grid a:hover {
            transform: translateY(-3px);
            background: rgba(140, 37, 244, 0.28);
        }

        .organizer-profile-shell {
            position: relative;
            background: radial-gradient(circle at top, rgba(140, 37, 244, 0.08), transparent 28%), #120a1c;
        }

        .organizer-profile-layout {
            gap: 28px;
            align-items: start;
        }

        .organizer-profile-main {
            flex: 1 1 0;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 28px;
        }

        .organizer-profile-sidebar {
            width: 350px;
            display: flex;
            flex-direction: column;
            gap: 24px;
            position: sticky;
            top: 112px;
        }

        .organizer-profile-panel {
            border-radius: 30px;
            padding: 28px;
        }

        .organizer-profile-panel--compact {
            padding: 24px;
        }

        .organizer-profile-panel__head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
        }

        .organizer-profile-panel__head--stacked {
            align-items: flex-end;
        }

        .organizer-profile-panel__head h2 {
            margin: 0;
            color: #fff;
            font-size: 1.75rem;
        }

        .organizer-profile-story-grid {
            gap: 18px;
        }

        .organizer-profile-story-grid article {
            flex: 1 1 260px;
            padding: 22px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .organizer-profile-story-grid h3 {
            margin-bottom: 14px;
            color: #fff;
            font-size: 1.15rem;
        }

        .organizer-profile-story-grid p {
            margin: 0;
            line-height: 1.8;
        }

        .organizer-profile-signal-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .organizer-profile-signal-list li,
        .organizer-contact-list li {
            list-style: none;
        }

        .organizer-event-tabs .nav {
            gap: 10px;
            border: none;
        }

        .organizer-event-tabs .nav-link {
            border: 0;
            border-radius: 999px;
            padding: 12px 18px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: rgba(255, 255, 255, 0.05);
            color: rgba(240, 232, 248, 0.78);
        }

        .organizer-event-tabs .nav-link span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 30px;
            height: 30px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            font-size: 0.8rem;
        }

        .organizer-event-tabs .nav-link.active {
            background: linear-gradient(135deg, rgba(140, 37, 244, 0.92), rgba(178, 104, 255, 0.88));
            color: #fff;
            box-shadow: 0 16px 34px rgba(109, 23, 190, 0.34);
        }

        .organizer-event-card {
            border-radius: 28px;
            overflow: hidden;
            margin-bottom: 24px;
        }

        .organizer-event-card__media {
            position: relative;
            aspect-ratio: 16 / 10;
            overflow: hidden;
        }

        .organizer-event-card__media img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .organizer-event-card:hover .organizer-event-card__media img {
            transform: scale(1.04);
        }

        .organizer-event-card__overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(11, 7, 18, 0.08), rgba(11, 7, 18, 0.68));
        }

        .organizer-event-card__topline {
            position: absolute;
            top: 18px;
            left: 18px;
            right: 18px;
            z-index: 1;
            display: flex;
            justify-content: space-between;
            gap: 12px;
        }

        .organizer-event-card__status,
        .organizer-event-card__price,
        .organizer-event-card__bookmark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            backdrop-filter: blur(14px);
        }

        .organizer-event-card__status,
        .organizer-event-card__price {
            padding: 9px 14px;
            background: rgba(255, 255, 255, 0.12);
            color: #fff;
            font-size: 0.84rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        .organizer-event-card__status--upcoming {
            background: rgba(58, 175, 111, 0.28);
        }

        .organizer-event-card__status--live {
            background: rgba(255, 133, 60, 0.28);
        }

        .organizer-event-card__status--over {
            background: rgba(255, 255, 255, 0.1);
            color: rgba(235, 227, 244, 0.78);
        }

        .organizer-event-card__bookmark {
            position: absolute;
            top: 18px;
            right: 18px;
            z-index: 1;
            width: 44px;
            height: 44px;
            background: rgba(16, 11, 24, 0.54);
            color: #fff;
        }

        .organizer-event-card__bookmark.is-active {
            background: rgba(58, 175, 111, 0.8);
        }

        .organizer-event-card__body {
            padding: 24px;
        }

        .organizer-event-card__eyebrow {
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
            color: rgba(231, 217, 244, 0.72);
            font-size: 0.84rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .organizer-event-card h3 {
            margin: 0;
            font-size: 1.35rem;
            line-height: 1.18;
        }

        .organizer-event-card h3 a {
            color: #fff;
        }

        .organizer-event-card p {
            margin: 14px 0 0;
            line-height: 1.75;
        }

        .organizer-event-card__meta-grid {
            gap: 14px;
            margin-top: 20px;
        }

        .organizer-event-card__meta-grid > div {
            flex: 1 1 calc(50% - 14px);
            min-width: 180px;
            padding: 14px 16px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .organizer-event-card__footer {
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-top: 22px;
        }

        .organizer-event-card__signals {
            gap: 10px;
        }

        .organizer-event-card__signals span {
            padding: 9px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.05);
            color: rgba(235, 227, 244, 0.72);
            font-size: 0.82rem;
        }

        .organizer-event-card__cta {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            color: #fff;
            font-weight: 700;
        }

        .organizer-empty-state {
            border-radius: 28px;
            padding: 52px 28px;
            text-align: center;
        }

        .organizer-empty-state h3 {
            color: #fff;
            margin-bottom: 10px;
        }

        .organizer-empty-state--compact {
            padding: 36px 24px;
        }

        .organizer-contact-list {
            flex-direction: column;
            gap: 16px;
            margin: 0;
            padding: 0;
        }

        .organizer-contact-list a {
            word-break: break-word;
        }

        .organizer-review-stack {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .organizer-review-card {
            padding: 18px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .organizer-review-card__head {
            gap: 14px;
            align-items: center;
            margin-bottom: 12px;
        }

        .organizer-review-card__head img {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            object-fit: cover;
        }

        .organizer-review-card__head strong {
            display: block;
            color: #fff;
        }

        .organizer-review-card__head span {
            color: #ffc85b;
            font-size: 0.84rem;
        }

        .organizer-social-grid {
            gap: 12px;
        }

        .organizer-social-grid a {
            width: auto;
            min-width: calc(50% - 12px);
            justify-content: flex-start;
            gap: 10px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 600;
        }

        .organizer-profile-ad {
            border-radius: 22px;
            overflow: hidden;
        }

        .organizer-profile-ad--inline {
            margin-top: 24px;
        }

        .organizer-contact-modal .modal-dialog {
            max-width: 720px;
        }

        .organizer-contact-modal .modal-content {
            border-radius: 28px;
            color: #fff;
        }

        .organizer-contact-modal .modal-header,
        .organizer-contact-modal .modal-body {
            border: 0;
        }

        .organizer-contact-modal .modal-title {
            font-family: 'Outfit', sans-serif;
            font-size: 1.45rem;
        }

        .organizer-contact-modal .close {
            color: #fff;
            opacity: 0.78;
        }

        .organizer-contact-modal .form_control {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: #fff;
            border-radius: 18px;
        }

        .organizer-contact-modal .form_control::placeholder {
            color: rgba(236, 229, 244, 0.48);
        }

        @media (max-width: 1199px) {
            .organizer-profile-layout {
                flex-direction: column;
            }

            .organizer-profile-sidebar {
                width: 100%;
                position: static;
            }
        }

        @media (max-width: 991px) {
            .organizer-profile-hero {
                padding: 124px 0 70px;
            }

            .organizer-profile-hero__grid {
                grid-template-columns: 1fr;
            }

            .organizer-profile-panel__head--stacked {
                align-items: flex-start;
            }
        }

        @media (max-width: 767px) {
            .organizer-profile-hero__main,
            .organizer-profile-hero__card,
            .organizer-profile-panel {
                padding: 22px;
                border-radius: 24px;
            }

            .organizer-profile-hero h1 {
                max-width: none;
                font-size: 2.5rem;
            }

            .organizer-profile-signal-list,
            .organizer-event-card__meta-grid {
                grid-template-columns: 1fr;
            }

            .organizer-social-grid a,
            .organizer-event-card__meta-grid > div {
                min-width: 100%;
            }

            .organizer-event-card__footer {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
>>>>>>> Stashed changes
@endsection
