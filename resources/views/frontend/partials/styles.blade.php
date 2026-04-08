<!-- Google Fonts -->
<link
<<<<<<< Updated upstream
  href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Roboto:wght@300;400;500;700&display=swap"
=======
  href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Manrope:wght@400;500;600;700;800&display=swap"
>>>>>>> Stashed changes
  rel="stylesheet">
<!-- FlatIcon Font -->
<link rel="stylesheet" href="{{ asset('assets/front/css/flaticon.css') }}">
<!-- Font Awesome -->
<link rel="stylesheet" href="{{ asset('assets/front/css/fontawesome.5.9.0.min.css') }}">
<!-- Bootstrap css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/bootstrap.4.5.3.min.css') }}">
<!-- Magnific Popup -->
<link rel="stylesheet" href="{{ asset('assets/front/css/magnific-popup.min.css') }}">
<!-- Slick Slider -->
<link rel="stylesheet" href="{{ asset('assets/front/css/slick.css') }}">
<!-- Swiper CSS -->
<link rel="stylesheet" href="{{ asset('assets/front/css/swiper-bundle.min.css') }}">
<!-- jQuery UI CSS -->
<link rel="stylesheet" href="{{ asset('assets/front/css/jquery-ui.min.css') }}">
<!-- Padding Margin -->
<link rel="stylesheet" href="{{ asset('assets/front/css/spacing.min.css') }}">
<!-- Menu css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/menu.css') }}">
<!-- datatables css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/datatables.min.css') }}">
<link rel="stylesheet" href="{{ asset('assets/front/css/dataTables.bootstrap4.css') }}">
<!-- Select2 -->
<link rel="stylesheet" href="{{ asset('assets/front/css/select2.min.css') }}">
<!-- nice-select -->
<link rel="stylesheet" href="{{ asset('assets/front/css/nice-select.css') }}">
<!-- dashboard css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/dashboard.css') }}">
<!-- Menu css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/menu.css') }}">
<!-- Main css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/style.css') }}">
<!-- Responsive css -->
<link rel="stylesheet" href="{{ asset('assets/front/css/responsive.css') }}">
<link rel="stylesheet" href="{{ asset('assets/front/css/daterangepicker.css') }}" />
<link rel="stylesheet" href="{{ asset('assets/front/css/toastr.css') }}">
<link rel="stylesheet" href="{{ asset('assets/front/css/organizer.css') }}">
@if ($currentLanguageInfo->direction == 1)
  {{-- right-to-left css --}}
  <link rel="stylesheet" href="{{ asset('assets/front/css/rtl-style.css') }}">

  {{-- right-to-left-responsive css --}}
  <link rel="stylesheet" href="{{ asset('assets/front/css/rtl-responsive.css') }}">
@endif
<style>
  :root {
<<<<<<< Updated upstream
    scroll-behavior: auto;
    --base-color: #454545;
    --heading-color: #030A15;
    --primary-color: #{{ $basicInfo->primary_color }};
    --light-color: #F7F7F7;
    --base-font: 'Roboto', sans-serif;
    --heading-font: 'Plus Jakarta Sans', sans-serif;
=======
    scroll-behavior: smooth;
    --base-color: #8C25F4;
    --primary-color: #8C25F4;
    --accent-color: #FFD700;
    --bg-dark: #191022;
    --bg-deep: #120a1c;
    --bg-surface: rgba(255, 255, 255, 0.04);
    --bg-surface-strong: rgba(255, 255, 255, 0.06);
    --glass-border: rgba(255, 255, 255, 0.1);
    --glass-border-strong: rgba(255, 255, 255, 0.14);
    --text-primary: #FFFFFF;
    --text-secondary: rgba(255, 255, 255, 0.72);
    --text-muted: rgba(228, 220, 247, 0.56);
    --surface-shadow: 0 24px 80px rgba(8, 3, 14, 0.24);
    --surface-shadow-soft: 0 16px 40px rgba(8, 3, 14, 0.16);
    --base-font: 'Manrope', sans-serif;
    --heading-font: 'Outfit', sans-serif;
    --inter: 'Manrope', sans-serif;
    --pjs: 'Outfit', sans-serif;
    --heading-color: #FFFFFF !important;
>>>>>>> Stashed changes
  }

  .overlay:before {
    position: absolute;
    content: '';
    height: 100%;
    width: 100%;
    left: 0;
    top: 0;
    z-index: -1;
    opacity: {{ $basicInfo->breadcrumb_overlay_opacity }};
    background: #{{ $basicInfo->breadcrumb_overlay_color }};
  }
