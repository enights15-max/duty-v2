<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventCollaboratorEarning extends Model
{
    use HasFactory;

    public const STATUS_PENDING_EVENT_COMPLETION = 'pending_event_completion';
    public const STATUS_PENDING_RELEASE = 'pending_release';
    public const STATUS_CLAIMABLE = 'claimable';
    public const STATUS_CLAIMED = 'claimed';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'event_id',
        'split_id',
        'identity_id',
        'identity_type',
        'role_type',
        'amount_reserved',
        'amount_claimed',
        'status',
        'released_at',
        'claimed_at',
        'last_calculated_at',
        'metadata',
    ];

    protected $casts = [
        'amount_reserved' => 'float',
        'amount_claimed' => 'float',
        'released_at' => 'datetime',
        'claimed_at' => 'datetime',
        'last_calculated_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function split()
    {
        return $this->belongsTo(EventCollaboratorSplit::class, 'split_id');
    }

    public function identity()
    {
        return $this->belongsTo(Identity::class);
    }

    public function getClaimableAmountAttribute(): float
    {
        return round(max(0, (float) $this->amount_reserved - (float) $this->amount_claimed), 2);
    }
}
