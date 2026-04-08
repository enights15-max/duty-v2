<?php

namespace App\Models\Event;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketPriceSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'ticket_id',
        'label',
        'effective_from',
        'price',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'effective_from' => 'datetime',
        'price' => 'float',
        'sort_order' => 'integer',
        'is_active' => 'boolean',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class, 'ticket_id');
    }
}
