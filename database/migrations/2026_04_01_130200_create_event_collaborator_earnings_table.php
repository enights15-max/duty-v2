<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_collaborator_earnings')) {
            return;
        }

        Schema::create('event_collaborator_earnings', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('split_id');
            $table->unsignedBigInteger('identity_id');
            $table->string('identity_type', 32);
            $table->string('role_type', 32)->default('artist');
            $table->decimal('amount_reserved', 15, 2)->default(0);
            $table->decimal('amount_claimed', 15, 2)->default(0);
            $table->string('status', 32)->default('pending_event_completion');
            $table->timestamp('released_at')->nullable();
            $table->timestamp('claimed_at')->nullable();
            $table->timestamp('last_calculated_at')->nullable();
            $table->text('metadata')->nullable();
            $table->timestamps();

            $table->unique(['split_id', 'identity_id'], 'event_collaborator_earnings_unique');
            $table->index(['identity_id', 'status']);
            $table->index(['event_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_collaborator_earnings');
    }
};
