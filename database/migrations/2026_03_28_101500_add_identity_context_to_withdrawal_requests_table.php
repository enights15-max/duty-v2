<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {

        if (!Schema::hasTable('withdrawal_requests')) {
            return;
        }
        Schema::table('withdrawal_requests', function (Blueprint $table): void {
            if (!Schema::hasColumn('withdrawal_requests', 'identity_id')) {
                $table->unsignedBigInteger('identity_id')->nullable();
            }

            if (!Schema::hasColumn('withdrawal_requests', 'actor_type')) {
                $table->string('actor_type', 32)->nullable();
            }

            if (!Schema::hasColumn('withdrawal_requests', 'display_name')) {
                $table->string('display_name')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('withdrawal_requests', function (Blueprint $table): void {
            if (Schema::hasColumn('withdrawal_requests', 'display_name')) {
                $table->dropColumn('display_name');
            }

            if (Schema::hasColumn('withdrawal_requests', 'actor_type')) {
                $table->dropColumn('actor_type');
            }

            if (Schema::hasColumn('withdrawal_requests', 'identity_id')) {
                $table->dropColumn('identity_id');
            }
        });
    }
};
