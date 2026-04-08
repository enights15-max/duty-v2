<<<<<<< Updated upstream
<header class="main-header">
=======
@php
  $brandLogo = !empty($footerInfo) && !empty($footerInfo->footer_logo)
      ? asset('assets/admin/img/footer_logo/' . $footerInfo->footer_logo)
      : asset('assets/admin/img/' . $websiteInfo->logo);
@endphp
>>>>>>> Stashed changes

<header class="main-header glass-nav web-site-header">
  <div class="header-upper py-25">
    <div class="container clearfix">
      <div class="web-nav-shell">
        <div class="logo-outer">
          <a href="{{ route('index') }}" class="web-brand">
            <span class="logo">
              <img src="{{ $brandLogo }}" alt="Logo">
            </span>
          </a>
        </div>

        <div class="nav-outer clearfix ml-lg-auto">
          <nav class="main-menu navbar-expand-xl">
            <div class="navbar-header">
              <div class="logo-mobile">
                <a href="{{ route('index') }}">
                  <img src="{{ $brandLogo }}" alt="Logo">
                </a>
              </div>
              <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse"
                aria-controls="main-menu">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
            </div>

            <div class="navbar-collapse collapse clearfix" id="main-menu">
              @php
                $links = json_decode($menuInfos, true);
                $workspaceGuard = null;
                $workspaceLabel = __('Workspace');

                if (Auth::guard('organizer')->check()) {
                    $workspaceGuard = 'organizer';
                    $workspaceLabel = Auth::guard('organizer')->user()->username;
                } elseif (Auth::guard('artist')->check()) {
                    $workspaceGuard = 'artist';
                    $workspaceLabel = Auth::guard('artist')->user()->username;
                } elseif (Auth::guard('venue')->check()) {
                    $workspaceGuard = 'venue';
                    $workspaceLabel = Auth::guard('venue')->user()->username;
                }
              @endphp
              <ul class="navigation clearfix">
                @foreach ($links as $link)
                  @php
                    $href = get_href($link, $currentLanguageInfo->id);
                  @endphp
                  @if (!array_key_exists('children', $link))
                    <li><a href="{{ $href }}" target="{{ $link['target'] }}">{{ __($link['text']) }}</a></li>
                  @else
                    <li class="dropdown">
                      <a href="{{ $href }}" target="{{ $link['target'] }}">
                        {{ $link['text'] }}
                        <i class="fa fa-angle-down"></i>
                      </a>
                      <ul>
                        @foreach ($link['children'] as $level2)
                          @php
                            $l2Href = get_href($level2, $currentLanguageInfo->id);
                          @endphp
                          <li>
                            <a href="{{ $l2Href }}" target="{{ $level2['target'] }}">{{ __($level2['text']) }}</a>
                          </li>
                        @endforeach
                      </ul>
                    </li>
                  @endif
                @endforeach
              </ul>

              <div class="web-action-cluster">
                <a href="{{ route('frontend.download_app') }}" class="web-account-btn web-account-btn--accent web-top-cta">
                  <span class="web-account-btn__icon"><i class="fas fa-mobile-alt"></i></span>
                  <span>{{ __('Download App') }}</span>
                </a>

                <div class="dropdown web-top-cta">
                  <button type="button" class="web-account-btn dropdown-toggle" data-toggle="dropdown">
                    <span class="web-account-btn__icon"><i class="fas fa-briefcase"></i></span>
                    <span>{{ __('For Pros') }}</span>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="dropdownMenuButtonPro">
                    <a class="dropdown-item" href="{{ route('frontend.for_organizers') }}">{{ __('For Organizers') }}</a>
                    <a class="dropdown-item" href="{{ route('frontend.for_artists') }}">{{ __('For Artists & DJs') }}</a>
                    <a class="dropdown-item" href="{{ route('frontend.for_venues') }}">{{ __('For Venues') }}</a>
                  </div>
                </div>

                <form action="{{ route('change_language') }}" method="get" class="web-language">
                  <select name="lang_code" id="language" class="form-control" onchange="this.form.submit()">
                    @foreach ($allLanguageInfos as $item)
                      <option value="{{ $item->code }}"
                        {{ $item->code == $currentLanguageInfo->code ? 'selected' : '' }}>{{ $item->name }}</option>
                    @endforeach
                  </select>
                </form>

                @if (!Auth::guard('customer')->check())
                  <div class="dropdown">
                    <button type="button" class="web-account-btn dropdown-toggle" data-toggle="dropdown">
                      <span class="web-account-btn__icon"><i class="fas fa-user"></i></span>
                      <span>{{ __('Fan Access') }}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                      <a class="dropdown-item" href="{{ route('customer.login') }}">{{ __('Login') }}</a>
                      <a class="dropdown-item" href="{{ route('customer.signup') }}">{{ __('Signup') }}</a>
                    </div>
                  </div>
                @else
                  <div class="dropdown">
                    <button type="button" class="web-account-btn dropdown-toggle" data-toggle="dropdown">
                      <span class="web-account-btn__icon"><i class="fas fa-user-check"></i></span>
                      <span>{{ Auth::guard('customer')->user()->username }}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                      <a class="dropdown-item" href="{{ route('customer.dashboard') }}">{{ __('Dashboard') }}</a>
                      <a class="dropdown-item" href="{{ route('customer.logout') }}">{{ __('Logout') }}</a>
                    </div>
                  </div>
                @endif

                @if (!$workspaceGuard)
                  <div class="dropdown">
                    <button type="button" class="web-account-btn dropdown-toggle" data-toggle="dropdown">
                      <span class="web-account-btn__icon"><i class="fas fa-layer-group"></i></span>
                      <span>{{ __('Workspace') }}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton2">
                      <a class="dropdown-item" href="{{ route('organizer.signup') }}">{{ __('Create organizer account') }}</a>
                      <a class="dropdown-item" href="{{ route('organizer.login') }}">{{ __('Organizer login') }}</a>
                      <a class="dropdown-item" href="{{ route('artist.login') }}">{{ __('Artist login') }}</a>
                      <a class="dropdown-item" href="{{ route('venue.login') }}">{{ __('Venue login') }}</a>
                    </div>
                  </div>
                @else
                  <div class="dropdown">
                    <button type="button" class="web-account-btn dropdown-toggle" data-toggle="dropdown">
                      <span class="web-account-btn__icon"><i class="fas fa-bolt"></i></span>
                      <span>{{ $workspaceLabel }}</span>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                      @if ($workspaceGuard === 'organizer')
                        <a class="dropdown-item" href="{{ route('organizer.dashboard') }}">{{ __('Organizer dashboard') }}</a>
                        <a class="dropdown-item" href="{{ route('organizer.logout') }}">{{ __('Logout') }}</a>
                      @elseif ($workspaceGuard === 'artist')
                        <a class="dropdown-item" href="{{ route('artist.dashboard') }}">{{ __('Artist dashboard') }}</a>
                        <a class="dropdown-item" href="{{ route('artist.logout') }}">{{ __('Logout') }}</a>
                      @elseif ($workspaceGuard === 'venue')
                        <a class="dropdown-item" href="{{ route('venue.dashboard') }}">{{ __('Venue dashboard') }}</a>
                        <a class="dropdown-item" href="{{ route('venue.logout') }}">{{ __('Logout') }}</a>
                      @endif
                    </div>
                  </div>
                @endif
              </div>
            </div>
          </nav>
        </div>
      </div>
    </div>
  </div>
<<<<<<< Updated upstream
  <!--End Header Upper-->
=======
>>>>>>> Stashed changes
</header>
