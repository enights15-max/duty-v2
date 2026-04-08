<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeePolicy extends Model
{
    use HasFactory;

    public const TYPE_PERCENTAGE = 'percentage';
    public const TYPE_FIXED = 'fixed';
    public const TYPE_PERCENTAGE_PLUS_FIXED = 'percentage_plus_fixed';

    public const CHARGED_TO_BUYER = 'buyer';
    public const CHARGED_TO_SELLER = 'seller';
    public const CHARGED_TO_SPLIT = 'split';
    public const CHARGED_TO_PLATFORM = 'platform_absorbed';

    protected $fillable = [
        'operation_key',
        'label',
        'description',
        'fee_type',
        'percentage_value',
        'fixed_value',
        'minimum_fee',
        'maximum_fee',
        'charged_to',
        'currency',
        'is_active',
        'meta',
    ];

    protected $casts = [
        'percentage_value' => 'float',
        'fixed_value' => 'float',
        'minimum_fee' => 'float',
        'maximum_fee' => 'float',
        'is_active' => 'boolean',
        'meta' => 'array',
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
