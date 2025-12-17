<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('slot_seats', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('slot_id')->index();
            $table->string('name');
            $table->decimal('price', 8, 2)->default(0.00);
            $table->tinyInteger('is_deactive')->default(0);
            $table->tinyInteger('is_booked')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('slot_seats');
    }
};
