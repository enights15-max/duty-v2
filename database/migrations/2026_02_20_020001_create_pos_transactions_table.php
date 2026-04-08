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
        Schema::create('pos_transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('pos_terminal_id')->index();
            $table->uuid('wallet_transaction_id')->unique();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('DOP');
            $table->enum('status', ['success', 'failed', 'refunded'])->default('success');
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pos_transactions');
    }
};
