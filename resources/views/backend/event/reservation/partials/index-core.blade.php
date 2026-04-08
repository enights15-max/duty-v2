<div class="page-header">
  <h4 class="page-title">{{ $pageTitle }}</h4>
  <ul class="breadcrumbs">
    <li class="nav-home">
      <a href="{{ route($dashboardRoute) }}">
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
      <a href="#">{{ __('Reservations') }}</a>
    </li>
  </ul>
</div>

@php
  $reservationFilterLabel = match ($status) {
      'active' => __('Active only'),
      'completed' => __('Completed only'),
      'expired' => __('Expired only'),
      'defaulted' => __('Defaulted only'),
      default => __('All reservations'),
  };
  $refundReasonOptions = $refundReasonOptions ?? [];
  $refundRiskFlagOptions = $refundRiskFlagOptions ?? [];
  $refundReasonCode = $refundReasonCode ?? 'all';
  $refundRiskFlag = $refundRiskFlag ?? 'all';
  $decisionPeriod = $decisionPeriod ?? '30d';
  $showRefundDecisionFilters = !empty($refundReasonOptions) || !empty($refundRiskFlagOptions);
  $decisionInsights = $decisionInsights ?? [
      'supported' => false,
      'selected_period' => '30d',
      'selected_period_label' => __('Last 30 days'),
      'total_refund_decisions' => 0,
      'total_refunded_gross' => 0.0,
      'unique_admins_count' => 0,
      'decisions_with_risk_flags_count' => 0,
      'treasury_impact_count' => 0,
      'treasury_impact_gross' => 0.0,
      'gateway_refund_count' => 0,
      'latest_decision_at' => null,
      'top_reasons' => [],
      'top_risk_flags' => [],
      'top_admins' => [],
  ];
@endphp

