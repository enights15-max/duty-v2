@extends('frontend.layout')

@section('pageHeading')
    {{ $pageTitle }}
@endsection

@section('custom-style')
    @include('frontend.product.partials.styles')
@endsection

@section('hero-section')
    <section class="product-surface">
        <div class="product-surface__grid"></div>
        <div class="container">
            <div class="product-surface__hero-layout">
                <div class="product-surface__hero-main">
                    <span class="product-surface__eyebrow">
                        <span class="product-surface__eyebrow-dot"></span>
                        {{ $downloadContext['eyebrow'] }}
                    </span>

                    <h1 class="product-surface__title">
                        {{ $downloadContext['title'] }}
                        <span class="product-surface__title-accent">{{ __('Browse on web. Continue on your phone.') }}</span>
                    </h1>

                    <p class="product-surface__copy">{{ $downloadContext['copy'] }}</p>

                    <div class="product-surface__actions">
                        @if (!empty($storeLinks['ios']))
                            <a href="{{ $storeLinks['ios'] }}" class="product-surface__action">{{ __('Download on the App Store') }}</a>
                        @endif
                        @if (!empty($storeLinks['android']))
                            <a href="{{ $storeLinks['android'] }}" class="product-surface__ghost">{{ __('Get it on Google Play') }}</a>
                        @endif
                        @if (empty($storeLinks['ios']) && empty($storeLinks['android']))
                            <a href="{{ route('contact') }}" class="product-surface__action">{{ __('Request beta access') }}</a>
                        @endif
                    </div>
                </div>

                <aside class="product-surface__hero-side">
                    <article class="product-surface__access-card">
                        <span class="product-surface__tag">{{ __('Access layer') }}</span>
                        <h3 class="product-surface__panel-title">{{ __('Discovery starts on web. Entry and tickets live in the app.') }}</h3>
                        <p class="product-surface__panel-copy">{{ __('This bridge is intentional: public pages explain the scene, but the phone becomes the real place for wallet, reminders, access and follow-through.') }}</p>
                        <div class="product-surface__access-flow">
                            <div class="product-surface__flow-step">
                                <small>{{ __('1') }}</small>
                                <strong>{{ __('Browse the event') }}</strong>
                                <span>{{ __('See the story, the host and the context on web.') }}</span>
                            </div>
                            <div class="product-surface__flow-step">
                                <small>{{ __('2') }}</small>
                                <strong>{{ __('Open the app') }}</strong>
                                <span>{{ __('Continue into the app-first ticket and access flow.') }}</span>
                            </div>
                            <div class="product-surface__flow-step">
                                <small>{{ __('3') }}</small>
                                <strong>{{ __('Keep it with you') }}</strong>
                                <span>{{ __('Wallet, reminders and entry stay on the phone.') }}</span>
                            </div>
                        </div>
                    </article>

                    <article class="product-surface__store-hero-card">
                        <span class="product-surface__tag">{{ __('Choose your device') }}</span>
                        <div class="product-surface__device-grid">
                            <div class="product-surface__device-tile">
                                <small>{{ __('iPhone') }}</small>
                                <strong>{{ !empty($storeLinks['ios']) ? __('Ready to continue') : __('Link coming soon') }}</strong>
                                <span>{{ !empty($storeLinks['ios']) ? __('Open the iOS build and continue right where the event started.') : __('The App Store link will land here once distribution is ready.') }}</span>
                            </div>
                            <div class="product-surface__device-tile">
                                <small>{{ __('Android') }}</small>
                                <strong>{{ !empty($storeLinks['android']) ? __('Ready to continue') : __('Link coming soon') }}</strong>
                                <span>{{ !empty($storeLinks['android']) ? __('Jump into Google Play and keep the scene on your phone.') : __('The Google Play link will land here once distribution is ready.') }}</span>
                            </div>
                        </div>
                    </article>
                </aside>
            </div>

            <div class="product-surface__proof-grid">
                <article class="product-surface__proof-card">
                    <span class="product-surface__proof-value">{{ number_format($sceneStats['upcoming_events'] ?? 0) }}</span>
                    <span class="product-surface__proof-label">{{ __('live and upcoming events to explore') }}</span>
                </article>
                <article class="product-surface__proof-card">
                    <span class="product-surface__proof-value">{{ number_format($sceneStats['organizers'] ?? 0) }}</span>
                    <span class="product-surface__proof-label">{{ __('hosts building their public scene on Duty') }}</span>
                </article>
                <article class="product-surface__proof-card">
                    <span class="product-surface__proof-value">{{ __('App-first') }}</span>
                    <span class="product-surface__proof-label">{{ __('ticket wallet, social discovery and access experience') }}</span>
                </article>
            </div>
        </div>
    </section>
