<?php

namespace App\Models;

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
    ];
}
