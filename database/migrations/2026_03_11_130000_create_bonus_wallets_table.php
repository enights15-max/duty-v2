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
        Schema::create('bonus_wallets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('actor_type', 32)->nullable();
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->decimal('balance', 10, 2)->default(0.00);
            $table->char('currency', 3)->default('DOP');
            $table->enum('status', ['active', 'frozen'])->default('active');
            $table->timestamps();

            $table->index(['actor_type', 'actor_id'], 'bonus_wallets_actor_type_actor_id_idx');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bonus_wallets');
    }
};
