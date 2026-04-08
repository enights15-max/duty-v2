<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RewardRedemption extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'reward_id',
        'loyalty_transaction_id',
        'bonus_transaction_id',
        'reward_type',
        'points_cost',
        'status',
        'meta',
        'fulfilled_at',
    ];

    protected $casts = [
        'meta' => 'array',
        'fulfilled_at' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function reward()
    {
        return $this->belongsTo(RewardCatalog::class, 'reward_id');
    }
}
