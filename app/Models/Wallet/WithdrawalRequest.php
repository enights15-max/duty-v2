<?php

namespace App\Models\Wallet;

use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WithdrawalRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'identity_id',
        'actor_type',
        'display_name',
        'amount',
        'method',
        'payment_details',
        'status',
        'admin_notes',
        'transaction_id',
    ];

    protected $casts = [
        'payment_details' => 'array',
        'amount' => 'float',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
