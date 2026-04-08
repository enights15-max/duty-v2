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
        Schema::table('wallet_transactions', function (Blueprint $table) {
            $table->string('description')->nullable()->after('amount');
            $table->unsignedBigInteger('created_by')->nullable()->after('status');

            // Note: Changing enums in Laravel/MySQL can be tricky. 
            // We'll use a raw statement if needed, or just allow it in code if it's a string,
            // but the original migration used ->enum().
        });

        // Add 'admin_adjustment' to the enum for MySQL
        DB::statement("ALTER TABLE wallet_transactions MODIFY COLUMN type ENUM('credit', 'debit', 'hold_release', 'admin_adjustment') NOT NULL");
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('wallet_transactions', function (Blueprint $table) {
            $table->dropColumn(['description', 'created_by']);
        });

        DB::statement("ALTER TABLE wallet_transactions MODIFY COLUMN type ENUM('credit', 'debit', 'hold_release') NOT NULL");
    }
};
