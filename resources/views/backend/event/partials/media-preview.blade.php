@php
    $eventModel = $event ?? null;
    $fallbackImage = asset('assets/admin/img/noimage.jpg');
    $thumbnailPreview = $eventModel && $eventModel->thumbnail
        ? asset('assets/admin/img/event/thumbnail/' . $eventModel->thumbnail)
        : $fallbackImage;
@endphp

<div class="event-media-workbench" id="eventMediaWorkbench">
    <div class="event-media-workbench__header">
        <div>
            <span class="event-media-workbench__eyebrow">{{ __('Live Preview') }}</span>
            <h3 class="event-media-workbench__title">{{ __('Media fit before saving') }}</h3>
            <p class="event-media-workbench__description">
                {{ __('Upload any image, adjust the framing here, and keep the backend validation as a final guard. This preview mirrors how the event will present in detail and listing surfaces.') }}
            </p>
        </div>
    </div>

    <div class="event-media-workbench__targets">
        <div class="event-media-target">
            <span class="event-media-target__label">{{ __('Detail cover') }}</span>
            <span class="event-media-target__value">1170 × 570</span>
        </div>
        <div class="event-media-target">
            <span class="event-media-target__label">{{ __('Listing thumbnail') }}</span>
            <span class="event-media-target__value">320 × 230</span>
        </div>
    </div>

    <div class="event-media-preview" id="eventMediaPreview">
        <div class="event-media-preview__hero">
            <img
                src="{{ $thumbnailPreview }}"
                alt="{{ __('Event cover preview') }}"
                class="event-media-preview__hero-image"
                id="eventDetailPreviewHero"
                data-placeholder="{{ $fallbackImage }}"
            >

            <div class="event-media-preview__hero-content">
                <div class="event-media-preview__hero-meta">
                    <span>{{ __('Detail page cover') }}</span>
                </div>
                <h4 class="event-media-preview__hero-title" id="eventDetailPreviewTitle">
                    {{ __('Your event title') }}
                </h4>
                <p class="event-media-preview__hero-subtitle" id="eventDetailPreviewMeta">
                    {{ __('Date, time and venue will update while you edit the form.') }}
                </p>
            </div>
        </div>

        <div class="event-media-preview__sidebar">
            <div>
                <span class="event-media-preview__sidebar-label">{{ __('Listing card') }}</span>
            </div>

            <div class="event-media-preview__card">
                <img
                    src="{{ $thumbnailPreview }}"
                    alt="{{ __('Event thumbnail preview') }}"
                    class="event-media-preview__thumb-image"
                    id="eventDetailPreviewThumbnail"
                    data-placeholder="{{ $fallbackImage }}"
                >
                <div class="event-media-preview__card-body">
                    <h5 class="event-media-preview__card-title" id="eventCardPreviewTitle">
                        {{ __('Your event title') }}
                    </h5>
                    <div class="event-media-preview__card-meta">
                        <span id="eventCardPreviewDate">{{ __('Date pending') }}</span>
                        <span id="eventCardPreviewVenue">{{ __('Venue pending') }}</span>
                    </div>
                </div>
            </div>

            <p class="event-media-preview__hint">
                {{ __('The large frame follows the gallery/header media. If there is no gallery yet, the preview falls back to the thumbnail automatically.') }}
            </p>
        </div>
    </div>
</div>
