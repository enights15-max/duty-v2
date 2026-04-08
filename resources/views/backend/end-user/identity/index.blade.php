@extends('backend.layout')

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Professional Identities') }}</h4>
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
        <a href="#">{{ __('Customers Management') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ __('Professional Identities') }}</a>
      </li>
    </ul>
  </div>

  <div class="row mb-3">
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Total') }}</div>
          <div class="h4 mb-0">{{ $metrics['total'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Pending') }}</div>
          <div class="h4 mb-0 text-warning">{{ $metrics['pending'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Active') }}</div>
          <div class="h4 mb-0 text-success">{{ $metrics['active'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Rejected') }}</div>
          <div class="h4 mb-0 text-danger">{{ $metrics['rejected'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Pending > 48h') }}</div>
          <div class="h4 mb-0 text-dark">{{ $metrics['pending_over_48h'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Avg Approval (h)') }}</div>
          <div class="h4 mb-0">{{ $metrics['avg_approval_hours'] ?? '-' }}</div>
        </div>
      </div>
    </div>
  </div>

  <div class="row mb-3">
    <div class="col-md-3 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Suspended') }}</div>
          <div class="h4 mb-0 text-secondary">{{ $metrics['suspended'] }}</div>
        </div>
      </div>
    </div>
    <div class="col-md-3 col-6 mb-2">
      <div class="card mb-0">
        <div class="card-body py-3">
          <div class="small text-muted">{{ __('Avg Rejection (h)') }}</div>
          <div class="h4 mb-0">{{ $metrics['avg_rejection_hours'] ?? '-' }}</div>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Verification Queue') }}</div>
        </div>
        <div class="card-body">
          <form class="mb-3" method="GET" action="{{ route('admin.identity_management.index') }}">
            <div class="row">
              <div class="col-md-3 mb-2">
                <input type="text" name="q" class="form-control" placeholder="{{ __('Search by name, slug or owner') }}"
                  value="{{ $queryText }}">
              </div>
              <div class="col-md-2 mb-2">
                <select name="status" class="form-control">
                  <option value="">{{ __('All Statuses') }}</option>
                  <option value="pending" {{ $status === 'pending' ? 'selected' : '' }}>{{ __('Pending') }}</option>
                  <option value="active" {{ $status === 'active' ? 'selected' : '' }}>{{ __('Active') }}</option>
                  <option value="rejected" {{ $status === 'rejected' ? 'selected' : '' }}>{{ __('Rejected') }}</option>
                  <option value="suspended" {{ $status === 'suspended' ? 'selected' : '' }}>{{ __('Suspended') }}</option>
                </select>
              </div>
              <div class="col-md-2 mb-2">
                <select name="type" class="form-control">
                  <option value="">{{ __('All Types') }}</option>
                  <option value="artist" {{ $type === 'artist' ? 'selected' : '' }}>{{ __('Artist') }}</option>
                  <option value="organizer" {{ $type === 'organizer' ? 'selected' : '' }}>{{ __('Organizer') }}</option>
                  <option value="venue" {{ $type === 'venue' ? 'selected' : '' }}>{{ __('Venue') }}</option>
                  <option value="personal" {{ $type === 'personal' ? 'selected' : '' }}>{{ __('Personal') }}</option>
                </select>
              </div>
              <div class="col-md-3 mb-2 d-flex align-items-center">
                <div class="form-check mt-1">
                  <input class="form-check-input" type="checkbox" value="1" id="includePersonalFilter"
                    name="include_personal" {{ !empty($includePersonal) ? 'checked' : '' }}>
                  <label class="form-check-label" for="includePersonalFilter">
                    {{ __('Include personal identities') }}
                  </label>
                </div>
              </div>
              <div class="col-md-2 mb-2">
                <button type="submit" class="btn btn-primary btn-block">{{ __('Filter') }}</button>
              </div>
              <div class="col-md-2 mb-2">
                <a href="{{ route('admin.identity_management.index') }}" class="btn btn-light btn-block">{{ __('Reset') }}</a>
              </div>
              <div class="col-md-2 mb-2">
                <a href="{{ route('admin.identity_management.export', ['status' => $status, 'type' => $type, 'q' => $queryText, 'include_personal' => !empty($includePersonal) ? 1 : 0]) }}"
                  class="btn btn-outline-success btn-block">{{ __('Export CSV') }}</a>
              </div>
            </div>
          </form>

          <div class="table-responsive">
            <table class="table table-striped">
              <thead>
                <tr>
                  <th>{{ __('ID') }}</th>
                  <th>{{ __('Type') }}</th>
                  <th>{{ __('Display Name') }}</th>
                  <th>{{ __('Owner') }}</th>
                  <th>{{ __('Members') }}</th>
                  <th>{{ __('Status') }}</th>
                  <th>{{ __('Created') }}</th>
                  <th>{{ __('Actions') }}</th>
                </tr>
              </thead>
              <tbody>
                @forelse($identities as $identity)
                  <tr>
                    <td>#{{ $identity->id }}</td>
                    <td><span class="badge badge-info">{{ strtoupper($identity->type) }}</span></td>
                    <td>{{ $identity->display_name }}</td>
                    <td>
                      {{ optional($identity->owner)->first_name }} {{ optional($identity->owner)->last_name }}
                      <br>
                      <small>{{ optional($identity->owner)->email }}</small>
                    </td>
                    <td>{{ $identity->members->count() }}</td>
                    <td>
                      @if ($identity->status === 'pending')
                        <span class="badge badge-warning">{{ __('Pending') }}</span>
                      @elseif($identity->status === 'active')
                        <span class="badge badge-success">{{ __('Active') }}</span>
                      @elseif($identity->status === 'rejected')
                        <span class="badge badge-danger">{{ __('Rejected') }}</span>
                      @elseif($identity->status === 'suspended')
                        <span class="badge badge-dark">{{ __('Suspended') }}</span>
                      @else
                        <span class="badge badge-secondary">{{ $identity->status }}</span>
                      @endif
                    </td>
                    <td>{{ optional($identity->created_at)->format('Y-m-d H:i') }}</td>
                    <td>
                      <a href="{{ route('admin.identity_management.show', ['id' => $identity->id]) }}"
                        class="btn btn-sm btn-primary mb-1">{{ __('View') }}</a>

                      @if ($identity->status === 'pending')
                        <form class="d-inline-block mb-1"
                          action="{{ route('admin.identity_management.approve', ['id' => $identity->id]) }}" method="POST">
                          @csrf
                          <button type="submit" class="btn btn-sm btn-success">{{ __('Approve') }}</button>
                        </form>

                        <form id="reject-form-{{ $identity->id }}" class="d-inline-block mb-1"
                          action="{{ route('admin.identity_management.reject', ['id' => $identity->id]) }}" method="POST">
                          @csrf
                          <input type="hidden" name="reason" id="reject-reason-{{ $identity->id }}">
                          <button type="button" class="btn btn-sm btn-danger"
                            onclick="submitIdentityReason('reject-reason-{{ $identity->id }}', 'reject-form-{{ $identity->id }}', '{{ __('Reason for rejection') }}')">
                            {{ __('Reject') }}
                          </button>
                        </form>

                        <form id="request-info-form-{{ $identity->id }}" class="d-inline-block mb-1"
                          action="{{ route('admin.identity_management.request_info', ['id' => $identity->id]) }}" method="POST">
                          @csrf
                          <input type="hidden" name="reason" id="request-info-reason-{{ $identity->id }}">
                          <input type="hidden" name="fields" id="request-info-fields-{{ $identity->id }}">
                          <button type="button" class="btn btn-sm btn-warning"
                            onclick="submitIdentityRequestInfo('request-info-reason-{{ $identity->id }}', 'request-info-fields-{{ $identity->id }}', 'request-info-form-{{ $identity->id }}', '{{ __('What information should the owner provide?') }}', '{{ __('Optional: add fields separated by comma (ex: legal_name, contact_email)') }}')">
                            {{ __('Request Info') }}
                          </button>
                        </form>
                      @endif

                      @if ($identity->status === 'active')
                        <form id="suspend-form-{{ $identity->id }}" class="d-inline-block mb-1"
                          action="{{ route('admin.identity_management.suspend', ['id' => $identity->id]) }}" method="POST">
                          @csrf
                          <input type="hidden" name="reason" id="suspend-reason-{{ $identity->id }}">
                          <button type="button" class="btn btn-sm btn-dark"
                            onclick="submitIdentityReason('suspend-reason-{{ $identity->id }}', 'suspend-form-{{ $identity->id }}', '{{ __('Reason for suspension') }}')">
                            {{ __('Suspend') }}
                          </button>
                        </form>
                      @endif

                      @if ($identity->status === 'suspended')
                        <form class="d-inline-block mb-1"
                          action="{{ route('admin.identity_management.reactivate', ['id' => $identity->id]) }}" method="POST">
                          @csrf
                          <button type="submit" class="btn btn-sm btn-info">{{ __('Reactivate') }}</button>
                        </form>
                      @endif
                    </td>
                  </tr>
                @empty
                  <tr>
                    <td colspan="8" class="text-center">{{ __('No identities found') }}</td>
                  </tr>
                @endforelse
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer text-center">
          {{ $identities->appends(['status' => $status, 'type' => $type, 'q' => $queryText, 'include_personal' => !empty($includePersonal) ? 1 : 0])->links() }}
        </div>
      </div>
    </div>
  </div>
@endsection

@push('scripts')
  <script>
    function submitIdentityReason(inputId, formId, promptText) {
      const reason = window.prompt(promptText);
      if (!reason || !reason.trim()) {
        return;
      }
      document.getElementById(inputId).value = reason.trim();
      document.getElementById(formId).submit();
    }

    function submitIdentityRequestInfo(reasonInputId, fieldsInputId, formId, reasonPromptText, fieldsPromptText) {
      const reason = window.prompt(reasonPromptText);
      if (!reason || !reason.trim()) {
        return;
      }

      const fields = window.prompt(fieldsPromptText) || '';
      document.getElementById(reasonInputId).value = reason.trim();
      document.getElementById(fieldsInputId).value = fields.trim();
      document.getElementById(formId).submit();
    }
  </script>
@endpush
