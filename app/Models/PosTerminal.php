<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class PosTerminal extends Model
{
    use HasUuids;

    protected $fillable = [
        'organizer_id',
        'terminal_uuid',
        'name',
        'status',
        'last_active_at',
    ];

    protected $casts = [
        'last_active_at' => 'datetime',
    ];

    public function organizer()
    {
        return $this->belongsTo(User::class, 'organizer_id');
    }

    public function transactions()
    {
        return $this->hasMany(PosTransaction::class);
    }
}
