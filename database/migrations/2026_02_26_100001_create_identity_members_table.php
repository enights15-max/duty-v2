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
        Schema::create('identity_members', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('identity_id');
            $table->unsignedBigInteger('user_id');
            $table->enum('role', ['owner', 'admin', 'manager', 'staff', 'scanner', 'pos_operator'])->default('staff');
            $table->json('permissions')->nullable();
            $table->enum('status', ['active', 'invited', 'removed'])->default('active');
            $table->timestamps();

            $table->unique(['identity_id', 'user_id']);
            $table->foreign('identity_id')->references('id')->on('identities')->onDelete('cascade');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
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
