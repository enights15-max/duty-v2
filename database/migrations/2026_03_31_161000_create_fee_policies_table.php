<?php

use App\Models\BasicSettings\Basic;
use App\Services\FeeEngine;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('fee_policies')) {
            Schema::create('fee_policies', function (Blueprint $table): void {
                $table->id();
                $table->string('operation_key', 64)->unique();
                $table->string('label');
                $table->text('description')->nullable();
                $table->string('fee_type', 32)->default('percentage');
                $table->decimal('percentage_value', 8, 4)->nullable();
                $table->decimal('fixed_value', 12, 2)->nullable();
                $table->decimal('minimum_fee', 12, 2)->nullable();
                $table->decimal('maximum_fee', 12, 2)->nullable();
                $table->string('charged_to', 32)->default('seller');
                $table->string('currency', 8)->default('DOP');
                $table->boolean('is_active')->default(true);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        $engine = app(FeeEngine::class);
        $catalog = $engine->catalog();

        $rows = [];
        foreach ($catalog as $operationKey => $policy) {
            $rows[] = [
                'operation_key' => $operationKey,
                'label' => $policy['label'],
                'description' => $policy['description'],
                'fee_type' => $policy['fee_type'],
                'percentage_value' => $policy['percentage_value'],
                'fixed_value' => $policy['fixed_value'],
                'minimum_fee' => $policy['minimum_fee'],
                'maximum_fee' => $policy['maximum_fee'],
                'charged_to' => $policy['charged_to'],
                'currency' => $policy['currency'],
                'is_active' => $policy['is_active'],
                'meta' => isset($policy['meta']) ? json_encode($policy['meta']) : null,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        DB::table('fee_policies')->upsert(
            $rows,
            ['operation_key'],
            ['label', 'description', 'fee_type', 'percentage_value', 'fixed_value', 'minimum_fee', 'maximum_fee', 'charged_to', 'currency', 'is_active', 'meta', 'updated_at']
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('fee_policies');
    }
};
