<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventCollaboratorSplit extends Model
{
    use HasFactory;

    public const TYPE_PERCENTAGE = 'percentage';
    public const TYPE_FIXED = 'fixed';
    public const BASIS_NET_EVENT_REVENUE = 'net_event_revenue';
    public const BASIS_GROSS_TICKET_SALES = 'gross_ticket_sales';
    public const RELEASE_MODE_CLAIM_REQUIRED = 'claim_required';
    public const RELEASE_MODE_AUTO_RELEASE = 'auto_release';
    public const RELEASE_MODE_INHERIT = 'inherit';

    public const STATUS_DRAFT = 'draft';
    public const STATUS_CONFIRMED = 'confirmed';
    public const STATUS_LOCKED = 'locked';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'event_id',
        'identity_id',
        'identity_type',
        'legacy_id',
        'role_type',
        'split_type',
        'split_value',
        'basis',
        'status',
        'release_mode',
        'requires_claim',
        'auto_release',
        'notes',
    ];

    protected $casts = [
        'split_value' => 'float',
        'requires_claim' => 'boolean',
        'auto_release' => 'boolean',
    ];

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function identity()
    {
        return $this->belongsTo(Identity::class);
    }

    public function earning()
    {
        return $this->hasOne(EventCollaboratorEarning::class, 'split_id');
    }

    public function modeAuditLogs()
    {
        return $this->hasMany(EventCollaboratorModeAuditLog::class, 'split_id');
    }
}
