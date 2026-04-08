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

        $catalog = app(FeeEngine::class)->catalog();
        $policy = $catalog[FeeEngine::OP_CHECKOUT_CARD_PROCESSING] ?? null;
        if (!$policy) {
            return;
        }

        $payload = [
            'operation_key' => FeeEngine::OP_CHECKOUT_CARD_PROCESSING,
            'label' => $policy['label'],
            'description' => $policy['description'],
            'fee_type' => $policy['fee_type'] ?? FeePolicy::TYPE_PERCENTAGE_PLUS_FIXED,
            'percentage_value' => $policy['percentage_value'],
            'fixed_value' => $policy['fixed_value'],
            'minimum_fee' => $policy['minimum_fee'],
            'maximum_fee' => $policy['maximum_fee'],
            'charged_to' => $policy['charged_to'] ?? FeePolicy::CHARGED_TO_BUYER,
            'currency' => $policy['currency'] ?? 'DOP',
            'is_active' => $policy['is_active'] ?? true,
            'meta' => isset($policy['meta']) ? json_encode($policy['meta']) : null,
            'updated_at' => now(),
        ];

        $existingId = DB::table('fee_policies')
            ->where('operation_key', FeeEngine::OP_CHECKOUT_CARD_PROCESSING)
            ->value('id');

        if ($existingId) {
            DB::table('fee_policies')
                ->where('id', $existingId)
                ->update($payload);
            return;
        }

        DB::table('fee_policies')->insert(array_merge($payload, [
            'created_at' => now(),
        ]));
    }

    public function down(): void
    {
        if (!Schema::hasTable('fee_policies')) {
            return;
        }

        DB::table('fee_policies')
            ->where('operation_key', FeeEngine::OP_CHECKOUT_CARD_PROCESSING)
            ->delete();
    }
};
