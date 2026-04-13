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
        if (Schema::hasTable('wallet_holds')) { return; }

        Schema::create('wallet_holds', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('wallet_id');
            $table->decimal('amount', 10, 2);
            $table->timestamp('expires_at');
            $table->string('reference_type')->nullable(); // e.g., 'ticket_purchase'
            $table->string('reference_id')->nullable();
            $table->enum('status', ['active', 'released', 'consumed'])->default('active');
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
        Schema::dropIfExists('wallet_holds');
    }
};
