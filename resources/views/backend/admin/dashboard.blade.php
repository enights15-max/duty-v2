@extends('backend.layout')

@section('style')
  <style>
    .admin-dash {
      --dash-bg: linear-gradient(145deg, #f8f1ee 0%, #f4ebe7 55%, #fffaf7 100%);
      --dash-surface: rgba(255, 255, 255, 0.9);
      --dash-surface-strong: #ffffff;
      --dash-ink: #16121a;
      --dash-muted: #7b7280;
      --dash-border: rgba(22, 18, 26, 0.08);
      --dash-shadow: 0 18px 45px rgba(17, 10, 14, 0.09);
      --dash-shadow-soft: 0 14px 32px rgba(17, 10, 14, 0.06);
      --dash-primary: #c1121f;
      --dash-primary-2: #e15562;
      --dash-success: #238a57;
      --dash-warning: #c68500;
      --dash-danger: #d32f2f;
      --dash-dark-panel: linear-gradient(135deg, #160d11 0%, #2b1017 45%, #8a0f18 100%);
      --dash-dark-border: rgba(255, 255, 255, 0.12);
      --dash-grid-line: rgba(255, 255, 255, 0.08);
    }

    body[data-background-color='dark'] .admin-dash {
      --dash-bg: linear-gradient(145deg, #100d13 0%, #151018 55%, #1c141c 100%);
      --dash-surface: rgba(18, 13, 20, 0.9);
      --dash-surface-strong: #17111a;
      --dash-ink: #f5f7ff;
      --dash-muted: #b1a6b4;
      --dash-border: rgba(255, 255, 255, 0.08);
      --dash-shadow: 0 18px 45px rgba(3, 2, 5, 0.35);
      --dash-shadow-soft: 0 14px 32px rgba(3, 2, 5, 0.24);
      --dash-dark-panel: linear-gradient(135deg, #0f0a10 0%, #1b0d13 48%, #6f0c16 100%);
      --dash-dark-border: rgba(255, 255, 255, 0.14);
      --dash-grid-line: rgba(255, 255, 255, 0.06);
    }

    .admin-dash {
      display: grid;
      gap: 24px;
      color: var(--dash-ink);
    }

    .admin-dash__panel,
    .admin-dash__quick-card,
    .admin-dash__chart-card,
    .admin-dash__metric-card {
      border: 1px solid var(--dash-border);
      background: var(--dash-surface);
      backdrop-filter: blur(12px);
      box-shadow: var(--dash-shadow-soft);
    }

    .admin-dash__hero {
      position: relative;
      overflow: hidden;
      padding: 32px;
      border-radius: 30px;
      color: #ffffff;
      background: var(--dash-dark-panel);
      box-shadow: var(--dash-shadow);
    }

    .admin-dash__hero::before,
    .admin-dash__hero::after {
      content: '';
      position: absolute;
      inset: auto;
      pointer-events: none;
    }

    .admin-dash__hero::before {
      top: -160px;
      right: -80px;
      width: 320px;
      height: 320px;
      border-radius: 999px;
      background: radial-gradient(circle, rgba(255, 255, 255, 0.28) 0%, rgba(255, 255, 255, 0) 68%);
    }

    .admin-dash__hero::after {
      bottom: -120px;
      left: -80px;
      width: 280px;
      height: 280px;
      border-radius: 999px;
      background: radial-gradient(circle, rgba(24, 183, 247, 0.35) 0%, rgba(24, 183, 247, 0) 70%);
    }

    .admin-dash__hero-grid {
      position: relative;
      z-index: 1;
      display: grid;
      grid-template-columns: minmax(0, 1.3fr) minmax(320px, 0.9fr);
      gap: 28px;
      align-items: stretch;
    }

    .admin-dash__eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      padding: 8px 14px;
      border: 1px solid var(--dash-dark-border);
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.08);
      font-size: 12px;
      font-weight: 700;
      letter-spacing: 0.18em;
      text-transform: uppercase;
    }

    .admin-dash__hero h1 {
      margin: 18px 0 12px;
      font-size: clamp(2rem, 4vw, 3.45rem);
      line-height: 0.98;
      font-weight: 800;
      color: #ffffff;
    }

    .admin-dash__hero-copy {
      max-width: 720px;
      font-size: 1rem;
      line-height: 1.7;
      color: rgba(255, 255, 255, 0.78);
      margin-bottom: 22px;
    }

    .admin-dash__hero-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-bottom: 24px;
    }

    .admin-dash__hero-button {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      padding: 14px 18px;
      border-radius: 16px;
      font-weight: 700;
      text-decoration: none !important;
      transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
    }

    .admin-dash__hero-button:hover {
      transform: translateY(-2px);
    }

    .admin-dash__hero-button--solid {
      background: #ffffff;
      color: #14213d;
      box-shadow: 0 12px 25px rgba(8, 12, 24, 0.18);
    }

    .admin-dash__hero-button--ghost {
      border: 1px solid var(--dash-dark-border);
      background: rgba(255, 255, 255, 0.06);
      color: #ffffff;
    }

    .admin-dash__hero-flags {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .admin-dash__flag {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 10px 12px;
      border-radius: 14px;
      font-size: 0.92rem;
      font-weight: 700;
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid var(--dash-dark-border);
      color: rgba(255, 255, 255, 0.92);
    }

    .admin-dash__flag i {
      font-size: 0.88rem;
    }

    .admin-dash__hero-side {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 14px;
      align-content: start;
    }

    .admin-dash__hero-stat {
      min-height: 134px;
      padding: 18px;
      border-radius: 22px;
      background:
        linear-gradient(180deg, rgba(255, 255, 255, 0.11) 0%, rgba(255, 255, 255, 0.05) 100%),
        linear-gradient(145deg, rgba(255, 255, 255, 0.07) 0%, rgba(255, 255, 255, 0.03) 100%);
      border: 1px solid var(--dash-dark-border);
      backdrop-filter: blur(12px);
      position: relative;
      overflow: hidden;
    }

    .admin-dash__hero-stat::after {
      content: '';
      position: absolute;
      inset: 0;
      background-image: linear-gradient(var(--dash-grid-line) 1px, transparent 1px),
        linear-gradient(90deg, var(--dash-grid-line) 1px, transparent 1px);
      background-size: 18px 18px;
      opacity: 0.35;
      mask-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.35), transparent 85%);
    }

    .admin-dash__hero-stat-label,
    .admin-dash__metric-label,
    .admin-dash__section-label {
      position: relative;
      z-index: 1;
      display: block;
      margin-bottom: 10px;
      font-size: 0.74rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.16em;
      color: rgba(255, 255, 255, 0.68);
    }

    .admin-dash__hero-stat-value {
      position: relative;
      z-index: 1;
      display: block;
      font-size: clamp(1.35rem, 3vw, 2.2rem);
      font-weight: 800;
      color: #ffffff;
      line-height: 1.05;
    }

    .admin-dash__hero-stat-meta {
      position: relative;
      z-index: 1;
      margin-top: 12px;
      color: rgba(255, 255, 255, 0.72);
      font-size: 0.92rem;
      line-height: 1.45;
    }

    .admin-dash__section {
      display: grid;
      gap: 16px;
    }

    .admin-dash__section-head {
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      gap: 16px;
    }

    .admin-dash__section-title {
      margin: 6px 0 0;
      font-size: clamp(1.45rem, 2vw, 1.95rem);
      line-height: 1.1;
      font-weight: 800;
      color: var(--dash-ink);
    }

    .admin-dash__section-copy {
      margin: 8px 0 0;
      color: var(--dash-muted);
      max-width: 720px;
      line-height: 1.65;
    }

    .admin-dash__summary-strip {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      justify-content: flex-end;
    }

    .admin-dash__summary-chip {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 10px 12px;
      border-radius: 14px;
      background: var(--dash-surface);
      border: 1px solid var(--dash-border);
      color: var(--dash-muted);
      font-size: 0.92rem;
      font-weight: 700;
      box-shadow: var(--dash-shadow-soft);
    }

    .admin-dash__summary-chip strong {
      color: var(--dash-ink);
      font-weight: 800;
    }

    .admin-dash__metrics-grid {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 16px;
    }

    .admin-dash__metrics-grid--secondary {
      grid-template-columns: repeat(4, minmax(0, 1fr));
    }

    .admin-dash__metric-card {
      position: relative;
      overflow: hidden;
      padding: 20px;
      border-radius: 24px;
    }

    .admin-dash__metric-card::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(135deg, rgba(39, 93, 246, 0.08) 0%, rgba(24, 183, 247, 0.03) 60%, transparent 100%);
      pointer-events: none;
    }

    .admin-dash__metric-value {
      position: relative;
      z-index: 1;
      display: block;
      margin: 0;
      font-size: clamp(1.35rem, 2vw, 2.15rem);
      line-height: 1.08;
      font-weight: 800;
      color: var(--dash-ink);
    }

    .admin-dash__metric-meta {
      position: relative;
      z-index: 1;
      margin-top: 8px;
      color: var(--dash-muted);
      line-height: 1.55;
      min-height: 48px;
    }

    .admin-dash__metric-foot {
      position: relative;
      z-index: 1;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      margin-top: 14px;
      padding: 8px 10px;
      border-radius: 999px;
      background: rgba(39, 93, 246, 0.08);
      color: var(--dash-primary);
      font-size: 0.84rem;
      font-weight: 700;
    }

    .admin-dash__quick-grid {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 16px;
    }

    .admin-dash__quick-card {
      position: relative;
      display: flex;
      flex-direction: column;
      gap: 14px;
      min-height: 180px;
      padding: 18px;
      border-radius: 24px;
      text-decoration: none !important;
      color: inherit;
      overflow: hidden;
      transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
    }

    .admin-dash__quick-card::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(155deg, rgba(39, 93, 246, 0.08) 0%, rgba(24, 183, 247, 0.02) 56%, transparent 100%);
      pointer-events: none;
    }

    .admin-dash__quick-card:hover {
      transform: translateY(-4px);
      box-shadow: var(--dash-shadow);
      border-color: rgba(39, 93, 246, 0.18);
    }

    .admin-dash__quick-top,
    .admin-dash__quick-bottom {
      position: relative;
      z-index: 1;
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 12px;
    }

    .admin-dash__quick-icon {
      width: 48px;
      height: 48px;
      border-radius: 16px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, rgba(39, 93, 246, 0.12), rgba(24, 183, 247, 0.18));
      color: var(--dash-primary);
      font-size: 1.2rem;
      flex-shrink: 0;
    }

    .admin-dash__quick-count {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 42px;
      height: 32px;
      padding: 0 10px;
      border-radius: 999px;
      background: rgba(20, 33, 61, 0.06);
      color: var(--dash-ink);
      font-size: 0.88rem;
      font-weight: 800;
    }

    .admin-dash__quick-title {
      position: relative;
      z-index: 1;
      margin: 0;
      font-size: 1.2rem;
      line-height: 1.2;
      font-weight: 800;
      color: var(--dash-ink);
    }

    .admin-dash__quick-copy {
      position: relative;
      z-index: 1;
      margin: 0;
      color: var(--dash-muted);
      line-height: 1.6;
      min-height: 72px;
    }

    .admin-dash__quick-link {
      position: relative;
      z-index: 1;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      font-size: 0.92rem;
      font-weight: 800;
      color: var(--dash-primary);
    }

    .admin-dash__charts {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 18px;
    }

    .admin-dash__chart-card {
      border-radius: 28px;
      padding: 22px 22px 18px;
      min-height: 360px;
      display: grid;
      grid-template-rows: auto auto 1fr;
      gap: 12px;
    }

    .admin-dash__chart-heading {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 16px;
    }

    .admin-dash__chart-title {
      margin: 6px 0 0;
      font-size: 1.2rem;
      font-weight: 800;
      color: var(--dash-ink);
    }

    .admin-dash__chart-copy {
      color: var(--dash-muted);
      line-height: 1.6;
      margin: 0;
    }

    .admin-dash__chart-kpi {
      text-align: right;
      min-width: 110px;
    }

    .admin-dash__chart-kpi strong {
      display: block;
      font-size: 1.55rem;
      line-height: 1;
      color: var(--dash-ink);
      font-weight: 800;
    }

    .admin-dash__chart-kpi span {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      margin-top: 8px;
      font-size: 0.84rem;
      font-weight: 700;
      color: var(--dash-muted);
    }

    .admin-dash__chart-frame {
      position: relative;
      min-height: 250px;
      border-radius: 22px;
      background: linear-gradient(180deg, rgba(39, 93, 246, 0.04) 0%, rgba(39, 93, 246, 0.01) 100%);
      border: 1px solid var(--dash-border);
      padding: 10px;
    }

    .admin-dash__chart-frame canvas {
      width: 100% !important;
      height: 100% !important;
    }

    .admin-dash__empty {
      padding: 28px;
      border-radius: 24px;
      text-align: center;
      border: 1px dashed var(--dash-border);
      color: var(--dash-muted);
      background: var(--dash-surface);
    }

    @media (max-width: 1399px) {
      .admin-dash__metrics-grid,
      .admin-dash__metrics-grid--secondary,
      .admin-dash__quick-grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
    }

    @media (max-width: 1199px) {
      .admin-dash__hero-grid,
      .admin-dash__charts {
        grid-template-columns: 1fr;
      }

      .admin-dash__hero-side {
        grid-template-columns: repeat(4, minmax(0, 1fr));
      }

      .admin-dash__quick-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    @media (max-width: 991px) {
      .admin-dash__hero {
        padding: 24px;
      }

      .admin-dash__metrics-grid,
      .admin-dash__metrics-grid--secondary,
      .admin-dash__hero-side {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .admin-dash__section-head {
        flex-direction: column;
        align-items: flex-start;
      }

      .admin-dash__summary-strip {
        justify-content: flex-start;
      }
    }

    @media (max-width: 767px) {
      .admin-dash__metrics-grid,
      .admin-dash__metrics-grid--secondary,
      .admin-dash__quick-grid,
      .admin-dash__hero-side {
        grid-template-columns: 1fr;
      }

      .admin-dash__hero-actions {
        flex-direction: column;
        align-items: stretch;
      }

      .admin-dash__hero-button {
        justify-content: center;
      }

      .admin-dash__chart-heading {
        flex-direction: column;
      }

      .admin-dash__chart-kpi {
        text-align: left;
      }
    }
  </style>
@endsection

@section('content')
  <div class="mt-2 mb-4">
    <h2 class="{{ $settings->admin_theme_version == 'light' ? 'text-dark' : 'text-light' }} pb-2">{{ __('Welcome back,') }}
      {{ Auth::guard('admin')->user()->first_name . ' ' . Auth::guard('admin')->user()->last_name . '!' }}</h2>
  </div>

  {{-- dashboard information start --}}
  @php
    $rolePermissions = [];
    if (!is_null($roleInfo)) {
        $rolePermissions = json_decode($roleInfo->permissions) ?? [];
    }

    $can = function ($permission) use ($roleInfo, $rolePermissions) {
        return is_null($roleInfo) || (!empty($rolePermissions) && in_array($permission, $rolePermissions));
    };
    $canAny = function (array $permissions) use ($roleInfo, $rolePermissions) {
        return is_null($roleInfo) || (!empty($rolePermissions) && count(array_intersect($permissions, $rolePermissions)) > 0);
    };

    $canManageCustomers = $can('Customer Management');
    $canManageIdentities = is_null($roleInfo) || (!empty($rolePermissions) && (in_array('Identity Management', $rolePermissions) || in_array('Customer Management', $rolePermissions)));
    $canModerateReviews = $canManageIdentities;
    $canEconomy = $canAny(['Event Bookings', 'Event Booking Economy']);
    $canFeePolicies = $canAny(['Event Bookings', 'Event Booking Fee Policies']);
    $dashboardLanguageCode = isset($defaultLang) && !empty($defaultLang->code) ? $defaultLang->code : 'en';

    $money = function ($value) use ($settings) {
        $amount = number_format((float) $value, 2);
        return $settings->base_currency_symbol_position == 'left'
            ? $settings->base_currency_symbol . $amount
            : $amount . $settings->base_currency_symbol;
    };

    $heroStats = collect([
        [
            'visible' => $can('Lifetime Earning'),
            'label' => __('Lifetime Revenue'),
            'value' => $money(data_get($total_earning, 'total_revenue', 0)),
            'meta' => __('All-time event + product intake tracked by the platform.'),
        ],
        [
            'visible' => $can('Total Profit'),
            'label' => __('Platform Profit'),
            'value' => $money(data_get($total_earning, 'total_earning', 0)),
            'meta' => __('Net earnings retained after operating flows.'),
        ],
        [
            'visible' => $can('Event Bookings'),
            'label' => __('Active Reservations'),
            'value' => number_format((int) $activeReservations),
            'meta' => number_format((int) $reservationsDue24h) . __(' due in <24h / ') . number_format((int) $reservationsDue2h) . __(' due in <2h'),
        ],
        [
            'visible' => $canManageIdentities || $canModerateReviews,
            'label' => __('Moderation Queue'),
            'value' => number_format((int) $pendingIdentities + (int) $pendingReviews),
            'meta' => number_format((int) $pendingIdentities) . __(' identities pending / ') . number_format((int) $pendingReviews) . __(' reviews pending'),
        ],
    ])->where('visible', true)->values();

    $heroFlags = collect([
        $can('Event Bookings') && $reservationsDue2h > 0
            ? ['icon' => 'fas fa-bell', 'text' => number_format((int) $reservationsDue2h) . ' ' . __('reservations are due in under 2 hours')]
            : null,
        $canManageIdentities && $pendingIdentities > 0
            ? ['icon' => 'fas fa-id-card', 'text' => number_format((int) $pendingIdentities) . ' ' . __('professional identities need review')]
            : null,
        $canModerateReviews && $pendingReviews > 0
            ? ['icon' => 'fas fa-comments', 'text' => number_format((int) $pendingReviews) . ' ' . __('community reviews are waiting on moderation')]
            : null,
        $can('Event Bookings') && $activeReservations > 0
            ? ['icon' => 'fas fa-hourglass-half', 'text' => number_format((int) $activeReservations) . ' ' . __('live reservations currently holding inventory')]
            : null,
    ])->filter();

    $primaryMetrics = collect([
        [
            'visible' => $can('Event Management'),
            'label' => __('Event Catalog'),
            'value' => number_format((int) $totalEvents),
            'meta' => __('Published and draft events currently in your system.'),
            'foot' => __('') . number_format((int) $totalEventCategories) . __(' categories'),
        ],
        [
            'visible' => $can('Event Bookings'),
            'label' => __('Event Bookings'),
            'value' => number_format((int) $totalEventBookings),
            'meta' => __('All event booking rows tracked across the platform.'),
            'foot' => __('') . number_format((int) $bookingsThisYear) . __(' completed this year'),
        ],
        [
            'visible' => $can('Shop Management'),
            'label' => __('Shop Orders'),
            'value' => number_format((int) $totalOrders),
            'meta' => __('Product commerce orders recorded in the store flow.'),
            'foot' => __('') . number_format((int) $ordersThisYear) . __(' completed this year'),
        ],
        [
            'visible' => $can('Transaction'),
            'label' => __('Transactions'),
            'value' => number_format((int) $transcation_count),
            'meta' => __('Financial movements logged across platform operations.'),
            'foot' => __('Accounting and payout reference surface'),
        ],
    ])->where('visible', true)->values();

    $secondaryMetrics = collect([
        [
            'visible' => $can('Event Bookings'),
            'label' => __('Reservation Pressure'),
            'value' => number_format((int) $reservationsDue24h),
            'meta' => __('Reservations that need attention within the next 24 hours.'),
            'foot' => number_format((int) $reservationsDue2h) . __(' urgent in <2h'),
        ],
        [
            'visible' => $canManageIdentities,
            'label' => __('Identity Queue'),
            'value' => number_format((int) $pendingIdentities),
            'meta' => __('Professional identities waiting on approval or follow-up.'),
            'foot' => __('Verification and compliance workload'),
        ],
        [
            'visible' => $canModerateReviews,
            'label' => __('Review Queue'),
            'value' => number_format((int) $pendingReviews),
            'meta' => __('Reviews currently waiting on moderation decisions.'),
            'foot' => __('Community health checkpoint'),
        ],
        [
            'visible' => $can('Organizer Mangement'),
            'label' => __('Organizer Network'),
            'value' => number_format((int) $totalOrganizers),
            'meta' => __('Organizer accounts registered and visible to the admin team.'),
            'foot' => __('Supply-side relationship surface'),
        ],
        [
            'visible' => $canManageCustomers,
            'label' => __('Customers'),
            'value' => number_format((int) $totalRegisteredUsers),
            'meta' => __('Registered customer accounts inside the ecosystem.'),
            'foot' => __('Audience base for events and marketplace'),
        ],
        [
            'visible' => $can('Shop Management'),
            'label' => __('Products'),
            'value' => number_format((int) $totalProducts),
            'meta' => __('Products currently available in the commerce catalog.'),
            'foot' => $money($productRevenueThisYear) . __(' shop revenue this year'),
        ],
        [
            'visible' => $can('Blog Management'),
            'label' => __('Editorial'),
            'value' => number_format((int) $totalBlog),
            'meta' => __('Blog entries live in the admin editorial surface.'),
            'foot' => __('Content footprint across marketing pages'),
        ],
        [
            'visible' => $can('Lifetime Earning'),
            'label' => __('Event Revenue This Year'),
            'value' => $money($eventRevenueThisYear),
            'meta' => __('Completed booking intake plus taxes during the current year.'),
            'foot' => __('Live business pulse for events'),
        ],
    ])->where('visible', true)->values();

    $quickActions = collect([
        [
            'visible' => $can('Event Management'),
            'route' => route('admin.event_management.event', ['language' => $dashboardLanguageCode]),
            'icon' => 'fas fa-calendar-alt',
            'title' => __('Event Catalog'),
            'copy' => __('Browse, edit, clone and publish the event lineup without leaving operations.'),
            'count' => number_format((int) $totalEvents),
        ],
        [
            'visible' => $can('Event Bookings'),
            'route' => route('admin.event.booking'),
            'icon' => 'fas fa-ticket-alt',
            'title' => __('Bookings'),
            'copy' => __('Open the booking ledger to review payments, attendees and ticket activity.'),
            'count' => number_format((int) $totalEventBookings),
        ],
        [
            'visible' => $can('Event Bookings'),
            'route' => route('admin.event_reservation.index'),
            'icon' => 'fas fa-hourglass-half',
            'title' => __('Reservations'),
            'copy' => __('Control holds, due windows, conversions and refunds from a single queue.'),
            'count' => number_format((int) $activeReservations),
        ],
        [
            'visible' => $canModerateReviews,
            'route' => route('admin.review_management.index'),
            'icon' => 'fas fa-comment-dots',
            'title' => __('Review Queue'),
            'copy' => __('Moderate community feedback before it becomes public-facing platform signal.'),
            'count' => number_format((int) $pendingReviews),
        ],
        [
            'visible' => $canManageIdentities,
            'route' => route('admin.identity_management.index'),
            'icon' => 'fas fa-id-card',
            'title' => __('Identities'),
            'copy' => __('Approve or reject professional identity profiles and clear verification backlog.'),
            'count' => number_format((int) $pendingIdentities),
        ],
        [
            'visible' => $can('Organizer Mangement'),
            'route' => route('admin.organizer_management.registered_organizer', ['language' => $dashboardLanguageCode]),
            'icon' => 'fas fa-chalkboard-teacher',
            'title' => __('Organizers'),
            'copy' => __('Manage organizer accounts, approvals and ecosystem supply-side relationships.'),
            'count' => number_format((int) $totalOrganizers),
        ],
        [
            'visible' => $canManageCustomers,
            'route' => route('admin.organizer_management.registered_customer'),
            'icon' => 'fas fa-user-friends',
            'title' => __('Customers'),
            'copy' => __('Jump into customer records, support flows and audience-level account actions.'),
            'count' => number_format((int) $totalRegisteredUsers),
        ],
        [
            'visible' => $canManageCustomers,
            'route' => route('admin.wallet_management.wallets'),
            'icon' => 'fas fa-wallet',
            'title' => __('Wallets'),
            'copy' => __('Inspect balances, ledgers and payout pressure across customer wallets.'),
            'count' => null,
        ],
        [
            'visible' => $can('Shop Management'),
            'route' => route('admin.product.order'),
            'icon' => 'fas fa-box-open',
            'title' => __('Store Orders'),
            'copy' => __('Handle product order operations and review fulfillment-side commerce.'),
            'count' => number_format((int) $totalOrders),
        ],
        [
            'visible' => $can('Blackmarket'),
            'route' => route('admin.blackmarket.tickets'),
            'icon' => 'fas fa-retweet',
            'title' => __('Blackmarket'),
            'copy' => __('Review resale ticket inventory and marketplace-specific controls.'),
            'count' => null,
        ],
        [
            'visible' => $canFeePolicies,
            'route' => route('admin.event_booking.settings.fee_policies'),
            'icon' => 'fas fa-percent',
            'title' => __('Tax & Fees'),
            'copy' => __('Adjust booking tax, commissions and marketplace fee policy.'),
            'count' => null,
        ],
        [
            'visible' => $canEconomy,
            'route' => route('admin.event_booking.economy'),
            'icon' => 'fas fa-coins',
            'title' => __('Economy'),
            'copy' => __('Track Duty revenue by operation, event, organizer and venue.'),
            'count' => null,
        ],
        [
            'visible' => $can('Lifetime Earning'),
            'route' => route('admin.monthly_earning'),
            'icon' => 'fas fa-chart-line',
            'title' => __('Earnings'),
            'copy' => __('Open the deeper earnings report when you need trend-level reading.'),
            'count' => null,
        ],
    ])->where('visible', true)->values();

    $summaryChips = collect([
        $can('Event Bookings') ? ['label' => __('Reservations total'), 'value' => number_format((int) $totalReservations)] : null,
        $canManageIdentities ? ['label' => __('Identity queue'), 'value' => number_format((int) $pendingIdentities)] : null,
        $canModerateReviews ? ['label' => __('Review queue'), 'value' => number_format((int) $pendingReviews)] : null,
        $can('Shop Management') ? ['label' => __('Orders this year'), 'value' => number_format((int) $ordersThisYear)] : null,
    ])->filter();
  @endphp

  <div class="row dashboard-items">

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Lifetime Earning', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.monthly_earning') }}">
          <div class="card card-stats card-info card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-sack-dollar"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Life Time Earning') }}</p>
                    <h4 class="card-title">
                      {{ $settings->base_currency_symbol_position == 'left' ? $settings->base_currency_symbol : '' }}
                      {{ $total_earning->total_revenue }}
                      {{ $settings->base_currency_symbol_position == 'right' ? $settings->base_currency_symbol : '' }}

                    </h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Total Profit', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.monthly_profit') }}">
          <div class="card card-stats card-earning card-round text-white ">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-usd-square"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category text-white">{{ __('Total Profit') }}</p>
                    <h4 class="card-title text-white">
                      {{ $settings->base_currency_symbol_position == 'left' ? $settings->base_currency_symbol : '' }}
                      {{ $total_earning->total_earning }}
                      {{ $settings->base_currency_symbol_position == 'right' ? $settings->base_currency_symbol : '' }}

                    </h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif
    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.event_management.event', ['language' => $defaultLang->code]) }}">
          <div class="card card-stats card-success card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-calendar-alt"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Events') }}</p>
                    <h4 class="card-title">{{ $totalEvents }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.event_management.categories', ['language' => $defaultLang->code]) }}">
          <div class="card card-stats card-danger card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fal fa-sitemap"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Event Categories') }}</p>
                    <h4 class="card-title">{{ $totalEventCategories }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif


    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Transaction', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.transcation') }}">
          <div class="card card-stats card-secondary card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fal fa-exchange-alt"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Total Transcation') }}</p>
                    <h4 class="card-title">{{ $transcation_count }}
                    </h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Bookings', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.event.booking') }}">
          <div class="card card-stats card-primary card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-hotel"></i>
                  </div>
                </div>
                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Total Event Booking') }}</p>
                    <h4 class="card-title">{{ $totalEventBookings }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Organizer Mangement', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.organizer_management.registered_organizer', ['language' => $defaultLang->code]) }}">
          <div class="card card-stats card-warning card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fal fa-chalkboard-teacher"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Organizers') }}</p>
                    <h4 class="card-title">{{ $totalOrganizers }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Blog Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.blog_management.blogs', ['language' => $defaultLang->code]) }}">
          <div class="card card-stats card-info card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fal fa-blog"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Blog') }}</p>
                    <h4 class="card-title">{{ $totalBlog }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Customer Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.organizer_management.registered_customer') }}">
          <div class="card card-stats card-secondary card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="la flaticon-users"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Registered Customers') }}</p>
                    <h4 class="card-title">{{ $totalRegisteredUsers }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Shop Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.shop_management.products', ['language' => $defaultLang->code]) }}">
          <div class="card card-stats card-danger card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-shopping-basket"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Products') }}</p>
                    <h4 class="card-title">{{ $totalProducts }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif
    @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Shop Management', $rolePermissions)))
      <div class="col-sm-6 col-md-4">
        <a href="{{ route('admin.product.order') }}">
          <div class="card card-stats card-success card-round">
            <div class="card-body">
              <div class="row">
                <div class="col-5">
                  <div class="icon-big text-center">
                    <i class="fas fa-receipt"></i>
                  </div>
                </div>

                <div class="col-7 col-stats">
                  <div class="numbers">
                    <p class="card-category">{{ __('Orders') }}</p>
                    <h4 class="card-title">{{ $totalOrders }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    @endif

  </div>

  @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Event Management', $rolePermissions)))
    <div class="row">
      <div class="col-lg-6">
        <div class="card">
          <div class="card-header">
            <div class="card-title">{{ __('Event Booking Monthly Earning') }} ({{ date('Y') }})</div>
          </div>

          <div class="card-body">
            <div class="chart-container">
              <canvas id="incomeChart"></canvas>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-6">
        <div class="card">
          <div class="card-header">
            <div class="card-title">{{ __('Monthly Event Bookings') }} ({{ date('Y') }})</div>
          </div>

          <div class="card-body">
            <div class="chart-container">
              <canvas id="TotalEventBookingChart"></canvas>
            </div>
          </div>
        </div>
      </div>
  @endif

  {{-- product chart --}}
  @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Shop Management', $rolePermissions)))
    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Product Order Monthly Income') }} ({{ date('Y') }})</div>
        </div>

        <div class="card-body">
          <div class="chart-container">
            <canvas id="ProductOrderChart"></canvas>
          </div>
        </div>
      </div>
    </div>
  @endif

  @if (is_null($roleInfo) || (!empty($rolePermissions) && in_array('Shop Management', $rolePermissions)))
    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <div class="card-title">{{ __('Monthly Product Orders') }} ({{ date('Y') }})</div>
        </div>

        <div class="card-body">
          <div class="chart-container">
            <canvas id="TotalProductOrderChart"></canvas>
          </div>
        </div>
      </div>
    </div>
  @endif
  </div>
  {{-- dashboard information end --}}
@endsection

@section('script')
  {{-- chart js --}}
  <script type="text/javascript" src="{{ asset('assets/admin/js/chart.min.js') }}"></script>

  <script>
    "use strict";
    const monthArr = @php echo json_encode($eventMonths) @endphp;
    const incomeArr = @php echo json_encode($eventIncomes) @endphp;
    const totalBookings = @php echo json_encode($totalBookings) @endphp;

    const productIncome = @php echo json_encode($productIncome) @endphp;
    const totalOders = @php echo json_encode($totalOders) @endphp;
  </script>

  <script type="text/javascript" src="{{ asset('assets/admin/js/chart-init.js') }}"></script>
@endsection
