<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::table('online_gateways')->insert([
          'name' => 'NowPayments',
          'keyword' => 'now_payments',
          'information' => "",
          'status' => 0,
          'mobile_status' => 0,
          'mobile_information' => ""
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('online_gateways', function (Blueprint $table) {
            //
        });
    }
};
