@extends('backend.layout')

@php
  $money = fn ($value) => 'RD$ ' . number_format((float) $value, 2);
@endphp

@section('style')
  <style>
    .economy-filter-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px;
    }

    .economy-chart-card {
      min-height: 360px;
    }

    .economy-chart-wrap {
      position: relative;
      min-height: 280px;
    }

    .economy-kpi-note {
      font-size: 0.8rem;
      color: #7f8c9a;
    }
  </style>
@endsection

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Economy Dashboard') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('admin.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Bookings') }}</a></li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Economy') }}</a></li>
    </ul>
  </div>

  <div class="card">
    <div class="card-header d-flex flex-wrap justify-content-between align-items-center">
      <div>
        <div class="card-title mb-1">{{ __('Filters & export') }}</div>
        <p class="mb-0 text-muted">{{ __('Filtra el ledger económico por rango, operación o perfil y exporta la misma lectura en CSV o XLSX.') }}</p>
      </div>
      <div class="d-flex flex-wrap" style="gap: 8px;">
        <a href="{{ route('admin.event_booking.settings.fee_policies') }}" class="btn btn-primary btn-sm">{{ __('Fee Policies') }}</a>
        <a href="{{ route('admin.event_booking.economy.settlements') }}" class="btn btn-warning btn-sm">{{ __('Settlement Review') }}</a>
        <a href="{{ route('admin.event_booking.economy.export', request()->query()) }}" class="btn btn-success btn-sm">{{ __('Export CSV') }}</a>
        <a href="{{ route('admin.event_booking.economy.export', array_merge(request()->query(), ['format' => 'xlsx'])) }}" class="btn btn-success btn-sm">{{ __('Export XLSX') }}</a>
      </div>
    </div>
    <div class="card-body">
      <form method="GET" action="{{ route('admin.event_booking.economy') }}">
        <div class="mb-3 d-flex flex-wrap" style="gap: 8px;">
          @foreach ($presetOptions as $value => $label)
            <a href="{{ route('admin.event_booking.economy', array_merge(request()->except(['page', 'date_from', 'date_to', 'preset']), ['preset' => $value])) }}"
              class="btn btn-sm {{ $filters['preset'] === $value ? 'btn-primary' : 'btn-light' }}">
              {{ $label }}
            </a>
          @endforeach
        </div>

        <div class="economy-filter-grid">
          <div class="form-group mb-0">
            <label>{{ __('From') }}</label>
            <input type="date" class="form-control" name="date_from" value="{{ $filters['date_from'] }}">
          </div>
          <div class="form-group mb-0">
            <label>{{ __('To') }}</label>
            <input type="date" class="form-control" name="date_to" value="{{ $filters['date_to'] }}">
          </div>
          <div class="form-group mb-0">
            <label>{{ __('Operation') }}</label>
            <select class="form-control" name="operation_key">
              <option value="">{{ __('All operations') }}</option>
              @foreach ($operationOptions as $value => $label)
                <option value="{{ $value }}" {{ $filters['operation_key'] === $value ? 'selected' : '' }}>{{ $label }}</option>
              @endforeach
            </select>
          </div>
          <div class="form-group mb-0">
            <label>{{ __('Event') }}</label>
            <select class="form-control" name="event_id">
              <option value="">{{ __('All events') }}</option>
              @foreach ($eventOptions as $value => $label)
                <option value="{{ $value }}" {{ (string) $filters['event_id'] === (string) $value ? 'selected' : '' }}>{{ $label }}</option>
              @endforeach
            </select>
          </div>
          <div class="form-group mb-0">
            <label>{{ __('Organizer') }}</label>
            <select class="form-control" name="organizer_ref">
              <option value="">{{ __('All organizers') }}</option>
              @foreach ($organizerOptions as $value => $label)
                <option value="{{ $value }}" {{ $filters['organizer_ref'] === $value ? 'selected' : '' }}>{{ $label }}</option>
              @endforeach
            </select>
          </div>
          <div class="form-group mb-0">
            <label>{{ __('Venue') }}</label>
            <select class="form-control" name="venue_ref">
              <option value="">{{ __('All venues') }}</option>
              @foreach ($venueOptions as $value => $label)
                <option value="{{ $value }}" {{ $filters['venue_ref'] === $value ? 'selected' : '' }}>{{ $label }}</option>
              @endforeach
            </select>
          </div>
        </div>

        <div class="mt-3 d-flex flex-wrap" style="gap: 8px;">
          <button type="submit" class="btn btn-primary">{{ __('Apply filters') }}</button>
          <a href="{{ route('admin.event_booking.economy') }}" class="btn btn-light">{{ __('Reset') }}</a>
        </div>
      </form>
    </div>
  </div>

  <div class="row">
    <div class="col-md-3">
      <div class="card">
        <div class="card-body">
          <div class="text-muted small">{{ __('Duty Revenue') }}</div>
          <div class="h3 mb-1">{{ $money($summary->fee_amount ?? 0) }}</div>
          <div class="economy-kpi-note">{{ number_format((int) ($summary->operation_count ?? 0)) }} {{ __('monetized operations in current view') }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card">
        <div class="card-body">
          <div class="text-muted small">{{ __('Gross Volume') }}</div>
          <div class="h3 mb-1">{{ $money($summary->gross_amount ?? 0) }}</div>
          <div class="economy-kpi-note">{{ __('Total tracked through the platform revenue ledger') }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card">
        <div class="card-body">
          <div class="text-muted small">{{ __('Take Rate') }}</div>
          <div class="h3 mb-1">{{ number_format((float) $avgTakeRate, 2) }}%</div>
          <div class="economy-kpi-note">{{ __('Average Duty fee against gross volume') }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card">
        <div class="card-body">
          <div class="text-muted small">{{ __('Last 30 Days') }}</div>
          <div class="h3 mb-1">{{ $money($last30->fee_amount ?? 0) }}</div>
          <div class="economy-kpi-note">{{ number_format((int) ($last30->operation_count ?? 0)) }} {{ __('operations inside the last 30 days') }}</div>
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
      <div>
        <div class="card-title mb-1">{{ __('Gateway telemetry') }}</div>
        <div class="small text-muted">{{ __($gatewayTelemetry['scope_note'] ?? '') }}</div>
      </div>
      <div class="small text-muted">{{ __('Source overlap is expected in telemetry. Use this block to understand gateway usage, not to reconcile revenue totals.') }}</div>
    </div>
    <div class="card-body">
      <div class="row mb-3">
        <div class="col-md-3">
          <div class="border rounded p-3 h-100">
            <div class="text-muted small">{{ __('Tracked records') }}</div>
            <div class="h4 mb-1">{{ number_format((int) data_get($gatewayTelemetry, 'summary.total_records', 0)) }}</div>
            <div class="economy-kpi-note">{{ __('Rows with persisted gateway metadata across event payment sources') }}</div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="border rounded p-3 h-100">
            <div class="text-muted small">{{ __('Source systems') }}</div>
            <div class="h4 mb-1">{{ number_format((int) data_get($gatewayTelemetry, 'summary.source_count', 0)) }}</div>
            <div class="economy-kpi-note">{{ __('Reservation payments, booking allocations, and revenue ledger sources currently reporting') }}</div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="border rounded p-3 h-100">
            <div class="text-muted small">{{ __('Gateway families') }}</div>
            <div class="h4 mb-1">{{ number_format((int) data_get($gatewayTelemetry, 'summary.gateway_family_count', 0)) }}</div>
            <div class="economy-kpi-note">{{ __('Distinct gateway families seen in the current telemetry window') }}</div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="border rounded p-3 h-100">
            <div class="text-muted small">{{ __('Mixed requested') }}</div>
            <div class="h4 mb-1">{{ number_format((int) data_get($gatewayTelemetry, 'summary.mixed_requested_records', 0)) }}</div>
            <div class="economy-kpi-note">{{ __('Records that started as mixed funding and then resolved into a concrete payment path') }}</div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-lg-6">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Gateway family') }}</th>
                  <th>{{ __('Records') }}</th>
                  <th>{{ __('Tracked amount') }}</th>
                  <th>{{ __('Sources') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse (data_get($gatewayTelemetry, 'by_gateway_family', []) as $row)
                  <tr>
                    <td>{{ data_get($row, 'label') }}</td>
                    <td>{{ number_format((int) data_get($row, 'record_count', 0)) }}</td>
                    <td>{{ $money(data_get($row, 'tracked_amount', 0)) }}</td>
                    <td>{{ number_format((int) data_get($row, 'source_count', 0)) }}</td>
                  </tr>
                @empty
                  <tr><td colspan="4" class="text-center text-muted py-4">{{ __('No gateway telemetry matches the current scope.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Source') }}</th>
                  <th>{{ __('Records') }}</th>
                  <th>{{ __('Tracked amount') }}</th>
                  <th>{{ __('Top family') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse (data_get($gatewayTelemetry, 'by_source', []) as $row)
                  <tr>
                    <td>
                      <div class="font-weight-bold">{{ data_get($row, 'source_label') }}</div>
                      <div class="small text-muted">{{ data_get($row, 'latest_at') ? __('Latest:') . ' ' . data_get($row, 'latest_at') : __('No recent timestamp') }}</div>
                    </td>
                    <td>{{ number_format((int) data_get($row, 'record_count', 0)) }}</td>
                    <td>{{ $money(data_get($row, 'tracked_amount', 0)) }}</td>
                    <td>{{ data_get($row, 'top_gateway_family_label') }}</td>
                  </tr>
                @empty
                  <tr><td colspan="4" class="text-center text-muted py-4">{{ __('No telemetry sources are reporting inside the current scope.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="mt-4">
        <div class="font-weight-bold mb-2">{{ __('Recent gateway records') }}</div>
        <div class="table-responsive">
          <table class="table table-striped mb-0">
            <thead>
              <tr>
                <th>{{ __('Occurred At') }}</th>
                <th>{{ __('Source') }}</th>
                <th>{{ __('Event') }}</th>
                <th>{{ __('Requested') }}</th>
                <th>{{ __('Resolved') }}</th>
                <th>{{ __('Family') }}</th>
                <th>{{ __('Strategy') }}</th>
                <th>{{ __('Amount') }}</th>
              </tr>
            </thead>
            <tbody>
              @forelse (data_get($gatewayTelemetry, 'recent_records', []) as $row)
                <tr>
                  <td>{{ optional(data_get($row, 'occurred_at'))->format('Y-m-d H:i') ?: '—' }}</td>
                  <td>
                    <div class="font-weight-bold">{{ data_get($row, 'source_label') }}</div>
                    <div class="small text-muted">{{ data_get($row, 'reference_type') }}#{{ data_get($row, 'reference_id') }}</div>
                  </td>
                  <td>{{ data_get($row, 'event_label') }}</td>
                  <td>{{ data_get($row, 'requested_gateway_label') }}</td>
                  <td>{{ data_get($row, 'gateway_label') }}</td>
                  <td>{{ data_get($row, 'gateway_family_label') }}</td>
                  <td>{{ data_get($row, 'verification_strategy_label') }}</td>
                  <td>{{ $money(data_get($row, 'amount', 0)) }}</td>
                </tr>
              @empty
                <tr><td colspan="8" class="text-center text-muted py-4">{{ __('No recent gateway records match the current scope.') }}</td></tr>
              @endforelse
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-7">
      <div class="card economy-chart-card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Revenue trend') }}</div>
        </div>
        <div class="card-body">
          <div class="economy-chart-wrap">
            <canvas id="economyTrendChart"></canvas>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-5">
      <div class="card economy-chart-card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Operation mix') }}</div>
        </div>
        <div class="card-body">
          <div class="economy-chart-wrap">
            <canvas id="economyOperationChart"></canvas>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Revenue by Operation') }}</div>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Operation') }}</th>
                  <th>{{ __('Count') }}</th>
                  <th>{{ __('Gross') }}</th>
                  <th>{{ __('Duty Fee') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse ($byOperation as $row)
                  <tr>
                    <td>
                      <div class="font-weight-bold">{{ str($row->operation_key)->replace('_', ' ')->title() }}</div>
                      <div class="small text-muted">{{ $row->operation_key }}</div>
                    </td>
                    <td>{{ number_format((int) $row->operation_count) }}</td>
                    <td>{{ $money($row->gross_amount) }}</td>
                    <td class="font-weight-bold">{{ $money($row->fee_amount) }}</td>
                  </tr>
                @empty
                  <tr><td colspan="4" class="text-center text-muted py-4">{{ __('No revenue events recorded yet.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Top Events by Duty Revenue') }}</div>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Event') }}</th>
                  <th>{{ __('Operations') }}</th>
                  <th>{{ __('Duty Fee') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse ($topEvents as $row)
                  <tr>
                    <td>{{ $row->label }}</td>
                    <td>{{ number_format((int) $row->operation_count) }}</td>
                    <td class="font-weight-bold">{{ $money($row->fee_amount) }}</td>
                  </tr>
                @empty
                  <tr><td colspan="3" class="text-center text-muted py-4">{{ __('No event-level revenue yet.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Top Organizers') }}</div>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Organizer') }}</th>
                  <th>{{ __('Operations') }}</th>
                  <th>{{ __('Duty Fee') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse ($topOrganizers as $row)
                  <tr>
                    <td>{{ $row->organizer_label ?? $row->label }}</td>
                    <td>{{ number_format((int) $row->operation_count) }}</td>
                    <td class="font-weight-bold">{{ $money($row->fee_amount) }}</td>
                  </tr>
                @empty
                  <tr><td colspan="3" class="text-center text-muted py-4">{{ __('No organizer revenue yet.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title mb-0">{{ __('Top Venues') }}</div>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-striped mb-0">
              <thead>
                <tr>
                  <th>{{ __('Venue') }}</th>
                  <th>{{ __('Operations') }}</th>
                  <th>{{ __('Duty Fee') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse ($topVenues as $row)
                  <tr>
                    <td>{{ $row->venue_label ?? $row->label }}</td>
                    <td>{{ number_format((int) $row->operation_count) }}</td>
                    <td class="font-weight-bold">{{ $money($row->fee_amount) }}</td>
                  </tr>
                @empty
                  <tr><td colspan="3" class="text-center text-muted py-4">{{ __('No venue revenue yet.') }}</td></tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
      <div class="card-title mb-0">{{ __('Recent revenue events') }}</div>
      <div class="small text-muted">{{ __('Latest 50 rows after current filters') }}</div>
    </div>
    <div class="card-body">
      <div class="table-responsive">
        <table class="table table-striped mb-0">
          <thead>
            <tr>
              <th>{{ __('Occurred At') }}</th>
              <th>{{ __('Operation') }}</th>
              <th>{{ __('Event') }}</th>
              <th>{{ __('Organizer') }}</th>
              <th>{{ __('Venue') }}</th>
              <th>{{ __('Gross') }}</th>
              <th>{{ __('Duty Fee') }}</th>
              <th>{{ __('Charged To') }}</th>
            </tr>
          </thead>
          <tbody>
            @forelse ($recentEvents as $row)
              <tr>
                <td>{{ optional($row->occurred_at)->format('Y-m-d H:i') }}</td>
                <td>
                  <div class="font-weight-bold">{{ str($row->operation_key)->replace('_', ' ')->title() }}</div>
                  <div class="small text-muted">{{ $row->reference_type }}#{{ $row->reference_id }}</div>
                </td>
                <td>{{ $row->event_label ?? '—' }}</td>
                <td>{{ $row->organizer_label ?? '—' }}</td>
                <td>{{ $row->venue_label ?? '—' }}</td>
                <td>{{ $money($row->gross_amount) }}</td>
                <td class="font-weight-bold">{{ $money($row->fee_amount) }}</td>
                <td>{{ str($row->charged_to)->replace('_', ' ')->title() }}</td>
              </tr>
            @empty
              <tr><td colspan="8" class="text-center text-muted py-4">{{ __('No revenue events match the current filters.') }}</td></tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </div>
@endsection

@section('script')
  <script>
    (() => {
      const trendCanvas = document.getElementById('economyTrendChart');
      const operationCanvas = document.getElementById('economyOperationChart');

      if (typeof Chart === 'undefined') {
        return;
      }

      if (trendCanvas) {
        new Chart(trendCanvas, {
          type: 'line',
          data: {
            labels: @json($trendLabels),
            datasets: [{
              label: @json(__('Duty revenue')),
              data: @json($trendValues),
              borderColor: 'rgba(193,18,31,1)',
              backgroundColor: 'rgba(193,18,31,0.12)',
              tension: 0.35,
              fill: true,
              pointRadius: 3,
              pointHoverRadius: 5,
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false }
            },
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
      }

      if (operationCanvas) {
        new Chart(operationCanvas, {
          type: 'doughnut',
          data: {
            labels: @json($operationChartLabels),
            datasets: [{
              data: @json($operationChartValues),
              backgroundColor: [
                '#C1121F',
                '#238A57',
                '#E15562',
                '#C68500',
                '#D32F2F',
                '#8C8391',
                '#5D5564',
                '#F0C9B8',
                '#2D262F',
                '#B89FA8',
              ],
              borderWidth: 0
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'bottom'
              }
            }
          }
        });
      }
    })();
  </script>
@endsection
