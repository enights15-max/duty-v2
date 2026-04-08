<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('fee_policy_audit_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('fee_policy_id');
            $table->unsignedBigInteger('admin_id')->nullable();
            $table->string('action', 80);
            $table->json('before')->nullable();
            $table->json('after')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();

            $table->index('fee_policy_id');
            $table->index('admin_id');
            $table->index('action');
            $table->foreign('fee_policy_id')->references('id')->on('fee_policies')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fee_policy_audit_logs');
    }
};
