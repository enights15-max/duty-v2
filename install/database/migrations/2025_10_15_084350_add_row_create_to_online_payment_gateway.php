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
          'name' => 'Authorize.net',
          'keyword' => 'authorize.net',
          'information' => "",
          'status' => 0,
          'mobile_status' => 0,
          'mobile_information' => ""
        ]);

      DB::table('online_gateways')->insert([
        'name' => 'Monnify',
        'keyword' => 'monnify',
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
