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

        if (!Schema::hasTable('basic_settings')) {
            return;
        }
    Schema::table('basic_settings', function (Blueprint $table) {

      if (!Schema::hasColumn('basic_settings', 'mobile_app_logo')) {
      $table->string('mobile_app_logo')->nullable();
      }
      if (!Schema::hasColumn('basic_settings', 'mobile_favicon')) {
      $table->string('mobile_favicon')->nullable();
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
    Schema::table('basic_settings', function (Blueprint $table) {
      //
    });
  }
};
