<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class BonusWallet extends Model
{
    use HasFactory;
    use HasUuids;

    private static ?bool $hasActorColumns = null;

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

        self::$hasActorColumns = Schema::hasColumn('bonus_wallets', 'actor_type')
            && Schema::hasColumn('bonus_wallets', 'actor_id');

        return self::$hasActorColumns;
    }
}
