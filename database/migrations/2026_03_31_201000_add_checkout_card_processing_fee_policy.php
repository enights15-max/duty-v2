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
        if (!Schema::hasTable('fee_policies') || !Schema::hasColumn('fee_policies', 'operation_key')) {
            return;
        }

        $columns = array_flip(Schema::getColumnListing('fee_policies'));
        $catalog = app(FeeEngine::class)->catalog();
        $policy = $catalog[FeeEngine::OP_CHECKOUT_CARD_PROCESSING] ?? null;
        if (!$policy) {
            return;
        }

        $basePayload = [
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

        $payload = [];
        foreach ($basePayload as $column => $value) {
            if (isset($columns[$column])) {
                $payload[$column] = $value;
            }
        }

        if (isset($columns['created_at'])) {
            $payload['created_at'] = now();
        }

        DB::table('fee_policies')->updateOrInsert(
            ['operation_key' => FeeEngine::OP_CHECKOUT_CARD_PROCESSING],
            $payload
        );
    }

    public function down(): void
    {
        if (!Schema::hasTable('fee_policies') || !Schema::hasColumn('fee_policies', 'operation_key')) {
            return;
        }

        DB::table('fee_policies')
            ->where('operation_key', FeeEngine::OP_CHECKOUT_CARD_PROCESSING)
            ->delete();
    }
};
