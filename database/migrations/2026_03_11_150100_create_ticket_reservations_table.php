<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ticket_reservations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('ticket_id');
            $table->string('reservation_code')->unique();
            $table->string('booking_order_number')->nullable();
            $table->unsignedInteger('quantity')->default(1);
            $table->decimal('reserved_unit_price', 15, 2);
            $table->decimal('total_amount', 15, 2);
            $table->decimal('deposit_required', 15, 2)->default(0);
            $table->decimal('amount_paid', 15, 2)->default(0);
            $table->decimal('remaining_balance', 15, 2)->default(0);
            $table->enum('deposit_type', ['fixed', 'percentage'])->nullable();
            $table->decimal('deposit_value', 15, 2)->nullable();
            $table->decimal('minimum_installment_amount', 15, 2)->nullable();
            $table->dateTime('final_due_date')->nullable();
            $table->dateTime('expires_at')->nullable();
            $table->string('event_date')->nullable();
            $table->enum('status', ['active', 'expired', 'completed', 'cancelled', 'defaulted'])->default('active');
            $table->string('payment_method', 32)->nullable();
            $table->string('fname')->nullable();
            $table->string('lname')->nullable();
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->string('country')->nullable();
            $table->string('state')->nullable();
            $table->string('city')->nullable();
            $table->string('zip_code')->nullable();
            $table->string('address')->nullable();
            $table->timestamps();

            $table->index(['customer_id', 'status'], 'ticket_reservations_customer_status_idx');
            $table->index(['ticket_id', 'status'], 'ticket_reservations_ticket_status_idx');
            $table->index(['expires_at', 'status'], 'ticket_reservations_expires_status_idx');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ticket_reservations');
    }
};
