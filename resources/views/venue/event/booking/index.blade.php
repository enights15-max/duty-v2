@extends('venue.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Event Bookings') }}</h4>
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
                <a href="#">{{ __('Event Bookings') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Recent Bookings') }}</div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped mt-3">
                            <thead>
                                <tr>
                                    <th scope="col">{{ __('Booking ID') }}</th>
                                    <th scope="col">{{ __('Event') }}</th>
                                    <th scope="col">{{ __('Customer') }}</th>
                                    <th scope="col">{{ __('Amount') }}</th>
                                    <th scope="col">{{ __('Payment') }}</th>
                                    <th scope="col">{{ __('Action') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($bookings as $booking)
                                    <tr>
                                        <td>{{ $booking->booking_id }}</td>
                                        <td>{{ $booking->evnt ? $booking->evnt->title : '-' }}</td>
                                        <td>{{ $booking->fname }} {{ $booking->lname }}</td>
                                        <td>{{ $booking->currencySymbol }}{{ $booking->price }}</td>
                                        <td>
                                            @if ($booking->paymentStatus == 'completed')
                                                <span class="badge badge-success">{{ __('Completed') }}</span>
                                            @elseif($booking->paymentStatus == 'pending')
                                                <span class="badge badge-warning">{{ __('Pending') }}</span>
                                            @else
                                                <span class="badge badge-danger">{{ $booking->paymentStatus }}</span>
                                            @endif
                                        </td>
                                        <td>
                                            <a href="{{ route('venue.event_booking.details', $booking->id) }}"
                                                class="btn btn-primary btn-sm">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    <div class="mt-3">
                        {{ $bookings->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection