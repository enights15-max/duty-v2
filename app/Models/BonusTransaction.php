<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BonusTransaction extends Model
{
    use HasFactory;
    use HasUuids;

    protected $fillable = [
        'bonus_wallet_id',
        'type',
        'amount',
        'reference_type',
        'reference_id',
        'idempotency_key',
        'status',
        'consumed_amount',
        'expired_amount',
        'expires_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'consumed_amount' => 'decimal:2',
        'expired_amount' => 'decimal:2',
        'expires_at' => 'datetime',
    ];

    public function bonusWallet()
    {
        return $this->belongsTo(BonusWallet::class);
    }
}
