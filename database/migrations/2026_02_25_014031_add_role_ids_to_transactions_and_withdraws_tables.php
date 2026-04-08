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
        Schema::table('transactions', function (Blueprint $table) {
            $table->unsignedBigInteger('venue_id')->nullable()->after('organizer_id');
            $table->unsignedBigInteger('artist_id')->nullable()->after('venue_id');
        });

        Schema::table('withdraws', function (Blueprint $table) {
            $table->unsignedBigInteger('venue_id')->nullable()->after('organizer_id');
            $table->unsignedBigInteger('artist_id')->nullable()->after('venue_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn(['venue_id', 'artist_id']);
        });

        Schema::table('withdraws', function (Blueprint $table) {
            $table->dropColumn(['venue_id', 'artist_id']);
        });
    }
};
