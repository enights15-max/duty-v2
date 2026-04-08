@extends('artist.layout')

@section('content')
    <div class="mt-2 mb-4">
        <h2 class=" pb-2 ">{{ __('Welcome back') . ','}} {{ Auth::guard('artist')->user()->username . '!' }}</h2>
    </div>

    <div class="row dashboard-items">
        <div class="col-xl-3 col-lg-6">
            <div class="card card-stats card-info card-round">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5">
                            <div class="icon-big text-center">
                                <i class="fas fa-users"></i>
                            </div>
                        </div>

                        <div class="col-7 col-stats">
                            <div class="numbers">
                                <p class="card-category">{{ __('Followers') }}</p>
                                <h4 class="card-title">{{ Auth::guard('artist')->user()->followers()->count() }}</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection