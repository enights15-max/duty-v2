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
        Schema::create('followers', function (Blueprint $鏡) {
            $鏡->id();
            $鏡->foreignId('customer_id')->constrained('customers')->onDelete('cascade');
            $鏡->foreignId('organizer_id')->constrained('organizers')->onDelete('cascade');
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
