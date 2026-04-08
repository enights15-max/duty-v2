<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('review_prompt_deliveries', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id');
            $table->string('status')->default('queued');
            $table->timestamp('dispatched_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();

            $table->unique(['customer_id', 'event_id'], 'review_prompt_deliveries_customer_event_unique');
            $table->index(['status', 'created_at'], 'review_prompt_deliveries_status_created_idx');
            $table->index(['customer_id', 'status'], 'review_prompt_deliveries_customer_status_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('review_prompt_deliveries');
    }
};
