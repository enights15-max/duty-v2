<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('chats', function (Blueprint $table) {
            $table->dropForeign('chats_customer_id_foreign');
            $table->dropForeign('chats_organizer_id_foreign');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('chats', function (Blueprint $table) {
            $table->foreign('initiator_id', 'chats_customer_id_foreign')->references('id')->on('customers')->onDelete('cascade');
            $table->foreign('participant_id', 'chats_organizer_id_foreign')->references('id')->on('organizers')->onDelete('cascade');
        });
    }
};
