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

        if (!Schema::hasTable('tickets')) {
            return;
        }
        Schema::table('tickets', function (Blueprint $table) {
            $table->boolean('reservation_enabled')->default(false);
            $table->enum('reservation_deposit_type', ['fixed', 'percentage'])->nullable();
            $table->decimal('reservation_deposit_value', 15, 2)->nullable();
            $table->dateTime('reservation_final_due_date')->nullable();
            $table->decimal('reservation_min_installment_amount', 15, 2)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->dropColumn([
                'reservation_enabled',
                'reservation_deposit_type',
                'reservation_deposit_value',
                'reservation_final_due_date',
                'reservation_min_installment_amount',
            ]);
        });
    }
};
