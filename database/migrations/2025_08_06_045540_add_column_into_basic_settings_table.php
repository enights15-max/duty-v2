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
    if (!Schema::hasTable('basic_settings')) {
      Schema::create('basic_settings', function (Blueprint $table) {
        $table->id();
        $table->timestamps();
      });
    }

    Schema::table('basic_settings', function (Blueprint $table) {
      if (!Schema::hasColumn('basic_settings', 'google_map_status')) {
        $table->tinyInteger('google_map_status')->default(0);
      }
      if (!Schema::hasColumn('basic_settings', 'google_map_api_key')) {
        $table->string('google_map_api_key')->nullable();
      }
      if (!Schema::hasColumn('basic_settings', 'google_map_radius')) {
        $table->string('google_map_radius')->nullable();
      }
      if (!Schema::hasColumn('basic_settings', 'event_country_status')) {
        $table->tinyInteger('event_country_status')->default(0);
      }
      if (!Schema::hasColumn('basic_settings', 'event_state_status')) {
        $table->tinyInteger('event_state_status')->default(0);
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
    if (!Schema::hasTable('basic_settings')) {
      return;
    }

    Schema::table('basic_settings', function (Blueprint $table) {
      foreach (['google_map_status', 'google_map_api_key', 'google_map_radius', 'event_country_status', 'event_state_status'] as $column) {
        if (Schema::hasColumn('basic_settings', $column)) {
          $table->dropColumn($column);
        }
      }
    });
  }
};
