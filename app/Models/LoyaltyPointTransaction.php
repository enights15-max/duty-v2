<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LoyaltyPointTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'rule_id',
        'type',
        'points',
        'balance_after',
        'reference_type',
        'reference_id',
        'idempotency_key',
        'meta',
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function rule()
    {
        return $this->belongsTo(LoyaltyRule::class, 'rule_id');
    }
}
