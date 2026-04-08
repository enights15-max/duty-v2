@extends('venue.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Booking Details') }}</h4>
        <ul class="breadcrumbs">
            <li class="nav-home">
                <a href="{{ route('venue.dashboard') }}">
                    <i class="flaticon-home"></i>
                </a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="{{ route('venue.event.booking') }}">{{ __('Event Bookings') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Booking Details') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Booking ID') }}: #{{ $booking->booking_id }}</div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Event') }}:</strong></div>
                                <div class="col-8">{{ $booking->evnt ? $booking->evnt->title : '-' }}</div>
                            </div>
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Customer') }}:</strong></div>
                                <div class="col-8">{{ $booking->fname }} {{ $booking->lname }}</div>
                            </div>
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Email') }}:</strong></div>
                                <div class="col-8">{{ $booking->email }}</div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Amount') }}:</strong></div>
                                <div class="col-8">{{ $booking->currencySymbol }}{{ $booking->price }}</div>
                            </div>
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Status') }}:</strong></div>
                                <div class="col-8">
                                    @if ($booking->paymentStatus == 'completed')
                                        <span class="badge badge-success">{{ __('Completed') }}</span>
                                    @else
                                        <span class="badge badge-warning">{{ $booking->paymentStatus }}</span>
                                    @endif
                                </div>
                            </div>
                            <div class="row border-bottom pb-2 mb-3">
                                <div class="col-4"><strong>{{ __('Date') }}:</strong></div>
                                <div class="col-8">{{ $booking->created_at->format('d M, Y') }}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection