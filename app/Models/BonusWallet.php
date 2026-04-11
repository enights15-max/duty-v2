<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BonusWallet extends Model
{
    use HasFactory;
    use HasUuids;

    protected $fillable = [
        'user_id',
        'actor_type',
        'actor_id',
        'balance',
        'currency',
        'status',
    ];

    public function transactions()
    {
        return $this->hasMany(BonusTransaction::class);
    }

    public function scopeForActor(Builder $query, $actor): Builder
    {
        $actorId = $actor instanceof Authenticatable ? (int) $actor->getAuthIdentifier() : (int) $actor;
        $actorType = $actor instanceof \App\Models\User ? 'user' : 'customer';

        return $query->where('actor_type', $actorType)->where('actor_id', $actorId);
    }
}
