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
    if (!Schema::hasTable('event_contents')) {
      Schema::create('event_contents', function (Blueprint $table) {
        $table->id();
        $table->unsignedBigInteger('event_id')->nullable();
        $table->timestamps();
      });
    }

    Schema::table('event_contents', function (Blueprint $table) {
      if (!Schema::hasColumn('event_contents', 'country_id')) {
        $table->bigInteger('country_id')->nullable();
      }
      if (!Schema::hasColumn('event_contents', 'city_id')) {
        $table->bigInteger('city_id')->nullable();
      }
      if (!Schema::hasColumn('event_contents', 'state_id')) {
        $table->bigInteger('state_id')->nullable();
      }
    });
  }

  /**
   * Reverse the migrations.
   *
   * @return void
   */
  public function down()
  {
    if (!Schema::hasTable('event_contents')) {
      return;
    }

    Schema::table('event_contents', function (Blueprint $table) {
      foreach (['country_id', 'city_id', 'state_id'] as $column) {
        if (Schema::hasColumn('event_contents', $column)) {
          $table->dropColumn($column);
        }
      }
    });
  }
};
