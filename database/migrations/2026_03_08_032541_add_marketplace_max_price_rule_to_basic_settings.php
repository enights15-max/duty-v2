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

        if (!Schema::hasTable('basic_settings')) {
            return;
        }
        Schema::table('basic_settings', function (Blueprint $table) {
            $table->tinyInteger('marketplace_max_price_rule')->default(0)->comment('0: Off, 1: On');
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
            $table->dropColumn('marketplace_max_price_rule');
        });
    }
};
