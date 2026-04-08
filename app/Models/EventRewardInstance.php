<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Model;

class EventRewardInstance extends Model
{
    public const STATUS_RESERVED = 'reserved';
    public const STATUS_ACTIVATED = 'activated';
    public const STATUS_CLAIMED = 'claimed';
    public const STATUS_EXPIRED = 'expired';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'event_id',
        'reward_definition_id',
        'booking_id',
        'ticket_id',
        'customer_id',
        'ticket_unit_key',
        'instance_index',
        'claim_code',
        'claim_qr_payload',
        'status',
        'activated_at',
        'claimed_at',
        'expires_at',
        'claimed_by_identity_id',
        'claimed_station_id',
        'meta',
        'promoter_identity_id',
        'sponsor_identity_id',
    ];

    protected $casts = [
        'instance_index' => 'integer',
        'activated_at' => 'datetime',
        'claimed_at' => 'datetime',
        'expires_at' => 'datetime',
        'meta' => 'array',
        'sponsor_identity_id' => 'integer',
    ];

    public function sponsorIdentity()
    {
        return $this->belongsTo(Identity::class, 'sponsor_identity_id');
    }

    public function promoterIdentity()
    {
        return $this->belongsTo(Identity::class, 'promoter_identity_id');
    }

    public function event()
    {
        return $this->belongsTo(Event::class, 'event_id');
    }

    public function definition()
    {
        return $this->belongsTo(EventRewardDefinition::class, 'reward_definition_id');
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function claimLogs()
    {
        return $this->hasMany(EventRewardClaimLog::class, 'reward_instance_id');
    }
}
