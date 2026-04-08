<?php

use App\Models\FeePolicy;
use App\Services\FeeEngine;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('fee_policies')) {
            return;
        }

        DB::table('fee_policies')->updateOrInsert(
            ['operation_key' => FeeEngine::OP_WALLET_TOPUP],
            [
                'label' => 'Wallet topup',
                'description' => 'Buyer-paid processing fee for wallet topups.',
                'fee_type' => FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
                'percentage_value' => 5,
                'fixed_value' => 15,
                'minimum_fee' => null,
                'maximum_fee' => null,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'currency' => 'DOP',
                'is_active' => true,
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );
    }

    public function down(): void
    {
        if (!Schema::hasTable('fee_policies')) {
            return;
        }

        DB::table('fee_policies')
            ->where('operation_key', FeeEngine::OP_WALLET_TOPUP)
            ->update([
                'fee_type' => FeePolicy::TYPE_PERCENTAGE,
                'percentage_value' => 0,
                'fixed_value' => 0,
                'charged_to' => FeePolicy::CHARGED_TO_BUYER,
                'is_active' => false,
                'updated_at' => now(),
            ]);
    }
};
