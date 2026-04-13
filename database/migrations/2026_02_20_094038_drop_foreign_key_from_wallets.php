<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasTable('wallets') || Schema::getConnection()->getDriverName() === 'sqlite') {
            return;
        }

        // Only drop the foreign key if it actually exists
        $foreignKeys = Schema::getConnection()
            ->getDoctrineSchemaManager()
            ->listTableForeignKeys('wallets');

        $hasFk = collect($foreignKeys)->contains(fn ($fk) => in_array('user_id', $fk->getLocalColumns()));

        if (!$hasFk) {
            return;
        }

        Schema::table('wallets', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('wallets') || !Schema::hasTable('users') || Schema::getConnection()->getDriverName() === 'sqlite') {
            return;
        }

        Schema::table('wallets', function (Blueprint $table) {
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }
};
