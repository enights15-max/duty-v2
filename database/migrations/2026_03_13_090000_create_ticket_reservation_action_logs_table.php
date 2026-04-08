<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ticket_reservation_action_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('reservation_id');
            $table->string('actor_type', 32)->nullable();
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->string('action', 64);
            $table->json('meta')->nullable();
            $table->timestamps();

            $table->index(['reservation_id', 'created_at'], 'reservation_action_logs_reservation_created_idx');
            $table->index(['actor_type', 'actor_id'], 'reservation_action_logs_actor_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_reservation_action_logs');
    }
};
