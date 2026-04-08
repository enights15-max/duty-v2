@php
    $priceSchedules = collect($priceSchedules ?? []);
    $currencyText = $currencyText ?? '';
@endphp

<input type="hidden" name="price_schedules_present" value="1">

<div class="card bg-transparent border border-secondary-subtle">
    <div class="card-body">
        <div class="d-flex justify-content-between align-items-start mb-3">
            <div>
                <h5 class="mb-1">{{ __('Scheduled Price Changes') }}</h5>
                <p class="text-muted mb-0">
                    {{ __('Define future price increases for this ticket. The current base price remains active until the first schedule date.') }}
                </p>
            </div>
            <button type="button" class="btn btn-sm btn-primary addPriceScheduleRow"
                data-currency="{{ $currencyText }}">
                <i class="fas fa-plus-circle"></i> {{ __('Add change') }}
            </button>
        </div>

        <div class="table-responsive">
            <table class="table table-bordered table-sm mb-0">
                <thead>
                    <tr>
                        <th>{{ __('Label') }}</th>
                        <th>{{ __('Effective From') }}</th>
                        <th>{{ __('Price') }}{{ $currencyText ? ' (' . $currencyText . ')' : '' }}</th>
                        <th>{{ __('Active') }}</th>
                        <th>{{ __('Action') }}</th>
                    </tr>
                </thead>
                <tbody id="priceScheduleRows" data-next-index="{{ $priceSchedules->count() }}">
                    @foreach ($priceSchedules as $index => $schedule)
                        <tr>
                            <td>
                                <input type="text" name="price_schedules[{{ $index }}][label]" class="form-control"
                                    value="{{ old("price_schedules.$index.label", $schedule->label) }}"
                                    placeholder="{{ __('Presale Phase 2') }}">
                            </td>
                            <td>
                                <input type="datetime-local" name="price_schedules[{{ $index }}][effective_from]"
                                    class="form-control"
                                    value="{{ old("price_schedules.$index.effective_from", optional($schedule->effective_from)->format('Y-m-d\TH:i')) }}">
                            </td>
                            <td>
                                <input type="number" step="0.01" min="0.01"
                                    name="price_schedules[{{ $index }}][price]" class="form-control"
                                    value="{{ old("price_schedules.$index.price", number_format((float) $schedule->price, 2, '.', '')) }}"
                                    placeholder="0.00">
                            </td>
                            <td class="text-center align-middle">
                                <input type="hidden" name="price_schedules[{{ $index }}][is_active]" value="0">
                                <input type="checkbox" name="price_schedules[{{ $index }}][is_active]" value="1"
                                    {{ old("price_schedules.$index.is_active", $schedule->is_active ? '1' : '0') == '1' ? 'checked' : '' }}>
                                <input type="hidden" name="price_schedules[{{ $index }}][sort_order]"
                                    value="{{ old("price_schedules.$index.sort_order", $schedule->sort_order ?? $index) }}">
                            </td>
                            <td class="text-center align-middle">
                                <button type="button" class="btn btn-sm btn-outline-danger removePriceScheduleRow">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
