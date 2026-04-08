<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlatformRevenueEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'idempotency_key',
        'policy_id',
        'operation_key',
        'reference_type',
        'reference_id',
        'booking_id',
        'event_id',
        'ticket_id',
        'transfer_id',
        'actor_customer_id',
        'target_customer_id',
        'owner_identity_id',
        'owner_identity_type',
        'organizer_id',
        'venue_id',
        'artist_id',
        'venue_identity_id',
        'gross_amount',
        'fee_amount',
        'net_amount',
        'total_charge_amount',
        'charged_to',
        'currency',
        'status',
        'metadata',
        'occurred_at',
    ];

    protected $casts = [
        'gross_amount' => 'float',
        'fee_amount' => 'float',
        'net_amount' => 'float',
        'total_charge_amount' => 'float',
        'metadata' => 'array',
        'occurred_at' => 'datetime',
    ];

    public function policy()
    {
        return $this->belongsTo(FeePolicy::class, 'policy_id');
    }
}
