@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Venue Details') }}</h4>
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
                <a href="#">{{ __('Venue Details') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Venue Information') }}</div>
                </div>

                <div class="card-body">
                    @php
                        $linkedIdentity = $identityContext['identity'] ?? null;
                    @endphp
                    <div class="row mb-4">
                        <div class="col-lg-12">
                            <div class="alert alert-light border mb-0">
                                <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center">
                                    <div class="mb-3 mb-lg-0">
                                        <div class="small text-muted text-uppercase">{{ __('Professional Profile') }}</div>
                                        <div class="mt-2">
                                            <span class="badge badge-{{ $identityContext['status_class'] ?? 'secondary' }}">
                                                {{ __($identityContext['status_label'] ?? 'Not linked') }}
                                            </span>
                                        </div>
                                        @if ($linkedIdentity)
                                            <div class="mt-2">
                                                <strong>#{{ $linkedIdentity->id }}</strong> · {{ $linkedIdentity->display_name }}
                                                @if (!empty($linkedIdentity->slug))
                                                    <span class="text-muted">· {{ $linkedIdentity->slug }}</span>
                                                @endif
                                            </div>
                                            <div class="small text-muted">
                                                {{ __('Owner') }}:
                                                {{ !empty($identityContext['owner_name']) ? $identityContext['owner_name'] : __('Owner not assigned') }}
                                                @if (!empty($identityContext['owner_email']))
                                                    · {{ $identityContext['owner_email'] }}
                                                @endif
                                            </div>
                                            @if (!empty($identityContext['latest_action']))
                                                <div class="small text-muted mt-1">
                                                    {{ __('Latest moderation action') }}:
                                                    {{ __(ucfirst(str_replace('_', ' ', $identityContext['latest_action']))) }}
                                                    @if (!empty($identityContext['latest_action_at']))
                                                        · {{ \Carbon\Carbon::parse($identityContext['latest_action_at'])->format('Y-m-d H:i') }}
                                                    @endif
                                                </div>
                                            @endif
                                        @else
                                            <div class="small text-muted mt-2">
                                                {{ __('This venue has not been linked to a professional identity yet. The legacy venue record still works operationally, but moderation and ownership live in the identity layer.') }}
                                            </div>
                                        @endif
                                    </div>
                                    @if ($linkedIdentity)
                                        <div>
                                            <a href="{{ route('admin.identity_management.show', ['id' => $linkedIdentity->id]) }}"
                                                class="btn btn-primary btn-sm">
                                                {{ __('Open Professional Profile') }}
                                            </a>
                                        </div>
                                    @endif
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-4">
                            <div class="form-group">
                                <label>{{ __('Image') }}</label>
                                <br>
                                @if ($venue->image != null)
                                    <img src="{{ asset('assets/admin/img/venue/' . $venue->image) }}" alt="..."
                                        style="width: 100%; max-width: 300px;">
                                @else
                                    <img src="{{ asset('assets/admin/img/noimage.jpg') }}" alt="..."
                                        style="width: 100%; max-width: 300px;">
                                @endif
                            </div>
                        </div>
                        <div class="col-lg-8">
                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="form-group">
                                        <label>{{ __('Name') }}</label>
                                        <p>{{ $venue->name }}</p>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group">
                                        <label>{{ __('Username') }}</label>
                                        <p>{{ $venue->username }}</p>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group">
                                        <label>{{ __('Email') }}</label>
                                        <p>{{ $venue->email }}</p>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group">
                                        <label>{{ __('Location') }}</label>
                                        <p>{{ $venue->location }}</p>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>{{ __('Details') }}</label>
                                <p>{{ $venue->details }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
