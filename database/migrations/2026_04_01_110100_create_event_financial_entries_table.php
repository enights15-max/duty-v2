<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_financial_entries')) {
            return;
        }

        Schema::create('event_financial_entries', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('treasury_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->string('idempotency_key')->unique();
            $table->string('entry_type', 64);
            $table->string('reference_type', 64)->nullable();
            $table->string('reference_id')->nullable();
            $table->unsignedBigInteger('actor_customer_id')->nullable();
            $table->unsignedBigInteger('owner_identity_id')->nullable();
            $table->string('owner_identity_type', 32)->nullable();
            $table->unsignedBigInteger('organizer_id')->nullable();
            $table->unsignedBigInteger('venue_id')->nullable();
            $table->decimal('gross_amount', 15, 2)->default(0);
            $table->decimal('fee_amount', 15, 2)->default(0);
            $table->decimal('net_amount', 15, 2)->default(0);
            $table->string('currency', 8)->default('DOP');
            $table->string('status', 32)->default('reserved');
            $table->text('metadata')->nullable();
            $table->timestamp('occurred_at')->nullable();
            $table->timestamps();

            $table->index(['event_id', 'entry_type']);
            $table->index(['booking_id', 'entry_type']);
            $table->index('owner_identity_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_financial_entries');
    }
};
