@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Wallet History') }} - {{ $wallet->user->fname ?? 'N/A' }}
            {{ $wallet->user->lname ?? '' }}</h4>
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
                <a href="{{ route('admin.wallet_management.wallets') }}">{{ __('Customer Wallets') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Wallet History') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="card-title">{{ __('Wallet Transactions for') }} {{ $wallet->user->email ?? 'N/A' }}
                        </div>
                        <div>
                            <strong>{{ __('Current Balance:') }}</strong>
                            {{ env('BASE_CURRENCY_SYMBOL_POSITION') == 'left' ? env('BASE_CURRENCY_SYMBOL') : '' }}
                            {{ $wallet->balance }}
                            {{ env('BASE_CURRENCY_SYMBOL_POSITION') == 'right' ? env('BASE_CURRENCY_SYMBOL') : '' }}
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($transactions) == 0)
                                <h3 class="text-center">{{ __('NO TRANSACTIONS FOUND') . '!' }}</h3>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3">
                                        <thead>
                                            <tr>
                                                <th scope="col">{{ __('Reference ID') }}</th>
                                                <th scope="col">{{ __('Type') }}</th>
                                                <th scope="col">{{ __('Amount') }}</th>
                                                <th scope="col">{{ __('Description') }}</th>
                                                <th scope="col">{{ __('By Admin') }}</th>
                                                <th scope="col">{{ __('Date') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($transactions as $transaction)
                                                <tr>
                                                    <td>{{ $transaction->reference_id ?? '-' }}</td>
                                                    <td>
                                                        @if ($transaction->type == 'deposit' || $transaction->type == 'admin_adjustment' && $transaction->amount > 0)
                                                            <span
                                                                class="badge badge-success">{{ ucfirst(str_replace('_', ' ', $transaction->type)) }}</span>
                                                        @else
                                                            <span
                                                                class="badge badge-danger">{{ ucfirst(str_replace('_', ' ', $transaction->type)) }}</span>
                                                        @endif
                                                    </td>
                                                    <td class="{{ $transaction->amount > 0 ? 'text-success' : 'text-danger' }}">
                                                        {{ $transaction->amount > 0 ? '+' : '' }}{{ $transaction->amount }}
                                                    </td>
                                                    <td>{{ $transaction->description }}</td>
                                                    <td>
                                                        @if($transaction->admin)
                                                            {{ $transaction->admin->username }}
                                                        @else
                                                            -
                                                        @endif
                                                    </td>
                                                    <td>{{ $transaction->created_at->format('M d, Y h:i A') }}</td>
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
                        {{ $transactions->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection