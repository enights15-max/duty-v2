@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Edit Venue') }}</h4>
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
                <a href="#">{{ __('Edit Venue') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Edit Venue') }}</div>
                </div>

                <div class="card-body">
                    @php
                        $linkedIdentity = $identityContext['identity'] ?? null;
                    @endphp
                    <div class="row mb-4">
                        <div class="col-lg-8 mx-auto">
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
                                                {{ __('This venue still operates only through the legacy record. Link or create a professional identity to manage moderation and ownership from the canonical layer.') }}
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
                        <div class="col-lg-8 mx-auto">
                            <form id="ajaxForm"
                                action="{{ route('admin.venue_management.venue_update', ['id' => $venue->id]) }}"
                                method="post" enctype="multipart/form-data">
                                @csrf
                                <div class="form-group">
                                    <label for="">{{ __('Image') }}</label>
                                    <br>
                                    <div class="thumb-preview">
                                        @if ($venue->image != null)
                                            <img src="{{ asset('assets/admin/img/venue/' . $venue->image) }}" alt="..."
                                                class="uploaded-img">
                                        @else
                                            <img src="{{ asset('assets/admin/img/noimage.jpg') }}" alt="..."
                                                class="uploaded-img">
                                        @endif
                                    </div>
                                    <div class="mt-3">
                                        <div role="button" class="btn btn-primary btn-sm upload-btn">
                                            {{ __('Choose Image') }}
                                            <input type="file" class="img-input" name="image">
                                        </div>
                                    </div>
                                    <p id="err_image" class="mt-1 mb-0 text-danger em"></p>
                                </div>

                                <div class="row">
                                    <div class="col-lg-6">
                                        <div class="form-group">
                                            <label>{{ __('Name') . '*' }}</label>
                                            <input type="text" class="form-control" name="name" value="{{ $venue->name }}"
                                                placeholder="{{ __('Enter Name') }}">
                                            <p id="err_name" class="mt-1 mb-0 text-danger em"></p>
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <div class="form-group">
                                            <label>{{ __('Username') . '*' }}</label>
                                            <input type="text" class="form-control" name="username"
                                                value="{{ $venue->username }}" placeholder="{{ __('Enter Username') }}">
                                            <p id="err_username" class="mt-1 mb-0 text-danger em"></p>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-lg-6">
                                        <div class="form-group">
                                            <label>{{ __('Email') . '*' }}</label>
                                            <input type="email" class="form-control" name="email"
                                                value="{{ $venue->email }}" placeholder="{{ __('Enter Email') }}">
                                            <p id="err_email" class="mt-1 mb-0 text-danger em"></p>
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <div class="form-group">
                                            <label>{{ __('Password') }}</label>
                                            <input type="password" class="form-control" name="password"
                                                placeholder="{{ __('Enter Password') }}">
                                            <p class="text-warning">
                                                {{ __('Leave it blank if you don\'t want to change it.') }}</p>
                                            <p id="err_password" class="mt-1 mb-0 text-danger em"></p>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label>{{ __('Location') }}</label>
                                    <input type="text" class="form-control" name="location" value="{{ $venue->location }}"
                                        placeholder="{{ __('Enter Location') }}">
                                    <p id="err_location" class="mt-1 mb-0 text-danger em"></p>
                                </div>

                                <div class="form-group">
                                    <label>{{ __('Details') }}</label>
                                    <textarea class="form-control" name="details" rows="5"
                                        placeholder="{{ __('Enter Details') }}">{{ $venue->details }}</textarea>
                                    <p id="err_details" class="mt-1 mb-0 text-danger em"></p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card-footer">
                    <div class="row">
                        <div class="col-12 text-center">
                            <button type="submit" id="submitBtn" class="btn btn-success">
                                {{ __('Update') }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
