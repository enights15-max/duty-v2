{{-- fontawesome css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/all.min.css') }}">

{{-- fontawesome icon picker css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/fontawesome-iconpicker.min.css') }}">

{{-- bootstrap css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/bootstrap.min.css') }}">

{{-- bootstrap tags-input css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/bootstrap-tagsinput.css') }}">

{{-- jQuery-ui css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/jquery-ui.min.css') }}">

{{-- jQuery-timepicker css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/jquery.timepicker.min.css') }}">

{{-- bootstrap-datepicker css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/bootstrap-datepicker.css') }}">

{{-- select2 css --}}
<link rel="stylesheet" href="{{asset('assets/admin/css/select2.min.css')}}">

{{-- dropzone css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/dropzone.min.css') }}">

{{-- monokai css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/monokai-sublime.css') }}">

{{-- atlantis css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/atlantis.css') }}">

{{-- admin-main css --}}
<link rel="stylesheet" href="{{ asset('assets/admin/css/admin-main.css') }}">

@includeIf('backend.partials.scarlet-light-theme')

<style>
  .logo-header__mode-badge {
    margin-left: auto;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.45rem 0.8rem;
    border-radius: 999px;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--panel-text-soft);
    background: var(--panel-surface-muted);
    border: 1px solid var(--panel-border);
  }

  .admin-layout-toggle {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    font-weight: 600;
  }

  .admin-topnav-layout .main-panel,
  .admin-topnav-layout .main-header {
    width: 100% !important;
  }

  .admin-topnav-layout .main-panel {
    min-height: calc(100vh - 70px);
  }

  .admin-topnav-shell {
    padding: 0;
    margin-right: auto;
    margin-left: 1.5rem;
  }

  .admin-topnav {
    display: flex;
    align-items: center;
    background: transparent;
    border: none;
    box-shadow: none;
    padding: 0;
  }

  .admin-topnav__intro {
    min-width: 180px;
    color: var(--panel-text);
  }

  .admin-topnav__caption {
    max-width: 320px;
    margin-top: 0.35rem;
    font-size: 0.84rem;
    line-height: 1.5;
    color: var(--panel-text-soft);
  }

  .admin-topnav__eyebrow {
    display: block;
    margin-bottom: 0.2rem;
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--panel-text-muted);
  }

  .admin-topnav__menu {
    margin: 0;
    padding: 0;
    list-style: none;
    display: flex;
    align-items: center;
    gap: 0.65rem;
    flex-wrap: wrap;
  }

  .admin-topnav__item {
    position: relative;
  }

  .admin-topnav__link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    height: 38px;
    padding: 0 1.25rem;
    border-radius: 12px;
    border: 1px solid rgba(0, 0, 0, 0.05);
    background: var(--panel-surface-muted);
    color: var(--panel-text-soft);
    font-size: 0.85rem;
    font-weight: 700;
    transition: all 0.2s ease;
  }

  .admin-topnav__link:hover,
  .admin-topnav__link:focus,
  .admin-topnav__link.is-active {
    color: #fff;
    text-decoration: none;
    background: linear-gradient(135deg, var(--scarlet-primary) 0%, var(--scarlet-primary-deep) 100%);
    border-color: transparent;
    box-shadow: 0 12px 24px rgba(193, 18, 31, 0.18);
  }

  .admin-topnav__dropdown {
    min-width: 240px;
    padding: 0.55rem;
    border: 1px solid var(--panel-border);
    border-radius: 18px;
    background: var(--panel-surface);
    box-shadow: var(--scarlet-shadow-strong);
  }

  .admin-topnav__dropdown--wide {
    min-width: 640px;
    max-width: min(720px, calc(100vw - 3rem));
  }

  .admin-topnav__dropdown-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 0.65rem;
  }

  .admin-topnav__dropdown-group {
    padding: 0.35rem;
    border-radius: 14px;
    background: linear-gradient(180deg, rgba(193, 18, 31, 0.06), rgba(255, 255, 255, 0));
  }

  .admin-topnav__dropdown-title {
    margin-bottom: 0.45rem;
    padding: 0.35rem 0.5rem;
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--scarlet-primary);
  }

  .admin-topnav__dropdown-link,
  .admin-topnav__dropdown .dropdown-item {
    display: block;
    border-radius: 12px;
    padding: 0.7rem 0.85rem;
    font-weight: 600;
    color: var(--panel-text);
    transition: all 0.18s ease;
  }

  .admin-topnav__dropdown-link:hover,
  .admin-topnav__dropdown-link:focus,
  .admin-topnav__dropdown .dropdown-item:hover {
    background: var(--scarlet-primary-soft);
    color: var(--panel-text);
    text-decoration: none;
    transform: translateX(2px);
  }

  @media (max-width: 1199.98px) {
    .admin-topnav {
      flex-direction: column;
      align-items: stretch;
    }

    .admin-topnav__intro {
      min-width: 0;
    }

    .admin-topnav__caption {
      max-width: none;
    }
  }

  @media (max-width: 767.98px) {
    .admin-topnav-shell {
      padding: 0.85rem 1rem 0;
    }

    .admin-topnav {
      border-radius: 18px;
      padding: 0.85rem;
    }

    .admin-topnav__menu {
      gap: 0.45rem;
    }

    .admin-topnav__dropdown,
    .admin-topnav__dropdown--wide {
      min-width: 0;
      max-width: calc(100vw - 2rem);
    }

    .admin-topnav__dropdown-grid {
      grid-template-columns: 1fr;
    }

    .admin-topnav__link {
      width: 100%;
      justify-content: space-between;
    }

    .admin-topnav__item {
      width: 100%;
    }
  }
</style>
