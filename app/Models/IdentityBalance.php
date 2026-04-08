<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IdentityBalance extends Model
{
    use HasFactory;

    protected $fillable = [
        'identity_id',
        'legacy_type',
        'legacy_id',
        'balance',
        'last_synced_at',
    ];

    protected $casts = [
        'balance' => 'float',
        'last_synced_at' => 'datetime',
    ];

    public function identity()
    {
        return $this->belongsTo(Identity::class);
    }
}
