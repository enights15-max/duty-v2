<?php

namespace App\Models\Event;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventLineup extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'artist_id',
        'source_type',
        'display_name',
        'sort_order',
        'is_headliner',
    ];

    protected $casts = [
        'is_headliner' => 'boolean',
    ];

    public function event()
    {
        return $this->belongsTo(\App\Models\Event::class, 'event_id');
    }

    public function artist()
    {
        return $this->belongsTo(\App\Models\Artist::class, 'artist_id');
    }
}
