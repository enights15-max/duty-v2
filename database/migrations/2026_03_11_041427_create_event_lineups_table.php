<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        if (Schema::hasTable('event_lineups')) { return; }

        Schema::create('event_lineups', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('artist_id')->nullable();
            $table->string('source_type', 32);
            $table->string('display_name');
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_headliner')->default(false);
            $table->timestamps();

            $table->index(['event_id', 'sort_order']);
            $table->index(['event_id', 'is_headliner']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('event_lineups');
    }
};