<div class="ops-shell">
  <div class="ops-hero">
    <div class="ops-hero__grid">
      <div>
        <span class="ops-hero__eyebrow">{{ __('Reservations') }}</span>
        <h1 class="ops-hero__title">{{ __('Deposit monitoring and lifecycle control') }}</h1>
        <p class="ops-hero__copy">
          {{ __('Monitor partial payments, due windows, refunds and booking conversion from a queue designed for support and settlement workflows.') }}
        </p>
      </div>
      <div class="ops-hero__meta">
        <div class="ops-hero__stat">
          <span class="ops-hero__stat-label">{{ __('Results in scope') }}</span>
          <span class="ops-hero__stat-value">{{ number_format($reservations->total()) }}</span>
          <span class="ops-hero__stat-note">{{ __('Reservations matching the active search and status filters') }}</span>
        </div>
        <div class="ops-hero__stat">
          <span class="ops-hero__stat-label">{{ __('Current status scope') }}</span>
          <span class="ops-hero__stat-value">{{ $reservationFilterLabel }}</span>
          <span class="ops-hero__stat-note">{{ __('Switch between active, completed and risk queues from the toolbar below') }}</span>
        </div>
      </div>
    </div>
  </div>

  <div class="ops-metric-grid">
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Total') }}</span>
      <span class="ops-metric__value">{{ number_format($metrics['total']) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Active') }}</span>
      <span class="ops-metric__value text-warning">{{ number_format($metrics['active']) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Completed') }}</span>
      <span class="ops-metric__value text-success">{{ number_format($metrics['completed']) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Expired') }}</span>
      <span class="ops-metric__value text-danger">{{ number_format($metrics['expired']) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Defaulted') }}</span>
      <span class="ops-metric__value text-danger">{{ number_format($metrics['defaulted']) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Active balance') }}</span>
      <span class="ops-metric__value">${{ number_format($metrics['active_remaining_total'], 2) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Due <24h') }}</span>
      <span class="ops-metric__value text-warning">{{ number_format($metrics['due_24h'] ?? 0) }}</span>
    </div>
    <div class="ops-metric">
      <span class="ops-metric__label">{{ __('Due <2h') }}</span>
      <span class="ops-metric__value text-danger">{{ number_format($metrics['due_2h'] ?? 0) }}</span>
    </div>
  </div>

  @if (!empty($decisionInsights['supported']))
    <div class="card ops-panel mb-4">
      <div class="card-header">
        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center">
          <div>
            <div class="card-title">{{ __('Refund decision insights') }}</div>
            <small class="text-muted">
              {{ __('Operational breakdown of refund reasons, risk flags and admins for the reservations currently in scope.') }}
            </small>
          </div>
          <form action="{{ route($indexRoute) }}" method="GET" class="mt-3 mt-lg-0">
            <input type="hidden" name="status" value="{{ $status }}">
            @if ($queryText !== '')
              <input type="hidden" name="q" value="{{ $queryText }}">
            @endif
            @if ($eventTitle !== '')
              <input type="hidden" name="event_title" value="{{ $eventTitle }}">
            @endif
            @if (!empty($eventId))
              <input type="hidden" name="event_id" value="{{ $eventId }}">
            @endif
            <input type="hidden" name="refund_state" value="{{ $refundState }}">
            <input type="hidden" name="due_state" value="{{ $dueState }}">
            <input type="hidden" name="refund_reason_code" value="{{ $refundReasonCode }}">
            <input type="hidden" name="refund_risk_flag" value="{{ $refundRiskFlag }}">
            <div class="d-flex align-items-end" style="gap: .75rem;">
              <div>
                <label class="mb-1">{{ __('Decision period') }}</label>
                <select name="decision_period" class="form-control form-control-sm">
                  @foreach (['7d' => __('Last 7 days'), '30d' => __('Last 30 days'), '90d' => __('Last 90 days'), 'all' => __('All time')] as $periodValue => $periodLabel)
                    <option value="{{ $periodValue }}" {{ $decisionPeriod === $periodValue ? 'selected' : '' }}>{{ $periodLabel }}</option>
                  @endforeach
                </select>
              </div>
              <button type="submit" class="btn btn-sm btn-outline-primary">{{ __('Apply') }}</button>
            </div>
          </form>
        </div>
      </div>
      <div class="card-body">
        <div class="ops-metric-grid mb-4">
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Refund decisions') }}</span>
            <span class="ops-metric__value">{{ number_format((int) ($decisionInsights['total_refund_decisions'] ?? 0)) }}</span>
            <span class="ops-metric__note">{{ $decisionInsights['selected_period_label'] ?? __('Last 30 days') }}</span>
          </div>
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Refunded gross') }}</span>
            <span class="ops-metric__value text-warning">${{ number_format((float) ($decisionInsights['total_refunded_gross'] ?? 0), 2) }}</span>
          </div>
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Treasury impact') }}</span>
            <span class="ops-metric__value text-danger">{{ number_format((int) ($decisionInsights['treasury_impact_count'] ?? 0)) }}</span>
            <span class="ops-metric__note">${{ number_format((float) ($decisionInsights['treasury_impact_gross'] ?? 0), 2) }}</span>
          </div>
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Gateway refunds') }}</span>
            <span class="ops-metric__value text-info">{{ number_format((int) ($decisionInsights['gateway_refund_count'] ?? 0)) }}</span>
          </div>
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Flagged decisions') }}</span>
            <span class="ops-metric__value text-warning">{{ number_format((int) ($decisionInsights['decisions_with_risk_flags_count'] ?? 0)) }}</span>
          </div>
          <div class="ops-metric">
            <span class="ops-metric__label">{{ __('Admins involved') }}</span>
            <span class="ops-metric__value">{{ number_format((int) ($decisionInsights['unique_admins_count'] ?? 0)) }}</span>
            @if (!empty($decisionInsights['latest_decision_at']))
              <span class="ops-metric__note">{{ __('Latest') }}: {{ $decisionInsights['latest_decision_at'] }}</span>
            @endif
          </div>
        </div>

        <div class="row">
          <div class="col-lg-4 mb-4 mb-lg-0">
            <h5 class="mb-3">{{ __('Top reasons') }}</h5>
            @if (!empty($decisionInsights['top_reasons']))
              <div class="d-flex flex-column" style="gap: .75rem;">
                @foreach ($decisionInsights['top_reasons'] as $item)
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <div class="font-weight-bold">{{ $item['label'] }}</div>
                      <small class="text-muted">{{ $item['code'] }}</small>
                    </div>
                    <span class="badge badge-primary">{{ $item['count'] }}</span>
                  </div>
                @endforeach
              </div>
            @else
              <p class="text-muted mb-0">{{ __('No refund decisions in the current scope yet.') }}</p>
            @endif
          </div>
          <div class="col-lg-4 mb-4 mb-lg-0">
            <h5 class="mb-3">{{ __('Top risk flags') }}</h5>
            @if (!empty($decisionInsights['top_risk_flags']))
              <div class="d-flex flex-column" style="gap: .75rem;">
                @foreach ($decisionInsights['top_risk_flags'] as $item)
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <div class="font-weight-bold">{{ $item['label'] }}</div>
                      <small class="text-muted">{{ $item['code'] }}</small>
                    </div>
                    <span class="badge badge-warning">{{ $item['count'] }}</span>
                  </div>
                @endforeach
              </div>
            @else
              <p class="text-muted mb-0">{{ __('No risk flags logged for the current scope.') }}</p>
            @endif
          </div>
          <div class="col-lg-4">
            <h5 class="mb-3">{{ __('Top admins') }}</h5>
            @if (!empty($decisionInsights['top_admins']))
              <div class="d-flex flex-column" style="gap: .75rem;">
                @foreach ($decisionInsights['top_admins'] as $item)
                  <div class="d-flex justify-content-between align-items-center">
                    <div class="font-weight-bold">{{ $item['label'] }}</div>
                    <span class="badge badge-success">{{ $item['count'] }}</span>
                  </div>
                @endforeach
              </div>
            @else
              <p class="text-muted mb-0">{{ __('No admin refund actions recorded in the current scope.') }}</p>
            @endif
          </div>
        </div>
      </div>
    </div>
  @endif

  <div class="card ops-panel">
      <div class="card-header">
        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center">
          <div>
            <div class="card-title">{{ __('Reservation Queue') }}</div>
            <small class="text-muted">{{ $queueDescription }}</small>
          </div>

          <div class="mt-3 mt-lg-0">
            <div class="d-flex flex-column flex-xl-row align-items-xl-center" style="gap: .75rem;">
              <div class="btn-group btn-group-sm" role="group">
                @foreach (['all' => 'primary', 'active' => 'warning', 'completed' => 'success', 'expired' => 'danger', 'defaulted' => 'danger'] as $filterStatus => $tone)
                  <a href="{{ route($indexRoute, array_merge(request()->except('page'), ['status' => $filterStatus])) }}"
                    class="btn btn-{{ $status === $filterStatus ? $tone : 'light' }}">
                    {{ ucfirst($filterStatus) }}
                  </a>
                @endforeach
              </div>
              @isset($exportRoute)
                <a href="{{ route($exportRoute, request()->except('page')) }}" class="btn btn-sm btn-outline-primary">
                  <i class="fas fa-file-download"></i> {{ __('Export CSV') }}
                </a>
              @endisset
            </div>
          </div>
        </div>
      </div>

      <div class="card-body">
        <form action="{{ route($indexRoute) }}" method="GET" class="mb-4">
          <input type="hidden" name="status" value="{{ $status }}">
          @if (!empty($eventId))
            <input type="hidden" name="event_id" value="{{ $eventId }}">
          @endif
          <div class="row ops-toolbar__grid">
            <div class="col-lg-3">
              <label>{{ __('Search reservation / customer') }}</label>
              <input type="text" class="form-control" name="q" value="{{ $queryText }}"
                placeholder="{{ __('Reservation code, customer name or email') }}">
            </div>
            <div class="col-lg-3">
              <label>{{ __('Event title') }}</label>
              <input type="text" class="form-control" name="event_title" value="{{ $eventTitle }}"
                placeholder="{{ __('Search by event title') }}">
            </div>
            <div class="col-lg-3">
              <label>{{ __('Refund state') }}</label>
              <select name="refund_state" class="form-control">
                <option value="all" {{ ($refundState ?? 'all') === 'all' ? 'selected' : '' }}>{{ __('All reservations') }}</option>
                <option value="refundable" {{ ($refundState ?? 'all') === 'refundable' ? 'selected' : '' }}>{{ __('Refundable only') }}</option>
                <option value="refunded" {{ ($refundState ?? 'all') === 'refunded' ? 'selected' : '' }}>{{ __('Refunded only') }}</option>
              </select>
            </div>
            <div class="col-lg-3">
              <label>{{ __('Due window') }}</label>
              <select name="due_state" class="form-control">
                <option value="all" {{ ($dueState ?? 'all') === 'all' ? 'selected' : '' }}>{{ __('All due states') }}</option>
                <option value="due_24h" {{ ($dueState ?? 'all') === 'due_24h' ? 'selected' : '' }}>{{ __('Due in less than 24h') }}</option>
                <option value="due_2h" {{ ($dueState ?? 'all') === 'due_2h' ? 'selected' : '' }}>{{ __('Due in less than 2h') }}</option>
              </select>
            </div>
            <input type="hidden" name="decision_period" value="{{ $decisionPeriod }}">
            @if ($showRefundDecisionFilters)
              <div class="col-lg-3 mt-3">
                <label>{{ __('Refund reason') }}</label>
                <select name="refund_reason_code" class="form-control">
                  <option value="all" {{ $refundReasonCode === 'all' ? 'selected' : '' }}>{{ __('All refund reasons') }}</option>
                  @foreach ($refundReasonOptions as $optionValue => $optionLabel)
                    <option value="{{ $optionValue }}" {{ $refundReasonCode === $optionValue ? 'selected' : '' }}>
                      {{ $optionLabel }}
                    </option>
                  @endforeach
                </select>
              </div>
              <div class="col-lg-3 mt-3">
                <label>{{ __('Risk flag') }}</label>
                <select name="refund_risk_flag" class="form-control">
                  <option value="all" {{ $refundRiskFlag === 'all' ? 'selected' : '' }}>{{ __('All risk flags') }}</option>
                  @foreach ($refundRiskFlagOptions as $optionValue => $optionLabel)
                    <option value="{{ $optionValue }}" {{ $refundRiskFlag === $optionValue ? 'selected' : '' }}>
                      {{ $optionLabel }}
                    </option>
                  @endforeach
                </select>
              </div>
            @endif
            <div class="col-lg-12 d-flex align-items-end mt-3">
              <button class="btn btn-primary mr-2" type="submit">
                <i class="fas fa-search"></i> {{ __('Search') }}
              </button>
              <a class="btn btn-light" href="{{ route($indexRoute, ['status' => $status, 'refund_state' => 'all', 'due_state' => 'all', 'refund_reason_code' => 'all', 'refund_risk_flag' => 'all', 'decision_period' => '30d']) }}">
                {{ __('Clear') }}
              </a>
            </div>
          </div>
        </form>

        @if (!empty($eventId))
          <div class="ops-inline-note mb-4">
            <strong>{{ __('Scoped to event #:id', ['id' => $eventId]) }}</strong>
            <span>{{ __('These results are coming from a direct settlement review link, so refund operations stay locked to a single event until you clear the filter.') }}</span>
          </div>
        @endif

        @if ($showRefundDecisionFilters && ($refundReasonCode !== 'all' || $refundRiskFlag !== 'all'))
          <div class="ops-inline-note mb-4">
            <strong>{{ __('Refund decision filters active') }}</strong>
            <span>
              {{ __('The queue is narrowed using structured refund governance metadata so support can work only the relevant risk cases.') }}
            </span>
          </div>
        @endif

        @if ($reservations->count() === 0)
          <div class="ops-empty">
            <h3>{{ __('No reservations found') }}</h3>
            <p>{{ __('Try another status or adjust the search terms.') }}</p>
          </div>
        @else
          <div class="table-responsive">
            <table class="table table-striped ops-table">
              <thead>
                <tr>
                  <th>{{ __('Reservation') }}</th>
                  <th>{{ __('Event') }}</th>
                  <th>{{ __('Customer') }}</th>
                  <th>{{ __('Qty') }}</th>
                  <th>{{ __('Total') }}</th>
                  <th>{{ __('Paid') }}</th>
                  <th>{{ __('Remaining') }}</th>
                  <th>{{ __('Due / Expires') }}</th>
                  <th>{{ __('Bookings') }}</th>
                  <th>{{ __('Actions') }}</th>
                </tr>
              </thead>
              <tbody>
                @foreach ($reservations as $reservation)
                  @php
                    $eventInfo = $reservation->event?->information;
                    if (empty($eventInfo) && !empty($reservation->event_id)) {
                        $eventInfo = \App\Models\Event\EventContent::where('event_id', $reservation->event_id)
                            ->where('language_id', optional($defaultLang)->id)
                            ->first() ?: \App\Models\Event\EventContent::where('event_id', $reservation->event_id)->first();
                    }

                    $customerLabel = trim((string) ($reservation->customer?->fname . ' ' . $reservation->customer?->lname));
                    if ($customerLabel === '') {
                        $customerLabel = trim((string) ($reservation->fname . ' ' . $reservation->lname));
                    }
                    if ($customerLabel === '') {
                        $customerLabel = $reservation->email ?: '-';
                    }

                    $statusClass = match ($reservation->status) {
                        'active' => 'warning',
                        'completed' => 'success',
                        'expired' => 'secondary',
                        'defaulted' => 'danger',
                        'cancelled' => 'dark',
                        default => 'light',
                    };

                    $grossPaid = round((float) $reservation->payments->sum('total_amount'), 2);
                    $bookingCount = $reservation->bookings->count();
                    $refundFinancials = $reservation->refund_financials ?? [];
                    $refundRefundable = $reservation->refund_refundable_summary ?? [];
                    $refundableGross = (float) ($refundRefundable['gross_amount'] ?? 0);
                    $refundedGross = (float) ($refundFinancials['refunded_gross'] ?? 0);
                    $lastAction = $reservation->actionLogs->first();
                    $lastActionClass = match ($lastAction?->action) {
                        'refund_processed' => 'warning',
                        'converted_to_bookings' => 'success',
                        'cancelled', 'marked_defaulted' => 'danger',
                        'reactivated', 'extended' => 'info',
                        default => 'light',
                    };
                  @endphp
                  <tr>
                    <td>
                      <div class="font-weight-bold">{{ $reservation->reservation_code }}</div>
                      <div class="mt-1 d-flex flex-wrap align-items-center" style="gap: .35rem;">
                        <span class="badge badge-{{ $statusClass }}">{{ ucfirst($reservation->status) }}</span>
                        @if (!empty($reservation->due_state_badge))
                          <span class="badge badge-{{ $reservation->due_state_badge['tone'] }}">
                            {{ $reservation->due_state_badge['label'] }}
                          </span>
                        @endif
                        @if ($lastAction)
                          <span class="badge badge-{{ $lastActionClass }}">
                            {{ ucwords(str_replace('_', ' ', $lastAction->action)) }}
                          </span>
                        @endif
                      </div>
                      <small class="text-muted d-block mt-2">{{ __('Created') }}: {{ FullDateTime($reservation->created_at) }}</small>
                      @if ($lastAction)
                        <small class="text-muted d-block mt-1">
                          {{ __('Last action') }}:
                          {{ FullDateTime($lastAction->created_at) }}
                          @if (!empty($lastAction->actor_type))
                            · {{ ucfirst((string) $lastAction->actor_type) }}
                          @endif
                        </small>
                      @endif
                    </td>
                    <td>
                      @if (!empty($eventInfo))
                        <a href="{{ route('event.details', ['slug' => $eventInfo->slug, 'id' => $eventInfo->event_id]) }}" target="_blank">
                          {{ $eventInfo->title }}
                        </a>
                      @else
                        <span>{{ __('Event') }} #{{ $reservation->event_id }}</span>
                      @endif
                      <small class="text-muted d-block mt-1">{{ __('Ticket') }}: {{ $reservation->ticket?->title ?: ('#' . $reservation->ticket_id) }}</small>
                    </td>
                    <td>
                      @if (!empty($customerDetailsRouteName) && $reservation->customer)
                        <a href="{{ route($customerDetailsRouteName, ['id' => $reservation->customer->id, 'language' => optional($defaultLang)->code]) }}">
                          {{ $customerLabel }}
                        </a>
                      @else
                        <span>{{ $customerLabel }}</span>
                      @endif
                      @if (!empty($reservation->email))
                        <small class="text-muted d-block mt-1">{{ $reservation->email }}</small>
                      @endif
                    </td>
                    <td>{{ $reservation->quantity }}</td>
                    <td>${{ number_format($reservation->total_amount, 2) }}</td>
                    <td>
                      <div>${{ number_format($reservation->amount_paid, 2) }}</div>
                      @if ($grossPaid > (float) $reservation->amount_paid)
                        <small class="text-muted d-block">{{ __('Gross') }}: ${{ number_format($grossPaid, 2) }}</small>
                      @endif
                      @if ($refundedGross > 0)
                        <small class="text-warning d-block">{{ __('Refunded') }}: ${{ number_format($refundedGross, 2) }}</small>
                      @endif
                    </td>
                    <td>
                      <div class="font-weight-bold {{ (float) $reservation->remaining_balance > 0 ? 'text-danger' : 'text-success' }}">
                        ${{ number_format((float) $reservation->remaining_balance, 2) }}
                      </div>
                      @if ($refundableGross > 0)
                        <small class="text-info d-block">{{ __('Refundable') }}: ${{ number_format($refundableGross, 2) }}</small>
                      @endif
                    </td>
                    <td>
                      <div>
                        <strong>{{ __('Final') }}:</strong>
                        {{ $reservation->final_due_date ? FullDateTime($reservation->final_due_date) : '-' }}
                      </div>
                      <small class="text-muted d-block mt-1">
                        <strong>{{ __('Expires') }}:</strong>
                        {{ $reservation->expires_at ? FullDateTime($reservation->expires_at) : '-' }}
                      </small>
                      @if (!empty($reservation->due_state_badge))
                        <small class="d-block mt-1 text-{{ $reservation->due_state_badge['tone'] }}">
                          {{ $reservation->due_state_badge['meta'] }}
                        </small>
                      @endif
                    </td>
                    <td>
                      @if ($bookingCount > 0)
                        <span class="badge badge-success">{{ $bookingCount }} {{ __('linked') }}</span>
                        @if ($bookingCount === 1)
                          <div class="mt-2">
                            <a href="{{ route($bookingDetailsRouteName, ['id' => $reservation->bookings->first()->id]) }}">
                              {{ __('Open booking') }}
                            </a>
                          </div>
                        @endif
                      @else
                        <span class="text-muted">{{ __('Pending conversion') }}</span>
                      @endif
                    </td>
                    <td>
                      <a href="{{ route($detailsRoute, ['id' => $reservation->id]) }}" class="btn btn-sm btn-primary">
                        {{ __('Details') }}
                      </a>
                    </td>
                  </tr>
                @endforeach
              </tbody>
            </table>
          </div>
        @endif
      </div>

      @if ($reservations->hasPages())
        <div class="card-footer">
          {{ $reservations->links() }}
        </div>
      @endif
  </div>
</div>
