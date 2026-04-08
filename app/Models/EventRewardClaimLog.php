<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventRewardClaimLog extends Model
{
    protected $fillable = [
        'reward_instance_id',
        'action',
        'actor_identity_id',
        'station_id',
        'reason_code',
        'meta',
        'occurred_at',
    ];

    protected $casts = [
        'meta' => 'array',
        'occurred_at' => 'datetime',
    ];

    public function rewardInstance()
    {
        return $this->belongsTo(EventRewardInstance::class, 'reward_instance_id');
    }
}
