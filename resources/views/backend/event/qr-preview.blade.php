@extends($layout)

@section('content')
  <div class="page-header">
    <h4 class="page-title">{{ __('Event QR') }}</h4>
    <ul class="breadcrumbs">
      <li class="nav-home">
        <a href="{{ $dashboardRoute }}">
          <i class="flaticon-home"></i>
        </a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="{{ $listingRoute }}">{{ __('Events') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="{{ $editRoute }}">{{ __('Edit Event') }}</a>
      </li>
      <li class="separator">
        <i class="flaticon-right-arrow"></i>
      </li>
      <li class="nav-item">
        <a href="#">{{ __('Event QR') }}</a>
      </li>
    </ul>
  </div>

  <style>
    .event-qr-shell {
      display: grid;
      gap: 1.5rem;
      grid-template-columns: minmax(320px, 420px) minmax(320px, 1fr);
    }

    .event-qr-card,
    .event-qr-panel {
      background: #fff;
      border: 1px solid rgba(17, 24, 39, 0.08);
      border-radius: 24px;
      box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
    }

    .event-qr-card {
      padding: 1.5rem;
      text-align: center;
    }

    .event-qr-card__eyebrow {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-size: .8rem;
      font-weight: 700;
      letter-spacing: .08em;
      text-transform: uppercase;
      color: #7c3aed;
      background: rgba(124, 58, 237, 0.12);
      border-radius: 999px;
      padding: .45rem .8rem;
      margin-bottom: 1rem;
    }

    .event-qr-card__title {
      font-size: 1.2rem;
      font-weight: 700;
      color: #111827;
      margin-bottom: .5rem;
    }

    .event-qr-card__meta {
      color: #6b7280;
      font-size: .95rem;
      margin-bottom: 1.25rem;
    }

    .event-qr-frame {
      display: grid;
      place-items: center;
      background: linear-gradient(180deg, #f8fafc 0%, #eef2ff 100%);
      border: 1px solid rgba(124, 58, 237, 0.12);
      border-radius: 24px;
      min-height: 360px;
      padding: 1rem;
    }

    .event-qr-frame img {
      width: min(100%, 320px);
      height: auto;
      display: block;
    }

    .event-qr-card__hint {
      margin-top: 1rem;
      color: #6b7280;
      font-size: .92rem;
      line-height: 1.6;
    }

    .event-qr-panel {
      padding: 1.75rem;
    }

    .event-qr-panel__kicker {
      font-size: .82rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: .08em;
      color: #7c3aed;
      margin-bottom: .75rem;
    }

    .event-qr-panel__title {
      font-size: 1.5rem;
      font-weight: 700;
      color: #111827;
      margin-bottom: .75rem;
    }

    .event-qr-panel__copy {
      color: #4b5563;
      line-height: 1.75;
      margin-bottom: 1.5rem;
      max-width: 58ch;
    }

    .event-qr-actions {
      display: flex;
      flex-wrap: wrap;
      gap: .75rem;
      margin-bottom: 1.5rem;
    }

    .event-qr-link-box {
      border: 1px solid rgba(17, 24, 39, 0.08);
      border-radius: 18px;
      padding: 1rem;
      background: #f9fafb;
      margin-bottom: 1.25rem;
    }

    .event-qr-link-box label {
      display: block;
      font-size: .85rem;
      font-weight: 700;
      color: #374151;
      margin-bottom: .5rem;
    }

    .event-qr-link-row {
      display: flex;
      gap: .75rem;
      align-items: center;
    }

    .event-qr-link-row input {
      flex: 1;
      border: 1px solid rgba(17, 24, 39, 0.12);
      border-radius: 12px;
      padding: .85rem 1rem;
      background: #fff;
      color: #111827;
      font-size: .95rem;
    }

    .event-qr-notes {
      display: grid;
      gap: .85rem;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    }

    .event-qr-note {
      border: 1px solid rgba(17, 24, 39, 0.08);
      border-radius: 18px;
      padding: 1rem;
      background: #fff;
    }

    .event-qr-note strong {
      display: block;
      color: #111827;
      margin-bottom: .35rem;
    }

    .event-qr-note span {
      color: #6b7280;
      font-size: .92rem;
      line-height: 1.6;
    }

    @media (max-width: 991px) {
      .event-qr-shell {
        grid-template-columns: 1fr;
      }
    }
  </style>

  <div class="event-qr-shell">
    <section class="event-qr-card">
      <span class="event-qr-card__eyebrow">{{ $workspaceKicker }}</span>
      <h3 class="event-qr-card__title">{{ $eventTitle }}</h3>
      <p class="event-qr-card__meta">
        {{ $workspaceLabel }} · {{ $eventRecord->status == 1 ? __('Active') : __('Draft / Inactive') }}
      </p>

      <div class="event-qr-frame">
        <img src="{{ $qrSvgUrl }}" alt="{{ __('QR for :event', ['event' => $eventTitle]) }}">
      </div>

      <p class="event-qr-card__hint">
        {{ __('Use this QR on flyers, stories, posters or table signage. Fans can scan it from the app and jump straight into the event flow.') }}
      </p>
    </section>

    <section class="event-qr-panel">
      <div class="event-qr-panel__kicker">{{ __('Scan-ready campaign asset') }}</div>
      <h2 class="event-qr-panel__title">{{ __('Share this event faster across physical and social surfaces') }}</h2>
      <p class="event-qr-panel__copy">
        {{ __('This MVP exports the event QR as SVG, which works well for Canva, Figma, print and social design tools. The QR points to the Duty event bridge so app users land directly on the event and new users are guided into the app flow.') }}
      </p>

      <div class="event-qr-actions">
        <a href="{{ $downloadSvgUrl }}" class="btn btn-primary">
          <i class="fas fa-download mr-1"></i>
          {{ __('Download SVG') }}
        </a>
        <a href="{{ $editRoute }}" class="btn btn-light">
          <i class="fas fa-pen mr-1"></i>
          {{ __('Back to Event') }}
        </a>
      </div>

      <div class="event-qr-link-box">
        <label for="eventQrScanLink">{{ __('Scan link') }}</label>
        <div class="event-qr-link-row">
          <input id="eventQrScanLink" type="text" readonly value="{{ $scanLink }}">
          <button type="button" class="btn btn-outline-secondary" onclick="copyEventQrLink()">
            <i class="far fa-copy mr-1"></i>
            {{ __('Copy') }}
          </button>
        </div>
      </div>

      <div class="event-qr-notes">
        <div class="event-qr-note">
          <strong>{{ __('How fans use it') }}</strong>
          <span>{{ __('Scan with the Duty scanner to open event details and move quickly toward purchase.') }}</span>
        </div>
        <div class="event-qr-note">
          <strong>{{ __('Best uses') }}</strong>
          <span>{{ __('Stories, flyers, posters, booth signage, DJ posts and venue screens.') }}</span>
        </div>
        <div class="event-qr-note">
          <strong>{{ __('Current format') }}</strong>
          <span>{{ __('SVG is available in this MVP. It stays sharp for print and can be converted in most design tools.') }}</span>
        </div>
      </div>
    </section>
  </div>

  <script>
    function copyEventQrLink() {
      const input = document.getElementById('eventQrScanLink');
      input.focus();
      input.select();
      input.setSelectionRange(0, input.value.length);

      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(input.value);
      } else {
        document.execCommand('copy');
      }
    }
  </script>
@endsection
