@extends('backend.layout')

@section('style')
  @includeIf('backend.partials.scarlet-operations-workspace')
@endsection

@section('content')
    @php
        $pendingCount = collect($collection)->where('status', 0)->count();
        $visiblePayable = collect($collection)->sum(fn ($item) => (float) $item->payable_amount);
    @endphp
    <div class="page-header">
        <h4 class="page-title">{{ __('Withdraw Requests') }}</h4>
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
                <a href="#">{{ __('Withdraw Method') }}</a>
            </li>
            <li class="separator">
                <i class="flaticon-right-arrow"></i>
            </li>
            <li class="nav-item">
                <a href="#">{{ __('Withdraw Requests') }}</a>
            </li>
        </ul>
    </div>

    <div class="ops-shell">
        <div class="ops-hero">
            <div class="ops-hero__grid">
                <div>
                    <span class="ops-hero__eyebrow">{{ __('Withdraw requests') }}</span>
                    <h1 class="ops-hero__title">{{ __('Review payouts before money leaves the system') }}</h1>
                    <p class="ops-hero__copy">
                        {{ __('Approve, decline or inspect payout requests with actor context, method details and payable totals in a single review queue.') }}
                    </p>
                </div>
                <div class="ops-hero__meta">
                    <div class="ops-hero__stat">
                        <span class="ops-hero__stat-label">{{ __('Pending in view') }}</span>
                        <span class="ops-hero__stat-value">{{ number_format($pendingCount) }}</span>
                        <span class="ops-hero__stat-note">{{ __('Requests still waiting for approval on this page') }}</span>
                    </div>
                    <div class="ops-hero__stat">
                        <span class="ops-hero__stat-label">{{ __('Visible payable') }}</span>
                        <span class="ops-hero__stat-value">
                            {{ $currencyInfo->base_currency_symbol_position == 'left' ? $currencyInfo->base_currency_symbol : '' }}{{ number_format((float) $visiblePayable, 2) }}{{ $currencyInfo->base_currency_symbol_position == 'right' ? $currencyInfo->base_currency_symbol : '' }}
                        </span>
                        <span class="ops-hero__stat-note">{{ __('Combined payable amount across visible requests') }}</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="card ops-panel">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card-title d-inline-block">{{ __('Withdraw Requests') }}</div>
                        </div>
                        <div class="col-lg-6 offset-lg-2">
                            <form class="float-right" action="{{ route('admin.withdraw.withdraw_request') }}"
                                method="GET">
                                <input name="search" type="text" class="form-control min-230"
                                    placeholder="Search  withdraw id, method name" value="{{ request()->input('search') }}">
                            </form>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($collection) == 0)
                                <div class="ops-empty">
                                    <h3>{{ __('No withdraw requests found') }}</h3>
                                    <p>{{ __('Search by request ID or method name to narrow down the payout queue.') }}</p>
                                </div>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3 ops-table">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th scope="col">{{ __('Withdraw Id') }}</th>
                                                <th scope="col">{{ __('Method Name') }}</th>
                                                <th scope="col">{{ __('Total Amount') }}</th>
                                                <th scope="col">{{ __('Total Charge') }}</th>
                                                <th scope="col">{{ __('Total Payable Amount') }}</th>
                                                <th scope="col">{{ __('Status') }}</th>
                                                <th scope="col">{{ __('Actions') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($collection as $item)
                                                <tr>
                                                    <td>{{ $loop->iteration }}</td>
                                                    <td>{{ $item->withdraw_id }}</td>
                                                    <td>
                                                        {{ optional($item->method)->name }}
                                                    </td>
                                                    <td>
                                                        {{ $currencyInfo->base_currency_symbol_position == 'left' ? $currencyInfo->base_currency_symbol : '' }}
                                                        {{ $item->amount }}
                                                        {{ $currencyInfo->base_currency_symbol_position == 'right' ? $currencyInfo->base_currency_symbol : '' }}
                                                    </td>
                                                    <td>
                                                        {{ $currencyInfo->base_currency_symbol_position == 'left' ? $currencyInfo->base_currency_symbol : '' }}
                                                        {{ $item->total_charge }}
                                                        {{ $currencyInfo->base_currency_symbol_position == 'right' ? $currencyInfo->base_currency_symbol : '' }}
                                                    </td>
                                                    <td>
                                                        {{ $currencyInfo->base_currency_symbol_position == 'left' ? $currencyInfo->base_currency_symbol : '' }}
                                                        {{ $item->payable_amount }}
                                                        {{ $currencyInfo->base_currency_symbol_position == 'right' ? $currencyInfo->base_currency_symbol : '' }}
                                                    </td>
                                                    <td>
                                                        @if ($item->status == 0)
                                                            <span class="badge badge-danger">{{ __('Pending') }}</span>
                                                        @elseif($item->status == 1)
                                                            <span class="badge badge-success">{{ __('Approved') }}</span>
                                                        @elseif($item->status == 2)
                                                            <span class="badge badge-warning">{{ __('Decline') }}</span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        <a href="javascript:void(0)" data-toggle="modal"
                                                            data-target="#withdrawModal{{ $item->id }}"
                                                            class="btn btn-primary mt-1 btn-xs"><span class="btn-label">
                                                                <i class="fas fa-eye"></i>
                                                            </span> {{ __('View') }}</a>
                                                        @if ($item->status == 0)
                                                            <a href="{{ route('admin.witdraw.approve_withdraw', ['id' => $item->id]) }}"
                                                                class="btn btn-success mt-1 btn-xs  confirmBtn"><span
                                                                    class="btn-label">
                                                                    <i class="fas fa-check-circle"></i>
                                                                </span> {{ __('Approve') }}</a>
                                                            <a href="{{ route('admin.witdraw.decline_withdraw', ['id' => $item->id]) }}"
                                                                class="btn btn-warning mt-1 btn-xs confirmBtn"><span
                                                                    class="btn-label">
                                                                    <i class="fas fa-times"></i>
                                                                </span> {{ __('Decline') }}</a>
                                                        @endif



                                                        <form class="deleteForm d-inline-block"
                                                            action="{{ route('admin.witdraw.delete_withdraw', ['id' => $item->id]) }}"
                                                            method="post">

                                                            @csrf
                                                            <button type="submit"
                                                                class="btn btn-danger mt-1 btn-xs deleteBtn">
                                                                <span class="btn-label">
                                                                    <i class="fas fa-trash"></i>
                                                                </span>
                                                                {{ __('Delete') }}
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                                <div class="">
                                    {{ $collection->appends([
                                            'search' => request()->input('search'),
                                        ])->links() }}
                                </div>
                            @endif
                        </div>
                    </div>
                </div>

                <div class="card-footer"></div>
            </div>
        </div>
    </div>

    {{-- edit modal --}}
    @include('backend.withdraw.history.view')
@endsection
