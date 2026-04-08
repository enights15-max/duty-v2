@extends('venue.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Create Ticket') }}</h4>
        <ul class="breadcrumbs">
            <li class="nav-home">
                <a href="{{ route('venue.dashboard') }}">
                    <i class="flaticon-home"></i>
                </a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="{{ route('venue.support_tickets') }}">{{ __('Support Tickets') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-8 mx-auto">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('New Support Ticket') }}</div>
                </div>
                <div class="card-body">
                    <form action="{{ route('venue.support_ticket.store') }}" method="POST">
                        @csrf
                        <div class="form-group">
                            <label>{{ __('Subject') . '*' }}</label>
                            <input type="text" class="form-control" name="subject" value="{{ old('subject') }}">
                            @error('subject')
                                <p class="mt-2 mb-0 text-danger">{{ $message }}</p>
                            @enderror
                        </div>
                        <div class="form-group">
                            <label>{{ __('Description') . '*' }}</label>
                            <textarea name="description" rows="5" class="form-control">{{ old('description') }}</textarea>
                            @error('description')
                                <p class="mt-2 mb-0 text-danger">{{ $message }}</p>
                            @enderror
                        </div>
                        <div class="form-group text-center">
                            <button type="submit" class="btn btn-success">{{ __('Submit') }}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection