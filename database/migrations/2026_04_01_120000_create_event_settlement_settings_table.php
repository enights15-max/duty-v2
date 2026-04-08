<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_settlement_settings')) {
            return;
        }

        Schema::create('event_settlement_settings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('event_id')->unique();
            $table->string('hold_mode', 48)->default('auto_after_grace_period');
            $table->unsignedInteger('grace_period_hours')->default(72);
            $table->unsignedInteger('refund_window_hours')->default(72);
            $table->boolean('auto_release_owner_share')->default(false);
            $table->boolean('auto_release_collaborator_shares')->default(false);
            $table->boolean('require_admin_approval')->default(false);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_settlement_settings');
    }
};
