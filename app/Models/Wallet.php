<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Support\Facades\Schema;

class Wallet extends Model
{
    use HasFactory, HasUuids;
    private static ?bool $hasActorColumns = null;

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

        if (self::supportsActorColumns()) {
            return $query->where('actor_type', $actorType)->where('actor_id', $actorId);
        }

        return $query->where('user_id', $actorId);
    }

    public static function supportsActorColumns(): bool
    {
        if (self::$hasActorColumns !== null) {
            return self::$hasActorColumns;
        }

        self::$hasActorColumns = Schema::hasColumn('wallets', 'actor_type')
            && Schema::hasColumn('wallets', 'actor_id');

        return self::$hasActorColumns;
    }
}
