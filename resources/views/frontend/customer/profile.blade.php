@extends('frontend.layout')
@section('pageHeading')
    {{ $customer->fname }} {{ $customer->lname }}
@endsection

@section('hero-section')
    <!-- Page Banner Start -->
    <section class="page-banner overlay pt-120 pb-125 rpt-90 rpb-95 lazy"
        data-bg="{{ asset('assets/admin/img/' . $basicInfo->breadcrumb) }}">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <div class="banner-inner banner-author">
                        <div class="author mb-3">
                            <figure class="author-img mb-0">
                                <a href="javaScript:void(0)">
                                    @if ($customer->photo == null)
                                        <img class="rounded-lg lazy" data-src="{{ asset('assets/front/images/profile.jpg') }}"
                                            alt="image">
                                    @else
                                        <img class="rounded-lg lazy"
                                            data-src="{{ asset('assets/admin/img/customer-profile/' . $customer->photo) }}"
                                            alt="image">
                                    @endif
                                </a>
                            </figure>
                            <div class="author-info">
                                <h3 class="mb-1 text-white">{{ $customer->fname }} {{ $customer->lname }}</h3>
                                <h6 class="mb-1 text-white">{{ $customer->username }}</h6>
                                <span>{{ __('Member since') }} {{ date('M Y', strtotime($customer->created_at)) }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Page Banner End -->
@endsection
@section('content')
    <div class="author-area py-120 rpy-100 ">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    @if ($customer->is_private == 1 && !$is_owner)
                        <div class="alert alert-info text-center py-5">
                            <i class="fas fa-lock fa-3x mb-3"></i>
                            <h4>{{ __('This profile is private') }}</h4>
                            <p>{{ __('The user has chosen to hide their profile details.') }}</p>
                        </div>
                    @else
                        <div class="user-profile-details">
                            <div class="account-info">
                                <div class="title">
                                    <h4>{{ __('Profile Information') }}</h4>
                                </div>
                                <div class="row mt-4">
                                    <div class="col-md-6 mb-3">
                                        <h6>{{ __('City') }}</h6>
                                        <p>{{ $customer->city ?? __('N/A') }}</p>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <h6>{{ __('Country') }}</h6>
                                        <p>{{ $customer->country ?? __('N/A') }}</p>
                                    </div>
                                    <div class="col-md-12 mb-3">
                                        <h6>{{ __('Address') }}</h6>
                                        <p>{{ $customer->address ?? __('N/A') }}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection