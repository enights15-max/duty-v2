<style>
  .event-media-workbench {
    margin: 1.25rem 0 2rem;
    border: 1px solid rgba(108, 117, 125, 0.18);
    border-radius: 24px;
    padding: 1.25rem;
    background:
      radial-gradient(circle at top left, rgba(0, 108, 255, 0.08), transparent 32%),
      radial-gradient(circle at bottom right, rgba(255, 0, 98, 0.06), transparent 30%),
      #0f1723;
    color: #eef2ff;
    box-shadow: 0 20px 45px rgba(15, 23, 35, 0.14);
  }

  .event-media-workbench__header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .event-media-workbench__eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.3rem 0.75rem;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.08);
    color: #a5b4fc;
    font-size: 0.74rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    font-weight: 700;
  }

  .event-media-workbench__title {
    margin: 0.55rem 0 0.35rem;
    font-size: 1.15rem;
    font-weight: 700;
    color: #fff;
  }

  .event-media-workbench__description {
    margin: 0;
    color: rgba(226, 232, 240, 0.72);
    max-width: 680px;
    line-height: 1.55;
  }

  .event-media-workbench__targets {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 0.75rem;
    margin: 1rem 0 1.25rem;
  }

  .event-media-target {
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 16px;
    padding: 0.85rem 0.95rem;
    background: rgba(255, 255, 255, 0.04);
  }

  .event-media-target__label {
    display: block;
    font-size: 0.76rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: rgba(165, 180, 252, 0.9);
    margin-bottom: 0.35rem;
    font-weight: 700;
  }

  .event-media-target__value {
    display: block;
    font-size: 1rem;
    font-weight: 700;
    color: #fff;
  }

  .event-media-preview {
    display: grid;
    grid-template-columns: minmax(0, 2.3fr) minmax(280px, 1fr);
    gap: 1rem;
  }

  .event-media-preview__hero {
    position: relative;
    min-height: 260px;
    border-radius: 22px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.08);
    background: #020617;
  }

  .event-media-preview__hero-image {
    width: 100%;
    height: 100%;
    min-height: 260px;
    object-fit: cover;
    display: block;
    filter: saturate(1.02);
  }

  .event-media-preview__hero::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(2, 6, 23, 0.12) 0%, rgba(2, 6, 23, 0.85) 100%);
    pointer-events: none;
  }

  .event-media-preview__hero-content {
    position: absolute;
    inset: auto 0 0 0;
    padding: 1.15rem 1.15rem 1rem;
    z-index: 1;
  }

  .event-media-preview__hero-meta {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.28rem 0.7rem;
    border-radius: 999px;
    background: rgba(15, 23, 35, 0.45);
    color: rgba(226, 232, 240, 0.9);
    font-size: 0.74rem;
    margin-bottom: 0.7rem;
    backdrop-filter: blur(8px);
  }

  .event-media-preview__hero-title {
    color: #fff;
    font-size: 1.55rem;
    line-height: 1.1;
    margin: 0 0 0.5rem;
    font-weight: 800;
    text-transform: uppercase;
  }

  .event-media-preview__hero-subtitle {
    color: rgba(226, 232, 240, 0.84);
    margin: 0;
    font-size: 0.95rem;
  }

  .event-media-preview__sidebar {
    border-radius: 22px;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.08);
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .event-media-preview__sidebar-label {
    font-size: 0.78rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: rgba(165, 180, 252, 0.92);
    font-weight: 700;
  }

  .event-media-preview__card {
    border-radius: 18px;
    overflow: hidden;
    background: rgba(2, 6, 23, 0.88);
    border: 1px solid rgba(255, 255, 255, 0.08);
  }

  .event-media-preview__thumb-image {
    width: 100%;
    aspect-ratio: 320 / 230;
    object-fit: cover;
    display: block;
    background: #0f1723;
  }

  .event-media-preview__card-body {
    padding: 0.9rem 1rem 1rem;
  }

  .event-media-preview__card-title {
    margin: 0 0 0.35rem;
    color: #fff;
    font-size: 1rem;
    font-weight: 700;
  }

  .event-media-preview__card-meta {
    display: flex;
    flex-direction: column;
    gap: 0.4rem;
    color: rgba(226, 232, 240, 0.72);
    font-size: 0.86rem;
  }

  .event-media-preview__hint {
    margin: 0;
    font-size: 0.85rem;
    line-height: 1.5;
    color: rgba(226, 232, 240, 0.72);
  }

  #my-dropzone.dropzone .dz-preview {
    margin: 14px;
  }

  #my-dropzone.dropzone .dz-preview .dz-image {
    position: relative;
    width: 188px;
    height: 92px;
    border-radius: 16px;
    overflow: hidden;
    background: #0f1723;
    box-shadow: 0 10px 24px rgba(15, 23, 35, 0.12);
  }

  #my-dropzone.dropzone .dz-preview .dz-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  #my-dropzone.dropzone .dz-preview .dz-details {
    width: 188px;
    min-width: 188px;
  }

  #my-dropzone.dropzone .dz-preview.event-media-gallery-preview .dz-image::after {
    content: '1170 × 570';
    position: absolute;
    left: 10px;
    bottom: 10px;
    padding: 0.18rem 0.52rem;
    border-radius: 999px;
    background: rgba(15, 23, 35, 0.7);
    color: #fff;
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 0.04em;
  }

  .event-image-cropper .modal-dialog {
    max-width: 1080px;
  }

  .event-image-cropper .modal-content {
    border: 0;
    border-radius: 24px;
    overflow: hidden;
    background: #0f1723;
    color: #eef2ff;
    box-shadow: 0 28px 72px rgba(2, 6, 23, 0.45);
  }

  .event-image-cropper .modal-header,
  .event-image-cropper .modal-footer {
    border-color: rgba(255, 255, 255, 0.08);
  }

  .event-image-cropper .close {
    color: #fff;
    opacity: 0.8;
    text-shadow: none;
  }

  .event-image-cropper__layout {
    display: grid;
    grid-template-columns: minmax(0, 2fr) minmax(260px, 0.9fr);
    gap: 1.25rem;
    align-items: start;
  }

  .event-image-cropper__stage {
    border-radius: 22px;
    padding: 1rem;
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.03), rgba(255, 255, 255, 0.02));
    border: 1px solid rgba(255, 255, 255, 0.08);
  }

  .event-image-cropper__canvas-wrap {
    width: 100%;
    border-radius: 18px;
    overflow: hidden;
    background:
      linear-gradient(45deg, rgba(148, 163, 184, 0.08) 25%, transparent 25%),
      linear-gradient(-45deg, rgba(148, 163, 184, 0.08) 25%, transparent 25%),
      linear-gradient(45deg, transparent 75%, rgba(148, 163, 184, 0.08) 75%),
      linear-gradient(-45deg, transparent 75%, rgba(148, 163, 184, 0.08) 75%);
    background-size: 32px 32px;
    background-position: 0 0, 0 16px, 16px -16px, -16px 0;
    user-select: none;
  }

  .event-image-cropper__canvas {
    display: block;
    width: 100%;
    height: auto;
    cursor: grab;
  }

  .event-image-cropper__canvas.is-dragging {
    cursor: grabbing;
  }

  .event-image-cropper__controls {
    border-radius: 22px;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .event-image-cropper__target {
    padding: 0.9rem 1rem;
    border-radius: 16px;
    background: rgba(129, 140, 248, 0.12);
    border: 1px solid rgba(129, 140, 248, 0.2);
  }

  .event-image-cropper__target-label {
    display: block;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    font-size: 0.72rem;
    color: #a5b4fc;
    font-weight: 700;
    margin-bottom: 0.3rem;
  }

  .event-image-cropper__target-value {
    display: block;
    font-size: 1.05rem;
    color: #fff;
    font-weight: 700;
  }

  .event-image-cropper__range-wrap label {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.87rem;
    color: rgba(226, 232, 240, 0.84);
    margin-bottom: 0.4rem;
  }

  .event-image-cropper__range {
    width: 100%;
  }

  .event-image-cropper__mini {
    border-radius: 16px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.08);
    background: #020617;
  }

  .event-image-cropper__mini img {
    width: 100%;
    display: block;
  }

  .event-image-cropper__tips {
    margin: 0;
    padding-left: 1rem;
    color: rgba(226, 232, 240, 0.72);
    font-size: 0.85rem;
    line-height: 1.5;
  }

  .event-image-cropper__tips li + li {
    margin-top: 0.35rem;
  }

  @media (max-width: 991px) {
    .event-media-preview,
    .event-image-cropper__layout {
      grid-template-columns: 1fr;
    }

    .event-media-preview__hero {
      min-height: 220px;
    }

    .event-media-preview__hero-image {
      min-height: 220px;
    }
  }
</style>
