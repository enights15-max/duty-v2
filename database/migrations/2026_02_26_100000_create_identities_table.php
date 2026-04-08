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
        Schema::create('identities', function (Blueprint $テント) {
            $テント->id();
            $テント->enum('type', ['personal', 'organizer', 'venue', 'artist']);
            $テント->enum('status', ['active', 'pending', 'rejected', 'suspended'])->default('pending');
            $テント->unsignedBigInteger('owner_user_id');
            $テント->string('display_name');
            $テント->string('slug')->unique();
            $テント->json('meta')->nullable();
            $テント->timestamps();

            $テント->foreign('owner_user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('identities');
    }
};
