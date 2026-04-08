@extends('frontend.layout')

@section('pageHeading')
    {{ $pageTitle }}
@endsection

@section('meta-description')
    {{ $shareDescription }}
@endsection

@section('meta-keywords')
    {{ __('duty,event,tickets,app,download') }}
@endsection

@section('og-title')
    {{ $eventTitle }}
@endsection

@section('og-description')
    {{ $shareDescription }}
@endsection

@section('page-icon')
    {{ asset('assets/front/images/duty-app-icon-share.png') }}
@endsection

@section('apple-touch-icon')
    {{ asset('assets/front/images/duty-app-icon-share.png') }}
@endsection

@section('og-image')
    {{ $eventImageUrl ?: asset('assets/front/images/duty-app-icon-share.png') }}
@endsection

@section('head-extra')
    <meta property="og:type" content="website" />
    <meta property="og:site_name" content="Duty" />
    <meta property="og:url" content="{{ request()->fullUrl() }}" />
    <meta property="og:image:alt" content="{{ $eventTitle }}" />
    <meta name="twitter:card" content="{{ $eventImageUrl ? 'summary_large_image' : 'summary' }}">
    <meta name="twitter:title" content="{{ $eventTitle }}">
    <meta name="twitter:description" content="{{ $shareDescription }}">
    <meta name="twitter:image" content="{{ $eventImageUrl ?: asset('assets/front/images/duty-app-icon-share.png') }}">
@endsection

