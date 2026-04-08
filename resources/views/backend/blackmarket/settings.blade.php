@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Blackmarket Settings') }}</h4>
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
                <a href="#">{{ __('Blackmarket') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Settings') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <form id="ajaxForm" action="{{ route('admin.blackmarket.update_settings') }}" method="post">
                    @csrf
                    <div class="card-header">
                        <div class="row">
                            <div class="col-lg-10">
                                <div class="card-title">{{ __('Update Blackmarket Settings') }}</div>
                            </div>
                        </div>
                    </div>

                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-6 offset-lg-3">
                                <div class="form-group">
                                    <label>{{ __('Marketplace Commission') . ' (%) *' }}</label>
                                    <input type="number" step="0.01" class="form-control" name="marketplace_commission"
                                        value="{{ $data->marketplace_commission }}"
                                        placeholder="{{ __('Enter Marketplace Commission') }}">
                                    <p id="err_marketplace_commission" class="mt-2 mb-0 text-danger em"></p>
                                    <small
                                        class="form-text text-muted">{{ __('Commission charged to the buyer on Blackmarket transactions.') }}</small>
                                </div>

                                <div class="form-group">
                                    <label>{{ __('Price Logic Rule') . ' *' }}</label>
                                    <div class="selectgroup w-100">
                                        <label class="selectgroup-item">
                                            <input type="radio" name="marketplace_max_price_rule" value="1"
                                                class="selectgroup-input" {{ $data->marketplace_max_price_rule == 1 ? 'checked' : '' }}>
                                            <span class="selectgroup-button">{{ __('Restrict Price') }}</span>
                                        </label>
                                        <label class="selectgroup-item">
                                            <input type="radio" name="marketplace_max_price_rule" value="0"
                                                class="selectgroup-input" {{ $data->marketplace_max_price_rule == 0 ? 'checked' : '' }}>
                                            <span class="selectgroup-button">{{ __('No Restriction') }}</span>
                                        </label>
                                    </div>
                                    <p id="err_marketplace_max_price_rule" class="mt-2 mb-0 text-danger em"></p>
                                    <small
                                        class="form-text text-muted">{{ __('If enabled, tickets cannot be listed for more than their original purchase price.') }}</small>
                                </div>
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
                </form>
            </div>
        </div>
    </div>
@endsection