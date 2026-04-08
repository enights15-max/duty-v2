@extends('backend.layout')

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Community Reviews') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ route('admin.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Customers Management') }}</a></li>
      <li class="separator"><i class="flaticon-right-arrow"></i></li>
      <li class="nav-item"><a href="#">{{ __('Community Reviews') }}</a></li>
    </ul>
  </div>

  <div class="row mb-3">
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Total') }}</div><div class="h4 mb-0">{{ $metrics['total'] }}</div></div></div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Pending') }}</div><div class="h4 mb-0 text-warning">{{ $metrics['pending_moderation'] }}</div></div></div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Published') }}</div><div class="h4 mb-0 text-success">{{ $metrics['published'] }}</div></div></div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Hidden') }}</div><div class="h4 mb-0 text-secondary">{{ $metrics['hidden'] }}</div></div></div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Rejected') }}</div><div class="h4 mb-0 text-danger">{{ $metrics['rejected'] }}</div></div></div>
    </div>
    <div class="col-md-2 col-6 mb-2">
      <div class="card mb-0"><div class="card-body py-3"><div class="small text-muted">{{ __('Avg Rating') }}</div><div class="h4 mb-0">{{ $metrics['average_rating'] }}</div></div></div>
    </div>
  </div>

  <div class="card">
    <div class="card-header">
      <div class="card-title">{{ __('Moderation Queue') }}</div>
    </div>
    <div class="card-body">
      <form class="mb-3" method="GET" action="{{ route('admin.review_management.index') }}">
        <div class="row">
          <div class="col-md-4 mb-2">
            <input type="text" name="q" class="form-control" value="{{ $queryText }}"
              placeholder="{{ __('Search by comment, customer or event') }}">
          </div>
          <div class="col-md-2 mb-2">
            <select name="status" class="form-control">
              <option value="pending_moderation" {{ $status === 'pending_moderation' ? 'selected' : '' }}>{{ __('Pending') }}</option>
              <option value="all" {{ $status === 'all' ? 'selected' : '' }}>{{ __('All Statuses') }}</option>
              <option value="published" {{ $status === 'published' ? 'selected' : '' }}>{{ __('Published') }}</option>
              <option value="hidden" {{ $status === 'hidden' ? 'selected' : '' }}>{{ __('Hidden') }}</option>
              <option value="rejected" {{ $status === 'rejected' ? 'selected' : '' }}>{{ __('Rejected') }}</option>
            </select>
          </div>
          <div class="col-md-2 mb-2">
            <select name="target_type" class="form-control">
              <option value="" {{ $targetType === '' ? 'selected' : '' }}>{{ __('All Targets') }}</option>
              <option value="event" {{ $targetType === 'event' ? 'selected' : '' }}>{{ __('Event') }}</option>
              <option value="organizer" {{ $targetType === 'organizer' ? 'selected' : '' }}>{{ __('Organizer') }}</option>
              <option value="artist" {{ $targetType === 'artist' ? 'selected' : '' }}>{{ __('Artist') }}</option>
            </select>
          </div>
          <div class="col-md-2 mb-2">
            <button type="submit" class="btn btn-primary btn-block">{{ __('Filter') }}</button>
          </div>
          <div class="col-md-2 mb-2">
            <a href="{{ route('admin.review_management.index') }}" class="btn btn-light btn-block">{{ __('Reset') }}</a>
          </div>
        </div>
      </form>

      <div class="table-responsive">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>{{ __('ID') }}</th>
              <th>{{ __('Target') }}</th>
              <th>{{ __('Customer') }}</th>
              <th>{{ __('Event') }}</th>
              <th>{{ __('Rating') }}</th>
              <th>{{ __('Status') }}</th>
              <th>{{ __('Submitted') }}</th>
              <th>{{ __('Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            @forelse($reviews as $review)
              @php
                $meta = is_array($review->meta) ? $review->meta : [];
                $targetSnapshot = is_array($meta['target_snapshot'] ?? null) ? $meta['target_snapshot'] : [];
                $targetLabel = $targetSnapshot['name'] ?? ucfirst(str_replace('App\\Models\\', '', class_basename($review->reviewable_type))) . ' #' . $review->reviewable_id;
                $eventTitle = optional(optional($review->event)->information)->title ?? data_get($meta, 'event_snapshot.title') ?? __('Event') . ' #' . $review->event_id;
              @endphp
              <tr>
                <td>#{{ $review->id }}</td>
                <td>
                  <span class="badge badge-info text-uppercase">{{ class_basename($review->reviewable_type) }}</span><br>
                  <small>{{ $targetLabel }}</small>
                </td>
                <td>
                  {{ optional($review->customer)->fname }} {{ optional($review->customer)->lname }}<br>
                  <small>{{ optional($review->customer)->email }}</small>
                </td>
                <td>{{ $eventTitle }}</td>
                <td>{{ $review->rating }}/5</td>
                <td>
                  @if ($review->status === 'pending_moderation')
                    <span class="badge badge-warning">{{ __('Pending') }}</span>
                  @elseif($review->status === 'published')
                    <span class="badge badge-success">{{ __('Published') }}</span>
                  @elseif($review->status === 'hidden')
                    <span class="badge badge-secondary">{{ __('Hidden') }}</span>
                  @elseif($review->status === 'rejected')
                    <span class="badge badge-danger">{{ __('Rejected') }}</span>
                  @else
                    <span class="badge badge-light">{{ $review->status }}</span>
                  @endif
                </td>
                <td>{{ optional($review->submitted_at ?? $review->created_at)->format('Y-m-d H:i') }}</td>
                <td style="min-width: 280px;">
                  <a href="{{ route('admin.review_management.show', ['id' => $review->id]) }}" class="btn btn-sm btn-primary mb-1">{{ __('View') }}</a>

                  @if ($review->status !== 'published')
                    <form class="d-inline-block mb-1" action="{{ route('admin.review_management.publish', ['id' => $review->id]) }}" method="POST">
                      @csrf
                      <button type="submit" class="btn btn-sm btn-success">{{ __('Publish') }}</button>
                    </form>
                  @endif

                  @if ($review->status !== 'hidden' && $review->status !== 'rejected')
                    <form class="d-inline-block mb-1" action="{{ route('admin.review_management.hide', ['id' => $review->id]) }}" method="POST">
                      @csrf
                      <input type="text" name="reason" class="form-control form-control-sm mb-1" placeholder="{{ __('Hide reason') }}" required>
                      <button type="submit" class="btn btn-sm btn-dark">{{ __('Hide') }}</button>
                    </form>
                  @endif

                  @if ($review->status !== 'rejected')
                    <form class="d-inline-block mb-1" action="{{ route('admin.review_management.reject', ['id' => $review->id]) }}" method="POST">
                      @csrf
                      <input type="text" name="reason" class="form-control form-control-sm mb-1" placeholder="{{ __('Reject reason') }}" required>
                      <button type="submit" class="btn btn-sm btn-danger">{{ __('Reject') }}</button>
                    </form>
                  @endif
                </td>
              </tr>
            @empty
              <tr>
                <td colspan="8" class="text-center text-muted">{{ __('No reviews found for this filter.') }}</td>
              </tr>
            @endforelse
          </tbody>
        </table>
      </div>

      <div class="mt-3">{{ $reviews->links() }}</div>
    </div>
  </div>
@endsection
