<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IdentityMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'identity_id',
        'user_id',
        'role',
        'permissions',
        'status',
    ];

    protected $casts = [
        'permissions' => 'array',
    ];

    public function identity()
    {
        return $this->belongsTo(Identity::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
