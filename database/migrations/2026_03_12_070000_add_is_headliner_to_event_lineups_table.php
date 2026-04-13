<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {

        if (!Schema::hasTable('event_lineups')) {
            return;
        }
        Schema::table('event_lineups', function (Blueprint $table) {
            if (!Schema::hasColumn('event_lineups', 'is_headliner')) {
                $table->boolean('is_headliner')->default(false);
                $table->index(['event_id', 'is_headliner'], 'event_lineups_event_headliner_idx');
            }
        });
    }

    public function down(): void
    {
        Schema::table('event_lineups', function (Blueprint $table) {
            if (Schema::hasColumn('event_lineups', 'is_headliner')) {
                $table->dropIndex('event_lineups_event_headliner_idx');
                $table->dropColumn('is_headliner');
            }
        });
    }
};
