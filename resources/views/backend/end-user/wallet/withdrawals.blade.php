@extends('backend.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Withdrawal Requests') }}</h4>
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
                <a href="#">{{ __('Withdrawals') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card-title">{{ __('All Requests') }}</div>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($withdrawals) == 0)
                                <h3 class="text-center">{{ __('NO REQUESTS FOUND') . '!' }}</h3>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3">
                                        <thead>
                                            <tr>
                                                <th scope="col">{{ __('Profile') }}</th>
                                                <th scope="col">{{ __('Amount') }}</th>
                                                <th scope="col">{{ __('Method') }}</th>
                                                <th scope="col">{{ __('Status') }}</th>
                                                <th scope="col">{{ __('Requested At') }}</th>
                                                <th scope="col">{{ __('Actions') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($withdrawals as $withdrawal)
                                                <tr>
                                                    <td>
                                                        <div class="d-flex flex-column">
                                                            <strong>{{ $withdrawal->display_name ?: ($withdrawal->customer->fname . ' ' . $withdrawal->customer->lname) }}</strong>
                                                            <small class="text-muted">
                                                                {{ $withdrawal->identity_id ? ucfirst($withdrawal->actor_type) . ' · ' : __('Personal') . ' · ' }}
                                                                {{ $withdrawal->customer->fname }} {{ $withdrawal->customer->lname }}
                                                            </small>
                                                            <small class="text-muted">{{ $withdrawal->customer->email }}</small>
                                                        </div>
                                                    </td>
                                                    <td>{{ env('BASE_CURRENCY_SYMBOL', '$') }}{{ number_format($withdrawal->amount, 2) }}
                                                    </td>
                                                    <td>{{ ucfirst($withdrawal->method) }}</td>
                                                    <td>
                                                        @if ($withdrawal->status == 'pending')
                                                            <span class="badge badge-warning">{{ __('Pending') }}</span>
                                                        @elseif($withdrawal->status == 'approved')
                                                            <span class="badge badge-success">{{ __('Approved') }}</span>
                                                        @else
                                                            <span class="badge badge-danger">{{ __('Rejected') }}</span>
                                                        @endif
                                                    </td>
                                                    <td>{{ $withdrawal->created_at->format('M d, Y H:i') }}</td>
                                                    <td>
                                                        @if ($withdrawal->status == 'pending')
                                                            <form
                                                                action="{{ route('admin.wallet_management.approve_withdrawal', $withdrawal->id) }}"
                                                                method="POST" style="display:inline-block;">
                                                                @csrf
                                                                <button type="submit"
                                                                    class="btn btn-success btn-sm">{{ __('Approve') }}</button>
                                                            </form>
                                                            <button type="button" class="btn btn-danger btn-sm" data-toggle="modal"
                                                                data-target="#rejectModal{{ $withdrawal->id }}">
                                                                {{ __('Reject') }}
                                                            </button>

                                                            {{-- Reject Modal --}}
                                                            <div class="modal fade" id="rejectModal{{ $withdrawal->id }}" tabindex="-1"
                                                                role="dialog">
                                                                <div class="modal-dialog" role="document">
                                                                    <div class="modal-content">
                                                                        <form
                                                                            action="{{ route('admin.wallet_management.reject_withdrawal', $withdrawal->id) }}"
                                                                            method="POST">
                                                                            @csrf
                                                                            <div class="modal-header">
                                                                                <h5 class="modal-title">{{ __('Reject Withdrawal') }}
                                                                                </h5>
                                                                                <button type="button" class="close"
                                                                                    data-dismiss="modal"><span>&times;</span></button>
                                                                            </div>
                                                                            <div class="modal-body">
                                                                                <div class="form-group">
                                                                                    <label>{{ __('Reason for Rejection') }}</label>
                                                                                    <textarea name="reason" class="form-control"
                                                                                        rows="3" required></textarea>
                                                                                </div>
                                                                            </div>
                                                                            <div class="modal-footer">
                                                                                <button type="button" class="btn btn-secondary"
                                                                                    data-dismiss="modal">{{ __('Close') }}</button>
                                                                                <button type="submit"
                                                                                    class="btn btn-danger">{{ __('Reject & Refund') }}</button>
                                                                            </div>
                                                                        </form>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        @else
                                                            <span class="text-muted">{{ __('No actions available') }}</span>
                                                        @endif
                                                    </td>
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
                        {{ $withdrawals->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
