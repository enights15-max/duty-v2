<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('platform_revenue_events')) {
            return;
        }

        Schema::create('platform_revenue_events', function (Blueprint $table): void {
            $table->id();
            $table->string('idempotency_key', 191)->unique();
            $table->unsignedBigInteger('policy_id')->nullable();
            $table->string('operation_key', 64);
            $table->string('reference_type', 64)->nullable();
            $table->string('reference_id', 191)->nullable();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('ticket_id')->nullable();
            $table->unsignedBigInteger('transfer_id')->nullable();
            $table->unsignedBigInteger('actor_customer_id')->nullable();
            $table->unsignedBigInteger('target_customer_id')->nullable();
            $table->unsignedBigInteger('owner_identity_id')->nullable();
            $table->string('owner_identity_type', 32)->nullable();
            $table->unsignedBigInteger('organizer_id')->nullable();
            $table->unsignedBigInteger('venue_id')->nullable();
            $table->unsignedBigInteger('artist_id')->nullable();
            $table->unsignedBigInteger('venue_identity_id')->nullable();
            $table->decimal('gross_amount', 15, 2)->default(0);
            $table->decimal('fee_amount', 15, 2)->default(0);
            $table->decimal('net_amount', 15, 2)->default(0);
            $table->decimal('total_charge_amount', 15, 2)->default(0);
            $table->string('charged_to', 32)->default('seller');
            $table->string('currency', 8)->default('DOP');
            $table->string('status', 32)->default('completed');
            $table->json('metadata')->nullable();
            $table->timestamp('occurred_at')->nullable();
            $table->timestamps();

            $table->index(['operation_key', 'occurred_at']);
            $table->index(['event_id', 'operation_key']);
            $table->index(['owner_identity_id', 'operation_key']);
            $table->index(['venue_identity_id', 'operation_key']);
            $table->index(['actor_customer_id', 'operation_key']);
            $table->index(['booking_id', 'operation_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('platform_revenue_events');
    }
};
