@extends('organizer.layout')

@section('content')
  @php
    $statusClass = match ($reservation->status) {
        'active' => 'warning',
        'completed' => 'success',
        'expired' => 'secondary',
        'defaulted' => 'danger',
        'cancelled' => 'dark',
        default => 'light',
    };
  @endphp

  <div class="page-header">
    <h4 class="page-title">{{ __('Reservation Details') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('organizer.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ __('Event Bookings') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="{{ route('organizer.event_reservation.index', ['status' => 'all']) }}">{{ __('Reservations') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ $reservation->reservation_code }}</a>
      </li>
    </ul>
  </div>

  <div class="row">
    <div class="col-lg-8">
      @include('backend.event.reservation.partials.details-core', [
        'backUrl' => route('organizer.event_reservation.index', ['status' => 'all']),
        'bookingDetailsRouteName' => 'organizer.event_booking.details',
        'customerDetailsRouteName' => null,
      ])
    </div>

    <div class="col-lg-4">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Organizer Actions') }}</div>
        </div>
        <div class="card-body">
          <div class="alert alert-warning">
            {{ __('Organizers can operate reservation timelines and inventory for their own events. Refunds remain admin-managed.') }}
          </div>

          @if ($actions['can_extend'])
            <form action="{{ route('organizer.event_reservation.extend', ['id' => $reservation->id]) }}" method="POST" class="mb-4">
              @csrf
              <h5 class="mb-3">{{ __('Extend active reservation') }}</h5>
              <div class="form-group">
                <label>{{ __('New expiration') }}</label>
                <input type="datetime-local" class="form-control" name="expires_at"
                  value="{{ optional($reservation->expires_at)->format('Y-m-d\\TH:i') }}" required>
              </div>
              <div class="form-group">
                <label>{{ __('Final due date') }}</label>
                <input type="datetime-local" class="form-control" name="final_due_date"
                  value="{{ optional($reservation->final_due_date)->format('Y-m-d\\TH:i') }}">
              </div>
              <button class="btn btn-primary btn-block" type="submit">{{ __('Update timeline') }}</button>
            </form>
          @endif

          @if ($actions['can_reactivate'])
            <form action="{{ route('organizer.event_reservation.reactivate', ['id' => $reservation->id]) }}" method="POST" class="mb-4">
              @csrf
              <h5 class="mb-3">{{ __('Reactivate reservation') }}</h5>
              <div class="form-group">
                <label>{{ __('New expiration') }}</label>
                <input type="datetime-local" class="form-control" name="expires_at"
                  value="{{ now()->addDays(3)->format('Y-m-d\\TH:i') }}" required>
              </div>
              <div class="form-group">
                <label>{{ __('Final due date') }}</label>
                <input type="datetime-local" class="form-control" name="final_due_date"
                  value="{{ optional($reservation->final_due_date)->format('Y-m-d\\TH:i') }}">
              </div>
              <button class="btn btn-warning btn-block" type="submit">{{ __('Reactivate and hold inventory') }}</button>
            </form>
          @endif

          @if ($actions['can_convert'])
            <form action="{{ route('organizer.event_reservation.convert', ['id' => $reservation->id]) }}" method="POST" class="mb-4"
              onsubmit="return confirm('{{ __('Convert this reservation into bookings now?') }}')">
              @csrf
              <button class="btn btn-success btn-block" type="submit">{{ __('Convert into bookings') }}</button>
            </form>
          @endif

          @if ($actions['can_default'])
            <form action="{{ route('organizer.event_reservation.default', ['id' => $reservation->id]) }}" method="POST" class="mb-3"
              onsubmit="return confirm('{{ __('Mark this reservation as defaulted?') }}')">
              @csrf
              <button class="btn btn-danger btn-block" type="submit">{{ __('Mark defaulted') }}</button>
            </form>
          @endif

          @if ($actions['can_cancel'])
            <form action="{{ route('organizer.event_reservation.cancel', ['id' => $reservation->id]) }}" method="POST"
              onsubmit="return confirm('{{ __('Cancel this reservation? Any refund must be handled by an administrator.') }}')">
              @csrf
              <button class="btn btn-outline-danger btn-block" type="submit">{{ __('Cancel reservation') }}</button>
            </form>
          @endif

          @if (!$actions['can_extend'] && !$actions['can_reactivate'] && !$actions['can_convert'] && !$actions['can_default'] && !$actions['can_cancel'])
            <p class="text-muted mb-0">{{ __('No organizer actions are available for the current reservation state.') }}</p>
          @endif
        </div>
      </div>
    </div>
  </div>
@endsection
