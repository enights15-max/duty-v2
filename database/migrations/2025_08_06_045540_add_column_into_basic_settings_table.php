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
    Schema::table('basic_settings', function (Blueprint $table) {
      $table->tinyInteger('google_map_status')->default(0);
      $table->string('google_map_api_key')->nullable();
      $table->string('google_map_radius')->nullable();
      $table->tinyInteger('event_country_status')->default(0);
      $table->tinyInteger('event_state_status')->default(0);
    });
  }

  /**
   * Reverse the migrations.
   *
   * @return void
   */
  public function down()
  {
    Schema::table('basic_settings', function (Blueprint $table) {
      $table->dropColumn('google_map_status');
      $table->dropColumn('google_map_api_key');
      $table->dropColumn('google_map_radius');
      $table->dropColumn('event_country_status');
      $table->dropColumn('event_state_status');
    });
  }
};
