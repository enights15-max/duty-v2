<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class NfcToken extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'actor_type',
        'actor_id',
        'uid_hash',
        'pin_hash',
        'status',
        'daily_limit',
        'daily_spent',
        'last_used_at',
    ];

    protected $casts = [
        'last_used_at' => 'datetime',
        'daily_limit' => 'decimal:2',
        'daily_spent' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(Customer::class, 'user_id');
    }

    public function scopeForActor(Builder $query, $actor): Builder
    {
        $actorId = $actor instanceof Authenticatable ? (int) $actor->getAuthIdentifier() : (int) $actor;
        $actorType = $actor instanceof \App\Models\User ? 'user' : 'customer';

        return $query->where('actor_type', $actorType)->where('actor_id', $actorId);
    }
}
