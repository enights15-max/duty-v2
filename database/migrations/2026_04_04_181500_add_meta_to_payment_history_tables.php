<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('reservation_payments') && !Schema::hasColumn('reservation_payments', 'meta')) {
            Schema::table('reservation_payments', function (Blueprint $table) {
                $table->json('meta')->nullable();
            });
        }

        if (Schema::hasTable('booking_payment_allocations') && !Schema::hasColumn('booking_payment_allocations', 'meta')) {
            Schema::table('booking_payment_allocations', function (Blueprint $table) {
                $table->json('meta')->nullable();
            });
        }

        if (Schema::hasTable('wallet_transactions') && !Schema::hasColumn('wallet_transactions', 'meta')) {
            Schema::table('wallet_transactions', function (Blueprint $table) {
                $table->json('meta')->nullable();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('reservation_payments') && Schema::hasColumn('reservation_payments', 'meta')) {
            Schema::table('reservation_payments', function (Blueprint $table) {
                $table->dropColumn('meta');
            });
        }

        if (Schema::hasTable('booking_payment_allocations') && Schema::hasColumn('booking_payment_allocations', 'meta')) {
            Schema::table('booking_payment_allocations', function (Blueprint $table) {
                $table->dropColumn('meta');
            });
        }

        if (Schema::hasTable('wallet_transactions') && Schema::hasColumn('wallet_transactions', 'meta')) {
            Schema::table('wallet_transactions', function (Blueprint $table) {
                $table->dropColumn('meta');
            });
        }
    }
};
