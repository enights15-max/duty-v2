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
        if (!Schema::hasTable('customers')) {
            Schema::create('customers', function (Blueprint $table) {
                $table->id();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->string('provider_id')->nullable();
                $table->timestamps();
            });
        }

        Schema::table('customers', function (Blueprint $table) {
            if (!Schema::hasColumn('customers', 'provider_id')) {
                $table->string('provider_id')->nullable();
            }

            if (!Schema::hasColumn('customers', 'firebase_uid')) {
                $table->string('firebase_uid')->nullable();
            }
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE customers MODIFY COLUMN email VARCHAR(255) NULL');
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('customers')) {
            return;
        }

        Schema::table('customers', function (Blueprint $table) {
            if (Schema::hasColumn('customers', 'firebase_uid')) {
                $table->dropColumn('firebase_uid');
            }
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE customers MODIFY COLUMN email VARCHAR(255) NOT NULL');
        }
    }
};
