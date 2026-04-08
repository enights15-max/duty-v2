<style>
  :root {
    --scarlet-primary: #C1121F;
    --scarlet-primary-deep: #8A0F18;
    --scarlet-primary-soft: rgba(193, 18, 31, 0.10);
    --scarlet-primary-outline: rgba(193, 18, 31, 0.22);
    --scarlet-blush: #E6B7BC;
    --scarlet-dust-rose: #C84F5B;
    --scarlet-warm-gold: #D4A63C;
    --scarlet-graphite-wine: #2D1619;
    --scarlet-cocoa-smoke: #74666D;
    --scarlet-ink: #16121A;
    --scarlet-ink-soft: #5D5564;
    --scarlet-muted: #8C8391;
    --scarlet-success: #238A57;
    --scarlet-warning: #C68500;
    --scarlet-danger: #D32F2F;
    --scarlet-info: #4459E6;
    --scarlet-shadow: 0 18px 40px rgba(17, 10, 14, 0.08);
    --scarlet-shadow-strong: 0 24px 54px rgba(17, 10, 14, 0.12);
  }

  body[data-background-color='white'] {
    --panel-bg: #F6F2ED;
    --panel-bg-alt: #EFE8E1;
    --panel-surface: rgba(255, 255, 255, 0.94);
    --panel-surface-strong: #FFFFFF;
    --panel-surface-muted: #F4ECE5;
    --panel-border: #E4DCD8;
    --panel-border-strong: #D7CAC4;
    --panel-text: #16121A;
    --panel-text-soft: #5D5564;
    --panel-text-muted: #8C8391;
    --panel-nav: #FFF8F5;
    --panel-nav-alt: #F2E6E1;
    --panel-glass: rgba(255, 255, 255, 0.76);
  }

  body[data-background-color='dark'] {
    --panel-bg: #100E14;
    --panel-bg-alt: #18131A;
    --panel-surface: rgba(23, 19, 27, 0.94);
    --panel-surface-strong: #1B1620;
    --panel-surface-muted: #241D29;
    --panel-border: #312936;
    --panel-border-strong: #453947;
    --panel-text: #F5F1EB;
    --panel-text-soft: #C7C0CC;
    --panel-text-muted: #948B98;
    --panel-nav: #17131A;
    --panel-nav-alt: #231C24;
    --panel-glass: rgba(26, 20, 30, 0.82);
    --scarlet-shadow: 0 22px 54px rgba(3, 2, 5, 0.35);
    --scarlet-shadow-strong: 0 28px 70px rgba(3, 2, 5, 0.5);
  }

  body {
    background: linear-gradient(180deg, var(--panel-bg) 0%, var(--panel-bg-alt) 100%) !important;
    color: var(--panel-text);
  }

  .wrapper,
  .main-panel,
  .content,
  .page-inner {
    background: transparent !important;
  }

  .main-panel > .content {
    min-height: calc(100vh - 70px);
  }

  .logo-header[data-background-color='white'],
  .logo-header[data-background-color='dark2'],
  .navbar-header[data-background-color='white'],
  .navbar-header[data-background-color='white2'],
  .navbar-header[data-background-color='dark'],
  .sidebar[data-background-color='white'],
  .sidebar[data-background-color='dark2'] {
    border: 0 !important;
    box-shadow: none !important;
  }

  .logo-header[data-background-color='white'] {
    background: linear-gradient(135deg, #FFF8F5 0%, #F5ECE8 100%) !important;
    border-right: 1px solid var(--panel-border) !important;
    border-bottom: 1px solid var(--panel-border) !important;
  }

  .logo-header[data-background-color='dark2'] {
    background: linear-gradient(135deg, #1A141B 0%, #231921 100%) !important;
    border-right: 1px solid var(--panel-border) !important;
    border-bottom: 1px solid var(--panel-border) !important;
  }

  .navbar-header[data-background-color='white'],
  .navbar-header[data-background-color='white2'] {
    background: var(--panel-glass) !important;
    border-bottom: 1px solid var(--panel-border) !important;
    backdrop-filter: blur(14px);
  }

  .navbar-header[data-background-color='dark'] {
    background: rgba(17, 13, 20, 0.86) !important;
    border-bottom: 1px solid var(--panel-border) !important;
    backdrop-filter: blur(14px);
  }

  .sidebar[data-background-color='white'] {
    background: linear-gradient(180deg, #FFF9F6 0%, #F4ECE5 100%) !important;
    border-right: 1px solid var(--panel-border) !important;
  }

  .sidebar[data-background-color='dark2'] {
    background: linear-gradient(180deg, #18131A 0%, #120F15 100%) !important;
    border-right: 1px solid var(--panel-border) !important;
  }

  .sidebar .user {
    border-bottom: 1px solid var(--panel-border) !important;
    padding-bottom: 1rem;
    margin-bottom: 1rem;
  }

  .sidebar .user .info a,
  .sidebar .user .info .user-level,
  .sidebar .nav .nav-item a,
  .sidebar .nav .nav-item a p,
  .sidebar .nav .nav-item a i,
  .sidebar .nav .nav-collapse .sub-item,
  .sidebar .text-section {
    color: var(--panel-text-soft) !important;
  }

  .sidebar .nav .nav-item a:hover,
  .sidebar .nav .nav-collapse li a:hover {
    background: var(--scarlet-primary-soft) !important;
    color: var(--panel-text) !important;
  }

  .sidebar .nav .nav-item a:hover p,
  .sidebar .nav .nav-item a:hover i,
  .sidebar .nav .nav-collapse li a:hover .sub-item {
    color: var(--panel-text) !important;
  }

  .sidebar .nav.nav-primary > .nav-item.active > a,
  .sidebar .nav.nav-primary > .nav-item.active > a:hover,
  .sidebar .nav .nav-collapse li.active > a {
    background: linear-gradient(135deg, var(--scarlet-primary) 0%, var(--scarlet-primary-deep) 100%) !important;
    box-shadow: 0 14px 30px rgba(193, 18, 31, 0.18);
    color: #FFF7F4 !important;
  }

  .sidebar .nav.nav-primary > .nav-item.active > a i,
  .sidebar .nav.nav-primary > .nav-item.active > a p,
  .sidebar .nav .nav-collapse li.active > a .sub-item {
    color: #FFF7F4 !important;
  }

  .sidebar .nav .nav-section .sidebar-mini-icon {
    color: var(--scarlet-primary) !important;
  }

  .page-header .page-title,
  .card-title,
  .dropdown-user .u-text h4,
  .table td,
  .table th,
  .footer,
  .nav-home a,
  .breadcrumbs .nav-item a {
    color: var(--panel-text) !important;
  }

  .page-header,
  .footer {
    color: var(--panel-text-soft);
  }

  .card,
  .dropdown-menu,
  .modal-content,
  .swal-modal,
  .note-editor.note-frame,
  .tox .tox-editor-header,
  .tox .tox-toolbar-overlord,
  .tox .tox-edit-area__iframe {
    border-color: var(--panel-border) !important;
    background: var(--panel-surface) !important;
    box-shadow: var(--scarlet-shadow);
  }

  .card {
    border-radius: 24px !important;
    overflow: hidden;
  }

  .card .card-header,
  .modal-header,
  .dropdown-divider {
    border-color: var(--panel-border) !important;
  }

  .card .card-header,
  .modal-header,
  .modal-footer {
    background: transparent !important;
  }

  .text-muted,
  .small.text-muted,
  .form-text,
  .card-category,
  .dropdown-user .u-text p,
  .breadcrumbs .separator i {
    color: var(--panel-text-muted) !important;
  }

  .btn-primary,
  .badge-primary,
  .btn-primary.disabled,
  .btn-primary:disabled {
    border: 0 !important;
    background: linear-gradient(135deg, var(--scarlet-primary) 0%, var(--scarlet-primary-deep) 100%) !important;
    color: #FFF8F4 !important;
    box-shadow: 0 14px 26px rgba(193, 18, 31, 0.18);
  }

  .btn-primary:hover,
  .btn-primary:focus,
  .btn-primary:active {
    transform: translateY(-1px);
    box-shadow: 0 18px 30px rgba(193, 18, 31, 0.24) !important;
  }

  .btn-light,
  .btn-outline-light {
    background: var(--panel-surface-muted) !important;
    color: var(--panel-text) !important;
    border-color: var(--panel-border) !important;
  }

  .btn-secondary {
    background: var(--panel-surface-muted) !important;
    border-color: var(--panel-border) !important;
    color: var(--panel-text) !important;
  }

  .btn-success {
    background: linear-gradient(135deg, var(--scarlet-success) 0%, #1d6a47 100%) !important;
    border-color: transparent !important;
  }

  .btn-warning {
    background: linear-gradient(135deg, var(--scarlet-warning) 0%, #9A6800 100%) !important;
    border-color: transparent !important;
    color: #FFF8E8 !important;
  }

  .btn-info {
    background: linear-gradient(135deg, var(--scarlet-info) 0%, #3143BD 100%) !important;
    border-color: transparent !important;
    color: #F5F7FF !important;
  }

  .btn-danger {
    background: linear-gradient(135deg, var(--scarlet-danger) 0%, #A82424 100%) !important;
    border-color: transparent !important;
  }

  .badge-success,
  .text-success {
    color: var(--scarlet-success) !important;
  }

  .badge-warning,
  .text-warning {
    color: var(--scarlet-warning) !important;
  }

  .badge-danger,
  .text-danger {
    color: var(--scarlet-danger) !important;
  }

  .badge-success,
  .badge-warning,
  .badge-danger {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    border-radius: 999px;
    padding: 0.32rem 0.72rem;
    background: var(--panel-surface-muted) !important;
    border: 1px solid var(--panel-border) !important;
    font-weight: 700;
  }

  .alert-success,
  .alert-warning,
  .alert-danger {
    border-radius: 18px !important;
    border-width: 1px !important;
    background: var(--panel-surface-muted) !important;
  }

  .alert-success {
    color: var(--scarlet-success) !important;
    border-color: rgba(35, 138, 87, 0.18) !important;
  }

  .alert-warning {
    color: var(--scarlet-warning) !important;
    border-color: rgba(198, 133, 0, 0.18) !important;
  }

  .alert-danger {
    color: var(--scarlet-danger) !important;
    border-color: rgba(211, 47, 47, 0.18) !important;
  }

  .scarlet-modal__eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.28rem 0.72rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.1);
    color: var(--scarlet-primary);
    text-transform: uppercase;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
  }

  .scarlet-modal__title {
    margin: 0.8rem 0 0.35rem;
    font-size: 1.25rem;
    font-weight: 800;
    color: var(--panel-text);
  }

  .scarlet-modal__intro {
    margin: 0;
    color: var(--panel-text-soft);
    line-height: 1.6;
  }

  .scarlet-modal__section {
    margin-top: 1rem;
    padding: 1rem 1rem 0.15rem;
    border-radius: 20px;
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 241, 237, 0.98) 100%);
    border: 1px solid rgba(193, 18, 31, 0.1);
  }

  body[data-background-color='dark'] .scarlet-modal__section {
    background: linear-gradient(180deg, rgba(42, 30, 33, 0.95) 0%, rgba(32, 23, 27, 0.98) 100%);
    border-color: rgba(225, 85, 98, 0.16);
  }

  .scarlet-form-hint {
    display: block;
    margin-top: 0.35rem;
    color: var(--panel-text-muted);
    font-size: 0.84rem;
    line-height: 1.55;
  }

  .scarlet-inline-note {
    padding: 0.9rem 1rem;
    border-radius: 16px;
    background: rgba(193, 18, 31, 0.08);
    color: var(--panel-text);
    border: 1px solid rgba(193, 18, 31, 0.12);
  }

  .selectgroup-input:checked + .selectgroup-button {
    background: linear-gradient(135deg, var(--scarlet-primary) 0%, var(--scarlet-primary-deep) 100%) !important;
    border-color: transparent !important;
    color: #FFF8F4 !important;
  }

  .form-control,
  .custom-select,
  .bootstrap-tagsinput,
  .tox .tox-tbtn--select,
  .tox .tox-number-input .tox-input-wrapper {
    min-height: 46px;
    border-radius: 16px !important;
    border-color: var(--panel-border) !important;
    background: var(--panel-surface-strong) !important;
    color: var(--panel-text) !important;
    box-shadow: none !important;
  }

  .form-control::placeholder,
  .bootstrap-tagsinput input::placeholder {
    color: var(--panel-text-muted) !important;
  }

  .form-control:focus,
  .custom-select:focus,
  .bootstrap-tagsinput:focus-within {
    border-color: var(--scarlet-primary-outline) !important;
    box-shadow: 0 0 0 4px rgba(193, 18, 31, 0.09) !important;
  }

  .table thead th {
    border-bottom-color: var(--panel-border) !important;
    color: var(--panel-text-soft) !important;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    font-size: 0.72rem;
    font-weight: 800;
  }

  .table td {
    border-top-color: var(--panel-border) !important;
  }

  .table-striped tbody tr:nth-of-type(odd) {
    background: rgba(193, 18, 31, 0.025) !important;
  }

  .dropdown-menu {
    border-radius: 18px !important;
    padding: 0.5rem !important;
  }

  .dropdown-item {
    border-radius: 12px !important;
    color: var(--panel-text-soft) !important;
    font-weight: 600;
  }

  .dropdown-item:hover,
  .dropdown-item:focus {
    background: var(--scarlet-primary-soft) !important;
    color: var(--panel-text) !important;
  }

  .avatar-img,
  .rounded-circle {
    box-shadow: 0 10px 24px rgba(17, 10, 14, 0.12);
  }

  .sidebar-search,
  .sidebar-search:focus {
    background: var(--panel-surface-strong) !important;
  }

  .footer {
    border-top: 1px solid var(--panel-border);
    background: transparent;
  }
</style>
