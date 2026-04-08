@extends('frontend.layout')
@section('pageHeading')
    {{ __('Home') }}
@endsection

@php
    $metaKeywords = !empty($seo->meta_keyword_home) ? $seo->meta_keyword_home : '';
    $metaDescription = !empty($seo->meta_description_home) ? $seo->meta_description_home : '';
@endphp
@section('meta-keywords', "{{ $metaKeywords }}")
@section('meta-description', "$metaDescription")

@section('hero-section')
    <!-- Hero Section Start -->
    @if ($heroSection)
        <section class="hero-section overlay pt-150 pb-120 lazy"
            data-bg="{{ asset('assets/admin/img/hero-section/' . $heroSection->background_image) }}">
    @else
            <section class="hero-section overlay pt-150 pb-120 lazy" data-bg="{{ asset('assets/front/images/hero-bg.jpg') }}">
        @endif
            <div class="mesh-overlay"
                style="position: absolute; top:0; left:0; width:100%; height:100%; background: radial-gradient(circle at 20% 30%, rgba(140, 37, 244, 0.2) 0%, transparent 60%), radial-gradient(circle at 80% 70%, rgba(99, 102, 241, 0.15) 0%, transparent 60%), radial-gradient(circle at 50% 50%, rgba(13, 8, 18, 0.4) 0%, transparent 100%); pointer-events: none;">
            </div>
            <div id="particles-js" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 1;">
            </div>
            <div class="container" style="position: relative; z-index: 2;">
                <div class="hero-content" data-aos="fade-up">
                    <h1 class="text-white animate-float" style="font-weight: 800; letter-spacing: -0.02em;">
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
                            class="theme-btn pulse-click glow-hover">{{ $heroSection ? $heroSection->first_button : __('Search') }}</button>
                    </form>
                </div>
            </div>
        </section>
        <!-- Hero Section End -->

        <!-- Urgency Ticker Start -->
        <div class="urgency-ticker-wrap"
            style="background: rgba(140, 37, 244, 0.1); border-top: 1px solid rgba(255,255,255,0.05); border-bottom: 1px solid rgba(255,255,255,0.05); padding: 10px 0; overflow: hidden; white-space: nowrap; position: relative; z-index: 10;">
            <div class="ticker-content"
                style="display: inline-block; animation: ticker 30s linear infinite; color: rgba(255,255,255,0.8); font-size: 14px; font-weight: 500;">
                <span class="ticker-item" style="margin-right: 50px;"><i class="fas fa-bolt text-warning mr-2"></i>
                    {{ __('Recently Booked') }}: <strong>Rock Concert Buenos Aires</strong></span>
                <span class="ticker-item" style="margin-right: 50px;"><i class="fas fa-fire text-danger mr-2"></i>
                    {{ __('Selling Fast') }}: <strong>Tech Conference 2026</strong></span>
                <span class="ticker-item" style="margin-right: 50px;"><i class="fas fa-ticket-alt text-success mr-2"></i>
                    {{ __('New Event') }}: <strong>Jazz Night at The Blue Note</strong></span>
                <span class="ticker-item" style="margin-right: 50px;"><i class="fas fa-bolt text-warning mr-2"></i>
                    {{ __('Recently Booked') }}: <strong>Art Gallery Opening</strong></span>
            </div>
        </div>
        <!-- Urgency Ticker End -->
