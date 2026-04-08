<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use Illuminate\Database\Eloquent\Concerns\HasUuids;

class WalletHold extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'wallet_id',
        'amount',
        'expires_at',
        'reference_type',
        'reference_id',
        'status',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }
}
