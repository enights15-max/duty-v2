<style>
  :root {
    --pro-primary: #C1121F;
    --pro-primary-deep: #8A0F18;
    --pro-primary-soft: rgba(193, 18, 31, 0.10);
    --pro-primary-outline: rgba(193, 18, 31, 0.22);
    --pro-success: #238A57;
    --pro-warning: #C68500;
    --pro-danger: #D32F2F;
    --pro-info: #4459E6;
    --pro-blush: #E6B7BC;
    --pro-dust-rose: #C84F5B;
    --pro-warm-gold: #D4A63C;
    --pro-graphite-wine: #2D1619;
    --pro-cocoa-smoke: #74666D;
  }

  body[data-background-color='white'] {
    --pro-bg: #F6F2ED;
    --pro-bg-alt: #EFE8E1;
    --pro-surface: rgba(255, 255, 255, 0.94);
    --pro-surface-strong: #FFFFFF;
    --pro-surface-alt: #F4ECE5;
    --pro-border: #E4DCD8;
    --pro-text: #16121A;
    --pro-text-soft: #5D5564;
    --pro-muted: #8C8391;
  }

  body[data-background-color='dark'] {
    --pro-bg: #100E14;
    --pro-bg-alt: #18131A;
    --pro-surface: rgba(23, 19, 27, 0.94);
    --pro-surface-strong: #1B1620;
    --pro-surface-alt: #211922;
    --pro-border: #312936;
    --pro-border-strong: #453947;
    --pro-text: #F5F1EB;
    --pro-text-soft: #C7C0CC;
    --pro-muted: #948B98;
  }

  body {
    background: linear-gradient(180deg, var(--pro-bg) 0%, var(--pro-bg-alt) 100%) !important;
    color: var(--pro-text);
  }

  .wrapper,
  .main-panel,
  .content,
  .page-inner {
    background: transparent !important;
  }

  .logo-header[data-background-color='white'],
  .navbar-header[data-background-color='white'],
  .sidebar[data-background-color='white'] {
    background: #FFF9F6 !important;
    border-color: var(--pro-border) !important;
  }

  .logo-header[data-background-color='dark2'],
  .navbar-header[data-background-color='dark'],
  .sidebar[data-background-color='dark2'] {
    background: #17131A !important;
    border-color: var(--pro-border) !important;
  }

  .sidebar,
  .navbar-header,
  .logo-header,
  .card,
  .dropdown-menu,
  .modal-content {
    box-shadow: 0 18px 42px rgba(17, 10, 14, 0.10) !important;
  }

  .card {
    border-radius: 22px !important;
    border-color: var(--pro-border) !important;
    background: var(--pro-surface) !important;
  }

  .card .card-header,
  .modal-header,
  .modal-footer {
    background: transparent !important;
    border-color: var(--pro-border) !important;
  }

  .btn-primary,
  .btn-primary.disabled,
  .btn-primary:disabled {
    border: 0 !important;
    background: linear-gradient(135deg, var(--pro-primary) 0%, var(--pro-primary-deep) 100%) !important;
    color: #FFF8F4 !important;
    box-shadow: 0 14px 26px rgba(193, 18, 31, 0.18);
  }

  .btn-light {
    background: var(--pro-surface-alt) !important;
    border-color: var(--pro-border) !important;
    color: var(--pro-text) !important;
  }

  .btn-success {
    background: linear-gradient(135deg, var(--pro-success) 0%, #1d6a47 100%) !important;
    border-color: transparent !important;
  }

  .btn-warning {
    background: linear-gradient(135deg, var(--pro-warning) 0%, #9A6800 100%) !important;
    border-color: transparent !important;
    color: #FFF8E8 !important;
  }

  .btn-danger {
    background: linear-gradient(135deg, var(--pro-danger) 0%, #A82424 100%) !important;
    border-color: transparent !important;
  }

  .btn-info {
    background: linear-gradient(135deg, var(--pro-info) 0%, #3143BD 100%) !important;
    border-color: transparent !important;
    color: #F5F7FF !important;
  }

  .badge-success,
  .text-success {
    color: var(--pro-success) !important;
  }

  .badge-warning,
  .text-warning {
    color: var(--pro-warning) !important;
  }

  .badge-danger,
  .text-danger {
    color: var(--pro-danger) !important;
  }

  .badge-success,
  .badge-warning,
  .badge-danger {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    border-radius: 999px;
    padding: 0.32rem 0.72rem;
    background: var(--pro-surface-alt) !important;
    border: 1px solid var(--pro-border) !important;
    font-weight: 700;
  }

  .alert-success,
  .alert-warning,
  .alert-danger {
    border-radius: 18px !important;
    border-width: 1px !important;
    background: var(--pro-surface-alt) !important;
  }

  .alert-success {
    color: var(--pro-success) !important;
    border-color: rgba(35, 138, 87, 0.18) !important;
  }

  .alert-warning {
    color: var(--pro-warning) !important;
    border-color: rgba(198, 133, 0, 0.18) !important;
  }

  .alert-danger {
    color: var(--pro-danger) !important;
    border-color: rgba(211, 47, 47, 0.18) !important;
  }

  .selectgroup-input:checked + .selectgroup-button {
    background: linear-gradient(135deg, var(--pro-primary) 0%, var(--pro-primary-deep) 100%) !important;
    border-color: transparent !important;
    color: #FFF8F4 !important;
  }

  .form-control,
  .custom-select {
    border-radius: 16px !important;
    border-color: var(--pro-border) !important;
    background: var(--pro-surface-strong) !important;
    color: var(--pro-text) !important;
    box-shadow: none !important;
  }

  .form-control:focus,
  .custom-select:focus {
    border-color: var(--pro-primary-outline) !important;
    box-shadow: 0 0 0 4px rgba(193, 18, 31, 0.09) !important;
  }

  .dropdown-menu {
    border-radius: 18px !important;
    border-color: var(--pro-border) !important;
    background: var(--pro-surface) !important;
  }

  .dropdown-item {
    border-radius: 12px !important;
    color: var(--pro-text-soft) !important;
    font-weight: 600;
  }

  .dropdown-item:hover,
  .dropdown-item:focus {
    background: var(--pro-primary-soft) !important;
    color: var(--pro-text) !important;
  }

  .sidebar .nav .nav-item a,
  .sidebar .nav .nav-item a p,
  .sidebar .nav .nav-item a i,
  .sidebar .nav .nav-collapse .sub-item,
  .sidebar .user .info a,
  .sidebar .user .info .user-level {
    color: var(--pro-text-soft) !important;
  }

  .sidebar .nav .nav-item a:hover,
  .sidebar .nav .nav-collapse li a:hover {
    background: var(--pro-primary-soft) !important;
    color: var(--pro-text) !important;
  }

  .sidebar .nav .nav-item.active > a,
  .sidebar .nav .nav-item.active > a:hover,
  .sidebar .nav .nav-collapse li.active > a {
    background: linear-gradient(135deg, var(--pro-primary) 0%, var(--pro-primary-deep) 100%) !important;
    color: #FFF8F4 !important;
  }

  .sidebar .nav .nav-item.active > a p,
  .sidebar .nav .nav-item.active > a i,
  .sidebar .nav .nav-collapse li.active > a .sub-item {
    color: #FFF8F4 !important;
  }

  .page-header .page-title,
  .card-title,
  .table td,
  .table th,
  .text-dark {
    color: var(--pro-text) !important;
  }

  .text-muted,
  .small.text-muted {
    color: var(--pro-muted) !important;
  }
</style>
