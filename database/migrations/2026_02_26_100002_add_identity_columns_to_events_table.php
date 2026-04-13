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
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->timestamps();
            });
        }

        Schema::table('events', function (Blueprint $table) {
            if (!Schema::hasColumn('events', 'owner_identity_id')) {
                $table->unsignedBigInteger('owner_identity_id')->nullable();
            }

            if (!Schema::hasColumn('events', 'venue_identity_id')) {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
            }

            if (Schema::hasTable('identities') && Schema::getConnection()->getDriverName() !== 'sqlite') {
                $table->foreign('owner_identity_id')->references('id')->on('identities')->onDelete('set null');
                $table->foreign('venue_identity_id')->references('id')->on('identities')->onDelete('set null');
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
                $table->dropForeign(['owner_identity_id']);
                $table->dropForeign(['venue_identity_id']);
            }

            $columns = array_values(array_filter([
                Schema::hasColumn('events', 'owner_identity_id') ? 'owner_identity_id' : null,
                Schema::hasColumn('events', 'venue_identity_id') ? 'venue_identity_id' : null,
            ]));

            if (!empty($columns)) {
                $table->dropColumn($columns);
            }
        });
    }
};
