@extends('backend.layout')

@section('style')
  @includeIf('backend.partials.scarlet-operations-workspace')
@endsection

@section('content')
  @include('backend.event.reservation.partials.index-core', [
    'pageTitle' => __('Ticket Reservations'),
    'dashboardRoute' => 'admin.dashboard',
    'indexRoute' => 'admin.event_reservation.index',
    'detailsRoute' => 'admin.event_reservation.details',
    'exportRoute' => 'admin.event_reservation.export',
    'bookingDetailsRouteName' => 'admin.event_booking.details',
    'customerDetailsRouteName' => 'admin.customer_management.customer_details',
    'queueDescription' => __('Monitor partial payments, due dates and reservation lifecycle before tickets convert into bookings.'),
  ])
@endsection
