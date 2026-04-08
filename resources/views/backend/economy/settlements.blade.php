@extends('backend.layout')

@php
  $money = function ($value) use ($currencyInfo) {
      $amount = number_format((float) $value, 2);
      return ($currencyInfo->base_currency_symbol_position ?? 'left') === 'left'
          ? ($currencyInfo->base_currency_symbol ?? 'RD$') . ' ' . $amount
          : $amount . ' ' . ($currencyInfo->base_currency_symbol ?? 'RD$');
  };
@endphp

@section('style')
  @include('backend.partials.scarlet-operations-workspace')
  <style>
    .settlement-filters {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px;
    }

    .settlement-detail-grid {
      display: grid;
      grid-template-columns: minmax(0, 1.25fr) minmax(320px, 0.9fr);
      gap: 20px;
    }

    .settlement-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 12px;
      border-radius: 999px;
      font-size: 0.82rem;
      font-weight: 700;
      letter-spacing: 0.01em;
      background: rgba(193, 18, 31, 0.08);
      color: var(--ops-primary);
      border: 1px solid rgba(193, 18, 31, 0.12);
    }

    .settlement-pill--success {
      background: rgba(35, 138, 87, 0.1);
      color: var(--ops-success);
      border-color: rgba(35, 138, 87, 0.18);
    }

    .settlement-pill--warning {
      background: rgba(198, 133, 0, 0.12);
      color: var(--ops-warning);
      border-color: rgba(198, 133, 0, 0.18);
    }

    .settlement-pill--danger {
      background: rgba(211, 47, 47, 0.1);
      color: var(--ops-danger);
      border-color: rgba(211, 47, 47, 0.18);
    }

    .settlement-kpi-note {
      color: var(--ops-muted);
      font-size: 0.82rem;
      line-height: 1.55;
    }

    .settlement-owner {
      display: grid;
      gap: 4px;
    }

    .settlement-owner strong {
      color: var(--ops-ink);
    }

    .settlement-owner small,
    .settlement-metadata,
    .settlement-entry-meta {
      color: var(--ops-muted);
    }

    .settlement-detail-block {
      display: grid;
      gap: 14px;
    }

    .settlement-stat-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 12px;
    }

    .settlement-stat {
      padding: 16px;
      border-radius: 18px;
      border: 1px solid rgba(22, 18, 26, 0.08);
      background: rgba(255, 255, 255, 0.72);
      display: grid;
      gap: 6px;
    }

    body[data-background-color='dark'] .settlement-stat {
      border-color: rgba(255, 255, 255, 0.08);
      background: rgba(255, 255, 255, 0.03);
    }

    .settlement-entry-list,
    .settlement-activity-list {
      display: grid;
      gap: 12px;
    }

    .settlement-entry,
    .settlement-activity {
      padding: 14px 16px;
      border-radius: 16px;
      border: 1px solid rgba(22, 18, 26, 0.08);
      background: rgba(255, 255, 255, 0.68);
    }

    body[data-background-color='dark'] .settlement-entry,
    body[data-background-color='dark'] .settlement-activity {
      border-color: rgba(255, 255, 255, 0.08);
      background: rgba(255, 255, 255, 0.03);
    }

    .settlement-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .settlement-reconciliation {
      display: grid;
      gap: 10px;
    }

    .settlement-reconciliation__row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      padding: 10px 0;
      border-bottom: 1px dashed rgba(22, 18, 26, 0.1);
    }

    .settlement-reconciliation__row:last-child {
      border-bottom: none;
      padding-bottom: 0;
    }

    .settlement-reconciliation__row strong {
      color: var(--ops-ink);
    }

    .settlement-reconciliation__row--emphasis strong:last-child {
      font-size: 1rem;
    }

    .settlement-reconciliation__hint {
      color: var(--ops-muted);
      font-size: 0.82rem;
      line-height: 1.55;
    }

    .settlement-empty {
      padding: 18px;
      border-radius: 18px;
      border: 1px dashed rgba(22, 18, 26, 0.12);
      color: var(--ops-muted);
      background: rgba(255, 255, 255, 0.58);
    }

    body[data-background-color='dark'] .settlement-empty {
      border-color: rgba(255, 255, 255, 0.12);
      background: rgba(255, 255, 255, 0.02);
    }

    @media (max-width: 991px) {
      .settlement-detail-grid {
        grid-template-columns: 1fr;
      }
    }
  </style>
@endsection

