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
        Schema::create('slots', function (Blueprint $table) {
          $table->id();
          $table->unsignedBigInteger('event_id')->index();
          $table->unsignedBigInteger('ticket_id')->index();
          $table->tinyInteger('slot_enable')->default(0);
          $table->unsignedBigInteger('slot_unique_id')->index();
          $table->tinyInteger('type')->comment("1= slot with manual select seat 2 = slot auto manual select seats")->index();
          $table->integer('number_of_seat');
          $table->double('pos_x');
          $table->double('pos_y');
          $table->double('width');
          $table->double('height');
          $table->decimal('price', 8, 2)->default(0.00);
          $table->string('name')->nullable();
          $table->float('rotate')->nullable();
          $table->integer('round')->default(0);
          $table->string('background_color')->nullable();
          $table->string('border_color')->nullable();
          $table->double('font_size', 8, 2)->default(14);
          $table->tinyInteger('is_deactive')->default(0);
          $table->tinyInteger('is_booked')->default(0);
          $table->string('pricing_type')->nullable();
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
        Schema::dropIfExists('slots');
    }
};
