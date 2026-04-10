<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class TicketTransfer extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'from_customer_id',
        'to_customer_id',
        'notes',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function scopePending(Builder $query): Builder
    {
        if (Schema::hasColumn($this->getTable(), 'status')) {
            return $query->where($this->getTable() . '.status', 'pending');
        }

        return $query;
    }
}
