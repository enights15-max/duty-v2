<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketTransfer extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'from_customer_id',
        'to_customer_id',
        'notes',
        'status',
        'flow',
    ];

    /**
     * Get the sender (from customer).
     */
    public function sender()
    {
        return $this->belongsTo(Customer::class, 'from_customer_id');
    }

    /**
     * Get the receiver (to customer).
     */
    public function receiver()
    {
        return $this->belongsTo(Customer::class, 'to_customer_id');
    }

    /**
     * Get the booking associated with this transfer.
     */
    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    /**
     * Scope to get only pending transfers.
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }
}
