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
        Schema::table('followers', function (Blueprint $table) {
            // Drop unique index first as it depends on organizer_id
            $table->dropUnique('followers_customer_id_organizer_id_unique');

            // Drop organizer_id column and its index
            $table->dropColumn('organizer_id');

            // Add polymorphic columns
            $table->unsignedBigInteger('following_id')->after('customer_id');
            $table->string('following_type')->after('following_id');

            // Re-add indices
            $table->index(['following_id', 'following_type']);
            $table->unique(['customer_id', 'following_id', 'following_type'], 'followers_follower_following_unique');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('followers', function (Blueprint $table) {
            $table->dropUnique('followers_follower_following_unique');
            $table->dropColumn(['following_id', 'following_type']);
            $table->unsignedBigInteger('organizer_id')->after('customer_id');
            $table->unique(['customer_id', 'organizer_id'], 'followers_customer_id_organizer_id_unique');
        });
    }
};
