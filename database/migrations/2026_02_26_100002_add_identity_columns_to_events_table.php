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
        Schema::table('events', function (Blueprint $table) {
            $table->unsignedBigInteger('owner_identity_id')->nullable()->after('venue_id');
            $table->unsignedBigInteger('venue_identity_id')->nullable()->after('owner_identity_id');

            $table->foreign('owner_identity_id')->references('id')->on('identities')->onDelete('set null');
            $table->foreign('venue_identity_id')->references('id')->on('identities')->onDelete('set null');

            $table->index('owner_identity_id');
            $table->index('venue_identity_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropForeign(['owner_identity_id']);
            $table->dropForeign(['venue_identity_id']);
            $table->dropColumn(['owner_identity_id', 'venue_identity_id']);
        });
    }
};
