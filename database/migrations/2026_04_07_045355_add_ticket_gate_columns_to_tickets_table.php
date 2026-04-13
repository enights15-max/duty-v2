<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            // "Don't activate me until THIS ticket sells out / date arrives"
            $table->unsignedBigInteger('gate_ticket_id')->nullable();
            $table->enum('gate_trigger', ['sold_out', 'date', 'manual'])->default('sold_out');
            $table->dateTime('gate_trigger_date')->nullable();

            $table->index('gate_ticket_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->dropIndex(['gate_ticket_id']);
            $table->dropColumn(['gate_ticket_id', 'gate_trigger', 'gate_trigger_date']);
        });
    }
};
