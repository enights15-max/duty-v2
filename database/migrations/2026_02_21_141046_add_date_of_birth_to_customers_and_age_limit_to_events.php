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
        Schema::table('customers', function (Blueprint $table) {
            $table->date('date_of_birth')->nullable()->after('photo');
        });

        Schema::table('events', function (Blueprint $table) {
            $table->integer('age_limit')->default(0)->after('status')->comment('0 means all ages');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('customers', function (Blueprint $table) {
            $table->dropColumn('date_of_birth');
        });

        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn('age_limit');
        });
    }
};
