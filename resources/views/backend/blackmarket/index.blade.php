@extends('backend.layout')

@section('style')
  @includeIf('backend.partials.scarlet-operations-workspace')
@endsection

@section('content')
    @php
        $listedCount = count($tickets);
        $listingTotal = collect($tickets->items())->sum(fn ($ticket) => (float) $ticket->listing_price);
    @endphp
    <div class="page-header">
        <h4 class="page-title">{{ __('Blackmarket') }}</h4>
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
                <a href="#">{{ __('Listed Tickets') }}</a>
            </li>
        </ul>
    </div>

    <div class="ops-shell">
        <div class="ops-hero">
            <div class="ops-hero__grid">
                <div>
                    <span class="ops-hero__eyebrow">{{ __('Blackmarket') }}</span>
                    <h1 class="ops-hero__title">{{ __('Resale visibility and market integrity') }}</h1>
                    <p class="ops-hero__copy">
                        {{ __('Review active resale listings, inspect seller context and keep an eye on price movement without leaving the operations panel.') }}
                    </p>
                </div>
                <div class="ops-hero__meta">
                    <div class="ops-hero__stat">
                        <span class="ops-hero__stat-label">{{ __('Listings on page') }}</span>
                        <span class="ops-hero__stat-value">{{ number_format($listedCount) }}</span>
                        <span class="ops-hero__stat-note">{{ __('Current page result count') }}</span>
                    </div>
                    <div class="ops-hero__stat">
                        <span class="ops-hero__stat-label">{{ __('Visible listing value') }}</span>
                        <span class="ops-hero__stat-value">RD$ {{ number_format((float) $listingTotal, 2) }}</span>
                        <span class="ops-hero__stat-note">{{ __('Combined listing amount across visible rows') }}</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="card ops-panel">
                <div class="card-header">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card-title">{{ __('Listed Tickets') }}</div>
                        </div>

                        <div class="col-lg-8">
                            <div class="row justify-content-lg-end justify-content-start">
                                <div class="col-lg-6">
                                    <form class="ml-3" action="{{ route('admin.blackmarket.tickets') }}" method="GET">
                                        <input name="search" type="text" class="form-control"
                                            placeholder="{{ __('Search By Order Number or Email') }}"
                                            value="{{ request()->input('search') }}">
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-12">
                            @if (count($tickets) == 0)
                                <div class="ops-empty">
                                    <h3>{{ __('No resale listings found') }}</h3>
                                    <p>{{ __('There are no current blackmarket listings matching the search input.') }}</p>
                                </div>
                            @else
                                <div class="table-responsive">
                                    <table class="table table-striped mt-3 ops-table">
                                        <thead>
                                            <tr>
                                                <th scope="col">{{ __('Order Number') }}</th>
                                                <th scope="col" width="25%">{{ __('Event') }}</th>
                                                <th scope="col">{{ __('Seller') }}</th>
                                                <th scope="col">{{ __('Orig. Price') }}</th>
                                                <th scope="col">{{ __('Listing Price') }}</th>
                                                <th scope="col">{{ __('Date Listed') }}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach ($tickets as $ticket)
                                                <tr>
                                                    <td>{{ '#' . $ticket->order_number }}</td>
                                                    <td>
                                                        @if ($ticket->event)
                                                            {{ $ticket->event->title }}
                                                        @else
                                                            {{ '-' }}
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if ($ticket->customerInfo)
                                                            {{ $ticket->customerInfo->fname }} {{ $ticket->customerInfo->lname }}
                                                            <br>
                                                            <small>({{ $ticket->customerInfo->username }})</small>
                                                        @else
                                                            {{ '-' }}
                                                        @endif
                                                    </td>
                                                    <td>
                                                        {{ $ticket->currencySymbol }} {{ $ticket->price }}
                                                    </td>
                                                    <td>
                                                        {{ $ticket->currencySymbol }} {{ $ticket->listing_price }}
                                                    </td>
                                                    <td>{{ $ticket->updated_at->format('M d, Y') }}</td>
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
                        {{ $tickets->appends(['search' => request()->input('search')])->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
