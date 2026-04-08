<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wallet_id')->constrained('wallets')->onDelete('cascade'); // Link to wallets.id (uuid)
            $table->enum('type', ['credit', 'debit', 'hold_release']);
            $table->decimal('amount', 10, 2);
            $table->string('reference_type')->nullable(); // poly: topup, ticket, pos, refund
            $table->string('reference_id')->nullable(); // External ID (Stripe Intent ID, Ticket ID, POS ID)
            $table->string('idempotency_key')->unique();
            $table->enum('status', ['pending', 'completed', 'failed', 'reversed'])->default('completed');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('wallet_transactions');
    }
};
