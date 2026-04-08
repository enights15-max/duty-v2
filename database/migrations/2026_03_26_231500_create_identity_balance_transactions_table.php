<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('identity_balance_transactions')) {
            Schema::create('identity_balance_transactions', function (Blueprint $table): void {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('identity_id');
                $table->string('type', 32);
                $table->decimal('amount', 15, 2);
                $table->string('description')->nullable();
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->decimal('balance_before', 15, 2)->default(0);
                $table->decimal('balance_after', 15, 2)->default(0);
                $table->json('meta')->nullable();
                $table->timestamps();

                $table->index(['identity_id', 'created_at']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('identity_balance_transactions');
    }
};
