<style>
  .ops-shell {
    display: grid;
    gap: 1.25rem;
  }

  .ops-hero {
    position: relative;
    overflow: hidden;
    border-radius: 28px;
    padding: 1.35rem 1.5rem;
    background:
      radial-gradient(circle at top right, rgba(225, 85, 98, 0.14), transparent 26%),
      linear-gradient(135deg, #170D12 0%, #2A1115 52%, #8A0F18 100%);
    color: #FFF8F4;
    box-shadow: 0 22px 44px rgba(17, 10, 14, 0.14);
  }

  .ops-hero::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.04));
    pointer-events: none;
  }

  .ops-hero__grid {
    position: relative;
    z-index: 1;
    display: grid;
    grid-template-columns: minmax(0, 1.4fr) minmax(240px, 0.9fr);
    gap: 1rem;
    align-items: start;
  }

  .ops-hero__eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.34rem 0.72rem;
    border-radius: 999px;
    background: rgba(255, 248, 244, 0.08);
    border: 1px solid rgba(255, 248, 244, 0.12);
    color: rgba(255, 248, 244, 0.82);
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.12em;
  }

  .ops-hero__title {
    margin: 0.8rem 0 0.4rem;
    color: #FFF8F4;
    font-size: clamp(1.45rem, 3vw, 2.15rem);
    line-height: 1.02;
    font-weight: 800;
  }

  .ops-hero__copy {
    margin: 0;
    max-width: 760px;
    color: rgba(255, 248, 244, 0.76);
    line-height: 1.62;
    font-size: 0.95rem;
  }

  .ops-hero__meta {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.75rem;
  }

  .ops-hero__stat {
    min-height: 112px;
    border-radius: 20px;
    padding: 1rem;
    background: rgba(255, 248, 244, 0.08);
    border: 1px solid rgba(255, 248, 244, 0.12);
    backdrop-filter: blur(8px);
  }

  .ops-hero__stat-label {
    display: block;
    margin-bottom: 0.45rem;
    color: rgba(255, 248, 244, 0.62);
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 0.11em;
    text-transform: uppercase;
  }

  .ops-hero__stat-value {
    display: block;
    color: #FFF8F4;
    font-size: 1.35rem;
    font-weight: 800;
    line-height: 1.08;
  }

  .ops-hero__stat-note {
    display: block;
    margin-top: 0.45rem;
    color: rgba(255, 248, 244, 0.7);
    font-size: 0.86rem;
    line-height: 1.45;
  }

  .ops-metric-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
    gap: 0.95rem;
  }

  .ops-metric {
    border-radius: 22px;
    border: 1px solid var(--panel-border);
    background: var(--panel-surface);
    box-shadow: var(--scarlet-shadow);
    padding: 1rem 1.05rem;
  }

  .ops-metric__label {
    display: block;
    margin-bottom: 0.45rem;
    color: var(--panel-text-muted);
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .ops-metric__value {
    display: block;
    color: var(--panel-text);
    font-size: 1.35rem;
    font-weight: 800;
    line-height: 1.05;
  }

  .ops-metric__value.is-warning { color: #C68500; }
  .ops-metric__value.is-success { color: #238A57; }
  .ops-metric__value.is-danger { color: #D32F2F; }
  .ops-metric__value.is-primary { color: #C1121F; }

  .ops-panel {
    border-radius: 28px !important;
    border: 1px solid var(--panel-border) !important;
    background: var(--panel-surface) !important;
    box-shadow: var(--scarlet-shadow) !important;
    overflow: hidden;
  }

  .ops-panel .card-header {
    padding: 1.2rem 1.35rem;
    border-bottom: 1px solid var(--panel-border) !important;
  }

  .ops-panel .card-title {
    font-size: 1.08rem;
    font-weight: 800;
  }

  .ops-panel .card-body {
    padding: 1.25rem 1.35rem;
  }

  .ops-toolbar {
    display: grid;
    gap: 0.9rem;
  }

  .ops-toolbar__grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 0.85rem;
    align-items: end;
  }

  .ops-toolbar__label {
    display: block;
    margin-bottom: 0.42rem;
    color: var(--panel-text-muted);
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .ops-toolbar__actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
    align-items: center;
  }

  .ops-note {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.52rem 0.8rem;
    border-radius: 999px;
    background: rgba(193, 18, 31, 0.08);
    border: 1px solid rgba(193, 18, 31, 0.15);
    color: #8A0F18;
    font-size: 0.82rem;
    font-weight: 700;
  }

  .ops-table {
    margin-top: 0.5rem;
  }

  .ops-table thead th {
    white-space: nowrap;
  }

  .ops-table td {
    vertical-align: middle;
  }

  .ops-empty {
    padding: 3.25rem 1rem;
    text-align: center;
  }

  .ops-empty h3,
  .ops-empty h4 {
    margin-bottom: 0.45rem;
    color: var(--panel-text);
    font-weight: 800;
  }

  .ops-empty p {
    margin: 0;
    color: var(--panel-text-muted);
  }

  .ops-stacked-list {
    display: grid;
    gap: 0.95rem;
  }

  .ops-stack-card {
    padding: 1rem 1.05rem;
    border-radius: 18px;
    border: 1px solid var(--panel-border);
    background: var(--panel-surface-strong);
  }

  .ops-stack-card__label {
    display: block;
    margin-bottom: 0.38rem;
    color: var(--panel-text-muted);
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .ops-stack-card__value {
    display: block;
    color: var(--panel-text);
    font-size: 1rem;
    font-weight: 700;
    line-height: 1.45;
  }

  @media (max-width: 991.98px) {
    .ops-hero__grid {
      grid-template-columns: 1fr;
    }

    .ops-hero__meta {
      grid-template-columns: 1fr;
    }
  }
</style>
