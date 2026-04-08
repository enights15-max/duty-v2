<?php

namespace App\Models\Reservation;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketReservationActionLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'reservation_id',
        'actor_type',
        'actor_id',
        'action',
        'meta',
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function reservation()
    {
        return $this->belongsTo(TicketReservation::class, 'reservation_id');
    }
}
