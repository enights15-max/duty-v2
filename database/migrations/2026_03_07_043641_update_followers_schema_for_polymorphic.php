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
        if (!Schema::hasTable('followers')) {
            return;
        }

        if (!Schema::hasColumn('followers', 'organizer_id')) {
            return;
        }

        if (Schema::getConnection()->getDriverName() === 'sqlite') {
            return;
        }

        try {
            Schema::table('followers', function (Blueprint $table) {
                $table->dropForeign(['organizer_id']);
            });
        } catch (\Exception $e) {
            // Foreign key might already be dropped if a previous migration run failed halfway.
        }

        Schema::table('followers', function (Blueprint $table) {
            // Adding a new unique constraint for the polymorphic relations FIRST
            // This satisfies the followers_customer_id_foreign constraint that relies on the first column.
            $table->unique(['customer_id', 'following_id', 'following_type'], 'followers_polymorphic_unique');

            // Now safe to drop old constraints and column
            $table->dropIndex('followers_organizer_id_foreign');
            $table->dropUnique('followers_customer_id_organizer_id_unique');
            $table->dropColumn('organizer_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('followers') || Schema::getConnection()->getDriverName() === 'sqlite') {
            return;
        }

        Schema::table('followers', function (Blueprint $table) {
            $table->dropUnique('followers_polymorphic_unique');
            $table->unsignedBigInteger('organizer_id');
        });

        Schema::table('followers', function (Blueprint $table) {
            $table->unique(['customer_id', 'organizer_id']);
            $table->foreign('organizer_id')->references('id')->on('organizers')->onDelete('cascade');
        });
    }
};
