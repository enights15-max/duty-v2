<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
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
                $table->timestamps();
            });
        }

        Schema::table('events', function (Blueprint $table) {
            if (!Schema::hasColumn('events', 'venue_id')) {
                $table->unsignedBigInteger('venue_id')->nullable()->after('organizer_id');
            }

            if (Schema::hasTable('venues') && Schema::getConnection()->getDriverName() !== 'sqlite') {
                $table->foreign('venue_id')->references('id')->on('venues')->onDelete('set null');
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
            if (Schema::getConnection()->getDriverName() !== 'sqlite') {
                $table->dropForeign(['venue_id']);
            }

            if (Schema::hasColumn('events', 'venue_id')) {
                $table->dropColumn('venue_id');
            }
        });
    }
};
