@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Edit Event') }}</h4>
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
                <a href="#">{{ __('Events Management') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a
                    href="{{ route('admin.event_management.event', ['language' => $defaultLang->code]) }}">{{ __('All Events') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>

            @php
                $event_title = DB::table('event_contents')
                    ->where('language_id', $defaultLang->id)
                    ->where('event_id', $event->id)
                    ->select('title')
                    ->first();
                if (empty($event_title)) {
                    $event_title = DB::table('event_contents')->where('event_id', $event->id)->select('title')->first();
                }

            @endphp
            @php
                $isPendingReview = (int) $event->status === 0 && (!empty($event->owner_identity_id) || !empty($event->venue_identity_id));
                $isProfessionalSubmission = !empty($event->owner_identity_id) || !empty($event->venue_identity_id);
                $managedByType = !empty($event->owner_identity_id) || !empty($event->organizer_id)
                    ? 'organizer'
                    : ((!empty($event->venue_identity_id) || !empty($event->venue_id)) ? 'venue' : 'admin');
                $managementLabel = match ($managedByType) {
                    'organizer' => __('Managed by organizer'),
                    'venue' => __('Managed by venue'),
                    default => __('Managed by admin'),
                };
                $hostingVenueName = $managedByType === 'organizer'
                    ? ($event->venue_name_snapshot ?: optional($event->venue)->name ?: optional($event->venue)->username)
                    : null;
                $reviewStatus = $event->review_status ?: null;
                $reviewStatusLabel = match ($reviewStatus) {
                    'pending' => __('Pending review'),
                    'approved' => __('Approved'),
                    'changes_requested' => __('Changes requested'),
                    'rejected' => __('Rejected'),
                    default => ($event->status == 1 ? __('Active') : __('Inactive')),
                };
                $reviewStatusBadgeClass = match ($reviewStatus) {
                    'approved' => 'success',
                    'changes_requested' => 'warning',
                    'rejected' => 'danger',
                    'pending' => 'info',
                    default => 'secondary',
                };
            @endphp
            <li class="nav-item">
                <a href="#">
                    {{ strlen($event_title->title) > 35 ? mb_substr($event_title->title, 0, 35, 'UTF-8') . '...' : $event_title->title }}
                </a>

            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>

            <li class="nav-item">
                <a href="#">{{ __('Edit Event') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title d-inline-block">{{ __('Edit Event') }}</div>


                    <a class="btn btn-info btn-sm float-right d-inline-block" href="{{ url()->previous() }}">
                        <span class="btn-label">
                            <i class="fas fa-backward"></i>
                        </span>
                        {{ __('Back') }}
                    </a>
                    <a class="mr-2 btn btn-success btn-sm float-right d-inline-block"
                        href="{{ route('event.details', ['slug' => eventSlug($defaultLang->id, $event->id), 'id' => $event->id]) }}"
                        target="_blank">
                        <span class="btn-label">
                            <i class="fas fa-eye"></i>
                        </span>
                        {{ __('Preview') }}
                    </a>
                    @if ($event->event_type == 'venue')
                        <a class="mr-2 btn btn-secondary btn-sm float-right d-inline-block"
                            href="{{ route('admin.event.ticket', ['language' => $defaultLang->code, 'event_id' => $event->id, 'event_type' => $event->event_type]) }}"
                            target="_blank">
                            <span class="btn-label">
                                <i class="far fa-ticket"></i>
                            </span>
                            {{ __('Tickets') }}
                        </a>
                    @endif
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="event-editor-hero">
                                <div>
                                    <span class="event-editor-hero__eyebrow">{{ __('Professional event authoring') }}</span>
                                    <h2 class="event-editor-hero__title">{{ __('Refine the live event experience before updating') }}</h2>
                                    <p class="event-editor-hero__copy">
                                        {{ __('Review media, timing, lineup and multilingual content in one polished workspace so every update stays consistent with the public event page.') }}
                                    </p>
                                </div>
                                <div class="event-editor-hero__stats">
                                    <div class="event-editor-hero__stat">
                                        <span class="event-editor-hero__stat-label">{{ __('Mode') }}</span>
                                        <span class="event-editor-hero__stat-value">{{ __('Edit') }}</span>
                                    </div>
                                    <div class="event-editor-hero__stat">
                                        <span class="event-editor-hero__stat-label">{{ __('Event type') }}</span>
                                        <span class="event-editor-hero__stat-value">{{ ucfirst($event->event_type) }}</span>
                                    </div>
                                    <div class="event-editor-hero__stat">
                                        <span class="event-editor-hero__stat-label">{{ __('Status') }}</span>
                                        <span class="event-editor-hero__stat-value">{{ $reviewStatusLabel }}</span>
                                    </div>
                                    <div class="event-editor-hero__stat">
                                        <span class="event-editor-hero__stat-label">{{ __('Date type') }}</span>
                                        <span class="event-editor-hero__stat-value">{{ ucfirst($event->date_type) }}</span>
                                    </div>
                                    </div>
                                </div>

                                <div class="card mt-4 mb-4 border-0 shadow-sm" style="background: linear-gradient(180deg, #fff8f5 0%, #f6ece8 100%); border: 1px solid rgba(193,18,31,0.10);">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-start flex-wrap">
                                            <div class="pr-3">
                                                <h5 class="mb-1">{{ __('Management context') }}</h5>
                                                <p class="text-muted mb-0">
                                                    {{ __('Clarify which profile controls this event and which venue only hosts it, so access and review decisions stay consistent.') }}
                                                </p>
                                            </div>
                                            <span class="badge badge-dark px-3 py-2">{{ $managementLabel }}</span>
                                        </div>

                                        @if (!empty($hostingVenueName))
                                            <div class="mt-3">
                                                <span class="badge badge-secondary px-3 py-2">{{ __('Host venue') }}: {{ $hostingVenueName }}</span>
                                            </div>
                                            <p class="text-muted mt-3 mb-0">
                                                {{ __('The host venue provides the location context, but management stays with the organizer that created the event.') }}
                                            </p>
                                        @endif
                                    </div>
                                </div>

                            @if ($isProfessionalSubmission)
                                <div class="card mb-4 border-0 shadow-sm" style="background: linear-gradient(180deg, #fffaf7 0%, #f5ece7 100%); border: 1px solid rgba(193,18,31,0.10);">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-start flex-wrap mb-3">
                                            <div class="pr-3">
                                                <h5 class="mb-1">{{ __('Review workflow') }}</h5>
                                                <p class="text-muted mb-0">
                                                    {{ __('Use these actions to approve the event, request changes, or reject it with a visible note for the professional profile.') }}
                                                </p>
                                            </div>
                                            <span class="badge badge-{{ $reviewStatusBadgeClass }}">{{ $reviewStatusLabel }}</span>
                                        </div>

                                        @if (!empty($event->review_notes))
                                            <div class="alert alert-secondary mb-3">
                                                <strong>{{ __('Current review notes') }}:</strong>
                                                <div class="mt-1">{{ $event->review_notes }}</div>
                                            </div>
                                        @endif

                                        <form action="{{ route('admin.event_management.event.event_status', ['id' => $event->id, 'language' => $defaultLang->code]) }}" method="post">
                                            @csrf
                                            <div class="form-group mb-3">
                                                <label for="review_notes"><strong>{{ __('Review notes') }}</strong></label>
                                                <textarea id="review_notes" name="review_notes" rows="4" class="form-control" placeholder="{{ __('Explain what needs to change or why the event is being rejected.') }}">{{ old('review_notes', $event->review_notes) }}</textarea>
                                            </div>
                                            <div class="d-flex flex-wrap" style="gap: 12px;">
                                                <button type="submit" name="review_action" value="approved" class="btn btn-success" onclick="document.getElementById('event-review-status-input').value='1';">
                                                    <i class="fas fa-check-circle mr-1"></i>{{ __('Approve') }}
                                                </button>
                                                <button type="submit" name="review_action" value="changes_requested" class="btn btn-warning" onclick="document.getElementById('event-review-status-input').value='0';">
                                                    <i class="fas fa-edit mr-1"></i>{{ __('Request changes') }}
                                                </button>
                                                <button type="submit" name="review_action" value="rejected" class="btn btn-danger" onclick="document.getElementById('event-review-status-input').value='0';">
                                                    <i class="fas fa-times-circle mr-1"></i>{{ __('Reject') }}
                                                </button>
                                            </div>
                                            <input type="hidden" id="event-review-status-input" name="status" value="{{ $event->status == 1 ? 1 : 0 }}">
                                        </form>
                                    </div>
                                </div>
                            @endif

                            <div class="card mb-4 border-0 shadow-sm" style="background: linear-gradient(180deg, #fffaf7 0%, #f5ece7 100%); border: 1px solid rgba(193,18,31,0.10);">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start flex-wrap mb-3">
                                        <div class="pr-3">
                                            <h5 class="mb-1">{{ __('Collaboration activity') }}</h5>
                                            <p class="text-muted mb-0">
                                                {{ __('Support and operations can inspect split setup, payout mode changes, manual claims and auto-release activity without leaving the event workspace.') }}
                                            </p>
                                        </div>
                                        <div class="d-flex align-items-center flex-wrap" style="gap: 10px;">
                                            <span class="badge badge-dark px-3 py-2">
                                                {{ __('Filter') }}: {{ collect($collaborationActivityFilters)->firstWhere('key', $collaborationActivityFilter)['label'] ?? __('All activity') }}
                                            </span>
                                            <a
                                                href="{{ route('admin.event_management.collaboration_activity_export', array_filter([
                                                    'id' => $event->id,
                                                    'collaboration_activity' => $collaborationActivityFilter,
                                                    'collaboration_activity_from' => $collaborationActivityFrom ?? null,
                                                    'collaboration_activity_to' => $collaborationActivityTo ?? null,
                                                ], fn ($value) => !is_null($value) && $value !== '')) }}"
                                                class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-file-export mr-1"></i>{{ __('Export CSV') }}
                                            </a>
                                        </div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-md-3 col-sm-6 mb-3">
                                            <div class="border rounded p-3 h-100">
                                                <small class="text-uppercase text-muted d-block">{{ __('Configured collaborators') }}</small>
                                                <strong class="d-block mt-1" style="font-size: 1.15rem;">
                                                    {{ count($collaborationSummary['splits'] ?? []) }}
                                                </strong>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 mb-3">
                                            <div class="border rounded p-3 h-100">
                                                <small class="text-uppercase text-muted d-block">{{ __('Claimable now') }}</small>
                                                <strong class="d-block mt-1" style="font-size: 1.15rem;">
                                                    {{ (int) ($collaborationSummary['claimable_count'] ?? 0) }}
                                                </strong>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 mb-3">
                                            <div class="border rounded p-3 h-100">
                                                <small class="text-uppercase text-muted d-block">{{ __('Reserved for collaborators') }}</small>
                                                <strong class="d-block mt-1" style="font-size: 1.15rem;">
                                                    {{ $getCurrencyInfo->base_currency_symbol_position == 'left'
                                                        ? $getCurrencyInfo->base_currency_symbol . number_format((float) ($collaborationSummary['reserved_for_collaborators'] ?? 0), 2)
                                                        : number_format((float) ($collaborationSummary['reserved_for_collaborators'] ?? 0), 2) . $getCurrencyInfo->base_currency_symbol }}
                                                </strong>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 mb-3">
                                            <div class="border rounded p-3 h-100">
                                                <small class="text-uppercase text-muted d-block">{{ __('Distributable pool') }}</small>
                                                <strong class="d-block mt-1" style="font-size: 1.15rem;">
                                                    {{ $getCurrencyInfo->base_currency_symbol_position == 'left'
                                                        ? $getCurrencyInfo->base_currency_symbol . number_format((float) ($collaborationSummary['distributable_amount'] ?? 0), 2)
                                                        : number_format((float) ($collaborationSummary['distributable_amount'] ?? 0), 2) . $getCurrencyInfo->base_currency_symbol }}
                                                </strong>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="d-flex flex-wrap mb-3" style="gap: 10px;">
                                        @foreach ($collaborationActivityFilters as $activityFilter)
                                            @php
                                                $isActiveActivityFilter = $collaborationActivityFilter === $activityFilter['key'];
                                            @endphp
                                            <a
                                                href="{{ route('admin.event_management.edit_event', array_filter([
                                                    'id' => $event->id,
                                                    'collaboration_activity' => $activityFilter['key'],
                                                    'collaboration_activity_from' => $collaborationActivityFrom ?? null,
                                                    'collaboration_activity_to' => $collaborationActivityTo ?? null,
                                                ], fn ($value) => !is_null($value) && $value !== '')) }}"
                                                class="btn btn-sm {{ $isActiveActivityFilter ? 'btn-primary' : 'btn-outline-secondary' }}">
                                                {{ $activityFilter['label'] }}
                                                <span class="ml-1 badge {{ $isActiveActivityFilter ? 'badge-light' : 'badge-secondary' }}">
                                                    {{ $activityFilter['count'] }}
                                                </span>
                                            </a>
                                        @endforeach
                                    </div>

                                    <form action="{{ route('admin.event_management.edit_event', ['id' => $event->id]) }}" method="get" class="row align-items-end mb-3">
                                        <div class="col-md-4">
                                            <label class="small text-uppercase text-muted">{{ __('From') }}</label>
                                            <input type="date" name="collaboration_activity_from" value="{{ $collaborationActivityFrom ?? '' }}" class="form-control">
                                        </div>
                                        <div class="col-md-4">
                                            <label class="small text-uppercase text-muted">{{ __('To') }}</label>
                                            <input type="date" name="collaboration_activity_to" value="{{ $collaborationActivityTo ?? '' }}" class="form-control">
                                        </div>
                                        <div class="col-md-4">
                                            <input type="hidden" name="collaboration_activity" value="{{ $collaborationActivityFilter }}">
                                            <div class="d-flex" style="gap: 10px;">
                                                <button type="submit" class="btn btn-outline-primary">{{ __('Apply dates') }}</button>
                                                <a href="{{ route('admin.event_management.edit_event', ['id' => $event->id, 'collaboration_activity' => $collaborationActivityFilter]) }}" class="btn btn-light">{{ __('Clear dates') }}</a>
                                            </div>
                                        </div>
                                    </form>

                                    @if (!empty($collaborationActivityItems))
                                        <div class="list-group">
                                            @foreach ($collaborationActivityItems as $activityItem)
                                                @php
                                                    $activityTypeLabel = match ($activityItem['type'] ?? 'split_configured') {
                                                        'split_configured' => __('Configuration'),
                                                        'mode_changed' => __('Mode change'),
                                                        'manual_claim_completed' => __('Manual payout'),
                                                        'auto_release_completed' => __('Auto release'),
                                                        default => __('Activity'),
                                                    };
                                                    $activityBadgeClass = match ($activityItem['type'] ?? 'split_configured') {
                                                        'split_configured' => 'secondary',
                                                        'mode_changed' => 'warning',
                                                        'manual_claim_completed' => 'success',
                                                        'auto_release_completed' => 'primary',
                                                        default => 'dark',
                                                    };
                                                    $activityAmount = (float) ($activityItem['amount'] ?? 0);
                                                    $formattedActivityAmount = $getCurrencyInfo->base_currency_symbol_position == 'left'
                                                        ? $getCurrencyInfo->base_currency_symbol . number_format($activityAmount, 2)
                                                        : number_format($activityAmount, 2) . $getCurrencyInfo->base_currency_symbol;
                                                @endphp
                                                <div class="list-group-item bg-transparent border rounded mb-2">
                                                    <div class="d-flex justify-content-between align-items-start flex-wrap" style="gap: 12px;">
                                                        <div class="pr-3">
                                                            <div class="d-flex align-items-center flex-wrap" style="gap: 10px;">
                                                                <strong>{{ $activityItem['title'] ?? __('Activity') }}</strong>
                                                                <span class="badge badge-{{ $activityBadgeClass }}">{{ $activityTypeLabel }}</span>
                                                            </div>
                                                            @if (!empty($activityItem['subtitle']))
                                                                <div class="text-muted mt-1">{{ $activityItem['subtitle'] }}</div>
                                                            @endif
                                                            @if (!empty($activityItem['occurred_at']))
                                                                <small class="text-muted d-block mt-2">
                                                                    {{ \Carbon\Carbon::parse($activityItem['occurred_at'])->timezone(config('app.timezone'))->format('M d, Y · h:i A') }}
                                                                </small>
                                                            @endif
                                                        </div>
                                                        <div class="text-right">
                                                            @if ($activityAmount > 0)
                                                                <div class="badge badge-success px-3 py-2">{{ $formattedActivityAmount }}</div>
                                                            @endif
                                                            @if (!empty($activityItem['is_automatic']))
                                                                <small class="d-block text-muted mt-2">{{ __('Automatic event settlement') }}</small>
                                                            @endif
                                                        </div>
                                                    </div>
                                                </div>
                                            @endforeach
                                        </div>
                                    @else
                                        <div class="alert alert-secondary mb-0">
                                            {{ __('No collaboration activity matches the selected filter yet.') }}
                                        </div>
                                    @endif
                                </div>
                            </div>

                            <div class="event-editor-shell">
                                <div class="event-editor-main">
                            <div class="alert alert-danger pb-1 dis-none" id="eventErrors">
                                <button type="button" class="close" data-dismiss="alert">×</button>
                                <ul></ul>
                            </div>
                            <div class="col-lg-12">
                                <label for="" class="mb-2"><strong>{{ __('Gallery Images') }} **</strong></label>
                                <div id="reload-slider-div">
                                    <div class="row mt-2">
                                        <div class="col">
                                            <table class="table" id="img-table">

                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <form action="{{ route('admin.event.imagesstore') }}" id="my-dropzone"
                                    enctype="multipart/formdata" class="dropzone create">
                                    @csrf
                                    <div class="fallback">
                                        <input name="file" type="file" multiple />
                                    </div>
                                    <input type="hidden" value="{{ $event->id }}" name="event_id">
                                </form>
                                <div class=" mb-0" id="errpreimg">

                                </div>
                                <p class="text-warning">{{ __('Image Size : 1170 x 570') }}</p>
                            </div>

                            <form id="eventForm" action="{{ route('admin.event.update') }}" method="POST"
                                enctype="multipart/form-data">
                                @csrf
                                <input type="hidden" name="event_id" value="{{ $event->id }}">
                                <input type="hidden" name="event_type" value="{{ $event->event_type }}">
                                <input type="hidden" name="gallery_images" value="0">
                                <div class="form-group">
                                    <label for="">{{ __('Thumbnail Image') . '*' }}</label>
                                    <br>
                                    <div class="thumb-preview">
                                        <img src="{{ $event->thumbnail ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) : asset('assets/admin/img/noimage.jpg') }}"
                                            alt="..." class="uploaded-img">
                                    </div>
                                    <div class="mt-3">
                                        <div role="button" class="btn btn-primary btn-sm upload-btn">
                                            {{ __('Choose Image') }}
                                            <input type="file" class="img-input" name="thumbnail">
                                        </div>
                                    </div>
                                    <p class="text-warning">{{ __('Image Size : 320x230') }}</p>
                                </div>

                                <div class="row">
                                    <div class="col-lg-12">
                                        <div class="form-group mt-1">
                                            <label for="">{{ __('Date Type') . '*' }}</label>
                                            <div class="selectgroup w-100">
                                                <label class="selectgroup-item">
                                                    <input type="radio" name="date_type" {{ $event->date_type == 'single' ? 'checked' : '' }} value="single"
                                                        class="selectgroup-input eventDateType" checked>
                                                    <span class="selectgroup-button">{{ __('Single') }}</span>
                                                </label>

                                                <label class="selectgroup-item">
                                                    <input type="radio" name="date_type" {{ $event->date_type == 'multiple' ? 'checked' : '' }} value="multiple"
                                                        class="selectgroup-input eventDateType">
                                                    <span class="selectgroup-button">{{ __('Multiple') }}</span>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row countDownStatus {{ $event->date_type == 'multiple' ? 'd-none' : '' }} ">
                                    <div class="col-lg-12">
                                        <div class="form-group mt-1">
                                            <label for="">{{ __('Countdown Status') . '*' }}</label>
                                            <div class="selectgroup w-100">
                                                <label class="selectgroup-item">
                                                    <input type="radio" name="countdown_status" value="1"
                                                        class="selectgroup-input" {{ $event->countdown_status == 1 ? 'checked' : '' }}>
                                                    <span class="selectgroup-button">{{ __('Active') }}</span>
                                                </label>

                                                <label class="selectgroup-item">
                                                    <input type="radio" name="countdown_status" value="0"
                                                        class="selectgroup-input" {{ $event->countdown_status == 0 ? 'checked' : '' }}>
                                                    <span class="selectgroup-button">{{ __('Deactive') }}</span>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {{-- single dates --}}
                                <div class="row {{ $event->date_type == 'multiple' ? 'd-none' : '' }}" id="single_dates">
                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label>{{ __('Start Date"') . '*' }}</label>
                                            <input type="date" name="start_date" value="{{ $event->start_date }}"
                                                placeholder="Enter Start Date" class="form-control">
                                        </div>
                                    </div>

                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('Start Time') . '*' }}</label>
                                            <input type="time" name="start_time" value="{{ $event->start_time }}"
                                                class="form-control">
                                        </div>
                                    </div>

                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label>{{ __('End Date"') . '*' }}</label>
                                            <input type="date" name="end_date" value="{{ $event->end_date }}"
                                                placeholder="Enter End Date" class="form-control">
                                        </div>
                                    </div>

                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('End Time') . '*' }}</label>
                                            <input type="time" name="end_time" value="{{ $event->end_time }}"
                                                class="form-control">
                                        </div>
                                    </div>
                                </div>

                                {{-- multiple dates --}}
                                <div class="row">
                                    <div class="col-lg-12 {{ $event->date_type == 'single' ? 'd-none' : '' }}"
                                        id="multiple_dates">
                                        @if ($event->date_type == 'multiple')
                                            @php
                                                $event_dates = $event->dates()->get();
                                            @endphp
                                        @else
                                            @php
                                                $event_dates = [];
                                            @endphp
                                        @endif
                                        <div class="form-group">
                                            <div class="table-responsive">
                                                <table class="table table-bordered">
                                                    <thead>
                                                        <tr>
                                                            <th scope="col">{{ __('Start Date') }}</th>
                                                            <th scope="col">{{ __('Start Time') }}</th>
                                                            <th scope="col">{{ __('End Date') }}</th>
                                                            <th scope="col">{{ __('End Time') }}</th>
                                                            <th scope="col"><a href="javascrit:void(0)"
                                                                    class="btn btn-success addDateRow"><i
                                                                        class="fas fa-plus-circle"></i></a></th>
                                                        </tr>
                                                    <tbody>
                                                        @if (count($event_dates) > 0)
                                                            @foreach ($event_dates as $date)
                                                                <tr>
                                                                    <td>
                                                                        <div class="form-group">
                                                                            <label for="">{{ __('Start Date') . '*' }}</label>
                                                                            <input type="date" name="m_start_date[]"
                                                                                class="form-control"
                                                                                value="{{ $date->start_date }}">
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="form-group">
                                                                            <label for="">{{ __('Start Time') . '*' }}</label>
                                                                            <input type="time" name="m_start_time[]"
                                                                                class="form-control"
                                                                                value="{{ $date->start_time }}">
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="form-group">
                                                                            <label for="">{{ __('End Date') . '*' }}
                                                                            </label>
                                                                            <input type="date" name="m_end_date[]"
                                                                                class="form-control" value="{{ $date->end_date }}">
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="form-group">
                                                                            <label for="">{{ __('End Time') . '*' }}
                                                                            </label>
                                                                            <input type="time" name="m_end_time[]"
                                                                                class="form-control" value="{{ $date->end_time }}">
                                                                        </div>
                                                                    </td>
                                                                    <input type="hidden" name="date_ids[]" value="{{ $date->id }}">
                                                                    <td>
                                                                        <a href="javascript:void(0)"
                                                                            data-url="{{ route('admin.event.delete.date', $date->id) }}"
                                                                            class="btn btn-danger deleteDateDbRow">
                                                                            <i class="fas fa-minus"></i></a>
                                                                    </td>
                                                                </tr>
                                                            @endforeach
                                                        @else
                                                            <tr>
                                                                <td>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Start Date') . '*' }}</label>
                                                                        <input type="date" name="m_start_date[]"
                                                                            class="form-control">
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Start Time') . '*' }}</label>
                                                                        <input type="time" name="m_start_time[]"
                                                                            class="form-control">
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('End Date') . '*' }}
                                                                        </label>
                                                                        <input type="date" name="m_end_date[]"
                                                                            class="form-control">
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('End Time') . '*' }}
                                                                        </label>
                                                                        <input type="time" name="m_end_time[]"
                                                                            class="form-control">
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <a href="javascript:void(0)"
                                                                        class="btn btn-danger deleteDateRow">
                                                                        <i class="fas fa-minus"></i></a>
                                                                </td>
                                                            </tr>
                                                        @endif

                                                    </tbody>
                                                    </thead>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row ">
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label for="">{{ __('Status') . '*' }}</label>
                                            <select name="status" class="form-control">
                                                <option selected disabled>{{ __('Select a Status') }}</option>
                                                <option {{ $event->status == '1' ? 'selected' : '' }} value="1">
                                                    {{ __('Active') }}
                                                </option>
                                                <option {{ $event->status == '0' ? 'selected' : '' }} value="0">
                                                    {{ __('Deactive') }}
                                                </option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('Age Limit') }}</label>
                                            <input type="number" name="age_limit" class="form-control"
                                                placeholder="0 = All Ages" value="{{ $event->age_limit ?? 0 }}" min="0">
                                            <p class="text-warning mb-0">{{ __('Set 0 for All Ages') }}</p>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('Is Feature') . '*' }}</label>
                                            <select name="is_featured" class="form-control">
                                                <option selected disabled>{{ __('Select') }}</option>
                                                <option value="yes" {{ $event->is_featured == 'yes' ? 'selected' : '' }}>
                                                    {{ __('Yes') }}
                                                </option>
                                                <option value="no" {{ $event->is_featured == 'no' ? 'selected' : '' }}>
                                                    {{ __('No') }}
                                                </option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('Organizer') }}</label>
                                            <select name="organizer_id" class="form-control js-example-basic-single">
                                                <option value="" selected>{{ __('Select Organizer') }}</option>
                                                @foreach ($organizers as $organizer)
                                                    <option {{ $organizer->id == $event->organizer_id ? 'selected' : '' }}
                                                        value="{{ $organizer->id }}">{{ $organizer->username }}</option>
                                                @endforeach
                                            </select>
                                            <p class="text-warning">{{ __("Please leave it blank for Admin's event") }}
                                            </p>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="form-group">
                                            <label for="">{{ __('Artists') }}</label>
                                            @php
                                                $selectedArtists = $event->artists->pluck('id')->toArray();
                                            @endphp
                                            <select name="artist_ids[]" class="form-control js-example-basic-single" multiple="multiple">
                                                @foreach ($artists as $artist)
                                                    <option value="{{ $artist->id }}" {{ in_array($artist->id, $selectedArtists) ? 'selected' : '' }}>
                                                        {{ $artist->username }}
                                                    </option>
                                                @endforeach
                                            </select>
                                            <p class="text-warning">{{ __('Select multiple artists if applicable') }}</p>
                                        </div>
                                    </div>
                                </div>
                                @if ($event->event_type == 'online')
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form-group mt-1">
                                                <label for="">{{ __('Total Number of Available Tickets') . '*' }}</label>
                                                <div class="selectgroup w-100">
                                                    <label class="selectgroup-item">
                                                        <input type="radio" name="ticket_available_type" value="unlimited"
                                                            class="selectgroup-input" {{ @$event->ticket->ticket_available_type == 'unlimited' ? 'checked' : '' }}>
                                                        <span class="selectgroup-button">{{ __('Unlimited') }}</span>
                                                    </label>

                                                    <label class="selectgroup-item">
                                                        <input type="radio" name="ticket_available_type" value="limited"
                                                            class="selectgroup-input" {{ @$event->ticket->ticket_available_type == 'limited' ? 'checked' : '' }}>
                                                        <span class="selectgroup-button">{{ __('Limited') }}</span>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-lg-6 {{ @$event->ticket->ticket_available_type == 'limited' ? '' : 'd-none' }}"
                                            id="ticket_available">
                                            <div class="form-group">
                                                <label>{{ __('Enter total number of available tickets') . '*' }}</label>
                                                <input type="number" name="ticket_available"
                                                    placeholder="Enter total number of available tickets" class="form-control"
                                                    value="{{ @$event->ticket->ticket_available }}">
                                            </div>
                                        </div>
                                        @if ($websiteInfo->event_guest_checkout_status != 1)
                                            <div class="col-lg-6">
                                                <div class="form-group mt-1">
                                                    <label
                                                        for="">{{ __('Maximum number of tickets for each customer') . '*' }}</label>
                                                    <div class="selectgroup w-100">
                                                        <label class="selectgroup-item">
                                                            <input type="radio" name="max_ticket_buy_type" value="unlimited"
                                                                class="selectgroup-input" {{ @$event->ticket->max_ticket_buy_type == 'unlimited' ? 'checked' : '' }}>
                                                            <span class="selectgroup-button">{{ __('Unlimited') }}</span>
                                                        </label>

                                                        <label class="selectgroup-item">
                                                            <input type="radio" name="max_ticket_buy_type" value="limited"
                                                                class="selectgroup-input" {{ @$event->ticket->max_ticket_buy_type == 'limited' ? 'checked' : '' }}>
                                                            <span class="selectgroup-button">{{ __('Limited') }}</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-lg-6 {{ @$event->ticket->max_ticket_buy_type == 'limited' ? '' : 'd-none' }}"
                                                id="max_buy_ticket">
                                                <div class="form-group">
                                                    <label>{{ __('Enter Maximum number of tickets for each customer') . '*' }}</label>
                                                    <input type="number" name="max_buy_ticket"
                                                        placeholder="Enter Maximum number of tickets for each customer"
                                                        class="form-control" value="{{ @$event->ticket->max_buy_ticket }}">
                                                </div>
                                            </div>
                                        @else
                                            <input type="hidden" name="max_ticket_buy_type" value="unlimited">
                                        @endif

                                        <div class="col-lg-6">
                                            <div class="">
                                                <div class="form-group">
                                                    <label for="">{{ __('Price') }}
                                                        ({{ $getCurrencyInfo->base_currency_text }})
                                                        *</label>
                                                    <input type="number" name="price" id="ticket-pricing"
                                                        value="{{ $event->ticket->price }}" placeholder="Enter Price"
                                                        class="form-control {{ optional($event->ticket)->pricing_type == 'free' ? 'd-none' : '' }}">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <input type="checkbox" name="pricing_type" {{ optional($event->ticket)->pricing_type == 'free' ? 'checked' : '' }}
                                                    value="free" class="" id="free_ticket"> <label
                                                    for="free_ticket">{{ __('Tickets are Free') }}</label>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="">
                                                <div class="form-group">
                                                    <label for="">{{ __('Meeting Url') }}
                                                        *</label>
                                                    <input type="text" name="meeting_url" value="{{ $event->meeting_url }}"
                                                        placeholder="Enter Price" class="form-control">
                                                </div>
                                            </div>
                                        </div>
                                    </div>



                                    <div class="row {{ optional($event->ticket)->pricing_type == 'free' ? 'd-none' : '' }}"
                                        id="early_bird_discount_free">
                                        <div class="col-lg-12">
                                            <div class="form-group mt-1">
                                                <label for="">{{ __('Early Bird Discount') . '*' }}</label>
                                                <div class="selectgroup w-100">
                                                    <label class="selectgroup-item">
                                                        <input type="radio" name="early_bird_discount_type" {{ optional($event->ticket)->early_bird_discount == 'disable' ? 'checked' : '' }} value="disable" class="selectgroup-input" checked>
                                                        <span class="selectgroup-button">{{ __('Disable') }}</span>
                                                    </label>

                                                    <label class="selectgroup-item">
                                                        <input type="radio" name="early_bird_discount_type" {{ optional($event->ticket)->early_bird_discount == 'enable' ? 'checked' : '' }} value="enable" class="selectgroup-input">
                                                        <span class="selectgroup-button">{{ __('Enable') }}</span>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-lg-12 {{ optional($event->ticket)->early_bird_discount == 'disable' ? 'd-none' : '' }}"
                                            id="early_bird_dicount">
                                            <div class="row">
                                                <div class="col-lg-3">
                                                    <div class="form-group">
                                                        <label for="">{{ __('Discount') }} *</label>
                                                        <select name="discount_type" class="form-control discount_type">
                                                            <option disabled>{{ __('Select Discount Type') }}</option>
                                                            <option {{ optional($event->ticket)->early_bird_discount_type == 'fixed' ? 'selected' : '' }} value="fixed">{{ __('Fixed') }}</option>
                                                            <option {{ optional($event->ticket)->early_bird_discount_type == 'percentage' ? 'selected' : '' }} value="percentage">{{ __('Percentage') }}
                                                            </option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col-lg-3">
                                                    <div class="form-group">
                                                        <label for="">{{ __('Amount') }} *</label>
                                                        <input type="number" name="early_bird_discount_amount"
                                                            value="{{ optional($event->ticket)->early_bird_discount_amount }}"
                                                            class="form-control early_bird_discount_amount">
                                                    </div>
                                                </div>
                                                <div class="col-lg-3">
                                                    <div class="form-group">
                                                        <label for="">{{ __('Discount End Date') }} *</label>
                                                        <input type="date" name="early_bird_discount_date"
                                                            value="{{ optional($event->ticket)->early_bird_discount_date }}"
                                                            class="form-control">
                                                    </div>
                                                </div>
                                                <div class="col-lg-3">
                                                    <div class="form-group">
                                                        <label for="">{{ __('Discount End Time') }} *</label>
                                                        <input type="time" name="early_bird_discount_time"
                                                            value="{{ optional($event->ticket)->early_bird_discount_time }}"
                                                            class="form-control">
                                                    </div>
                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                @endif


                                <div id="accordion" class="mt-3">
                                    @foreach ($languages as $language)
                                        <div class="version">
                                            <div class="version-header" id="heading{{ $language->id }}">
                                                <h5 class="mb-0">
                                                    <button type="button" class="btn btn-link" data-toggle="collapse"
                                                        data-target="#collapse{{ $language->id }}"
                                                        aria-expanded="{{ $language->is_default == 1 ? 'true' : 'false' }}"
                                                        aria-controls="collapse{{ $language->id }}">
                                                        {{ $language->name . __(' Language') }}
                                                        {{ $language->is_default == 1 ? '(Default)' : '' }}
                                                    </button>
                                                </h5>
                                            </div>
                                            @php
                                                $event_content = DB::table('event_contents')
                                                    ->where('language_id', $language->id)
                                                    ->where('event_id', $event->id)
                                                    ->first();
                                            @endphp
                                            <div id="collapse{{ $language->id }}"
                                                class="collapse {{ $language->is_default == 1 ? 'show' : '' }}"
                                                aria-labelledby="heading{{ $language->id }}" data-parent="#accordion">
                                                <div class="version-body">
                                                    <div class="row">
                                                        <div class="col-lg-6">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                <label>{{ __('Event Title') . '*' }}</label>
                                                                <input type="text" class="form-control"
                                                                    name="{{ $language->code }}_title"
                                                                    value="{{ @$event_content->title }}"
                                                                    placeholder="Enter Event Name">
                                                            </div>
                                                        </div>

                                                        <div class="col-lg-6">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                @php
                                                                    $categories = DB::table('event_categories')
                                                                        ->where('language_id', $language->id)
                                                                        ->where('status', 1)
                                                                        ->orderBy('serial_number', 'asc')
                                                                        ->get();
                                                                @endphp

                                                                <label for="">{{ __('Category') . '*' }}</label>
                                                                <select name="{{ $language->code }}_category_id"
                                                                    class="form-control">
                                                                    <option selected disabled>{{ __('Select Category') }}
                                                                    </option>

                                                                    @foreach ($categories as $category)
                                                                        <option value="{{ $category->id }}" {{ @$event_content->event_category_id == $category->id ? 'selected' : '' }}>
                                                                            {{ $category->name }}
                                                                        </option>
                                                                    @endforeach
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    @if ($event->event_type == 'venue')
                                                        <div class="row">
                                                            <div class="col-lg-12">
                                                                <div class="form-group">
                                                                    <label for="">{{ __('Address') . '*' }}</label>
                                                                    <input type="text" name="{{ $language->code }}_address"
                                                                        class="form-control {{ $language->direction == 1 ? 'rtl text-right' : '' }}"
                                                                        placeholder="Enter Address"
                                                                        id="search-address_{{ $language->code }}"
                                                                        value="{{ @$event_content->address }}">
                                                                    @if ($language->is_default == 1 && $settings->google_map_status == 1)
                                                                        <a href="" class="btn btn-secondary mt-2 btn-sm"
                                                                            data-toggle="modal" data-target="#GoogleMapModal">
                                                                            <i class="fas fa-eye"></i>
                                                                            {{ __('Show Map') }}
                                                                        </a>
                                                                    @endif
                                                                </div>
                                                            </div>
                                                            <!-- latitude and longitude -->

                                                            @if ($language->is_default == 1)
                                                                <div class="col-lg-4">
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Latitude') }}</label>
                                                                        <input type="text" name="latitude"
                                                                            value="{{ @$event->latitude }}" placeholder="Latitude"
                                                                            class="form-control latitude">
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4">
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Longitude') }}</label>
                                                                        <input type="text" placeholder="Longitude"
                                                                            value="{{ @$event->longitude }}" name="longitude"
                                                                            class="form-control longitude">
                                                                    </div>
                                                                </div>
                                                            @endif

                                                            @if ($settings->event_country_status == 1)
                                                                @php
                                                                    $country = \DB::table('event_countries')
                                                                        ->where([
                                                                            ['language_id', $language->id],
                                                                            ['status', 1],
                                                                            ['id', $event_content->country_id],
                                                                        ])
                                                                        ->select('id', 'name')
                                                                        ->first();
                                                                @endphp
                                                                <div class="col-lg-4">
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('County') . '*' }}</label>
                                                                        <select name="{{ $language->code }}_country"
                                                                            data-lang="{{ $language->id }}"
                                                                            class="form-control countryDropdown country_select">
                                                                            @if (!is_null($country))
                                                                                <option selected value="{{ $country->id }}">
                                                                                    {{ $country->name }}
                                                                                </option>
                                                                            @else
                                                                                <option selected disabled>
                                                                                    {{ __('Select County') }}
                                                                                </option>
                                                                            @endif
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                            @endif
                                                            @if ($settings->event_state_status == 1)
                                                                @php
                                                                    $state = \DB::table('event_states')
                                                                        ->where([
                                                                            ['language_id', $language->id],
                                                                            ['status', 1],
                                                                            ['id', $event_content->state_id],
                                                                        ])
                                                                        ->select('id', 'name')
                                                                        ->first();
                                                                    $none = 'none';
                                                                @endphp
                                                                <div class="col-lg-4 state_div"
                                                                    style="display: {{ $settings->event_country_status == 0 || @$event_content->state_id ? '' : $none }}">
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('State') }}</label>
                                                                        <select name="{{ $language->code }}_state"
                                                                            data-lang="{{ $language->id }}"
                                                                            class="form-control stateDropdown state_select">
                                                                            @if (!is_null($state))
                                                                                <option selected value="{{ $state->id }}">
                                                                                    {{ $state->name }}
                                                                                </option>
                                                                            @else
                                                                                <option selected disabled>
                                                                                    {{ __('Select County') }}
                                                                                </option>
                                                                            @endif
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                            @endif

                                                            @php
                                                                $city = \DB::table('event_cities')
                                                                    ->where([
                                                                        ['language_id', $language->id],
                                                                        ['status', 1],
                                                                        ['id', $event_content->city_id],
                                                                    ])
                                                                    ->select('id', 'name')
                                                                    ->first();
                                                            @endphp
                                                            <div class="col-lg-4">
                                                                <div class="form-group">
                                                                    <label for="">{{ __('City') . '*' }}</label>
                                                                    <select name="{{ $language->code }}_city"
                                                                        data-lang="{{ $language->id }}"
                                                                        class="form-control cityDropdown city_select">
                                                                        @if (!is_null($city))
                                                                            <option selected value="{{ $city->id }}">
                                                                                {{ $city->name }}
                                                                            </option>
                                                                        @else
                                                                            <option selected disabled>
                                                                                {{ __('Select County') }}
                                                                            </option>
                                                                        @endif
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-4">
                                                                <div class="form-group">
                                                                    <label for="">{{ __('Zip/Post Code ') }}</label>
                                                                    <input type="text" placeholder="Enter Zip/Post Code"
                                                                        name="{{ $language->code }}_zip_code"
                                                                        class="form-control {{ $language->direction == 1 ? 'rtl text-right' : '' }}"
                                                                        value="{{ @$event_content->zip_code }}">
                                                                </div>
                                                            </div>
                                                        </div>
                                                    @endif

                                                    <div class="row">
                                                        <div class="col">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                <label>{{ __('Description') . '*' }}</label>
                                                                <textarea id="descriptionTmce{{ $language->id }}"
                                                                    class="form-control summernote"
                                                                    name="{{ $language->code }}_description"
                                                                    placeholder="Enter Event Description"
                                                                    data-height="300">{!! @$event_content->description !!}</textarea>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-lg-12">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                <label>{{ __('Refund Policy') }} *</label>
                                                                <textarea class="form-control"
                                                                    name="{{ $language->code }}_refund_policy" rows="5"
                                                                    placeholder="Enter Refund Policy">{{ @$event_content->refund_policy }}</textarea>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-lg-12">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                <label>{{ __('Event Meta Keywords') }}</label>
                                                                <input class="form-control"
                                                                    name="{{ $language->code }}_meta_keywords"
                                                                    value="{{ @$event_content->meta_keywords }}"
                                                                    placeholder="Enter Meta Keywords" data-role="tagsinput">
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-lg-12">
                                                            <div
                                                                class="form-group {{ $language->direction == 1 ? 'rtl text-right' : '' }}">
                                                                <label>{{ __('Event Meta Description') }}</label>
                                                                <textarea class="form-control"
                                                                    name="{{ $language->code }}_meta_description" rows="5"
                                                                    placeholder="Enter Meta Description">{{ @$event_content->meta_description }}</textarea>
                                                            </div>
                                                        </div>
                                                    </div>



                                                    <div class="row">
                                                        <div class="col">
                                                            @php $currLang = $language; @endphp

                                                            @foreach ($languages as $language)
                                                                @continue($language->id == $currLang->id)

                                                                <div class="form-check py-0">
                                                                    <label class="form-check-label">
                                                                        <input class="form-check-input" type="checkbox"
                                                                            onchange="cloneInput('collapse{{ $currLang->id }}', 'collapse{{ $language->id }}', event)">
                                                                        <span class="form-check-sign">{{ __('Clone for') }}
                                                                            <strong
                                                                                class="text-capitalize text-secondary">{{ $language->name }}</strong>
                                                                            {{ __('language') }}</span>
                                                                    </label>
                                                                </div>
                                                            @endforeach
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>

                                <div id="sliders"></div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card-footer">
                    <div class="row">
                        <div class="col-12 text-center">
                            <button type="submit" id="EventSubmit" class="btn btn-primary">
                                {{ __('Update') }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    @if ($settings->google_map_status == 1)
        @includeIf('backend.event.map-modal')
    @endif
@endsection

@section('script')
    @if ($settings->google_map_status == 1)
        <script
            src="https://maps.googleapis.com/maps/api/js?key={{ $settings->google_map_api_key }}&libraries=places&callback=initMap"
            async defer></script>
        <script src="{{ asset('assets/admin/js/edit-map-init.js') }}"></script>
    @endif
    <script type="text/javascript" src="{{ asset('assets/admin/js/admin-partial.js') }}"></script>
    <script src="{{ asset('assets/admin/js/admin_dropzone.js') }}"></script>
    <script>
        $(document).ready(function () {
            $('.js-example-basic-single').select2();
        });
    </script>
    <script src="{{ asset('assets/admin/js/event_specification.js') }}"></script>
@endsection

@section('variables')
    @php
        $haveCoSt = $settings->event_country_status == 1 && $settings->event_state_status == 1 ? 1 : 0;
        $languages = App\Models\Language::get();
    @endphp
    <script>
        "use strict";
        let languages = "{{ $languages }}";
        var storeUrl = "{{ route('admin.event.imagesstore') }}";
        var removeUrl = "{{ route('admin.event.imagermv') }}";

        var rmvdbUrl = "{{ route('admin.event.imgdbrmv') }}";
        var loadImgs = "{{ route('admin.event.images', $event->id) }}";
        var defaultLang = "{{ $defaultLang->code }}";

        const haveCoSt = {{ $haveCoSt }};
        const isActiveState = {{ $settings->event_state_status == 1 ? 1 : 0 }};
        const getStateUrl = "{{ route('get.city.state') }}";
        const getCityUrl = "{{ route('get.cities.state') }}";
    </script>
    @if ($settings->google_map_status == 1)
        <script>
            var address = "{{ @$event_address->address }}";
        </script>
    @endif
@endsection