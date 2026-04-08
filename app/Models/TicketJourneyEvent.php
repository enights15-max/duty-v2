<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketJourneyEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'event_id',
        'ticket_id',
        'actor_customer_id',
        'target_customer_id',
        'transfer_id',
        'type',
        'price',
        'metadata',
        'occurred_at',
    ];

    protected $casts = [
        'price' => 'float',
        'metadata' => 'array',
        'occurred_at' => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }
}
