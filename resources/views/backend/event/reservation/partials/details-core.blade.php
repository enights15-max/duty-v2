@php
  $eventInfo = $reservation->event?->information;
  if (empty($eventInfo) && !empty($reservation->event_id)) {
      $eventInfo = \App\Models\Event\EventContent::where('event_id', $reservation->event_id)
          ->where('language_id', optional($defaultLang)->id)
          ->first() ?: \App\Models\Event\EventContent::where('event_id', $reservation->event_id)->first();
  }

  $completedPayments = $reservation->payments
      ->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])
      ->where('status', 'completed')
      ->sortBy('paid_at')
      ->values();
  $refundPayments = $reservation->payments
      ->filter(fn ($payment) => str_ends_with((string) $payment->source_type, '_refund'))
      ->sortBy('paid_at')
      ->values();

  $timelineItems = collect([
      [
          'label' => __('Reservation created'),
          'timestamp' => $reservation->created_at,
          'note' => $reservation->reservation_code,
          'tone' => 'primary',
      ],
      [
          'label' => __('First payment captured'),
          'timestamp' => $completedPayments->first()?->paid_at,
          'note' => $completedPayments->isNotEmpty()
              ? '$' . number_format((float) $completedPayments->first()->total_amount, 2) . ' · ' . ucwords(str_replace('_', ' ', $completedPayments->first()->source_type))
              : null,
          'tone' => 'success',
      ],
      [
          'label' => __('Latest refund issued'),
          'timestamp' => $refundPayments->last()?->paid_at,
          'note' => $refundPayments->isNotEmpty()
              ? '$' . number_format(abs((float) $refundPayments->sum('total_amount')), 2) . ' ' . __('refunded so far')
              : null,
          'tone' => 'warning',
      ],
      [
          'label' => __('Reservation expires'),
          'timestamp' => $reservation->expires_at,
          'note' => $reservation->status === 'active' ? __('Active hold window') : ucfirst((string) $reservation->status),
          'tone' => 'secondary',
      ],
      [
          'label' => __('Converted into bookings'),
          'timestamp' => $reservation->bookings->sortBy('created_at')->first()?->created_at,
          'note' => $reservation->bookings->isNotEmpty()
              ? __('Linked bookings') . ': ' . $reservation->bookings->count()
              : null,
          'tone' => 'info',
      ],
  ])->filter(fn ($item) => !empty($item['timestamp']))->values();

  $actionLogs = $reservation->actionLogs ?? collect();
@endphp

