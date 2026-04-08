<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ArtistTip extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'artist_id',
        'booking_id',
        'event_id',
        'amount',
        'wallet_amount',
        'card_amount',
        'currency',
        'status',
        'customer_wallet_transaction_id',
        'artist_wallet_transaction_id',
        'stripe_payment_intent_id',
        'meta',
        'completed_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'wallet_amount' => 'decimal:2',
        'card_amount' => 'decimal:2',
        'meta' => 'array',
        'completed_at' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function artist()
    {
        return $this->belongsTo(Artist::class);
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
