<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeePolicyAuditLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'fee_policy_id',
        'admin_id',
        'action',
        'before',
        'after',
        'meta',
    ];

    protected $casts = [
        'before' => 'array',
        'after' => 'array',
        'meta' => 'array',
    ];

    public function policy()
    {
        return $this->belongsTo(FeePolicy::class, 'fee_policy_id');
    }

    public function admin()
    {
        return $this->belongsTo(Admin::class, 'admin_id');
    }
}
