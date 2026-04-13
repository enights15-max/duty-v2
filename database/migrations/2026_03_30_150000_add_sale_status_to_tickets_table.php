<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {

        if (!Schema::hasTable('tickets')) {
            return;
        }
        Schema::table('tickets', function (Blueprint $table) {
            if (!Schema::hasColumn('tickets', 'sale_status')) {
                $table->string('sale_status', 24)->default('active');
            }

            if (!Schema::hasColumn('tickets', 'archived_at')) {
                $table->timestamp('archived_at')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            if (Schema::hasColumn('tickets', 'archived_at')) {
                $table->dropColumn('archived_at');
            }

            if (Schema::hasColumn('tickets', 'sale_status')) {
                $table->dropColumn('sale_status');
            }
        });
    }
};
