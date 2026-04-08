<style>
  .event-index-shell {
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }

  .event-index-board {
    border-radius: 28px;
    background: linear-gradient(180deg, #ffffff 0%, #fbf3ee 100%);
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: 0 20px 38px rgba(15, 23, 42, 0.08);
    overflow: visible;
  }

  .event-index-topbar {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    padding: 1.25rem 1.5rem 1rem;
    border-bottom: 1px solid rgba(15, 23, 42, 0.08);
  }

  .event-index-topbar__meta {
    display: flex;
    flex-direction: column;
    gap: 0.4rem;
  }

  .event-index-topbar__title-row {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.75rem;
  }

  .event-index-topbar__title {
    margin: 0;
    color: #0f172a;
    font-size: 1.5rem;
    font-weight: 800;
  }

  .event-index-topbar__count {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 38px;
    height: 38px;
    padding: 0 0.95rem;
    border-radius: 999px;
    background: #0f172a;
    color: #ffffff;
    font-size: 0.95rem;
    font-weight: 800;
  }

  .event-index-topbar__subtitle {
    margin: 0;
    color: #64748b;
    line-height: 1.5;
    max-width: 620px;
    font-size: 0.94rem;
  }

  .event-index-topbar__scopes {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.55rem;
    margin-top: 0.1rem;
  }

  .event-index-topbar__scope-pill {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    min-height: 34px;
    padding: 0.42rem 0.75rem;
    border-radius: 999px;
    background: #fbf1ed;
    border: 1px solid rgba(15, 23, 42, 0.07);
    color: #334155;
  }

  .event-index-topbar__scope-pill small {
    color: #64748b;
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.05em;
    text-transform: uppercase;
  }

  .event-index-topbar__scope-pill strong {
    color: #0f172a;
    font-size: 0.83rem;
    font-weight: 800;
  }

  .event-index-topbar__actions {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 0.8rem;
  }

  .event-index-bulk-delete {
    min-height: 44px;
    border-radius: 14px;
    border: 0;
    background: linear-gradient(135deg, #8A0F18 0%, #E15562 100%);
    color: #fff;
    font-weight: 700;
    box-shadow: 0 14px 24px rgba(217, 4, 41, 0.18);
  }

  .event-index-add {
    min-height: 44px;
    border: 0;
    border-radius: 14px;
    background: linear-gradient(135deg, #0f172a 0%, #C1121F 100%);
    color: #fff !important;
    font-weight: 700;
    box-shadow: 0 16px 28px rgba(193, 18, 31, 0.18);
  }

  .event-index-workbench {
    display: flex;
    flex-direction: column;
    gap: 0.9rem;
    padding: 1.25rem 1.5rem 0;
  }

  .event-index-primary-form {
    display: grid;
    grid-template-columns: minmax(280px, 1.6fr) minmax(180px, 0.7fr) auto auto;
    gap: 0.85rem;
    align-items: end;
    padding: 1rem;
    border-radius: 24px;
    background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%);
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.82);
  }

  .event-index-search,
  .event-index-select-field {
    display: flex;
    flex-direction: column;
    gap: 0.38rem;
    margin: 0;
  }

  .event-index-search__label,
  .event-index-select-field__label,
  .event-index-chip-group__label {
    color: #64748b;
    font-size: 0.74rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .event-index-search__control {
    display: flex;
    align-items: center;
    gap: 0.7rem;
    min-height: 50px;
    padding: 0 1rem;
    border-radius: 16px;
    background: #ffffff;
    border: 1px solid #d7e1ef;
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.9);
  }

  .event-index-search__control i {
    color: #94a3b8;
  }

  .event-index-search__control input {
    width: 100%;
    border: 0;
    outline: none;
    background: transparent;
    color: #0f172a;
  }

  .event-index-select-field .form-control {
    min-height: 50px;
    border-radius: 16px;
    border-color: #d7e1ef;
    box-shadow: none;
  }

  .event-index-select-field .form-control:focus,
  .event-index-search__control:focus-within {
    border-color: rgba(193, 18, 31, 0.38);
    box-shadow: 0 0 0 4px rgba(193, 18, 31, 0.08);
  }

  .event-index-primary-form__actions {
    display: flex;
    gap: 0.65rem;
    flex-wrap: wrap;
  }

  .event-index-search-submit,
  .event-index-clear {
    min-height: 50px;
    border-radius: 16px;
    font-weight: 700;
  }

  .event-index-search-submit {
    border: 0;
    background: linear-gradient(135deg, #0f172a 0%, #C1121F 100%);
  }

  .event-index-clear {
    border: 0;
    background: #edf2fa;
    color: #0f172a;
  }

  .event-index-view-switch {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.35rem;
    border-radius: 18px;
    background: #faf2ee;
    border: 1px solid rgba(15, 23, 42, 0.08);
    justify-self: end;
  }

  .event-index-view-switch__button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.45rem;
    min-height: 42px;
    padding: 0.7rem 0.95rem;
    border-radius: 14px;
    color: #475569;
    text-decoration: none !important;
    font-weight: 800;
    transition: all 0.16s ease;
  }

  .event-index-view-switch__button:hover,
  .event-index-view-switch__button:focus {
    background: #ffffff;
    color: #0f172a;
    outline: none;
  }

  .event-index-view-switch__button.is-active {
    background: linear-gradient(135deg, #0f172a 0%, #C1121F 100%);
    color: #ffffff;
    box-shadow: 0 14px 24px rgba(193, 18, 31, 0.16);
  }

  .event-index-nav-row {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.9rem;
  }

  .event-index-chip-group {
    display: flex;
    flex-direction: column;
    gap: 0.55rem;
    padding: 0.1rem 0;
  }

  .event-index-chip-tabs {
    display: flex;
    flex-wrap: wrap;
    gap: 0.65rem;
    padding: 0.2rem 0 0.1rem;
  }

  .event-index-chip-tab {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    padding: 0.72rem 0.95rem;
    border-radius: 999px;
    text-decoration: none !important;
    background: #f8fbff;
    color: #334155;
    border: 1px solid rgba(15, 23, 42, 0.08);
    font-weight: 700;
    transition: all 0.18s ease;
  }

  .event-index-chip-tab strong {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 26px;
    height: 26px;
    padding: 0 0.45rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.08);
    font-size: 0.78rem;
    font-weight: 800;
    color: #C1121F;
  }

  .event-index-chip-tab:hover,
  .event-index-chip-tab:focus {
    transform: translateY(-1px);
    color: #0f172a;
    border-color: rgba(193, 18, 31, 0.24);
    box-shadow: 0 12px 22px rgba(193, 18, 31, 0.08);
    outline: none;
  }

  .event-index-chip-tab.is-active {
    background: linear-gradient(135deg, #edf4ff 0%, #ffffff 100%);
    color: #C1121F;
    border-color: rgba(193, 18, 31, 0.32);
    box-shadow: 0 14px 24px rgba(193, 18, 31, 0.08);
  }

  .event-index-advanced {
    border-radius: 22px;
    border: 1px dashed rgba(15, 23, 42, 0.14);
    background: linear-gradient(180deg, #f8fbff 0%, #fdfefe 100%);
    overflow: hidden;
  }

  .event-index-advanced summary {
    list-style: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.85rem;
    padding: 1rem 1.1rem;
    color: #0f172a;
    font-weight: 800;
  }

  .event-index-advanced summary::-webkit-details-marker {
    display: none;
  }

  .event-index-advanced__summary-copy {
    display: flex;
    flex-direction: column;
    gap: 0.2rem;
  }

  .event-index-advanced__summary-copy strong {
    color: #0f172a;
    font-size: 0.96rem;
    font-weight: 800;
  }

  .event-index-advanced summary small {
    color: #64748b;
    font-size: 0.84rem;
    font-weight: 600;
  }

  .event-index-advanced__summary-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 34px;
    padding: 0.42rem 0.8rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.08);
    color: #C1121F;
    font-size: 0.78rem;
    font-weight: 800;
    white-space: nowrap;
  }

  .event-index-advanced__form {
    display: grid;
    grid-template-columns: repeat(5, minmax(0, 1fr));
    gap: 0.85rem;
    padding: 0 1.1rem 1.1rem;
    align-items: end;
  }

  .event-index-toggle-field {
    display: flex;
    align-items: center;
    gap: 0.8rem;
    min-height: 50px;
    padding: 0.78rem 0.95rem;
    border-radius: 16px;
    background: #ffffff;
    border: 1px solid #d7e1ef;
    margin: 0;
  }

  .event-index-toggle-field input {
    width: 18px;
    height: 18px;
    flex-shrink: 0;
  }

  .event-index-toggle-field span {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
    min-width: 0;
  }

  .event-index-toggle-field strong {
    color: #0f172a;
    font-size: 0.92rem;
    font-weight: 800;
  }

  .event-index-toggle-field small {
    color: #64748b;
    line-height: 1.35;
  }

  .event-index-select-field.is-disabled {
    opacity: 0.5;
  }

  .event-index-advanced__actions {
    display: flex;
    justify-content: flex-end;
    align-items: end;
  }

  .event-index-advanced__actions .btn {
    min-height: 50px;
    border-radius: 16px;
    font-weight: 700;
  }

  .event-index-summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.9rem;
    padding: 0.15rem 0 0.2rem;
    border-top: 1px solid rgba(15, 23, 42, 0.06);
  }

  .event-index-selection-toggle {
    display: inline-flex;
    align-items: center;
    gap: 0.65rem;
    min-height: 42px;
    padding: 0.72rem 0.9rem;
    border-radius: 16px;
    background: #faf2ee;
    border: 1px solid rgba(15, 23, 42, 0.08);
    color: #0f172a;
    font-weight: 700;
  }

  .event-index-summary-pills {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.65rem;
  }

  .event-index-summary-pills span {
    display: inline-flex;
    align-items: center;
    min-height: 38px;
    padding: 0.6rem 0.8rem;
    border-radius: 999px;
    background: #ffffff;
    border: 1px solid rgba(15, 23, 42, 0.06);
    color: #475569;
    font-size: 0.86rem;
    font-weight: 700;
  }

  .event-index-summary-pills strong {
    color: #0f172a;
    margin-left: 0.2rem;
  }

  .event-index-table-wrap {
    padding: 0.2rem 1.5rem 1.5rem;
  }

  .event-index-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 10px;
    margin: 0;
  }

  .event-index-table thead th {
    border: 0;
    background: transparent;
    color: #64748b;
    font-size: 0.76rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    font-weight: 800;
    padding: 0 0.85rem 0.2rem;
    white-space: nowrap;
  }

  .event-index-table tbody tr {
    background: #ffffff;
    box-shadow: 0 14px 28px rgba(15, 23, 42, 0.06);
  }

  .event-index-table tbody tr.is-expired {
    background: linear-gradient(180deg, #fffafa 0%, #fffdfd 100%);
  }

  .event-index-table tbody td {
    padding: 0.88rem 0.85rem;
    border-top: 1px solid rgba(15, 23, 42, 0.06);
    border-bottom: 1px solid rgba(15, 23, 42, 0.06);
    vertical-align: middle;
  }

  .event-index-table tbody td:first-child {
    border-left: 1px solid rgba(15, 23, 42, 0.06);
    border-radius: 18px 0 0 18px;
  }

  .event-index-table tbody td:last-child {
    border-right: 1px solid rgba(15, 23, 42, 0.06);
    border-radius: 0 18px 18px 0;
  }

  .event-index-check {
    width: 46px;
    text-align: center;
  }

  .event-index-table .bulk-check,
  .event-index-selection-toggle input,
  .event-index-card__check input {
    width: 18px;
    height: 18px;
    cursor: pointer;
  }

  .event-index-group__row {
    background: transparent !important;
    box-shadow: none !important;
  }

  .event-index-group__row td {
    padding: 0.6rem 0 0.35rem !important;
    border: 0 !important;
    background: transparent !important;
  }

  .event-index-group__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 1rem;
    padding: 0.82rem 0.95rem;
    border-radius: 18px;
    background: linear-gradient(180deg, #f8fbff 0%, #f2e7e3 100%);
    border: 1px solid rgba(15, 23, 42, 0.06);
  }

  .event-index-group__title {
    margin: 0;
    color: #0f172a;
    font-size: 0.96rem;
    font-weight: 800;
  }

  .event-index-group__hint {
    margin: 0.2rem 0 0;
    color: #64748b;
    font-size: 0.8rem;
  }

  .event-index-group__count {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 38px;
    height: 38px;
    padding: 0 0.8rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.08);
    color: #C1121F;
    font-size: 0.9rem;
    font-weight: 800;
  }

  .event-index-row {
    display: flex;
    align-items: stretch;
    gap: 0.85rem;
    min-width: 260px;
  }

  .event-index-row__media {
    position: relative;
    width: 124px;
    min-height: 102px;
    flex: 0 0 124px;
    border-radius: 18px;
    overflow: hidden;
    background: #e2e8f0;
    box-shadow: 0 12px 22px rgba(15, 23, 42, 0.14);
  }

  .event-index-row__thumb {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .event-index-row__media::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(15, 23, 42, 0.16) 0%, rgba(15, 23, 42, 0.05) 36%, rgba(15, 23, 42, 0.72) 100%);
    pointer-events: none;
  }

  .event-index-row__overlay {
    position: absolute;
    inset: 0;
    z-index: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 0.48rem;
  }

  .event-index-lifecycle {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    align-self: flex-start;
    padding: 0.34rem 0.62rem;
    border-radius: 999px;
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    box-shadow: 0 10px 18px rgba(15, 23, 42, 0.16);
  }

  .event-index-lifecycle--current {
    background: rgba(234, 246, 238, 0.96);
    color: #0f9d58;
  }

  .event-index-lifecycle--expired {
    background: rgba(255, 241, 242, 0.96);
    color: #e11d48;
  }

  .event-index-row__event-id,
  .event-index-card__event-id {
    display: inline-flex;
    align-items: center;
    align-self: flex-start;
    min-height: 32px;
    padding: 0.34rem 0.65rem;
    border-radius: 999px;
    background: rgba(15, 23, 42, 0.68);
    border: 1px solid rgba(255, 255, 255, 0.12);
    color: #ffffff;
    font-size: 0.74rem;
    font-weight: 800;
    letter-spacing: 0.04em;
    backdrop-filter: blur(10px);
  }

  .event-index-row__body {
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 0.38rem;
  }

  .event-index-row__title,
  .event-index-card__title {
    color: #0f172a;
    font-size: 1.02rem;
    font-weight: 800;
    line-height: 1.35;
    text-decoration: none !important;
  }

  .event-index-row__title:hover,
  .event-index-card__title:hover {
    color: #C1121F;
  }

  .event-index-row__meta,
  .event-index-card__meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.4rem 0.85rem;
    color: #64748b;
    font-size: 0.82rem;
  }

  .event-index-row__meta span,
  .event-index-card__meta span {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
  }

  .event-index-organizer {
    display: inline-flex;
    flex-direction: column;
    gap: 0.28rem;
  }

  .event-index-organizer__name {
    color: #0f172a;
    text-decoration: none !important;
    font-weight: 700;
    font-size: 0.92rem;
  }

  .event-index-organizer__name:hover {
    color: #C1121F;
  }

  .event-index-organizer__badge {
    display: inline-flex;
    align-items: center;
    width: fit-content;
    padding: 0.3rem 0.65rem;
    border-radius: 999px;
    background: #eaf6ee;
    color: #0f9d58;
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .event-index-badges {
    display: flex;
    flex-wrap: wrap;
    gap: 0.42rem;
  }

  .event-index-pill {
    display: inline-flex;
    align-items: center;
    padding: 0.3rem 0.66rem;
    border-radius: 999px;
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .event-index-pill--type {
    background: #ebf2ff;
    color: #C1121F;
  }

  .event-index-pill--category {
    background: #f4f7fb;
    color: #475569;
    text-transform: none;
    letter-spacing: 0;
  }

  .event-index-state-stack,
  .event-index-card__ops {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    min-width: 176px;
  }

  .event-index-state-stack form,
  .event-index-card__ops form {
    margin: 0;
  }

  .event-index-ticket-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.4rem;
    width: 100%;
    padding: 0.68rem 0.88rem;
    border-radius: 13px;
    background: linear-gradient(135deg, #0f9d58 0%, #2ecf5f 100%);
    color: #fff !important;
    text-decoration: none !important;
    font-weight: 700;
    box-shadow: 0 12px 24px rgba(46, 207, 95, 0.18);
  }

  .event-index-ticket-muted {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    min-height: 42px;
    padding: 0.68rem 0.88rem;
    border-radius: 12px;
    background: #eef2f7;
    color: #64748b;
    font-size: 0.86rem;
    font-weight: 600;
    text-align: center;
  }

  .event-index-state-stack .form-control,
  .event-index-card__ops .form-control {
    min-height: 42px;
    border-radius: 12px;
    border: 0;
    font-weight: 800;
    box-shadow: none;
    font-size: 0.9rem;
  }

  .event-index-state-stack .bg-primary,
  .event-index-state-stack .bg-warning,
  .event-index-state-stack .bg-success,
  .event-index-state-stack .bg-danger,
  .event-index-card__ops .bg-primary,
  .event-index-card__ops .bg-warning,
  .event-index-card__ops .bg-success,
  .event-index-card__ops .bg-danger {
    color: #fff !important;
  }

  .event-index-state-stack .bg-warning.text-dark,
  .event-index-card__ops .bg-warning.text-dark {
    color: #1e293b !important;
  }

  .event-index-actions {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 0.55rem;
    flex-wrap: wrap;
    min-width: 168px;
  }

  .event-index-primary-action {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.45rem;
    min-height: 42px;
    padding: 0.65rem 0.92rem;
    border-radius: 13px;
    text-decoration: none !important;
    background: linear-gradient(135deg, #0f172a 0%, #C1121F 100%);
    color: #ffffff;
    font-weight: 700;
    box-shadow: 0 14px 24px rgba(193, 18, 31, 0.14);
  }

  .event-index-primary-action--block {
    width: 100%;
  }

  .event-index-primary-action:hover,
  .event-index-primary-action:focus {
    color: #ffffff;
    outline: none;
  }

  .event-index-more {
    min-height: 42px;
    padding: 0.65rem 0.92rem;
    border-radius: 13px;
    border: 0;
    background: linear-gradient(135deg, #f7ece8 0%, #ead7d4 100%);
    color: #0f172a;
    font-weight: 800;
  }

  .event-index-manage {
    position: relative;
    z-index: 20;
  }

  .event-index-manage.show {
    z-index: 60;
  }

  .event-index-manage .dropdown-menu {
    z-index: 80;
    margin-top: 0.65rem;
    border: 1px solid rgba(15, 23, 42, 0.08);
    border-radius: 16px;
    box-shadow: 0 18px 38px rgba(15, 23, 42, 0.14);
    padding: 0.45rem;
  }

  .event-index-manage .dropdown-item {
    border-radius: 10px;
    font-weight: 700;
  }

  .event-index-manage .dropdown-item:hover,
  .event-index-manage .dropdown-item:focus {
    background: #f5f7ff;
    color: #C1121F;
  }

  .event-index-grid-wrap {
    padding: 0.2rem 1.5rem 1.5rem;
  }

  .event-index-card-group {
    display: flex;
    flex-direction: column;
    gap: 0.9rem;
  }

  .event-index-card-group + .event-index-card-group {
    margin-top: 1.1rem;
  }

  .event-index-grid {
    display: grid;
    grid-template-columns: repeat(var(--event-index-grid-columns, 3), minmax(0, 1fr));
    gap: 1rem;
    align-items: start;
    overflow: visible;
  }

  .event-index-card {
    position: relative;
    display: flex;
    flex-direction: column;
    border-radius: 24px;
    background: linear-gradient(180deg, #ffffff 0%, #fcfdff 100%);
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: 0 22px 34px rgba(15, 23, 42, 0.08);
    overflow: visible;
  }

  .event-index-card.is-expired {
    background: linear-gradient(180deg, #fffafa 0%, #fff6f7 100%);
  }

  .event-index-card.is-expired .event-index-card__hero {
    filter: saturate(0.72);
  }

  .event-index-grid-wrap--compact .event-index-card {
    border-radius: 20px;
  }

  .event-index-card__check {
    position: absolute;
    top: 1rem;
    left: 1rem;
    z-index: 2;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 34px;
    height: 34px;
    border-radius: 12px;
    background: rgba(248, 250, 252, 0.92);
    border: 1px solid rgba(15, 23, 42, 0.08);
    margin: 0;
    backdrop-filter: blur(8px);
  }

  .event-index-card__hero {
    position: relative;
    min-height: 220px;
    display: block;
    border-radius: 24px 24px 0 0;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
    overflow: hidden;
    background-color: #0f172a;
  }

  .event-index-card__hero::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(15, 23, 42, 0.08) 0%, rgba(15, 23, 42, 0.16) 40%, rgba(15, 23, 42, 0.78) 100%);
  }

  .event-index-grid-wrap--compact .event-index-card__hero {
    min-height: 188px;
    border-radius: 20px 20px 0 0;
  }

  .event-index-card__hero-top {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    z-index: 2;
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 0.6rem;
    padding: 1rem 1rem 0;
  }

  .event-index-card__hero-overlay {
    position: absolute;
    inset: 0;
    z-index: 2;
    display: flex;
    align-items: flex-end;
    justify-content: flex-start;
    gap: 0.6rem;
    padding: 1rem;
  }

  .event-index-card__hero-copy {
    display: flex;
    flex-direction: column;
    gap: 0.3rem;
    max-width: 88%;
  }

  .event-index-card__eyebrow {
    display: inline-flex;
    align-items: center;
    width: fit-content;
    padding: 0.3rem 0.55rem;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.12);
    border: 1px solid rgba(255, 255, 255, 0.14);
    color: rgba(255, 255, 255, 0.88);
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    backdrop-filter: blur(10px);
  }

  .event-index-card__hero-title {
    color: #ffffff;
    font-size: 1.18rem;
    font-weight: 800;
    line-height: 1.2;
    text-shadow: 0 10px 26px rgba(15, 23, 42, 0.42);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .event-index-card__hero-owner {
    color: rgba(255, 255, 255, 0.82);
    font-size: 0.84rem;
    font-weight: 700;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .event-index-card__body {
    display: flex;
    flex-direction: column;
    gap: 0.82rem;
    padding: 1rem 1rem 1.05rem;
  }

  .event-index-grid-wrap--compact .event-index-card__body {
    padding: 0.88rem;
  }

  .event-index-card__ops {
    border-top: 1px solid rgba(15, 23, 42, 0.06);
    padding-top: 0.9rem;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.55rem;
    min-width: 0;
  }

  .event-index-card__ops .event-index-ticket-button,
  .event-index-card__ops .event-index-ticket-muted {
    grid-column: 1 / -1;
  }

  .event-index-card__footer {
    display: flex;
    align-items: center;
    gap: 0.65rem;
    margin-top: auto;
  }

  .event-index-card__manage {
    flex: 0 0 auto;
  }

  .event-index-card__manage .btn {
    min-width: 92px;
  }

  .event-index-card__body .event-index-badges {
    gap: 0.42rem;
  }

  .event-index-card__body .event-index-pill--category {
    background: #f5f7fb;
  }

  .event-index-empty {
    padding: 3.5rem 1.5rem;
    text-align: center;
    color: #64748b;
  }

  .event-index-empty__title {
    margin: 0.65rem 0 0.35rem;
    color: #0f172a;
    font-size: 1.3rem;
    font-weight: 800;
  }

  .event-index-empty__text {
    max-width: 560px;
    margin: 0 auto;
    line-height: 1.6;
  }

  .event-index-pagination {
    padding: 0 1.5rem 1.5rem;
    text-align: center;
  }

  @media (max-width: 1399.98px) {
    .event-index-advanced__form {
      grid-template-columns: repeat(3, minmax(0, 1fr));
    }
  }

  @media (max-width: 1199.98px) {
    .event-index-primary-form {
      grid-template-columns: minmax(0, 1fr) minmax(180px, 0.8fr) auto;
    }

    .event-index-view-switch {
      justify-self: stretch;
      grid-column: 1 / -1;
    }

    .event-index-nav-row {
      grid-template-columns: 1fr;
    }

    .event-index-grid {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
  }

  @media (max-width: 991.98px) {
    .event-index-topbar {
      flex-direction: column;
      align-items: stretch;
    }

    .event-index-topbar__actions {
      justify-content: flex-start;
    }

    .event-index-primary-form {
      grid-template-columns: 1fr;
    }

    .event-index-primary-form__actions {
      order: 4;
    }

    .event-index-view-switch {
      order: 5;
      justify-self: stretch;
    }

    .event-index-advanced__form {
      grid-template-columns: 1fr 1fr;
    }

    .event-index-summary-row {
      flex-direction: column;
      align-items: stretch;
    }

    .event-index-advanced summary {
      flex-direction: column;
      align-items: flex-start;
    }
  }

  @media (max-width: 767.98px) {
    .event-index-workbench,
    .event-index-table-wrap,
    .event-index-grid-wrap,
    .event-index-pagination {
      padding-left: 1rem;
      padding-right: 1rem;
    }

    .event-index-row {
      min-width: 220px;
      align-items: flex-start;
    }

    .event-index-row__media {
      width: 96px;
      min-height: 88px;
      flex-basis: 96px;
    }

    .event-index-advanced__form {
      grid-template-columns: 1fr;
    }

    .event-index-grid {
      grid-template-columns: 1fr;
    }

    .event-index-card__footer {
      flex-direction: column;
      align-items: stretch;
    }

    .event-index-card__manage .btn {
      width: 100%;
    }
  }
</style>
