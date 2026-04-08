<style>
  .event-editor-frame {
    background: linear-gradient(180deg, #f7efea 0%, #efe4df 100%);
  }

  .event-editor-hero {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1.25rem;
    padding: 1.25rem 1.35rem;
    border-radius: 24px;
    margin-bottom: 1.25rem;
    background:
      radial-gradient(circle at top right, rgba(193, 18, 31, 0.16), transparent 26%),
      linear-gradient(135deg, #230f14 0%, #3a141b 56%, #591922 100%);
    color: #f8e9ea;
    box-shadow: 0 22px 48px rgba(11, 18, 37, 0.16);
    position: relative;
    overflow: hidden;
  }

  .event-editor-hero::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.03));
    pointer-events: none;
  }

  .event-editor-hero__eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.28rem 0.72rem;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.1);
    color: #f0b6bc;
    text-transform: uppercase;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
  }

  .event-editor-hero__title {
    margin: 0.7rem 0 0.4rem;
    font-size: 1.85rem;
    line-height: 1.05;
    font-weight: 800;
    color: #fff;
  }

  .event-editor-hero__copy {
    max-width: 700px;
    margin: 0;
    color: rgba(248, 233, 234, 0.78);
    line-height: 1.6;
  }

  .event-editor-hero__stats {
    display: grid;
    grid-template-columns: repeat(2, minmax(120px, 1fr));
    gap: 0.75rem;
    min-width: 260px;
    position: relative;
    z-index: 1;
  }

  .event-editor-hero__stat {
    padding: 0.95rem 1rem;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(10px);
  }

  .event-editor-hero__stat-label {
    display: block;
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: rgba(240, 182, 188, 0.88);
    margin-bottom: 0.3rem;
    font-weight: 700;
  }

  .event-editor-hero__stat-value {
    display: block;
    font-size: 1rem;
    font-weight: 700;
    color: #fff;
  }

  .event-editor-shell {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 320px;
    gap: 1.35rem;
    align-items: start;
  }

  .event-editor-main {
    min-width: 0;
  }

  .event-editor-sidebar {
    position: sticky;
    top: 108px;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .event-editor-sidebar__panel {
    border-radius: 24px;
    padding: 1.2rem;
    background: #ffffff;
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: 0 16px 34px rgba(15, 23, 42, 0.08);
  }

  .event-editor-sidebar__eyebrow {
    display: inline-flex;
    padding: 0.28rem 0.68rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.1);
    color: #C1121F;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .event-editor-sidebar__title {
    margin: 0.8rem 0 0.35rem;
    font-size: 1.15rem;
    font-weight: 800;
    color: #2d1619;
  }

  .event-editor-sidebar__text {
    margin: 0;
    color: #74666d;
    line-height: 1.55;
    font-size: 0.92rem;
  }

  .event-editor-sidebar__progress {
    margin-top: 1rem;
  }

  .event-editor-sidebar__progress-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.45rem;
    font-size: 0.88rem;
    color: #65555d;
    font-weight: 600;
  }

  .event-editor-sidebar__progress-bar {
    width: 100%;
    height: 10px;
    border-radius: 999px;
    background: #efe4df;
    overflow: hidden;
  }

  .event-editor-sidebar__progress-bar span {
    display: block;
    height: 100%;
    width: 0;
    border-radius: inherit;
    background: linear-gradient(90deg, #C1121F 0%, #E15562 100%);
    transition: width 0.24s ease;
  }

  .event-editor-sidebar__save-wrap {
    margin-top: 1rem;
    padding: 0.9rem;
    border-radius: 20px;
    background: linear-gradient(180deg, #fffaf7 0%, #f2e7e3 100%);
    border: 1px solid rgba(193, 18, 31, 0.12);
  }

  .event-editor-sidebar__save {
    width: 100%;
    min-height: 52px;
    border: 0;
    border-radius: 16px;
    background: linear-gradient(135deg, #2d1619 0%, #C1121F 100%);
    color: #fff;
    font-size: 0.98rem;
    font-weight: 800;
    letter-spacing: 0.01em;
    box-shadow: 0 18px 30px rgba(193, 18, 31, 0.2);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.55rem;
    transition: transform 0.18s ease, box-shadow 0.18s ease;
    cursor: pointer;
  }

  .event-editor-sidebar__save:hover,
  .event-editor-sidebar__save:focus {
    transform: translateY(-1px);
    color: #fff;
    box-shadow: 0 20px 34px rgba(193, 18, 31, 0.26);
    outline: none;
  }

  .event-editor-sidebar__save:disabled {
    opacity: 0.72;
    cursor: progress;
    transform: none;
    box-shadow: none;
  }

  .event-editor-sidebar__save-note {
    margin: 0.7rem 0 0;
    color: #74666d;
    font-size: 0.84rem;
    line-height: 1.55;
  }

  .event-editor-nav {
    display: flex;
    flex-direction: column;
    gap: 0.55rem;
    margin-top: 1rem;
  }

  .event-editor-nav__item {
    width: 100%;
    border: 1px solid rgba(15, 23, 42, 0.08);
    border-radius: 18px;
    background: #faf2ee;
    padding: 0.85rem 0.95rem;
    text-align: left;
    transition: transform 0.18s ease, border-color 0.18s ease, background 0.18s ease, box-shadow 0.18s ease;
  }

  .event-editor-nav__item:hover,
  .event-editor-nav__item:focus {
    transform: translateY(-1px);
    border-color: rgba(193, 18, 31, 0.22);
    background: #fff;
    box-shadow: 0 12px 28px rgba(193, 18, 31, 0.08);
    outline: none;
  }

  .event-editor-nav__item.is-active {
    background: linear-gradient(135deg, #f7ece8 0%, #fffaf7 100%);
    border-color: rgba(193, 18, 31, 0.34);
  }

  .event-editor-nav__meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 0.75rem;
  }

  .event-editor-nav__label {
    font-size: 0.94rem;
    font-weight: 700;
    color: #2d1619;
  }

  .event-editor-nav__status {
    font-size: 0.74rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: #94a3b8;
  }

  .event-editor-nav__status.is-complete {
    color: #0f9d58;
  }

  .event-editor-nav__status.is-pending {
    color: #e97b18;
  }

  .event-editor-sidebar__links {
    display: flex;
    flex-direction: column;
    gap: 0.55rem;
    margin-top: 1rem;
  }

  .event-editor-context-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.75rem;
    margin-top: 0.45rem;
  }

  .event-editor-context-card {
    padding: 0.95rem 1rem;
    border-radius: 18px;
    background: linear-gradient(180deg, #fffaf7 0%, #f2e7e3 100%);
    border: 1px solid rgba(193, 18, 31, 0.12);
  }

  .event-editor-context-card--wide {
    grid-column: 1 / -1;
  }

  .event-editor-context-card__label {
    display: block;
    margin-bottom: 0.3rem;
    color: #c84f5b;
    text-transform: uppercase;
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.08em;
  }

  .event-editor-context-card__value {
    display: block;
    color: #2d1619;
    font-size: 1rem;
    font-weight: 800;
    line-height: 1.35;
  }

  .event-editor-sidebar__link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.45rem;
    border-radius: 14px;
    padding: 0.78rem 0.95rem;
    text-decoration: none !important;
    font-weight: 700;
    font-size: 0.9rem;
  }

  .event-editor-sidebar__link--primary {
    background: #2d1619;
    color: #fff !important;
  }

  .event-editor-sidebar__link--ghost {
    background: #f7ece8;
    color: #2d1619 !important;
  }

  .event-editor-sidebar__tips {
    margin: 1rem 0 0;
    padding-left: 1rem;
    color: #74666d;
    font-size: 0.88rem;
    line-height: 1.55;
  }

  .event-editor-section {
    border-radius: 26px;
    background: #fff;
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: 0 16px 34px rgba(15, 23, 42, 0.08);
    padding: 1.2rem 1.25rem;
    margin-bottom: 1.25rem;
    scroll-margin-top: 108px;
  }

  .event-editor-section__header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .event-editor-section__kicker {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.24rem 0.66rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.08);
    color: #C1121F;
    text-transform: uppercase;
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
  }

  .event-editor-section__title {
    margin: 0.65rem 0 0.3rem;
    font-size: 1.28rem;
    font-weight: 800;
    color: #2d1619;
  }

  .event-editor-section__copy {
    margin: 0;
    color: #74666d;
    line-height: 1.55;
    max-width: 760px;
  }

  .event-editor-section__badge {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.5rem 0.75rem;
    border-radius: 14px;
    background: #faf2ee;
    color: #65555d;
    font-size: 0.82rem;
    font-weight: 700;
  }

  .event-editor-section__body > .row:last-child,
  .event-editor-section__body > .form-group:last-child,
  .event-editor-section__body > .event-media-workbench:last-child {
    margin-bottom: 0;
  }

  .event-editor-section .form-group label {
    font-weight: 700;
    color: #2d1619;
  }

  .event-editor-section .form-control,
  .event-editor-section .select2-container--default .select2-selection--single,
  .event-editor-section .note-editor.note-frame,
  .event-editor-section .bootstrap-tagsinput {
    border-radius: 14px;
  }

  .event-editor-section .form-control,
  .event-editor-section .bootstrap-tagsinput {
    border-color: #d7e1ef;
    min-height: 46px;
    box-shadow: none;
  }

  .event-editor-section .form-control:focus,
  .event-editor-section .bootstrap-tagsinput.focus {
    border-color: rgba(193, 18, 31, 0.38);
    box-shadow: 0 0 0 4px rgba(193, 18, 31, 0.08);
  }

  .event-editor-section .selectgroup {
    gap: 0.65rem;
  }

  .event-editor-section .selectgroup-item {
    flex: 1 1 auto;
  }

  .event-editor-section .selectgroup-button {
    border-radius: 14px !important;
    border-color: #d7e1ef !important;
    min-height: 46px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
  }

  .event-editor-section .selectgroup-input:checked + .selectgroup-button {
    background: linear-gradient(135deg, #C1121F 0%, #E15562 100%);
    border-color: transparent !important;
    color: #fff;
    box-shadow: 0 14px 24px rgba(193, 18, 31, 0.22);
  }

  .event-editor-section .table {
    margin-bottom: 0;
  }

  .event-editor-section .table thead th {
    background: #faf2ee;
    color: #334155;
    font-weight: 800;
    border-top: 0;
  }

  .event-editor-section .version {
    border: 1px solid rgba(15, 23, 42, 0.08);
    border-radius: 20px;
    overflow: hidden;
    background: #fff;
    margin-bottom: 1rem;
  }

  .event-editor-section .version-header {
    background: linear-gradient(180deg, #fffaf7 0%, #f2e7e3 100%);
    border-bottom: 1px solid rgba(15, 23, 42, 0.08);
  }

  .event-editor-section .version-header .btn-link {
    display: block;
    width: 100%;
    padding: 1rem 1.1rem;
    text-align: left;
    color: #2d1619;
    font-weight: 800;
    text-decoration: none;
  }

  .event-editor-section .version-body {
    padding: 1rem 1.1rem 0.35rem;
  }

  .event-editor-savebar {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.9rem;
    padding: 1rem;
    border-top: 1px solid rgba(15, 23, 42, 0.08);
    background: linear-gradient(180deg, #ffffff 0%, #f8eee9 100%);
  }

  .event-editor-savebar__button {
    min-width: 220px;
    min-height: 50px;
    border: 0;
    border-radius: 16px;
    background: linear-gradient(135deg, #2d1619 0%, #C1121F 100%);
    color: #fff;
    font-size: 0.98rem;
    font-weight: 800;
    letter-spacing: 0.01em;
    box-shadow: 0 18px 30px rgba(193, 18, 31, 0.2);
  }

  .event-editor-savebar__hint {
    font-size: 0.9rem;
    color: #64748b;
    margin: 0;
  }

  @media (max-width: 1199.98px) {
    .event-editor-shell {
      grid-template-columns: 1fr;
    }

    .event-editor-sidebar {
      position: static;
      order: -1;
    }
  }

  @media (max-width: 767.98px) {
    .event-editor-hero {
      flex-direction: column;
    }

    .event-editor-hero__stats {
      width: 100%;
      min-width: 0;
    }

    .event-editor-section__header {
      flex-direction: column;
    }

    .event-editor-savebar {
      flex-direction: column;
    }

    .event-editor-savebar__button {
      width: 100%;
    }

    .event-editor-sidebar__save-wrap {
      padding: 0.8rem;
    }

    .event-editor-context-grid {
      grid-template-columns: 1fr;
    }

    .event-editor-context-card--wide {
      grid-column: auto;
    }
  }
</style>
