@extends('frontend.layout')
@section('pageHeading')
    {{ $content->title }}
@endsection

@php
    $og_title = $content->title;
    $og_description = strip_tags($content->description);
    $og_image = asset('assets/admin/img/event/thumbnail/' . $content->thumbnail);
    $heroEventDate = $content->date_type == 'multiple' ? eventLatestDates($content->id) : null;
    $detailDate = $content->date_type == 'multiple' ? strtotime(optional($heroEventDate)->start_date) : strtotime($content->start_date);
    $detailNow = \Carbon\Carbon::now()->timezone($websiteInfo->timezone)->translatedFormat('Y-m-d H:i:s');
    $heroStartDateTime = $content->date_type == 'multiple'
        ? optional($heroEventDate)->start_date_time
        : $content->start_date . ' ' . $content->start_time;
    $heroEndDateTime = $content->date_type == 'multiple'
        ? optional(eventLastEndDates($content->id))->end_date_time
        : $content->end_date . ' ' . $content->end_time;
    $heroStatusLabel = __('Live');
    $heroStatusClass = 'is-live';
    if ($heroStartDateTime && $heroStartDateTime >= $detailNow) {
        $heroStatusLabel = __('Upcoming');
        $heroStatusClass = 'is-upcoming';
    } elseif ($heroEndDateTime && $heroEndDateTime < $detailNow) {
        $heroStatusLabel = __('Over');
        $heroStatusClass = 'is-over';
    }
    $heroOrganizerName = $organizer_profile['organizer_name'] ?? ($organizer_profile['username'] ?? null);
    $heroOrganizerPhoto = $organizer_profile['photo'] ?? null;
    $heroVenueName = $venue_summary['name'] ?? null;
    $heroVenueAddress = $venue_summary['address'] ?? $content->address;
    $heroLineupCount = ($lineup ?? collect())->count() > 0 ? ($lineup ?? collect())->count() : count($artists ?? []);
    $appDownloadUrl = route('frontend.download_app', ['surface' => 'event', 'event' => $content->id]);
@endphp

@section('meta-keywords', "{{ $content->meta_keywords }}")
@section('meta-description', "$content->meta_description")
@section('og-title', "$og_title")
@section('og-description', "$og_description")
@section('og-image', "$og_image")

@section('custom-style')
    <link rel="stylesheet" href="{{ asset('assets/admin/css/summernote-content.css') }}">
    <link rel="stylesheet" href="{{ asset('assets/front/css/slot.css') }}">