<<<<<<< Updated upstream
=======

  /* Dark Theme Core Resets */
  body {
    background:
      radial-gradient(circle at top left, rgba(140, 37, 244, 0.16), transparent 26%),
      radial-gradient(circle at 82% 8%, rgba(255, 207, 90, 0.08), transparent 18%),
      linear-gradient(180deg, #1b1227 0%, #140d1f 54%, #191022 100%) !important;
    color: var(--text-primary) !important;
    font-family: var(--inter) !important;
  }

  ::selection {
    background: rgba(140, 37, 244, 0.32);
    color: #fff;
  }

  a {
    color: #d8b6ff;
    transition: color 0.25s ease, opacity 0.25s ease;
  }

  a:hover {
    color: #fff;
  }

  h1,
  h2,
  h3,
  h4,
  h5,
  h6 {
    color: var(--text-primary) !important;
    font-family: var(--pjs) !important;
  }

  .section-title h2 {
    color: var(--text-primary) !important;
  }

  .section-title p {
    color: var(--text-secondary) !important;
  }

  .page-wrapper {
    position: relative;
    overflow-x: clip;
    overflow-y: visible;
  }

  .page-wrapper::before {
    position: fixed;
    inset: 0;
    content: '';
    pointer-events: none;
    background-image:
      linear-gradient(rgba(255, 255, 255, 0.025) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.025) 1px, transparent 1px);
    background-size: 38px 38px;
    mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.42), transparent 88%);
    opacity: 0.16;
    z-index: 0;
  }

  .page-wrapper > * {
    position: relative;
    z-index: 1;
  }

  .theme-btn,
  .btn,
  button.theme-btn {
    border-radius: 18px;
    font-family: var(--pjs);
    font-weight: 800;
    letter-spacing: 0.01em;
  }

  .theme-btn {
    background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
    border: 0;
    box-shadow: 0 18px 34px rgba(140, 37, 244, 0.22);
  }

  .theme-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 20px 38px rgba(140, 37, 244, 0.3);
  }

  .form-control,
  .nice-select,
  select,
  input,
  textarea {
    border-radius: 18px !important;
  }

  .alert {
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(10px);
  }

  .main-header.web-site-header {
    position: sticky;
    top: 0;
    z-index: 1045;
    padding-top: 12px;
  }

  .main-header.web-site-header .header-upper {
    padding-top: 0 !important;
    padding-bottom: 12px !important;
  }

  .main-header .logo img,
  .main-header .logo-mobile img {
    max-height: 46px;
    width: auto;
    max-width: 156px;
    object-fit: contain;
    display: block;
  }

  .main-header.glass-nav,
  .main-header.glass-nav .header-upper,
  .main-header.fixed-header .header-upper,
  .fixed-header .header-upper {
    background: transparent !important;
    box-shadow: none !important;
  }

  .main-header.glass-nav.fixed-header,
  .main-header.fixed-header,
  .main-header.web-site-header.sticky,
  .main-header.web-site-header.fixed-header {
    background: linear-gradient(180deg, rgba(12, 8, 18, 0.94), rgba(12, 8, 18, 0.76)) !important;
    backdrop-filter: blur(18px);
    -webkit-backdrop-filter: blur(18px);
    box-shadow: 0 14px 36px rgba(5, 2, 9, 0.22);
  }

  .web-nav-shell {
    display: grid;
    grid-template-columns: max-content minmax(0, 1fr);
    align-items: center;
    gap: 28px;
    padding: 12px 18px;
    border-radius: 28px;
    background: rgba(15, 9, 22, 0.72);
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--surface-shadow-soft);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
  }

  .web-brand {
    display: inline-flex;
    align-items: center;
    gap: 0;
    min-width: fit-content;
  }

  .web-brand__copy {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .web-brand__title {
    color: #fff;
    font-family: var(--pjs);
    font-size: 16px;
    font-weight: 800;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .web-brand__subtitle {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    line-height: 1;
  }

  .web-nav-shell .nav-outer {
    flex: 1 1 auto;
    min-width: 0;
  }

  .web-nav-shell .main-menu {
    width: 100%;
  }

  .web-nav-shell .main-menu .navbar-collapse {
    display: grid !important;
    grid-template-columns: max-content minmax(0, 1fr);
    align-items: center;
    gap: 18px;
  }

  .web-nav-shell .navigation {
    display: flex;
    align-items: center;
    flex-wrap: nowrap;
    gap: 10px;
    min-width: 0;
    margin: 0;
  }

  .web-nav-shell .navigation > li {
    margin: 0;
    float: none;
  }

  .web-nav-shell .navigation > li > a {
    display: inline-flex;
    align-items: center;
    min-height: 42px;
    padding: 0 14px;
    margin-left: 0 !important;
    border-radius: 999px;
    color: rgba(255, 255, 255, 0.84);
    font-size: 14px;
    font-weight: 700;
  }

  .web-nav-shell .navigation > li:hover > a,
  .web-nav-shell .navigation > li.current > a {
    background: rgba(255, 255, 255, 0.05);
    color: #fff;
  }

  .web-nav-shell .navigation li ul {
    border-radius: 22px;
    background: rgba(17, 11, 26, 0.98);
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--surface-shadow);
    padding: 10px;
  }

  .web-nav-shell .navigation li ul li a {
    border-radius: 14px;
    color: rgba(255, 255, 255, 0.82);
    font-weight: 600;
  }

  .web-nav-shell .navigation li ul li a:hover {
    background: rgba(140, 37, 244, 0.14);
    color: #fff;
  }

  .web-action-cluster {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    flex-wrap: nowrap;
    gap: 10px;
    margin-left: auto;
    min-width: 0;
  }

  .web-language {
    min-width: 132px;
  }

  .web-language .form-control,
  .web-account-btn {
    min-height: 46px;
    border: 1px solid rgba(255, 255, 255, 0.08) !important;
    background: rgba(255, 255, 255, 0.04) !important;
    color: #fff !important;
    border-radius: 999px !important;
    font-weight: 700;
  }

  .web-account-btn {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 0 16px;
    white-space: nowrap;
  }

  .web-account-btn__icon {
    width: 28px;
    height: 28px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 999px;
    background: rgba(140, 37, 244, 0.2);
    color: #fff;
    font-size: 12px;
  }

  .web-account-btn:hover,
  .web-account-btn:focus {
    color: #fff !important;
  }

  .web-account-btn--accent {
    background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%) !important;
    border-color: rgba(140, 37, 244, 0.3) !important;
    box-shadow: 0 16px 30px rgba(140, 37, 244, 0.24);
  }

  .web-account-btn--accent .web-account-btn__icon {
    background: rgba(255, 255, 255, 0.16);
  }

  .web-nav-shell--compact {
    justify-content: space-between;
    gap: 18px;
  }

  .web-compact-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: flex-end;
    gap: 10px;
  }

  .web-account-btn--compact-link {
    background: rgba(255, 255, 255, 0.03) !important;
  }

  .web-language--compact {
    min-width: 118px;
  }

  .web-unified-body--compact .page-banner {
    padding-top: 74px !important;
    padding-bottom: 36px !important;
    background: transparent !important;
  }

  .web-unified-body--compact .page-banner.overlay:before {
    opacity: 0 !important;
  }

  .web-unified-body--compact .banner-inner {
    max-width: 880px;
    margin: 0 auto;
    padding: 32px 36px;
    border-radius: 30px;
    background: linear-gradient(180deg, rgba(30, 19, 43, 0.94), rgba(17, 11, 25, 0.94));
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--surface-shadow);
  }

  .web-unified-body--compact .page-title {
    margin-bottom: 12px;
    font-size: clamp(2.2rem, 4vw, 3.4rem);
    line-height: 1;
    letter-spacing: -0.04em;
  }

  .web-unified-body--compact .breadcrumb {
    margin-bottom: 0;
    padding: 0;
    background: transparent;
  }

  .web-unified-body--compact .breadcrumb-item,
  .web-unified-body--compact .breadcrumb-item a {
    color: var(--text-secondary);
  }

  .web-unified-body--compact .login-area {
    padding-top: 28px !important;
    padding-bottom: 108px !important;
  }

  .web-unified-body--compact .login-form {
    padding: 32px;
    border-radius: 32px;
    background: linear-gradient(180deg, rgba(28, 18, 40, 0.96), rgba(17, 11, 25, 0.96));
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--surface-shadow);
  }

  .web-unified-body--compact .login-form label {
    display: block;
    margin-bottom: 10px;
    color: #fff;
    font-size: 14px;
    font-weight: 700;
  }

  .web-unified-body--compact .login-form .form-control {
    min-height: 58px;
    border-radius: 18px !important;
    background: rgba(255, 255, 255, 0.08) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    color: #fff !important;
    box-shadow: none !important;
  }

  .web-unified-body--compact .login-form .form-control::placeholder {
    color: rgba(255, 255, 255, 0.44);
  }

  .web-unified-body--compact .login-form .theme-btn {
    min-height: 54px;
    padding-inline: 28px;
    border-radius: 18px;
  }

  .web-unified-body--compact .login-form .form-group.mt-3 {
    gap: 14px;
    padding-top: 14px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
    flex-wrap: wrap;
  }

  .web-unified-body--compact .login-form .form-group.mt-3 p,
  .web-unified-body--compact .login-form .form-group.mt-3 a {
    color: var(--text-secondary);
  }

  .web-unified-body--compact .login-form .form-group.mt-3 a:hover {
    color: #fff;
  }

  .web-nav-shell .dropdown-menu {
    background: rgba(17, 11, 26, 0.98);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 20px;
    box-shadow: var(--surface-shadow);
    padding: 10px;
    overflow: hidden;
  }

  .web-nav-shell .dropdown-item {
    border-radius: 12px;
    color: rgba(255, 255, 255, 0.82);
    font-weight: 600;
  }

  .web-nav-shell .dropdown-item:hover,
  .web-nav-shell .dropdown-item:focus {
    background: rgba(140, 37, 244, 0.14);
    color: #fff;
  }

  .web-footer {
    position: relative;
    padding: 96px 0 34px;
    margin-top: 56px;
    background:
      radial-gradient(circle at top left, rgba(140, 37, 244, 0.14), transparent 24%),
      linear-gradient(180deg, rgba(14, 9, 21, 0.94), rgba(14, 9, 21, 0.98));
    border-top: 1px solid rgba(255, 255, 255, 0.08);
  }

  .web-footer__grid {
    display: grid;
    grid-template-columns: 1.25fr 0.8fr 0.95fr;
    gap: 24px;
  }

  .web-footer__panel {
    height: 100%;
    padding: 28px;
    border-radius: 28px;
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--surface-shadow-soft);
  }

  .web-footer__eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 18px;
    color: #c79cff;
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.18em;
  }

  .web-footer__title {
    margin: 0 0 14px;
    color: #fff;
    font-family: var(--pjs);
    font-size: 32px;
    line-height: 1;
    letter-spacing: -0.03em;
  }

  .web-footer__copy,
  .web-footer__contact,
  .web-footer__links a,
  .web-footer__bottom,
  .web-footer__legal {
    color: var(--text-secondary);
  }

  .web-footer__copy {
    line-height: 1.85;
    margin-bottom: 20px;
  }

  .web-footer .footer-logo img {
    max-width: 168px;
    width: auto;
    height: auto;
    display: block;
  }

  .web-footer__metrics {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  .web-footer__metric {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 11px 14px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    color: rgba(255, 255, 255, 0.82);
    font-size: 13px;
    font-weight: 700;
  }

  .web-footer__heading {
    margin: 0 0 16px;
    color: #fff;
    font-family: var(--pjs);
    font-size: 22px;
    letter-spacing: -0.02em;
  }

  .web-footer__links {
    margin: 0;
    padding: 0;
    list-style: none;
    display: grid;
    gap: 10px;
  }

  .web-footer__links a {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
  }

  .web-footer__links a::before {
    content: '';
    width: 7px;
    height: 7px;
    border-radius: 999px;
    background: rgba(140, 37, 244, 0.8);
    box-shadow: 0 0 14px rgba(140, 37, 244, 0.4);
  }

  .web-footer__contact {
    display: grid;
    gap: 14px;
    line-height: 1.75;
  }

  .web-footer__contact-row {
    display: flex;
    align-items: flex-start;
    gap: 12px;
  }

  .web-footer__contact-icon,
  .social-style-one a {
    width: 42px;
    height: 42px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    color: #fff;
  }

  .social-style-one {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  .social-style-one a:hover {
    background: rgba(140, 37, 244, 0.16);
    color: #fff;
    transform: translateY(-1px);
  }

  .web-footer__bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    margin-top: 26px;
    padding-top: 20px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
  }

  .web-footer__legal {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
  }

  .scroll-top {
    border-radius: 18px;
    background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
    box-shadow: 0 18px 34px rgba(140, 37, 244, 0.24);
  }

  @media (max-width: 1199.98px) {
    .web-nav-shell {
      grid-template-columns: 1fr;
      gap: 18px;
    }

    .web-nav-shell .main-menu .navbar-collapse {
      grid-template-columns: 1fr;
      flex-wrap: wrap;
    }

    .web-nav-shell .navigation,
    .web-action-cluster {
      flex-wrap: wrap;
    }

    .web-footer__grid {
      grid-template-columns: 1fr 1fr;
    }

    .web-footer__grid > :first-child {
      grid-column: 1 / -1;
    }
  }

  @media (max-width: 991.98px) {
    .main-header.web-site-header {
      padding-top: 10px;
    }

    .main-header.web-site-header .header-upper {
      padding-bottom: 10px !important;
    }

    .web-nav-shell {
      padding: 14px;
    }

    .web-nav-shell .main-menu .navbar-collapse {
      display: block !important;
    }

    .web-brand__copy {
      display: none;
    }

    .web-action-cluster {
      width: 100%;
      margin-top: 14px;
      justify-content: flex-start;
      flex-wrap: wrap;
    }

    .web-top-cta {
      flex: 1 1 calc(50% - 10px);
    }

    .web-compact-actions {
      width: 100%;
      justify-content: flex-start;
    }
  }

  @media (max-width: 767.98px) {
    .web-footer {
      padding-top: 76px;
    }

    .web-footer__grid,
    .web-footer__bottom {
      grid-template-columns: 1fr;
      display: grid;
    }

    .web-footer__bottom {
      gap: 14px;
    }

    .web-unified-body--compact .page-banner {
      padding-top: 56px !important;
    }

    .web-unified-body--compact .banner-inner,
    .web-unified-body--compact .login-form {
      padding: 24px;
      border-radius: 24px;
    }
  }
>>>>>>> Stashed changes
</style>
