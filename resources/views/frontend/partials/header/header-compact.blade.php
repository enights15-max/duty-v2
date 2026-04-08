@php
  $brandLogo = !empty($footerInfo) && !empty($footerInfo->footer_logo)
      ? asset('assets/admin/img/footer_logo/' . $footerInfo->footer_logo)
      : asset('assets/admin/img/' . $websiteInfo->logo);
@endphp

<header class="main-header glass-nav web-site-header web-header-compact">
  <div class="header-upper py-25">
    <div class="container clearfix">
      <div class="web-nav-shell web-nav-shell--compact">
        <div class="logo-outer">
          <a href="{{ route('index') }}" class="web-brand">
            <span class="logo">
              <img src="{{ $brandLogo }}" alt="Logo">
            </span>
          </a>
        </div>

        <div class="web-compact-actions ml-lg-auto">
          <a href="{{ route('index') }}" class="web-account-btn web-account-btn--compact-link">{{ __('Home') }}</a>
          <a href="{{ route('events') }}" class="web-account-btn web-account-btn--compact-link">{{ __('Events') }}</a>
          <a href="{{ route('frontend.download_app') }}" class="web-account-btn web-account-btn--accent">
            <span class="web-account-btn__icon"><i class="fas fa-mobile-alt"></i></span>
            <span>{{ __('Download App') }}</span>
          </a>
          <form action="{{ route('change_language') }}" method="get" class="web-language web-language--compact">
            <select name="lang_code" id="language-compact" class="form-control" onchange="this.form.submit()">
              @foreach ($allLanguageInfos as $item)
                <option value="{{ $item->code }}" {{ $item->code == $currentLanguageInfo->code ? 'selected' : '' }}>
                  {{ $item->name }}
                </option>
              @endforeach
            </select>
          </form>
        </div>
      </div>
    </div>
  </div>
</header>
