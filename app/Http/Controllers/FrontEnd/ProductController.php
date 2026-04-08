<?php

namespace App\Http\Controllers\FrontEnd;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Event;
use App\Models\Event\EventContent;
use App\Models\Organizer;
use App\Models\Venue;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function downloadApp(Request $request)
    {
        $surface = $request->query('surface', 'general');
        $eventTitle = null;

        if ($surface === 'event' && $request->filled('event')) {
            $eventTitle = EventContent::query()
                ->where('event_id', $request->query('event'))
                ->value('title') ?: __('Duty event');
        }

        return view('frontend.product.download-app', [
            'pageTitle' => __('Download the app'),
            'storeLinks' => $this->storeLinks(),
            'sceneStats' => $this->sceneStats(),
            'downloadContext' => $this->downloadContext($surface, $eventTitle),
        ]);
    }

    public function openEvent(Request $request, int $id, ?string $slug = null)
    {
        $event = Event::query()->find($id);
        $content = EventContent::query()
            ->where('event_id', $id)
            ->select('title', 'slug', 'meta_description', 'address', 'city')
            ->first();

        $eventTitle = $content?->title ?: __('Duty event');
        $shareDescription = $this->eventShareDescription($event, $content);
        $publicEventUrl = $content?->slug
            ? route('event.details', ['slug' => $content->slug, 'id' => $id])
            : route('frontend.download_app', ['surface' => 'event', 'event' => $id]);

        $thumbnail = $event?->thumbnail;
        $eventImageUrl = null;
        if (!empty($thumbnail)) {
            $eventImageUrl = str_starts_with($thumbnail, 'http')
                ? $thumbnail
                : asset('assets/admin/img/event/thumbnail/' . $thumbnail);
        }

        return view('frontend.product.open-event', [
            'pageTitle' => $eventTitle,
            'eventTitle' => $eventTitle,
            'shareDescription' => $shareDescription,
            'eventId' => $id,
            'eventSlug' => $content?->slug ?: $slug,
            'eventImageUrl' => $eventImageUrl,
            'publicEventUrl' => $publicEventUrl,
            'downloadUrl' => route('frontend.download_app', [
                'surface' => 'event',
                'event' => $id,
            ]),
            'deepLinkUrl' => $this->deepLinkUrl('event/' . $id),
            'storeLinks' => $this->storeLinks(),
        ]);
    }

    public function forOrganizers()
    {
        $sceneStats = $this->sceneStats();

        return view('frontend.product.persona', [
            'pageTitle' => __('For Organizers'),
            'storeLinks' => $this->storeLinks(),
            'sceneStats' => $sceneStats,
            'persona' => [
                'eyebrow' => __('For organizers'),
                'title' => __('Run the scene from the web. Bring the crowd into the app.'),
                'accent' => __('Publish events, manage bookings and grow repeat attendance with a stronger social loop.'),
                'description' => __('Duty gives organizers a public web presence, a pro workspace and an app-first consumer flow. Fans discover on the web, then download the app for tickets, access and social follow-through.'),
                'primary_label' => __('Create organizer account'),
                'primary_url' => route('organizer.signup'),
                'secondary_label' => __('Download the app'),
                'secondary_url' => route('frontend.download_app', ['surface' => 'organizer']),
                'proof' => [
                    ['value' => number_format($sceneStats['upcoming_events']), 'label' => __('upcoming events live on the scene')],
                    ['value' => number_format($sceneStats['organizers']), 'label' => __('organizers already visible in discovery')],
                    ['value' => __('Web + App'), 'label' => __('dual-surface model for acquisition and access')],
                ],
                'pillars' => [
                    [
                        'title' => __('Launch with presence'),
                        'copy' => __('Organizer pages, public event pages and SEO-friendly sharing help you look established before people ever download the app.'),
                    ],
                    [
                        'title' => __('Operate from desktop'),
                        'copy' => __('Bookings, reservations, scanner flows, earnings and reporting stay in a pro-friendly web workspace.'),
                    ],
                    [
                        'title' => __('Close the loop in the app'),
                        'copy' => __('Consumers buy, hold access, follow your scene and come back through the app experience instead of one-off web checkouts.'),
                    ],
                ],
                'workflows' => [
                    __('Create and publish events with stronger public presentation'),
                    __('Monitor bookings, reservations and due-soon activity from web dashboards'),
                    __('Build followers and social proof around your host identity'),
                    __('Push fans into the app for ticket access and repeat engagement'),
                ],
                'footer_title' => __('Built for teams that need reach and control.'),
                'footer_copy' => __('Use the web to recruit the audience and the app to keep them coming back.')
            ],
        ]);
    }

    public function forArtists()
    {
        $sceneStats = $this->sceneStats();

        return view('frontend.product.persona', [
            'pageTitle' => __('For Artists'),
            'storeLinks' => $this->storeLinks(),
            'sceneStats' => $sceneStats,
            'persona' => [
                'eyebrow' => __('For artists and DJs'),
                'title' => __('Turn appearances into a profile people can follow.'),
                'accent' => __('The web gives your presence reach. The app keeps fans connected after the night ends.'),
                'description' => __('Duty helps artists show up in lineups, discovery, public profiles and social context. When fans move into the app, they can keep following your scene, tips and upcoming appearances.'),
                'primary_label' => __('Talk to the Duty team'),
                'primary_url' => route('contact'),
                'secondary_label' => __('Artist login'),
                'secondary_url' => route('artist.login'),
                'proof' => [
                    ['value' => number_format($sceneStats['artists']), 'label' => __('artists currently discoverable')],
                    ['value' => __('Profile-first'), 'label' => __('public presence around lineups and reviews')],
                    ['value' => __('App-social'), 'label' => __('follow, review and tip loops inside the app')],
                ],
                'pillars' => [
                    [
                        'title' => __('Show up where discovery happens'),
                        'copy' => __('Your profile, appearances and related events can be part of the public scene even before someone becomes a fan.'),
                    ],
                    [
                        'title' => __('Carry momentum across events'),
                        'copy' => __('Each lineup appearance becomes another surface that can point listeners back into your identity and upcoming shows.'),
                    ],
                    [
                        'title' => __('Stay close to your audience'),
                        'copy' => __('The app becomes the place where recurring listeners keep your scene in their pocket.'),
                    ],
                ],
                'workflows' => [
                    __('Appear in lineups and public event narratives with stronger presentation'),
                    __('Collect social proof from reviews, visibility and repeated appearances'),
                    __('Give fans a reason to move from browsing to following inside the app'),
                    __('Use artist access to review performance, earnings and future bookings'),
                ],
                'footer_title' => __('This is not just a profile card.'),
                'footer_copy' => __('It is a long-term artist surface that keeps growing as your scene grows.')
            ],
        ]);
    }

    public function forVenues()
    {
        $sceneStats = $this->sceneStats();

        return view('frontend.product.persona', [
            'pageTitle' => __('For Venues'),
            'storeLinks' => $this->storeLinks(),
            'sceneStats' => $sceneStats,
            'persona' => [
                'eyebrow' => __('For venues'),
                'title' => __('Make the place part of the brand, not just the address.'),
                'accent' => __('Venue pages become a real discovery surface while your web tools stay focused on operations.'),
                'description' => __('Duty lets venues present their identity publicly, host events with stronger place branding and keep ticket access inside the app where the experience feels native.'),
                'primary_label' => __('Talk to the Duty team'),
                'primary_url' => route('contact'),
                'secondary_label' => __('Venue login'),
                'secondary_url' => route('venue.login'),
                'proof' => [
                    ['value' => number_format($sceneStats['venues']), 'label' => __('venues already visible in the network')],
                    ['value' => __('Place-first'), 'label' => __('public venue pages with event calendars')],
                    ['value' => __('Ops-ready'), 'label' => __('bookings, reservations and scanner support on web')],
                ],
                'pillars' => [
                    [
                        'title' => __('Present the room properly'),
                        'copy' => __('A venue should feel like a destination. Public pages and event detail surfaces now let the place carry more atmosphere and authority.'),
                    ],
                    [
                        'title' => __('Keep operational control on desktop'),
                        'copy' => __('Calendars, reservations, bookings and scanner flows stay practical for venue teams working from web.'),
                    ],
                    [
                        'title' => __('Move guests into the app'),
                        'copy' => __('Guests can browse the place on web, then unlock tickets and entry through the app-first customer journey.'),
                    ],
                ],
                'workflows' => [
                    __('Run venue calendars with clearer public branding'),
                    __('Manage bookings, reservations and payouts from the web workspace'),
                    __('Give promoters and guests a stronger public destination to share'),
                    __('Use the app as the final ticket and access layer for attendees'),
                ],
                'footer_title' => __('The venue becomes part of the scene graph.'),
                'footer_copy' => __('Not just where an event happens, but a place people can remember, follow and return to.')
            ],
        ]);
    }

    private function sceneStats(): array
    {
        return [
            'upcoming_events' => Event::query()->where('status', 1)->where('end_date_time', '>=', now())->count(),
            'organizers' => Organizer::query()->where('status', 1)->count(),
            'artists' => Artist::query()->where('status', 1)->count(),
            'venues' => Venue::query()->where('status', 1)->count(),
        ];
    }

    private function storeLinks(): array
    {
        return [
            'ios' => config('services.duty_app.ios_url'),
            'android' => config('services.duty_app.android_url'),
        ];
    }

    private function deepLinkUrl(string $path): string
    {
        $base = config('services.duty_app.deep_link_base', 'duty://');

        if (str_ends_with($base, '://')) {
            return $base . ltrim($path, '/');
        }

        return rtrim($base, '/') . '/' . ltrim($path, '/');
    }

    private function downloadContext(string $surface, ?string $eventTitle = null): array
    {
        if ($surface === 'event') {
            return [
                'eyebrow' => __('App-first ticket access'),
                'title' => $eventTitle
                    ? __('Unlock :event in the app.', ['event' => $eventTitle])
                    : __('Unlock tickets and access inside the app.'),
                'copy' => __('Duty uses the app as the ticket wallet, entry pass and social layer. Browse on web, then continue on your phone for the full event flow.'),
            ];
        }

        if ($surface === 'organizer') {
            return [
                'eyebrow' => __('Consumer experience lives here'),
                'title' => __('The app is where your audience buys, follows and shows up.'),
                'copy' => __('The web brings them in. The app keeps the relationship going through tickets, access, follow signals and recurring discovery.'),
            ];
        }

        return [
            'eyebrow' => __('Duty app'),
            'title' => __('Keep the ticket, the scene and the access pass in one place.'),
            'copy' => __('The app is the consumer core of Duty: discover the scene, unlock tickets, store access and stay close to the people and places you follow.'),
        ];
    }

    private function eventShareDescription(?Event $event, ?EventContent $content): string
    {
        $metaDescription = trim((string) ($content?->meta_description ?? ''));
        if ($metaDescription !== '') {
            return $metaDescription;
        }

        $parts = [];

        $dateText = null;
        if (!empty($event?->start_date)) {
            try {
                $date = Carbon::parse($event->start_date)->translatedFormat('M j, Y');
                $time = !empty($event->start_time)
                    ? Carbon::parse($event->start_time)->translatedFormat('g:i A')
                    : null;
                $dateText = $time ? $date . ' at ' . $time : $date;
            } catch (\Throwable $exception) {
                $dateText = null;
            }
        }

        if ($dateText) {
            $parts[] = $dateText;
        }

        $location = trim((string) ($content?->address ?? ''));
        if ($location === '') {
            $location = trim((string) ($content?->city ?? ''));
        }
        if ($location === '' && !empty($event?->venue_name_snapshot)) {
            $location = trim((string) $event->venue_name_snapshot);
        }

        if ($location !== '') {
            $parts[] = $location;
        }

        $summary = implode(' · ', $parts);
        if ($summary !== '') {
            return __(':summary. Open in Duty for tickets, access and scene updates.', [
                'summary' => $summary,
            ]);
        }

        return __('Open this event in the Duty app for ticket access, entry and scene updates.');
    }
}
