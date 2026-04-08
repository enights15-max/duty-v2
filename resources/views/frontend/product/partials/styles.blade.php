<style>
    .product-surface {
        position: relative;
        overflow: hidden;
        padding: 156px 0 96px;
        color: var(--text-primary);
    }

    .product-surface::before,
    .product-surface::after {
        content: '';
        position: absolute;
        border-radius: 50%;
        pointer-events: none;
        filter: blur(18px);
        opacity: 0.7;
    }

    .product-surface::before {
        width: 320px;
        height: 320px;
        top: 80px;
        left: -100px;
        background: radial-gradient(circle, rgba(140, 37, 244, 0.28), transparent 68%);
    }

    .product-surface::after {
        width: 260px;
        height: 260px;
        top: 160px;
        right: -80px;
        background: radial-gradient(circle, rgba(255, 207, 90, 0.12), transparent 68%);
    }

    .product-surface__grid {
        position: absolute;
        inset: 0;
        background-image:
            linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
        background-size: 34px 34px;
        opacity: 0.2;
        mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.88), transparent 90%);
        pointer-events: none;
    }

    .product-surface__eyebrow {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 10px 16px;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.08);
        color: rgba(255, 255, 255, 0.84);
        font-size: 12px;
        font-weight: 800;
        letter-spacing: 0.18em;
        text-transform: uppercase;
    }

    .product-surface__eyebrow-dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: linear-gradient(135deg, #ffcf5a, #8c25f4);
        box-shadow: 0 0 18px rgba(140, 37, 244, 0.48);
    }

    .product-surface__title {
        margin: 22px 0 0;
        font-family: var(--pjs);
        font-size: clamp(2.85rem, 5vw, 5.25rem);
        line-height: 0.96;
        letter-spacing: -0.05em;
        max-width: 760px;
    }

    .product-surface__title-accent {
        display: block;
        color: #d7adff;
    }

    .product-surface__copy {
        max-width: 660px;
        margin: 22px 0 0;
        color: var(--text-secondary);
        font-size: 18px;
        line-height: 1.85;
    }

    .product-surface__hero-layout {
        display: grid;
        grid-template-columns: minmax(0, 1.02fr) minmax(340px, 0.98fr);
        gap: 30px;
        align-items: start;
    }

    .product-surface__hero-main {
        min-width: 0;
    }

    .product-surface__hero-side {
        display: grid;
        gap: 18px;
    }

    .product-surface__actions {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
        margin-top: 30px;
    }

    .product-surface__action,
    .product-surface__ghost {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        min-height: 54px;
        padding: 0 22px;
        border-radius: 18px;
        font-weight: 800;
        font-family: var(--pjs);
        letter-spacing: 0.01em;
        transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
    }

    .product-surface__action {
        color: #fff;
        background: linear-gradient(135deg, #8c25f4 0%, #a95fff 100%);
        box-shadow: 0 18px 34px rgba(140, 37, 244, 0.26);
    }

    .product-surface__ghost {
        color: #fff;
        border: 1px solid rgba(255, 255, 255, 0.1);
        background: rgba(255, 255, 255, 0.04);
    }

    .product-surface__action:hover,
    .product-surface__ghost:hover {
        color: #fff;
        transform: translateY(-1px);
    }

    .product-surface__proof-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
        margin-top: 28px;
    }

    .product-surface__proof-card,
    .product-surface__panel,
    .product-surface__download-card,
    .product-surface__info-card,
    .product-surface__workflow-card,
    .product-surface__store-card {
        position: relative;
        overflow: hidden;
        border-radius: 28px;
        background: linear-gradient(180deg, rgba(33, 22, 46, 0.92), rgba(16, 10, 24, 0.92));
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: var(--surface-shadow);
    }

    .product-surface__proof-card {
        padding: 22px;
    }

    .product-surface__access-card,
    .product-surface__store-hero-card {
        position: relative;
        overflow: hidden;
        border-radius: 30px;
        padding: 28px;
        background: linear-gradient(180deg, rgba(33, 22, 46, 0.94), rgba(16, 10, 24, 0.94));
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: var(--surface-shadow);
    }

    .product-surface__access-card::before,
    .product-surface__store-hero-card::before {
        content: '';
        position: absolute;
        inset: 0;
        background: radial-gradient(circle at top right, rgba(140, 37, 244, 0.16), transparent 48%);
        pointer-events: none;
    }

    .product-surface__access-flow {
        display: grid;
        gap: 14px;
        margin-top: 22px;
    }

    .product-surface__flow-step {
        display: grid;
        gap: 6px;
        padding: 16px 18px;
        border-radius: 22px;
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(255, 255, 255, 0.06);
    }

    .product-surface__flow-step small {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: rgba(140, 37, 244, 0.18);
        color: #fff;
        font-size: 12px;
        font-weight: 800;
    }

    .product-surface__flow-step strong {
        color: #fff;
        font-size: 1rem;
        font-weight: 700;
    }

    .product-surface__flow-step span {
        color: var(--text-secondary);
        font-size: 14px;
        line-height: 1.7;
    }

    .product-surface__device-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 16px;
        margin-top: 18px;
    }

    .product-surface__device-tile {
        display: grid;
        gap: 8px;
        min-height: 160px;
        padding: 20px;
        border-radius: 24px;
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(255, 255, 255, 0.08);
    }

    .product-surface__device-tile small {
        color: rgba(255, 255, 255, 0.64);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.14em;
        text-transform: uppercase;
    }

    .product-surface__device-tile strong {
        color: #fff;
        font-size: 1.05rem;
        line-height: 1.3;
    }

    .product-surface__device-tile span {
        color: var(--text-secondary);
        font-size: 14px;
        line-height: 1.75;
    }

    .product-surface__proof-value {
        display: block;
        color: #fff;
        font-family: var(--pjs);
        font-size: clamp(1.9rem, 3vw, 2.7rem);
        letter-spacing: -0.04em;
    }

    .product-surface__proof-label {
        display: block;
        margin-top: 8px;
        color: var(--text-secondary);
        font-size: 14px;
        line-height: 1.7;
    }

    .product-surface__layout {
        display: grid;
        grid-template-columns: minmax(0, 1.16fr) minmax(340px, 0.84fr);
        gap: 28px;
        margin-top: 54px;
    }

    .product-surface__panel {
        padding: 28px;
    }

    .product-surface__panel-title {
        margin: 0 0 12px;
        font-size: 1.2rem;
        letter-spacing: -0.02em;
    }

    .product-surface__panel-copy {
        margin: 0;
        color: var(--text-secondary);
        line-height: 1.8;
    }

    .product-surface__pillars {
        display: grid;
        gap: 16px;
    }

    .product-surface__pillar {
        padding: 22px;
        border-radius: 24px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.06);
    }

    .product-surface__pillar h3 {
        margin: 0 0 8px;
        font-size: 1.1rem;
    }

    .product-surface__pillar p,
    .product-surface__workflow-list li,
    .product-surface__store-copy,
    .product-surface__info-copy {
        color: var(--text-secondary);
        line-height: 1.8;
    }

    .product-surface__workflow-list {
        list-style: none;
        padding: 0;
        margin: 0;
        display: grid;
        gap: 14px;
    }

    .product-surface__workflow-list li {
        display: flex;
        gap: 14px;
        align-items: flex-start;
    }

    .product-surface__workflow-list li::before {
        content: '\2713';
        flex: 0 0 auto;
        width: 24px;
        height: 24px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        margin-top: 2px;
        background: rgba(140, 37, 244, 0.16);
        color: #fff;
        font-size: 13px;
        font-weight: 700;
    }

    .product-surface__info-card,
    .product-surface__download-card,
    .product-surface__workflow-card,
    .product-surface__store-card {
        padding: 28px;
    }

    .product-surface__tag {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 14px;
        padding: 9px 14px;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(255, 255, 255, 0.08);
        color: rgba(255, 255, 255, 0.8);
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.14em;
    }

    .product-surface__mini-stat-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
        margin-top: 22px;
    }

    .product-surface__mini-stat {
        padding: 18px;
        border-radius: 20px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.06);
    }

    .product-surface__mini-stat strong {
        display: block;
        font-family: var(--pjs);
        font-size: 1.6rem;
        letter-spacing: -0.04em;
    }

    .product-surface__mini-stat span {
        color: var(--text-secondary);
        font-size: 13px;
        line-height: 1.7;
    }

    .product-surface__download-stack {
        display: grid;
        gap: 18px;
        margin-top: 52px;
    }

    .product-surface__store-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 16px;
        margin-top: 18px;
    }

    .product-surface__store-button {
        display: flex;
        flex-direction: column;
        justify-content: center;
        min-height: 132px;
        padding: 22px;
        border-radius: 24px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        background: rgba(255, 255, 255, 0.03);
        color: #fff;
        transition: transform 0.22s ease, border-color 0.22s ease, background 0.22s ease;
    }

    .product-surface__store-button:hover {
        color: #fff;
        transform: translateY(-1px);
        border-color: rgba(140, 37, 244, 0.34);
        background: rgba(140, 37, 244, 0.08);
    }

    .product-surface__store-button small {
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.14em;
        font-size: 11px;
        font-weight: 700;
    }

    .product-surface__store-button strong {
        display: block;
        margin-top: 10px;
        font-family: var(--pjs);
        font-size: 1.2rem;
        line-height: 1.25;
    }

    .product-surface__store-button span {
        display: block;
        margin-top: 8px;
        color: var(--text-secondary);
        font-size: 14px;
        line-height: 1.7;
    }

    .product-surface__store-button--disabled {
        opacity: 0.72;
        cursor: default;
    }

    .product-surface__store-button--disabled:hover {
        transform: none;
        border-color: rgba(255, 255, 255, 0.08);
        background: rgba(255, 255, 255, 0.03);
    }

    .product-surface__footer-band {
        margin-top: 28px;
        padding: 22px 24px;
        border-radius: 24px;
        background: linear-gradient(135deg, rgba(140, 37, 244, 0.14), rgba(255, 207, 90, 0.05));
        border: 1px solid rgba(255, 255, 255, 0.08);
    }

    .product-surface__footer-band h3 {
        margin: 0 0 8px;
    }

    .product-surface__footer-band p {
        margin: 0;
        color: var(--text-secondary);
        line-height: 1.8;
    }

    @media (max-width: 1199.98px) {
        .product-surface__hero-layout,
        .product-surface__layout {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 991.98px) {
        .product-surface {
            padding: 138px 0 84px;
        }

        .product-surface__proof-grid,
        .product-surface__device-grid,
        .product-surface__store-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 767.98px) {
        .product-surface__title {
            font-size: 2.55rem;
        }

        .product-surface__actions {
            flex-direction: column;
        }

        .product-surface__action,
        .product-surface__ghost {
            width: 100%;
        }

        .product-surface__mini-stat-grid {
            grid-template-columns: 1fr;
        }
    }
</style>
