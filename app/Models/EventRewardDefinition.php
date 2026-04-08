<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventRewardDefinition extends Model
{
    public const STATUS_ACTIVE = 'active';
    public const STATUS_INACTIVE = 'inactive';

    public const TRIGGER_ON_TICKET_SCAN = 'on_ticket_scan';
    public const TRIGGER_ON_BOOKING_COMPLETED = 'on_booking_completed';
    public const TRIGGER_MANUAL_ISSUE = 'manual_issue';

    protected $fillable = [
        'event_id',
        'title',
        'description',
        'reward_type',
        'trigger_mode',
        'fulfillment_mode',
        'inventory_limit',
        'per_ticket_quantity',
        'eligible_ticket_ids',
        'station_scope',
        'meta',
        'status',
        'exclusive_promoter_split_id',
        'sponsor_identity_id',
    ];

    protected $casts = [
        'inventory_limit' => 'integer',
        'per_ticket_quantity' => 'integer',
        'eligible_ticket_ids' => 'array',
        'exclusive_promoter_split_id' => 'integer',
        'sponsor_identity_id' => 'integer',
        'station_scope' => 'array',
        'meta' => 'array',
    ];

    public function sponsorIdentity()
    {
        return $this->belongsTo(Identity::class, 'sponsor_identity_id');
    }

    public function exclusivePromoterSplit()
    {
        return $this->belongsTo(EventCollaboratorSplit::class, 'exclusive_promoter_split_id');
    }

    public function event()
    {
        return $this->belongsTo(Event::class, 'event_id');
    }

    public function instances()
    {
        return $this->hasMany(EventRewardInstance::class, 'reward_definition_id');
    }
}
