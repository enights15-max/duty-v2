@extends('backend.layout')

@section('content')
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

            <div class="col-lg-4 offset-lg-1 mt-2 mt-lg-0">

              <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle btn-sm float-right" type="button"
                  id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                  {{ __('Add Event') }}
                </button>

                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                  <a href="{{ route('add.event.event', ['type' => 'online']) }}" class="dropdown-item">
                    {{ __('Online Event') }}
                  </a>

<<<<<<< Updated upstream
                  <a href="{{ route('add.event.event', ['type' => 'venue']) }}" class="dropdown-item">
                    {{ __('Venue Event') }}
                  </a>
=======
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

        <details class="event-index-advanced" {{ $statusFilter !== 'all' || $featuredOnly || $activeLanguage !== $defaultLang->code || $viewMode === 'grid' ? 'open' : '' }}>
          <summary>
            <span class="event-index-advanced__summary-copy">
              <strong>{{ __('Advanced filters & display') }}</strong>
              <small>{{ __('Language, status, featured and grid controls') }}</small>
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
                        @if ($organizerName)
                          <a target="_blank" href="{{ route('admin.organizer_management.organizer_details', ['id' => $event->organizer_id, 'language' => $defaultLang->code]) }}" class="event-index-organizer__name">
                            {{ $organizerName }}
                          </a>
                        @else
                          <span class="event-index-organizer__name">{{ __('Admin') }}</span>
                          <span class="event-index-organizer__badge">{{ __('Internal') }}</span>
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
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ __('Deactive') }}</option>
                          </select>
                        </form>

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
>>>>>>> Stashed changes
                </div>
              </div>

<<<<<<< Updated upstream
              <button class="btn btn-danger btn-sm float-right mr-2 d-none bulk-delete"
                data-href="{{ route('admin.event_management.bulk_delete_event') }}">
                <i class="flaticon-interface-5"></i> {{ __('Delete') }}
              </button>
            </div>
          </div>
=======
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
                            <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>{{ __('Deactive') }}</option>
                          </select>
                        </form>

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
>>>>>>> Stashed changes
        </div>

        <div class="card-body">
          <div class="row">
            <div class="col-lg-12">

              <div class="float-right">
                <div class="form-group">
                  <form action="" method="get">
                    <input type="hidden" name="language" value="{{ request()->input('language') }}" class="hidden">
                    <input type="text" name="title" value="{{ request()->input('title') }}" name="name"
                      placeholder="Enter Event Name" class="form-control">
                  </form>
                </div>
              </div>

              @if (count($events) == 0)
                <h3 class="text-center mt-2">{{ __('NO EVENT CONTENT FOUND FOR ') . $language->name . '!' }}</h3>
              @else
                <div class="table-responsive">
                  <table class="table table-striped mt-3">
                    <thead>
                      <tr>
                        <th scope="col">
                          <input type="checkbox" class="bulk-check" data-val="all">
                        </th>
                        <th scope="col" width="30%">{{ __('Title') }}</th>
                        <th scope="col">{{ __('Organizer') }}</th>
                        <th scope="col">{{ __('Type') }}</th>
                        <th scope="col">{{ __('Category') }}</th>
                        <th scope="col">{{ __('Ticket') }}</th>
                        <th scope="col">{{ __('Status') }}</th>
                        <th scope="col">{{ __('Featured') }}</th>
                        <th scope="col">{{ __('Actions') }}</th>
                      </tr>
                    </thead>
                    <tbody>
                      @foreach ($events as $event)
                        <tr>
                          <td>
                            <input type="checkbox" class="bulk-check" data-val="{{ $event->id }}">
                          </td>
                          <td width="20%">
                            <a target="_blank"
                              href="{{ route('event.details', ['slug' => $event->slug, 'id' => $event->id]) }}">{{ strlen($event->title) > 30 ? mb_substr($event->title, 0, 30, 'UTF-8') . '....' : $event->title }}</a>
                          </td>
                          <td>
                            @if ($event->organizer)
                              <a target="_blank"
                                href="{{ route('admin.organizer_management.organizer_details', ['id' => $event->organizer_id, 'language' => $defaultLang->code]) }}">
                                {{ strlen($event->organizer->username) > 20 ? mb_substr($event->organizer->username, 0, 20, 'UTF-8') . '....' : $event->organizer->username }}</a>
                            @else
                              <span class="badge badge-success">{{ __('Admin') }}</span>
                            @endif
                          </td>
                          <td>
                            {{ ucfirst($event->event_type) }}
                          </td>
                          <td>
                            {{ $event->category }}
                          </td>
                          <td>
                            @if ($event->event_type == 'venue')
                              <a href="{{ route('admin.event.ticket', ['language' => request()->input('language'), 'event_id' => $event->id, 'event_type' => $event->event_type]) }}"
                                class="btn btn-success btn-sm">{{ __('Manage') }}</a>
                            @endif
                          </td>
                          <td>
                            <form id="statusForm-{{ $event->id }}" class="d-inline-block"
                              action="{{ route('admin.event_management.event.event_status', ['id' => $event->id, 'language' => request()->input('language')]) }}"
                              method="post">

                              @csrf
                              <select
                                class="form-control form-control-sm {{ $event->status == 0 ? 'bg-warning text-dark' : 'bg-primary' }}"
                                name="status"
                                onchange="document.getElementById('statusForm-{{ $event->id }}').submit()">
                                <option value="1" {{ $event->status == 1 ? 'selected' : '' }}>
                                  {{ __('Active') }}
                                </option>
                                <option value="0" {{ $event->status == 0 ? 'selected' : '' }}>
                                  {{ __('Deactive') }}
                                </option>
                              </select>
                            </form>
                          </td>
                          <td>

                            <form id="featuredForm-{{ $event->id }}" class="d-inline-block"
                              action="{{ route('admin.event_management.event.update_featured', ['id' => $event->id]) }}"
                              method="post">

                              @csrf
                              <select
                                class="form-control form-control-sm {{ $event->is_featured == 'yes' ? 'bg-success' : 'bg-danger' }}"
                                name="is_featured"
                                onchange="document.getElementById('featuredForm-{{ $event->id }}').submit()">
                                <option value="yes" {{ $event->is_featured == 'yes' ? 'selected' : '' }}>
                                  {{ __('Yes') }}
                                </option>
                                <option value="no" {{ $event->is_featured == 'no' ? 'selected' : '' }}>
                                  {{ __('No') }}
                                </option>
                              </select>
                            </form>
                          </td>
                          <td>
                            <div class="dropdown">
                              <button class="btn btn-secondary dropdown-toggle btn-sm" type="button"
                                id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true"
                                aria-expanded="false">
                                {{ __('Select') }}
                              </button>

                              <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                <a href="{{ route('admin.event_management.edit_event', ['id' => $event->id]) }}"
                                  class="dropdown-item">
                                  {{ __('Edit') }}
                                </a>

                                <a href="{{ route('admin.event_management.ticket_setting', ['id' => $event->id]) }}"
                                  class="dropdown-item">
                                  {{ __('Ticket Settings') }}
                                </a>

                                <form class="deleteForm d-block"
                                  action="{{ route('admin.event_management.delete_event', ['id' => $event->id]) }}"
                                  method="post">

                                  @csrf
                                  <button type="submit" class="btn btn-sm deleteBtn">
                                    {{ __('Delete') }}
                                  </button>
                                </form>
                              </div>
                            </div>
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

        <div class="card-footer text-center">
          <div class="d-inline-block mt-3">
            {{ $events->appends([
                    'language' => request()->input('language'),
                    'title' => request()->input('title'),
                ])->links() }}
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection
