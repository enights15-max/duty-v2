<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventTreasury extends Model
{
    use HasFactory;

    public const STATUS_COLLECTING = 'collecting';
    public const STATUS_AWAITING_SETTLEMENT = 'awaiting_settlement';
    public const STATUS_SETTLEMENT_HOLD = 'settlement_hold';
    public const STATUS_ELIGIBLE_FOR_PAYOUT = 'eligible_for_payout';
    public const STATUS_SETTLED = 'settled';

    protected $fillable = [
        'event_id',
        'gross_collected',
        'refunded_amount',
        'platform_fee_total',
        'reserved_for_owner',
        'reserved_for_collaborators',
        'released_to_wallet',
        'available_for_settlement',
        'hold_until',
        'admin_release_approved_at',
        'admin_release_approved_by_admin_id',
        'settlement_status',
        'auto_payout_enabled',
        'auto_payout_delay_hours',
    ];

    protected $casts = [
        'gross_collected' => 'float',
        'refunded_amount' => 'float',
        'platform_fee_total' => 'float',
        'reserved_for_owner' => 'float',
        'reserved_for_collaborators' => 'float',
        'released_to_wallet' => 'float',
        'available_for_settlement' => 'float',
        'hold_until' => 'datetime',
        'admin_release_approved_at' => 'datetime',
        'auto_payout_enabled' => 'boolean',
    ];

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function entries()
    {
        return $this->hasMany(EventFinancialEntry::class, 'treasury_id');
    }

    public function getClaimableAmountAttribute(): float
    {
        return round(max(
            0,
            (float) $this->available_for_settlement
            - (float) $this->reserved_for_collaborators
            - (float) $this->released_to_wallet
        ), 2);
    }
}
