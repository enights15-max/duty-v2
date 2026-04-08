@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Wallet Management') }}</h4>
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
                <a href="#">{{ __('Customer Wallets') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card-title">{{ __('All Wallets') }}</div>
                        </div>

                        <div class="col-lg-6 offset-lg-2">
                            <form class="float-right" action="" method="GET">
                                <input name="info" type="text" class="form-control min-230"
                                    placeholder="Search By Username, Name or Email"
                                    value="{{ !empty(request()->input('info')) ? request()->input('info') : '' }}">
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($wallets) == 0)
                                <h3 class="text-center">{{ __('NO WALLETS FOUND') . '!' }}</h3>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3">
                                        <thead>
                                            <tr>
                                                <th scope="col">{{ __('Customer Name') }}</th>
                                                <th scope="col">{{ __('Email ') }}</th>
                                                <th scope="col">{{ __('Balance') }}</th>
                                                <th scope="col">{{ __('Status') }}</th>
                                                <th scope="col">{{ __('Actions') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($wallets as $wallet)
                                                <tr>
                                                    <td>{{ $wallet->user->fname ?? 'N/A' }} {{ $wallet->user->lname ?? '' }}</td>
                                                    <td>{{ $wallet->user->email ?? 'N/A' }}</td>
                                                    <td>{{ env('BASE_CURRENCY_SYMBOL_POSITION') == 'left' ? env('BASE_CURRENCY_SYMBOL') : '' }}
                                                        {{ $wallet->balance }}
                                                        {{ env('BASE_CURRENCY_SYMBOL_POSITION') == 'right' ? env('BASE_CURRENCY_SYMBOL') : '' }}
                                                    </td>
                                                    <td>
                                                        @if ($wallet->status == 'active')
                                                            <span class="badge badge-success">{{ __('Active') }}</span>
                                                        @else
                                                            <span class="badge badge-danger">{{ __('Locked') }}</span>
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
                                                                <a href="{{ route('admin.wallet_management.wallet_history', ['id' => $wallet->id]) }}"
                                                                    class="dropdown-item">
                                                                    {{ __('History') }}
                                                                </a>

                                                                <a href="javascript:void(0)" class="dropdown-item"
                                                                    data-toggle="modal"
                                                                    data-target="#adjustBalanceModal{{ $wallet->id }}">
                                                                    {{ __('Adjust Balance') }}
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>

                                                {{-- Adjust Balance Modal --}}
                                                <div class="modal fade" id="adjustBalanceModal{{ $wallet->id }}" tabindex="-1"
                                                    role="dialog" aria-labelledby="adjustBalanceModalLabel" aria-hidden="true">
                                                    <div class="modal-dialog" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title" id="adjustBalanceModalLabel">
                                                                    {{ __('Adjust Wallet Balance') }} - {{ $wallet->user->fname ?? 'Unknown' }}
                                                                    {{ $wallet->user->lname ?? '' }}</h5>
                                                                <button type="button" class="close" data-dismiss="modal"
                                                                    aria-label="Close">
                                                                    <span aria-hidden="true">&times;</span>
                                                                </button>
                                                            </div>
                                                            <form
                                                                action="{{ route('admin.wallet_management.wallet_adjust', ['id' => $wallet->id]) }}"
                                                                method="POST">
                                                                @csrf
                                                                <div class="modal-body">
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Adjustment Type') }} **</label>
                                                                        <select name="type" class="form-control" required>
                                                                            <option value="add">{{ __('Add Balance') }}</option>
                                                                            <option value="subtract">{{ __('Subtract Balance') }}
                                                                            </option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Amount') }} **</label>
                                                                        <input type="number" step="0.01" class="form-control"
                                                                            name="amount" placeholder="e.g. 50.00" required>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <label for="">{{ __('Reason / Description') }} **</label>
                                                                        <input type="text" class="form-control" name="description"
                                                                            placeholder="e.g. Promotional credit" required>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary"
                                                                        data-dismiss="modal">{{ __('Close') }}</button>
                                                                    <button type="submit"
                                                                        class="btn btn-primary">{{ __('Submit') }}</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
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
                        {{ $wallets->appends(['info' => request()->input('info')])->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection