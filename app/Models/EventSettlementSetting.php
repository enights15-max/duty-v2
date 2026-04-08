<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventSettlementSetting extends Model
{
    use HasFactory;

    public const HOLD_MODE_MANUAL_ADMIN = 'manual_admin';
    public const HOLD_MODE_AUTO_AFTER_GRACE_PERIOD = 'auto_after_grace_period';
    public const DEFAULT_GRACE_PERIOD_HOURS = 72;
    public const DEFAULT_REFUND_WINDOW_HOURS = 72;

    protected $fillable = [
        'event_id',
        'hold_mode',
        'grace_period_hours',
        'refund_window_hours',
        'auto_release_owner_share',
        'auto_release_collaborator_shares',
        'require_admin_approval',
        'notes',
    ];

    protected $casts = [
        'grace_period_hours' => 'integer',
        'refund_window_hours' => 'integer',
        'auto_release_owner_share' => 'boolean',
        'auto_release_collaborator_shares' => 'boolean',
        'require_admin_approval' => 'boolean',
    ];

    public static function defaultAttributes(): array
    {
        return [
            'hold_mode' => self::HOLD_MODE_AUTO_AFTER_GRACE_PERIOD,
            'grace_period_hours' => self::DEFAULT_GRACE_PERIOD_HOURS,
            'refund_window_hours' => self::DEFAULT_REFUND_WINDOW_HOURS,
            'auto_release_owner_share' => false,
            'auto_release_collaborator_shares' => false,
            'require_admin_approval' => false,
            'notes' => null,
        ];
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }
}
