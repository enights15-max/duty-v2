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
        if (Schema::hasTable('bookings')) {
            Schema::table('bookings', function (Blueprint $table) {
                if (!Schema::hasColumn('bookings', 'promoter_split_id')) {
                    $table->unsignedBigInteger('promoter_split_id')->nullable()->index();
                }
            });
        }

        if (Schema::hasTable('event_reward_instances')) {
            Schema::table('event_reward_instances', function (Blueprint $table) {
                if (!Schema::hasColumn('event_reward_instances', 'promoter_identity_id')) {
                    $table->unsignedBigInteger('promoter_identity_id')->nullable()->index();
                }
            });
        }

        if (Schema::hasTable('event_reward_definitions')) {
            Schema::table('event_reward_definitions', function (Blueprint $table) {
                if (!Schema::hasColumn('event_reward_definitions', 'exclusive_promoter_split_id')) {
                    $table->unsignedBigInteger('exclusive_promoter_split_id')->nullable()->index();
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (Schema::hasTable('bookings')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->dropColumn('promoter_split_id');
            });
        }

        if (Schema::hasTable('event_reward_instances')) {
            Schema::table('event_reward_instances', function (Blueprint $table) {
                $table->dropColumn('promoter_identity_id');
            });
        }

        if (Schema::hasTable('event_reward_definitions')) {
            Schema::table('event_reward_definitions', function (Blueprint $table) {
                $table->dropColumn('exclusive_promoter_split_id');
            });
        }
    }
};