@section('content')
  <div class="ops-shell">
    <div class="ops-hero">
      <div class="ops-hero__eyebrow">{{ __('Financial Operations') }}</div>
      <h1>{{ __('Settlement Review') }}</h1>
      <p>{{ __('Supervisa tesorerías por evento, valida ventanas de retención, aprueba liberaciones y ejecuta payouts al wallet del owner cuando el caso ya esté listo.') }}</p>
      <div class="ops-hero__meta">
        <span class="settlement-pill">{{ __('Treasury queue') }}</span>
        <span class="settlement-pill settlement-pill--warning">{{ __('Refund-sensitive operations') }}</span>
        <a href="{{ route('admin.event_booking.economy') }}" class="btn btn-light btn-sm">{{ __('Back to economy dashboard') }}</a>
      </div>
    </div>

    <div class="ops-metric-grid">
      <div class="ops-metric-card">
        <div class="ops-metric-card__label">{{ __('Tracked treasuries') }}</div>
        <div class="ops-metric-card__value">{{ number_format((int) ($summaryCards['total_events'] ?? 0)) }}</div>
        <div class="settlement-kpi-note">{{ __('Eventos con presupuesto independiente dentro del filtro actual.') }}</div>
      </div>
      <div class="ops-metric-card">
        <div class="ops-metric-card__label">{{ __('Settlement hold') }}</div>
        <div class="ops-metric-card__value">{{ number_format((int) ($summaryCards['holding_count'] ?? 0)) }}</div>
        <div class="settlement-kpi-note">{{ __('Incluye refund windows, holds manuales y eventos todavía bloqueados por aprobación.') }}</div>
      </div>
      <div class="ops-metric-card">
        <div class="ops-metric-card__label">{{ __('Ready to release') }}</div>
        <div class="ops-metric-card__value">{{ number_format((int) ($summaryCards['ready_count'] ?? 0)) }}</div>
        <div class="settlement-kpi-note">{{ __('Treasuries con monto reclamable y estado elegible para payout.') }}</div>
      </div>
      <div class="ops-metric-card">
        <div class="ops-metric-card__label">{{ __('Claimable total') }}</div>
        <div class="ops-metric-card__value">{{ $money($summaryCards['claimable_total'] ?? 0) }}</div>
        <div class="settlement-kpi-note">{{ __('Monto total que podría liberarse desde esta cola si todos los casos estuvieran aprobados.') }}</div>
      </div>
    </div>

    <div class="card ops-panel">
      <div class="card-header">
        <div>
          <div class="card-title mb-1">{{ __('Queue filters') }}</div>
          <p class="mb-0 text-muted">{{ __('Refina la cola por estado financiero, necesidad de aprobación o tipo de owner antes de entrar al detalle.') }}</p>
        </div>
      </div>
      <div class="card-body">
        <form method="GET" action="{{ route('admin.event_booking.economy.settlements') }}">
          <div class="settlement-filters">
            <div class="form-group mb-0">
              <label>{{ __('Search event') }}</label>
              <input type="text" class="form-control" name="search" value="{{ $filters['search'] }}" placeholder="{{ __('Event title') }}">
            </div>
            <div class="form-group mb-0">
              <label>{{ __('Settlement status') }}</label>
              <select class="form-control" name="status">
                @foreach ($statusOptions as $value => $label)
                  <option value="{{ $value }}" {{ $filters['status'] === $value ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
              </select>
            </div>
            <div class="form-group mb-0">
              <label>{{ __('Approval state') }}</label>
              <select class="form-control" name="approval">
                @foreach ($approvalOptions as $value => $label)
                  <option value="{{ $value }}" {{ $filters['approval'] === $value ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
              </select>
            </div>
            <div class="form-group mb-0">
              <label>{{ __('Owner type') }}</label>
              <select class="form-control" name="owner_type">
                @foreach ($ownerTypeOptions as $value => $label)
                  <option value="{{ $value }}" {{ $filters['owner_type'] === $value ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
              </select>
            </div>
          </div>
          <div class="mt-3 d-flex flex-wrap" style="gap: 8px;">
            <button type="submit" class="btn btn-primary">{{ __('Apply filters') }}</button>
            <a href="{{ route('admin.event_booking.economy.settlements') }}" class="btn btn-light">{{ __('Reset') }}</a>
            <a href="{{ route('admin.event_booking.economy.settlements.export', request()->query()) }}" class="btn btn-outline-secondary">{{ __('Export queue CSV') }}</a>
          </div>
        </form>
      </div>
    </div>

	      <div class="settlement-detail-grid">
	          <div class="card ops-panel">
        <div class="card-header">
          <div>
            <div class="card-title mb-1">{{ __('Settlement queue') }}</div>
            <p class="mb-0 text-muted">{{ __('Cada fila resume ownership, estado financiero, hold activo y el monto que eventualmente podría liberarse.') }}</p>
          </div>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-striped ops-table mb-0">
              <thead>
                <tr>
                  <th>{{ __('Event') }}</th>
                  <th>{{ __('Owner') }}</th>
                  <th>{{ __('Status') }}</th>
                  <th>{{ __('Claimable') }}</th>
                  <th>{{ __('Hold / approval') }}</th>
                  <th class="text-right">{{ __('Actions') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse ($treasuries as $treasury)
                  <tr>
                    <td>
                      <div class="font-weight-bold">{{ $treasury->title }}</div>
                      <div class="settlement-metadata">#{{ $treasury->event_id }}</div>
                      @if (!empty($treasury->host_venue_label) && $treasury->host_venue_label !== $treasury->owner_label)
                        <div class="settlement-metadata">{{ __('Host venue:') }} {{ $treasury->host_venue_label }}</div>
                      @endif
                    </td>
                    <td>
                      <div class="settlement-owner">
                        <strong>{{ $treasury->owner_label }}</strong>
                        <small>{{ str($treasury->owner_type ?: 'owner')->replace('_', ' ')->title() }}</small>
                      </div>
                    </td>
                    <td>
                      <span class="settlement-pill settlement-pill--{{ $treasury->status_tone }}">{{ $treasury->status_label }}</span>
                    </td>
                    <td>
                      <div class="font-weight-bold">{{ $money(data_get($treasury, 'snapshot.claimable_amount', 0)) }}</div>
                      <div class="settlement-metadata">{{ __('Released:') }} {{ $money(data_get($treasury, 'snapshot.released_to_wallet', 0)) }}</div>
                    </td>
                    <td>
                      @if (data_get($treasury, 'snapshot.needs_admin_approval'))
                        <div class="settlement-pill settlement-pill--warning">{{ __('Pending admin approval') }}</div>
                      @elseif (data_get($treasury, 'snapshot.admin_release_approved_at'))
                        <div class="settlement-pill settlement-pill--success">{{ __('Approved by admin') }}</div>
                        <div class="settlement-metadata mt-2">{{ data_get($treasury, 'snapshot.admin_release_approved_at') }}</div>
                      @elseif (data_get($treasury, 'snapshot.remaining_hold_hours'))
                        <div class="settlement-metadata">{{ __('Hold remaining: :hours h', ['hours' => data_get($treasury, 'snapshot.remaining_hold_hours')]) }}</div>
                      @else
                        <div class="settlement-metadata">{{ __('No active hold') }}</div>
                      @endif
                    </td>
                    <td class="text-right">
                      <a href="{{ $treasury->review_url }}" class="btn btn-sm btn-primary">{{ __('Review') }}</a>
                    </td>
                  </tr>
                @empty
                  <tr>
                    <td colspan="6" class="text-center text-muted py-5">{{ __('No event treasuries matched this filter.') }}</td>
                  </tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
        @if (method_exists($treasuries, 'links'))
          <div class="card-footer">
            {{ $treasuries->links() }}
          </div>
        @endif
      </div>

      <div class="settlement-detail-block">
        @if ($selectedSettlement)
          <div class="card ops-panel">
            <div class="card-header d-flex flex-wrap justify-content-between align-items-center" style="gap: 12px;">
              <div>
                <div class="card-title mb-1">{{ $selectedSettlement['title'] }}</div>
                <p class="mb-0 text-muted">{{ $selectedSettlement['owner_label'] }}</p>
              </div>
              <span class="settlement-pill settlement-pill--{{ $selectedSettlement['status_tone'] }}">{{ $selectedSettlement['status_label'] }}</span>
            </div>
            <div class="card-body">
              <div class="settlement-stat-grid mb-3">
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Gross collected') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'snapshot.gross_collected', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Refunded') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'snapshot.refunded_amount', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Duty fees') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'snapshot.platform_fee_total', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Claimable now') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'snapshot.claimable_amount', 0)) }}</strong>
                </div>
              </div>

              <div class="settlement-actions mb-3">
                @if (data_get($selectedSettlement, 'snapshot.needs_admin_approval'))
                  <form method="POST" action="{{ route('admin.event_booking.economy.settlements.approve', ['event' => $selectedSettlement['event_id']]) }}">
                    @csrf
                    <button type="submit" class="btn btn-warning">{{ __('Approve owner release') }}</button>
                  </form>
                @endif

                @if (data_get($selectedSettlement, 'snapshot.can_release_now'))
                  <form method="POST" action="{{ route('admin.event_booking.economy.settlements.release', ['event' => $selectedSettlement['event_id']]) }}" onsubmit="return confirm('{{ __('Liberar fondos al wallet del owner ahora?') }}')">
                    @csrf
                    <button type="submit" class="btn btn-success">{{ __('Release owner share now') }}</button>
                  </form>
                @endif

                <a href="{{ route('admin.event_booking.economy.settlements.event_export', ['event' => $selectedSettlement['event_id']] + request()->query()) }}" class="btn btn-outline-secondary">{{ __('Export settlement CSV') }}</a>
                <a href="{{ route('admin.event_management.edit_event', ['id' => $selectedSettlement['event_id']]) }}" class="btn btn-light">{{ __('Open event workspace') }}</a>
              </div>

	              <div class="settlement-entry-list">
                <div class="settlement-entry">
                  <div class="font-weight-bold mb-2">{{ __('Settlement controls') }}</div>
                  <div class="settlement-entry-meta">{{ __('Requires admin approval:') }} {{ data_get($selectedSettlement, 'detail.settlement_settings.require_admin_approval') ? __('Yes') : __('No') }}</div>
                  <div class="settlement-entry-meta">{{ __('Hold mode:') }} {{ str(data_get($selectedSettlement, 'detail.settlement_settings.hold_mode', 'auto_after_grace_period'))->replace('_', ' ')->title() }}</div>
                  <div class="settlement-entry-meta">{{ __('Grace period:') }} {{ data_get($selectedSettlement, 'detail.settlement_settings.grace_period_hours') ?: '—' }} {{ __('hours') }}</div>
                  <div class="settlement-entry-meta">{{ __('Refund window:') }} {{ data_get($selectedSettlement, 'detail.settlement_settings.refund_window_hours') ?: '—' }} {{ __('hours') }}</div>
                  <div class="settlement-entry-meta">{{ __('Auto release owner share:') }} {{ data_get($selectedSettlement, 'detail.settlement_settings.auto_release_owner_share') ? __('Enabled') : __('Disabled') }}</div>
                  @if (data_get($selectedSettlement, 'detail.settlement_settings.notes'))
                    <div class="settlement-metadata mt-2">{{ data_get($selectedSettlement, 'detail.settlement_settings.notes') }}</div>
                  @endif
                </div>

	                <div class="settlement-entry">
	                  <div class="font-weight-bold mb-2">{{ __('Treasury state') }}</div>
                  <div class="settlement-entry-meta">{{ __('Available for settlement:') }} {{ $money(data_get($selectedSettlement, 'snapshot.available_for_settlement', 0)) }}</div>
                  <div class="settlement-entry-meta">{{ __('Reserved for collaborators:') }} {{ $money(data_get($selectedSettlement, 'snapshot.reserved_for_collaborators', 0)) }}</div>
                  <div class="settlement-entry-meta">{{ __('Released to wallet:') }} {{ $money(data_get($selectedSettlement, 'snapshot.released_to_wallet', 0)) }}</div>
                  @if (data_get($selectedSettlement, 'snapshot.hold_until'))
                    <div class="settlement-entry-meta">{{ __('Hold until:') }} {{ data_get($selectedSettlement, 'snapshot.hold_until') }}</div>
                  @endif
                  @if (data_get($selectedSettlement, 'snapshot.admin_release_approved_at'))
                    <div class="settlement-entry-meta">{{ __('Approved at:') }} {{ data_get($selectedSettlement, 'snapshot.admin_release_approved_at') }}</div>
                  @endif
	                </div>

                  <div class="settlement-entry">
                    <div class="font-weight-bold mb-2">{{ __('Reconciliation') }}</div>
                    <div class="settlement-reconciliation">
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Gross collected') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.gross_collected', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Less refunded amount') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.refunded_amount', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Collected after refunds') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.collected_after_refunds', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Less Duty fees') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.platform_fee_total', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Net after platform fees') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.net_after_platform_fees', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Reserved for collaborators') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.reserved_for_collaborators', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Owner reserved and unreleased') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.owner_reserved_unreleased', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row">
                        <span>{{ __('Already released to wallet') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.released_to_wallet', 0)) }}</strong>
                      </div>
                      <div class="settlement-reconciliation__row settlement-reconciliation__row--emphasis">
                        <span>{{ __('Releasable now') }}</span>
                        <strong>{{ $money(data_get($selectedSettlement, 'detail.reconciliation.releasable_now', 0)) }}</strong>
                      </div>
                    </div>

                    @if (data_get($selectedSettlement, 'detail.reconciliation.blocked_release_amount', 0) > 0)
                      <div class="settlement-empty mt-3">
                        <strong>{{ __('Blocked from release: :amount', ['amount' => $money(data_get($selectedSettlement, 'detail.reconciliation.blocked_release_amount', 0))]) }}</strong>
                        @if (data_get($selectedSettlement, 'detail.reconciliation.block_reason_label'))
                          <div class="settlement-reconciliation__hint mt-1">{{ data_get($selectedSettlement, 'detail.reconciliation.block_reason_label') }}</div>
                        @endif
                      </div>
                    @elseif (data_get($selectedSettlement, 'detail.reconciliation.releasable_now', 0) > 0)
                      <div class="settlement-reconciliation__hint mt-3">{{ __('This amount is currently releasable without further treasury math. Any remaining restriction is operational, not numerical.') }}</div>
                    @endif
                  </div>
	              </div>
	            </div>
	          </div>

	          <div class="card ops-panel">
	            <div class="card-header d-flex flex-wrap justify-content-between align-items-center" style="gap: 12px;">
	              <div>
	                <div class="card-title mb-1">{{ __('Refund operations') }}</div>
	                <p class="mb-0 text-muted">{{ __('Conecta la tesorería retenida con la cola de reservas reembolsables para que soporte pueda pasar del evento al caso financiero correcto sin perder contexto.') }}</p>
	              </div>
	              @if (data_get($selectedSettlement, 'detail.refund_operations.has_open_refund_window'))
	                <span class="settlement-pill settlement-pill--warning">{{ __('Refund window active') }}</span>
	              @elseif (data_get($selectedSettlement, 'detail.refund_operations.refundable_reservations_count', 0) > 0)
	                <span class="settlement-pill settlement-pill--danger">{{ __('Refund action pending') }}</span>
	              @else
	                <span class="settlement-pill settlement-pill--success">{{ __('No open refund blockers') }}</span>
	              @endif
	            </div>
	            <div class="card-body">
	              <div class="settlement-stat-grid mb-3">
	                <div class="settlement-stat">
	                  <div class="text-muted small">{{ __('Reservations tracked') }}</div>
	                  <strong>{{ number_format((int) data_get($selectedSettlement, 'detail.refund_operations.total_reservations', 0)) }}</strong>
	                </div>
	                <div class="settlement-stat">
	                  <div class="text-muted small">{{ __('Refundable reservations') }}</div>
	                  <strong>{{ number_format((int) data_get($selectedSettlement, 'detail.refund_operations.refundable_reservations_count', 0)) }}</strong>
	                  <div class="settlement-entry-meta">{{ $money(data_get($selectedSettlement, 'detail.refund_operations.refundable_gross', 0)) }}</div>
	                </div>
	                <div class="settlement-stat">
	                  <div class="text-muted small">{{ __('Refunded reservations') }}</div>
	                  <strong>{{ number_format((int) data_get($selectedSettlement, 'detail.refund_operations.refunded_reservations_count', 0)) }}</strong>
	                  <div class="settlement-entry-meta">{{ $money(data_get($selectedSettlement, 'detail.refund_operations.refunded_gross', 0)) }}</div>
	                </div>
	                <div class="settlement-stat">
	                  <div class="text-muted small">{{ __('Refund window') }}</div>
	                  <strong>
	                    @if (data_get($selectedSettlement, 'detail.refund_operations.has_open_refund_window'))
	                      {{ __('Open') }}
	                    @else
	                      {{ __('Closed') }}
	                    @endif
	                  </strong>
	                  @if (data_get($selectedSettlement, 'detail.refund_operations.refund_window_until'))
	                    <div class="settlement-entry-meta">{{ data_get($selectedSettlement, 'detail.refund_operations.refund_window_until') }}</div>
	                  @endif
	                </div>
	              </div>

	              <div class="settlement-actions mb-3">
	                <a href="{{ data_get($selectedSettlement, 'detail.refund_operations.all_queue_url') }}" class="btn btn-light">{{ __('Open reservation queue') }}</a>
	                <a href="{{ data_get($selectedSettlement, 'detail.refund_operations.refundable_queue_url') }}" class="btn btn-warning">{{ __('Refundable only') }}</a>
	                <a href="{{ data_get($selectedSettlement, 'detail.refund_operations.refunded_queue_url') }}" class="btn btn-outline-secondary">{{ __('Refunded history') }}</a>
	              </div>

	              @if (data_get($selectedSettlement, 'detail.refund_operations.hold_reason_label'))
	                <div class="settlement-empty mb-3">
	                  <strong>{{ __('Current hold reason:') }}</strong>
	                  <span>{{ data_get($selectedSettlement, 'detail.refund_operations.hold_reason_label') }}</span>
	                </div>
	              @endif

                  @if (data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision'))
                    <div class="settlement-empty mb-3">
                      <div class="font-weight-bold mb-2">{{ __('Latest refund decision') }}</div>
                      <div class="settlement-entry-meta">
                        <strong>{{ __('Reason:') }}</strong>
                        {{ data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.reason_label', '—') }}
                      </div>
                      @if (data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.admin_label'))
                        <div class="settlement-entry-meta mt-1">
                          <strong>{{ __('Processed by:') }}</strong>
                          {{ data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.admin_label') }}
                          @if (data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.occurred_at'))
                            · {{ data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.occurred_at') }}
                          @endif
                        </div>
                      @endif
                      @if (!empty(data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.risk_flag_labels', [])))
                        <div class="settlement-entry-meta mt-1">
                          <strong>{{ __('Risk flags:') }}</strong>
                          {{ collect(data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.risk_flag_labels', []))->implode(', ') }}
                        </div>
                      @endif
                      @if (data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.admin_note'))
                        <div class="settlement-reconciliation__hint mt-2">
                          {{ data_get($selectedSettlement, 'detail.refund_operations.latest_refund_decision.admin_note') }}
                        </div>
                      @endif
                    </div>
                  @endif

	              @if (!empty(data_get($selectedSettlement, 'detail.refund_operations.cases', [])))
	                <div class="settlement-activity-list">
	                  @foreach (data_get($selectedSettlement, 'detail.refund_operations.cases', []) as $case)
	                    <div class="settlement-activity">
	                      <div class="d-flex flex-wrap justify-content-between align-items-start" style="gap: 12px;">
	                        <div>
	                          <div class="font-weight-bold">{{ __('Reservation :code', ['code' => data_get($case, 'reservation_code')]) }}</div>
	                          <div class="settlement-entry-meta">{{ data_get($case, 'status_label') }}</div>
	                          @if (data_get($case, 'last_paid_at'))
	                            <div class="settlement-entry-meta mt-1">{{ __('Last payment:') }} {{ data_get($case, 'last_paid_at') }}</div>
	                          @endif
	                        </div>
	                        <div class="text-right">
	                          @if ((float) data_get($case, 'refundable_gross', 0) > 0)
	                            <div class="font-weight-bold text-warning">{{ __('Refundable: :amount', ['amount' => $money(data_get($case, 'refundable_gross', 0))]) }}</div>
	                          @endif
	                          @if ((float) data_get($case, 'refunded_gross', 0) > 0)
	                            <div class="settlement-entry-meta">{{ __('Refunded: :amount', ['amount' => $money(data_get($case, 'refunded_gross', 0))]) }}</div>
	                          @endif
	                        </div>
	                      </div>
	                      <div class="mt-3">
	                        <a href="{{ data_get($case, 'detail_url') }}" class="btn btn-sm btn-primary">{{ __('Review reservation') }}</a>
	                      </div>
	                    </div>
	                  @endforeach
	                </div>
	              @else
	                <div class="settlement-empty">{{ __('No reservation refund cases are currently attached to this event.') }}</div>
	              @endif
	            </div>
	          </div>

	          <div class="card ops-panel">
	            <div class="card-header">
	              <div class="card-title mb-0">{{ __('Settlement actions log') }}</div>
	            </div>
	            <div class="card-body">
	              @if (!empty(data_get($selectedSettlement, 'detail.settlement_actions', [])))
	                <div class="settlement-activity-list">
	                  @foreach (data_get($selectedSettlement, 'detail.settlement_actions', []) as $action)
	                    <div class="settlement-activity">
	                      <div class="d-flex flex-wrap justify-content-between align-items-start" style="gap: 12px;">
	                        <div>
	                          <div class="font-weight-bold">{{ data_get($action, 'action_label') }}</div>
	                          <div class="settlement-entry-meta">
	                            {{ __('Actor:') }} {{ data_get($action, 'admin_label') }}
	                            @if (data_get($action, 'occurred_at'))
	                              · {{ data_get($action, 'occurred_at') }}
	                            @endif
	                          </div>
	                          @if (data_get($action, 'release_source'))
	                            <div class="settlement-entry-meta mt-1">{{ __('Source:') }} {{ data_get($action, 'release_source') }}</div>
	                          @endif
	                        </div>
	                        <div class="text-right">
	                          <span class="settlement-pill settlement-pill--{{ data_get($action, 'tone', 'primary') }}">{{ str(data_get($action, 'action_type', 'action'))->replace('_', ' ')->title() }}</span>
	                          @if ((float) data_get($action, 'amount', 0) > 0)
	                            <div class="font-weight-bold mt-2">{{ $money(data_get($action, 'amount', 0)) }}</div>
	                          @endif
	                        </div>
	                      </div>
	                    </div>
	                  @endforeach
	                </div>
	              @else
	                <div class="settlement-empty">{{ __('No approval or payout actions have been recorded for this treasury yet.') }}</div>
	              @endif
	            </div>
	          </div>

	          <div class="card ops-panel">
	            <div class="card-header">
	              <div class="card-title mb-0">{{ __('Recent treasury activity') }}</div>
	            </div>
            <div class="card-body">
              @if (!empty(data_get($selectedSettlement, 'detail.recent_entries', [])))
                <div class="settlement-entry-list">
                  @foreach (data_get($selectedSettlement, 'detail.recent_entries', []) as $entry)
                    <div class="settlement-entry">
                      <div class="d-flex flex-wrap justify-content-between align-items-start" style="gap: 10px;">
                        <div>
                          <div class="font-weight-bold">{{ $entry['entry_label'] }}</div>
                          <div class="settlement-entry-meta">{{ $entry['occurred_at'] ?: '—' }} · {{ data_get($entry, 'status_label', str($entry['status'])->replace('_', ' ')->title()) }}</div>
                          @if (data_get($entry, 'entry_summary'))
                            <div class="settlement-entry-meta mt-1">{{ data_get($entry, 'entry_summary') }}</div>
                          @endif
                        </div>
                        <div class="text-right">
                          <div class="font-weight-bold">{{ $money($entry['net_amount']) }}</div>
                          @if ($entry['fee_amount'] != 0)
                            <div class="settlement-entry-meta">{{ __('Fee:') }} {{ $money($entry['fee_amount']) }}</div>
                          @endif
                        </div>
                      </div>
                    </div>
                  @endforeach
                </div>
              @else
                <div class="settlement-empty">{{ __('No treasury ledger entries recorded yet for this event.') }}</div>
              @endif
            </div>
          </div>

          <div class="card ops-panel">
            <div class="card-header">
              <div class="card-title mb-0">{{ __('Collaborator finance') }}</div>
            </div>
            <div class="card-body">
              <div class="settlement-stat-grid mb-3">
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Reserved for collaborators') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'detail.collaboration_summary.reserved_for_collaborators', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Collaborators claimable') }}</div>
                  <strong>{{ number_format((int) data_get($selectedSettlement, 'detail.collaboration_summary.claimable_count', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Claimable amount') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.claimable_amount', 0)) }}</strong>
                </div>
                <div class="settlement-stat">
                  <div class="text-muted small">{{ __('Already released') }}</div>
                  <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.released_to_wallet', 0)) }}</strong>
                </div>
              </div>

              <div class="settlement-entry mb-3">
                <div class="font-weight-bold mb-2">{{ __('Collaborator reconciliation') }}</div>
                <div class="settlement-reconciliation">
                  <div class="settlement-reconciliation__row">
                    <span>{{ __('Distributable amount') }}</span>
                    <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.distributable_amount', 0)) }}</strong>
                  </div>
                  <div class="settlement-reconciliation__row">
                    <span>{{ __('Reserved outstanding') }}</span>
                    <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.reserved_for_collaborators', 0)) }}</strong>
                  </div>
                  <div class="settlement-reconciliation__row">
                    <span>{{ __('Pending release') }}</span>
                    <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.pending_amount', 0)) }}</strong>
                  </div>
                  <div class="settlement-reconciliation__row">
                    <span>{{ __('Claimable now') }}</span>
                    <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.claimable_amount', 0)) }}</strong>
                  </div>
                  <div class="settlement-reconciliation__row">
                    <span>{{ __('Claimed to wallet') }}</span>
                    <strong>{{ $money(data_get($selectedSettlement, 'detail.collaborator_reconciliation.claimed_amount', 0)) }}</strong>
                  </div>
                </div>
                @if ((float) data_get($selectedSettlement, 'detail.reconciliation.unreleased_balance_delta', 0) !== 0.0)
                  <div class="settlement-empty mt-3">
                    <strong>{{ __('Treasury reconciliation delta detected') }}</strong>
                    <div class="settlement-reconciliation__hint mt-1">{{ __('Unreleased collaborator and owner balances do not reconcile perfectly with treasury totals. Review the split allocations below.') }}</div>
                  </div>
                @endif
              </div>

              @if (!empty(data_get($selectedSettlement, 'detail.collaborator_reconciliation.basis_breakdown', [])))
                <div class="settlement-entry mb-3">
                  <div class="font-weight-bold mb-2">{{ __('Basis breakdown') }}</div>
                  <div class="settlement-entry-list">
                    @foreach (data_get($selectedSettlement, 'detail.collaborator_reconciliation.basis_breakdown', []) as $basis)
                      <div class="settlement-entry">
                        <div class="d-flex flex-wrap justify-content-between align-items-start" style="gap: 10px;">
                          <div>
                            <div class="font-weight-bold">{{ data_get($basis, 'label') }}</div>
                            <div class="settlement-entry-meta">{{ __('Splits: :count', ['count' => number_format((int) data_get($basis, 'split_count', 0))]) }}</div>
                          </div>
                          <div class="text-right">
                            <div class="font-weight-bold">{{ $money(data_get($basis, 'reserved_amount', 0)) }}</div>
                            <div class="settlement-entry-meta">{{ __('Basis amount: :amount', ['amount' => $money(data_get($basis, 'max_basis_amount', 0))]) }}</div>
                          </div>
                        </div>
                      </div>
                    @endforeach
                  </div>
                </div>
              @endif

              @if (!empty(data_get($selectedSettlement, 'detail.collaborator_reconciliation.split_allocations', [])))
                <div class="settlement-entry mb-3">
                  <div class="font-weight-bold mb-2">{{ __('Split allocations') }}</div>
                  <div class="settlement-entry-list">
                    @foreach (data_get($selectedSettlement, 'detail.collaborator_reconciliation.split_allocations', []) as $allocation)
                      <div class="settlement-entry">
                        <div class="d-flex flex-wrap justify-content-between align-items-start" style="gap: 10px;">
                          <div>
                            <div class="font-weight-bold">{{ data_get($allocation, 'display_name', __('Collaborator')) }}</div>
                            <div class="settlement-entry-meta">
                              {{ data_get($allocation, 'basis_label') }}
                              · {{ data_get($allocation, 'effective_release_mode_label') }}
                              · {{ str((string) data_get($allocation, 'status'))->replace('_', ' ')->title() }}
                            </div>
                          </div>
                          <div class="text-right">
                            <div class="font-weight-bold">{{ $money(data_get($allocation, 'amount_reserved', 0)) }}</div>
                            <div class="settlement-entry-meta">{{ __('Claimed: :amount', ['amount' => $money(data_get($allocation, 'amount_claimed', 0))]) }}</div>
                            <div class="settlement-entry-meta">{{ __('Claimable: :amount', ['amount' => $money(data_get($allocation, 'claimable_amount', 0))]) }}</div>
                          </div>
                        </div>
                      </div>
                    @endforeach
                  </div>
                </div>
              @endif

              @if (!empty(data_get($selectedSettlement, 'detail.collaboration_summary.activity', [])))
                <div class="settlement-activity-list">
                  @foreach (data_get($selectedSettlement, 'detail.collaboration_summary.activity', []) as $activity)
                    <div class="settlement-activity">
                      <div class="font-weight-bold">{{ data_get($activity, 'title', __('Collaboration activity')) }}</div>
                      @if (data_get($activity, 'subtitle'))
                        <div class="settlement-entry-meta">{{ data_get($activity, 'subtitle') }}</div>
                      @endif
                      @if (data_get($activity, 'occurred_at'))
                        <div class="settlement-entry-meta mt-2">{{ data_get($activity, 'occurred_at') }}</div>
                      @endif
                    </div>
                  @endforeach
                </div>
              @else
                <div class="settlement-empty">{{ __('No collaborator finance activity recorded yet for this event.') }}</div>
              @endif
            </div>
          </div>
        @else
          <div class="card ops-panel">
            <div class="card-body">
              <div class="settlement-empty">
                <div class="font-weight-bold mb-2">{{ __('Choose a treasury to review') }}</div>
                <div>{{ __('Select an event from the queue to inspect the treasury, approval state, collaborator reserves and latest financial ledger entries.') }}</div>
              </div>
            </div>
          </div>
        @endif
      </div>
    </div>
  </div>
@endsection
