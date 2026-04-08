<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ticket_price_schedules', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('ticket_id');
            $table->string('label')->nullable();
            $table->dateTime('effective_from');
            $table->decimal('price', 15, 2);
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['ticket_id', 'effective_from'], 'ticket_price_schedules_ticket_effective_idx');
            $table->index(['ticket_id', 'is_active'], 'ticket_price_schedules_ticket_active_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_price_schedules');
    }
};
