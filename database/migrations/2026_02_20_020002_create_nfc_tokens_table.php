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
        Schema::create('nfc_tokens', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->unsignedBigInteger('user_id')->index();
            $table->string('uid_hash')->unique(); // HMAC of raw UID
            $table->string('pin_hash')->nullable(); // Optional PIN
            $table->enum('status', ['active', 'locked', 'lost', 'expired'])->default('active');
            $table->decimal('daily_limit', 10, 2)->default(5000.00);
            $table->decimal('daily_spent', 10, 2)->default(0.00);
            $table->timestamp('last_used_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('nfc_tokens');
    }
};
