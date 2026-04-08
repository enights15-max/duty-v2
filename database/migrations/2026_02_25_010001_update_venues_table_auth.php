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
        Schema::table('venues', function (Blueprint $table) {
            $table->string('username')->unique()->after('slug')->nullable();
            $table->string('email')->unique()->after('username')->nullable();
            $table->string('password')->after('email')->nullable();
            $table->timestamp('email_verified_at')->nullable()->after('password');
            $table->decimal('amount', 20, 2)->default(0.00)->after('status');
            $table->rememberToken();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('venues', function (Blueprint $table) {
            $table->dropColumn(['username', 'email', 'password', 'email_verified_at', 'amount', 'remember_token']);
        });
    }
};
