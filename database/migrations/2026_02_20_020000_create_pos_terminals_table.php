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
        Schema::create('pos_terminals', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->unsignedBigInteger('organizer_id')->index();
            $table->string('terminal_uuid')->unique();
            $table->string('name')->nullable();
            $table->enum('status', ['active', 'revoked'])->default('active');
            $table->timestamp('last_active_at')->nullable();
            $table->timestamps();

            // Note: organizer_id refers to the users table (organizers are users)
            // Not adding hard constraint to avoid issues with inconsistent DB states as seen previously
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pos_terminals');
    }
};
