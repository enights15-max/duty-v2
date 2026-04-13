<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('event_treasuries')) {
            return;
        }

        Schema::table('event_treasuries', function (Blueprint $table): void {
            if (!Schema::hasColumn('event_treasuries', 'admin_release_approved_at')) {
                $table->timestamp('admin_release_approved_at')->nullable();
            }

            if (!Schema::hasColumn('event_treasuries', 'admin_release_approved_by_admin_id')) {
                $table->unsignedBigInteger('admin_release_approved_by_admin_id')->nullable();
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('event_treasuries')) {
            return;
        }

        Schema::table('event_treasuries', function (Blueprint $table): void {
            if (Schema::hasColumn('event_treasuries', 'admin_release_approved_by_admin_id')) {
                $table->dropColumn('admin_release_approved_by_admin_id');
            }

            if (Schema::hasColumn('event_treasuries', 'admin_release_approved_at')) {
                $table->dropColumn('admin_release_approved_at');
            }
        });
    }
};
