<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('event_collaborator_splits')) {
            return;
        }

        if (!Schema::hasColumn('event_collaborator_splits', 'release_mode')) {
            Schema::table('event_collaborator_splits', function (Blueprint $table): void {
                $table->string('release_mode', 32)
                    ->default('claim_required')
                    ->after('status');
            });
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('event_collaborator_splits')
            || !Schema::hasColumn('event_collaborator_splits', 'release_mode')) {
            return;
        }

        Schema::table('event_collaborator_splits', function (Blueprint $table): void {
            $table->dropColumn('release_mode');
        });
    }
};
