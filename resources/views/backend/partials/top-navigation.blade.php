@php
    $rolePermissions = [];
    if (!is_null($roleInfo)) {
        $rolePermissions = json_decode($roleInfo->permissions) ?? [];
    }

    $canMenuBuilder = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Menu Builder', $rolePermissions));
    $canEventManagement = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Management', $rolePermissions));
    $canEventBookings = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Bookings', $rolePermissions));
    $canBlackmarket = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Blackmarket', $rolePermissions));
    $canSupport = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Support Ticket', $rolePermissions));
    $canTransactions = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Transaction', $rolePermissions));
    $canWithdraw = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Withdraw Method', $rolePermissions));
    $canPayments = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Payment Gateways', $rolePermissions));
    $canOrganizers = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Organizer Mangement', $rolePermissions));
    $canCustomers = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Customer Management', $rolePermissions));
    $canIdentities = is_null($roleInfo) || (!empty($rolePermissions) && (in_array('Identity Management', $rolePermissions) || in_array('Customer Management', $rolePermissions)));
    $canReviews = $canIdentities;
    $canVenues = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Venue Management', $rolePermissions));
    $canArtists = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Artist Management', $rolePermissions));
    $canWallets = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Customer Management', $rolePermissions));
    $canAds = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Advertise', $rolePermissions));
    $canPopups = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Announcement Popups', $rolePermissions));
    $canSubscribers = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Subscribers', $rolePermissions));
    $canPush = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Push Notification', $rolePermissions));
    $canHomePage = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Home Page', $rolePermissions));
    $canFooter = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Footer', $rolePermissions));
    $canCustomPages = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Custom Pages', $rolePermissions));
    $canBlog = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Blog Management', $rolePermissions));
    $canFaq = is_null($roleInfo) || (!empty($rolePermissions) && in_array('FAQ Management', $rolePermissions));
    $canBasicSettings = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Basic Settings', $rolePermissions));
    $canMobileInterface = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Mobile Interface', $rolePermissions));
    $canPwa = is_null($roleInfo) || (!empty($rolePermissions) && in_array('PWA Settings', $rolePermissions));
    $canAdmins = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Admin Management', $rolePermissions));
    $canLanguages = is_null($roleInfo) || (!empty($rolePermissions) && in_array('Language Management', $rolePermissions));

    $dashboardActive = request()->routeIs('admin.dashboard');
    $operationsActive =
        request()->routeIs('admin.event_management.*') ||
        request()->routeIs('admin.choose-event-type') ||
        request()->routeIs('add.event.event') ||
        request()->routeIs('admin.event.*') ||
        request()->routeIs('admin.ticket_management.*') ||
        request()->routeIs('admin.event.booking') ||
        request()->routeIs('admin.event_booking.*') ||
        request()->routeIs('admin.event_reservation.*') ||
        request()->routeIs('admin.blackmarket.*') ||
        request()->routeIs('admin.support_ticket.*') ||
        request()->routeIs('admin.support_tickets*');
    $peopleActive =
        request()->routeIs('admin.organizer_management.*') ||
        request()->routeIs('admin.customer_management.*') ||
        request()->routeIs('admin.identity_management.*') ||
        request()->routeIs('admin.review_management.*') ||
        request()->routeIs('admin.venue_management.*') ||
        request()->routeIs('admin.artist_management.*') ||
        request()->routeIs('admin.wallet_management.*');
    $financeActive =
        request()->routeIs('admin.transcation') ||
        request()->routeIs('admin.withdraw.*') ||
        request()->routeIs('admin.withdraw_payment_method.*') ||
        request()->routeIs('admin.payment_gateways.*');
    $growthActive =
        request()->routeIs('admin.advertise.*') ||
        request()->routeIs('admin.announcement_popups*') ||
        request()->routeIs('admin.user_management.subscribers') ||
        request()->routeIs('admin.user_management.mail_for_subscribers') ||
        request()->routeIs('admin.user_management.push_notification.*');
    $contentActive =
        request()->routeIs('admin.home_page.*') ||
        request()->routeIs('admin.footer.*') ||
        request()->routeIs('admin.custom_pages*') ||
        request()->routeIs('admin.blog_management.*') ||
        request()->routeIs('admin.faq_management') ||
        request()->routeIs('admin.menu_builder') ||
        request()->routeIs('admin.contact.page');
    $systemActive =
        request()->routeIs('admin.basic_settings.*') ||
        request()->routeIs('admin.mobile_interface*') ||
        request()->routeIs('admin.pwa*') ||
        request()->routeIs('admin.admin_management.*') ||
        request()->routeIs('admin.language_management') ||
        request()->routeIs('admin.edit_admin_keywords');
