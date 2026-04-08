<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artist_tips', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->unsignedBigInteger('artist_id');
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->decimal('wallet_amount', 10, 2)->default(0);
            $table->decimal('card_amount', 10, 2)->default(0);
            $table->char('currency', 3)->default('DOP');
            $table->string('status', 32)->default('processing');
            $table->uuid('customer_wallet_transaction_id')->nullable();
            $table->uuid('artist_wallet_transaction_id')->nullable();
            $table->string('stripe_payment_intent_id')->nullable();
            $table->json('meta')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['customer_id', 'artist_id']);
            $table->index(['artist_id', 'event_id']);
            $table->index('booking_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artist_tips');
    }
};
