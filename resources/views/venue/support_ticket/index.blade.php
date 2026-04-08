@extends('venue.layout')

@section('content')
    <div class="page-header">
        <h4 class="page-title">{{ __('Support Tickets') }}</h4>
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
                <a href="#">{{ __('Support Tickets') }}</a>
            </li>
        </ul>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="card-title">{{ __('All Tickets') }}</div>
                        </div>
                        <div class="col-lg-6 text-right">
                            <a href="{{ route('venue.support_ticket.create') }}" class="btn btn-primary btn-sm">
                                <i class="fas fa-plus"></i> {{ __('Create Ticket') }}
                            </a>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped mt-3">
                            <thead>
                                <tr>
                                    <th scope="col">{{ __('Ticket ID') }}</th>
                                    <th scope="col">{{ __('Subject') }}</th>
                                    <th scope="col">{{ __('Status') }}</th>
                                    <th scope="col">{{ __('Action') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($tickets as $ticket)
                                    <tr>
                                        <td>#{{ $ticket->ticket_id }}</td>
                                        <td>{{ $ticket->subject }}</td>
                                        <td>
                                            @if ($ticket->status == 1)
                                                <span class="badge badge-info">{{ __('Open') }}</span>
                                            @elseif($ticket->status == 2)
                                                <span class="badge badge-success">{{ __('Closed') }}</span>
                                            @else
                                                <span class="badge badge-secondary">{{ __('Pending') }}</span>
                                            @endif
                                        </td>
                                        <td>
                                            <a href="{{ route('venue.support_tickets.message', $ticket->id) }}"
                                                class="btn btn-primary btn-sm">
                                                <i class="fas fa-comments"></i>
                                            </a>
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    <div class="mt-3">
                        {{ $tickets->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection