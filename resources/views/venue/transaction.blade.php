@extends('venue.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Transactions') }}</h4>
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
                <a href="#">{{ __('Transactions') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">{{ __('Transaction History') }}</div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped mt-3">
                            <thead>
                                <tr>
                                    <th scope="col">{{ __('Trans ID') }}</th>
                                    <th scope="col">{{ __('Amount') }}</th>
                                    <th scope="col">{{ __('Type') }}</th>
                                    <th scope="col">{{ __('Date') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($transcations as $trans)
                                    <tr>
                                        <td>{{ $trans->transcation_id }}</td>
                                        <td>{{ $trans->currency_symbol }}{{ $trans->grand_total }}</td>
                                        <td>
                                            @if ($trans->transcation_type == 1)
                                                {{ __('Booking') }}
                                            @elseif($trans->transcation_type == 3)
                                                {{ __('Withdraw') }}
                                            @else
                                                {{ __('Other') }}
                                            @endif
                                        </td>
                                        <td>{{ $trans->created_at->format('d M, Y') }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    <div class="mt-3">
                        {{ $transcations->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection