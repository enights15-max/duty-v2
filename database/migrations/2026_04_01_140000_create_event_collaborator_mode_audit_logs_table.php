<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_collaborator_mode_audit_logs')) {
            return;
        }

        Schema::create('event_collaborator_mode_audit_logs', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('split_id');
            $table->unsignedBigInteger('earning_id')->nullable();
            $table->unsignedBigInteger('identity_id');
            $table->unsignedBigInteger('actor_identity_id')->nullable();
            $table->string('actor_identity_type', 32)->nullable();
            $table->boolean('previous_requires_claim')->default(true);
            $table->boolean('previous_auto_release')->default(false);
            $table->boolean('new_requires_claim')->default(true);
            $table->boolean('new_auto_release')->default(false);
            $table->string('source', 48)->default('manual_toggle');
            $table->text('metadata')->nullable();
            $table->timestamps();

            $table->index(['event_id', 'split_id']);
            $table->index(['identity_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_collaborator_mode_audit_logs');
    }
};
