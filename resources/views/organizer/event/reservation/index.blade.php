@extends('organizer.layout')

@section('content')
  @include('backend.event.reservation.partials.index-core', [
    'pageTitle' => __('Reservation Queue'),
    'dashboardRoute' => 'organizer.dashboard',
    'indexRoute' => 'organizer.event_reservation.index',
    'detailsRoute' => 'organizer.event_reservation.details',
    'exportRoute' => 'organizer.event_reservation.export',
    'bookingDetailsRouteName' => 'organizer.event_booking.details',
    'customerDetailsRouteName' => null,
    'queueDescription' => __('Operate hold windows, follow pending balances and convert completed reservations into bookings for your events.'),
  ])
@endsection
