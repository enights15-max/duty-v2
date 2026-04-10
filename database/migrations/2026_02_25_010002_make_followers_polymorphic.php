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
            Schema::create('followers', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('following_id')->nullable();
                $table->string('following_type')->nullable();
                $table->timestamps();
                $table->index(['following_id', 'following_type']);
                $table->unique(['customer_id', 'following_id', 'following_type'], 'followers_follower_following_unique');
            });

            return;
        }

        Schema::table('followers', function (Blueprint $table) {
            if (Schema::hasColumn('followers', 'organizer_id') && Schema::getConnection()->getDriverName() !== 'sqlite') {
                // Drop unique index first as it depends on organizer_id
                $table->dropUnique('followers_customer_id_organizer_id_unique');

                // Drop organizer_id column and its index
                $table->dropColumn('organizer_id');
            }

            // Add polymorphic columns
            if (!Schema::hasColumn('followers', 'following_id')) {
                $table->unsignedBigInteger('following_id')->nullable()->after('customer_id');
            }

            if (!Schema::hasColumn('followers', 'following_type')) {
                $table->string('following_type')->nullable()->after('following_id');
            }

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
        if (!Schema::hasTable('followers')) {
            return;
        }

        Schema::table('followers', function (Blueprint $table) {
            if (Schema::getConnection()->getDriverName() !== 'sqlite') {
                $table->dropUnique('followers_follower_following_unique');

                $columns = array_values(array_filter([
                    Schema::hasColumn('followers', 'following_id') ? 'following_id' : null,
                    Schema::hasColumn('followers', 'following_type') ? 'following_type' : null,
                ]));

                if (!empty($columns)) {
                    $table->dropColumn($columns);
                }

                if (!Schema::hasColumn('followers', 'organizer_id')) {
                    $table->unsignedBigInteger('organizer_id')->after('customer_id');
                }

                $table->unique(['customer_id', 'organizer_id'], 'followers_customer_id_organizer_id_unique');
            }
        });
    }
};
