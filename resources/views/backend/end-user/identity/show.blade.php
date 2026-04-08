@extends('backend.layout')

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Identity Details') }}</h4>
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
        <a href="{{ route('admin.identity_management.index') }}">{{ __('Professional Identities') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ __('Identity Details') }}</a>
      </li>
    </ul>
  </div>

  <div class="row">
    <div class="col-md-8">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ $identity->display_name }} <small class="text-muted">#{{ $identity->id }}</small></div>
        </div>
        <div class="card-body">
          <div class="row mb-3">
            <div class="col-md-6">
              <strong>{{ __('Type') }}:</strong>
              <span class="badge badge-info">{{ strtoupper($identity->type) }}</span>
            </div>
            <div class="col-md-6">
              <strong>{{ __('Status') }}:</strong>
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
            </div>
          </div>

          <div class="mb-3">
            <strong>{{ __('Slug') }}:</strong> {{ $identity->slug }}
          </div>
          <div class="mb-3">
            <strong>{{ __('Created At') }}:</strong> {{ optional($identity->created_at)->format('Y-m-d H:i:s') }}
          </div>
          <div class="mb-3">
            <strong>{{ __('Updated At') }}:</strong> {{ optional($identity->updated_at)->format('Y-m-d H:i:s') }}
          </div>

          <hr>
          <h5>{{ __('Metadata') }}</h5>
          <pre class="p-3" style="background:#f8f9fa;border:1px solid #e9ecef;border-radius:6px;">{{ json_encode($identity->meta ?? [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) }}</pre>

          @php
            $revisionRequest = data_get($identity->meta, 'revision_request', []);
            $revisionFields = is_array($revisionRequest['fields'] ?? null) ? $revisionRequest['fields'] : [];
          @endphp
          @if (!empty($revisionRequest))
            <hr>
            <h5>{{ __('Current Revision Request') }}</h5>
            <p class="mb-1"><strong>{{ __('Reason') }}:</strong> {{ $revisionRequest['reason'] ?? '-' }}</p>
            <p class="mb-1"><strong>{{ __('Requested At') }}:</strong> {{ $revisionRequest['requested_at'] ?? '-' }}</p>
            <p class="mb-0"><strong>{{ __('Fields') }}:</strong>
              @if (count($revisionFields) > 0)
                {{ implode(', ', $revisionFields) }}
              @else
                {{ __('Not specified') }}
              @endif
            </p>
          @endif
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Moderation History') }}</div>
        </div>
        <div class="card-body">
          @if (count($history) === 0)
            <p class="text-muted mb-0">{{ __('No moderation actions yet.') }}</p>
          @else
            <div class="table-responsive">
              <table class="table table-striped">
                <thead>
                  <tr>
                    <th>{{ __('Action') }}</th>
                    <th>{{ __('Admin ID') }}</th>
                    <th>{{ __('Date') }}</th>
                    <th>{{ __('Details') }}</th>
                  </tr>
                </thead>
                <tbody>
                  @foreach (array_reverse($history) as $item)
                    <tr>
                      <td>{{ strtoupper($item['action'] ?? '-') }}</td>
                      <td>{{ $item['admin_id'] ?? '-' }}</td>
                      <td>{{ $item['at'] ?? '-' }}</td>
                      <td>
                        <pre class="mb-0" style="background:transparent;border:none;padding:0;">{{ json_encode($item['details'] ?? [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) }}</pre>
                      </td>
                    </tr>
                  @endforeach
                </tbody>
              </table>
            </div>
          @endif
        </div>
      </div>
    </div>

    <div class="col-md-4">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Owner') }}</div>
        </div>
        <div class="card-body">
          <p><strong>{{ __('Name') }}:</strong> {{ optional($identity->owner)->first_name }} {{ optional($identity->owner)->last_name }}</p>
          <p><strong>{{ __('Username') }}:</strong> {{ optional($identity->owner)->username }}</p>
          <p><strong>{{ __('Email') }}:</strong> {{ optional($identity->owner)->email }}</p>
          <p class="mb-0"><strong>{{ __('Owner User ID') }}:</strong> {{ $identity->owner_user_id }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Members') }}</div>
        </div>
        <div class="card-body">
          @if ($identity->members->count() === 0)
            <p class="text-muted mb-0">{{ __('No members found.') }}</p>
          @else
            <ul class="list-unstyled mb-0">
              @foreach ($identity->members as $member)
                <li class="mb-2 pb-2 border-bottom">
                  <strong>{{ optional($member->user)->first_name }} {{ optional($member->user)->last_name }}</strong><br>
                  <small>{{ optional($member->user)->email }}</small><br>
                  <span class="badge badge-secondary">{{ $member->role }}</span>
                  <span class="badge badge-light">{{ $member->status }}</span>
                </li>
              @endforeach
            </ul>
          @endif
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Moderation Actions') }}</div>
        </div>
        <div class="card-body">
          @if ($identity->status === 'pending')
            <form action="{{ route('admin.identity_management.approve', ['id' => $identity->id]) }}" method="POST" class="mb-2">
              @csrf
              <button type="submit" class="btn btn-success btn-block">{{ __('Approve') }}</button>
            </form>

            <form action="{{ route('admin.identity_management.reject', ['id' => $identity->id]) }}" method="POST" class="mb-2">
              @csrf
              <input type="text" class="form-control mb-2" name="reason" placeholder="{{ __('Reason for rejection') }}"
                required>
              <button type="submit" class="btn btn-danger btn-block">{{ __('Reject') }}</button>
            </form>

            <form action="{{ route('admin.identity_management.request_info', ['id' => $identity->id]) }}" method="POST"
              class="mb-2">
              @csrf
              <input type="text" class="form-control mb-2" name="reason"
                placeholder="{{ __('Requested information') }}" required>
              <input type="text" class="form-control mb-2" name="fields"
                placeholder="{{ __('Optional fields (comma separated): legal_name, contact_email') }}">
              <button type="submit" class="btn btn-warning btn-block">{{ __('Request Info') }}</button>
            </form>
          @endif

          @if ($identity->status === 'active')
            <form action="{{ route('admin.identity_management.suspend', ['id' => $identity->id]) }}" method="POST"
              class="mb-2">
              @csrf
              <input type="text" class="form-control mb-2" name="reason" placeholder="{{ __('Reason for suspension') }}"
                required>
              <button type="submit" class="btn btn-dark btn-block">{{ __('Suspend') }}</button>
            </form>
          @endif

          @if ($identity->status === 'suspended')
            <form action="{{ route('admin.identity_management.reactivate', ['id' => $identity->id]) }}" method="POST"
              class="mb-2">
              @csrf
              <button type="submit" class="btn btn-info btn-block">{{ __('Reactivate') }}</button>
            </form>
          @endif

          <a href="{{ route('admin.identity_management.index') }}" class="btn btn-light btn-block">{{ __('Back to list') }}</a>
        </div>
      </div>
    </div>
  </div>
@endsection
