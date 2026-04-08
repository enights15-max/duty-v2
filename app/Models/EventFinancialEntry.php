<?php

namespace App\Models;

use App\Models\Event\Booking;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventFinancialEntry extends Model
{
    use HasFactory;

    public const TYPE_OWNER_SHARE_RESERVED = 'owner_share_reserved';
    public const TYPE_OWNER_SHARE_RELEASED_TO_WALLET = 'owner_share_released_to_wallet';
    public const TYPE_COLLABORATOR_SHARE_RESERVED = 'collaborator_share_reserved';
    public const TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET = 'collaborator_share_released_to_wallet';
    public const TYPE_RESERVATION_PAYMENT_RESERVED = 'reservation_payment_reserved';
    public const TYPE_RESERVATION_REFUND_PROCESSED = 'reservation_refund_processed';
    public const TYPE_SETTLEMENT_HOLD_OPENED = 'settlement_hold_opened';
    public const TYPE_REFUND_WINDOW_OPENED = 'refund_window_opened';
    public const TYPE_SETTLEMENT_RELEASE_APPROVED = 'settlement_release_approved';

    protected $fillable = [
        'treasury_id',
        'event_id',
        'booking_id',
        'idempotency_key',
        'entry_type',
        'reference_type',
        'reference_id',
        'actor_customer_id',
        'owner_identity_id',
        'owner_identity_type',
        'target_identity_id',
        'target_identity_type',
        'organizer_id',
        'venue_id',
        'gross_amount',
        'fee_amount',
        'net_amount',
        'currency',
        'status',
        'metadata',
        'occurred_at',
    ];

    protected $casts = [
        'gross_amount' => 'float',
        'fee_amount' => 'float',
        'net_amount' => 'float',
        'metadata' => 'array',
        'occurred_at' => 'datetime',
    ];

    public function treasury()
    {
        return $this->belongsTo(EventTreasury::class, 'treasury_id');
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }
}