<div class="card ops-panel">
  <div class="card-header d-flex justify-content-between align-items-center">
    <div>
      <div class="card-title mb-1">{{ $reservation->reservation_code }}</div>
      <span class="badge badge-{{ $statusClass }}">{{ ucfirst($reservation->status) }}</span>
    </div>
    <a class="btn btn-info btn-sm" href="{{ $backUrl }}">
      <i class="fas fa-backward"></i> {{ __('Back') }}
    </a>
  </div>
  <div class="card-body">
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Event') }}:</strong></div>
      <div class="col-lg-8">
        @if (!empty($eventInfo))
          <a href="{{ route('event.details', ['slug' => $eventInfo->slug, 'id' => $eventInfo->event_id]) }}" target="_blank">
            {{ $eventInfo->title }}
          </a>
        @else
          {{ __('Event') }} #{{ $reservation->event_id }}
        @endif
      </div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Ticket') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->ticket?->title ?: ('#' . $reservation->ticket_id) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Created at') }}:</strong></div>
      <div class="col-lg-8">{{ FullDateTime($reservation->created_at) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Event date') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->event_date ?: '-' }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Quantity') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->quantity }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Reserved unit price') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($reservation->reserved_unit_price, 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Reservation total') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($reservation->total_amount, 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Deposit required') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($reservation->deposit_required, 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Amount paid') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($financials['base_paid'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Processing fees paid') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($financials['fees_paid'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Gross customer paid') }}:</strong></div>
      <div class="col-lg-8">${{ number_format($financials['gross_paid'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Remaining balance') }}:</strong></div>
      <div class="col-lg-8 text-danger">${{ number_format($financials['remaining_balance'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Refunded base') }}:</strong></div>
      <div class="col-lg-8 text-warning">${{ number_format($financials['refunded_base'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Refunded fees') }}:</strong></div>
      <div class="col-lg-8 text-warning">${{ number_format($financials['refunded_fees'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Refunded gross') }}:</strong></div>
      <div class="col-lg-8 text-warning">${{ number_format($financials['refunded_gross'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Net collected') }}:</strong></div>
      <div class="col-lg-8 text-success">${{ number_format($financials['net_collected'], 2) }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Final due date') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->final_due_date ? FullDateTime($reservation->final_due_date) : '-' }}</div>
    </div>
    <div class="row">
      <div class="col-lg-4"><strong>{{ __('Reservation expires') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->expires_at ? FullDateTime($reservation->expires_at) : '-' }}</div>
    </div>
  </div>
</div>

<div class="card ops-panel">
  <div class="card-header">
    <div class="card-title">{{ __('Reservation Timeline') }}</div>
  </div>
  <div class="card-body">
    @if ($timelineItems->isEmpty())
      <div class="ops-empty">
        <h3>{{ __('No timeline markers yet') }}</h3>
        <p>{{ __('This reservation has not generated enough lifecycle signals to build a timeline yet.') }}</p>
      </div>
    @else
      <div class="timeline timeline-style-1">
        @foreach ($timelineItems as $timelineItem)
          <div class="timeline-item">
            <div class="timeline-badge bg-{{ $timelineItem['tone'] }}"></div>
            <div class="timeline-panel">
              <div class="timeline-heading">
                <h6 class="timeline-title mb-1">{{ $timelineItem['label'] }}</h6>
                <small class="text-muted">{{ FullDateTime($timelineItem['timestamp']) }}</small>
              </div>
              @if (!empty($timelineItem['note']))
                <div class="timeline-body mt-2">
                  <p class="mb-0 text-muted">{{ $timelineItem['note'] }}</p>
                </div>
              @endif
            </div>
          </div>
        @endforeach
      </div>
    @endif
  </div>
</div>

<div class="card ops-panel">
  <div class="card-header">
    <div class="card-title">{{ __('Action Audit') }}</div>
  </div>
  <div class="card-body">
    @if ($actionLogs->isEmpty())
      <div class="ops-empty">
        <h3>{{ __('No manual actions logged') }}</h3>
        <p>{{ __('Operational actions such as refunds, extensions or conversions will appear here once they happen.') }}</p>
      </div>
    @else
      <div class="timeline timeline-style-1">
        @foreach ($actionLogs as $log)
          @php
            $actionTone = match ($log->action) {
                'refund_processed' => 'warning',
                'converted_to_bookings' => 'success',
                'cancelled', 'marked_defaulted' => 'danger',
                'reactivated' => 'info',
                default => 'primary',
            };
            $actorLabel = $log->actor_type ? ucfirst((string) $log->actor_type) : __('System');
            $noteParts = collect([
                !empty($log->meta['gross_amount']) ? '$' . number_format((float) $log->meta['gross_amount'], 2) : null,
                !empty($log->meta['booking_count']) ? __('Bookings') . ': ' . $log->meta['booking_count'] : null,
                !empty($log->meta['expires_at']) ? __('Expires') . ': ' . $log->meta['expires_at'] : null,
                !empty($log->meta['final_due_date']) ? __('Final due') . ': ' . $log->meta['final_due_date'] : null,
            ])->filter()->implode(' · ');
            $refundReasonLabel = data_get($log->meta, 'refund_reason_label');
            $refundRiskLabel = collect((array) data_get($log->meta, 'refund_risk_flag_labels', []))->implode(', ');
            $refundAdminNote = data_get($log->meta, 'refund_admin_note');
          @endphp
          <div class="timeline-item">
            <div class="timeline-badge bg-{{ $actionTone }}"></div>
            <div class="timeline-panel">
              <div class="timeline-heading">
                <h6 class="timeline-title mb-1">{{ ucwords(str_replace('_', ' ', $log->action)) }}</h6>
                <small class="text-muted">{{ $actorLabel }} · {{ FullDateTime($log->created_at) }}</small>
              </div>
              @if ($noteParts !== '')
                <div class="timeline-body mt-2">
                  <p class="mb-0 text-muted">{{ $noteParts }}</p>
                </div>
              @endif
              @if ($refundReasonLabel || $refundRiskLabel || $refundAdminNote)
                <div class="timeline-body mt-2">
                  @if ($refundReasonLabel)
                    <p class="mb-1 text-muted"><strong>{{ __('Reason') }}:</strong> {{ $refundReasonLabel }}</p>
                  @endif
                  @if ($refundRiskLabel !== '')
                    <p class="mb-1 text-muted"><strong>{{ __('Risk flags') }}:</strong> {{ $refundRiskLabel }}</p>
                  @endif
                  @if ($refundAdminNote)
                    <p class="mb-0 text-muted"><strong>{{ __('Admin note') }}:</strong> {{ $refundAdminNote }}</p>
                  @endif
                </div>
              @endif
            </div>
          </div>
        @endforeach
      </div>
    @endif
  </div>
</div>

<div class="card ops-panel">
  <div class="card-header">
    <div class="card-title">{{ __('Customer Snapshot') }}</div>
  </div>
  <div class="card-body">
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Customer') }}:</strong></div>
      <div class="col-lg-8">
        @if (!empty($customerDetailsRouteName) && $reservation->customer)
          <a href="{{ route($customerDetailsRouteName, ['id' => $reservation->customer->id, 'language' => optional($defaultLang)->code]) }}">
            {{ trim(($reservation->customer->fname ?: '') . ' ' . ($reservation->customer->lname ?: '')) ?: ($reservation->customer->email ?: '-') }}
          </a>
        @else
          {{ trim(($reservation->customer?->fname ?: $reservation->fname ?: '') . ' ' . ($reservation->customer?->lname ?: $reservation->lname ?: '')) ?: '-' }}
        @endif
      </div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Email') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->email ?: ($reservation->customer?->email ?: '-') }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Phone') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->phone ?: '-' }}</div>
    </div>
    <div class="row mb-2">
      <div class="col-lg-4"><strong>{{ __('Address') }}:</strong></div>
      <div class="col-lg-8">{{ $reservation->address ?: '-' }}</div>
    </div>
    <div class="row">
      <div class="col-lg-4"><strong>{{ __('Location') }}:</strong></div>
      <div class="col-lg-8">
        {{ collect([$reservation->city, $reservation->state, $reservation->country, $reservation->zip_code])->filter()->implode(', ') ?: '-' }}
      </div>
    </div>
  </div>
</div>

<div class="card ops-panel">
  <div class="card-header">
    <div class="card-title">{{ __('Reservation Payments') }}</div>
  </div>
  <div class="card-body">
    @if ($reservation->payments->isEmpty())
      <div class="ops-empty">
        <h3>{{ __('No payment rows recorded') }}</h3>
        <p>{{ __('Captured deposit rows and later installments will surface here as soon as they are created.') }}</p>
      </div>
    @else
      <div class="table-responsive">
        <table class="table table-striped ops-table">
          <thead>
            <tr>
              <th>{{ __('Group') }}</th>
              <th>{{ __('Source') }}</th>
              <th>{{ __('Amount') }}</th>
              <th>{{ __('Fee') }}</th>
              <th>{{ __('Total') }}</th>
              <th>{{ __('Status') }}</th>
              <th>{{ __('Paid at') }}</th>
            </tr>
          </thead>
          <tbody>
            @foreach ($reservation->payments as $payment)
              <tr>
                <td>{{ $payment->payment_group }}</td>
                <td>{{ ucwords(str_replace('_', ' ', $payment->source_type)) }}</td>
                <td>${{ number_format($payment->amount, 2) }}</td>
                <td>${{ number_format($payment->fee_amount, 2) }}</td>
                <td>${{ number_format($payment->total_amount, 2) }}</td>
                <td>
                  <span class="badge badge-{{ $payment->status === 'reversed' ? 'warning' : 'success' }}">
                    {{ ucfirst($payment->status) }}
                  </span>
                </td>
                <td>{{ $payment->paid_at ? FullDateTime($payment->paid_at) : '-' }}</td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>
    @endif

    @if ($paymentSummary->isNotEmpty())
      <div class="row mt-4">
        @foreach ($paymentSummary as $sourceType => $summary)
          <div class="col-md-4 mb-3">
            <div class="p-3 border rounded h-100">
              <h5 class="mb-2">{{ ucwords(str_replace('_', ' ', $sourceType)) }}</h5>
              <div><strong>{{ __('Base') }}:</strong> ${{ number_format($summary['amount'], 2) }}</div>
              <div><strong>{{ __('Fee') }}:</strong> ${{ number_format($summary['fee_amount'], 2) }}</div>
              <div><strong>{{ __('Total') }}:</strong> ${{ number_format($summary['total_amount'], 2) }}</div>
            </div>
          </div>
        @endforeach
      </div>
    @endif

    @if ($refundSummary->isNotEmpty())
      <div class="mt-3 pt-3 border-top">
        <h5 class="mb-3">{{ __('Refunds already issued') }}</h5>
        <div class="row">
          @foreach ($refundSummary as $sourceType => $summary)
            <div class="col-md-4 mb-3">
              <div class="p-3 border rounded h-100 bg-light">
                <h5 class="mb-2">{{ ucwords(str_replace('_', ' ', $sourceType)) }}</h5>
                <div><strong>{{ __('Base refunded') }}:</strong> ${{ number_format($summary['amount'], 2) }}</div>
                <div><strong>{{ __('Fees refunded') }}:</strong> ${{ number_format($summary['fee_amount'], 2) }}</div>
                <div><strong>{{ __('Gross refunded') }}:</strong> ${{ number_format($summary['total_amount'], 2) }}</div>
              </div>
            </div>
          @endforeach
        </div>
      </div>
    @endif

    @if ($refundableSummary['by_source']->isNotEmpty())
      <div class="mt-3 pt-3 border-top">
        <h5 class="mb-3">{{ __('Refundable right now') }}</h5>
        <div class="row">
          @foreach ($refundableSummary['by_source'] as $sourceType => $summary)
            <div class="col-md-4 mb-3">
              <div class="p-3 border rounded h-100 bg-light">
                <h5 class="mb-2">{{ ucwords(str_replace('_', ' ', $sourceType)) }}</h5>
                <div><strong>{{ __('Base pending') }}:</strong> ${{ number_format($summary['amount'], 2) }}</div>
                <div><strong>{{ __('Fees pending') }}:</strong> ${{ number_format($summary['fee_amount'], 2) }}</div>
                <div><strong>{{ __('Gross pending') }}:</strong> ${{ number_format($summary['total_amount'], 2) }}</div>
              </div>
            </div>
          @endforeach
        </div>
      </div>
    @endif
  </div>
</div>

<div class="card ops-panel">
  <div class="card-header">
    <div class="card-title">{{ __('Linked Bookings') }}</div>
  </div>
  <div class="card-body">
    @if ($reservation->bookings->isEmpty())
      <div class="ops-empty">
        <h3>{{ __('No linked bookings yet') }}</h3>
        <p>{{ __('This reservation is still pending conversion, so booking records have not been created yet.') }}</p>
      </div>
    @else
      <div class="table-responsive">
        <table class="table table-striped ops-table">
          <thead>
            <tr>
              <th>{{ __('Booking ID') }}</th>
              <th>{{ __('Order') }}</th>
              <th>{{ __('Payment Status') }}</th>
              <th>{{ __('Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            @foreach ($reservation->bookings as $booking)
              <tr>
                <td>#{{ $booking->booking_id }}</td>
                <td>{{ $booking->order_number }}</td>
                <td>{{ paymentStatusLabel($booking->paymentStatus) }}</td>
                <td>
                  <a href="{{ route($bookingDetailsRouteName, ['id' => $booking->id]) }}" class="btn btn-sm btn-primary">
                    {{ __('Open booking') }}
                  </a>
                </td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>
    @endif
  </div>
</div>