@endsection

@section('content')
    <div class="container pb-110">
        <div class="product-surface__layout">
            <div class="product-surface__download-stack">
                <article class="product-surface__download-card">
                    <span class="product-surface__tag">{{ __('Why the app matters') }}</span>
                    <h3 class="product-surface__panel-title">{{ __('Duty is designed around the phone, not around a web checkout.') }}</h3>
                    <p class="product-surface__panel-copy">{{ __('That is where tickets live, access is unlocked, reminders arrive and the social loop keeps moving after the event page is closed.') }}</p>
                </article>

                <article class="product-surface__workflow-card">
                    <span class="product-surface__tag">{{ __('What you unlock') }}</span>
                    <ul class="product-surface__workflow-list">
                        <li>{{ __('Buy or unlock tickets inside the app-first flow') }}</li>
                        <li>{{ __('Hold your ticket and access pass in the same place') }}</li>
                        <li>{{ __('Follow organizers, artists and venues you care about') }}</li>
                        <li>{{ __('Keep updates, reminders and scene activity close to you') }}</li>
                    </ul>
                </article>
            </div>

            <div class="product-surface__download-stack">
                <article class="product-surface__store-card">
                    <span class="product-surface__tag">{{ __('Store links') }}</span>
                    <h3 class="product-surface__panel-title">{{ __('Choose your device') }}</h3>
                    <p class="product-surface__store-copy">{{ __('You can keep using the web for discovery and public browsing. The app becomes the place where the full consumer experience lives.') }}</p>
                    <div class="product-surface__store-grid">
                        @if (!empty($storeLinks['ios']))
                            <a href="{{ $storeLinks['ios'] }}" class="product-surface__store-button">
                                <small>{{ __('iPhone') }}</small>
                                <strong>{{ __('Download on the App Store') }}</strong>
                                <span>{{ __('Open the iOS build and continue with the app-first ticket flow.') }}</span>
                            </a>
                        @else
                            <div class="product-surface__store-button product-surface__store-button--disabled">
                                <small>{{ __('iPhone') }}</small>
                                <strong>{{ __('App Store link coming soon') }}</strong>
                                <span>{{ __('We will plug the iOS beta link here as soon as distribution is ready.') }}</span>
                            </div>
                        @endif

                        @if (!empty($storeLinks['android']))
                            <a href="{{ $storeLinks['android'] }}" class="product-surface__store-button">
                                <small>{{ __('Android') }}</small>
                                <strong>{{ __('Get it on Google Play') }}</strong>
                                <span>{{ __('Continue on Android and keep your scene with you.') }}</span>
                            </a>
                        @else
                            <div class="product-surface__store-button product-surface__store-button--disabled">
                                <small>{{ __('Android') }}</small>
                                <strong>{{ __('Google Play link coming soon') }}</strong>
                                <span>{{ __('We will plug the Android beta link here as soon as distribution is ready.') }}</span>
                            </div>
                        @endif
                    </div>
                </article>

                <article class="product-surface__info-card">
                    <span class="product-surface__tag">{{ __('Need help') }}</span>
                    <h3 class="product-surface__panel-title">{{ __('Rolling this out in beta?') }}</h3>
                    <p class="product-surface__info-copy">{{ __('Use the web to explain the product, attract the right audience and route people into the mobile experience when they are ready to unlock tickets.') }}</p>
                    <div class="product-surface__actions mt-4">
                        <a href="{{ route('frontend.for_organizers') }}" class="product-surface__ghost">{{ __('For organizers') }}</a>
                        <a href="{{ route('frontend.for_artists') }}" class="product-surface__ghost">{{ __('For artists') }}</a>
                        <a href="{{ route('frontend.for_venues') }}" class="product-surface__ghost">{{ __('For venues') }}</a>
                    </div>
                </article>
            </div>
        </div>
    </div>
@endsection
