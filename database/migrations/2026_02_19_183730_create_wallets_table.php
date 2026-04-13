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
        if (Schema::hasTable('wallets')) { return; }

        Schema::create('wallets', function (Blueprint $table) {
            $table->uuid('id')->primary(); // Spec requests UUID
            $table->unsignedBigInteger('user_id');
            $table->decimal('balance', 10, 2)->default(0.00);
            $table->char('currency', 3)->default('DOP');
            $table->enum('status', ['active', 'frozen'])->default('active');
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
        Schema::dropIfExists('wallets');
    }
};
