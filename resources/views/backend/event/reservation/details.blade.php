@extends('backend.layout')

@section('style')
  @includeIf('backend.partials.scarlet-operations-workspace')
@endsection

@section('content')
  @php
    $eventInfo = $reservation->event?->information;
    if (empty($eventInfo) && !empty($reservation->event_id)) {
        $eventInfo = \App\Models\Event\EventContent::where('event_id', $reservation->event_id)
            ->where('language_id', optional($defaultLang)->id)
            ->first() ?: \App\Models\Event\EventContent::where('event_id', $reservation->event_id)->first();
    }

    $statusClass = match ($reservation->status) {
        'active' => 'warning',
        'completed' => 'success',
        'expired' => 'secondary',
        'defaulted' => 'danger',
        'cancelled' => 'dark',
        default => 'light',
      };

      $reservationScopeLabel = match ($reservation->status) {
          'active' => __('Active hold'),
          'completed' => __('Converted'),
          'expired' => __('Expired'),
          'defaulted' => __('Defaulted'),
          'cancelled' => __('Cancelled'),
          default => __('Reservation'),
      };
  @endphp

  <div class="page-header">
    <h4 class="page-title">{{ __('Reservation Details') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('admin.dashboard') }}">
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
        <a href="{{ route('admin.event_reservation.index', ['status' => 'all']) }}">{{ __('Reservations') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ $reservation->reservation_code }}</a>
      </li>
    </ul>
  </div>

  <div class="ops-shell">
    <div class="ops-hero">
      <div class="ops-hero__grid">
        <div>
          <span class="ops-hero__eyebrow">{{ __('Reservations') }}</span>
          <h1 class="ops-hero__title">{{ __('Lifecycle and refund control') }}</h1>
          <p class="ops-hero__copy">
            {{ __('Review the reservation timeline, track captured amounts and process operational actions without losing treasury context.') }}
          </p>
        </div>
        <div class="ops-hero__meta">
          <div class="ops-hero__stat">
            <span class="ops-hero__stat-label">{{ __('Reservation code') }}</span>
            <span class="ops-hero__stat-value">{{ $reservation->reservation_code }}</span>
            <span class="ops-hero__stat-note">{{ __('Primary support reference for this hold') }}</span>
          </div>
          <div class="ops-hero__stat">
            <span class="ops-hero__stat-label">{{ __('Current state') }}</span>
            <span class="ops-hero__stat-value">{{ $reservationScopeLabel }}</span>
            <span class="ops-hero__stat-note">{{ __('Use the action panel to extend, refund or convert when the queue requires it') }}</span>
          </div>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-lg-8">
        @include('backend.event.reservation.partials.details-core', [
          'backUrl' => route('admin.event_reservation.index', ['status' => 'all']),
          'bookingDetailsRouteName' => 'admin.event_booking.details',
          'customerDetailsRouteName' => 'admin.customer_management.customer_details',
        ])
      </div>

      <div class="col-lg-4">
        <div class="card ops-panel">
          <div class="card-header">
            <div class="card-title">{{ __('Admin Actions') }}</div>
          </div>
          <div class="card-body">
            <div class="ops-note">
              {{ __('Cancelling or defaulting a reservation releases inventory when applicable. Refunds are processed manually from this panel and only for cancelled/defaulted reservations.') }}
            </div>

            @if ($actions['can_refund'])
              <form action="{{ route('admin.event_reservation.refund', ['id' => $reservation->id]) }}" method="POST" class="mb-4"
                onsubmit="return confirm('{{ __('Process the selected refund amounts now? Leave all fields empty to refund the full remaining balance.') }}')">
                @csrf
                <h5 class="mb-2">{{ __('Issue refund') }}</h5>
                <p class="text-muted mb-3">
                  {{ __('Enter only the sources you want to refund. If every field is left empty, the system will refund the full remaining balance back to the original sources.') }}
                </p>
                <div class="mb-3">
                  <strong>{{ __('Refundable gross right now') }}:</strong>
                  ${{ number_format((float) ($refundableSummary['gross_amount'] ?? 0), 2) }}
                </div>
                <div class="mb-3">
                  <div class="d-flex flex-wrap">
                    <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-all" data-refund-percent="25">25%</button>
                    <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-all" data-refund-percent="50">50%</button>
                    <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-all" data-refund-percent="100">{{ __('Full refund') }}</button>
                    <button type="button" class="btn btn-sm btn-outline-secondary mb-2 js-refund-preset-clear">{{ __('Clear') }}</button>
                  </div>
                  <small class="form-text text-muted">
                    {{ __('Quick presets fill every refundable source proportionally. You can still adjust each field manually afterwards.') }}
                  </small>
                </div>
                <div class="form-group">
                  <label>{{ __('Refund reason') }}</label>
                  <select class="form-control" name="refund_reason_code" required>
                    <option value="">{{ __('Select a reason') }}</option>
                    @foreach (($refundReasonOptions ?? []) as $reasonCode => $reasonLabel)
                      <option value="{{ $reasonCode }}" {{ old('refund_reason_code') === $reasonCode ? 'selected' : '' }}>
                        {{ __($reasonLabel) }}
                      </option>
                    @endforeach
                  </select>
                  <small class="form-text text-muted">
                    {{ __('Every admin refund must be classified so ops and finance can reconstruct why the money left the event treasury.') }}
                  </small>
                </div>
                <div class="form-group">
                  <label>{{ __('Risk flags') }}</label>
                  <div class="d-flex flex-wrap" style="gap: 8px 16px;">
                    @foreach (($refundRiskFlagOptions ?? []) as $riskCode => $riskLabel)
                      <label class="mb-0 d-inline-flex align-items-center" style="gap: 8px;">
                        <input type="checkbox" name="refund_risk_flags[]" value="{{ $riskCode }}"
                          {{ in_array($riskCode, (array) old('refund_risk_flags', []), true) ? 'checked' : '' }}>
                        <span>{{ __($riskLabel) }}</span>
                      </label>
                    @endforeach
                  </div>
                  <small class="form-text text-muted">
                    {{ __('Use flags when the refund needs extra follow-up in treasury, gateway reconciliation or customer support.') }}
                  </small>
                </div>
                <div class="form-group">
                  <label>{{ __('Admin note') }}</label>
                  <textarea class="form-control" name="refund_admin_note" rows="3" maxlength="1000" required
                    placeholder="{{ __('Explain briefly why this refund is being processed and any follow-up that ops should know about.') }}">{{ old('refund_admin_note') }}</textarea>
                  <small class="form-text text-muted">
                    {{ __('Minimum note length') }}:
                    {{ data_get($refundGovernanceRules, 'min_admin_note_length', 12) }}
                    {{ __('characters. Goodwill/dispute cases require at least') }}
                    {{ data_get($refundGovernanceRules, 'complex_admin_note_length', 24) }}
                    {{ __('characters.') }}
                  </small>
                </div>
                @if (!empty(data_get($refundGovernanceRules, 'rules', [])))
                  <div class="ops-inline-note mb-3">
                    <strong>{{ __('Refund governance rules') }}</strong>
                    <div class="mt-2">
                      @foreach ((array) data_get($refundGovernanceRules, 'rules', []) as $governanceRule)
                        <div class="text-muted mb-1">• {{ data_get($governanceRule, 'label') }}</div>
                      @endforeach
                    </div>
                  </div>
                @endif
                @foreach (['bonus_wallet', 'wallet', 'card'] as $refundSource)
                  @php
                    $sourceSummary = $refundableSummary['by_source']->get($refundSource);
                    $oldInput = old('refund_' . $refundSource);
                  @endphp
                  @if (!empty($sourceSummary) && (float) ($sourceSummary['total_amount'] ?? 0) > 0)
                    <div class="form-group">
                      <label>{{ ucwords(str_replace('_', ' ', $refundSource)) }}</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        max="{{ number_format((float) $sourceSummary['total_amount'], 2, '.', '') }}"
                        class="form-control"
                        name="refund_{{ $refundSource }}"
                        data-refund-source="{{ $refundSource }}"
                        data-refund-max="{{ number_format((float) $sourceSummary['total_amount'], 2, '.', '') }}"
                        value="{{ $oldInput }}"
                        placeholder="{{ number_format((float) $sourceSummary['total_amount'], 2, '.', '') }}">
                      <small class="form-text text-muted">
                        {{ __('Refundable now') }}: ${{ number_format((float) $sourceSummary['total_amount'], 2) }}
                        @if ((float) ($sourceSummary['fee_amount'] ?? 0) > 0)
                          | {{ __('Includes fees') }}: ${{ number_format((float) $sourceSummary['fee_amount'], 2) }}
                        @endif
                      </small>
                      <div class="mt-2 d-flex flex-wrap">
                        <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-source" data-refund-percent="25" data-refund-target="{{ $refundSource }}">25%</button>
                        <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-source" data-refund-percent="50" data-refund-target="{{ $refundSource }}">50%</button>
                        <button type="button" class="btn btn-sm btn-light mr-2 mb-2 js-refund-preset-source" data-refund-percent="100" data-refund-target="{{ $refundSource }}">{{ __('Full') }}</button>
                      </div>
                    </div>
                  @endif
                @endforeach
                <button class="btn btn-outline-warning btn-block" type="submit">{{ __('Process refund') }}</button>
              </form>
            @endif

            @if ($actions['can_extend'])
              <form action="{{ route('admin.event_reservation.extend', ['id' => $reservation->id]) }}" method="POST" class="mb-4">
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
              <form action="{{ route('admin.event_reservation.reactivate', ['id' => $reservation->id]) }}" method="POST" class="mb-4">
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
              <form action="{{ route('admin.event_reservation.convert', ['id' => $reservation->id]) }}" method="POST" class="mb-4"
                onsubmit="return confirm('{{ __('Convert this reservation into bookings now?') }}')">
                @csrf
                <button class="btn btn-success btn-block" type="submit">{{ __('Convert into bookings') }}</button>
              </form>
            @endif

            @if ($actions['can_default'])
              <form action="{{ route('admin.event_reservation.default', ['id' => $reservation->id]) }}" method="POST" class="mb-3"
                onsubmit="return confirm('{{ __('Mark this reservation as defaulted?') }}')">
                @csrf
                <button class="btn btn-danger btn-block" type="submit">{{ __('Mark defaulted') }}</button>
              </form>
            @endif

            @if ($actions['can_cancel'])
              <form action="{{ route('admin.event_reservation.cancel', ['id' => $reservation->id]) }}" method="POST"
                onsubmit="return confirm('{{ __('Cancel this reservation? You can issue the refund afterwards from this same panel.') }}')">
                @csrf
                <button class="btn btn-outline-danger btn-block" type="submit">{{ __('Cancel reservation') }}</button>
              </form>
            @endif

            @if (!$actions['can_refund'] && !$actions['can_extend'] && !$actions['can_reactivate'] && !$actions['can_convert'] && !$actions['can_default'] && !$actions['can_cancel'])
              <p class="text-muted mb-0">{{ __('No admin actions are available for the current reservation state.') }}</p>
            @endif
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection

