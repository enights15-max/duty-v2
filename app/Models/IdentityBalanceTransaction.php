<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IdentityBalanceTransaction extends Model
{
    use HasFactory;
    use HasUuids;

    protected $fillable = [
        'identity_id',
        'type',
        'amount',
        'description',
        'reference_type',
        'reference_id',
        'balance_before',
        'balance_after',
        'meta',
    ];

    protected $casts = [
        'meta' => 'array',
        'amount' => 'float',
        'balance_before' => 'float',
        'balance_after' => 'float',
    ];
}
