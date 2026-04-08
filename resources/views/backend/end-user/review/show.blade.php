@extends('backend.layout')

@section('content')
  @php
    $meta = is_array($review->meta) ? $review->meta : [];
    $targetSnapshot = is_array($meta['target_snapshot'] ?? null) ? $meta['target_snapshot'] : [];
    $targetLabel = $targetSnapshot['name'] ?? class_basename($review->reviewable_type) . ' #' . $review->reviewable_id;
    $eventTitle = optional(optional($review->event)->information)->title ?? data_get($meta, 'event_snapshot.title') ?? __('Event') . ' #' . $review->event_id;
  @endphp

  <div class="page-header">
    <h4 class="page-title">{{ __('Review Details') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('admin.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="{{ route('admin.review_management.index') }}">{{ __('Community Reviews') }}</a></li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Review Details') }}</a></li>
    </ul>
  </div>

  <div class="row">
    <div class="col-md-8">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ $targetLabel }} <small class="text-muted">#{{ $review->id }}</small></div>
        </div>
        <div class="card-body">
          <div class="row mb-3">
            <div class="col-md-4"><strong>{{ __('Target Type') }}:</strong> {{ class_basename($review->reviewable_type) }}</div>
            <div class="col-md-4"><strong>{{ __('Status') }}:</strong> {{ $review->status }}</div>
            <div class="col-md-4"><strong>{{ __('Rating') }}:</strong> {{ $review->rating }}/5</div>
          </div>

          <div class="mb-3">
            <strong>{{ __('Event') }}:</strong> {{ $eventTitle }}
          </div>
          <div class="mb-3">
            <strong>{{ __('Submitted At') }}:</strong> {{ optional($review->submitted_at ?? $review->created_at)->format('Y-m-d H:i:s') }}
          </div>
          <div class="mb-3">
            <strong>{{ __('Comment') }}:</strong>
            <div class="p-3 mt-2" style="background:#f8f9fa;border:1px solid #e9ecef;border-radius:6px;white-space:pre-wrap;">{{ $review->comment ?: __('Rating only review.') }}</div>
          </div>

          <hr>
          <h5>{{ __('Moderation Metadata') }}</h5>
          <pre class="p-3" style="background:#f8f9fa;border:1px solid #e9ecef;border-radius:6px;">{{ json_encode($meta, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) }}</pre>
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
                    <th>{{ __('From') }}</th>
                    <th>{{ __('To') }}</th>
                    <th>{{ __('Admin ID') }}</th>
                    <th>{{ __('Date') }}</th>
                    <th>{{ __('Details') }}</th>
                  </tr>
                </thead>
                <tbody>
                  @foreach (array_reverse($history) as $item)
                    <tr>
                      <td>{{ strtoupper($item['action'] ?? '-') }}</td>
                      <td>{{ $item['from'] ?? '-' }}</td>
                      <td>{{ $item['to'] ?? '-' }}</td>
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
          <div class="card-title">{{ __('Customer') }}</div>
        </div>
        <div class="card-body">
          <p><strong>{{ __('Name') }}:</strong> {{ optional($review->customer)->fname }} {{ optional($review->customer)->lname }}</p>
          <p><strong>{{ __('Username') }}:</strong> {{ optional($review->customer)->username }}</p>
          <p><strong>{{ __('Email') }}:</strong> {{ optional($review->customer)->email }}</p>
          <p class="mb-0"><strong>{{ __('Customer ID') }}:</strong> {{ $review->customer_id }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Booking Context') }}</div>
        </div>
        <div class="card-body">
          <p><strong>{{ __('Booking ID') }}:</strong> {{ $review->booking_id ?: '-' }}</p>
          <p><strong>{{ __('Payment Status') }}:</strong> {{ paymentStatusLabel(optional($review->booking)->paymentStatus) }}</p>
          <p><strong>{{ __('Scan Status') }}:</strong> {{ optional($review->booking)->scan_status ?: '-' }}</p>
          <p class="mb-0"><strong>{{ __('Event ID') }}:</strong> {{ $review->event_id ?: '-' }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Moderation Actions') }}</div>
        </div>
        <div class="card-body">
          @if ($review->status !== 'published')
            <form action="{{ route('admin.review_management.publish', ['id' => $review->id]) }}" method="POST" class="mb-2">
              @csrf
              <input type="text" name="note" class="form-control mb-2" placeholder="{{ __('Optional publish note') }}">
              <button type="submit" class="btn btn-success btn-block">{{ __('Publish') }}</button>
            </form>
          @endif

          @if ($review->status !== 'hidden' && $review->status !== 'rejected')
            <form action="{{ route('admin.review_management.hide', ['id' => $review->id]) }}" method="POST" class="mb-2">
              @csrf
              <input type="text" name="reason" class="form-control mb-2" placeholder="{{ __('Reason for hiding') }}" required>
              <button type="submit" class="btn btn-dark btn-block">{{ __('Hide') }}</button>
            </form>
          @endif

          @if ($review->status !== 'rejected')
            <form action="{{ route('admin.review_management.reject', ['id' => $review->id]) }}" method="POST" class="mb-2">
              @csrf
              <input type="text" name="reason" class="form-control mb-2" placeholder="{{ __('Reason for rejection') }}" required>
              <button type="submit" class="btn btn-danger btn-block">{{ __('Reject') }}</button>
            </form>
          @endif

          <a href="{{ route('admin.review_management.index') }}" class="btn btn-light btn-block">{{ __('Back to list') }}</a>
        </div>
      </div>
    </div>
  </div>
@endsection