@section('script')
  <script>
    (function () {
      const sourceInputs = Array.from(document.querySelectorAll('[data-refund-source]'));
      if (!sourceInputs.length) {
        return;
      }

      const formatAmount = (value) => {
        const numeric = Number(value || 0);
        return numeric > 0 ? numeric.toFixed(2) : '';
      };

      const applyPercentToInput = (input, percent) => {
        const max = Number(input.dataset.refundMax || 0);
        if (max <= 0) {
          input.value = '';
          return;
        }

        const amount = (max * percent) / 100;
        input.value = formatAmount(Math.min(max, amount));
      };

      document.querySelectorAll('.js-refund-preset-all').forEach((button) => {
        button.addEventListener('click', function () {
          const percent = Number(this.dataset.refundPercent || 0);
          sourceInputs.forEach((input) => applyPercentToInput(input, percent));
        });
      });

      document.querySelectorAll('.js-refund-preset-source').forEach((button) => {
        button.addEventListener('click', function () {
          const target = this.dataset.refundTarget;
          const percent = Number(this.dataset.refundPercent || 0);
          const input = document.querySelector('[data-refund-source="' + target + '"]');
          if (input) {
            applyPercentToInput(input, percent);
          }
        });
      });

      const clearButton = document.querySelector('.js-refund-preset-clear');
      if (clearButton) {
        clearButton.addEventListener('click', function () {
          sourceInputs.forEach((input) => {
            input.value = '';
          });
        });
      }
    })();
  </script>
@endsection
