<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::table('ticket_transfers', function (Blueprint $table) {
            $table->string('flow')->default('owner_offer')->after('status');
            // owner_offer, receiver_request
        });
    }

    public function down()
    {
        Schema::table('ticket_transfers', function (Blueprint $table) {
            $table->dropColumn('flow');
        });
    }
};
