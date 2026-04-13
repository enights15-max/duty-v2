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
        if (Schema::hasTable('identity_members')) { return; }

        Schema::create('identity_members', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('identity_id');
            $table->unsignedBigInteger('user_id');
            $table->enum('role', ['owner', 'admin', 'manager', 'staff', 'scanner', 'pos_operator'])->default('staff');
            $table->json('permissions')->nullable();
            $table->enum('status', ['active', 'invited', 'removed'])->default('active');
            $table->timestamps();

            $table->unique(['identity_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('identity_members');
    }
};
