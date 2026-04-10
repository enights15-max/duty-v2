<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasTable('tickets')) {
          Schema::create('tickets', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->string('pricing_type')->nullable();
            $table->decimal('price', 10, 2)->nullable();
            $table->decimal('f_price', 10, 2)->nullable();
            $table->timestamps();
          });
        }

        Schema::table('tickets', function (Blueprint $table) {
          if (!Schema::hasColumn('tickets', 'normal_ticket_slot_enable')) {
            $table->tinyInteger('normal_ticket_slot_enable')->default(0);
          }
          if (!Schema::hasColumn('tickets', 'normal_ticket_slot_unique_id')) {
            $table->integer('normal_ticket_slot_unique_id')->nullable();
          }
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('tickets')) {
            return;
        }

        Schema::table('tickets', function (Blueprint $table) {
            foreach (['normal_ticket_slot_enable', 'normal_ticket_slot_unique_id'] as $column) {
                if (Schema::hasColumn('tickets', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