@section('custom-style')
    @include('frontend.product.partials.styles')
    <style>
        .open-event-bridge {
            padding: 156px 0 110px;
        }

        .open-event-bridge__layout {
            display: grid;
            grid-template-columns: minmax(0, 1.08fr) minmax(340px, 0.92fr);
            gap: 28px;
            align-items: stretch;
        }

        .open-event-bridge__surface {
            position: relative;
            overflow: hidden;
            border-radius: 32px;
            min-height: 100%;
            background:
                linear-gradient(180deg, rgba(11, 7, 18, 0.18), rgba(11, 7, 18, 0.78)),
                radial-gradient(circle at top right, rgba(140, 37, 244, 0.26), transparent 42%),
                #120b1b;
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--surface-shadow);
        }

        .open-event-bridge__surface::after {
            content: '';
            position: absolute;
            inset: 0;
            background:
                linear-gradient(180deg, rgba(15, 9, 22, 0.1), rgba(15, 9, 22, 0.88)),
                url('{{ $eventImageUrl ?? '' }}') center/cover no-repeat;
            opacity: {{ $eventImageUrl ? '1' : '0' }};
            z-index: 0;
        }

        .open-event-bridge__surface-inner,
        .open-event-bridge__actions,
        .open-event-bridge__side {
            position: relative;
            z-index: 1;
        }

        .open-event-bridge__surface-inner {
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            min-height: 100%;
            padding: 34px;
            gap: 18px;
        }

        .open-event-bridge__eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            width: fit-content;
            padding: 10px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.08);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: rgba(255, 255, 255, 0.84);
        }

        .open-event-bridge__eyebrow-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffcf5a, #8c25f4);
        }

        .open-event-bridge__title {
            margin: 0;
            max-width: 660px;
            font-family: var(--pjs);
            font-size: clamp(2.8rem, 5vw, 4.5rem);
            line-height: 0.96;
            letter-spacing: -0.05em;
        }

        .open-event-bridge__copy {
            max-width: 620px;
            margin: 0;
            color: var(--text-secondary);
            font-size: 18px;
            line-height: 1.8;
        }

        .open-event-bridge__actions {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
        }

        .open-event-bridge__button,
        .open-event-bridge__button-ghost {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 54px;
            padding: 0 22px;
            border-radius: 18px;
            font-family: var(--pjs);
            font-weight: 800;
            transition: transform 0.22s ease, box-shadow 0.22s ease;
        }

        .open-event-bridge__button {
            color: #fff;
            background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
            box-shadow: 0 18px 34px rgba(140, 37, 244, 0.24);
        }

        .open-event-bridge__button-ghost {
            color: #fff;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .open-event-bridge__button:hover,
        .open-event-bridge__button-ghost:hover {
            color: #fff;
            transform: translateY(-1px);
        }

        .open-event-bridge__side {
            display: grid;
            gap: 18px;
        }

        .open-event-bridge__card {
            padding: 28px;
            border-radius: 28px;
            background: linear-gradient(180deg, rgba(33, 22, 46, 0.92), rgba(16, 10, 24, 0.92));
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: var(--surface-shadow);
        }

        .open-event-bridge__card h3 {
            margin: 0 0 10px;
            font-size: 1.18rem;
        }

        .open-event-bridge__card p,
        .open-event-bridge__card li {
            color: var(--text-secondary);
            line-height: 1.8;
        }

        .open-event-bridge__list {
            margin: 0;
            padding-left: 18px;
        }

        .open-event-bridge__meta {
            display: grid;
            gap: 12px;
        }

        .open-event-bridge__meta-line {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            color: var(--text-secondary);
            font-size: 14px;
        }

        .open-event-bridge__meta-line strong {
            color: #fff;
            font-weight: 700;
        }

        @media (max-width: 991px) {
            .open-event-bridge {
                padding: 132px 0 88px;
            }

            .open-event-bridge__layout {
                grid-template-columns: 1fr;
            }

            .open-event-bridge__surface-inner {
                min-height: 460px;
            }
        }
    </style>
@endsection

@section('hero-section')
    <section class="product-surface open-event-bridge">
        <div class="product-surface__grid"></div>
        <div class="container">
            <div class="open-event-bridge__layout">
                <article class="open-event-bridge__surface">
                    <div class="open-event-bridge__surface-inner">
                        <span class="open-event-bridge__eyebrow">
                            <span class="open-event-bridge__eyebrow-dot"></span>
                            {{ __('Open in the Duty app') }}
                        </span>

                        <h1 class="open-event-bridge__title">{{ $eventTitle }}</h1>
                        <p class="open-event-bridge__copy">
                            {{ __('If Duty is already installed, we will take you straight into this event. If not, we will route you to install the app and continue there.') }}
                        </p>

                        <div class="open-event-bridge__actions">
                            <a href="{{ $deepLinkUrl }}" class="open-event-bridge__button" id="open-duty-app">
                                {{ __('Open in app') }}
                            </a>
                            <a href="{{ $downloadUrl }}" class="open-event-bridge__button-ghost" id="install-duty-app">
                                {{ __('Install the app') }}
                            </a>
                            <a href="{{ $publicEventUrl }}" class="open-event-bridge__button-ghost">
                                {{ __('Continue on web') }}
                            </a>
                        </div>
                    </div>
                </article>

                <aside class="open-event-bridge__side">
                    <article class="open-event-bridge__card">
                        <span class="product-surface__tag">{{ __('What happens next') }}</span>
                        <h3>{{ __('This link is built as a bridge, not just a page.') }}</h3>
                        <ul class="open-event-bridge__list">
                            <li>{{ __('Installed app: open the exact event inside Duty.') }}</li>
                            <li>{{ __('No app yet: send the visitor to install first.') }}</li>
                            <li>{{ __('Need context first: keep the public event page available too.') }}</li>
                        </ul>
                    </article>

                    <article class="open-event-bridge__card">
                        <span class="product-surface__tag">{{ __('Event target') }}</span>
                        <div class="open-event-bridge__meta">
                            <div class="open-event-bridge__meta-line">
                                <span>{{ __('Event ID') }}</span>
                                <strong>#{{ $eventId }}</strong>
                            </div>
                            <div class="open-event-bridge__meta-line">
                                <span>{{ __('Deep link') }}</span>
                                <strong>{{ $deepLinkUrl }}</strong>
                            </div>
                        </div>
                    </article>
                </aside>
            </div>
        </div>
    </section>
@endsection

@section('content')
@endsection

@section('script')
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const deepLinkUrl = @json($deepLinkUrl);
            const iosStoreUrl = @json($storeLinks['ios'] ?? null);
            const androidStoreUrl = @json($storeLinks['android'] ?? null);
            const genericDownloadUrl = @json($downloadUrl);
            const openButton = document.getElementById('open-duty-app');
            const installButton = document.getElementById('install-duty-app');

            const ua = navigator.userAgent || navigator.vendor || '';
            const isIOS = /iPhone|iPad|iPod/i.test(ua);
            const isAndroid = /Android/i.test(ua);
            const isMobile = isIOS || isAndroid;

            const fallbackUrl = isIOS && iosStoreUrl
                ? iosStoreUrl
                : isAndroid && androidStoreUrl
                    ? androidStoreUrl
                    : genericDownloadUrl;

            let fallbackTimer = null;

            const clearFallback = () => {
                if (fallbackTimer) {
                    window.clearTimeout(fallbackTimer);
                    fallbackTimer = null;
                }
            };

            const openApp = (event) => {
                if (event) {
                    event.preventDefault();
                }
                window.location.href = deepLinkUrl;
            };

            const installApp = (event) => {
                if (event) {
                    event.preventDefault();
                }
                window.location.href = fallbackUrl;
            };

            openButton?.addEventListener('click', openApp);
            installButton?.addEventListener('click', installApp);

            document.addEventListener('visibilitychange', function () {
                if (document.hidden) {
                    clearFallback();
                }
            });

            window.addEventListener('pagehide', clearFallback);

            if (!isMobile) {
                return;
            }

            fallbackTimer = window.setTimeout(function () {
                if (!document.hidden) {
                    window.location.replace(fallbackUrl);
                }
            }, 1600);

            window.setTimeout(function () {
                openApp();
            }, 80);
        });
    </script>
@endsection
