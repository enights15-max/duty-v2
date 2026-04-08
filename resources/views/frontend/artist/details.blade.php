@extends('frontend.layout')

@php
    $coverPhoto = $artist->cover_photo_url ?: asset('assets/admin/img/' . $basicInfo->breadcrumb);
    $photo = $artist->photo_url ?: asset('assets/front/images/user.png');
    $genres = collect($artist->genres ?? [])->filter(fn($genre) => filled($genre))->values();
    $locationParts = collect([$artist->city ?? null, $artist->country ?? null])->filter()->values();
    $location = $locationParts->implode(', ');
    $gallery = collect($artist->gallery ?? [])->filter(fn($image) => filled($image))->values();
    $bookingNotes = trim((string) ($artist->booking_notes ?? ''));

    $normalizeUrl = function (?string $value, string $kind): ?string {
        $trimmed = trim((string) $value);
        if ($trimmed === '') {
            return null;
        }

        if (str_starts_with($trimmed, 'http://') || str_starts_with($trimmed, 'https://')) {
            return $trimmed;
        }

        $clean = ltrim($trimmed, '@');

        return match ($kind) {
            'instagram' => "https://instagram.com/{$clean}",
            'facebook' => "https://facebook.com/{$clean}",
            'tiktok' => str_contains($clean, 'tiktok.com/') ? "https://{$clean}" : "https://www.tiktok.com/@{$clean}",
            'spotify' => str_contains($clean, 'spotify.com/') ? "https://{$clean}" : "https://open.spotify.com/{$clean}",
            'soundcloud' => str_contains($clean, 'soundcloud.com/') ? "https://{$clean}" : "https://soundcloud.com/{$clean}",
            'youtube' => (str_contains($clean, 'youtube.com/') || str_contains($clean, 'youtu.be/')) ? "https://{$clean}" : "https://youtube.com/@{$clean}",
            'twitter' => "https://twitter.com/{$clean}",
            'linkedin' => "https://linkedin.com/in/{$clean}",
            default => $trimmed,
        };
    };

    $spotifyUrl = $normalizeUrl($artist->spotify ?? null, 'spotify');
    $soundcloudUrl = $normalizeUrl($artist->soundcloud ?? null, 'soundcloud');
    $youtubeUrl = $normalizeUrl($artist->youtube ?? null, 'youtube');
    $instagramUrl = $normalizeUrl($artist->instagram ?? null, 'instagram');
    $facebookUrl = $normalizeUrl($artist->facebook ?? null, 'facebook');
    $tiktokUrl = $normalizeUrl($artist->tiktok ?? null, 'tiktok');
    $twitterUrl = $normalizeUrl($artist->twitter ?? null, 'twitter');
    $linkedinUrl = $normalizeUrl($artist->linkedin ?? null, 'linkedin');

    $spotifyEmbed = null;
    if ($spotifyUrl && str_contains($spotifyUrl, 'open.spotify.com')) {
        $spotifyEmbed = str_replace('open.spotify.com/', 'open.spotify.com/embed/', $spotifyUrl);
    }

    $soundcloudEmbed = $soundcloudUrl
        ? 'https://w.soundcloud.com/player/?url=' . urlencode($soundcloudUrl) . '&auto_play=false&hide_related=false&show_comments=false&show_user=true&show_reposts=false&visual=true'
        : null;

    $youtubeEmbed = null;
    if ($youtubeUrl) {
        $youtubeParts = parse_url($youtubeUrl);
        if (($youtubeParts['host'] ?? '') === 'youtu.be') {
            $path = trim($youtubeParts['path'] ?? '', '/');
            if ($path !== '') {
                $youtubeEmbed = 'https://www.youtube.com/embed/' . $path;
            }
        } else {
            parse_str($youtubeParts['query'] ?? '', $youtubeQuery);
            if (!empty($youtubeQuery['v'])) {
                $youtubeEmbed = 'https://www.youtube.com/embed/' . $youtubeQuery['v'];
            } elseif (str_contains($youtubeParts['path'] ?? '', '/shorts/')) {
                $segments = explode('/shorts/', $youtubeParts['path']);
                if (!empty($segments[1])) {
                    $youtubeEmbed = 'https://www.youtube.com/embed/' . trim($segments[1], '/');
                }
            }
        }
    }

    $socialLinks = collect([
        ['label' => 'Instagram', 'url' => $instagramUrl, 'icon' => 'fab fa-instagram'],
        ['label' => 'Facebook', 'url' => $facebookUrl, 'icon' => 'fab fa-facebook-f'],
        ['label' => 'TikTok', 'url' => $tiktokUrl, 'icon' => 'fab fa-tiktok'],
        ['label' => 'Spotify', 'url' => $spotifyUrl, 'icon' => 'fab fa-spotify'],
        ['label' => 'SoundCloud', 'url' => $soundcloudUrl, 'icon' => 'fab fa-soundcloud'],
        ['label' => 'YouTube', 'url' => $youtubeUrl, 'icon' => 'fab fa-youtube'],
        ['label' => 'Twitter', 'url' => $twitterUrl, 'icon' => 'fab fa-twitter'],
        ['label' => 'LinkedIn', 'url' => $linkedinUrl, 'icon' => 'fab fa-linkedin-in'],
    ])->filter(fn($item) => filled($item['url']))->values();
