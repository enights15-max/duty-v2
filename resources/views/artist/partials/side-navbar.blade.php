<div class="sidebar sidebar-style-2"
    data-background-color="{{ Auth::guard('artist')->user()->theme_version == 'light' ? 'white' : 'dark2' }}">
    <div class="sidebar-wrapper scrollbar scrollbar-inner">
        <div class="sidebar-content">
            <div class="user">
                <div class="avatar-sm float-left mr-2">
                    @if (Auth::guard('artist')->user()->photo != null)
                        <img src="{{ asset('assets/admin/img/artist/' . Auth::guard('artist')->user()->photo) }}"
                            alt="Artist Image" class="avatar-img rounded-circle">
                    @else
                        <img src="{{ asset('assets/admin/img/blank_user.jpg') }}" alt="" class="avatar-img rounded-circle">
                    @endif
                </div>


                <div class="info">
                    <a>
                        <span>
                            {{ Auth::guard('artist')->user()->username }}

                            <span class="user-level">{{ __('Artist') }}</span>
                        </span>
                    </a>

                    <div class="clearfix"></div>
                </div>
            </div>
            <ul class="nav nav-primary">
                {{-- dashboard --}}
                <li class="nav-item @if (request()->routeIs('artist.dashboard')) active @endif">
                    <a href="{{ route('artist.dashboard') }}">
                        <i class="la flaticon-paint-palette"></i>
                        <p>{{ __('Dashboard') }}</p>
                    </a>
                </li>

                <li class="nav-item
                  @if (request()->routeIs('artist.edit.profile')) active @endif">
                    <a href="{{ route('artist.edit.profile') }}">
                        <i class="fal fa-user-edit"></i>
                        <p>{{ __('Edit Profile') }}</p>
                    </a>
                </li>

                <li class="nav-item @if (request()->routeIs('artist.monthly_income')) active @endif">
                    <a href="{{ route('artist.monthly_income') }}">
                        <i class="fal fa-funnel-dollar"></i>
                        <p>{{ __('Monthly Income') }}</p>
                    </a>
                </li>

                <li class="nav-item @if (request()->routeIs('artist.transcation')) active @endif">
                    <a href="{{ route('artist.transcation') }}">
                        <i class="fal fa-exchange-alt"></i>
                        <p>{{ __('Transactions') }}</p>
                    </a>
                </li>

                <li
                    class="nav-item @if (request()->routeIs('artist.withdraw') || request()->routeIs('artist.withdraw.create')) active @endif">
                    <a href="{{ route('artist.withdraw') }}">
                        <i class="fal fa-minus-circle"></i>
                        <p>{{ __('Withdrawals') }}</p>
                    </a>
                </li>
                <li class="nav-item @if (request()->routeIs('artist.change.password')) active @endif">
                    <a href="{{ route('artist.change.password') }}">
                        <i class="fal fa-key"></i>
                        <p>{{ __('Change Password') }}</p>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('artist.logout') }}">
                        <i class="fal fa-sign-out "></i>
                        <p>{{ __('Logout') }}</p>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</div>