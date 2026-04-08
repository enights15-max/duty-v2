<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('ticket_journey_events')) {
            return;
        }

        Schema::create('ticket_journey_events', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('booking_id')->nullable()->index();
            $table->unsignedBigInteger('event_id')->nullable()->index();
            $table->unsignedBigInteger('ticket_id')->nullable()->index();
            $table->unsignedBigInteger('actor_customer_id')->nullable()->index();
            $table->unsignedBigInteger('target_customer_id')->nullable()->index();
            $table->unsignedBigInteger('transfer_id')->nullable()->index();
            $table->string('type', 64)->index();
            $table->decimal('price', 15, 2)->nullable();
            $table->json('metadata')->nullable();
            $table->timestamp('occurred_at')->nullable()->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_journey_events');
    }
};
