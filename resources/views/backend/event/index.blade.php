@extends('backend.layout')

@section('content')
  @php
    $activeLanguage = request()->input('language', $defaultLang->code);
    $activeType = request()->input('event_type');
    $activeLifecycle = request()->input('lifecycle', 'all');
    $titleFilter = request()->input('title');
    $statusFilter = $statusFilter ?? request()->input('status_filter', 'all');
    $statusFilter = in_array($statusFilter, ['all', 'active', 'inactive'], true) ? $statusFilter : 'all';
    $submissionFilter = $submissionFilter ?? request()->input('submission_filter', 'all');
    $submissionFilter = in_array($submissionFilter, ['all', 'app_submitted', 'admin_authored'], true) ? $submissionFilter : 'all';
    $sortBy = $sortBy ?? request()->input('sort_by', 'timeline');
    $sortBy = in_array($sortBy, ['timeline', 'newest', 'oldest', 'title_asc', 'title_desc'], true) ? $sortBy : 'timeline';
    $featuredOnly = isset($featuredOnly) ? (bool) $featuredOnly : request()->boolean('featured_only');
    $viewMode = $viewMode ?? request()->input('view_mode', 'list');
    $viewMode = in_array($viewMode, ['list', 'grid'], true) ? $viewMode : 'list';
    $gridColumns = isset($gridColumns) ? (int) $gridColumns : (int) request()->input('grid_columns', 3);
    $gridColumns = in_array($gridColumns, [2, 3, 4], true) ? $gridColumns : 3;
    $gridDensity = $gridDensity ?? request()->input('grid_density', 'comfortable');
    $gridDensity = in_array($gridDensity, ['comfortable', 'compact'], true) ? $gridDensity : 'comfortable';

    $pageEvents = $events->getCollection();
    $visibleCount = $pageEvents->count();
    $currentPageCount = $pageEvents->where('is_expired', 0)->count();
    $expiredPageCount = $pageEvents->where('is_expired', 1)->count();
    $featuredCount = $pageEvents->where('is_featured', 'yes')->count();
    $activeStatusCount = $pageEvents->where('status', 1)->count();
    $inactiveStatusCount = $pageEvents->where('status', 0)->count();
    $pendingReviewCount = $pageEvents->filter(function ($event) {
      return (int) $event->status === 0 && (!empty($event->owner_identity_id) || !empty($event->venue_identity_id));
    })->count();
    $submissionCounts = $submissionCounts ?? [
      'all' => $events->total(),
      'app_submitted' => $pageEvents->filter(function ($event) {
        return !empty($event->owner_identity_id) || !empty($event->venue_identity_id);
      })->count(),
      'admin_authored' => $pageEvents->filter(function ($event) {
        return empty($event->owner_identity_id) && empty($event->venue_identity_id);
      })->count(),
    ];
    $venueCount = $pageEvents->where('event_type', 'venue')->count();
    $onlineCount = $pageEvents->where('event_type', 'online')->count();

    $sortLabels = [
      'timeline' => __('Timeline priority'),
      'newest' => __('Newest first'),
      'oldest' => __('Oldest first'),
      'title_asc' => __('Title A-Z'),
      'title_desc' => __('Title Z-A'),
    ];
    $currentSortLabel = $sortLabels[$sortBy] ?? $sortLabels['timeline'];
    $advancedSettingsCount = 0;
    if ($activeLanguage !== $defaultLang->code) {
      $advancedSettingsCount++;
    }
    if ($statusFilter !== 'all') {
      $advancedSettingsCount++;
    }
    if ($submissionFilter !== 'all') {
      $advancedSettingsCount++;
    }
    if ($featuredOnly) {
      $advancedSettingsCount++;
    }
    if ($viewMode === 'grid' && ($gridColumns !== 3 || $gridDensity !== 'comfortable')) {
      $advancedSettingsCount++;
    }

    $summaryTokens = collect([
      ['label' => __('Sort'), 'value' => $currentSortLabel],
    ]);
    if ($activeType) {
      $summaryTokens->push(['label' => __('Type'), 'value' => ucfirst($activeType)]);
    }
    if ($activeLifecycle !== 'all') {
      $summaryTokens->push(['label' => __('Timeline'), 'value' => ucfirst($activeLifecycle)]);
    }
    if ($statusFilter !== 'all') {
      $summaryTokens->push(['label' => __('Status'), 'value' => ucfirst($statusFilter)]);
    }
    if ($submissionFilter !== 'all') {
      $summaryTokens->push([
        'label' => __('Source'),
        'value' => $submissionFilter === 'app_submitted' ? __('App submitted') : __('Admin authored'),
      ]);
    }
    if ($featuredOnly) {
      $summaryTokens->push(['label' => __('Focus'), 'value' => __('Featured only')]);
    }
    if ($pendingReviewCount > 0) {
      $summaryTokens->push(['label' => __('Review'), 'value' => $pendingReviewCount . ' ' . __('pending')]);
    }
    if ($activeLanguage !== $defaultLang->code) {
      $summaryTokens->push(['label' => __('Language'), 'value' => $language->name]);
    }
    if ($viewMode === 'grid') {
      $summaryTokens->push(['label' => __('View'), 'value' => __('Grid') . ' · ' . $gridColumns . ' ' . __('cols')]);
      if ($gridDensity !== 'comfortable') {
        $summaryTokens->push(['label' => __('Density'), 'value' => ucfirst($gridDensity)]);
      }
    }

    $surfaceParams = [
      'view_mode' => $viewMode,
      'grid_columns' => $gridColumns,
      'grid_density' => $gridDensity,
      'sort_by' => $sortBy,
    ];

    $baseRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);
    $filterRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);
    $lifecycleRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);

    if (filled($titleFilter)) {
      $baseRouteParams['title'] = $titleFilter;
      $filterRouteParams['title'] = $titleFilter;
      $lifecycleRouteParams['title'] = $titleFilter;
    }

    if (filled($activeType)) {
      $baseRouteParams['event_type'] = $activeType;
      $filterRouteParams['event_type'] = $activeType;
      $lifecycleRouteParams['event_type'] = $activeType;
    }

    if ($activeLifecycle !== 'all') {
      $baseRouteParams['lifecycle'] = $activeLifecycle;
      $filterRouteParams['lifecycle'] = $activeLifecycle;
    }

    if ($statusFilter !== 'all') {
      $baseRouteParams['status_filter'] = $statusFilter;
      $filterRouteParams['status_filter'] = $statusFilter;
      $lifecycleRouteParams['status_filter'] = $statusFilter;
    }
    if ($submissionFilter !== 'all') {
      $baseRouteParams['submission_filter'] = $submissionFilter;
      $filterRouteParams['submission_filter'] = $submissionFilter;
      $lifecycleRouteParams['submission_filter'] = $submissionFilter;
    }

    if ($featuredOnly) {
      $baseRouteParams['featured_only'] = 1;
      $filterRouteParams['featured_only'] = 1;
      $lifecycleRouteParams['featured_only'] = 1;
    }

    $statusRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);
    $featuredRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);
    if (filled($titleFilter)) {
      $statusRouteParams['title'] = $titleFilter;
      $featuredRouteParams['title'] = $titleFilter;
    }
    if (filled($activeType)) {
      $statusRouteParams['event_type'] = $activeType;
      $featuredRouteParams['event_type'] = $activeType;
    }
    if ($activeLifecycle !== 'all') {
      $statusRouteParams['lifecycle'] = $activeLifecycle;
      $featuredRouteParams['lifecycle'] = $activeLifecycle;
    }
    if ($featuredOnly) {
      $statusRouteParams['featured_only'] = 1;
    }
    if ($statusFilter !== 'all') {
      $featuredRouteParams['status_filter'] = $statusFilter;
    }
    if ($submissionFilter !== 'all') {
      $statusRouteParams['submission_filter'] = $submissionFilter;
      $featuredRouteParams['submission_filter'] = $submissionFilter;
    }

    $submissionRouteParams = array_merge(['language' => $activeLanguage], $surfaceParams);
    if (filled($titleFilter)) {
      $submissionRouteParams['title'] = $titleFilter;
    }
    if (filled($activeType)) {
      $submissionRouteParams['event_type'] = $activeType;
    }
    if ($activeLifecycle !== 'all') {
      $submissionRouteParams['lifecycle'] = $activeLifecycle;
    }
    if ($statusFilter !== 'all') {
      $submissionRouteParams['status_filter'] = $statusFilter;
    }
    if ($featuredOnly) {
      $submissionRouteParams['featured_only'] = 1;
    }

    $allEventsUrl = route('admin.event_management.event', $baseRouteParams);
    $venueEventsUrl = route('admin.event_management.event', array_merge($baseRouteParams, ['event_type' => 'venue']));
    $onlineEventsUrl = route('admin.event_management.event', array_merge($baseRouteParams, ['event_type' => 'online']));
    $allLifecycleUrl = route('admin.event_management.event', $lifecycleRouteParams);
    $currentLifecycleUrl = route('admin.event_management.event', array_merge($lifecycleRouteParams, ['lifecycle' => 'current']));
    $expiredLifecycleUrl = route('admin.event_management.event', array_merge($lifecycleRouteParams, ['lifecycle' => 'expired']));
    $allStatusUrl = route('admin.event_management.event', $statusRouteParams);
    $activeStatusUrl = route('admin.event_management.event', array_merge($statusRouteParams, ['status_filter' => 'active']));
    $inactiveStatusUrl = route('admin.event_management.event', array_merge($statusRouteParams, ['status_filter' => 'inactive']));
    $allFeaturedUrl = route('admin.event_management.event', $featuredRouteParams);
    $featuredOnlyUrl = route('admin.event_management.event', array_merge($featuredRouteParams, ['featured_only' => 1]));
    $allSubmissionUrl = route('admin.event_management.event', $submissionRouteParams);
    $appSubmittedUrl = route('admin.event_management.event', array_merge($submissionRouteParams, ['submission_filter' => 'app_submitted']));
    $adminAuthoredUrl = route('admin.event_management.event', array_merge($submissionRouteParams, ['submission_filter' => 'admin_authored']));
    $clearFiltersUrl = route('admin.event_management.event', array_merge(['language' => $activeLanguage], $surfaceParams));
    $listViewUrl = route('admin.event_management.event', array_merge($filterRouteParams, ['view_mode' => 'list']));
    $gridViewUrl = route('admin.event_management.event', array_merge($filterRouteParams, ['view_mode' => 'grid']));

    $boardLabel = !request()->filled('event_type')
      ? __('All Events')
      : (request()->input('event_type') === 'venue' ? __('Venue Events') : __('Online Events'));

    $boardSubtitle = __('Search, edit, clone and publish events from one cleaner operating surface.');
    if ($activeType === 'venue') {
      $boardSubtitle = __('Venue events with onsite ticketing, seating logic and floor operations.');
    } elseif ($activeType === 'online') {
      $boardSubtitle = __('Online events with remote access flow, digital delivery and checkout control.');
    }

    $scopeBadges = collect();
    if ($activeType) {
      $scopeBadges->push([
        'label' => __('Scope'),
        'value' => ucfirst($activeType),
      ]);
    }
    if ($activeLifecycle !== 'all') {
      $scopeBadges->push([
        'label' => __('Timeline'),
        'value' => ucfirst($activeLifecycle),
      ]);
    }
    if (filled($titleFilter)) {
      $scopeBadges->push([
        'label' => __('Search'),
        'value' => $titleFilter,
      ]);
    }

    $currentEvents = $pageEvents->where('is_expired', 0)->values();
    $expiredEvents = $pageEvents->where('is_expired', 1)->values();
    $eventGroups = collect();
    if ($currentEvents->isNotEmpty()) {
      $eventGroups->push([
        'key' => 'current',
        'label' => __('Current events'),
        'hint' => __('Events whose end time has not passed yet.'),
        'items' => $currentEvents,
      ]);
    }
    if ($expiredEvents->isNotEmpty()) {
      $eventGroups->push([
        'key' => 'expired',
        'label' => __('Expired events'),
        'hint' => __('Events that already passed their final end date and time.'),
        'items' => $expiredEvents,
      ]);
    }
  @endphp

  <div class="page-header">
    <h4 class="page-title">{{ __('Events') }}</h4>
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
      @if (!request()->filled('event_type'))
        <li class="separator">
          <i class="flaticon-right-arrow"></i>
        </li>
        <li class="nav-item">
          <a
            href="{{ route('admin.event_management.event', ['language' => $defaultLang->code]) }}">{{ __('All Events') }}</a>
        </li>
      @endif
      @if (request()->filled('event_type') && request()->input('event_type') == 'venue')
        <li class="separator">
          <i class="flaticon-right-arrow"></i>
        </li>
        <li class="nav-item">
          <a href="#">{{ __('Venue Events') }}</a>
        </li>
      @endif
      @if (request()->filled('event_type') && request()->input('event_type') == 'online')
        <li class="separator">
          <i class="flaticon-right-arrow"></i>
        </li>
        <li class="nav-item">
          <a href="#">{{ __('Online Events') }}</a>
        </li>
      @endif
    </ul>
  </div>

  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <div class="row">
            <div class="col-lg-4">
              <div class="card-title d-inline-block">
                {{ __('Events') . ' (' . $language->name . ' ' . __('Language') . ')' }}
              </div>
            </div>

            <div class="col-lg-3">
              @if (!empty($langs))
                <select name="language" class="form-control"
                  onchange="window.location='{{ url()->current() . '?language=' }}' + this.value+'&event_type='+'{{ request()->input('event_type') }}'">
                  <option selected disabled>{{ __('Select a Language') }}</option>
                  @foreach ($langs as $lang)
                    <option value="{{ $lang->code }}"
                      {{ $lang->code == request()->input('language') ? 'selected' : '' }}>
                      {{ $lang->name }}
                    </option>
                  @endforeach
                </select>
              @endif
            </div>

      <div class="event-index-workbench">
        <form action="{{ route('admin.event_management.event') }}" method="get" class="event-index-primary-form">
          <input type="hidden" name="language" value="{{ $activeLanguage }}">
          <input type="hidden" name="event_type" value="{{ $activeType }}">
          <input type="hidden" name="lifecycle" value="{{ $activeLifecycle === 'all' ? '' : $activeLifecycle }}">
          <input type="hidden" name="status_filter" value="{{ $statusFilter === 'all' ? '' : $statusFilter }}">
          <input type="hidden" name="submission_filter" value="{{ $submissionFilter === 'all' ? '' : $submissionFilter }}">
          <input type="hidden" name="featured_only" value="{{ $featuredOnly ? 1 : '' }}">
          <input type="hidden" name="view_mode" value="{{ $viewMode }}">
          <input type="hidden" name="grid_columns" value="{{ $gridColumns }}">
          <input type="hidden" name="grid_density" value="{{ $gridDensity }}">

              <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle btn-sm float-right" type="button"
                  id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                  {{ __('Add Event') }}
                </button>

                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                  <a href="{{ route('add.event.event', ['type' => 'online']) }}" class="dropdown-item">
                    {{ __('Online Event') }}
                  </a>

          <div class="event-index-primary-form__actions">
            <button type="submit" class="btn btn-primary event-index-search-submit">
              <i class="fas fa-search mr-1"></i>
              {{ __('Apply') }}
            </button>
            <a href="{{ $clearFiltersUrl }}" class="btn btn-light event-index-clear">{{ __('Clear') }}</a>
          </div>

          <div class="event-index-view-switch">
            <a href="{{ $listViewUrl }}" class="event-index-view-switch__button {{ $viewMode === 'list' ? 'is-active' : '' }}">
              <i class="fas fa-list-ul"></i>
              <span>{{ __('List') }}</span>
            </a>
            <a href="{{ $gridViewUrl }}" class="event-index-view-switch__button {{ $viewMode === 'grid' ? 'is-active' : '' }}">
              <i class="fas fa-th-large"></i>
              <span>{{ __('Grid') }}</span>
            </a>
          </div>
        </form>

        <div class="event-index-nav-row">
          <div class="event-index-chip-group">
            <span class="event-index-chip-group__label">{{ __('Type') }}</span>
            <div class="event-index-chip-tabs">
              <a href="{{ $allEventsUrl }}" class="event-index-chip-tab {{ !request()->filled('event_type') ? 'is-active' : '' }}">
                <span>{{ __('All') }}</span>
                <strong>{{ $events->total() }}</strong>
              </a>
              <a href="{{ $venueEventsUrl }}" class="event-index-chip-tab {{ $activeType === 'venue' ? 'is-active' : '' }}">
                <span>{{ __('Venue') }}</span>
                <strong>{{ $venueCount }}</strong>
              </a>
              <a href="{{ $onlineEventsUrl }}" class="event-index-chip-tab {{ $activeType === 'online' ? 'is-active' : '' }}">
                <span>{{ __('Online') }}</span>
                <strong>{{ $onlineCount }}</strong>
              </a>
            </div>
          </div>

          <div class="event-index-chip-group">
            <span class="event-index-chip-group__label">{{ __('Timeline') }}</span>
            <div class="event-index-chip-tabs">
              <a href="{{ $allLifecycleUrl }}" class="event-index-chip-tab {{ $activeLifecycle === 'all' ? 'is-active' : '' }}">
                <span>{{ __('All') }}</span>
                <strong>{{ $lifecycleCounts['all'] ?? $events->total() }}</strong>
              </a>
              <a href="{{ $currentLifecycleUrl }}" class="event-index-chip-tab {{ $activeLifecycle === 'current' ? 'is-active' : '' }}">
                <span>{{ __('Current') }}</span>
                <strong>{{ $lifecycleCounts['current'] ?? $currentPageCount }}</strong>
              </a>
              <a href="{{ $expiredLifecycleUrl }}" class="event-index-chip-tab {{ $activeLifecycle === 'expired' ? 'is-active' : '' }}">
                <span>{{ __('Expired') }}</span>
                <strong>{{ $lifecycleCounts['expired'] ?? $expiredPageCount }}</strong>
              </a>
            </div>
          </div>

          <div class="event-index-chip-group">
            <span class="event-index-chip-group__label">{{ __('Source') }}</span>
            <div class="event-index-chip-tabs">
              <a href="{{ $allSubmissionUrl }}" class="event-index-chip-tab {{ $submissionFilter === 'all' ? 'is-active' : '' }}">
                <span>{{ __('All') }}</span>
                <strong>{{ $submissionCounts['all'] ?? $events->total() }}</strong>
              </a>
              <a href="{{ $appSubmittedUrl }}" class="event-index-chip-tab {{ $submissionFilter === 'app_submitted' ? 'is-active' : '' }}">
                <span>{{ __('App submitted') }}</span>
                <strong>{{ $submissionCounts['app_submitted'] ?? 0 }}</strong>
              </a>
              <a href="{{ $adminAuthoredUrl }}" class="event-index-chip-tab {{ $submissionFilter === 'admin_authored' ? 'is-active' : '' }}">
                <span>{{ __('Admin authored') }}</span>
                <strong>{{ $submissionCounts['admin_authored'] ?? 0 }}</strong>
              </a>
            </div>
          </div>
        </div>

        <details class="event-index-advanced" {{ $statusFilter !== 'all' || $submissionFilter !== 'all' || $featuredOnly || $activeLanguage !== $defaultLang->code || $viewMode === 'grid' ? 'open' : '' }}>
          <summary>
            <span class="event-index-advanced__summary-copy">
              <strong>{{ __('Advanced filters & display') }}</strong>
              <small>{{ __('Language, source, status, featured and grid controls') }}</small>
            </span>
            <span class="event-index-advanced__summary-badge">
              {{ $advancedSettingsCount > 0 ? trans_choice('{1} :count active|[2,*] :count active', $advancedSettingsCount, ['count' => $advancedSettingsCount]) : __('Defaults') }}
            </span>
          </summary>

          <form action="{{ route('admin.event_management.event') }}" method="get" class="event-index-advanced__form">
            <input type="hidden" name="title" value="{{ $titleFilter }}">
            @if (filled($activeType))
              <input type="hidden" name="event_type" value="{{ $activeType }}">
            @endif
            @if ($activeLifecycle !== 'all')
              <input type="hidden" name="lifecycle" value="{{ $activeLifecycle }}">
            @endif
            <input type="hidden" name="view_mode" value="{{ $viewMode }}">
            <input type="hidden" name="sort_by" value="{{ $sortBy }}">

            <label class="event-index-select-field">
              <span class="event-index-select-field__label">{{ __('Language') }}</span>
              <select name="language" class="form-control">
                @foreach ($langs as $lang)
                  <option value="{{ $lang->code }}" {{ $lang->code == $activeLanguage ? 'selected' : '' }}>{{ $lang->name }}</option>
                @endforeach
              </select>
            </label>

            <label class="event-index-select-field">
              <span class="event-index-select-field__label">{{ __('Status') }}</span>
              <select name="status_filter" class="form-control">
                <option value="all" {{ $statusFilter === 'all' ? 'selected' : '' }}>{{ __('All statuses') }}</option>
                <option value="active" {{ $statusFilter === 'active' ? 'selected' : '' }}>{{ __('Active') }}</option>
                <option value="inactive" {{ $statusFilter === 'inactive' ? 'selected' : '' }}>{{ __('Deactive') }}</option>
              </select>
            </label>

            <label class="event-index-select-field">
              <span class="event-index-select-field__label">{{ __('Source') }}</span>
              <select name="submission_filter" class="form-control">
                <option value="all" {{ $submissionFilter === 'all' ? 'selected' : '' }}>{{ __('All sources') }}</option>
                <option value="app_submitted" {{ $submissionFilter === 'app_submitted' ? 'selected' : '' }}>{{ __('App submitted') }}</option>
                <option value="admin_authored" {{ $submissionFilter === 'admin_authored' ? 'selected' : '' }}>{{ __('Admin authored') }}</option>
              </select>
            </label>

            <label class="event-index-toggle-field">
              <input type="checkbox" name="featured_only" value="1" {{ $featuredOnly ? 'checked' : '' }}>
              <span>
                <strong>{{ __('Featured only') }}</strong>
                <small>{{ __('Restrict results to events currently marked as featured') }}</small>
              </span>
            </label>

            <label class="event-index-select-field {{ $viewMode === 'grid' ? '' : 'is-disabled' }}">
              <span class="event-index-select-field__label">{{ __('Grid columns') }}</span>
              <select name="grid_columns" class="form-control" {{ $viewMode === 'grid' ? '' : 'disabled' }}>
                <option value="2" {{ $gridColumns === 2 ? 'selected' : '' }}>2</option>
                <option value="3" {{ $gridColumns === 3 ? 'selected' : '' }}>3</option>
                <option value="4" {{ $gridColumns === 4 ? 'selected' : '' }}>4</option>
              </select>
            </label>

            <label class="event-index-select-field {{ $viewMode === 'grid' ? '' : 'is-disabled' }}">
              <span class="event-index-select-field__label">{{ __('Grid density') }}</span>
              <select name="grid_density" class="form-control" {{ $viewMode === 'grid' ? '' : 'disabled' }}>
                <option value="comfortable" {{ $gridDensity === 'comfortable' ? 'selected' : '' }}>{{ __('Comfortable') }}</option>
                <option value="compact" {{ $gridDensity === 'compact' ? 'selected' : '' }}>{{ __('Compact') }}</option>
              </select>
            </label>

            <div class="event-index-advanced__actions">
              <button type="submit" class="btn btn-primary">{{ __('Apply advanced settings') }}</button>
            </div>
          </form>
        </details>

        <div class="event-index-summary-row">
          <label class="event-index-selection-toggle">
            <input type="checkbox" class="bulk-check" data-val="all">
            <span>{{ __('Select all on this page') }}</span>
          </label>

          <div class="event-index-summary-pills">
            @foreach ($summaryTokens as $token)
              <span>{{ $token['label'] }} <strong>{{ $token['value'] }}</strong></span>
            @endforeach
          </div>
        </div>
      </div>

      @if ($events->count() === 0)
        <div class="event-index-empty">
          <div class="mb-3">
            <i class="fas fa-calendar-times fa-2x"></i>
          </div>
          <h3 class="event-index-empty__title">{{ __('No events found') }}</h3>
          <p class="event-index-empty__text">
            {{ __('There is no event content for the current language and filters. Clear the filters or create a new event to continue building the catalog.') }}
          </p>
        </div>
      @elseif ($viewMode === 'list')
        <div class="table-responsive event-index-table-wrap">
          <table class="table event-index-table">
            <thead>
              <tr>
                <th class="event-index-check"></th>
                <th>{{ __('Event') }}</th>
                <th>{{ __('Owner') }}</th>
                <th>{{ __('Operations') }}</th>
                <th class="text-right">{{ __('Actions') }}</th>
              </tr>
            </thead>
            @foreach ($eventGroups as $group)
              <tbody class="event-index-group event-index-group--{{ $group['key'] }}">
                <tr class="event-index-group__row">
                  <td colspan="5">
                    <div class="event-index-group__header">
                      <div>
                        <h4 class="event-index-group__title">{{ $group['label'] }}</h4>
                        <p class="event-index-group__hint">{{ $group['hint'] }}</p>
                      </div>
                      <span class="event-index-group__count">{{ $group['items']->count() }}</span>
                    </div>
                  </td>
                </tr>
                @foreach ($group['items'] as $event)
                  @php
                    $thumbnail = $event->thumbnail
                      ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail)
                      : asset('assets/admin/img/noimage.jpg');
                    $dateLabel = $event->start_date
                      ? \Carbon\Carbon::parse($event->start_date)->format('M d, Y')
                      : __('Date pending');
                    $timeLabel = $event->start_time ? date('g:i A', strtotime($event->start_time)) : __('Time pending');
                    $organizerName = optional($event->organizer)->username;
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
                    $isPendingReview = (int) $event->status === 0 && (!empty($event->owner_identity_id) || !empty($event->venue_identity_id));
                    $reviewStatus = $event->review_status ?: null;
                    $inactiveLabel = match ($reviewStatus) {
                      'pending' => __('Pending review'),
                      'changes_requested' => __('Changes requested'),
                      'rejected' => __('Rejected'),
                      default => ($isPendingReview ? __('Pending review') : __('Inactive')),
                    };
                    $effectiveEndLabel = $event->effective_end_date_time
                      ? \Carbon\Carbon::parse($event->effective_end_date_time)->format('M d, Y · g:i A')
                      : null;
                    $collaborationPreview = $event->collaboration_summary_preview ?? null;
                    $latestCollaborationActivity = data_get($collaborationPreview, 'latest_activity');
                    $latestActivityTypeLabel = match (data_get($latestCollaborationActivity, 'type')) {
                      'split_configured' => __('Configuration'),
                      'mode_changed' => __('Mode change'),
                      'manual_claim_completed' => __('Manual payout'),
                      'auto_release_completed' => __('Auto release'),
                      default => __('Activity'),
                    };
                    $latestActivityBadgeClass = match (data_get($latestCollaborationActivity, 'type')) {
                      'split_configured' => 'secondary',
                      'mode_changed' => 'warning',
                      'manual_claim_completed' => 'success',
                      'auto_release_completed' => 'primary',
                      default => 'dark',
                    };
                    $latestActivityAmount = (float) data_get($latestCollaborationActivity, 'amount', 0);
                    $formattedLatestActivityAmount = $getCurrencyInfo->base_currency_symbol_position == 'left'
                      ? $getCurrencyInfo->base_currency_symbol . number_format($latestActivityAmount, 2)
                      : number_format($latestActivityAmount, 2) . $getCurrencyInfo->base_currency_symbol;
                  @endphp
                  <tr class="{{ $event->is_expired ? 'is-expired' : 'is-current' }}">
                    <td class="event-index-check">
                      <input type="checkbox" class="bulk-check" data-val="{{ $event->id }}">
                    </td>
                    <td>
                      <div class="event-index-row">
                        <div class="event-index-row__media">
                          <img src="{{ $thumbnail }}" alt="{{ $event->title }}" class="event-index-row__thumb">
                          <div class="event-index-row__overlay">
                            <span class="event-index-lifecycle event-index-lifecycle--{{ $event->is_expired ? 'expired' : 'current' }}">
                              {{ $event->is_expired ? __('Expired') : __('Current') }}
                            </span>
                            <span class="event-index-row__event-id"># {{ $event->id }}</span>
                          </div>
                        </div>
                        <div class="event-index-row__body">
                          <a target="_blank" href="{{ route('event.details', ['slug' => $event->slug, 'id' => $event->id]) }}" class="event-index-row__title">
                            {{ $event->title }}
                          </a>
                          <div class="event-index-row__meta">
                            <span><i class="far fa-calendar-alt"></i> {{ $dateLabel }}</span>
                            <span><i class="far fa-clock"></i> {{ $timeLabel }}</span>
                            @if ($effectiveEndLabel)
                              <span><i class="fas fa-flag-checkered"></i> {{ $event->is_expired ? __('Ended') : __('Ends') }} {{ $effectiveEndLabel }}</span>
                            @endif
                          </div>
                          <div class="event-index-badges">
                            <span class="event-index-pill event-index-pill--type">{{ ucfirst($event->event_type) }}</span>
                            <span class="event-index-pill event-index-pill--category">{{ $event->category ?: __('Uncategorized') }}</span>
                            @if ($isPendingReview)
                              <span class="event-index-pill event-index-pill--status">{{ __('Pending review') }}</span>
                            @endif
                          </div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div class="event-index-organizer">
                        @if ($organizerName)
                          <a target="_blank" href="{{ route('admin.organizer_management.organizer_details', ['id' => $event->organizer_id, 'language' => $defaultLang->code]) }}" class="event-index-organizer__name">
                            {{ $organizerName }}
                          </a>
                        @else
                          <span class="event-index-organizer__name">{{ __('Admin') }}</span>
                          <span class="event-index-organizer__badge">{{ __('Internal') }}</span>
                        @endif
                        <span class="event-index-organizer__badge mt-2">{{ $managementLabel }}</span>
                        @if (!empty($hostingVenueName))
                          <span class="event-index-ticket-muted mt-2">{{ __('Host venue') }}: {{ $hostingVenueName }}</span>
                        @endif
                      </div>
                    </td>
                    <td>
                      <div class="event-index-state-stack">
                        @if ($event->event_type === 'venue')
                          <a href="{{ route('admin.event.ticket', ['language' => $activeLanguage, 'event_id' => $event->id, 'event_type' => $event->event_type]) }}" class="event-index-ticket-button">
                            <i class="far fa-ticket-alt"></i>
                            {{ __('Manage tickets') }}
                          </a>
                        @else
                          <span class="event-index-ticket-muted">{{ __('Online ticket rules') }}</span>
                        @endif

                        <form id="statusForm-{{ $event->id }}" action="{{ route('admin.event_management.event.event_status', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post">
                          @csrf
                          <select class="form-control form-control-sm {{ $event->status == 0 ? 'bg-warning text-dark' : 'bg-primary' }}" name="status" onchange="document.getElementById('statusForm-{{ $event->id }}').submit()">
                            <option value="1" {{ $event->status == 1 ? 'selected' : '' }}>{{ __('Active') }}</option>
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ $inactiveLabel }}</option>
                          </select>
                        </form>
                        @if ($isPendingReview)
                          <span class="event-index-ticket-muted">{{ __('Submitted from app and waiting for admin approval.') }}</span>
                        @elseif ($reviewStatus === 'changes_requested' && !empty($event->review_notes))
                          <span class="event-index-ticket-muted">{{ __('Notes') }}: {{ $event->review_notes }}</span>
                        @elseif ($reviewStatus === 'rejected' && !empty($event->review_notes))
                          <span class="event-index-ticket-muted">{{ __('Reason') }}: {{ $event->review_notes }}</span>
                        @endif

                        @if (!empty($collaborationPreview) && (data_get($collaborationPreview, 'has_activity') || data_get($collaborationPreview, 'claimable_count', 0) > 0))
                          <div class="border rounded p-2 mt-2 bg-light">
                            <div class="d-flex justify-content-between align-items-center flex-wrap" style="gap: 8px;">
                              <strong>{{ __('Collaboration activity') }}</strong>
                              <a href="{{ route('admin.event_management.edit_event', ['id' => $event->id]) }}" class="small">
                                {{ __('Review') }}
                              </a>
                            </div>
                            <div class="small text-muted mt-1">
                              <span class="badge {{ (int) data_get($collaborationPreview, 'claimable_count', 0) > 0 ? 'badge-success' : 'badge-light' }}">
                                {{ __('Claimable now') }}: {{ (int) data_get($collaborationPreview, 'claimable_count', 0) }}
                              </span>
                              · {{ __('Reserved') }}:
                              <strong>
                                {{ $getCurrencyInfo->base_currency_symbol_position == 'left'
                                  ? $getCurrencyInfo->base_currency_symbol . number_format((float) data_get($collaborationPreview, 'reserved_for_collaborators', 0), 2)
                                  : number_format((float) data_get($collaborationPreview, 'reserved_for_collaborators', 0), 2) . $getCurrencyInfo->base_currency_symbol }}
                              </strong>
                            </div>
                            @if (!empty($latestCollaborationActivity))
                              <div class="small mt-2">
                                <span class="badge badge-{{ $latestActivityBadgeClass }}">{{ $latestActivityTypeLabel }}</span>
                                <span class="text-muted ml-1">{{ data_get($latestCollaborationActivity, 'title') }}</span>
                                @if ($latestActivityAmount > 0)
                                  <span class="badge badge-success ml-1">{{ $formattedLatestActivityAmount }}</span>
                                @endif
                              </div>
                            @endif
                          </div>
                        @endif

                        @unless ($event->is_expired)
                          <form id="featuredForm-{{ $event->id }}" action="{{ route('admin.event_management.event.update_featured', ['id' => $event->id]) }}" method="post">
                            @csrf
                            <select class="form-control form-control-sm {{ $event->is_featured == 'yes' ? 'bg-success' : 'bg-danger' }}" name="is_featured" onchange="document.getElementById('featuredForm-{{ $event->id }}').submit()">
                              <option value="yes" {{ $event->is_featured == 'yes' ? 'selected' : '' }}>{{ __('Featured') }}</option>
                              <option value="no" {{ $event->is_featured == 'no' ? 'selected' : '' }}>{{ __('Not featured') }}</option>
                            </select>
                          </form>
                        @endunless
                      </div>
                    </td>
                    <td>
                      <div class="event-index-actions">
                        <a href="{{ route('admin.event_management.edit_event', ['id' => $event->id]) }}" class="event-index-primary-action">
                          <i class="fas fa-pen"></i>
                          {{ __('Edit') }}
                        </a>

                        <div class="dropdown event-index-manage">
                          <button class="btn dropdown-toggle event-index-more" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            {{ __('More') }}
                          </button>
                          <div class="dropdown-menu dropdown-menu-right">
                            <a href="{{ route('event.details', ['slug' => $event->slug, 'id' => $event->id]) }}" target="_blank" class="dropdown-item">
                              {{ __('Preview') }}
                            </a>
                            <a href="{{ route('admin.event_management.qr', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Event QR') }}
                            </a>
                            <form action="{{ route('admin.event_management.clone_event', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post" class="d-block">
                              @csrf
                              <button type="submit" class="dropdown-item">
                                {{ __('Clone Event') }}
                              </button>
                            </form>
                            <a href="{{ route('admin.event_management.ticket_setting', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Ticket Settings') }}
                            </a>
                            <form class="deleteForm d-block" action="{{ route('admin.event_management.delete_event', ['id' => $event->id]) }}" method="post">
                              @csrf
                              <button type="submit" class="dropdown-item deleteBtn">
                                {{ __('Delete') }}
                              </button>
                            </form>
                          </div>
                        </div>
                      </div>
                    </td>
                  </tr>
                @endforeach
              </tbody>
            @endforeach
          </table>
        </div>
      @else
        <div class="event-index-grid-wrap event-index-grid-wrap--{{ $gridDensity }}" style="--event-index-grid-columns: {{ $gridColumns }};">
          @foreach ($eventGroups as $group)
            <section class="event-index-card-group event-index-card-group--{{ $group['key'] }}">
              <div class="event-index-group__header">
                <div>
                  <h4 class="event-index-group__title">{{ $group['label'] }}</h4>
                  <p class="event-index-group__hint">{{ $group['hint'] }}</p>
                </div>
              </div>

              <div class="event-index-grid">
                @foreach ($group['items'] as $event)
                  @php
                    $thumbnail = $event->thumbnail
                      ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail)
                      : asset('assets/admin/img/noimage.jpg');
                    $dateLabel = $event->start_date
                      ? \Carbon\Carbon::parse($event->start_date)->format('M d, Y')
                      : __('Date pending');
                    $timeLabel = $event->start_time ? date('g:i A', strtotime($event->start_time)) : __('Time pending');
                    $organizerName = optional($event->organizer)->username;
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
                    $isPendingReview = (int) $event->status === 0 && (!empty($event->owner_identity_id) || !empty($event->venue_identity_id));
                    $reviewStatus = $event->review_status ?: null;
                    $inactiveLabel = match ($reviewStatus) {
                      'pending' => __('Pending review'),
                      'changes_requested' => __('Changes requested'),
                      'rejected' => __('Rejected'),
                      default => ($isPendingReview ? __('Pending review') : __('Inactive')),
                    };
                    $effectiveEndLabel = $event->effective_end_date_time
                      ? \Carbon\Carbon::parse($event->effective_end_date_time)->format('M d, Y · g:i A')
                      : null;
                    $collaborationPreview = $event->collaboration_summary_preview ?? null;
                    $latestCollaborationActivity = data_get($collaborationPreview, 'latest_activity');
                    $latestActivityTypeLabel = match (data_get($latestCollaborationActivity, 'type')) {
                      'split_configured' => __('Configuration'),
                      'mode_changed' => __('Mode change'),
                      'manual_claim_completed' => __('Manual payout'),
                      'auto_release_completed' => __('Auto release'),
                      default => __('Activity'),
                    };
                    $latestActivityBadgeClass = match (data_get($latestCollaborationActivity, 'type')) {
                      'split_configured' => 'secondary',
                      'mode_changed' => 'warning',
                      'manual_claim_completed' => 'success',
                      'auto_release_completed' => 'primary',
                      default => 'dark',
                    };
                    $latestActivityAmount = (float) data_get($latestCollaborationActivity, 'amount', 0);
                    $formattedLatestActivityAmount = $getCurrencyInfo->base_currency_symbol_position == 'left'
                      ? $getCurrencyInfo->base_currency_symbol . number_format($latestActivityAmount, 2)
                      : number_format($latestActivityAmount, 2) . $getCurrencyInfo->base_currency_symbol;
                  @endphp
                  <article class="event-index-card {{ $event->is_expired ? 'is-expired' : 'is-current' }}">
                    <label class="event-index-card__check">
                      <input type="checkbox" class="bulk-check" data-val="{{ $event->id }}">
                    </label>

                    <a target="_blank" href="{{ route('event.details', ['slug' => $event->slug, 'id' => $event->id]) }}" class="event-index-card__hero" style="background-image: url('{{ $thumbnail }}');">
                      <div class="event-index-card__hero-top">
                        <span class="event-index-lifecycle event-index-lifecycle--{{ $event->is_expired ? 'expired' : 'current' }}">
                          {{ $event->is_expired ? __('Expired') : __('Current') }}
                        </span>
                        <span class="event-index-card__event-id"># {{ $event->id }}</span>
                      </div>
                      <div class="event-index-card__hero-overlay">
                        <div class="event-index-card__hero-copy">
                          <span class="event-index-card__eyebrow">{{ ucfirst($event->event_type) }} · {{ $event->category ?: __('Uncategorized') }}</span>
                          <span class="event-index-card__hero-title">{{ $event->title }}</span>
                          <span class="event-index-card__hero-owner">{{ $organizerName ?: __('Admin workspace') }}</span>
                        </div>
                      </div>
                    </a>

                    <div class="event-index-card__body">
                      <div class="event-index-card__meta">
                        <span><i class="far fa-calendar-alt"></i> {{ $dateLabel }}</span>
                        <span><i class="far fa-clock"></i> {{ $timeLabel }}</span>
                        @if ($effectiveEndLabel)
                          <span><i class="fas fa-flag-checkered"></i> {{ $event->is_expired ? __('Ended') : __('Ends') }} {{ $effectiveEndLabel }}</span>
                        @endif
                      </div>

                      <div class="event-index-badges">
                        <span class="event-index-pill event-index-pill--type">{{ ucfirst($event->event_type) }}</span>
                        <span class="event-index-pill event-index-pill--category">{{ $event->category ?: __('Uncategorized') }}</span>
                        @if ($isPendingReview)
                          <span class="event-index-pill event-index-pill--status">{{ __('Pending review') }}</span>
                        @elseif ($reviewStatus === 'changes_requested')
                          <span class="event-index-pill event-index-pill--status">{{ __('Changes requested') }}</span>
                        @elseif ($reviewStatus === 'rejected')
                          <span class="event-index-pill event-index-pill--status">{{ __('Rejected') }}</span>
                        @endif
                      </div>

                      <div class="event-index-state-stack mt-2">
                        <span class="event-index-ticket-muted">{{ $managementLabel }}</span>
                        @if (!empty($hostingVenueName))
                          <span class="event-index-ticket-muted">{{ __('Host venue') }}: {{ $hostingVenueName }}</span>
                        @endif
                        @if (!empty($collaborationPreview) && (data_get($collaborationPreview, 'has_activity') || data_get($collaborationPreview, 'claimable_count', 0) > 0))
                          <div class="border rounded p-2 mt-2 bg-light">
                            <div class="d-flex justify-content-between align-items-center flex-wrap" style="gap: 8px;">
                              <strong class="small">{{ __('Collaboration activity') }}</strong>
                              <span class="badge {{ (int) data_get($collaborationPreview, 'claimable_count', 0) > 0 ? 'badge-success' : 'badge-light' }}">
                                {{ __('Claimable') }}: {{ (int) data_get($collaborationPreview, 'claimable_count', 0) }}
                              </span>
                            </div>
                            @if (!empty($latestCollaborationActivity))
                              <div class="small text-muted mt-1">{{ data_get($latestCollaborationActivity, 'title') }}</div>
                              <div class="d-flex justify-content-between align-items-center mt-1 flex-wrap" style="gap: 8px;">
                                <span class="badge badge-{{ $latestActivityBadgeClass }}">{{ $latestActivityTypeLabel }}</span>
                                @if ($latestActivityAmount > 0)
                                  <span class="badge badge-success">{{ $formattedLatestActivityAmount }}</span>
                                @endif
                              </div>
                            @endif
                          </div>
                        @endif
                      </div>

                      <div class="event-index-card__ops">
                        @if ($event->event_type === 'venue')
                          <a href="{{ route('admin.event.ticket', ['language' => $activeLanguage, 'event_id' => $event->id, 'event_type' => $event->event_type]) }}" class="event-index-ticket-button">
                            <i class="far fa-ticket-alt"></i>
                            {{ __('Manage tickets') }}
                          </a>
                        @else
                          <span class="event-index-ticket-muted">{{ __('Online ticket rules') }}</span>
                        @endif

                        <form id="grid-statusForm-{{ $event->id }}" action="{{ route('admin.event_management.event.event_status', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post">
                          @csrf
                          <select class="form-control form-control-sm {{ $event->status == 0 ? 'bg-warning text-dark' : 'bg-primary' }}" name="status" onchange="document.getElementById('grid-statusForm-{{ $event->id }}').submit()">
                            <option value="1" {{ $event->status == 1 ? 'selected' : '' }}>{{ __('Active') }}</option>
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ $inactiveLabel }}</option>
                          </select>
                        </form>
                        @if ($isPendingReview)
                          <span class="event-index-ticket-muted">{{ __('Submitted from app and waiting for admin approval.') }}</span>
                        @elseif ($reviewStatus === 'changes_requested' && !empty($event->review_notes))
                          <span class="event-index-ticket-muted">{{ __('Notes') }}: {{ $event->review_notes }}</span>
                        @elseif ($reviewStatus === 'rejected' && !empty($event->review_notes))
                          <span class="event-index-ticket-muted">{{ __('Reason') }}: {{ $event->review_notes }}</span>
                        @endif

                        @unless ($event->is_expired)
                          <form id="grid-featuredForm-{{ $event->id }}" action="{{ route('admin.event_management.event.update_featured', ['id' => $event->id]) }}" method="post">
                            @csrf
                            <select class="form-control form-control-sm {{ $event->is_featured == 'yes' ? 'bg-success' : 'bg-danger' }}" name="is_featured" onchange="document.getElementById('grid-featuredForm-{{ $event->id }}').submit()">
                              <option value="yes" {{ $event->is_featured == 'yes' ? 'selected' : '' }}>{{ __('Featured') }}</option>
                              <option value="no" {{ $event->is_featured == 'no' ? 'selected' : '' }}>{{ __('Not featured') }}</option>
                            </select>
                          </form>
                        @endunless
                      </div>

                      <div class="event-index-card__footer">
                        <a href="{{ route('admin.event_management.edit_event', ['id' => $event->id]) }}" class="event-index-primary-action event-index-primary-action--block">
                          <i class="fas fa-pen"></i>
                          {{ __('Edit') }}
                        </a>

                        <div class="dropdown event-index-manage event-index-card__manage">
                          <button class="btn dropdown-toggle event-index-more" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            {{ __('More') }}
                          </button>
                          <div class="dropdown-menu dropdown-menu-right">
                            <a href="{{ route('event.details', ['slug' => $event->slug, 'id' => $event->id]) }}" target="_blank" class="dropdown-item">
                              {{ __('Preview') }}
                            </a>
                            <a href="{{ route('admin.event_management.qr', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Event QR') }}
                            </a>
                            <form action="{{ route('admin.event_management.clone_event', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post" class="d-block">
                              @csrf
                              <button type="submit" class="dropdown-item">
                                {{ __('Clone Event') }}
                              </button>
                            </form>
                            <a href="{{ route('admin.event_management.ticket_setting', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Ticket Settings') }}
                            </a>
                            <form class="deleteForm d-block" action="{{ route('admin.event_management.delete_event', ['id' => $event->id]) }}" method="post">
                              @csrf
                              <button type="submit" class="dropdown-item deleteBtn">
                                {{ __('Delete') }}
                              </button>
                            </form>
                          </div>
                        </div>
                      </div>
                    </div>
                  </article>
                @endforeach
              </div>
            </section>
          @endforeach
        </div>

      <div class="event-index-pagination">
        <div class="d-inline-block mt-3">
          {{ $events->appends([
                  'language' => request()->input('language'),
                  'title' => request()->input('title'),
                  'event_type' => request()->input('event_type'),
                  'lifecycle' => request()->input('lifecycle'),
                  'status_filter' => $statusFilter,
                  'submission_filter' => $submissionFilter,
                  'featured_only' => $featuredOnly ? 1 : null,
                  'sort_by' => $sortBy,
                  'view_mode' => $viewMode,
                  'grid_columns' => $gridColumns,
                  'grid_density' => $gridDensity,
              ])->links() }}
        </div>
      </div>
    </div>
  </div>
@endsection
