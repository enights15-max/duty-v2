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
        if (!Schema::hasTable('events')) {
          Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('organizer_id')->nullable();
            $table->string('thumbnail')->nullable();
            $table->tinyInteger('status')->default(1);
            $table->dateTime('start_date')->nullable();
            $table->dateTime('end_date_time')->nullable();
            $table->timestamps();
          });
        }

        Schema::table('events', function (Blueprint $table) {
          if (!Schema::hasColumn('events', 'ticket_slot_image')) {
            $table->string('ticket_slot_image')->nullable();
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
        if (!Schema::hasTable('events')) {
            return;
        }

        Schema::table('events', function (Blueprint $table) {
            if (Schema::hasColumn('events', 'ticket_slot_image')) {
                $table->dropColumn('ticket_slot_image');
            }
        });
    }
};
