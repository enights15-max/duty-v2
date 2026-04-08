@extends('venue.layout')

@section('content')
  @include('backend.event.reservation.partials.index-core', [
    'pageTitle' => __('Reservation Queue'),
    'dashboardRoute' => 'venue.dashboard',
    'indexRoute' => 'venue.event_reservation.index',
    'detailsRoute' => 'venue.event_reservation.details',
    'exportRoute' => 'venue.event_reservation.export',
    'bookingDetailsRouteName' => 'venue.event_booking.details',
    'customerDetailsRouteName' => null,
    'queueDescription' => __('Track reserved inventory, outstanding balances and conversion readiness across the events hosted by your venue.'),
  ])
@endsection
