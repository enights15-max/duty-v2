<?php

namespace App\Models;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Schema;

class NfcToken extends Model
{
    use HasUuids;
    private static ?bool $hasActorColumns = null;

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

        self::$hasActorColumns = Schema::hasColumn('nfc_tokens', 'actor_type')
            && Schema::hasColumn('nfc_tokens', 'actor_id');

        return self::$hasActorColumns;
    }
}
