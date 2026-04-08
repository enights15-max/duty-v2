<?php

namespace App\Models;

use App\Models\Event\Booking;
use App\Models\Event;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'booking_id',
        'event_id',
        'reviewable_id',
        'reviewable_type',
        'rating',
        'comment',
        'status',
        'meta',
        'submitted_at',
    ];

    protected $casts = [
        'rating' => 'integer',
        'meta' => 'array',
        'submitted_at' => 'datetime',
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
        return $this->belongsTo(Event::class, 'event_id');
    }

    public function reviewable()
    {
        return $this->morphTo();
    }
}
