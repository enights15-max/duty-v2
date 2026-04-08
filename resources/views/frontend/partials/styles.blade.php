<!-- Google Fonts -->
<link
  href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Roboto:wght@300;400;500;700&family=DM+Sans:wght@400;500;700&family=Inter:wght@400;500;600&display=swap"
  rel="stylesheet">
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
<link rel="stylesheet" href="{{ asset('assets/front/css/ui-ux.css') }}">
@if ($currentLanguageInfo->direction == 1)
  {{-- right-to-left css --}}
  <link rel="stylesheet" href="{{ asset('assets/front/css/rtl-style.css') }}">

  {{-- right-to-left-responsive css --}}
  <link rel="stylesheet" href="{{ asset('assets/front/css/rtl-responsive.css') }}">
@endif
<style>
  :root {
    scroll-behavior: smooth;
    --base-color: #8C25F4;
    --primary-color: #8C25F4;
    --accent-color: #FFD700;
    --bg-dark: #0D0812;
    --bg-surface: rgba(255, 255, 255, 0.03);
    --glass-border: rgba(255, 255, 255, 0.1);
    --text-primary: #FFFFFF;
    --text-secondary: rgba(255, 255, 255, 0.7);
    --base-font: 'Inter', sans-serif;
    --heading-font: 'Plus Jakarta Sans', sans-serif;
    --inter: 'Inter', sans-serif;
    --pjs: 'Plus Jakarta Sans', sans-serif;
    --heading-color: #FFFFFF !important;
  }

  .overlay:before {
    position: absolute;
    content: '';
    height: 100%;
    width: 100%;
    left: 0;
    top: 0;
    z-index: -1;
    opacity:
      {{ $basicInfo->breadcrumb_overlay_opacity }}
    ;
    background: #{{ $basicInfo->breadcrumb_overlay_color }};
  }

  /* Dark Theme Core Resets */
  body {
    background-color: var(--bg-dark) !important;
    color: var(--text-primary) !important;
    font-family: var(--inter) !important;
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
</style>