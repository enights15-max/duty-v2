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
        if (Schema::hasTable('wallets')) {
            Schema::table('wallets', function (Blueprint $table) {
                if (!Schema::hasColumn('wallets', 'actor_type')) {
                    $table->string('actor_type', 32)->nullable();
                }

                if (!Schema::hasColumn('wallets', 'actor_id')) {
                    $table->unsignedBigInteger('actor_id')->nullable();
                }

                if (!Schema::hasColumn('wallets', 'actor_type') || !Schema::hasColumn('wallets', 'actor_id')) {
                    $table->index(['actor_type', 'actor_id'], 'wallets_actor_type_actor_id_idx');
                }
            });

            // Backfill from legacy user_id with "customer" default to preserve existing wallet/NFC flows.
            if (Schema::hasColumn('wallets', 'user_id')) {
                DB::table('wallets')
                    ->whereNull('actor_id')
                    ->update([
                        'actor_type' => 'customer',
                        'actor_id' => DB::raw('user_id'),
                    ]);
            }
        }

        if (Schema::hasTable('nfc_tokens')) {
            Schema::table('nfc_tokens', function (Blueprint $table) {
                if (!Schema::hasColumn('nfc_tokens', 'actor_type')) {
                    $table->string('actor_type', 32)->nullable();
                }

                if (!Schema::hasColumn('nfc_tokens', 'actor_id')) {
                    $table->unsignedBigInteger('actor_id')->nullable();
                }

                if (!Schema::hasColumn('nfc_tokens', 'actor_type') || !Schema::hasColumn('nfc_tokens', 'actor_id')) {
                    $table->index(['actor_type', 'actor_id'], 'nfc_tokens_actor_type_actor_id_idx');
                }
            });

            if (Schema::hasColumn('nfc_tokens', 'user_id')) {
                DB::table('nfc_tokens')
                    ->whereNull('actor_id')
                    ->update([
                        'actor_type' => 'customer',
                        'actor_id' => DB::raw('user_id'),
                    ]);
            }
        }

        if (Schema::hasTable('payment_methods')) {
            Schema::table('payment_methods', function (Blueprint $table) {
                if (!Schema::hasColumn('payment_methods', 'actor_type')) {
                    $table->string('actor_type', 32)->nullable();
                }

                if (!Schema::hasColumn('payment_methods', 'actor_id')) {
                    $table->unsignedBigInteger('actor_id')->nullable();
                }

                if (!Schema::hasColumn('payment_methods', 'actor_type') || !Schema::hasColumn('payment_methods', 'actor_id')) {
                    $table->index(['actor_type', 'actor_id'], 'payment_methods_actor_type_actor_id_idx');
                }
            });

            if (Schema::hasColumn('payment_methods', 'user_id')) {
                DB::table('payment_methods')
                    ->whereNull('actor_id')
                    ->update([
                        'actor_type' => 'customer',
                        'actor_id' => DB::raw('user_id'),
                    ]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('wallets')) {
            Schema::table('wallets', function (Blueprint $table) {
                if (Schema::hasColumn('wallets', 'actor_type') && Schema::hasColumn('wallets', 'actor_id')) {
                    $table->dropIndex('wallets_actor_type_actor_id_idx');
                }

                $columns = [];
                foreach (['actor_type', 'actor_id'] as $column) {
                    if (Schema::hasColumn('wallets', $column)) {
                        $columns[] = $column;
                    }
                }

                if ($columns !== []) {
                    $table->dropColumn($columns);
                }
            });
        }

        if (Schema::hasTable('nfc_tokens')) {
            Schema::table('nfc_tokens', function (Blueprint $table) {
                if (Schema::hasColumn('nfc_tokens', 'actor_type') && Schema::hasColumn('nfc_tokens', 'actor_id')) {
                    $table->dropIndex('nfc_tokens_actor_type_actor_id_idx');
                }

                $columns = [];
                foreach (['actor_type', 'actor_id'] as $column) {
                    if (Schema::hasColumn('nfc_tokens', $column)) {
                        $columns[] = $column;
                    }
                }

                if ($columns !== []) {
                    $table->dropColumn($columns);
                }
            });
        }

        if (Schema::hasTable('payment_methods')) {
            Schema::table('payment_methods', function (Blueprint $table) {
                if (Schema::hasColumn('payment_methods', 'actor_type') && Schema::hasColumn('payment_methods', 'actor_id')) {
                    $table->dropIndex('payment_methods_actor_type_actor_id_idx');
                }

                $columns = [];
                foreach (['actor_type', 'actor_id'] as $column) {
                    if (Schema::hasColumn('payment_methods', $column)) {
                        $columns[] = $column;
                    }
                }

                if ($columns !== []) {
                    $table->dropColumn($columns);
                }
            });
        }
    }
};
