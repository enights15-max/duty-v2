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
    Schema::table('event_contents', function (Blueprint $table) {
      $table->bigInteger('country_id')->nullable()->after('event_id');
      $table->bigInteger('city_id')->nullable()->after('country_id');
      $table->bigInteger('state_id')->nullable()->after('city_id');
    });
  }

  /**
   * Reverse the migrations.
   *
   * @return void
   */
  public function down()
  {
    Schema::table('event_contents', function (Blueprint $table) {
      $table->dropColumn('country_id');
      $table->dropColumn('city_id');
      $table->dropColumn('state_id');
    });
  }
};
