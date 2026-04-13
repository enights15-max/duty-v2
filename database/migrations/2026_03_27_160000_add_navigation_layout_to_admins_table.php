<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {

        if (!Schema::hasTable('admins')) {
            return;
        }
        Schema::table('admins', function (Blueprint $table) {
            if (!Schema::hasColumn('admins', 'navigation_layout')) {
                $table->string('navigation_layout', 20)
                    ->default('sidebar');
            }
        });
    }

    public function down(): void
    {
        Schema::table('admins', function (Blueprint $table) {
            if (Schema::hasColumn('admins', 'navigation_layout')) {
                $table->dropColumn('navigation_layout');
            }
        });
    }
};
