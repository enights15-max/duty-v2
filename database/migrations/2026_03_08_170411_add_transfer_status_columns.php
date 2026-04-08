<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        // Add status to ticket_transfers
        Schema::table('ticket_transfers', function (Blueprint $table) {
            $table->string('status')->default('pending')->after('notes');
            // pending, accepted, rejected, cancelled
        });

        // Add transfer_status to bookings
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('transfer_status')->nullable()->after('is_listed');
            // null = normal, 'transfer_pending' = awaiting acceptance
        });
    }

    public function down()
    {
        Schema::table('ticket_transfers', function (Blueprint $table) {
            $table->dropColumn('status');
        });

        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn('transfer_status');
        });
    }
};
