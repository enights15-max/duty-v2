<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrganizerReview extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'organizer_id',
        'rating',
        'comment',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function organizer()
    {
        return $this->belongsTo(Organizer::class);
    }
}
