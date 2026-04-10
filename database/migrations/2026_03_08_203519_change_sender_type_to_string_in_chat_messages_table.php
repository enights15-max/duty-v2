<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasTable('chat_messages') || !Schema::hasColumn('chat_messages', 'sender_type')) {
            return;
        }

        // Use raw SQL because doctrine/dbal might not be installed, 
        // and we need to change an ENUM to a STRING.
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE chat_messages MODIFY sender_type VARCHAR(255)");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (!Schema::hasTable('chat_messages') || !Schema::hasColumn('chat_messages', 'sender_type')) {
            return;
        }

        // Note: Reverting to ENUM might fail if there are values other than 'customer' or 'organizer'
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE chat_messages MODIFY sender_type ENUM('customer', 'organizer')");
        }
    }
};
