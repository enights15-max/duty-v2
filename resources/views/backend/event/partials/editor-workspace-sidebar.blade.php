@php
    $editorEvent = $event ?? null;
    $editorMode = $editorEvent ? __('Edit mode') : __('Create mode');
    $editorType = $editorEvent ? ucfirst($editorEvent->event_type) : ucfirst(request()->input('type') ?? __('Event'));
    $editorIdentity = $editorEvent && $editorEvent->organizer_id ? __('Organizer event') : __('Admin workspace');
    $eventContents = $editorEvent
        ? \App\Models\Event\EventContent::where('event_id', $editorEvent->id)->get()
        : collect();
    $mediaSeed = $editorEvent
        ? filled($editorEvent->thumbnail) && \App\Models\Event\EventImage::where('event_id', $editorEvent->id)->exists()
        : false;
    $scheduleSeed = false;
    if ($editorEvent) {
        if ($editorEvent->date_type === 'multiple') {
            $scheduleSeed = $editorEvent->dates()
                ->get()
                ->contains(fn ($date) => filled($date->start_date) && filled($date->start_time) && filled($date->end_date) && filled($date->end_time));
        } else {
            $scheduleSeed = filled($editorEvent->start_date) && filled($editorEvent->start_time) && filled($editorEvent->end_date) && filled($editorEvent->end_time);
        }
    }
    $settingsSeed = $editorEvent ? filled($editorEvent->status) && filled($editorEvent->is_featured) : false;
    $experienceSeed = false;
    if ($editorEvent) {
        if ($editorEvent->event_type === 'online') {
            $experienceSeed = filled($editorEvent->meeting_url)
                && (
                    optional($editorEvent->ticket)->pricing_type === 'free'
                    || filled(optional($editorEvent->ticket)->price)
                );
        } else {
            $experienceSeed = filled($editorEvent->venue_id)
                || (filled($editorEvent->venue_name_snapshot) && filled($editorEvent->venue_address_snapshot))
                || $eventContents->contains(fn ($content) => filled($content->address) && (filled($content->city_id) || filled($content->city)));
        }
    }
    $contentSeed = $eventContents->contains(function ($content) {
        return filled($content->title)
            && filled($content->event_category_id)
            && strlen(trim(strip_tags((string) $content->description))) >= 30;
    });
@endphp

