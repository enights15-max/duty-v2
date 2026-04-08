<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class EconomyRevenueExport implements FromCollection, WithHeadings, WithMapping
{
    public function __construct(
        private Collection $rows
    ) {
    }

    public function collection()
    {
        return $this->rows;
    }

    public function map($row): array
    {
        return [
            optional($row->occurred_at)->format('Y-m-d H:i:s'),
            $row->operation_key,
            $row->event_label ?? '',
            $row->organizer_label ?? '',
            $row->venue_label ?? '',
            number_format((float) $row->gross_amount, 2, '.', ''),
            number_format((float) $row->fee_amount, 2, '.', ''),
            number_format((float) $row->net_amount, 2, '.', ''),
            $row->charged_to,
            $row->reference_type,
            $row->reference_id,
            $row->booking_id,
            $row->transfer_id,
            $row->status,
        ];
    }

    public function headings(): array
    {
        return [
            'Occurred At',
            'Operation',
            'Event',
            'Organizer',
            'Venue',
            'Gross Amount',
            'Fee Amount',
            'Net Amount',
            'Charged To',
            'Reference Type',
            'Reference ID',
            'Booking ID',
            'Transfer ID',
            'Status',
        ];
    }
}
