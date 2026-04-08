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
        Schema::table('chats', function (Blueprint $table) {
            // Rename customer_id to initiator_id
            $table->renameColumn('customer_id', 'initiator_id');
            // Rename organizer_id to participant_id
            $table->renameColumn('organizer_id', 'participant_id');
        });

        Schema::table('chats', function (Blueprint $table) {
            // Add polymorphic type columns
            $table->string('initiator_type')->after('initiator_id')->nullable();
            $table->string('participant_type')->after('participant_id')->nullable();
        });

        // Migrate existing data
        DB::table('chats')->update([
            'initiator_type' => 'App\Models\Customer',
            'participant_type' => 'App\Models\Organizer'
        ]);

        // Make columns non-nullable after migration if desired, 
        // but let's keep them nullable for now to be safe during the transition in tinker if needed
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('chats', function (Blueprint $table) {
            $table->dropColumn(['initiator_type', 'participant_type']);
            $table->renameColumn('initiator_id', 'customer_id');
            $table->renameColumn('participant_id', 'organizer_id');
        });
    }
};
