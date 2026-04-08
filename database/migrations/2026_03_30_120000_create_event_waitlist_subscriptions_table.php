<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('event_waitlist_subscriptions', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('event_id')->index();
            $table->unsignedBigInteger('customer_id')->index();
            $table->string('status', 20)->default('active')->index();
            $table->string('notified_reason', 40)->nullable();
            $table->timestamp('notified_at')->nullable();
            $table->timestamps();

            $table->unique(['event_id', 'customer_id'], 'event_waitlist_unique_subscription');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_waitlist_subscriptions');
    }
};
