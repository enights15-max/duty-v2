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

        if (!Schema::hasTable('chats')) {
            return;
        }
        Schema::table('chats', function (Blueprint $table) {
            if (Schema::hasColumn('chats', 'customer_id') && !Schema::hasColumn('chats', 'initiator_id')) {
                // Rename customer_id to initiator_id
                $table->renameColumn('customer_id', 'initiator_id');
            }

            if (Schema::hasColumn('chats', 'organizer_id') && !Schema::hasColumn('chats', 'participant_id')) {
                // Rename organizer_id to participant_id
                $table->renameColumn('organizer_id', 'participant_id');
            }

            if (!Schema::hasColumn('chats', 'initiator_type')) {
                $table->string('initiator_type')->nullable();
            }

            if (!Schema::hasColumn('chats', 'participant_type')) {
                $table->string('participant_type')->nullable();
            }
        });

        // Migrate existing data
        if (Schema::hasColumn('chats', 'initiator_type') && Schema::hasColumn('chats', 'participant_type')) {
            DB::table('chats')->update([
                'initiator_type' => 'App\Models\Customer',
                'participant_type' => 'App\Models\Organizer'
            ]);
        }

        // Make columns non-nullable after migration if desired, 
        // but let's keep them nullable for now to be safe during the transition in tinker if needed
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (!Schema::hasTable('chats')) {
            return;
        }

        Schema::table('chats', function (Blueprint $table) {
            $columns = [];
            foreach (['initiator_type', 'participant_type'] as $column) {
                if (Schema::hasColumn('chats', $column)) {
                    $columns[] = $column;
                }
            }

            if ($columns !== []) {
                $table->dropColumn($columns);
            }

            if (Schema::hasColumn('chats', 'initiator_id') && !Schema::hasColumn('chats', 'customer_id')) {
                $table->renameColumn('initiator_id', 'customer_id');
            }

            if (Schema::hasColumn('chats', 'participant_id') && !Schema::hasColumn('chats', 'organizer_id')) {
                $table->renameColumn('participant_id', 'organizer_id');
            }
        });
    }
};
