@extends('artist.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Change Password') }}</h4>
        <ul class="breadcrumbs">
            <li class="nav-home">
                <a href="{{ route('artist.dashboard') }}">
                    <i class="flaticon-home"></i>
                </a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Change Password') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Change Password') }}</div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-6 mx-auto">
                            <form id="passwordForm" action="{{ route('artist.update_password') }}" method="POST">
                                @csrf
                                <div class="form-group">
                                    <label>{{ __('Current Password') . '*' }}</label>
                                    <input type="password" class="form-control" name="current_password">
                                    @error('current_password')
                                        <p class="mt-2 mb-0 text-danger">{{ $message }}</p>
                                    @enderror
                                </div>

                                <div class="form-group">
                                    <label>{{ __('New Password') . '*' }}</label>
                                    <input type="password" class="form-control" name="new_password">
                                    @error('new_password')
                                        <p class="mt-2 mb-0 text-danger">{{ $message }}</p>
                                    @enderror
                                </div>

                                <div class="form-group">
                                    <label>{{ __('Confirm New Password') . '*' }}</label>
                                    <input type="password" class="form-control" name="new_password_confirmation">
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card-footer">
                    <div class="row">
                        <div class="col-12 text-center">
                            <button type="submit" form="passwordForm" class="btn btn-success">
                                {{ __('Update') }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection