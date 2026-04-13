<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasTable('bonus_transactions')) { return; }

        Schema::create('bonus_transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bonus_wallet_id');
            $table->enum('type', ['credit', 'debit', 'reversal']);
            $table->decimal('amount', 10, 2);
            $table->string('reference_type')->nullable();
            $table->string('reference_id')->nullable();
            $table->string('idempotency_key')->unique();
            $table->enum('status', ['pending', 'completed', 'failed', 'reversed'])->default('completed');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bonus_transactions');
    }
};
