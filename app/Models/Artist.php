<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Laravel\Sanctum\HasApiTokens;

class Artist extends Model implements AuthenticatableContract
{
    use HasApiTokens, HasFactory, Authenticatable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'photo',
        'details',
        'facebook',
        'twitter',
        'linkedin',
        'status',
        'amount',
        'email_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    public function followers()
    {
        return $this->morphMany(Follower::class, 'following');
    }

    public function events()
    {
        return $this->belongsToMany(Event::class, 'event_artist');
    }
}
