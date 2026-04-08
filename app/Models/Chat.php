<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Chat extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'organizer_id',
        'last_message',
        'last_message_at',
    ];

    public function messages()
    {
        return $this->hasMany(ChatMessage::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function organizer()
    {
        return $this->belongsTo(Organizer::class);
    }
}
