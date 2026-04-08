<?php

namespace App\Models\Reservation;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReservationPayment extends Model
{
    use HasFactory;

    protected $fillable = [
        'reservation_id',
        'payment_group',
        'source_type',
        'amount',
        'fee_amount',
        'total_amount',
        'reference_type',
        'reference_id',
        'status',
        'paid_at',
        'meta',
    ];

    protected $casts = [
        'paid_at' => 'datetime',
        'meta' => 'array',
    ];

    public function reservation()
    {
        return $this->belongsTo(TicketReservation::class, 'reservation_id');
    }
}
