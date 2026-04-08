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
            <span class="product-surface__eyebrow">
                <span class="product-surface__eyebrow-dot"></span>
                {{ $persona['eyebrow'] }}
            </span>

            <h1 class="product-surface__title">
                {{ $persona['title'] }}
                <span class="product-surface__title-accent">{{ $persona['accent'] }}</span>
            </h1>

            <p class="product-surface__copy">{{ $persona['description'] }}</p>

            <div class="product-surface__actions">
                <a href="{{ $persona['primary_url'] }}" class="product-surface__action">
                    {{ $persona['primary_label'] }}
                    <i class="fas fa-arrow-right"></i>
                </a>
                <a href="{{ $persona['secondary_url'] }}" class="product-surface__ghost">
                    {{ $persona['secondary_label'] }}
                </a>
            </div>

            <div class="product-surface__proof-grid">
                @foreach ($persona['proof'] as $proof)
                    <article class="product-surface__proof-card">
                        <span class="product-surface__proof-value">{{ $proof['value'] }}</span>
                        <span class="product-surface__proof-label">{{ $proof['label'] }}</span>
                    </article>
                @endforeach
            </div>
        </div>
    </section>
@endsection

@section('content')
    <div class="container pb-110">
        <div class="product-surface__layout">
            <div class="product-surface__pillars">
                @foreach ($persona['pillars'] as $pillar)
                    <article class="product-surface__panel product-surface__pillar">
                        <h3>{{ $pillar['title'] }}</h3>
                        <p>{{ $pillar['copy'] }}</p>
                    </article>
                @endforeach

                <div class="product-surface__footer-band">
                    <h3>{{ $persona['footer_title'] }}</h3>
                    <p>{{ $persona['footer_copy'] }}</p>
                </div>
            </div>

            <div class="product-surface__download-stack">
                <article class="product-surface__workflow-card">
                    <span class="product-surface__tag">{{ __('How this works') }}</span>
                    <h3 class="product-surface__panel-title">{{ __('The web brings the attention. The app keeps the audience.') }}</h3>
                    <ul class="product-surface__workflow-list">
                        @foreach ($persona['workflows'] as $workflow)
                            <li>{{ $workflow }}</li>
                        @endforeach
                    </ul>
                </article>

                <article class="product-surface__info-card">
                    <span class="product-surface__tag">{{ __('Scene snapshot') }}</span>
                    <p class="product-surface__info-copy">{{ __('Duty is being shaped as an app-first event network with the web acting as public discovery, professional onboarding and long-form presentation.') }}</p>
                    <div class="product-surface__mini-stat-grid">
                        <div class="product-surface__mini-stat">
                            <strong>{{ number_format($sceneStats['upcoming_events'] ?? 0) }}</strong>
                            <span>{{ __('upcoming events') }}</span>
                        </div>
                        <div class="product-surface__mini-stat">
                            <strong>{{ number_format($sceneStats['organizers'] ?? 0) }}</strong>
                            <span>{{ __('active organizers') }}</span>
                        </div>
                        <div class="product-surface__mini-stat">
                            <strong>{{ number_format($sceneStats['artists'] ?? 0) }}</strong>
                            <span>{{ __('artists on the scene') }}</span>
                        </div>
                        <div class="product-surface__mini-stat">
                            <strong>{{ number_format($sceneStats['venues'] ?? 0) }}</strong>
                            <span>{{ __('venues in the network') }}</span>
                        </div>
                    </div>
                </article>

                <article class="product-surface__store-card">
                    <span class="product-surface__tag">{{ __('Consumer layer') }}</span>
                    <h3 class="product-surface__panel-title">{{ __('The app is where ticket access and repeat engagement live.') }}</h3>
                    <p class="product-surface__store-copy">{{ __('Use the public web to explain the scene and your value. Use the app to hold the ticket, social graph, alerts and access pass.') }}</p>
                    <div class="product-surface__actions mt-4">
                        <a href="{{ route('frontend.download_app') }}" class="product-surface__action">{{ __('Open download page') }}</a>
                    </div>
                </article>
            </div>
        </div>
    </div>
@endsection
