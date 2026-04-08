<footer class="web-footer">
  <div class="container">
    <div class="web-footer__grid">
      <div class="web-footer__panel">
        <span class="web-footer__eyebrow">{{ __('Web + App Unified') }}</span>
        <div class="footer-logo mb-25">
          @if (!is_null($footerInfo))
            <a href="{{ route('index') }}">
              <img src="{{ asset('assets/admin/img/footer_logo/' . $footerInfo->footer_logo) }}" alt="Logo">
            </a>
          @endif
        </div>
        <p class="web-footer__copy">{!! $footerInfo ? $footerInfo->about_company : '' !!}</p>
        <div class="web-footer__metrics">
          <span class="web-footer__metric"><i class="fas fa-calendar-alt"></i> {{ __('Events') }}</span>
          <span class="web-footer__metric"><i class="fas fa-user-friends"></i> {{ __('Community') }}</span>
          <span class="web-footer__metric"><i class="fas fa-bolt"></i> {{ __('Discovery') }}</span>
        </div>
        <div class="social-style-one mt-25">
          @if (count($socialMediaInfos) > 0)
            @foreach ($socialMediaInfos as $socialMediaInfo)
              <a href="{{ $socialMediaInfo->url }}"><i class="{{ $socialMediaInfo->icon }}"></i></a>
            @endforeach
          @endif
        </div>
      </div>

      <div class="web-footer__panel">
        <h5 class="web-footer__heading">{{ __('Quick Links') }}</h5>
        <ul class="web-footer__links">
          @foreach ($quickLinkInfos as $quickLinkInfo)
            <li><a href="{{ $quickLinkInfo->url }}">{{ $quickLinkInfo->title }}</a></li>
          @endforeach
        </ul>
      </div>

      <div class="web-footer__panel">
        <h5 class="web-footer__heading">{{ __('Contact') }}</h5>
        <div class="web-footer__contact">
          @if (!is_null($bex))
            @php
              $addresses = array_filter(explode(PHP_EOL, $bex->contact_addresses ?? ''));
              $mails = array_filter(explode(',', $bex->contact_mails ?? ''));
              $phones = array_filter(explode(',', $bex->contact_numbers ?? ''));
            @endphp

            @if (!empty($addresses))
              <div class="web-footer__contact-row">
                <span class="web-footer__contact-icon"><i class="fas fa-map-marker-alt"></i></span>
                <div>
                  @foreach ($addresses as $address)
                    <div>{{ $address }}</div>
                  @endforeach
                </div>
              </div>
            @endif

            @if (!empty($mails))
              <div class="web-footer__contact-row">
                <span class="web-footer__contact-icon"><i class="fas fa-envelope"></i></span>
                <div>
                  @foreach ($mails as $mail)
                    <div><a href="mailto:{{ trim($mail) }}">{{ trim($mail) }}</a></div>
                  @endforeach
                </div>
              </div>
            @endif

            @if (!empty($phones))
              <div class="web-footer__contact-row">
                <span class="web-footer__contact-icon"><i class="fas fa-mobile-alt"></i></span>
                <div>
                  @foreach ($phones as $phone)
                    <div><a href="tel:{{ trim($phone) }}">{{ trim($phone) }}</a></div>
                  @endforeach
                </div>
              </div>
            @endif
          @endif
        </div>
      </div>
    </div>

    @php
      $date = Date('Y');
      if (!empty($footerInfo->copyright_text)) {
          $footer_text = str_replace('{year}', $date, $footerInfo->copyright_text);
      }
    @endphp
    <div class="web-footer__bottom">
      <div>{!! !empty($footerInfo->copyright_text) ? $footer_text : '' !!}</div>
      <div class="web-footer__legal">
        <span>{{ __('Built for the same scene-first experience across app and web.') }}</span>
      </div>
      <button class="scroll-top scroll-to-target" data-target="html"><span class="fa fa-angle-up"></span></button>
    </div>
  </div>
</footer>