<<<<<<< Updated upstream
=======
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Manrope:wght@400;500;600;700;800&display=swap');

        .event-hero-web {
            position: relative;
            overflow: hidden;
            padding: 152px 0 48px;
            background:
                radial-gradient(circle at 10% 20%, rgba(140, 37, 244, 0.24), transparent 24%),
                radial-gradient(circle at 82% 22%, rgba(255, 207, 90, 0.12), transparent 18%),
                linear-gradient(180deg, rgba(18, 10, 28, 0.72), rgba(18, 10, 28, 0.94)),
                url('{{ $og_image }}') center/cover;
        }

        .event-hero-web::before {
            position: absolute;
            inset: 0;
            content: '';
            background:
                linear-gradient(180deg, rgba(20, 11, 30, 0.34), rgba(20, 11, 30, 0.94)),
                linear-gradient(90deg, rgba(20, 11, 30, 0.76), rgba(20, 11, 30, 0.22));
        }

        .event-hero-web__grid {
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
            background-size: 34px 34px;
            mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.74), transparent 86%);
            opacity: 0.2;
        }

        .event-hero-web__content,
        .event-hero-web__poster {
            position: relative;
            z-index: 1;
        }

        .event-hero-web__crumbs {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
            margin-bottom: 18px;
            color: rgba(255, 255, 255, 0.72);
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.12em;
        }

        .event-hero-web__crumbs a {
            color: rgba(255, 255, 255, 0.78);
        }

        .event-hero-web__eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 10px 16px;
            margin-bottom: 18px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.84);
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.16em;
        }

        .event-hero-web__dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffcf5a, #8c25f4);
            box-shadow: 0 0 18px rgba(140, 37, 244, 0.44);
        }

        .event-hero-web__title {
            margin: 0;
            color: #fff !important;
            font-family: 'Outfit', sans-serif !important;
            font-size: clamp(2.7rem, 5vw, 5rem);
            line-height: 0.96;
            letter-spacing: -0.05em;
            max-width: 720px;
        }

        .event-hero-web__summary {
            max-width: 620px;
            margin: 20px 0 0;
            color: rgba(255, 255, 255, 0.72);
            font-size: 17px;
            line-height: 1.85;
        }

        .event-hero-web__chips,
        .event-hero-web__host-stats {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .event-hero-web__chips {
            margin-top: 24px;
        }

        .event-hero-web__chip,
        .event-detail-unified__price-accent {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.84);
            font-size: 13px;
            font-weight: 700;
        }

        .event-hero-web__chip--status.is-upcoming {
            color: #d9ecff;
            background: rgba(59, 130, 246, 0.18);
        }

        .event-hero-web__chip--status.is-live {
            color: #dbffd8;
            background: rgba(34, 197, 94, 0.16);
        }

        .event-hero-web__chip--status.is-over {
            color: #ffd8de;
            background: rgba(239, 68, 68, 0.16);
        }

        .event-hero-web__host {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-top: 24px;
            padding: 16px 18px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            max-width: 560px;
            backdrop-filter: blur(16px);
        }

        .event-hero-web__host-avatar {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            object-fit: cover;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.08);
        }

        .event-hero-web__host-label {
            color: rgba(255, 255, 255, 0.56);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.14em;
            text-transform: uppercase;
        }

        .event-hero-web__host-name {
            color: #fff;
            font-family: 'Outfit', sans-serif;
            font-size: 24px;
            font-weight: 700;
            line-height: 1.05;
        }

        .event-hero-web__host-copy {
            color: rgba(255, 255, 255, 0.72);
            line-height: 1.65;
            margin-top: 6px;
        }

        .event-hero-web__poster-card {
            overflow: hidden;
            border-radius: 30px;
            background: rgba(18, 10, 28, 0.66);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 26px 90px rgba(8, 3, 14, 0.4);
        }

        .event-hero-web__poster-frame {
            position: relative;
            aspect-ratio: 4 / 5;
            background:
                linear-gradient(180deg, rgba(25, 16, 34, 0.08), rgba(25, 16, 34, 0.94)),
                url('{{ $og_image }}') center/cover;
        }

        .event-hero-web__poster-badge,
        .event-hero-web__poster-footer {
            position: absolute;
            z-index: 1;
        }

        .event-hero-web__poster-badge {
            top: 18px;
            left: 18px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(10, 5, 17, 0.54);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.86);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            backdrop-filter: blur(14px);
        }

        .event-hero-web__poster-footer {
            right: 18px;
            bottom: 18px;
            left: 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            padding: 16px 18px;
            border-radius: 22px;
            background: rgba(10, 5, 17, 0.58);
            border: 1px solid rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(14px);
        }

        .event-hero-web__poster-meta {
            color: rgba(255, 255, 255, 0.72);
            font-size: 13px;
            line-height: 1.65;
        }

        .event-hero-web__poster-meta strong {
            display: block;
            color: #fff;
            font-size: 19px;
            font-weight: 800;
        }

        .event-hero-web__poster-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            padding: 18px;
            background: rgba(16, 10, 23, 0.94);
        }

        .event-hero-web__poster-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-height: 52px;
            padding: 0 18px;
            border-radius: 18px;
            text-decoration: none !important;
            font-weight: 800;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .event-hero-web__poster-action--primary {
            background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
            color: #fff;
            box-shadow: 0 16px 34px rgba(140, 37, 244, 0.28);
        }

        .event-hero-web__poster-action--secondary {
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.04);
            color: rgba(255, 255, 255, 0.84);
        }

        .event-detail-unified {
            background: linear-gradient(180deg, #1a1225 0%, #140d1f 100%);
            color: rgba(255, 255, 255, 0.82);
        }

        .event-detail-unified .event-top {
            align-items: center;
            margin-bottom: 30px;
            padding: 18px 20px;
            border-radius: 26px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-top-date {
            min-width: 104px;
            padding: 16px 14px;
            border-radius: 24px;
            background: linear-gradient(180deg, rgba(140, 37, 244, 0.22), rgba(30, 20, 42, 0.9));
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-month,
        .event-detail-unified .event-date {
            color: #fff;
        }

        .event-detail-unified__summary-label {
            display: inline-block;
            margin-bottom: 10px;
            color: rgba(199, 156, 255, 0.94);
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.18em;
        }

        .event-detail-unified__app-note {
            margin-top: 14px;
            padding: 14px 16px;
            border-radius: 18px;
            background: rgba(140, 37, 244, 0.08);
            border: 1px solid rgba(140, 37, 244, 0.2);
            color: rgba(255, 255, 255, 0.78);
            font-size: 14px;
            line-height: 1.75;
        }

        .event-detail-unified__app-note a {
            color: #fff;
            font-weight: 800;
        }

        .event-detail-unified .event-details-header ul {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin: 0;
        }

        .event-detail-unified .event-details-header li {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 11px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
            color: rgba(255, 255, 255, 0.82);
        }

        .event-detail-unified .event-details-image {
            position: relative;
            overflow: hidden;
            border-radius: 30px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 26px 80px rgba(8, 3, 14, 0.28);
        }

        .event-detail-unified .event-details-images img,
        .event-detail-unified .swiper-slide img {
            min-height: 420px;
            max-height: 560px;
            width: 100%;
            object-fit: cover;
        }

        .event-detail-unified .event-details-image .buttons {
            position: absolute;
            top: 18px;
            right: 18px;
            display: flex;
            gap: 10px;
            z-index: 4;
        }

        .event-detail-unified .event-details-image .buttons a {
            width: 46px;
            height: 46px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 16px;
            background: rgba(10, 5, 17, 0.58);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: #fff;
            backdrop-filter: blur(12px);
        }

        .event-detail-unified .event-details-content-inner,
        .event-detail-unified .event-details-information {
            padding: 26px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 22px 60px rgba(8, 3, 14, 0.18);
        }

        .event-detail-unified .event-details-content-inner {
            margin-bottom: 18px;
        }

        .event-detail-unified .event-info span a,
        .event-detail-unified .event-info span {
            color: #d7adff;
            font-weight: 700;
        }

        .event-detail-unified .inner-title,
        .event-detail-unified h3 {
            color: #fff !important;
            font-family: 'Outfit', sans-serif !important;
            font-size: 30px;
            letter-spacing: -0.03em;
        }

        .event-detail-unified .summernote-content,
        .event-detail-unified .summernote-content *,
        .event-detail-unified .event-details-content-inner,
        .event-detail-unified .event-details-content-inner p,
        .event-detail-unified .event-details-content-inner li,
        .event-detail-unified .event-details-content-inner strong,
        .event-detail-unified .event-details-content-inner b {
            color: rgba(255, 255, 255, 0.78) !important;
        }

        .event-detail-unified .summernote-content h1,
        .event-detail-unified .summernote-content h2,
        .event-detail-unified .summernote-content h3,
        .event-detail-unified .summernote-content h4,
        .event-detail-unified .summernote-content h5,
        .event-detail-unified .summernote-content h6 {
            color: #fff !important;
            font-family: 'Outfit', sans-serif !important;
        }

        .event-detail-unified .our-location,
        .event-detail-unified .our-location iframe {
            border-radius: 26px;
            overflow: hidden;
        }

        .event-detail-unified .sidebar-sticky {
            top: 108px;
        }

        .event-detail-unified .event-details-information {
            color: rgba(255, 255, 255, 0.82);
        }

        .event-detail-unified .event-details-information b,
        .event-detail-unified .event-details-information p,
        .event-detail-unified .event-details-information strong,
        .event-detail-unified .event-details-information h6,
        .event-detail-unified .event-details-information .h4,
        .event-detail-unified .event-details-information label,
        .event-detail-unified .event-details-information .author h6,
        .event-detail-unified .event-details-information .author h6 a,
        .event-detail-unified .event-details-information .price-count h6,
        .event-detail-unified .event-details-information .total,
        .event-detail-unified .event-details-information .total span,
        .event-detail-unified .event-details-information .click-show .show-content,
        .event-detail-unified .event-details-information .click-show .show-content *,
        .event-detail-unified .event-details-information .price-count h6 *,
        .event-detail-unified .event-details-information .price-count > h6,
        .event-detail-unified .event-details-information .price-count > h6 *,
        .event-detail-unified .event-details-information .price-count p,
        .event-detail-unified .event-details-information .price-count p *,
        .event-detail-unified .event-details-information .mb-0 strong,
        .event-detail-unified .event-details-information .mb-0 strong *,
        .event-detail-unified .event-details-information .dropdown-toggle,
        .event-detail-unified .event-details-information .dropdown-item {
            color: #f6f1ff !important;
        }

        .event-detail-unified .event-details-information .author a,
        .event-detail-unified .event-details-information .read-more-btn,
        .event-detail-unified .event-details-information .dropdown-toggle {
            color: #c79cff;
        }

        .event-detail-unified .event-details-information .dropdown-toggle {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 700;
        }

        .event-detail-unified .event-details-information .dropdown-menu {
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 16px 32px rgba(8, 3, 14, 0.24);
            border-radius: 14px;
            padding: 0.45rem;
            background: rgba(15, 9, 22, 0.98);
        }

        .event-detail-unified .event-details-information .dropdown-item {
            border-radius: 10px;
            font-weight: 600;
        }

        .event-detail-unified .event-details-information .dropdown-item:hover,
        .event-detail-unified .event-details-information .dropdown-item:focus {
            background: rgba(140, 37, 244, 0.16);
            color: #fff;
        }

        .event-detail-unified .event-details-information hr,
        .event-detail-unified hr {
            border-top-color: rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-details-information .price-count h6 {
            font-size: 1.38rem;
            font-weight: 800;
        }

        .event-detail-unified .event-details-information .price-count h6 del {
            color: rgba(255, 255, 255, 0.4) !important;
        }

        .event-detail-unified .event-details-information .badge.badge-warning {
            color: #ffdcb7 !important;
            background: rgba(217, 119, 6, 0.18);
        }

        .event-detail-unified .event-details-information .quantity-input {
            border-radius: 18px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-details-information .quantity-input button,
        .event-detail-unified .event-details-information .quantity-input input {
            background: rgba(255, 255, 255, 0.04);
            color: #fff;
            border-color: rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-details-information .quantity-input button:hover {
            background: rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .event-details-information .quantity-input input {
            font-weight: 800;
        }

        .event-detail-unified .event-details-information .text-warning {
            color: #ffcf5a !important;
        }

        .event-detail-unified .event-details-information .total {
            align-items: center;
            gap: 0.75rem;
            padding-top: 0.5rem;
        }

        .event-detail-unified .event-details-information .theme-btn {
            color: #ffffff !important;
            font-weight: 800;
            min-height: 58px;
            border-radius: 18px;
            background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
            box-shadow: 0 18px 34px rgba(140, 37, 244, 0.22);
        }

        .event-detail-unified .author {
            padding: 12px 14px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .event-detail-unified .author img {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            object-fit: cover;
        }

        .event-detail-unified .releted-event-header h3 {
            color: #fff;
            font-family: 'Outfit', sans-serif !important;
            font-size: 30px;
            letter-spacing: -0.03em;
        }

        .event-detail-unified .event-item {
            overflow: hidden;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 18px 50px rgba(8, 3, 14, 0.18);
        }

        .event-detail-unified .event-item .event-content,
        .event-detail-unified .event-item .event-image {
            background: transparent;
        }

        .event-detail-unified .event-item .event-content {
            padding: 18px;
        }

        .event-detail-unified .event-item h5 a,
        .event-detail-unified .event-item .organizer,
        .event-detail-unified .event-item p,
        .event-detail-unified .event-item .location span,
        .event-detail-unified .event-item .time-info li,
        .event-detail-unified .event-item .price {
            color: rgba(255, 255, 255, 0.82) !important;
        }

        .event-detail-unified .event-item h5 a {
            color: #fff !important;
        }

        @media (max-width: 1199.98px) {
            .event-hero-web {
                padding-top: 138px;
            }
        }

        @media (max-width: 767.98px) {
            .event-hero-web {
                padding: 128px 0 40px;
            }

            .event-hero-web__host,
            .event-hero-web__poster-footer,
            .event-detail-unified .event-top {
                flex-direction: column;
                align-items: flex-start;
            }

            .event-hero-web__poster-actions {
                flex-direction: column;
            }

            .event-hero-web__poster-action {
                width: 100%;
            }
        }
    </style>
>>>>>>> Stashed changes
@endsection

@section('hero-section')
    <section class="event-hero-web">
        <div class="event-hero-web__grid"></div>
        <div class="container">
            <div class="row align-items-end">
                <div class="col-xl-7 event-hero-web__content">
                    <div class="event-hero-web__crumbs">
                        <a href="{{ route('index') }}">{{ __('Home') }}</a>
                        <span>/</span>
                        <span>{{ __('Event Detail') }}</span>
                    </div>

                    <span class="event-hero-web__eyebrow">
                        <span class="event-hero-web__dot"></span>
                        {{ $content->name ?? __('Event') }}
                    </span>

                    <h1 class="event-hero-web__title">{{ $content->title }}</h1>

                    <p class="event-hero-web__summary">
                        {{ \Illuminate\Support\Str::limit(strip_tags($content->description), 220) }}
                    </p>

                    <div class="event-hero-web__chips">
                        <span class="event-hero-web__chip event-hero-web__chip--status {{ $heroStatusClass }}">
                            <i class="fas fa-signal"></i>
                            {{ $heroStatusLabel }}
                        </span>
                        <span class="event-hero-web__chip">
                            <i class="far fa-calendar-alt"></i>
                            {{ $detailDate ? \Carbon\Carbon::parse($detailDate)->timezone($websiteInfo->timezone)->translatedFormat('D, d M Y') : __('Date TBA') }}
                        </span>
                        <span class="event-hero-web__chip">
                            <i class="far fa-clock"></i>
                            {{ $content->date_type == 'multiple' ? optional($heroEventDate)->duration : $content->duration }}
                        </span>
                        <span class="event-hero-web__chip">
                            <i class="fas fa-map-marker-alt"></i>
                            {{ $content->event_type == 'online' ? __('Online Event') : ($heroVenueAddress ?: __('Venue TBA')) }}
                        </span>
                        <span class="event-hero-web__chip">
                            <i class="fas fa-ticket-alt"></i>
                            {{ number_format($tickets_count) }} {{ __('ticket options') }}
                        </span>
                        @if ($heroLineupCount > 0)
                            <span class="event-hero-web__chip">
                                <i class="fas fa-music"></i>
                                {{ number_format($heroLineupCount) }} {{ __('artists') }}
                            </span>
                        @endif
                    </div>

                    <div class="event-hero-web__host">
                        <img class="event-hero-web__host-avatar"
                            src="{{ $heroOrganizerPhoto ?: asset('assets/front/images/user.png') }}"
                            alt="{{ $heroOrganizerName ?: __('Organizer') }}">
                        <div>
                            <div class="event-hero-web__host-label">{{ __('Hosted by') }}</div>
                            <div class="event-hero-web__host-name">{{ $heroOrganizerName ?: __('Duty host') }}</div>
                            <div class="event-hero-web__host-copy">
                                @if ($heroVenueName)
                                    {{ $heroVenueName }}
                                @else
                                    {{ __('Discover the full lineup, venue and ticket options from the same immersive event surface.') }}
                                @endif
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-5 event-hero-web__poster" data-aos="fade-left" data-aos-delay="120">
                    <div class="event-hero-web__poster-card">
                        <div class="event-hero-web__poster-frame">
                            <span class="event-hero-web__poster-badge">{{ $content->event_type == 'online' ? __('Online') : __('In person') }}</span>
                            <div class="event-hero-web__poster-footer">
                                <div class="event-hero-web__poster-meta">
                                    <strong>{{ $heroStatusLabel }}</strong>
                                    {{ $heroVenueAddress ?: __('Location will be announced') }}
                                </div>
                                <div class="event-detail-unified__price-accent">
                                    <i class="fas fa-bolt"></i>
                                    {{ __('Use the app for the final ticket flow') }}
                                </div>
                            </div>
                        </div>
                        <div class="event-hero-web__poster-actions">
                            <a href="{{ $appDownloadUrl }}" class="event-hero-web__poster-action event-hero-web__poster-action--primary">
                                {{ __('Get the app for tickets') }}
                                <i class="fas fa-arrow-right"></i>
                            </a>
                            <a href="#ticket-panel" class="event-hero-web__poster-action event-hero-web__poster-action--secondary">
                                {{ __('Preview ticket options') }}
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
@endsection
@section('content')
    <!-- Event Page Start -->
    @php
        $map_address = preg_replace('/\s+/u', ' ', trim($content->address));
        $map_address = str_replace('/', ' ', $map_address);
        $map_address = str_replace('?', ' ', $map_address);
        $map_address = str_replace(',', ' ', $map_address);
    @endphp
    <section id="event-story" class="event-details-section event-detail-unified pt-110 rpt-90 pb-90 rpb-70">
        <div class="container">
            <div class="event-details-content">
                <div class="event-top d-flex flex-wrap-wrap has-gap">
                    @php
                        if ($content->date_type == 'multiple') {
                            $event_date = eventLatestDates($content->id);
                            $date = strtotime(@$event_date->start_date);
                        } else {
                            $date = strtotime($content->start_date);
                        }
                    @endphp
                    @if ($content->date_type != 'multiple')
                        <div class="event-top-date">
                            <div class="event-month">
                                {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->translatedFormat('M') }}
                            </div>
                            <div class="event-date">
                                {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->translatedFormat('d') }}
                            </div>
                        </div>
                    @endif
                    <div class="event-bottom-content">
                        @php
                            if ($content->date_type == 'multiple') {
                                $event_date = eventLatestDates($content->id);
                                $startDateTime = @$event_date->start_date_time;
                                $endDateTime = @$event_date->end_date_time;
                                //for multiple get last end date
                                $last_end_date = eventLastEndDates($content->id);
                                $last_end_date = $last_end_date->end_date_time;

                                $now_time = \Carbon\Carbon::now()
                                    ->timezone($websiteInfo->timezone)
                                    ->translatedFormat('Y-m-d H:i:s');
                            } else {
                                $now_time = \Carbon\Carbon::now()
                                    ->timezone($websiteInfo->timezone)
                                    ->translatedFormat('Y-m-d H:i:s');
                                $startDateTime = $content->start_date . ' ' . $content->start_time;
                                $endDateTime = $content->end_date . ' ' . $content->end_time;
                            }
                            $over = false;

                        @endphp
                        @if ($content->date_type == 'single' && $content->countdown_status == 1)
                            @if ($endDateTime < $now_time)
                                @php
                                    $over = true;
                                @endphp
                            @endif
                            <span class="event-detail-unified__summary-label">{{ __('Quick facts') }}</span>
                        @elseif ($content->date_type == 'multiple')
                            @if ($startDateTime < $now_time && $last_end_date < $now_time)
                                @php
                                    $over = true;
                                @endphp
                            @endif
                            <span class="event-detail-unified__summary-label">{{ __('Quick facts') }}</span>
                        @else
                            <span class="event-detail-unified__summary-label">{{ __('Quick facts') }}</span>
                        @endif

                        <div class="event-details-header mb-25">
                            <ul>
                                <li><i class="far fa-calendar-alt"></i>
                                    {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->translatedFormat('D, dS M Y') }}
                                </li>

                                <li><i class="far fa-clock"></i>
                                    {{ $content->date_type == 'multiple' ? @$event_date->duration : $content->duration }}
                                </li>
                                @if ($content->event_type == 'venue')
                                    <li><i class="fas fa-map-marker-alt"></i>
                                        {{ $content->address }}
                                    </li>
                                @else
                                    <li><i class="fas fa-map-marker-alt"></i> {{ __('Online') }}</li>
                                @endif
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="event-details-image mb-50">
                    {{-- <div class="event-details-images">
                        @foreach ($images as $item)
                            <div class="slide-item">
                                <a href="{{ asset('assets/admin/img/event-gallery/' . $item->image) }}">
                                    <img src="{{ asset('assets/admin/img/event-gallery/' . $item->image) }}"
                                        alt="Event Details">
                                </a>
                            </div>
                        @endforeach
                    </div> --}}
                    <div class="swiper event-details-images">
                        <div class="swiper-wrapper">
                            @foreach ($images as $item)
                                <div class="swiper-slide">
                                    <a href="{{ asset('assets/admin/img/event-gallery/' . $item->image) }}">
                                        <img src="{{ asset('assets/admin/img/event-gallery/' . $item->image) }}"
                                            alt="Event Details">
                                    </a>
                                </div>
                            @endforeach
                        </div>
                        <div class="event-details-slide-prev"><i class="fas fa-chevron-left"></i></div>
                        <div class="event-details-slide-next"><i class="fas fa-chevron-right"></i></div>
                    </div>

                    <div class="buttons">
                        @if (Auth::guard('customer')->check())
                            @php
                                $customer_id = Auth::guard('customer')->user()->id;
                                $event_id = $content->id;
                                $checkWishList = checkWishList($event_id, $customer_id);
                            @endphp
                        @else
                            @php
                                $checkWishList = false;
                            @endphp
                        @endif
                        @if ($content->event_type != 'online')
                            <a href="javascript:void(0)" data-toggle="modal" data-target=".bd-example-modal-lg">
                                <i class="fas fa-map-marker-alt m-0"></i>
                            </a>
                        @endif
                        <a href="{{ $checkWishList == false ? route('addto.wishlist', $content->id) : route('remove.wishlist', $content->id) }}"
                            class="{{ $checkWishList == true ? 'text-success' : '' }}"><i class="fas fa-bookmark"></i></a>
                        <a href="javascript:void(0)" data-toggle="modal" data-target=".share-event">
                            <i class="fas fa-share-alt"></i></a>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-7">
                        <div class="event-details-content-inner">
                            <div class="event-info d-flex align-items-center mb-1">
                                <span>
                                    <a
                                        href="{{ route('events', ['category' => $content->slug]) }}">{{ $content->name }}</a>
                                </span>
                            </div>
                            @if (Session::has('paypal_error'))
                                <div class="alert alert-danger">{{ Session::get('paypal_error') }}</div>
                            @endif
                            @php
                                Session::put('paypal_error', null);
                            @endphp
                            <h3 class="inner-title mb-25">{{ __('Description') }}</h3>

                            <div class="summernote-content">
                                {!! $content->description !!}
                            </div>

                            @if ($content->event_type != 'online')
                                <h3 class="inner-title mb-30">{{ __('Map') }}</h3>
                                <div class="our-location mb-50">
                                    <iframe
                                        src="//maps.google.com/maps?width=100%25&amp;height=385&amp;hl=en&amp;q={{ $map_address }}&amp;t=&amp;z=14&amp;ie=UTF8&amp;iwloc=B&amp;output=embed"
                                        height="385" class="map-h" allowfullscreen="" loading="lazy"></iframe>
                                </div>
                            @endif

                            @if (!empty($content->refund_policy))
                                <h3>{{ __('Return Policy') }}</h3>
                                <p>{{ @$content->refund_policy }}</p>
                            @endif

                        </div>
                    </div>
                    <div class="col-lg-5">
                        <div class="sidebar-sticky">
                            <form action="{{ route('check-out2') }}" method="post"
                                @if ($over == true) onsubmit="return false" @endif>
                                @csrf
                                <input type="hidden" name="event_id" value="{{ $content->id }}" id="">
<<<<<<< Updated upstream
                                <input type="hidden" name="pricing_type" value="{{ $content->pricing_type }}"
                                    id="">
                                <div class="event-details-information">
=======
                                <input type="hidden" name="pricing_type" value="{{ $content->pricing_type }}" id="">
                                <div id="ticket-panel" class="event-details-information">
>>>>>>> Stashed changes
                                    <input type="hidden" name="date_type" value="{{ $content->date_type }}">
                                    @if ($content->date_type == 'multiple')
                                        @php
                                            $dates = eventDates($content->id);
                                            $exp_dates = eventExpDates($content->id);
                                        @endphp

                                        <div class="form-group">
                                            <label for="">{{ __('Select Date') }}</label>
                                            <select name="event_date" id="" class="form-control">
                                                @if (count($dates) > 0)
                                                    @foreach ($dates as $date)
                                                        <option value="{{ FullDateTime($date->start_date_time) }}">
                                                            {{ FullDateTime($date->start_date_time) }}
                                                            ({{ timeZoneOffset($websiteInfo->timezone) }}
                                                            {{ __('GMT') }})
                                                        </option>
                                                    @endforeach
                                                @endif
                                                @if (count($exp_dates) > 0)
                                                    @foreach ($exp_dates as $exp_date)
                                                        <option disabled value="">
                                                            {{ FullDateTime($exp_date->start_date_time) }}
                                                            ({{ timeZoneOffset($websiteInfo->timezone) }}
                                                            {{ __('GMT') }})
                                                        </option>
                                                    @endforeach
                                                @endif
                                            </select>
                                            @error('event_date')
                                                <p class="text-danger">{{ $message }}</p>
                                            @enderror
                                        </div>
                                    @else
                                        <input type="hidden" name="event_date"
                                            value="{{ FullDateTime($content->start_date . $content->start_time) }}">
                                    @endif

                                    {{-- Count down start --}}
                                    @if ($content->date_type == 'single' && $content->countdown_status == 1)
                                        <div class="event-details-top">
                                            @if ($startDateTime >= $now_time)
                                                <b>{{ __('Event Starts In') }}</b>
                                                <hr>
                                                @php
                                                    $dt = Carbon\Carbon::parse($startDateTime);
                                                    $year = $dt->year;
                                                    $month = $dt->month;
                                                    $day = $dt->day;
                                                    $end_time = Carbon\Carbon::parse($startDateTime);
                                                    $hour = $end_time->hour;
                                                    $minute = $end_time->minute;
                                                    $now = str_replace(
                                                        '+00:00',
                                                        '.000' . timeZoneOffset($websiteInfo->timezone) . '00:00',
                                                        gmdate('c'),
                                                    );

                                                @endphp
                                                <div class="count-down mb-3" dir="ltr">
                                                    <div class="event-countdown" data-now="{{ $now }}"
                                                        data-year="{{ $year }}" data-month="{{ $month }}"
                                                        data-day="{{ $day }}" data-hour="{{ $hour }}"
                                                        data-minute="{{ $minute }}"
                                                        data-timezone="{{ timeZoneOffset($websiteInfo->timezone) }}">
                                                    </div>
                                                </div>
                                            @elseif ($startDateTime <= $endDateTime && $endDateTime >= $now_time)
                                                <p>{{ __('The Event is Running') }}</p>
                                            @else
                                                <p>{{ __('The Event is Over') }}</p>
                                            @endif
                                        </div>
                                    @endif

                                    {{-- Countdown end --}}
                                    <b>{{ __('Organised By') }}</b>
                                    <hr>
                                    @if ($organizer == '')
                                        @php
                                            $admin = App\Models\Admin::first();
                                        @endphp
                                        <div class="author">
                                            <a
                                                href="{{ route('frontend.organizer.details', [$admin->id, str_replace(' ', '-', $admin->username), 'admin' => 'true']) }}"><img
                                                    class="lazy"
                                                    data-src="{{ asset('assets/admin/img/admins/' . $admin->image) }}"
                                                    alt="Author"></a>
                                            <div class="content">
                                                <h6><a
                                                        href="{{ route('frontend.organizer.details', [$admin->id, str_replace(' ', '-', $admin->username), 'admin' => 'true']) }}">{{ $admin->username }}</a>
                                                </h6>
                                            </div>
                                        </div>
                                    @else
                                        <div class="author">
                                            <a
                                                href="{{ route('frontend.organizer.details', [$organizer->id, str_replace(' ', '-', $organizer->username)]) }}">
                                                @if ($organizer->photo != null)
                                                    <img class="lazy"
                                                        data-src="{{ asset('assets/admin/img/organizer-photo/' . $organizer->photo) }}"
                                                        alt="Author">
                                                @else
                                                    <img class="lazy"
                                                        data-src="{{ asset('assets/front/images/user.png') }}"
                                                        alt="Author">
                                                @endif

                                            </a>

                                            <div class="content">
                                                <h6><a
                                                        href="{{ route('frontend.organizer.details', [$organizer->id, str_replace(' ', '-', $organizer->username)]) }}">{{ @$organizer->organizer_info->name }}</a>
                                                </h6>
                                                <a
                                                    href="{{ route('frontend.organizer.details', [$organizer->id, str_replace(' ', '-', $organizer->username)]) }}">{{ __('View  Profile') }}</a>
                                            </div>
                                        </div>
                                    @endif
                                    @if ($content->address != null)
                                        <b><i class="fas fa-map-marker-alt"></i> {{ $content->address }}</b>
                                        <hr>
                                    @endif

                                    {{-- Add to calendar --}}
                                    @php
                                        $start_date = str_replace('-', '', $content->start_date);
                                        $start_time = str_replace(':', '', $content->start_time);
                                        $end_date = str_replace('-', '', $content->end_date);
                                        $end_time = str_replace(':', '', $content->end_time);
                                    @endphp
                                    <div class="dropdown show pt-4 pb-4">
                                        <a class="dropdown-toggle" href="#" role="button" id="dropdownMenuLink"
                                            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <i class="fas fa-calendar-alt"></i> {{ __('Add to Calendar') }}
                                        </a>

                                        <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                            <a target="_blank" class="dropdown-item"
                                                href="//calendar.google.com/calendar/u/0/r/eventedit?text={{ $content->title }}&dates={{ $start_date }}T{{ $start_time }}/{{ $end_date }}T{{ $end_time }}&ctz={{ $websiteInfo->timezone }}&details=For+details,+click+here:+{{ route('event.details', [$content->eventSlug, $content->id]) }}&location={{ $content->event_type == 'online' ? 'Online' : $content->address }}&sf=true">{{ __('Google Calendar') }}</a>
                                            <a target="_blank" class="dropdown-item"
                                                href="//calendar.yahoo.com/?v=60&view=d&type=20&TITLE={{ $content->title }}&ST={{ $start_date }}T{{ $start_time }}&ET={{ $end_date }}T{{ $end_time }}&DUR=9959&DESC=For%20details%2C%20click%20here%3A%20{{ route('event.details', [$content->eventSlug, $content->id]) }}&in_loc={{ $content->event_type == 'online' ? 'Online' : $content->address }}">{{ __('Yahoo') }}</a>
                                        </div>
                                    </div>

                                    <input type="hidden" id="seatIds" name="seatIds">
                                    <input type="hidden" id="seatData" name="seatData">
                                    <input type="hidden" id="seatPrice" name="seat_price">


                                    @if ($content->event_type == 'online' && $content->pricing_type == 'normal')

                                        @php
                                            $ticket = App\Models\Event\Ticket::where('event_id', $content->id)->first();
                                            $event_count = App\Models\Event\Ticket::where('event_id', $content->id)
                                                ->get()
                                                ->count();
                                            if ($ticket->ticket_available_type == 'limited') {
                                                $stock = $ticket->ticket_available;
                                            } else {
                                                $stock = 'unlimited';
                                            }
                                            //ticket purchase or not check
                                            if (
                                                Auth::guard('customer')->user() &&
                                                $ticket->max_ticket_buy_type == 'limited'
                                            ) {
                                                $purchase = isTicketPurchaseOnline(
                                                    $ticket->event_id,
                                                    $ticket->max_buy_ticket,
                                                );
                                            } else {
                                                $purchase = ['status' => 'false', 'p_qty' => 0];
                                            }
                                        @endphp
                                        @if ($ticket)

                                            <b>{{ __('Select Tickets') }}</b>
                                            <hr>
                                            <div class="price-count">
                                                <h6 dir="ltr">

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
                                                            <del>
                                                                {{ symbolPrice($ticket->price) }}
                                                            </del>
                                                        @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                            @php
                                                                $c_price =
                                                                    ($ticket->price *
                                                                        $ticket->early_bird_discount_amount) /
                                                                    100;
                                                                $calculate_price = $ticket->price - $c_price;
                                                            @endphp
                                                            {{ symbolPrice($calculate_price) }}
                                                            <del>
                                                                {{ symbolPrice($ticket->price) }}
                                                            </del>
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


                                                </h6>
                                                <div class="quantity-input">
                                                    <button class="quantity-down" type="button" id="quantityDown">
                                                        -
                                                    </button>
                                                    <input class="quantity" type="number" readonly value="0"
                                                        data-price="{{ $calculate_price }}"
                                                        data-max_buy_ticket="{{ $ticket->max_buy_ticket }}"
                                                        name="quantity" data-ticket_id="{{ $ticket->id }}"
                                                        data-stock="{{ $stock }}"
                                                        data-purchase="{{ $purchase['status'] }}"
                                                        data-p_qty="{{ $purchase['p_qty'] }}">
                                                    <button class="quantity-up" type="button" id="quantityUP">
                                                        +
                                                    </button>
                                                </div>



                                                @if ($ticket->early_bird_discount == 'enable')
                                                    @php
                                                        $discount_date = Carbon\Carbon::parse(
                                                            $ticket->early_bird_discount_date .
                                                                $ticket->early_bird_discount_time,
                                                        );
                                                    @endphp
                                                    @if (!$discount_date->isPast())
                                                        <p>{{ __('Discount available') . ' ' }} :
                                                            ({{ __('till') . ' ' }} :
                                                            <span
                                                                dir="ltr">{{ \Carbon\Carbon::parse($discount_date)->timezone($websiteInfo->timezone)->translatedFormat('Y/m/d h:i a') }}</span>)
                                                        </p>
                                                    @endif
                                                @endif


                                            </div>
                                            <p
                                                class="text-warning max_error_{{ $ticket->id }}{{ $ticket->max_ticket_buy_type == 'limited' ? $ticket->max_buy_ticket : '' }} ">
                                            </p>

                                        @endif
                                    @elseif($content->event_type == 'online' && $content->pricing_type == 'free')
                                        <b>{{ __('Select Tickets') }}</b>
                                        <hr>
                                        @php
                                            $ticket = App\Models\Event\Ticket::where('event_id', $content->id)->first();
                                            $event_count = App\Models\Event\Ticket::where('event_id', $content->id)
                                                ->get()
                                                ->count();

                                            if ($ticket->ticket_available_type == 'limited') {
                                                $stock = $ticket->ticket_available;
                                            } else {
                                                $stock = 'unlimited';
                                            }

                                            //ticket purchase or not check
                                            if (
                                                Auth::guard('customer')->user() &&
                                                $ticket->max_ticket_buy_type == 'limited'
                                            ) {
                                                $purchase = isTicketPurchaseOnline(
                                                    $ticket->event_id,
                                                    $ticket->max_buy_ticket,
                                                );
                                                $max_buy_ticket = $ticket->max_buy_ticket;
                                            } else {
                                                $purchase = ['status' => 'false', 'p_qty' => 0];
                                                $max_buy_ticket = 999999;
                                            }
                                        @endphp
                                        <div class="price-count">
                                            <h6>
                                                {{ __('Free') }}
                                            </h6>
                                            <div class="quantity-input">
                                                <button class="quantity-down" type="button" id="quantityDown">
                                                    -
                                                </button>
                                                <input class="quantity" readonly type="number" value="0"
                                                    data-price="{{ $content->price }}"
                                                    data-max_buy_ticket="{{ $max_buy_ticket }}" name="quantity"
                                                    data-ticket_id="{{ $ticket->id }}"
                                                    data-stock="{{ $stock }}"
                                                    data-purchase="{{ $purchase['status'] }}"
                                                    data-p_qty="{{ $purchase['p_qty'] }}">
                                                <button class="quantity-up" type="button" id="quantityUP">
                                                    +
                                                </button>
                                            </div>

                                        </div>
                                        <p
                                            class="text-warning max_error_{{ $ticket->id }}{{ $ticket->max_ticket_buy_type == 'limited' ? $ticket->max_buy_ticket : '' }} ">
                                        </p>
                                    @elseif($content->event_type == 'venue')
                                        @php
                                            $tickets = DB::table('tickets')->where('event_id', $content->id)->get();
                                        @endphp
                                        @if (count($tickets) > 0)
                                            <b>{{ __('Select Tickets') }}</b>
                                            <hr>
                                            @foreach ($tickets as $ticket)
                                                @if ($ticket->pricing_type == 'normal')
                                                    @php
                                                        if ($ticket->ticket_available_type == 'limited') {
                                                            $stock = $ticket->ticket_available;
                                                        } else {
                                                            $stock = 'unlimited';
                                                        }

                                                        //ticket purchase or not check
                                                        $ticket_content = App\Models\Event\TicketContent::where([
                                                            ['language_id', $currentLanguageInfo->id],
                                                            ['ticket_id', $ticket->id],
                                                        ])->first();

                                                        if (
                                                            Auth::guard('customer')->user() &&
                                                            $ticket->max_ticket_buy_type == 'limited'
                                                        ) {
                                                            $purchase = isTicketPurchaseVenue(
                                                                $ticket->event_id,
                                                                $ticket->max_buy_ticket,
                                                                $ticket->id,
                                                                @$ticket_content->title,
                                                            );
                                                        } else {
                                                            $purchase = ['status' => 'false', 'p_qty' => 0];
                                                        }

                                                    @endphp
                                                    <p class="mb-0"><strong>{{ @$ticket_content->title }}</strong></p>
                                                    <div class="click-show">
                                                        <div class="show-content">
                                                            {!! @$ticket_content->description !!}
                                                        </div>
                                                        @if (strlen(@$ticket_content->description) > 50)
                                                            <div class="read-more-btn">
                                                                <span>{{ __('Read more') }}</span>
                                                                <span>{{ __('Read less') }}</span>
                                                            </div>
                                                        @endif
                                                    </div>
                                                    <div class="price-count">
                                                        <h6 dir="ltr">
                                                            <!------- slot button-------->
                                                            @if (isset($ticket) && $ticket->normal_ticket_slot_enable == 1)
                                                                @php
                                                                    $slotItem = app(
                                                                        \App\Services\BookingServices::class,
                                                                    )->showSlot(
                                                                        $event_id,
                                                                        $ticket->id,
                                                                        $ticket->normal_ticket_slot_unique_id,
                                                                    );
                                                                    $slotPrice = $slotItem['price'];
                                                                @endphp
                                                                @if ($slotItem['available_seat'] == true)
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
                                                                                    $slotPrice -
                                                                                    $ticket->early_bird_discount_amount;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}
                                                                            <del>

                                                                                {{ symbolPrice($slotPrice) }}
                                                                            </del>
                                                                        @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                            @php
                                                                                $c_price =
                                                                                    ($slotPrice *
                                                                                        $ticket->early_bird_discount_amount) /
                                                                                    100;
                                                                                $calculate_price =
                                                                                    $slotPrice - $c_price;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}

                                                                            <del>
                                                                                {{ symbolPrice($slotPrice) }}
                                                                            </del>
                                                                        @else
                                                                            @php
                                                                                $calculate_price = $slotPrice;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}
                                                                        @endif
                                                                    @else
                                                                        @php
                                                                            $calculate_price = $slotPrice;
                                                                        @endphp
                                                                        {{ symbolPrice($calculate_price) }}
                                                                    @endif
                                                                @else
                                                                    @php
                                                                        $is_slot = App\Models\Event\Slot::where([
                                                                            'slot_unique_id' =>
                                                                                $ticket->normal_ticket_slot_unique_id,
                                                                            'event_id' => $event_id,
                                                                            'ticket_id' => $ticket->id,
                                                                        ])->first();
                                                                    @endphp
                                                                    @if (!empty($is_slot) && $slotItem['available_seat'] == false)
                                                                        <span class="badge badge-warning">
                                                                            {{ __('Booked') }}
                                                                        </span>
                                                                    @else
                                                                        <span class="badge badge-warning">
                                                                            {{ __('No Seat Found!') }}
                                                                        </span>
                                                                    @endif
                                                                @endif
                                                            @else
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
                                                                        <del>

                                                                            {{ symbolPrice($ticket->price) }}
                                                                        </del>
                                                                    @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                        @php
                                                                            $c_price =
                                                                                ($ticket->price *
                                                                                    $ticket->early_bird_discount_amount) /
                                                                                100;
                                                                            $calculate_price =
                                                                                $ticket->price - $c_price;
                                                                        @endphp
                                                                        {{ symbolPrice($calculate_price) }}

                                                                        <del>
                                                                            {{ symbolPrice($ticket->price) }}
                                                                        </del>
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
                                                            @endif
                                                        </h6>
                                                        <!------- slot button-------->
                                                        @if (isset($ticket) && $ticket->normal_ticket_slot_enable == 1)
                                                            <button
                                                                class="theme-btn-2 btn-xs mb-1 btn_seat_mapping_slot {{ $over == true ? 'btn-warning' : '' }}"
                                                                data-slot_unique_id="{{ $ticket->normal_ticket_slot_unique_id }}"
                                                                data-event_id="{{ request()->id }}"
                                                                data-ticket_id="{{ $ticket->id }}"
                                                                data-url="{{ route('event.slot-mapping-seat') }}"
                                                                @if ($over == true) disabled @endif>
                                                                {{ $over == true ? __('Over') : __('Seating') }}
                                                            </button>

                                                            <input type="hidden" value="0" class="quantity"
                                                                data-price="0" data-max_buy_ticket=""
                                                                data-name="{{ @$ticket_content->title }}"
                                                                name="quantity[]" data-ticket_id="{{ $ticket->id }}"
                                                                readonly data-stock="0">
                                                        @else
                                                            <div class="quantity-input">
                                                                <button class="quantity-down" type="button"
                                                                    id="quantityDown">
                                                                    -
                                                                </button>
                                                                <input class="quantity" readonly type="number"
                                                                    value="0" data-price="{{ $calculate_price }}"
                                                                    data-max_buy_ticket="{{ $ticket->max_buy_ticket }}"
                                                                    name="quantity[]"
                                                                    data-ticket_id="{{ $ticket->id }}"
                                                                    data-stock="{{ $stock }}"
                                                                    data-purchase="{{ $purchase['status'] }}"
                                                                    data-p_qty="{{ $purchase['p_qty'] }}">
                                                                <button class="quantity-up" type="button"
                                                                    id="quantityUP">
                                                                    +
                                                                </button>
                                                            </div>
                                                        @endif

                                                        @if ($ticket->early_bird_discount == 'enable')
                                                            @php
                                                                $discount_date = Carbon\Carbon::parse(
                                                                    $ticket->early_bird_discount_date .
                                                                        $ticket->early_bird_discount_time,
                                                                );
                                                            @endphp
                                                            @if (!$discount_date->isPast())
                                                                <p>{{ __('Discount available') . ' ' }} :
                                                                    ({{ __('till') . ' ' }} :
                                                                    <span
                                                                        dir="ltr">{{ \Carbon\Carbon::parse($discount_date)->timezone($websiteInfo->timezone)->translatedFormat('Y/m/d h:i a') }}</span>)
                                                                </p>
                                                            @endif
                                                        @endif

                                                    </div>
                                                    <p
                                                        class="text-warning max_error_{{ $ticket->id }}{{ $ticket->max_ticket_buy_type == 'limited' ? $ticket->max_buy_ticket : '' }} ">
                                                    </p>
                                                @elseif($ticket->pricing_type == 'variation')
                                                    @php
                                                        $variations = json_decode($ticket->variations);
                                                        $varition_names = App\Models\Event\VariationContent::where([
                                                            ['ticket_id', $ticket->id],
                                                            ['language_id', $currentLanguageInfo->id],
                                                        ])->get();
                                                        if (empty($varition_names)) {
                                                            $varition_names = App\Models\Event\VariationContent::where(
                                                                'ticket_id',
                                                                $ticket->id,
                                                            )->get();
                                                        }

                                                        $de_lang = App\Models\Language::where('is_default', 1)->first();
                                                        $de_varition_names = App\Models\Event\VariationContent::where([
                                                            ['ticket_id', $ticket->id],
                                                            ['language_id', $de_lang->id],
                                                        ])->get();
                                                        if (empty($de_varition_names)) {
                                                            $de_varition_names = App\Models\Event\VariationContent::where(
                                                                [['ticket_id', $ticket->id]],
                                                            )->get();
                                                        }
                                                    @endphp
                                                    @foreach ($variations as $key => $item)
                                                        @php
                                                            //ticket purchase or not check
                                                            if (Auth::guard('customer')->user()) {
                                                                if (count($de_varition_names) > 0) {
                                                                    $purchase = isTicketPurchaseVenue(
                                                                        $ticket->event_id,
                                                                        $item->v_max_ticket_buy,
                                                                        $ticket->id,
                                                                        $de_varition_names[$key]['name'],
                                                                    );
                                                                }
                                                            } else {
                                                                $purchase = ['status' => 'false', 'p_qty' => 0];
                                                            }
                                                            $ticket_content = App\Models\Event\TicketContent::where([
                                                                ['language_id', $currentLanguageInfo->id],
                                                                ['ticket_id', $ticket->id],
                                                            ])->first();
                                                            if (empty($ticket_content)) {
                                                                $ticket_content = App\Models\Event\TicketContent::where(
                                                                    [['ticket_id', $ticket->id]],
                                                                )->first();
                                                            }
                                                        @endphp
                                                        <p class="mb-0"><strong>{{ @$ticket_content->title }} -
                                                                {{ @$varition_names[$key]['name'] }}</strong>
                                                        </p>
                                                        <div class="click-show">
                                                            <div class="show-content">
                                                                {!! @$ticket_content->description !!}
                                                            </div>
                                                            @if (strlen(@$ticket_content->description) > 50)
                                                                <div class="read-more-btn">
                                                                    <span>{{ __('Read more') }}</span>
                                                                    <span>{{ __('Read less') }}</span>
                                                                </div>
                                                            @endif
                                                        </div>
                                                        <div class="price-count">
                                                            <h6 dir="ltr">
                                                                @if (!empty($item?->slot_enable) && $item->slot_enable == 1)
                                                                    @php
                                                                        $slotItem = app(
                                                                            \App\Services\BookingServices::class,
                                                                        )->showSlot(
                                                                            $event_id,
                                                                            $ticket->id,
                                                                            $item->slot_unique_id,
                                                                        );
                                                                        $slotPrice = $slotItem['price'];
                                                                    @endphp

                                                                    @if ($slotItem['available_seat'] == true)
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
                                                                                        $slotPrice -
                                                                                        $ticket->early_bird_discount_amount;
                                                                                @endphp
                                                                                {{ symbolPrice($calculate_price) }}
                                                                                <del>
                                                                                    {{ symbolPrice($slotPrice) }}
                                                                                </del>
                                                                            @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                                @php
                                                                                    $c_price =
                                                                                        ($slotPrice *
                                                                                            $ticket->early_bird_discount_amount) /
                                                                                        100;
                                                                                    $calculate_price =
                                                                                        $slotPrice - $c_price;
                                                                                @endphp
                                                                                {{ symbolPrice($calculate_price) }}
                                                                                <del>
                                                                                    {{ symbolPrice($slotPrice) }}
                                                                                </del>
                                                                            @else
                                                                                {{ symbolPrice($slotPrice) }}
                                                                            @endif
                                                                        @else
                                                                            {{ symbolPrice($slotPrice) }}
                                                                        @endif
                                                                    @else
                                                                        @php
                                                                            $is_slot = App\Models\Event\Slot::where([
                                                                                'slot_unique_id' =>
                                                                                    $item->slot_unique_id,
                                                                                'event_id' => $event_id,
                                                                                'ticket_id' => $ticket->id,
                                                                            ])->first();
                                                                        @endphp

                                                                        @if (!is_null($is_slot) && $slotItem['available_seat'] == false)
                                                                            <span class="badge badge-warning">
                                                                                {{ __('Booked') }}
                                                                            </span>
                                                                        @else
                                                                            <span class="badge badge-warning">
                                                                                {{ __('No Seat Available') }}
                                                                            </span>
                                                                        @endif
                                                                    @endif
                                                                @else
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
                                                                                    $item->price -
                                                                                    $ticket->early_bird_discount_amount;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}

                                                                            <del>
                                                                                {{ symbolPrice($item->price) }}
                                                                            </del>
                                                                        @elseif ($ticket->early_bird_discount_type == 'percentage' && !$discount_date->isPast())
                                                                            @php
                                                                                $c_price =
                                                                                    ($item->price *
                                                                                        $ticket->early_bird_discount_amount) /
                                                                                    100;
                                                                                $calculate_price =
                                                                                    $item->price - $c_price;
                                                                            @endphp
                                                                            {{ symbolPrice($calculate_price) }}

                                                                            <del>
                                                                                {{ symbolPrice($item->price) }}
                                                                            </del>
                                                                        @else
                                                                            @php
                                                                                $calculate_price = $item->price;
                                                                            @endphp

                                                                            {{ symbolPrice($calculate_price) }}
                                                                        @endif
                                                                    @else
                                                                        @php
                                                                            $calculate_price = $item->price;
                                                                        @endphp
                                                                        {{ symbolPrice($calculate_price) }}
                                                                    @endif
                                                                @endif
                                                            </h6>

                                                            @if (!empty($item?->slot_enable) && $item->slot_enable == 1)
                                                                <button
                                                                    class="theme-btn-2 btn-xs mb-1 btn_seat_mapping_slot {{ $over == true ? 'btn-warning' : '' }}"
                                                                    data-slot_unique_id="{{ $item?->slot_unique_id }}"
                                                                    data-event_id="{{ request()->id }}"
                                                                    data-ticket_id="{{ $ticket->id }}"
                                                                    data-url="{{ route('event.slot-mapping-seat') }}"
                                                                    @if ($over == true) disabled @endif>

                                                                    {{ $over == true ? __('Over') : __('Seating') }}
                                                                </button>
                                                                <input type="hidden" value="0" class="quantity"
                                                                    data-price="0" data-max_buy_ticket=""
                                                                    data-name="{{ $item->name }}" name="quantity[]"
                                                                    data-ticket_id="{{ $ticket->id }}" readonly
                                                                    data-stock="0">
                                                            @else
                                                                <div class="quantity-input">
                                                                    <button class="quantity-down_variation" type="button"
                                                                        id="quantityDown">
                                                                        -
                                                                    </button>
                                                                    <input type="hidden" name="v_name[]"
                                                                        value="{{ $item->name }}">
                                                                    @php
                                                                        if ($item->ticket_available_type == 'limited') {
                                                                            $stock = $item->ticket_available;
                                                                        } else {
                                                                            $stock = 'unlimited';
                                                                        }
                                                                        if ($item->max_ticket_buy_type == 'limited') {
                                                                            $max_buy = $item->v_max_ticket_buy;
                                                                        } else {
                                                                            $max_buy = 'unlimited';
                                                                        }
                                                                    @endphp
                                                                    <input type="number" value="0" class="quantity"
                                                                        data-price="{{ $calculate_price }}"
                                                                        data-max_buy_ticket="{{ $max_buy }}"
                                                                        data-name="{{ $item->name }}"
                                                                        name="quantity[]"
                                                                        data-ticket_id="{{ $ticket->id }}" readonly
                                                                        data-stock="{{ $stock }}">
                                                                    <button class="quantity-up" type="button"
                                                                        id="quantityUP">
                                                                        +
                                                                    </button>
                                                                </div>
                                                            @endif

                                                            @if ($ticket->early_bird_discount == 'enable')
                                                                @php
                                                                    $discount_date = Carbon\Carbon::parse(
                                                                        $ticket->early_bird_discount_date .
                                                                            $ticket->early_bird_discount_time,
                                                                    );
                                                                @endphp
                                                                @if (!$discount_date->isPast())
                                                                    <p>{{ __('Discount available') . ' ' }} :
                                                                        ({{ __('till') . ' ' }} :
                                                                        <span
                                                                            dir="ltr">{{ \Carbon\Carbon::parse($discount_date)->translatedFormat('Y/m/d h:i a') }}</span>)
                                                                    </p>
                                                                @endif
                                                            @endif

                                                        </div>
                                                        <p
                                                            class="text-warning max_error_{{ $ticket->id }}{{ $item->v_max_ticket_buy }} ">
                                                        </p>
                                                    @endforeach
                                                @elseif($ticket->pricing_type == 'free')
                                                    @php
                                                        if ($ticket->ticket_available_type == 'limited') {
                                                            $stock = $ticket->ticket_available;
                                                        } else {
                                                            $stock = 'unlimited';
                                                        }

                                                        //ticket purchase or not check
                                                        $de_lang = App\Models\Language::where('is_default', 1)->first();
                                                        $ticket_content_default = App\Models\Event\TicketContent::where(
                                                            [['language_id', $de_lang->id], ['ticket_id', $ticket->id]],
                                                        )->first();
                                                        if (
                                                            Auth::guard('customer')->user() &&
                                                            $ticket->max_ticket_buy_type == 'limited'
                                                        ) {
                                                            $purchase = isTicketPurchaseVenue(
                                                                $ticket->event_id,
                                                                $ticket->max_buy_ticket,
                                                                $ticket->id,
                                                                @$ticket_content_default->title,
                                                            );
                                                        } else {
                                                            $purchase = ['status' => 'false', 'p_qty' => 1];
                                                        }
                                                        $ticket_content = App\Models\Event\TicketContent::where([
                                                            ['language_id', $currentLanguageInfo->id],
                                                            ['ticket_id', $ticket->id],
                                                        ])->first();
                                                    @endphp
                                                    <p class="mb-0"><strong>{{ @$ticket_content->title }}</strong></p>
                                                    <div class="click-show">
                                                        <div class="show-content">
                                                            {!! @$ticket_content->description !!}
                                                        </div>
                                                        @if (strlen(@$ticket_content->description) > 50)
                                                            <div class="read-more-btn">
                                                                <span>{{ __('Read more') }}</span>
                                                                <span>{{ __('Read less') }}</span>
                                                            </div>
                                                        @endif
                                                    </div>
                                                    <div class="price-count">
                                                        <h6 dir="ltr">
                                                            <!------- slot button-------->
                                                            @if (isset($ticket) && $ticket->free_tickete_slot_enable == 1)
                                                                @php
                                                                    $slotItem = app(
                                                                        \App\Services\BookingServices::class,
                                                                    )->showSlot(
                                                                        $event_id,
                                                                        $ticket->id,
                                                                        $ticket->free_tickete_slot_unique_id,
                                                                    );
                                                                    $slotPrice = 0.0;
                                                                @endphp
                                                                @if ($slotItem['available_seat'] == true)
                                                                    {{ __('free') }}
                                                                @else
                                                                    @php
                                                                        $is_slot = App\Models\Event\Slot::where([
                                                                            'slot_unique_id' =>
                                                                                $ticket->free_tickete_slot_unique_id,
                                                                            'event_id' => $event_id,
                                                                            'ticket_id' => $ticket->id,
                                                                        ])->first();
                                                                    @endphp
                                                                    @if (!empty($is_slot) && $slotItem['available_seat'] == false)
                                                                        <span class="badge badge-warning">
                                                                            {{ __('Booked') }}
                                                                        </span>
                                                                    @else
                                                                        <span class="badge badge-warning">
                                                                            {{ __('No Seat Available') }}
                                                                        </span>
                                                                    @endif
                                                                @endif
                                                            @else
                                                                {{ __('free') }}
                                                            @endif

                                                        </h6>
                                                        @if (isset($ticket) && $ticket->free_tickete_slot_enable == 1)
                                                            <button
                                                                class="theme-btn-2 btn-xs mb-1 btn_seat_mapping_slot {{ $over == true ? 'btn-warning' : '' }}"
                                                                data-slot_unique_id="{{ $ticket->free_tickete_slot_unique_id }}"
                                                                data-event_id="{{ request()->id }}"
                                                                data-ticket_id="{{ $ticket->id }}"
                                                                data-url="{{ route('event.slot-mapping-seat') }}"
                                                                @if ($over == true) disabled @endif>
                                                                {{ $over == true ? __('Over') : __('Seating') }}
                                                            </button>
                                                            <input type="hidden" value="0" class="quantity"
                                                                data-price="0" data-max_buy_ticket=""
                                                                data-name="{{ @$ticket_content->title }}"
                                                                name="quantity[]" data-ticket_id="{{ $ticket->id }}"
                                                                readonly data-stock="0">
                                                        @else
                                                            <div class="quantity-input">
                                                                <button class="quantity-down" type="button"
                                                                    id="quantityDown">
                                                                    -
                                                                </button>
                                                                <input class="quantity"
                                                                    data-max_buy_ticket="{{ $ticket->max_buy_ticket }}"
                                                                    type="number" value="0"
                                                                    data-price="{{ $ticket->price }}" name="quantity[]"
                                                                    data-ticket_id="{{ $ticket->id }}" readonly
                                                                    data-stock="{{ $stock }}"
                                                                    data-purchase="{{ $purchase['status'] }}"
                                                                    data-p_qty="{{ $purchase['p_qty'] }}">
                                                                <button class="quantity-up" type="button"
                                                                    id="quantityUP">
                                                                    +
                                                                </button>
                                                            </div>
                                                        @endif
                                                    </div>
                                                    <p
                                                        class="text-warning max_error_{{ $ticket->id }}{{ $ticket->max_ticket_buy_type == 'limited' ? $ticket->max_buy_ticket : '' }} ">
                                                    </p>
                                                @endif
                                            @endforeach
                                        @endif
                                    @endif
                                    @if ($tickets_count > 0)
                                        <div class="event-detail-unified__app-note">
                                            {{ __('Duty is moving toward app-first ticket access. Use the app for the full entry experience, or keep using the beta web checkout below while we finish that transition.') }}
                                            <a href="{{ $appDownloadUrl }}">{{ __('Open the download page') }}</a>.
                                        </div>
                                        <div class="total">
                                            <b>{{ __('Total Price') . ' :' }} </b>
                                            <span class="h4" dir="ltr">
                                                <span>{{ $basicInfo->base_currency_symbol_position == 'left' ? $basicInfo->base_currency_symbol : '' }}</span>
                                                <span id="total_price">0</span>
                                                <span>{{ $basicInfo->base_currency_symbol_position == 'right' ? $basicInfo->base_currency_symbol : '' }}</span>

                                            </span>
                                            <input type="hidden" name="total" id="total">
                                        </div>
<<<<<<< Updated upstream
                                        <button class="theme-btn w-100 mt-20"
                                            type="submit">{{ __('Book Now') }}</button>
=======
                                        <button class="theme-btn w-100 mt-20" type="submit">{{ __('Continue with beta web checkout') }}</button>
>>>>>>> Stashed changes
                                    @endif
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                @if (!empty(showAd(3)))
                    <div class="text-center mt-4">
                        {!! showAd(3) !!}
                    </div>
                @endif
            </div>
            @if (count($related_events) > 0)
                <hr>
                <div class="releted-event-header mt-50">
                    <h3>{{ __('Related Events') }}</h3>
                    <div class="related-event-buttons mb-10">
                        <div class="related-event-slide-prev slide-btn"><i class="fas fa-chevron-left"></i></div>
                        <div class="related-event-slide-next slide-btn"><i class="fas fa-chevron-right"></i></div>
                    </div>
                </div>

                <div class="swiper related-event-slider">
                    <div class="swiper-wrapper">
                        @foreach ($related_events as $event)
                            <div class="swiper-slide">
                                <div class="event-item">
                                    <div class="event-image">
                                        <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                                            <img class="lazy"
                                                data-src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                                                alt="Event">
                                        </a>
                                    </div>
                                    <div class="event-content">
                                        <ul class="time-info">
                                            <li>
                                                <i class="far fa-calendar-alt"></i>
                                                <span>
                                                    @php
                                                        $date = strtotime($event->start_date);
                                                    @endphp
                                                    {{ \Carbon\Carbon::parse($date)->timezone($websiteInfo->timezone)->translatedFormat('d M') }}
                                                </span>
                                            </li>
                                            @php
                                                if ($event->date_type == 'multiple') {
                                                    $event_date = eventLatestDates($event->id);
                                                    $date = strtotime(@$event_date->start_date);
                                                } else {
                                                    $date = strtotime($event->start_date);
                                                }
                                            @endphp
                                            <li>
                                                <i class="far fa-hourglass"></i>
                                                <span
                                                    title="Event Duration">{{ $event->date_type == 'multiple' ? @$event_date->duration : $event->duration }}</span>
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

                                        @if (strlen($desc) > 45)
                                            <p>{{ mb_substr($desc, 0, 50) . '....' }}</p>
                                        @else
                                            <p>{{ $desc }}</p>
                                        @endif
                                        @php
                                            $ticket = DB::table('tickets')->where('event_id', $event->id)->first();
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
                                                                    $variation = json_decode($ticket->variations, true);
                                                                    $v_min_price = array_reduce(
                                                                        $variation,
                                                                        function ($a, $b) {
                                                                            return $a['price'] < $b['price'] ? $a : $b;
                                                                        },
                                                                        array_shift($variation),
                                                                    );
                                                                    if ($v_min_price['slot_enable'] == 1) {
                                                                        $slot_variations = json_decode($ticket->variations, true);
                                                                        $v_slot_min_price = array_reduce(
                                                                            $slot_variations,
                                                                            function ($a, $b) {
                                                                                return $a['slot_seat_min_price'] <
                                                                                    $b['slot_seat_min_price']
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
                                                                                $calculate_price = $price - $p_price;
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
                                                                    if ($ticket->normal_ticket_slot_enable == 1) {
                                                                        $ticketPrice = $ticket->slot_seat_min_price;
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
                                                                            $calculate_price = $ticketPrice - $p_price;
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
            @endif
        </div>
    </section>
    <!-- Event Page End -->

@endsection
@section('script')
    <script>
        "use strict"
        var currency_symbol = "{{ $basicInfo->base_currency_symbol }}";
        var price_text = "{{ __('Price') }}";
        var lang_No_seat_selected_yet = "{{ __('No seat selected yet') }}";
        var seat_has_been_selected_msg = "{{ __('Seat has been selected!') }}";
        var seat_has_been_unselected_msg = "{{ __('Seat has been unselected!') }}";
        var seleted_text = "{{ __('Selected') }}";
        var select_text = "{{ __('Select') }}";
        var slot_already_booked_msg = "{{ __('Slot already Booked!') }}";
        var booked_text = "{{ __('Booked') }}";
    </script>
    <script src="{{ asset('assets/front/js/slot.js') }}"></script>
@endsection
@section('modals')
    @includeIf('frontend.partials.modals')
    @includeIf('frontend.event.slots.seat-mapping-modal')
    @includeIf('frontend.event.slots.slots-seat')
@endsection
