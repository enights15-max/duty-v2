<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Follow extends Model
{
    protected $fillable = [
        'follower_id',
        'follower_type',
        'followable_id',
        'followable_type',
        'status'
    ];

    public function follower()
    {
        return $this->morphTo();
    }

    public function followable()
    {
        return $this->morphTo();
    }
}
