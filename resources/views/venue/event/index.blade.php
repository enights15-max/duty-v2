@extends('venue.layout')

@section('style')
  @include('backend.event.partials.index-workspace-style')
@endsection

@section('content')
  @php
    $activeLanguage = request()->input('language', $defaultLang->code);
    $activeType = request()->input('event_type');
    $activeLifecycle = request()->input('lifecycle', 'all');
    $titleFilter = request()->input('title');
    $statusFilter = $statusFilter ?? request()->input('status_filter', 'all');
    $statusFilter = in_array($statusFilter, ['all', 'active', 'inactive'], true) ? $statusFilter : 'all';
    $sortBy = $sortBy ?? request()->input('sort_by', 'timeline');
    $sortBy = in_array($sortBy, ['timeline', 'newest', 'oldest', 'title_asc', 'title_desc'], true) ? $sortBy : 'timeline';
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
    $venueCount = $pageEvents->where('event_type', 'venue')->count();
    $onlineCount = $pageEvents->where('event_type', 'online')->count();
    $workspaceOwner = optional(Auth::guard('venue')->user())->username ?? optional(Auth::guard('venue')->user())->name ?? __('Venue workspace');

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

    $allEventsUrl = route('venue.event_management.event', $baseRouteParams);
    $venueEventsUrl = route('venue.event_management.event', array_merge($baseRouteParams, ['event_type' => 'venue']));
    $onlineEventsUrl = route('venue.event_management.event', array_merge($baseRouteParams, ['event_type' => 'online']));
    $allLifecycleUrl = route('venue.event_management.event', $lifecycleRouteParams);
    $currentLifecycleUrl = route('venue.event_management.event', array_merge($lifecycleRouteParams, ['lifecycle' => 'current']));
    $expiredLifecycleUrl = route('venue.event_management.event', array_merge($lifecycleRouteParams, ['lifecycle' => 'expired']));
    $clearFiltersUrl = route('venue.event_management.event', array_merge(['language' => $activeLanguage], $surfaceParams));
    $listViewUrl = route('venue.event_management.event', array_merge($filterRouteParams, ['view_mode' => 'list']));
    $gridViewUrl = route('venue.event_management.event', array_merge($filterRouteParams, ['view_mode' => 'grid']));

    $boardLabel = !request()->filled('event_type')
      ? __('All Events')
      : (request()->input('event_type') === 'venue' ? __('Venue Events') : __('Online Events'));

    $boardSubtitle = __('Review your venue calendar, publishing state and upcoming history from one cleaner workspace.');
    if ($activeType === 'venue') {
      $boardSubtitle = __('Venue-hosted events with onsite presence, room usage and local scheduling visibility.');
    } elseif ($activeType === 'online') {
      $boardSubtitle = __('Online events attached to your venue workspace with remote delivery context.');
    }

    $scopeBadges = collect();
    if ($activeType) {
      $scopeBadges->push(['label' => __('Scope'), 'value' => ucfirst($activeType)]);
    }
    if ($activeLifecycle !== 'all') {
      $scopeBadges->push(['label' => __('Timeline'), 'value' => ucfirst($activeLifecycle)]);
    }
    if (filled($titleFilter)) {
      $scopeBadges->push(['label' => __('Search'), 'value' => $titleFilter]);
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
        <a href="{{ route('venue.dashboard') }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ __('Event Management') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ $boardLabel }}</a>
      </li>
    </ul>
  </div>

  <div class="event-index-shell">
    <section class="event-index-board">
      <div class="event-index-topbar">
        <div class="event-index-topbar__meta">
          <div class="event-index-topbar__title-row">
            <h3 class="event-index-topbar__title">{{ __('Events') . ' · ' . $language->name }}</h3>
            <span class="event-index-topbar__count">{{ $visibleCount }}</span>
          </div>
          <p class="event-index-topbar__subtitle">{{ $boardSubtitle }}</p>
          @if ($scopeBadges->isNotEmpty())
            <div class="event-index-topbar__scopes">
              @foreach ($scopeBadges as $scopeBadge)
                <span class="event-index-topbar__scope-pill">
                  <small>{{ $scopeBadge['label'] }}</small>
                  <strong>{{ $scopeBadge['value'] }}</strong>
                </span>
              @endforeach
            </div>
          @endif
        </div>

        <div class="event-index-topbar__actions">
          <button class="btn bulk-delete d-none event-index-bulk-delete"
            data-href="{{ route('venue.event_management.bulk_delete_event') }}">
            <i class="flaticon-interface-5"></i>
            {{ __('Delete Selected') }}
          </button>

          <div class="dropdown event-index-manage">
            <button class="btn dropdown-toggle event-index-add" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <i class="fas fa-plus mr-1"></i>
              {{ __('Add Event') }}
            </button>

            <div class="dropdown-menu dropdown-menu-right">
              <a href="{{ route('venue.add.event.event', ['type' => 'online']) }}" class="dropdown-item">
                {{ __('Online Event') }}
              </a>
              <a href="{{ route('venue.add.event.event', ['type' => 'venue']) }}" class="dropdown-item">
                {{ __('Venue Event') }}
              </a>
            </div>
          </div>
        </div>
      </div>

      <div class="event-index-workbench">
        <form action="{{ route('venue.event_management.event') }}" method="get" class="event-index-primary-form">
          <input type="hidden" name="language" value="{{ $activeLanguage }}">
          <input type="hidden" name="event_type" value="{{ $activeType }}">
          <input type="hidden" name="lifecycle" value="{{ $activeLifecycle === 'all' ? '' : $activeLifecycle }}">
          <input type="hidden" name="status_filter" value="{{ $statusFilter === 'all' ? '' : $statusFilter }}">
          <input type="hidden" name="view_mode" value="{{ $viewMode }}">
          <input type="hidden" name="grid_columns" value="{{ $gridColumns }}">
          <input type="hidden" name="grid_density" value="{{ $gridDensity }}">

          <label class="event-index-search">
            <span class="event-index-search__label">{{ __('Search') }}</span>
            <span class="event-index-search__control">
              <i class="fas fa-search"></i>
              <input type="text" name="title" value="{{ $titleFilter }}" placeholder="{{ __('Search events by title') }}">
            </span>
          </label>

          <label class="event-index-select-field">
            <span class="event-index-select-field__label">{{ __('Sort') }}</span>
            <select name="sort_by" class="form-control">
              @foreach ($sortLabels as $sortKey => $sortLabel)
                <option value="{{ $sortKey }}" {{ $sortBy === $sortKey ? 'selected' : '' }}>{{ $sortLabel }}</option>
              @endforeach
            </select>
          </label>

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
        </div>

        <details class="event-index-advanced" {{ $statusFilter !== 'all' || $activeLanguage !== $defaultLang->code || $viewMode === 'grid' ? 'open' : '' }}>
          <summary>
            <span class="event-index-advanced__summary-copy">
              <strong>{{ __('Advanced filters & display') }}</strong>
              <small>{{ __('Language, status and grid controls') }}</small>
            </span>
            <span class="event-index-advanced__summary-badge">
              {{ $advancedSettingsCount > 0 ? trans_choice('{1} :count active|[2,*] :count active', $advancedSettingsCount, ['count' => $advancedSettingsCount]) : __('Defaults') }}
            </span>
          </summary>

          <form action="{{ route('venue.event_management.event') }}" method="get" class="event-index-advanced__form">
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
                    $dateLabel = $event->start_date ? \Carbon\Carbon::parse($event->start_date)->format('M d, Y') : __('Date pending');
                    $timeLabel = $event->start_time ? date('g:i A', strtotime($event->start_time)) : __('Time pending');
                    $effectiveEndLabel = $event->effective_end_date_time
                      ? \Carbon\Carbon::parse($event->effective_end_date_time)->format('M d, Y · g:i A')
                      : null;
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
                          </div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div class="event-index-organizer">
                        <span class="event-index-organizer__name">{{ $workspaceOwner }}</span>
                        <span class="event-index-organizer__badge">{{ __('Venue') }}</span>
                      </div>
                    </td>
                    <td>
                      <div class="event-index-state-stack">
                        <span class="event-index-ticket-muted">
                          {{ $event->event_type === 'venue' ? __('Edit ticketing from the event editor') : __('Online delivery managed from the event editor') }}
                        </span>

                        <form id="statusForm-{{ $event->id }}" action="{{ route('venue.event_management.event.event_status', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post">
                          @csrf
                          <select class="form-control form-control-sm {{ $event->status == 0 ? 'bg-warning text-dark' : 'bg-primary' }}" name="status" onchange="document.getElementById('statusForm-{{ $event->id }}').submit()">
                            <option value="1" {{ $event->status == 1 ? 'selected' : '' }}>{{ __('Active') }}</option>
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ __('Deactive') }}</option>
                          </select>
                        </form>
                      </div>
                    </td>
                    <td>
                      <div class="event-index-actions">
                        <a href="{{ route('venue.event_management.edit_event', ['id' => $event->id]) }}" class="event-index-primary-action">
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
                            <a href="{{ route('venue.event_management.qr', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Event QR') }}
                            </a>
                            <form class="deleteForm d-block" action="{{ route('venue.event_management.delete_event', ['id' => $event->id]) }}" method="post">
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
                <span class="event-index-group__count">{{ $group['items']->count() }}</span>
              </div>

              <div class="event-index-grid">
                @foreach ($group['items'] as $event)
                  @php
                    $thumbnail = $event->thumbnail
                      ? asset('assets/admin/img/event/thumbnail/' . $event->thumbnail)
                      : asset('assets/admin/img/noimage.jpg');
                    $dateLabel = $event->start_date ? \Carbon\Carbon::parse($event->start_date)->format('M d, Y') : __('Date pending');
                    $timeLabel = $event->start_time ? date('g:i A', strtotime($event->start_time)) : __('Time pending');
                    $effectiveEndLabel = $event->effective_end_date_time
                      ? \Carbon\Carbon::parse($event->effective_end_date_time)->format('M d, Y · g:i A')
                      : null;
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
                          <span class="event-index-card__hero-owner">{{ $workspaceOwner }}</span>
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
                      </div>

                      <div class="event-index-card__ops">
                        <span class="event-index-ticket-muted">
                          {{ $event->event_type === 'venue' ? __('Edit ticketing from the event editor') : __('Online delivery managed from the event editor') }}
                        </span>

                        <form id="grid-statusForm-{{ $event->id }}" action="{{ route('venue.event_management.event.event_status', ['id' => $event->id, 'language' => $activeLanguage]) }}" method="post">
                          @csrf
                          <select class="form-control form-control-sm {{ $event->status == 0 ? 'bg-warning text-dark' : 'bg-primary' }}" name="status" onchange="document.getElementById('grid-statusForm-{{ $event->id }}').submit()">
                            <option value="1" {{ $event->status == 1 ? 'selected' : '' }}>{{ __('Active') }}</option>
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ __('Deactive') }}</option>
                          </select>
                        </form>
                      </div>

                      <div class="event-index-card__footer">
                        <a href="{{ route('venue.event_management.edit_event', ['id' => $event->id]) }}" class="event-index-primary-action event-index-primary-action--block">
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
                            <a href="{{ route('venue.event_management.qr', ['id' => $event->id]) }}" class="dropdown-item">
                              {{ __('Event QR') }}
                            </a>
                            <form class="deleteForm d-block" action="{{ route('venue.event_management.delete_event', ['id' => $event->id]) }}" method="post">
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
      @endif

      <div class="event-index-pagination">
        <div class="d-inline-block mt-3">
          {{ $events->appends([
                  'language' => $activeLanguage,
                  'title' => request()->input('title'),
                  'event_type' => request()->input('event_type'),
                  'lifecycle' => request()->input('lifecycle'),
                  'status_filter' => $statusFilter,
                  'sort_by' => $sortBy,
                  'view_mode' => $viewMode,
                  'grid_columns' => $gridColumns,
                  'grid_density' => $gridDensity,
              ])->links() }}
        </div>
      </div>
    </section>
  </div>
@endsection
