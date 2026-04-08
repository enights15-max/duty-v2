@php
    $now_time = \Carbon\Carbon::now();

    if ($event->date_type == 'multiple') {
        $event_date = eventLatestDates($event->id);
        $date = strtotime(@$event_date->start_date);
    } else {
        $date = strtotime($event->start_date);
    }

    $organizer = null;
    $admin = null;

    if ($event->organizer_id != null) {
        $organizer = App\Models\Organizer::where('id', $event->organizer_id)->first();
    }

    if (!$organizer) {
        $admin = App\Models\Admin::first();
    }

    if ($event->event_type == 'online') {
        $ticket = App\Models\Event\Ticket::where('event_id', $event->id)
            ->orderBy('price', 'asc')
            ->first();
    } else {
        $ticket = App\Models\Event\Ticket::where([['event_id', $event->id], ['price', '!=', null]])
            ->orderBy('price', 'asc')
            ->first();
        if (empty($ticket)) {
            $ticket = App\Models\Event\Ticket::where([['event_id', $event->id], ['f_price', '!=', null]])
                ->orderBy('price', 'asc')
                ->first();
        }
    }
    $event_count = DB::table('tickets')
        ->where('event_id', $event->id)
        ->get()
        ->count();
@endphp

<div class="col-lg-4 col-md-6 item">
    <div class="event-card-v2">
        <div class="card-image">
            <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                <img class="lazy" data-src="{{ asset('assets/admin/img/event/thumbnail/' . $event->thumbnail) }}"
                    alt="Event">
            </a>
            @if ($ticket)
                <div class="card-badge {{ $ticket->price != null ? 'price' : '' }}">
                    @if ($ticket->price != null || $ticket->pricing_type == 'variation')
                        {{ symbolPrice($ticket->price ?? 0) }}
                    @else
                        {{ __('FREE') }}
                    @endif
                </div>
            @endif
        </div>

        <div class="card-body">
            @php
                $categoryName = @$event->categoryName;
                if (!$categoryName && isset($event->event_category_id)) {
                    $category = App\Models\Event\EventCategory::find($event->event_category_id);
                    $categoryName = @$category->name;
                }
            @endphp
            <span class="card-category">{{ $categoryName ?? __('Event') }}</span>
            <h5 class="card-title">
                <a href="{{ route('event.details', [$event->slug, $event->id]) }}">
                    {{ strlen($event->title) > 45 ? mb_substr($event->title, 0, 45) . '...' : $event->title }}
                </a>
            </h5>

            <div class="card-meta-row">
                <i class="far fa-calendar-alt"></i>
                <span>{{ \Carbon\Carbon::parse($date)->translatedFormat('D, M d') }} •
                    {{ \Carbon\Carbon::parse(strtotime($event->start_time))->translatedFormat('h:i A') }}</span>
            </div>

            <div class="card-meta-row">
                <i class="fas fa-map-marker-alt"></i>
                <span>{{ $event->event_type == 'venue' ? $event->address : __('Online Event') }}</span>
            </div>
        </div>

        <div class="card-footer-v2">
            <div class="card-organizer">
                <i class="far fa-user-circle"></i>
                @if ($organizer && !empty($organizer->organizer_info?->name))
                    <span>{{ $organizer->organizer_info->name }}</span>
                @else
                    <span>{{ $admin->username ?? __('DUTY') }}</span>
                @endif
            </div>
            <a href="{{ route('event.details', [$event->slug, $event->id]) }}" class="card-btn">
                {{ __('Book Now') }} <i class="fas fa-chevron-right"></i>
            </a>
        </div>
    </div>
</div>
