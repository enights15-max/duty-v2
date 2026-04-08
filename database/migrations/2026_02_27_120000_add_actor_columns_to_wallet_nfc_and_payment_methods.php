<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            $table->string('actor_type', 32)->nullable()->after('user_id');
            $table->unsignedBigInteger('actor_id')->nullable()->after('actor_type');
            $table->index(['actor_type', 'actor_id'], 'wallets_actor_type_actor_id_idx');
        });

        Schema::table('nfc_tokens', function (Blueprint $table) {
            $table->string('actor_type', 32)->nullable()->after('user_id');
            $table->unsignedBigInteger('actor_id')->nullable()->after('actor_type');
            $table->index(['actor_type', 'actor_id'], 'nfc_tokens_actor_type_actor_id_idx');
        });

        Schema::table('payment_methods', function (Blueprint $table) {
            $table->string('actor_type', 32)->nullable()->after('user_id');
            $table->unsignedBigInteger('actor_id')->nullable()->after('actor_type');
            $table->index(['actor_type', 'actor_id'], 'payment_methods_actor_type_actor_id_idx');
        });

        // Backfill from legacy user_id with "customer" default to preserve existing wallet/NFC flows.
        DB::table('wallets')
            ->whereNull('actor_id')
            ->update([
                'actor_type' => 'customer',
                'actor_id' => DB::raw('user_id'),
            ]);

        DB::table('nfc_tokens')
            ->whereNull('actor_id')
            ->update([
                'actor_type' => 'customer',
                'actor_id' => DB::raw('user_id'),
            ]);

        DB::table('payment_methods')
            ->whereNull('actor_id')
            ->update([
                'actor_type' => 'customer',
                'actor_id' => DB::raw('user_id'),
            ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            $table->dropIndex('wallets_actor_type_actor_id_idx');
            $table->dropColumn(['actor_type', 'actor_id']);
        });

        Schema::table('nfc_tokens', function (Blueprint $table) {
            $table->dropIndex('nfc_tokens_actor_type_actor_id_idx');
            $table->dropColumn(['actor_type', 'actor_id']);
        });

        Schema::table('payment_methods', function (Blueprint $table) {
            $table->dropIndex('payment_methods_actor_type_actor_id_idx');
            $table->dropColumn(['actor_type', 'actor_id']);
        });
    }
};
