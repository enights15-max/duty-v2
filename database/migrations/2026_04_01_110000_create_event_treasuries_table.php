<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_treasuries')) {
            return;
        }

        Schema::create('event_treasuries', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('event_id')->unique();
            $table->decimal('gross_collected', 15, 2)->default(0);
            $table->decimal('refunded_amount', 15, 2)->default(0);
            $table->decimal('platform_fee_total', 15, 2)->default(0);
            $table->decimal('reserved_for_owner', 15, 2)->default(0);
            $table->decimal('reserved_for_collaborators', 15, 2)->default(0);
            $table->decimal('released_to_wallet', 15, 2)->default(0);
            $table->decimal('available_for_settlement', 15, 2)->default(0);
            $table->timestamp('hold_until')->nullable();
            $table->string('settlement_status', 32)->default('collecting');
            $table->boolean('auto_payout_enabled')->default(false);
            $table->unsignedInteger('auto_payout_delay_hours')->nullable();
            $table->timestamps();

            $table->index('settlement_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_treasuries');
    }
};
