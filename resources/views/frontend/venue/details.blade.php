@extends('frontend.layout')

@php
    $profile = $venueProfile ?? [];
    $displayName = $venue->name;
    $displayUsername = $venue->username;
    $displayDetails = $venue->details;
    $venueImage = $venue->photo_url ?: asset('assets/front/images/user.png');
    $heroBackdrop = $venueImage;
    $socialLinks = array_filter([
        'facebook' => $venue->facebook,
        'twitter' => $venue->twitter,
        'linkedin' => $venue->linkedin,
    ]);
    $memberSince = !empty($venue->created_at) ? \Carbon\Carbon::parse($venue->created_at)->translatedFormat('M Y') : null;
    $upcomingCount = $upcomingEvents->count();
    $pastCount = $pastEvents->count();
    $totalCount = $events->count();
@endphp

@section('pageHeading')
    {{ $displayName }}
@endsection
@section('meta-keywords', $displayName . ', venue profile, events')
@section('meta-description', $displayDetails ? strip_tags($displayDetails) : $displayName)

@section('hero-section')
    <section class="venue-profile-hero">
        <div class="venue-profile-hero__backdrop" style="background-image: linear-gradient(125deg, rgba(9, 12, 19, 0.84), rgba(22, 30, 48, 0.92)), url('{{ $heroBackdrop }}');"></div>
        <div class="container venue-profile-hero__container">
            <div class="venue-profile-hero__grid">
                <div class="venue-profile-hero__main">
                    <div class="venue-profile-hero__eyebrow">{{ __('Venue profile') }}</div>
                    <h1>{{ $displayName }}</h1>
                    <div class="venue-profile-hero__identity">
                        @if ($displayUsername)
                            <span>@ {{ $displayUsername }}</span>
                        @endif
                        @if ($memberSince)
                            <span>{{ __('Member since') }} {{ $memberSince }}</span>
                        @endif
                        @if ($locationSummary)
                            <span>{{ $locationSummary }}</span>
                        @endif
                    </div>
                    @if ($displayDetails)
                        <p class="venue-profile-hero__summary">
                            {{ mb_strlen(strip_tags($displayDetails)) > 210 ? mb_substr(strip_tags($displayDetails), 0, 210) . '...' : strip_tags($displayDetails) }}
                        </p>
                    @endif
                    <div class="venue-profile-hero__chips">
                        <span>
                            <i class="fas fa-calendar-alt"></i>
                            {{ $upcomingCount }} {{ __('upcoming') }}
                        </span>
                        <span>
                            <i class="fas fa-users"></i>
                            {{ $venue->followers_count }} {{ __('followers') }}
                        </span>
                        <span>
                            <i class="fas fa-star"></i>
                            {{ $venue->average_rating }} / 5
                        </span>
                        <span>
                            <i class="fas fa-archway"></i>
                            {{ $totalCount }} {{ __('events hosted') }}
                        </span>
                    </div>
                    <div class="venue-profile-hero__actions">
                        <a href="#venue-calendar" class="theme-btn theme-btn--wide">{{ __('Explore calendar') }}</a>
                        @if ($mapsUrl)
                            <a href="{{ $mapsUrl }}" target="_blank" rel="noopener" class="theme-btn theme-btn--ghost">{{ __('Open in maps') }}</a>
                        @endif
                    </div>
                </div>

                <aside class="venue-profile-hero__card">
                    <div class="venue-profile-hero__photo-wrap">
                        <img src="{{ $venueImage }}" alt="{{ $displayName }}">
                    </div>
                    <div class="venue-profile-hero__card-copy">
                        <p>{{ __('Place snapshot') }}</p>
                        <h3>{{ __('A venue page that feels closer to the scene than to a directory listing.') }}</h3>
                    </div>
                    <div class="venue-profile-hero__stats-grid">
                        <div>
                            <span>{{ __('Upcoming') }}</span>
                            <strong>{{ $upcomingCount }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Past') }}</span>
                            <strong>{{ $pastCount }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Reviews') }}</span>
                            <strong>{{ $venue->review_count }}</strong>
                        </div>
                        <div>
                            <span>{{ __('Rating') }}</span>
                            <strong>{{ $venue->average_rating }}</strong>
                        </div>
                    </div>
                    @if (!empty($socialLinks))
                        <div class="venue-profile-hero__socials">
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
    <section class="venue-profile-shell py-120 rpy-100">
        <div class="container">
            <div class="venue-profile-layout">
                <div class="venue-profile-main">
                    <div class="venue-profile-panel venue-profile-panel--story">
                        <div class="venue-profile-panel__head">
                            <div>
                                <span class="venue-panel-kicker">{{ __('Place story') }}</span>
                                <h2>{{ __('What this venue brings to the scene') }}</h2>
                            </div>
                        </div>
                        <div class="venue-profile-story-grid">
                            <article>
                                <h3>{{ __('About the space') }}</h3>
                                <p>{!! nl2br(e($displayDetails ?: __('This venue is preparing its public story.'))) !!}</p>
                            </article>
                            <article>
                                <h3>{{ __('Signals') }}</h3>
                                <ul class="venue-profile-signal-list">
                                    <li>
                                        <span>{{ __('Followers') }}</span>
                                        <strong>{{ $venue->followers_count }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Published reviews') }}</span>
                                        <strong>{{ $venue->review_count }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Average rating') }}</span>
                                        <strong>{{ $venue->average_rating }}</strong>
                                    </li>
                                    <li>
                                        <span>{{ __('Visible events') }}</span>
                                        <strong>{{ $totalCount }}</strong>
                                    </li>
                                </ul>
                            </article>
                        </div>
                    </div>

                    <div class="venue-profile-panel venue-profile-panel--events" id="venue-calendar">
                        <div class="venue-profile-panel__head venue-profile-panel__head--stacked">
                            <div>
                                <span class="venue-panel-kicker">{{ __('Calendar') }}</span>
                                <h2>{{ __('What is happening here') }}</h2>
                            </div>
                            <p>{{ __('Track the next wave of events and keep a clean view of what has already passed through this venue.') }}</p>
                        </div>

                        <div class="venue-event-tabs mb-30">
                            <ul class="nav nav-pills">
                                <li class="nav-item">
                                    <button class="nav-link active" type="button" data-toggle="tab" data-target="#venue-upcoming">
                                        {{ __('Upcoming') }}
                                        <span>{{ $upcomingCount }}</span>
                                    </button>
                                </li>
                                <li class="nav-item">
                                    <button class="nav-link" type="button" data-toggle="tab" data-target="#venue-past">
                                        {{ __('Past') }}
                                        <span>{{ $pastCount }}</span>
                                    </button>
                                </li>
                            </ul>
                        </div>

                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="venue-upcoming">
                                <div class="row">
                                    @forelse ($upcomingEvents as $event)
                                        <div class="col-xl-6">
                                            <article class="venue-event-card venue-event-card--upcoming">
                                                <div class="venue-event-card__media">
                                                    <a href="{{ $event->event_url }}">
                                                        <img src="{{ $event->thumbnail_url }}" alt="{{ $event->title }}">
                                                    </a>
                                                    <div class="venue-event-card__overlay"></div>
                                                    <div class="venue-event-card__topline">
                                                        <span class="venue-event-card__status venue-event-card__status--{{ $event->status_class }}">{{ $event->status_label }}</span>
                                                        <span class="venue-event-card__price">{{ $event->price_display }}</span>
                                                    </div>
                                                </div>
                                                <div class="venue-event-card__body">
                                                    <div class="venue-event-card__eyebrow">
                                                        <span>{{ $event->date_badge }}</span>
                                                        <span>{{ $event->time_badge }}</span>
                                                    </div>
                                                    <h3><a href="{{ $event->event_url }}">{{ $event->title }}</a></h3>
                                                    <div class="venue-event-card__meta-grid">
                                                        <div>
                                                            <span>{{ __('Starts') }}</span>
                                                            <strong>{{ $event->date_full }}</strong>
                                                        </div>
                                                        <div>
                                                            <span>{{ __('Location') }}</span>
                                                            <strong>{{ $event->location }}</strong>
                                                        </div>
                                                    </div>
                                                    <div class="venue-event-card__footer">
                                                        <div class="venue-event-card__signals">
                                                            <span>{{ $event->price_hint }}</span>
                                                            <span>{{ __('Scene ready') }}</span>
                                                        </div>
                                                        <a href="{{ $event->event_url }}" class="venue-event-card__cta">
                                                            {{ __('Open event') }}
                                                            <i class="fas fa-arrow-right"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    @empty
                                        <div class="col-12">
                                            <div class="venue-empty-state">
                                                <h3>{{ __('No upcoming events yet') }}</h3>
                                                <p>{{ __('This venue does not have visible upcoming events right now. Check back soon.') }}</p>
                                            </div>
                                        </div>
                                    @endforelse
                                </div>
                            </div>

                            <div class="tab-pane fade" id="venue-past">
                                <div class="row">
                                    @forelse ($pastEvents as $event)
                                        <div class="col-xl-6">
                                            <article class="venue-event-card venue-event-card--past">
                                                <div class="venue-event-card__media">
                                                    <a href="{{ $event->event_url }}">
                                                        <img src="{{ $event->thumbnail_url }}" alt="{{ $event->title }}">
                                                    </a>
                                                    <div class="venue-event-card__overlay"></div>
                                                    <div class="venue-event-card__topline">
                                                        <span class="venue-event-card__status venue-event-card__status--{{ $event->status_class }}">{{ $event->status_label }}</span>
                                                        <span class="venue-event-card__price">{{ $event->price_display }}</span>
                                                    </div>
                                                </div>
                                                <div class="venue-event-card__body">
                                                    <div class="venue-event-card__eyebrow">
                                                        <span>{{ $event->date_badge }}</span>
                                                        <span>{{ $event->time_badge }}</span>
                                                    </div>
                                                    <h3><a href="{{ $event->event_url }}">{{ $event->title }}</a></h3>
                                                    <div class="venue-event-card__meta-grid">
                                                        <div>
                                                            <span>{{ __('Date') }}</span>
                                                            <strong>{{ $event->date_full }}</strong>
                                                        </div>
                                                        <div>
                                                            <span>{{ __('Location') }}</span>
                                                            <strong>{{ $event->location }}</strong>
                                                        </div>
                                                    </div>
                                                    <div class="venue-event-card__footer">
                                                        <div class="venue-event-card__signals">
                                                            <span>{{ __('Previously hosted') }}</span>
                                                            <span>{{ $event->price_hint }}</span>
                                                        </div>
                                                        <a href="{{ $event->event_url }}" class="venue-event-card__cta">
                                                            {{ __('Open event') }}
                                                            <i class="fas fa-arrow-right"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    @empty
                                        <div class="col-12">
                                            <div class="venue-empty-state venue-empty-state--compact">
                                                <h3>{{ __('No past events yet') }}</h3>
                                                <p>{{ __('Once this venue has hosted public events, they will appear here.') }}</p>
                                            </div>
                                        </div>
                                    @endforelse
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <aside class="venue-profile-sidebar">
                    <div class="venue-profile-panel venue-profile-panel--compact">
                        <div class="venue-profile-panel__head">
                            <div>
                                <span class="venue-panel-kicker">{{ __('Location') }}</span>
                                <h2>{{ __('Venue signals') }}</h2>
                            </div>
                        </div>
                        <ul class="venue-contact-list">
                            @if ($venue->address)
                                <li>
                                    <span>{{ __('Address') }}</span>
                                    <strong>{{ $venue->address }}</strong>
                                </li>
                            @endif
                            @if ($locationSummary)
                                <li>
                                    <span>{{ __('Area') }}</span>
                                    <strong>{{ $locationSummary }}</strong>
                                </li>
                            @endif
                            @if ($venue->zip_code)
                                <li>
                                    <span>{{ __('Postal code') }}</span>
                                    <strong>{{ $venue->zip_code }}</strong>
                                </li>
                            @endif
                            <li>
                                <span>{{ __('Followers') }}</span>
                                <strong>{{ $venue->followers_count }}</strong>
                            </li>
                        </ul>
                        @if ($mapsUrl)
                            <a href="{{ $mapsUrl }}" target="_blank" rel="noopener" class="theme-btn theme-btn--wide mt-20">{{ __('Open in maps') }}</a>
                        @endif
                    </div>

                    @if (!empty($socialLinks))
                        <div class="venue-profile-panel venue-profile-panel--compact">
                            <div class="venue-profile-panel__head">
                                <div>
                                    <span class="venue-panel-kicker">{{ __('Elsewhere') }}</span>
                                    <h2>{{ __('Venue channels') }}</h2>
                                </div>
                            </div>
                            <div class="venue-social-grid">
                                @foreach ($socialLinks as $network => $url)
                                    <a href="{{ $url }}" target="_blank" rel="noopener">
                                        <i class="fab fa-{{ $network === 'linkedin' ? 'linkedin-in' : $network }}"></i>
                                        <span>{{ ucfirst($network) }}</span>
                                    </a>
                                @endforeach
                            </div>
                        </div>
                    @endif
                </aside>
            </div>
        </div>
    </section>

    <style>
        .venue-profile-hero {
            position: relative;
            overflow: hidden;
            padding: 144px 0 88px;
            color: #eef5ff;
        }

        .venue-profile-hero__backdrop {
            position: absolute;
            inset: 0;
            background-size: cover;
            background-position: center;
            filter: saturate(1.05);
        }

        .venue-profile-hero::after {
            content: '';
            position: absolute;
            inset: auto 0 0;
            height: 220px;
            background: linear-gradient(180deg, rgba(8, 10, 16, 0) 0%, rgba(8, 10, 16, 0.9) 78%, rgba(8, 10, 16, 1) 100%);
        }

        .venue-profile-hero__container {
            position: relative;
            z-index: 1;
        }

        .venue-profile-hero__grid {
            display: grid;
            grid-template-columns: minmax(0, 1.65fr) minmax(320px, 0.9fr);
            gap: 28px;
            align-items: stretch;
        }

        .venue-profile-hero__main,
        .venue-profile-hero__card,
        .venue-profile-panel,
        .venue-event-card,
        .venue-empty-state {
            background: linear-gradient(180deg, rgba(27, 38, 59, 0.86), rgba(12, 17, 28, 0.96));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 24px 60px rgba(5, 8, 14, 0.35);
            backdrop-filter: blur(18px);
        }

        .venue-profile-hero__main {
            border-radius: 34px;
            padding: 36px 38px;
        }

        .venue-profile-hero__card {
            border-radius: 34px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            gap: 22px;
        }

        .venue-profile-hero__eyebrow,
        .venue-panel-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.82rem;
            letter-spacing: 0.24em;
            text-transform: uppercase;
            color: rgba(204, 224, 255, 0.66);
            margin-bottom: 14px;
        }

        .venue-profile-hero h1,
        .venue-profile-panel__head h2,
        .venue-profile-story-grid h3,
        .venue-event-card h3 {
            font-family: 'Outfit', sans-serif;
        }

        .venue-profile-hero h1 {
            margin: 0;
            font-size: clamp(2.6rem, 4vw, 4.2rem);
            line-height: 0.96;
            max-width: 11ch;
        }

        .venue-profile-hero__identity,
        .venue-profile-hero__chips,
        .venue-profile-hero__actions,
        .venue-profile-hero__stats-grid,
        .venue-profile-hero__socials,
        .venue-profile-layout,
        .venue-profile-story-grid,
        .venue-contact-list,
        .venue-social-grid,
        .venue-event-card__eyebrow,
        .venue-event-card__meta-grid,
        .venue-event-card__footer,
        .venue-event-card__signals {
            display: flex;
            flex-wrap: wrap;
        }

        .venue-profile-hero__identity {
            gap: 12px;
            margin-top: 18px;
        }

        .venue-profile-hero__identity span,
        .venue-profile-hero__chips span {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.06);
            color: rgba(234, 241, 252, 0.82);
            font-size: 0.95rem;
        }

        .venue-profile-hero__summary {
            margin: 22px 0 0;
            max-width: 62ch;
            color: rgba(223, 232, 245, 0.8);
            font-size: 1.02rem;
            line-height: 1.75;
        }

        .venue-profile-hero__chips {
            gap: 12px;
            margin-top: 24px;
        }

        .venue-profile-hero__actions {
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
            color: #eef5ff;
            box-shadow: none;
        }

        .theme-btn--ghost:hover {
            color: #fff;
            border-color: rgba(255, 255, 255, 0.18);
            transform: translateY(-2px);
        }

        .venue-profile-hero__photo-wrap {
            position: relative;
            overflow: hidden;
            border-radius: 26px;
            aspect-ratio: 1 / 1.03;
            background: rgba(255, 255, 255, 0.05);
        }

        .venue-profile-hero__photo-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .venue-profile-hero__card-copy p,
        .venue-profile-panel__head--stacked p,
        .venue-event-card p,
        .venue-empty-state p,
        .venue-profile-story-grid p,
        .venue-contact-list strong,
        .venue-contact-list a {
            color: rgba(219, 228, 242, 0.76);
        }

        .venue-profile-hero__card-copy h3 {
            margin: 8px 0 0;
            font-size: 1.32rem;
            color: #fff;
        }

        .venue-profile-hero__stats-grid {
            gap: 12px;
        }

        .venue-profile-hero__stats-grid > div {
            flex: 1 1 calc(50% - 12px);
            min-width: 120px;
            padding: 16px 18px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.05);
        }

        .venue-profile-hero__stats-grid span,
        .venue-event-card__meta-grid span,
        .venue-contact-list span,
        .venue-profile-signal-list span {
            display: block;
            color: rgba(188, 205, 226, 0.64);
            font-size: 0.8rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .venue-profile-hero__stats-grid strong,
        .venue-event-card__meta-grid strong,
        .venue-contact-list strong,
        .venue-profile-signal-list strong {
            display: block;
            margin-top: 5px;
            color: #fff;
            font-size: 1.05rem;
            font-weight: 700;
        }

        .venue-profile-hero__socials {
            gap: 12px;
        }

        .venue-profile-hero__socials a,
        .venue-social-grid a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.06);
            color: #eef5ff;
            transition: transform 0.2s ease, background 0.2s ease;
        }

        .venue-profile-hero__socials a:hover,
        .venue-social-grid a:hover {
            transform: translateY(-3px);
            background: rgba(80, 158, 255, 0.24);
        }

        .venue-profile-shell {
            position: relative;
            background: radial-gradient(circle at top, rgba(80, 158, 255, 0.08), transparent 28%), #090d14;
        }

        .venue-profile-layout {
            gap: 28px;
            align-items: start;
        }

        .venue-profile-main {
            flex: 1 1 0;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 28px;
        }

        .venue-profile-sidebar {
            width: 350px;
            display: flex;
            flex-direction: column;
            gap: 24px;
            position: sticky;
            top: 112px;
        }

        .venue-profile-panel {
            border-radius: 30px;
            padding: 28px;
        }

        .venue-profile-panel--compact {
            padding: 24px;
        }

        .venue-profile-panel__head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
        }

        .venue-profile-panel__head--stacked {
            align-items: flex-end;
        }

        .venue-profile-panel__head h2 {
            margin: 0;
            color: #fff;
            font-size: 1.75rem;
        }

        .venue-profile-story-grid {
            gap: 18px;
        }

        .venue-profile-story-grid article {
            flex: 1 1 260px;
            padding: 22px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .venue-profile-story-grid h3 {
            margin-bottom: 14px;
            color: #fff;
            font-size: 1.15rem;
        }

        .venue-profile-story-grid p {
            margin: 0;
            line-height: 1.8;
        }

        .venue-profile-signal-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .venue-profile-signal-list li,
        .venue-contact-list li {
            list-style: none;
        }

        .venue-event-tabs .nav {
            gap: 10px;
            border: none;
        }

        .venue-event-tabs .nav-link {
            border: 0;
            border-radius: 999px;
            padding: 12px 18px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: rgba(255, 255, 255, 0.05);
            color: rgba(229, 236, 247, 0.78);
        }

        .venue-event-tabs .nav-link span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 30px;
            height: 30px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            font-size: 0.8rem;
        }

        .venue-event-tabs .nav-link.active {
            background: linear-gradient(135deg, rgba(80, 158, 255, 0.92), rgba(110, 196, 255, 0.88));
            color: #091018;
            box-shadow: 0 16px 34px rgba(37, 99, 182, 0.32);
        }

        .venue-event-card {
            border-radius: 28px;
            overflow: hidden;
            margin-bottom: 24px;
        }

        .venue-event-card__media {
            position: relative;
            aspect-ratio: 16 / 10;
            overflow: hidden;
        }

        .venue-event-card__media img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .venue-event-card:hover .venue-event-card__media img {
            transform: scale(1.04);
        }

        .venue-event-card__overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(8, 12, 18, 0.08), rgba(8, 12, 18, 0.7));
        }

        .venue-event-card__topline {
            position: absolute;
            top: 18px;
            left: 18px;
            right: 18px;
            z-index: 1;
            display: flex;
            justify-content: space-between;
            gap: 12px;
        }

        .venue-event-card__status,
        .venue-event-card__price {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 9px 14px;
            border-radius: 999px;
            backdrop-filter: blur(14px);
            background: rgba(255, 255, 255, 0.12);
            color: #fff;
            font-size: 0.84rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        .venue-event-card__status--upcoming {
            background: rgba(72, 170, 111, 0.3);
        }

        .venue-event-card__status--past {
            background: rgba(255, 255, 255, 0.1);
            color: rgba(230, 236, 245, 0.82);
        }

        .venue-event-card__body {
            padding: 24px;
        }

        .venue-event-card__eyebrow {
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
            color: rgba(217, 227, 240, 0.72);
            font-size: 0.84rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .venue-event-card h3 {
            margin: 0;
            font-size: 1.35rem;
            line-height: 1.18;
        }

        .venue-event-card h3 a {
            color: #fff;
        }

        .venue-event-card__meta-grid {
            gap: 14px;
            margin-top: 20px;
        }

        .venue-event-card__meta-grid > div {
            flex: 1 1 calc(50% - 14px);
            min-width: 180px;
            padding: 14px 16px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        .venue-event-card__footer {
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-top: 22px;
        }

        .venue-event-card__signals {
            gap: 10px;
        }

        .venue-event-card__signals span {
            padding: 9px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.05);
            color: rgba(220, 228, 240, 0.72);
            font-size: 0.82rem;
        }

        .venue-event-card__cta {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            color: #fff;
            font-weight: 700;
        }

        .venue-empty-state {
            border-radius: 28px;
            padding: 52px 28px;
            text-align: center;
        }

        .venue-empty-state h3 {
            color: #fff;
            margin-bottom: 10px;
        }

        .venue-empty-state--compact {
            padding: 36px 24px;
        }

        .venue-contact-list {
            flex-direction: column;
            gap: 16px;
            margin: 0;
            padding: 0;
        }

        .venue-social-grid {
            gap: 12px;
        }

        .venue-social-grid a {
            width: auto;
            min-width: calc(50% - 12px);
            justify-content: flex-start;
            gap: 10px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 600;
        }

        @media (max-width: 1199px) {
            .venue-profile-layout {
                flex-direction: column;
            }

            .venue-profile-sidebar {
                width: 100%;
                position: static;
            }
        }

        @media (max-width: 991px) {
            .venue-profile-hero {
                padding: 124px 0 70px;
            }

            .venue-profile-hero__grid {
                grid-template-columns: 1fr;
            }

            .venue-profile-panel__head--stacked {
                align-items: flex-start;
            }
        }

        @media (max-width: 767px) {
            .venue-profile-hero__main,
            .venue-profile-hero__card,
            .venue-profile-panel {
                padding: 22px;
                border-radius: 24px;
            }

            .venue-profile-hero h1 {
                max-width: none;
                font-size: 2.5rem;
            }

            .venue-profile-signal-list,
            .venue-event-card__meta-grid {
                grid-template-columns: 1fr;
            }

            .venue-social-grid a,
            .venue-event-card__meta-grid > div {
                min-width: 100%;
            }

            .venue-event-card__footer {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
@endsection
