<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('event_financial_entries')) {
            return;
        }

        Schema::table('event_financial_entries', function (Blueprint $table): void {
            if (!Schema::hasColumn('event_financial_entries', 'target_identity_id')) {
                $table->unsignedBigInteger('target_identity_id')->nullable()->after('owner_identity_type');
                $table->index('target_identity_id');
            }

            if (!Schema::hasColumn('event_financial_entries', 'target_identity_type')) {
                $table->string('target_identity_type', 32)->nullable()->after('target_identity_id');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('event_financial_entries')) {
            return;
        }

        Schema::table('event_financial_entries', function (Blueprint $table): void {
            if (Schema::hasColumn('event_financial_entries', 'target_identity_id')) {
                $table->dropIndex(['target_identity_id']);
                $table->dropColumn('target_identity_id');
            }

            if (Schema::hasColumn('event_financial_entries', 'target_identity_type')) {
                $table->dropColumn('target_identity_type');
            }
        });
    }
};
