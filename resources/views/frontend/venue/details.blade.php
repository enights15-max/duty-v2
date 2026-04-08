@extends('frontend.layout')
@section('pageHeading')
    {{ $venue->name }}
@endsection
@section('meta-keywords', "{{ $venue->name }}, venue profile")
@section('meta-description', "$venue->details")

@section('hero-section')
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
                                    @if ($venue->photo == null)
                                        <img class="rounded-lg lazy" data-src="{{ asset('assets/front/images/user.png') }}"
                                            alt="image">
                                    @else
                                        <img class="rounded-lg lazy"
                                            data-src="{{ asset('assets/admin/img/venue-photo/' . $venue->photo) }}" alt="image">
                                    @endif
                                </a>
                            </figure>
                            <div class="author-info">
                                <h3 class="mb-1 text-white">{{ $venue->name }}</h3>
                                <h6 class="mb-1 text-white">{{ $venue->username }}</h6>
                                <span>{{ __('Member since') }} {{ date('M Y', strtotime($venue->created_at)) }}</span>
                            </div>
                        </div>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item"><a href="{{ route('index') }}">{{ __('Home') }}</a></li>
                                <li class="breadcrumb-item active">{{ __('Venue Details') }}</li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <div class="col-lg-4 text-white">
                    <div class="social-style-one">
                        <h5 class="mb-0">{{ __('Follow Me') }}</h5>
                        @if($venue->facebook)<a target="_blank" href="{{ $venue->facebook }}"><i
                        class="fab fa-facebook-f"></i></a>@endif
                        @if($venue->linkedin)<a target="_blank" href="{{ $venue->linkedin }}"><i
                        class="fab fa-linkedin-in"></i></a>@endif
                        @if($venue->twitter)<a target="_blank" href="{{ $venue->twitter }}"><i
                        class="fab fa-twitter"></i></a>@endif
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Page Banner End -->
@endsection
@section('content')
    <!-- Author-single-area start -->
    <div class="author-area py-120 rpy-100 ">
        <div class="container">
            <div class="row">
                <div class="col-lg-8">
                    <h3 class="mb-20">{{ __('Events at This Venue') }}</h3>
                    <div class="row">
                        @if (count($events) > 0)
                            @foreach ($events as $event)
                                @if (!empty($event->information))
                                    <div class="col-md-6">
                                        <div class="event-item">
                                            <div class="event-image">
                                                <a href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
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
                                                            {{ \Carbon\Carbon::parse($date)->translatedFormat('d M') }}
                                                        </span>
                                                    </li>
                                                    <li>
                                                        <i class="far fa-hourglass"></i>
                                                        <span
                                                            title="{{ __('Event Duration') }}">{{ $event->date_type == 'multiple' ? @$event_date->duration : $event->duration }}</span>
                                                    </li>
                                                </ul>
                                                <h5>
                                                    <a href="{{ route('event.details', [$event->information->slug, $event->id]) }}">
                                                        {{ strlen($event->information->title) > 45 ? mb_substr($event->information->title, 0, 50) . '....' : $event->information->title }}
                                                    </a>
                                                </h5>
                                                <div class="price-remain">
                                                    <div class="location">
                                                        <i class="fas fa-map-marker-alt"></i>
                                                        <span>{{ @$event->information->address }}</span>
                                                    </div>
                                                </div>
                                            </div>
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
                <div class="col-lg-4">
                    <div class="author-sidebar rmt-55">
                        <div class="widget search-widget">
                            <h4 class="widget-title">{{ __('Venue Info') }}</h4>
                            <div class="author-description">
                                {!! nl2br(e($venue->details)) !!}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection