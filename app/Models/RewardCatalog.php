<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RewardCatalog extends Model
{
    use HasFactory;

    protected $table = 'reward_catalog';

    protected $fillable = [
        'title',
        'description',
        'reward_type',
        'points_cost',
        'bonus_amount',
        'is_active',
        'is_featured',
        'meta',
    ];

    protected $casts = [
        'bonus_amount' => 'decimal:2',
        'is_active' => 'boolean',
        'is_featured' => 'boolean',
        'meta' => 'array',
    ];
}