@endsection
    @section('content')

        <!-- Events Section Start -->
        @if ($secInfo->featured_section_status == 1)
            <section class="events-section pt-110 rpt-90 pb-90 rpb-70 bg-premium-dark section-glow">
                <div class="container">

                    <div class="section-title text-center mb-45" data-aos="fade-down">
                        <h2>{{ $secTitleInfo ? $secTitleInfo->event_section_title : __('Featured Events') }}</h2>
                    </div>

                    @if ($eventCategories->isEmpty())
                        <p class="text-center">{{ __('No Events Found') }}</p>
                    @else
                        <nav class="category-pills-nav mb-45" data-aos="fade-up" data-aos-delay="100">
                            <div class="nav category-pills justify-content-center" id="nav-tab" role="tablist">
                                <button class="nav-link active pulse-click glow-hover" id="nav-all-tab" data-toggle="tab"
                                    data-target="#nav-all" type="button" role="tab" aria-controls="nav-all" aria-selected="true">
                                    <i class="fas fa-th-large"></i> {{ __('All') }}
                                </button>
                                @foreach ($eventCategories as $item)
                                    <button class="nav-link pulse-click glow-hover ajax-category-pill" id="nav-{{ $item->id }}-tab"
                                        data-toggle="tab" data-target="#nav-all" type="button" role="tab" aria-controls="nav-all"
                                        aria-selected="false" data-category-id="{{ $item->id }}">
                                        <i class="{{ $item->icon ?? 'fas fa-star' }}"></i> {{ $item->name }}
                                    </button>
                                @endforeach
                            </div>
                        </nav>

                        <div class="tab-content" id="nav-tabContent">
                            <div class="tab-pane fade show active" id="nav-all" role="tabpanel" aria-labelledby="nav-all-tab">
                                <div class="row" id="ajax-event-container">
                                    @php
                                        $now_time = \Carbon\Carbon::now();
                                        $eventsall = DB::table('event_contents')
                                            ->join('events', 'events.id', '=', 'event_contents.event_id')
                                            ->leftJoin('event_categories', 'event_categories.id', '=', 'event_contents.event_category_id')
                                            ->select('event_contents.*', 'events.*', 'event_categories.name as categoryName', 'events.id as id')
                                            ->where([
                                                ['event_contents.language_id', '=', $currentLanguageInfo->id],
                                                ['events.status', 1],
                                                ['events.end_date_time', '>=', $now_time],
                                                ['events.is_featured', '=', 'yes'],
                                            ])
                                            ->orderBy('events.created_at', 'desc')
                                            ->take(9)
                                            ->get();
                                    @endphp
                                    @foreach ($eventsall as $event)
                                        @include('frontend.partials.event-card', ['event' => $event])
                                    @endforeach
                                </div>
                                <div id="ajax-loader" class="text-center d-none py-5">
                                    <div class="spinner-border text-primary" style="color: var(--primary-color) !important;"
                                        role="status">
                                        <span class="sr-only">Loading...</span>
                                    </div>
                                </div>
                            </div>
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
            <section class="category-section pt-110 rpt-90 pb-80 rpb-60" style="background: #0D0812;">
                <div class="container">
                    <div class="section-title mb-60">
                        <h2>{{ $secTitleInfo ? $secTitleInfo->category_section_title : __('Categories') }}</h2>
                    </div>
                    <div class="category-wrap text-white">
                        @if (count($eventCategories) > 0)
                            @foreach ($eventCategories as $item)
                                <a href="{{ route('events', ['category' => $item->slug]) }}" class="category-item">
                                    <img class="lazy" data-src="{{ asset('assets/admin/img/event-category/' . $item->image) }}"
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

        <!-- For You Section Start -->
        @php
            $forYouEvents = [];
            if (Auth::guard('customer')->check()) {
                $customerId = Auth::guard('customer')->user()->id;
                // Simple personalization: Events in categories the user has in wishlist, or just featured
                $wishlistCategoryIds = DB::table('wishlists')
                    ->join('event_contents', 'event_contents.event_id', '=', 'wishlists.event_id')
                    ->where('wishlists.customer_id', $customerId)
                    ->pluck('event_contents.event_category_id')
                    ->unique()
                    ->toArray();

                if (!empty($wishlistCategoryIds)) {
                    $forYouEvents = DB::table('event_contents')
                        ->join('events', 'events.id', '=', 'event_contents.event_id')
                        ->whereIn('event_contents.event_category_id', $wishlistCategoryIds)
                        ->where([
                            ['event_contents.language_id', '=', $currentLanguageInfo->id],
                            ['events.status', 1],
                            ['events.end_date_time', '>=', \Carbon\Carbon::now()],
                        ])
                        ->orderBy('events.created_at', 'desc')
                        ->take(3)
                        ->get();
                }
            }

            if (empty($forYouEvents) || count($forYouEvents) == 0) {
                // Fallback: Trending/Top events
                $forYouEvents = DB::table('event_contents')
                    ->join('events', 'events.id', '=', 'event_contents.event_id')
                    ->where([
                        ['event_contents.language_id', '=', $currentLanguageInfo->id],
                        ['events.status', 1],
                        ['events.end_date_time', '>=', \Carbon\Carbon::now()],
                    ])
                    ->orderBy('events.id', 'desc') // Fallback to id
                    ->take(3)
                    ->get();
            }
        @endphp

        <section class="for-you-section pb-90" style="background: #0D0812;">
            <div class="container">
                <div class="section-title mb-45" data-aos="fade-right">
                    <span class="sub-title mb-10"
                        style="color: var(--primary-color); font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">{{ __('Personalized') }}</span>
                    <h2>{{ __('For You') }}</h2>
                </div>
                <div class="row">
                    @foreach ($forYouEvents as $event)
                        @include('frontend.partials.event-card', ['event' => $event])
                    @endforeach
                </div>
            </div>
        </section>
        <!-- For You Section End -->

        <!-- About Section Start -->
        @if ($secInfo->about_section_status == 1)
            <section class="about-section pb-120 rpb-95" style="background: #0D0812;">
                <div class="container">
                    @if (is_null($aboutUsSection))
                        <h2 class="text-center">{{ __('No data found for about section') }}</h2>
                    @endif
                    @if (!empty($aboutUsSection))
                        <div class="row align-items-center">
                            <div class="col-lg-6">
                                <div class="about-image-part pt-10 rmb-55">
                                    @if (!empty($aboutUsSection->image))
                                        <img class="lazy"
                                            data-src="{{ asset('assets/admin/img/about-us-section/' . $aboutUsSection->image) }}"
                                            alt="Image">
                                    @endif
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="about-content">
                                    <div class="section-title mb-30">
                                        <h2>{{ $aboutUsSection->title }}</h2>
                                    </div>
                                    <p>{{ $aboutUsSection->subtitle }}</p>
                                    <div>
                                        {!! $aboutUsSection->text !!}
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endif
                </div>
            </section>
        @endif
        <!-- About Section End -->


        <!-- Feature Section Start -->
        <section class="feature-section pt-110 rpt-90 bg-premium-dark section-glow">
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
            <section class="testimonial-section pt-120 rpt-80 bg-premium-dark section-glow">
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
                                            <img class="lazy" data-src="{{ asset('assets/admin/img/testimonial/clients.png') }}"
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
                                            data-src="{{ asset('assets/admin/img/partner/' . $item->image) }}" alt="Client Logo"></a>
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
    @endsection

    @section('custom-script')
        <script>
            particlesJS('particles-js', {
                "particles": {
                    "number": { "value": 80, "density": { "enable": true, "value_area": 800 } },
                    "color": { "value": "#ffffff" },
                    "shape": { "type": "circle" },
                    "opacity": { "value": 0.2, "random": false },
                    "size": { "value": 3, "random": true },
                    "line_linked": { "enable": true, "distance": 150, "color": "#ffffff", "opacity": 0.1, "width": 1 },
                    "move": { "enable": true, "speed": 2, "direction": "none", "random": false, "straight": false, "out_mode": "out", "bounce": false }
                },
                "interactivity": {
                    "detect_on": "canvas",
                    "events": { "onhover": { "enable": true, "mode": "grab" }, "onclick": { "enable": true, "mode": "push" }, "resize": true },
                    "modes": { "grab": { "distance": 140, "line_linked": { "opacity": 0.5 } }, "push": { "particles_nb": 4 } }
                },
                "retina_detect": true
            });

            // AJAX Category Filtering
            $(document).on('click', '.ajax-category-pill, #nav-all-tab', function (e) {
                e.preventDefault();
                let categoryId = $(this).data('category-id') || '';
                let container = $('#ajax-event-container');
                let loader = $('#ajax-loader');

                loader.removeClass('d-none');
                container.css('opacity', '0.5');

                $.ajax({
                    url: "{{ route('events.filter') }}",
                    type: "GET",
                    data: {
                        category_id: categoryId
                    },
                    success: function (response) {
                        container.html(response.html).css('opacity', '1');
                        loader.addClass('d-none');

                        // Re-init animations if needed
                        if (typeof AOS !== 'undefined') {
                            AOS.refresh();
                        }
                    },
                    error: function () {
                        loader.addClass('d-none');
                        container.css('opacity', '1');
                    }
                });
            });
        </script>
        <style>
            @keyframes ticker {
                0% {
                    transform: translateX(100%);
                }

                100% {
                    transform: translateX(-100%);
                }
            }

            .urgency-ticker-wrap {
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
            }

            .ticker-content:hover {
                animation-play-state: paused;
            }
        </style>
    @endsection