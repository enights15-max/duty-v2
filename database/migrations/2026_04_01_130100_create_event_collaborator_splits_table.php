<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('event_collaborator_splits')) {
            return;
        }

        Schema::create('event_collaborator_splits', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('identity_id');
            $table->string('identity_type', 32);
            $table->unsignedBigInteger('legacy_id')->nullable();
            $table->string('role_type', 32)->default('artist');
            $table->string('split_type', 32)->default('percentage');
            $table->decimal('split_value', 8, 4)->default(0);
            $table->string('basis', 32)->default('net_event_revenue');
            $table->string('status', 32)->default('confirmed');
            $table->boolean('requires_claim')->default(true);
            $table->boolean('auto_release')->default(false);
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['event_id', 'identity_id', 'role_type'], 'event_collaborator_splits_unique');
            $table->index(['event_id', 'status']);
            $table->index(['identity_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_collaborator_splits');
    }
};
