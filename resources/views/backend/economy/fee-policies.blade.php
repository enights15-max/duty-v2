@extends('backend.layout')

@section('style')
  @includeIf('backend.partials.scarlet-operations-workspace')
@endsection

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Fee Policies') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('admin.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Bookings') }}</a></li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Fee Policies') }}</a></li>
    </ul>
  </div>

  <div class="ops-shell">
    <div class="ops-hero">
      <div class="ops-hero__grid">
        <div>
          <span class="ops-hero__eyebrow">{{ __('Economy') }}</span>
          <h1 class="ops-hero__title">{{ __('Configure the platform fee engine') }}</h1>
          <p class="ops-hero__copy">
            {{ __('Set percentage, fixed or hybrid fee rules per operation while keeping primary sales, checkout processing and blackmarket aligned with the shared engine.') }}
          </p>
        </div>
        <div class="ops-hero__meta">
          <div class="ops-hero__stat">
            <span class="ops-hero__stat-label">{{ __('Policies loaded') }}</span>
            <span class="ops-hero__stat-value">{{ number_format($policies->count()) }}</span>
            <span class="ops-hero__stat-note">{{ __('Fee rules available in this environment') }}</span>
          </div>
          <div class="ops-hero__stat">
            <span class="ops-hero__stat-label">{{ __('Audit rows') }}</span>
            <span class="ops-hero__stat-value">{{ number_format($auditLogs->count()) }}</span>
            <span class="ops-hero__stat-note">{{ __('Recent policy changes visible below') }}</span>
          </div>
        </div>
      </div>
    </div>

    <div class="card ops-panel">
      <form action="{{ route('admin.event_booking.settings.update_fee_policies') }}" method="POST">
        @csrf
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center">
          <div>
            <div class="card-title mb-1">{{ __('Duty Fee Engine') }}</div>
            <p class="mb-0 text-muted">
              {{ __('Configura el porcentaje o monto fijo por operación. Venta primaria y blackmarket se mantienen sincronizados con el sistema legacy.') }}
            </p>
          </div>
          <a href="{{ route('admin.event_booking.economy') }}" class="btn btn-primary">{{ __('Open Economy Dashboard') }}</a>
        </div>

        <div class="card-body">
          <div class="ops-note mb-4">
            {{ __('These settings affect future calculations. Use the economy dashboard for payout and revenue monitoring, and this workspace for rule definition.') }}
          </div>
          <div class="table-responsive">
            <table class="table table-striped ops-table">
            <thead>
              <tr>
                <th>{{ __('Operation') }}</th>
                <th>{{ __('Status') }}</th>
                <th>{{ __('Fee Type') }}</th>
                <th>{{ __('Percent') }}</th>
                <th>{{ __('Fixed') }}</th>
                <th>{{ __('Minimum') }}</th>
                <th>{{ __('Maximum') }}</th>
                <th>{{ __('Charged To') }}</th>
                <th>{{ __('Currency') }}</th>
              </tr>
            </thead>
            <tbody>
              @foreach ($policies as $policy)
                <tr>
                  <td style="min-width: 240px;">
                    <div class="font-weight-bold">{{ $policy->label }}</div>
                    <div class="small text-muted">{{ $policy->operation_key }}</div>
                    @if (!empty($policy->description))
                      <div class="small text-muted mt-1">{{ $policy->description }}</div>
                    @endif
                  </td>
                  <td style="min-width: 120px;">
                    <input type="hidden" name="policies[{{ $policy->id }}][is_active]" value="0">
                    <label class="mb-0 d-inline-flex align-items-center">
                      <input type="checkbox" name="policies[{{ $policy->id }}][is_active]" value="1" {{ $policy->is_active ? 'checked' : '' }}>
                      <span class="ml-2">{{ $policy->is_active ? __('Active') : __('Paused') }}</span>
                    </label>
                  </td>
                  <td style="min-width: 190px;">
                    <select class="form-control" name="policies[{{ $policy->id }}][fee_type]">
                      @foreach ($feeTypes as $value => $label)
                        <option value="{{ $value }}" {{ $policy->fee_type === $value ? 'selected' : '' }}>{{ __($label) }}</option>
                      @endforeach
                    </select>
                  </td>
                  <td style="min-width: 140px;">
                    <input type="number" step="0.0001" min="0" max="100" class="form-control"
                      name="policies[{{ $policy->id }}][percentage_value]"
                      value="{{ old('policies.' . $policy->id . '.percentage_value', $policy->percentage_value) }}">
                  </td>
                  <td style="min-width: 140px;">
                    <input type="number" step="0.01" min="0" class="form-control"
                      name="policies[{{ $policy->id }}][fixed_value]"
                      value="{{ old('policies.' . $policy->id . '.fixed_value', $policy->fixed_value) }}">
                  </td>
                  <td style="min-width: 140px;">
                    <input type="number" step="0.01" min="0" class="form-control"
                      name="policies[{{ $policy->id }}][minimum_fee]"
                      value="{{ old('policies.' . $policy->id . '.minimum_fee', $policy->minimum_fee) }}">
                  </td>
                  <td style="min-width: 140px;">
                    <input type="number" step="0.01" min="0" class="form-control"
                      name="policies[{{ $policy->id }}][maximum_fee]"
                      value="{{ old('policies.' . $policy->id . '.maximum_fee', $policy->maximum_fee) }}">
                  </td>
                  <td style="min-width: 180px;">
                    <select class="form-control" name="policies[{{ $policy->id }}][charged_to]">
                      @foreach ($chargedToOptions as $value => $label)
                        <option value="{{ $value }}" {{ $policy->charged_to === $value ? 'selected' : '' }}>{{ __($label) }}</option>
                      @endforeach
                    </select>
                  </td>
                  <td style="min-width: 110px;">
                    <input type="text" class="form-control"
                      name="policies[{{ $policy->id }}][currency]"
                      value="{{ old('policies.' . $policy->id . '.currency', $policy->currency ?: 'DOP') }}">
                  </td>
                </tr>
              @endforeach
            </tbody>
          </table>
        </div>

          @if ($errors->any())
            <div class="alert alert-danger mt-3 mb-0">
              <ul class="mb-0">
                @foreach ($errors->all() as $error)
                  <li>{{ $error }}</li>
                @endforeach
              </ul>
            </div>
          @endif
        </div>

        <div class="card-footer text-center">
          <button type="submit" class="btn btn-success">{{ __('Save Fee Policies') }}</button>
        </div>
      </form>
    </div>

    <div class="card ops-panel">
      <div class="card-header d-flex flex-wrap justify-content-between align-items-center">
        <div>
          <div class="card-title mb-1">{{ __('Recent audit log') }}</div>
          <p class="mb-0 text-muted">{{ __('Últimos cambios registrados en las políticas de fee.') }}</p>
        </div>
        <form method="GET" action="{{ route('admin.event_booking.settings.fee_policies') }}" class="form-inline">
          <label class="mr-2">{{ __('Policy') }}</label>
          <select class="form-control form-control-sm mr-2" name="audit_policy_id">
            <option value="">{{ __('All policies') }}</option>
            @foreach ($policies as $policy)
              <option value="{{ $policy->id }}" {{ (string) $selectedAuditPolicyId === (string) $policy->id ? 'selected' : '' }}>
                {{ $policy->label }}
              </option>
            @endforeach
          </select>
          <button type="submit" class="btn btn-sm btn-primary mr-2">{{ __('Filter') }}</button>
          <a href="{{ route('admin.event_booking.settings.fee_policies') }}" class="btn btn-sm btn-light">{{ __('Reset') }}</a>
        </form>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped ops-table mb-0">
          <thead>
            <tr>
              <th>{{ __('When') }}</th>
              <th>{{ __('Policy') }}</th>
              <th>{{ __('Admin') }}</th>
              <th>{{ __('Changed fields') }}</th>
              <th>{{ __('Snapshot') }}</th>
            </tr>
          </thead>
          <tbody>
            @forelse ($auditLogs as $log)
              @php
                $changedFields = collect(data_get($log->meta, 'changed_fields', []));
                $adminName = trim((string) optional($log->admin)->first_name . ' ' . optional($log->admin)->last_name);
                if ($adminName === '') {
                    $adminName = optional($log->admin)->username ?: __('System');
                }
              @endphp
              <tr>
                <td>{{ optional($log->created_at)->format('Y-m-d H:i') }}</td>
                <td>
                  <div class="font-weight-bold">{{ optional($log->policy)->label ?: ('Policy #' . $log->fee_policy_id) }}</div>
                  <div class="small text-muted">{{ optional($log->policy)->operation_key }}</div>
                </td>
                <td>{{ $adminName }}</td>
                <td>
                  @if ($changedFields->isEmpty())
                    <span class="text-muted">—</span>
                  @else
                    @foreach ($changedFields as $field)
                      <span class="badge badge-info mr-1">{{ $field }}</span>
                    @endforeach
                  @endif
                </td>
                <td class="small text-muted">
                  @if (!empty($log->before) && !empty($log->after))
                    {{ __('Before') }}: {{ json_encode($log->before) }}<br>
                    {{ __('After') }}: {{ json_encode($log->after) }}
                  @else
                    —
                  @endif
                </td>
              </tr>
            @empty
              <tr><td colspan="5" class="text-center text-muted py-4">{{ __('No audit entries recorded yet.') }}</td></tr>
            @endforelse
          </tbody>
        </table>
        </div>
      </div>
    </div>
  </div>
@endsection
