<?php

namespace App\Models;

use App\Models\Customer;
use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketTransfer extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'from_customer_id',
        'to_customer_id',
        'status',
        'flow',
        'notes',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function sender()
    {
        return $this->belongsTo(Customer::class, 'from_customer_id');
    }

    public function receiver()
    {
        return $this->belongsTo(Customer::class, 'to_customer_id');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->where($this->getTable() . '.status', 'pending');
    }
}
