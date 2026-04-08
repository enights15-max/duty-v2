<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('event_reward_definitions')) {
            Schema::create('event_reward_definitions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title');
                $table->text('description')->nullable();
                $table->string('reward_type', 32)->default('perk');
                $table->string('trigger_mode', 32)->default('on_ticket_scan');
                $table->string('fulfillment_mode', 32)->default('qr_claim');
                $table->unsignedInteger('inventory_limit')->nullable();
                $table->unsignedInteger('per_ticket_quantity')->default(1);
                $table->longText('eligible_ticket_ids')->nullable();
                $table->longText('station_scope')->nullable();
                $table->text('meta')->nullable();
                $table->string('status', 32)->default('active');
                $table->timestamps();

                $table->index(['event_id', 'status']);
            });
        }

        if (!Schema::hasTable('event_reward_instances')) {
            Schema::create('event_reward_instances', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('reward_definition_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('ticket_unit_key', 120)->nullable();
                $table->unsignedInteger('instance_index')->default(1);
                $table->string('claim_code')->unique();
                $table->text('claim_qr_payload')->nullable();
                $table->string('status', 32)->default('reserved');
                $table->timestamp('activated_at')->nullable();
                $table->timestamp('claimed_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->unsignedBigInteger('claimed_by_identity_id')->nullable();
                $table->unsignedBigInteger('claimed_station_id')->nullable();
                $table->text('meta')->nullable();
                $table->timestamps();

                $table->unique(
                    ['reward_definition_id', 'booking_id', 'ticket_unit_key', 'instance_index'],
                    'event_reward_instances_unique_booking_slot'
                );
                $table->index(['event_id', 'status']);
                $table->index(['booking_id', 'status']);
            });
        }

        if (!Schema::hasTable('event_reward_claim_logs')) {
            Schema::create('event_reward_claim_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reward_instance_id');
                $table->string('action', 32);
                $table->unsignedBigInteger('actor_identity_id')->nullable();
                $table->unsignedBigInteger('station_id')->nullable();
                $table->string('reason_code', 64)->nullable();
                $table->text('meta')->nullable();
                $table->timestamp('occurred_at')->nullable();
                $table->timestamps();

                $table->index(['reward_instance_id', 'action']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('event_reward_claim_logs');
        Schema::dropIfExists('event_reward_instances');
        Schema::dropIfExists('event_reward_definitions');
    }
};
