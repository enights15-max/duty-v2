<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Wallet extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'actor_type',
        'actor_id',
        'balance',
        'currency',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(Customer::class, 'user_id');
    }

    public function transactions()
    {
        return $this->hasMany(WalletTransaction::class);
    }

    public function holds()
    {
        return $this->hasMany(WalletHold::class);
    }

    public function scopeForActor(Builder $query, $actor): Builder
    {
        $actorId = $actor instanceof Authenticatable ? (int) $actor->getAuthIdentifier() : (int) $actor;
        $actorType = $actor instanceof \App\Models\User ? 'user' : 'customer';

        return $query->where('actor_type', $actorType)->where('actor_id', $actorId);
    }
}
