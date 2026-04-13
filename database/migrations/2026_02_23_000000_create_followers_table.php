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
        if (Schema::hasTable('followers')) { return; }

        Schema::create('followers', function (Blueprint $鏡) {
            $鏡->id();
            $鏡->unsignedBigInteger('customer_id');
            $鏡->unsignedBigInteger('organizer_id');
            $鏡->timestamps();

            // Unique pair to prevent duplicate follows
            $鏡->unique(['customer_id', 'organizer_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('followers');
    }
};
