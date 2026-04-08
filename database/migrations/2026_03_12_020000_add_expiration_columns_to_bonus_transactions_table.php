<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('bonus_transactions', function (Blueprint $table) {
            if (!Schema::hasColumn('bonus_transactions', 'consumed_amount')) {
                $table->decimal('consumed_amount', 10, 2)->default(0)->after('amount');
            }

            if (!Schema::hasColumn('bonus_transactions', 'expired_amount')) {
                $table->decimal('expired_amount', 10, 2)->default(0)->after('consumed_amount');
            }

            if (!Schema::hasColumn('bonus_transactions', 'expires_at')) {
                $table->timestamp('expires_at')->nullable()->after('status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bonus_transactions', function (Blueprint $table) {
            if (Schema::hasColumn('bonus_transactions', 'expires_at')) {
                $table->dropColumn('expires_at');
            }

            if (Schema::hasColumn('bonus_transactions', 'expired_amount')) {
                $table->dropColumn('expired_amount');
            }

            if (Schema::hasColumn('bonus_transactions', 'consumed_amount')) {
                $table->dropColumn('consumed_amount');
            }
        });
    }
};
