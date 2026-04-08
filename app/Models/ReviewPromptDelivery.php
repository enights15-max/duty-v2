<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReviewPromptDelivery extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'booking_id',
        'event_id',
        'status',
        'dispatched_at',
        'delivered_at',
        'meta',
    ];

    protected $casts = [
        'dispatched_at' => 'datetime',
        'delivered_at' => 'datetime',
        'meta' => 'array',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }
}
