<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasTable('wallet_transactions')) {
            return;
        }

        Schema::table('wallet_transactions', function (Blueprint $table) {
            if (!Schema::hasColumn('wallet_transactions', 'description')) {
                $table->string('description')->nullable()->after('amount');
            }

            if (!Schema::hasColumn('wallet_transactions', 'created_by')) {
                $table->unsignedBigInteger('created_by')->nullable()->after('status');
            }

            // Note: Changing enums in Laravel/MySQL can be tricky. 
            // We'll use a raw statement if needed, or just allow it in code if it's a string,
            // but the original migration used ->enum().
        });

        // Add 'admin_adjustment' to the enum for MySQL
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE wallet_transactions MODIFY COLUMN type ENUM('credit', 'debit', 'hold_release', 'admin_adjustment') NOT NULL");
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('wallet_transactions')) {
            return;
        }

        Schema::table('wallet_transactions', function (Blueprint $table) {
            $columns = array_values(array_filter([
                Schema::hasColumn('wallet_transactions', 'description') ? 'description' : null,
                Schema::hasColumn('wallet_transactions', 'created_by') ? 'created_by' : null,
            ]));

            if (!empty($columns)) {
                $table->dropColumn($columns);
            }
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE wallet_transactions MODIFY COLUMN type ENUM('credit', 'debit', 'hold_release') NOT NULL");
        }
    }
};
