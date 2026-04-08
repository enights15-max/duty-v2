@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Registered Venues') }}</h4>
        <ul class="breadcrumbs">
            <li class="nav-home">
                <a href="{{ route('admin.dashboard') }}">
                    <i class="flaticon-home"></i>
                </a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Venues Management') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Registered Venues') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card-title">{{ __('All Venues') }}</div>
                        </div>

                        <div class="col-lg-6 offset-lg-2">
                            <button class="btn btn-danger btn-sm float-right d-none bulk-delete mr-2 ml-3 mt-1"
                                data-href="{{ route('admin.venue_management.bulk_delete_venue') }}">
                                <i class="flaticon-interface-5"></i> {{ __('Delete') }}
                            </button>

                            <form class="float-right" action="{{ route('admin.venue_management.registered_venue') }}"
                                method="GET">
                                <input name="info" type="text" class="form-control min-230"
                                    placeholder="Search By Name or Email ID"
                                    value="{{ !empty(request()->input('info')) ? request()->input('info') : '' }}">
                            </form>

                            <a href="{{ route('admin.venue_management.add_venue') }}"
                                class="btn btn-primary btn-sm float-right mr-2 mt-1">
                                <i class="fas fa-plus"></i> {{ __('Add Venue') }}
                            </a>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($venues) == 0)
                                <h3 class="text-center">{{ __('NO VENUE FOUND') . '!' }}</h3>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3">
                                        <thead>
                                            <tr>
                                                <th scope="col">
                                                    <input type="checkbox" class="bulk-check" data-val="all">
                                                </th>
                                                <th scope="col">{{ __('Name') }}</th>
                                                <th scope="col">{{ __('Username') }}</th>
                                                <th scope="col">{{ __('Email ID') }}</th>
                                                <th scope="col">{{ __('Account Status') }}</th>
                                                <th scope="col">{{ __('Professional Profile') }}</th>
                                                <th scope="col">{{ __('Owner') }}</th>
                                                <th scope="col">{{ __('Actions') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($venues as $venue)
                                                <tr>
                                                    <td>
                                                        <input type="checkbox" class="bulk-check" data-val="{{ $venue->id }}">
                                                    </td>
                                                    <td>{{ $venue->name }}</td>
                                                    <td>{{ $venue->username }}</td>
                                                    <td>{{ $venue->email }}</td>
                                                    <td>
                                                        <span class="badge badge-{{ $venue->status == 1 ? 'success' : 'danger' }}">
                                                            {{ $venue->status == 1 ? __('Active') : __('Deactive') }}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        @php
                                                            $identityContext = $venue->identity_context ?? [];
                                                            $linkedIdentity = $venue->linked_identity ?? null;
                                                        @endphp
                                                        <span class="badge badge-{{ $identityContext['status_class'] ?? 'secondary' }}">
                                                            {{ __($identityContext['status_label'] ?? 'Not linked') }}
                                                        </span>
                                                        @if ($linkedIdentity)
                                                            <div class="small text-muted mt-1">
                                                                #{{ $linkedIdentity->id }} · {{ $linkedIdentity->display_name }}
                                                            </div>
                                                        @else
                                                            <div class="small text-muted mt-1">{{ __('Legacy-only venue record') }}</div>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if ($linkedIdentity)
                                                            <div>{{ $identityContext['owner_name'] ?: __('Owner not assigned') }}</div>
                                                            <div class="small text-muted">
                                                                {{ $identityContext['owner_email'] ?: __('No owner email') }}
                                                            </div>
                                                        @else
                                                            <span class="text-muted">{{ __('No linked owner') }}</span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        <div class="dropdown">
                                                            <button class="btn btn-secondary dropdown-toggle btn-sm" type="button"
                                                                id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true"
                                                                aria-expanded="false">
                                                                {{ __('Select') }}
                                                            </button>

                                                            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                                                <a href="{{ route('admin.venue_management.venue_details', ['id' => $venue->id]) }}"
                                                                    class="dropdown-item">
                                                                    {{ __('Details') }}
                                                                </a>

                                                                <a href="{{ route('admin.venue_management.venue_edit', ['id' => $venue->id]) }}"
                                                                    class="dropdown-item">
                                                                    {{ __('Edit') }}
                                                                </a>

                                                                @if ($linkedIdentity)
                                                                    <a href="{{ route('admin.identity_management.show', ['id' => $linkedIdentity->id]) }}"
                                                                        class="dropdown-item">
                                                                        {{ __('View Professional Profile') }}
                                                                    </a>
                                                                @endif

                                                                <form class="deleteForm d-block"
                                                                    action="{{ route('admin.venue_management.venue_delete', ['id' => $venue->id]) }}"
                                                                    method="post">
                                                                    @csrf
                                                                    <button type="submit" class="deleteBtn">
                                                                        {{ __('Delete') }}
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            @endif
                        </div>
                    </div>
                </div>

                <div class="card-footer text-center">
                    <div class="d-inline-block mt-3">
                        {{ $venues->appends(['info' => request()->input('info')])->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
