<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('customers', function (Blueprint $table) {
            if (!Schema::hasColumn('customers', 'is_private')) {
                $table->boolean('is_private')->default(false)->after('gender');
            }

            if (!Schema::hasColumn('customers', 'show_interested_events')) {
                $table->boolean('show_interested_events')->default(true)->after('is_private');
            }

            if (!Schema::hasColumn('customers', 'show_attended_events')) {
                $table->boolean('show_attended_events')->default(true)->after('show_interested_events');
            }

            if (!Schema::hasColumn('customers', 'show_upcoming_attendance')) {
                $table->boolean('show_upcoming_attendance')->default(true)->after('show_attended_events');
            }
        });
    }

    public function down(): void
    {
        Schema::table('customers', function (Blueprint $table) {
            foreach ([
                'show_upcoming_attendance',
                'show_attended_events',
                'show_interested_events',
            ] as $column) {
                if (Schema::hasColumn('customers', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
