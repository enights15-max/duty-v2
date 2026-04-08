<div class="sidebar sidebar-style-2"
  data-background-color="{{ Auth::guard('venue')->user()->theme_version == 'light' ? 'white' : 'dark2' }}">
  <div class="sidebar-wrapper scrollbar scrollbar-inner">
    <div class="sidebar-content">
      <div class="user">
        <div class="avatar-sm float-left mr-2">
          @if (Auth::guard('venue')->user()->photo != null)
            <img src="{{ asset('assets/admin/img/venue-photo/' . Auth::guard('venue')->user()->photo) }}"
              alt="Admin Image" class="avatar-img rounded-circle">
          @else
            <img src="{{ asset('assets/admin/img/blank_user.jpg') }}" alt="" class="avatar-img rounded-circle">
          @endif
        </div>


        <div class="info">
          <a>
            <span>
              {{ Auth::guard('venue')->user()->username }}

              <span class="user-level">{{ __('Venue') }}</span>
            </span>
          </a>

          <div class="clearfix"></div>
        </div>
      </div>
      <ul class="nav nav-primary">
        {{-- search --}}
        <div class="row mb-3">
          <div class="col-12">
            <form action="" onsubmit="return false">
              <div class="form-group py-0">
                <input name="term" type="text" class="form-control sidebar-search ltr"
                  placeholder="Search Menu Here...">
              </div>
            </form>
          </div>
        </div>

        {{-- dashboard --}}
        <li class="nav-item @if (request()->routeIs('venue.dashboard')) active @endif">
          <a href="{{ route('venue.dashboard') }}">
            <i class="la flaticon-paint-palette"></i>
            <p>{{ __('Dashboard') }}</p>
          </a>
        </li>

        <li
          class="nav-item
          @if (request()->routeIs('venue.event_management.event')) active
          @elseif (request()->routeIs('choose-event-type')) active
          @elseif (request()->routeIs('venue.event_management.ticket_setting')) active
          @elseif (request()->routeIs('venue.add.event.event')) active
          @elseif (request()->routeIs('venue.event_management.edit_event')) active
          @elseif (request()->routeIs('venue.event.ticket')) active
          @elseif (request()->routeIs('venue.event.add.ticket')) active
          @elseif (request()->routeIs('venue.event.edit.ticket')) active
          @elseif (request()->routeIs('venue.event_management.seat_mapping')) active
          @endif">
          <a data-toggle="collapse" href="#course">
            <i class="fal fa-book"></i>
            <p>{{ __('Event Management') }}</p>
            <span class="caret"></span>
          </a>

          <div id="course"
            class="collapse
            @if (request()->routeIs('venue.event_management.event')) show
            @elseif (request()->routeIs('choose-event-type')) show
            @elseif (request()->routeIs('venue.event_management.ticket_setting')) show
            @elseif (request()->routeIs('venue.add.event.event')) show
            @elseif (request()->routeIs('venue.event_management.edit_event')) show
            @elseif (request()->routeIs('venue.event.ticket')) show
            @elseif (request()->routeIs('venue.event.add.ticket')) show
            @elseif (request()->routeIs('venue.event.edit.ticket')) show
            @elseif (request()->routeIs('venue.event_management.seat_mapping')) show
            @endif">
            <ul class="nav nav-collapse">

              <li
                class="

              @if (request()->routeIs('choose-event-type')) active
              @elseif (request()->routeIs('venue.add.event.event') && request()->input('type') == 'online') active
              @elseif (request()->routeIs('venue.add.event.event') && request()->input('type') == 'venue') active @endif
              ">
                <a href="{{ route('choose-event-type', ['language' => $defaultLang->code]) }}">
                  <span class="sub-item">{{ __('Add Event') }}</span>
                </a>
              </li>

              <li
                class="@if (request()->routeIs('venue.event_management.event') && request()->input('event_type') == '') active
                  @elseif (request()->routeIs('venue.event_management.edit_event') && request()->input('event_type') == '') active
                  @elseif (request()->routeIs('venue.event_management.ticket_setting')) active
                  @elseif (request()->routeIs('venue.event.ticket') && request()->input('event_type') == '') active
              @elseif (request()->routeIs('venue.event.add.ticket') && request()->input('event_type') == '') active
              @elseif (request()->routeIs('venue.event.edit.ticket') && request()->input('event_type') == '') active
              @elseif (request()->routeIs('venue.event_management.seat_mapping') && request()->input('event_type') == '') active
              @endif">
                <a href="{{ route('venue.event_management.event', ['language' => $defaultLang->code]) }}">
                  <span class="sub-item">{{ __('All Events') }}</span>
                </a>
              </li>

              <li
                class="
              @if (request()->routeIs('venue.event_management.event') && request()->input('event_type') == 'venue') active
              @elseif (request()->routeIs('venue.event.ticket') && request()->input('event_type') == 'venue') active
              @elseif (request()->routeIs('venue.event.add.ticket') && request()->input('event_type') == 'venue') active
              @elseif (request()->routeIs('venue.event.edit.ticket') && request()->input('event_type') == 'venue') active @endif">
                <a
                  href="{{ route('venue.event_management.event', ['language' => $defaultLang->code, 'event_type' => 'venue']) }}">
                  <span class="sub-item">{{ __('Venue Events') }}</span>
                </a>
              </li>

              <li class="

              @if (request()->routeIs('venue.event_management.event') && request()->input('event_type') == 'online') active @endif
              ">
                <a
                  href="{{ route('venue.event_management.event', ['language' => $defaultLang->code, 'event_type' => 'online']) }}">
                  <span class="sub-item">{{ __('Online Events') }}</span>
                </a>
              </li>
            </ul>
          </div>
        </li>

        <li
          class="nav-item
          @if (request()->routeIs('venue.event.booking')) active
          @elseif (request()->routeIs('venue.event_booking.details')) active
          @elseif (request()->routeIs('venue.event_booking.report')) active @endif">
          <a data-toggle="collapse" href="#bookings">
            <i class="fal fa-users-class"></i>
            <p>{{ __('Event Bookings') }}</p>
            <span class="caret"></span>
          </a>

          <div id="bookings"
            class="collapse
          @if (request()->routeIs('venue.event.booking')) show
          @elseif (request()->routeIs('venue.event_booking.details')) show
          @elseif (request()->routeIs('venue.event_booking.report')) show @endif">
            <ul class="nav nav-collapse">
              <li
                class="
              @if (request()->routeIs('venue.event.booking') && empty(request()->input('status'))) active
              @elseif (request()->routeIs('venue.event_booking.details')) active @endif">
                <a href="{{ route('venue.event.booking') }}">
                  <span class="sub-item">{{ __('All Bookings') }}</span>
                </a>
              </li>

              <li
                class="{{ request()->routeIs('venue.event.booking') && request()->input('status') == 'completed' ? 'active' : '' }}">
                <a href="{{ route('venue.event.booking', ['status' => 'completed']) }}">
                  <span class="sub-item">{{ __('Completed Bookings') }}</span>
                </a>
              </li>

              <li
                class="{{ request()->routeIs('venue.event.booking') && request()->input('status') == 'pending' ? 'active' : '' }}">
                <a href="{{ route('venue.event.booking', ['status' => 'pending']) }}">
                  <span class="sub-item">{{ __('Pending Bookings') }}</span>
                </a>
              </li>

              <li
                class="{{ request()->routeIs('venue.event.booking') && request()->input('status') == 'rejected' ? 'active' : '' }}">
                <a href="{{ route('venue.event.booking', ['status' => 'rejected']) }}">
                  <span class="sub-item">{{ __('Rejected Bookings') }}</span>
                </a>
              </li>

              <li class="{{ request()->routeIs('venue.event_booking.report') ? 'active' : '' }}">
                <a href="{{ route('venue.event_booking.report') }}">
                  <span class="sub-item">{{ __('Report') }}</span>
                </a>
              </li>
            </ul>
          </div>
        </li>
        <li
          class="nav-item
        @if (request()->routeIs('venue.withdraw')) active
        @elseif (request()->routeIs('venue.withdraw.create')) active @endif">
          <a href="{{ route('venue.withdraw', ['language' => $defaultLang->code]) }}">
            <i class="fal fa-donate"></i>
            <p>{{ __('Withdraw') }}</p>
          </a>
        </li>
        <li class="nav-item @if (request()->routeIs('venue.transcation')) active @endif">
          <a href="{{ route('venue.transcation') }}">
            <i class="fal fa-exchange-alt"></i>
            <p>{{ __('Transactions') }}</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="{{ route('venue.pwa') }}" target="_blank">
            <i class="fas fa-scanner"></i>
            <p>{{ __('Pwa Scanner') }}</p>
          </a>
        </li>

        @php
          $support_status = DB::table('support_ticket_statuses')->first();
        @endphp
        @if ($support_status->support_ticket_status == 'active')
          {{-- Support Ticket --}}
          <li
            class="nav-item @if (request()->routeIs('venue.support_tickets')) active
            @elseif (request()->routeIs('venue.support_tickets.message')) active
            @elseif (request()->routeIs('venue.support_ticket.create')) active @endif">
            <a data-toggle="collapse" href="#support_ticket">
              <i class="la flaticon-web-1"></i>
              <p>{{ __('Support Tickets') }}</p>
              <span class="caret"></span>
            </a>

            <div id="support_ticket"
              class="collapse
              @if (request()->routeIs('venue.support_tickets')) show
              @elseif (request()->routeIs('venue.support_tickets.message')) show
              @elseif (request()->routeIs('venue.support_ticket.create')) show @endif">
              <ul class="nav nav-collapse">

                <li
                  class="@if (request()->routeIs('venue.support_tickets')) active
              @elseif (request()->routeIs('venue.support_tickets.message')) active @endif">
                  <a href="{{ route('venue.support_tickets') }}">
                    <span class="sub-item">{{ __('All Tickets') }}</span>
                  </a>
                </li>
                <li class="{{ request()->routeIs('venue.support_ticket.create') ? 'active' : '' }}">
                  <a href="{{ route('venue.support_ticket.create') }}">
                    <span class="sub-item">{{ __('Add Ticket') }}</span>
                  </a>
                </li>
              </ul>
            </div>
          </li>
        @endif

        <li class="nav-item
                  @if (request()->routeIs('venue.edit.profile')) active @endif">
          <a href="{{ route('venue.edit.profile') }}">
            <i class="fal fa-user-edit"></i>
            <p>{{ __('Edit Profile') }}</p>
          </a>
        </li>
        <li class="nav-item @if (request()->routeIs('venue.change.password')) active @endif">
          <a href="{{ route('venue.change.password') }}">
            <i class="fal fa-key"></i>
            <p>{{ __('Change Password') }}</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="{{ route('venue.logout') }}">
            <i class="fal fa-sign-out "></i>
            <p>{{ __('Logout') }}</p>
          </a>
        </li>
      </ul>
    </div>
  </div>
</div>
