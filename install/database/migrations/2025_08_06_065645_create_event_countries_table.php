<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
  /**
   * Run the migrations.
   *
   * @return void
   */
  public function up()
  {
    Schema::create('event_countries', function (Blueprint $table) {
      $table->id();
      $table->string('language_id')->nullable();
      $table->string('name')->nullable();
      $table->string('slug')->nullable();
      $table->string('status')->nullable();
      $table->integer('serial_number')->nullable();
      $table->string('unquid')->nullable();
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
    Schema::dropIfExists('event_countries');
  }
};