<aside class="event-editor-sidebar">
    <div class="event-editor-sidebar__panel"
        id="eventEditorSidebarPanel"
        data-seed-media="{{ $mediaSeed ? 1 : 0 }}"
        data-seed-schedule="{{ $scheduleSeed ? 1 : 0 }}"
        data-seed-settings="{{ $settingsSeed ? 1 : 0 }}"
        data-seed-experience="{{ $experienceSeed ? 1 : 0 }}"
        data-seed-content="{{ $contentSeed ? 1 : 0 }}">
        <span class="event-editor-sidebar__eyebrow">{{ __('Workspace') }}</span>
        <h3 class="event-editor-sidebar__title">{{ __('Event Editor') }}</h3>
        <p class="event-editor-sidebar__text">
            {{ __('Move section by section, keep the media polished, and validate the public presentation before publishing.') }}
        </p>

        <div class="event-editor-sidebar__progress">
            <div class="event-editor-sidebar__progress-meta">
                <span>{{ __('Completion') }}</span>
                <strong id="eventEditorCompletion">0%</strong>
            </div>
            <div class="event-editor-sidebar__progress-bar">
                <span id="eventEditorCompletionBar"></span>
            </div>
        </div>

        <div class="event-editor-sidebar__save-wrap">
            <button type="button" id="EventSubmitSticky" class="event-editor-sidebar__save" aria-controls="eventForm">
                <i class="fas fa-save"></i>
                {{ $editorEvent ? __('Update Event') : __('Save Event') }}
            </button>
            <p class="event-editor-sidebar__save-note">
                {{ __('Save at any time without leaving the section navigation.') }}
            </p>
        </div>

        <nav class="event-editor-nav mt-3">
            <button type="button" class="event-editor-nav__item" data-editor-link="media">
                <div class="event-editor-nav__meta">
                    <span class="event-editor-nav__label">{{ __('Media') }}</span>
                    <span class="event-editor-nav__status" data-editor-status="media">{{ __('Pending') }}</span>
                </div>
            </button>
            <button type="button" class="event-editor-nav__item" data-editor-link="schedule">
                <div class="event-editor-nav__meta">
                    <span class="event-editor-nav__label">{{ __('Schedule') }}</span>
                    <span class="event-editor-nav__status" data-editor-status="schedule">{{ __('Pending') }}</span>
                </div>
            </button>
            <button type="button" class="event-editor-nav__item" data-editor-link="settings">
                <div class="event-editor-nav__meta">
                    <span class="event-editor-nav__label">{{ __('Settings') }}</span>
                    <span class="event-editor-nav__status" data-editor-status="settings">{{ __('Pending') }}</span>
                </div>
            </button>
            <button type="button" class="event-editor-nav__item" data-editor-link="experience">
                <div class="event-editor-nav__meta">
                    <span class="event-editor-nav__label">{{ __('Venue, lineup, tickets') }}</span>
                    <span class="event-editor-nav__status" data-editor-status="experience">{{ __('Pending') }}</span>
                </div>
            </button>
            <button type="button" class="event-editor-nav__item" data-editor-link="content">
                <div class="event-editor-nav__meta">
                    <span class="event-editor-nav__label">{{ __('Content & SEO') }}</span>
                    <span class="event-editor-nav__status" data-editor-status="content">{{ __('Pending') }}</span>
                </div>
            </button>
        </nav>
    </div>

    <div class="event-editor-sidebar__panel">
        <span class="event-editor-sidebar__eyebrow">{{ __('Context') }}</span>
        <h4 class="event-editor-sidebar__title">{{ __('Current setup') }}</h4>
        <div class="event-editor-context-grid">
            <div class="event-editor-context-card">
                <span class="event-editor-context-card__label">{{ __('Mode') }}</span>
                <span class="event-editor-context-card__value">{{ $editorMode }}</span>
            </div>
            <div class="event-editor-context-card">
                <span class="event-editor-context-card__label">{{ __('Event type') }}</span>
                <span class="event-editor-context-card__value">{{ $editorType }}</span>
            </div>
            <div class="event-editor-context-card event-editor-context-card--wide">
                <span class="event-editor-context-card__label">{{ __('Workspace owner') }}</span>
                <span class="event-editor-context-card__value">{{ $editorIdentity }}</span>
            </div>
        </div>

        @if ($editorEvent)
            <div class="event-editor-sidebar__links">
                <a class="event-editor-sidebar__link event-editor-sidebar__link--primary"
                    href="{{ route('event.details', ['slug' => eventSlug($defaultLang->id, $editorEvent->id), 'id' => $editorEvent->id]) }}"
                    target="_blank">
                    <i class="fas fa-eye"></i>
                    {{ __('Open public preview') }}
                </a>
                @if ($editorEvent->event_type === 'venue')
                    <a class="event-editor-sidebar__link event-editor-sidebar__link--ghost"
                        href="{{ route('admin.event.ticket', ['language' => $defaultLang->code, 'event_id' => $editorEvent->id, 'event_type' => $editorEvent->event_type]) }}"
                        target="_blank">
                        <i class="far fa-ticket-alt"></i>
                        {{ __('Manage tickets') }}
                    </a>
                @endif
            </div>
        @endif

        <ul class="event-editor-sidebar__tips">
            <li>{{ __('Use the media cropper to keep both cover and card thumbnails clean before saving.') }}</li>
            <li>{{ __('Complete the default language first, then clone or refine the remaining languages.') }}</li>
            <li>{{ __('For venue events, verify the public preview after changing venue or lineup.') }}</li>
        </ul>
    </div>
</aside>
