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
        $policy = $catalog[FeeEngine::OP_MARKETPLACE_CARD_PROCESSING] ?? null;

        if (!$policy) {
            return;
        }

        $payload = [];
        foreach ([
            'label' => $policy['label'],
            'description' => $policy['description'],
            'fee_type' => $policy['fee_type'],
            'percentage_value' => $policy['percentage_value'],
            'fixed_value' => $policy['fixed_value'],
            'minimum_fee' => $policy['minimum_fee'],
            'maximum_fee' => $policy['maximum_fee'],
            'charged_to' => $policy['charged_to'] ?? FeePolicy::CHARGED_TO_BUYER,
            'currency' => $policy['currency'] ?? 'DOP',
            'is_active' => $policy['is_active'] ?? true,
            'meta' => isset($policy['meta']) ? json_encode($policy['meta']) : null,
            'created_at' => now(),
            'updated_at' => now(),
        ] as $column => $value) {
            if (isset($columns[$column])) {
                $payload[$column] = $value;
            }
        }

        DB::table('fee_policies')->updateOrInsert(
            ['operation_key' => FeeEngine::OP_MARKETPLACE_CARD_PROCESSING],
            $payload
        );
    }

    public function down(): void
    {
        if (!Schema::hasTable('fee_policies') || !Schema::hasColumn('fee_policies', 'operation_key')) {
            return;
        }

        DB::table('fee_policies')
            ->where('operation_key', FeeEngine::OP_MARKETPLACE_CARD_PROCESSING)
            ->delete();
    }
};