@endphp

<div class="admin-topnav-shell">
    <div class="admin-topnav">

        <ul class="admin-topnav__menu">
            <li class="admin-topnav__item">
                <a href="{{ route('admin.dashboard') }}"
                    class="admin-topnav__link {{ $dashboardActive ? 'is-active' : '' }}">
                    <i class="fas fa-chart-pie"></i>
                    <span>{{ __('Dashboard') }}</span>
                </a>
            </li>

            @if ($canEventManagement || $canEventBookings || $canBlackmarket || $canSupport)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $operationsActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-bolt"></i>
                        <span>{{ __('Operations') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown admin-topnav__dropdown--wide">
                        <div class="admin-topnav__dropdown-grid">
                            @if ($canEventManagement)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Events') }}</div>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.event_management.event', ['language' => $defaultLang->code]) }}">{{ __('All Events') }}</a>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.choose-event-type', ['language' => $defaultLang->code]) }}">{{ __('Add Event') }}</a>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.event_management.settings') }}">{{ __('Event Specs') }}</a>
                                </div>
                            @endif
                            @if ($canEventBookings)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Bookings & Reservations') }}</div>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.event.booking') }}">{{ __('Bookings') }}</a>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.event_reservation.index', ['status' => 'all']) }}">{{ __('Reservations') }}</a>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.event_booking.report') }}">{{ __('Report') }}</a>
                                </div>
                            @endif
                            @if ($canBlackmarket || $canSupport)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Issue Flow') }}</div>
                                    @if ($canBlackmarket)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.blackmarket.tickets') }}">{{ __('Blackmarket') }}</a>
                                    @endif
                                    @if ($canSupport)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.support_tickets') }}">{{ __('Support Tickets') }}</a>
                                    @endif
                                </div>
                            @endif
                        </div>
                    </div>
                </li>
            @endif

            @if ($canCustomers || $canIdentities || $canOrganizers || $canArtists || $canVenues || $canReviews || $canWallets)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $peopleActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-user-friends"></i>
                        <span>{{ __('People') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown admin-topnav__dropdown--wide">
                        <div class="admin-topnav__dropdown-grid">
                            @if ($canCustomers || $canWallets)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Consumers') }}</div>
                                    @if ($canCustomers)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.organizer_management.registered_customer') }}">{{ __('Customers') }}</a>
                                    @endif
                                    @if ($canWallets)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.wallet_management.wallets') }}">{{ __('Wallets') }}</a>
                                    @endif
                                </div>
                            @endif
                            @if ($canIdentities || $canOrganizers || $canArtists || $canVenues)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Professional Accounts') }}</div>
                                    @if ($canIdentities)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.identity_management.index') }}">{{ __('Professional Identities') }}</a>
                                    @endif
                                    @if ($canOrganizers)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.organizer_management.registered_organizer') }}">{{ __('Organizers') }}</a>
                                    @endif
                                    @if ($canArtists)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.artist_management.registered_artist') }}">{{ __('Artists') }}</a>
                                    @endif
                                    @if ($canVenues)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.venue_management.registered_venue') }}">{{ __('Venues') }}</a>
                                    @endif
                                </div>
                            @endif
                            @if ($canReviews)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Community') }}</div>
                                    <a class="admin-topnav__dropdown-link" href="{{ route('admin.review_management.index') }}">{{ __('Reviews') }}</a>
                                </div>
                            @endif
                        </div>
                    </div>
                </li>
            @endif

            @if ($canTransactions || $canWithdraw || $canPayments)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $financeActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-coins"></i>
                        <span>{{ __('Finance') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown">
                        @if ($canTransactions)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.transcation') }}">{{ __('Transactions') }}</a>
                        @endif
                        @if ($canWithdraw)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.withdraw.payment_method', ['language' => $defaultLang->code]) }}">{{ __('Payout Methods') }}</a>
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.withdraw.withdraw_request', ['language' => $defaultLang->code]) }}">{{ __('Withdraw Requests') }}</a>
                        @endif
                        @if ($canPayments)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.payment_gateways.online_gateways') }}">{{ __('Payments') }}</a>
                        @endif
                    </div>
                </li>
            @endif

            @if ($canAds || $canPopups || $canSubscribers || $canPush)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $growthActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-bullhorn"></i>
                        <span>{{ __('Growth') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown">
                        @if ($canPush)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.user_management.push_notification.settings') }}">{{ __('Push Notifications') }}</a>
                        @endif
                        @if ($canSubscribers)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.user_management.subscribers') }}">{{ __('Subscribers') }}</a>
                        @endif
                        @if ($canAds)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.advertise.advertisements') }}">{{ __('Advertisements') }}</a>
                        @endif
                        @if ($canPopups)
                            <a class="admin-topnav__dropdown-link" href="{{ route('admin.announcement_popups', ['language' => $defaultLang->code]) }}">{{ __('Popups') }}</a>
                        @endif
                    </div>
                </li>
            @endif

            @if ($canHomePage || $canFooter || $canCustomPages || $canBlog || $canFaq || $canMenuBuilder)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $contentActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-layer-group"></i>
                        <span>{{ __('Content') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown admin-topnav__dropdown--wide">
                        <div class="admin-topnav__dropdown-grid">
                            @if ($canHomePage || $canFooter)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Website') }}</div>
                                    @if ($canHomePage)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.home_page.hero_section', ['language' => $defaultLang->code]) }}">{{ __('Website Content') }}</a>
                                    @endif
                                    @if ($canFooter)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.footer.content', ['language' => $defaultLang->code]) }}">{{ __('Footer') }}</a>
                                    @endif
                                </div>
                            @endif
                            @if ($canCustomPages || $canMenuBuilder)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Pages') }}</div>
                                    @if ($canCustomPages)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.custom_pages', ['language' => $defaultLang->code]) }}">{{ __('Custom Pages') }}</a>
                                    @endif
                                    @if ($canMenuBuilder)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.menu_builder', ['language' => $defaultLang->code]) }}">{{ __('Menu Builder') }}</a>
                                    @endif
                                </div>
                            @endif
                            @if ($canBlog || $canFaq)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Editorial') }}</div>
                                    @if ($canBlog)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.blog_management.blogs', ['language' => $defaultLang->code]) }}">{{ __('Blog') }}</a>
                                    @endif
                                    @if ($canFaq)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.faq_management', ['language' => $defaultLang->code]) }}">{{ __('FAQ') }}</a>
                                    @endif
                                </div>
                            @endif
                        </div>
                    </div>
                </li>
            @endif

            @if ($canBasicSettings || $canMobileInterface || $canPwa || $canAdmins || $canLanguages)
                <li class="admin-topnav__item dropdown">
                    <a href="#" class="admin-topnav__link dropdown-toggle {{ $systemActive ? 'is-active' : '' }}" data-toggle="dropdown">
                        <i class="fas fa-cog"></i>
                        <span>{{ __('System') }}</span>
                    </a>
                    <div class="dropdown-menu admin-topnav__dropdown admin-topnav__dropdown--wide">
                        <div class="admin-topnav__dropdown-grid">
                            @if ($canBasicSettings || $canMobileInterface || $canPwa)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Platform') }}</div>
                                    @if ($canBasicSettings)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.basic_settings.general_settings') }}">{{ __('System Settings') }}</a>
                                    @endif
                                    @if ($canMobileInterface)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.mobile_interface', ['language' => $defaultLang->code]) }}">{{ __('App Settings') }}</a>
                                    @endif
                                    @if ($canPwa)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.pwa.scanner') }}">{{ __('PWA Settings') }}</a>
                                    @endif
                                </div>
                            @endif
                            @if ($canAdmins || $canLanguages)
                                <div class="admin-topnav__dropdown-group">
                                    <div class="admin-topnav__dropdown-title">{{ __('Administration') }}</div>
                                    @if ($canAdmins)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.admin_management.registered_admins') }}">{{ __('Admins') }}</a>
                                    @endif
                                    @if ($canLanguages)
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.language_management') }}">{{ __('Languages') }}</a>
                                        <a class="admin-topnav__dropdown-link" href="{{ route('admin.edit_admin_keywords') }}">{{ __('Admin Keywords') }}</a>
                                    @endif
                                </div>
                            @endif
                        </div>
                    </div>
                </li>
            @endif
        </ul>
    </div>
</div>
