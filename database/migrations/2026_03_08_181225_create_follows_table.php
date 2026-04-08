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
        Schema::create('follows', function (Blueprint $table) {
            $table->id();
            $table->morphs('follower');
            $table->morphs('followable');
            $table->string('status')->default('accepted'); // 'pending' or 'accepted'
            $table->timestamps();

            // Prevent duplicate follows
            $table->unique(['follower_id', 'follower_type', 'followable_id', 'followable_type'], 'unique_follow');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('follows');
    }
};
