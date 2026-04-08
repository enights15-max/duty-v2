<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Follower extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'following_id',
        'following_type',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function following()
    {
        return $this->morphTo();
    }
}