@endphp

@section('pageHeading')
    {{ $artist->name }}
@endsection

@section('meta-keywords', "{$artist->name}, artist profile, press kit")
@section('meta-description', strip_tags((string) $artist->details))
@section('og-title', $artist->name . ' | Artist Profile')
@section('og-description', strip_tags((string) $artist->details))
@section('og-image', $artist->cover_photo_url ?: $artist->photo_url)

@section('custom-style')
    <style>
        .artist-press-hero {
            position: relative;
            padding: 140px 0 110px;
            background:
                linear-gradient(180deg, rgba(8, 5, 14, 0.28), rgba(12, 7, 19, 0.86)),
                radial-gradient(circle at top right, rgba(236, 72, 153, 0.20), transparent 28%),
                linear-gradient(180deg, rgba(18, 12, 28, 0.12), rgba(18, 12, 28, 0.9)),
                url('{{ $coverPhoto }}') center/cover no-repeat;
            overflow: hidden;
        }

        .artist-press-hero::after {
            position: absolute;
            inset: auto 0 0;
            height: 130px;
            content: '';
            background: linear-gradient(180deg, rgba(18, 12, 28, 0), #161022 90%);
        }

        .artist-press-shell {
            position: relative;
            z-index: 1;
        }

        .artist-press-avatar {
            width: 134px;
            height: 134px;
            border-radius: 34px;
            object-fit: cover;
            border: 4px solid rgba(255, 255, 255, 0.16);
            box-shadow: 0 24px 70px rgba(236, 72, 153, 0.22);
            background: rgba(255, 255, 255, 0.04);
        }

        .artist-press-kicker {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 10px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.12);
            color: rgba(255, 255, 255, 0.72);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .artist-press-title {
            max-width: 840px;
            margin: 22px 0 12px;
            font-size: clamp(38px, 5vw, 68px);
            line-height: 0.95;
            letter-spacing: -0.04em;
            font-weight: 800;
        }

        .artist-press-handle {
            color: rgba(216, 182, 255, 0.92);
            font-size: 19px;
            font-weight: 700;
        }

        .artist-press-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 22px;
        }

        .artist-press-meta__chip {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.10);
            color: rgba(255, 255, 255, 0.84);
            font-weight: 600;
        }

        .artist-press-summary {
            margin-top: 28px;
            max-width: 760px;
            color: rgba(255, 255, 255, 0.74);
            font-size: 16px;
            line-height: 1.8;
        }

        .artist-press-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.65fr) minmax(300px, 0.95fr);
            gap: 28px;
            align-items: start;
        }

        .artist-press-card {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 28px;
            padding: 28px;
            box-shadow: 0 18px 42px rgba(6, 3, 10, 0.16);
        }

        .artist-press-card__title {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .artist-press-card__sub {
            color: rgba(255, 255, 255, 0.6);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .artist-press-links {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .artist-press-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: #fff;
            font-weight: 700;
        }

        .artist-press-link:hover {
            color: #fff;
            transform: translateY(-1px);
            background: rgba(255, 255, 255, 0.08);
        }

        .artist-press-embed {
            overflow: hidden;
            border-radius: 22px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.03);
        }

        .artist-press-embed + .artist-press-embed {
            margin-top: 16px;
        }

        .artist-press-embed iframe {
            width: 100%;
            border: 0;
        }

        .artist-press-facts {
            display: grid;
            gap: 14px;
        }

        .artist-press-cta {
            margin-top: 18px;
            padding: 20px;
            border-radius: 22px;
            background: linear-gradient(135deg, rgba(236, 72, 153, 0.18), rgba(124, 58, 237, 0.18));
            border: 1px solid rgba(255, 255, 255, 0.10);
        }

        .artist-press-cta__title {
            color: #fff;
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .artist-press-cta__copy {
            color: rgba(255, 255, 255, 0.72);
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 16px;
        }

        .artist-press-cta__button {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 13px 18px;
            border-radius: 999px;
            background: #fff;
            color: #161022;
            font-weight: 800;
        }

        .artist-press-cta__button:hover {
            color: #161022;
            transform: translateY(-1px);
        }

        .artist-press-fact {
            padding: 16px 18px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .artist-press-fact__label {
            display: block;
            color: rgba(255, 255, 255, 0.46);
            font-size: 11px;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .artist-press-fact__value {
            color: #fff;
            font-size: 16px;
            font-weight: 700;
            line-height: 1.45;
        }

        .artist-press-events {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .artist-press-gallery {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
        }

        .artist-press-gallery__item {
            overflow: hidden;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.04);
        }

        .artist-press-gallery__item img {
            width: 100%;
            aspect-ratio: 1.05;
            object-fit: cover;
            display: block;
        }

        .artist-press-event {
            overflow: hidden;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .artist-press-event__thumb {
            width: 100%;
            aspect-ratio: 1.35;
            object-fit: cover;
            display: block;
        }

        .artist-press-event__body {
            padding: 18px;
        }

        .artist-press-event__meta {
            color: rgba(255, 255, 255, 0.52);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.14em;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .artist-press-empty {
            padding: 24px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.03);
            border: 1px dashed rgba(255, 255, 255, 0.12);
            color: rgba(255, 255, 255, 0.58);
        }

        @media (max-width: 991.98px) {
            .artist-press-grid {
                grid-template-columns: 1fr;
            }

            .artist-press-links,
            .artist-press-events,
            .artist-press-gallery {
                grid-template-columns: 1fr;
            }

            .artist-press-hero {
                padding-top: 120px;
                padding-bottom: 92px;
            }
        }
    </style>
@endsection

@section('hero-section')
    <section class="artist-press-hero">
        <div class="container artist-press-shell">
            <div class="artist-press-kicker">
                <span>Artist Profile</span>
                <span>Press Surface</span>
            </div>

            <div class="d-flex flex-wrap align-items-end mt-4" style="gap: 24px;">
                <img class="artist-press-avatar" src="{{ $photo }}" alt="{{ $artist->name }}">
                <div>
                    <h1 class="artist-press-title text-white">{{ $artist->name }}</h1>
                    @if (!empty($artist->username))
                        <div class="artist-press-handle">{{ str_starts_with($artist->username, '@') ? $artist->username : '@' . $artist->username }}</div>
                    @endif
                </div>
            </div>

            <div class="artist-press-meta">
                @foreach ($genres as $genre)
                    <span class="artist-press-meta__chip"><i class="fas fa-wave-square"></i>{{ $genre }}</span>
                @endforeach
                @if ($location !== '')
                    <span class="artist-press-meta__chip"><i class="fas fa-map-marker-alt"></i>{{ $location }}</span>
                @endif
                @if (!empty($artist->created_at))
                    <span class="artist-press-meta__chip"><i class="far fa-calendar-alt"></i>{{ __('Member since') }} {{ date('M Y', strtotime($artist->created_at)) }}</span>
                @endif
            </div>

            @if (!empty($artist->details))
                <div class="artist-press-summary">
                    {!! nl2br(e($artist->details)) !!}
                </div>
            @endif
        </div>
    </section>
@endsection

@section('content')
    <section class="author-area py-120 rpy-100">
        <div class="container">
            <div class="artist-press-grid">
                <div>
                    <div class="artist-press-card">
                        <div class="artist-press-card__title">{{ __('Music & Media') }}</div>
                        <div class="artist-press-card__sub">
                            {{ __('Use this section as a lightweight press kit: streaming links, media touchpoints and public discovery channels in one place.') }}
                        </div>

                        @if ($spotifyEmbed || $soundcloudEmbed || $youtubeEmbed)
                            @if ($spotifyEmbed)
                                <div class="artist-press-embed">
                                    <iframe src="{{ $spotifyEmbed }}" height="152" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>
                                </div>
                            @endif

                            @if ($soundcloudEmbed)
                                <div class="artist-press-embed">
                                    <iframe src="{{ $soundcloudEmbed }}" height="280" allow="autoplay" loading="lazy"></iframe>
                                </div>
                            @endif

                            @if ($youtubeEmbed)
                                <div class="artist-press-embed">
                                    <iframe src="{{ $youtubeEmbed }}" height="320" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen loading="lazy"></iframe>
                                </div>
                            @endif
                        @else
                            <div class="artist-press-empty">
                                {{ __('No embeddable music or video links yet. Add Spotify, SoundCloud or a YouTube video to turn this profile into a stronger press surface.') }}
                            </div>
                        @endif

                        @if ($socialLinks->isNotEmpty())
                            <div class="artist-press-links mt-25">
                                @foreach ($socialLinks as $link)
                                    <a class="artist-press-link" href="{{ $link['url'] }}" target="_blank" rel="noopener">
                                        <i class="{{ $link['icon'] }}"></i>
                                        <span>{{ $link['label'] }}</span>
                                    </a>
                                @endforeach
                            </div>
                        @endif
                    </div>

                    <div class="artist-press-card mt-30">
                        <div class="artist-press-card__title">{{ __('Press Gallery') }}</div>
                        <div class="artist-press-card__sub">
                            {{ __('Portraits, live shots and visual cues that help the artist profile read like a usable press surface.') }}
                        </div>

                        @if ($gallery->isNotEmpty())
                            <div class="artist-press-gallery">
                                @foreach ($gallery as $image)
                                    <div class="artist-press-gallery__item">
                                        <img src="{{ $image }}" alt="{{ $artist->name }}">
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="artist-press-empty">
                                {{ __('No press gallery uploaded yet.') }}
                            </div>
                        @endif
                    </div>

                    <div class="artist-press-card mt-30">
                        <div class="artist-press-card__title">{{ __('Upcoming & Featured Events') }}</div>
                        <div class="artist-press-card__sub">
                            {{ __('A quick snapshot of where the artist is showing up next. This gives promoters, venues and press a simple activity read.') }}
                        </div>

                        @if (count($events) > 0)
                            <div class="artist-press-events">
                                @foreach ($events as $event)
                                    <article class="artist-press-event">
                                        <a href="{{ $event->event_url }}">
                                            <img class="artist-press-event__thumb" src="{{ $event->thumbnail_url }}" alt="{{ $event->title }}">
                                        </a>
                                        <div class="artist-press-event__body">
                                            <div class="artist-press-event__meta">
                                                {{ $event->is_past ? __('Past Event') : __('Upcoming') }}
                                                @if ($event->date)
                                                    • {{ \Carbon\Carbon::parse($event->date)->translatedFormat('d M Y') }}
                                                @endif
                                            </div>
                                            <h5 class="mb-10">
                                                <a href="{{ $event->event_url }}">
                                                    {{ $event->title }}
                                                </a>
                                            </h5>
                                            <div class="text-white-50 small">
                                                <i class="fas fa-map-marker-alt mr-2"></i>{{ $event->location ?: __('Online') }}
                                            </div>
                                        </div>
                                    </article>
                                @endforeach
                            </div>
                        @else
                            <div class="artist-press-empty">
                                {{ __('No upcoming events are published for this artist yet.') }}
                            </div>
                        @endif
                    </div>
                </div>

                <div>
                    <div class="artist-press-card">
                        <div class="artist-press-card__title">{{ __('Press Notes') }}</div>
                        <div class="artist-press-card__sub">
                            {{ __('A simple, readable summary for promoters, brands, venues or editors reviewing the profile quickly.') }}
                        </div>

                        <div class="artist-press-facts">
                            <div class="artist-press-fact">
                                <span class="artist-press-fact__label">{{ __('Stage Name') }}</span>
                                <div class="artist-press-fact__value">{{ $artist->name }}</div>
                            </div>

                            @if ($genres->isNotEmpty())
                                <div class="artist-press-fact">
                                    <span class="artist-press-fact__label">{{ __('Genres') }}</span>
                                    <div class="artist-press-fact__value">{{ $genres->implode(', ') }}</div>
                                </div>
                            @endif

                            @if ($location !== '')
                                <div class="artist-press-fact">
                                    <span class="artist-press-fact__label">{{ __('Based In') }}</span>
                                    <div class="artist-press-fact__value">{{ $location }}</div>
                                </div>
                            @endif

                            <div class="artist-press-fact">
                                <span class="artist-press-fact__label">{{ __('Primary Contact') }}</span>
                                <div class="artist-press-fact__value">{{ __('Duty chat and public media links') }}</div>
                            </div>

                            @if ($bookingNotes !== '')
                                <div class="artist-press-fact">
                                    <span class="artist-press-fact__label">{{ __('For Promoters & Venues') }}</span>
                                    <div class="artist-press-fact__value">{{ $bookingNotes }}</div>
                                </div>
                            @endif

                            <div class="artist-press-fact">
                                <span class="artist-press-fact__label">{{ __('Profile Use') }}</span>
                                <div class="artist-press-fact__value">{{ __('Public discovery, music preview and lightweight digital press kit') }}</div>
                            </div>
                        </div>

                        <div class="artist-press-cta">
                            <div class="artist-press-cta__title">{{ __('Book / Contact') }}</div>
                            <div class="artist-press-cta__copy">
                                {{ __('The primary contact channel for this artist is Duty chat. Open the app to start a booking or collaboration conversation.') }}
                            </div>
                            <a class="artist-press-cta__button" href="{{ route('frontend.download_app', ['surface' => 'artist']) }}">
                                <i class="fas fa-comment-dots"></i>
                                <span>{{ __('Open in Duty') }}</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
@endsection
