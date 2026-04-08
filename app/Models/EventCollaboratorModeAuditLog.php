<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventCollaboratorModeAuditLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'split_id',
        'earning_id',
        'identity_id',
        'actor_identity_id',
        'actor_identity_type',
        'previous_requires_claim',
        'previous_auto_release',
        'new_requires_claim',
        'new_auto_release',
        'source',
        'metadata',
    ];

    protected $casts = [
        'previous_requires_claim' => 'boolean',
        'previous_auto_release' => 'boolean',
        'new_requires_claim' => 'boolean',
        'new_auto_release' => 'boolean',
        'metadata' => 'array',
    ];

    public function split()
    {
        return $this->belongsTo(EventCollaboratorSplit::class, 'split_id');
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }
}
