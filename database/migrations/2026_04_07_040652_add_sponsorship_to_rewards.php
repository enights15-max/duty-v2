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
        Schema::table('event_reward_definitions', function (Blueprint $table) {
            if (!Schema::hasColumn('event_reward_definitions', 'exclusive_promoter_split_id')) {
                $table->unsignedBigInteger('exclusive_promoter_split_id')->nullable()->index();
            }
            if (!Schema::hasColumn('event_reward_definitions', 'sponsor_identity_id')) {
                $table->unsignedBigInteger('sponsor_identity_id')->nullable();
                $table->index('sponsor_identity_id');
            }
        });

        Schema::table('event_reward_instances', function (Blueprint $table) {
            if (!Schema::hasColumn('event_reward_instances', 'promoter_identity_id')) {
                $table->unsignedBigInteger('promoter_identity_id')->nullable()->index();
            }
            if (!Schema::hasColumn('event_reward_instances', 'sponsor_identity_id')) {
                $table->unsignedBigInteger('sponsor_identity_id')->nullable();
                $table->index('sponsor_identity_id');
            }
        });
        
        Schema::table('bookings', function (Blueprint $table) {
            if (!Schema::hasColumn('bookings', 'promoter_split_id')) {
                $table->unsignedBigInteger('promoter_split_id')->nullable()->index();
            }
        });
    }

    public function down()
    {
        Schema::table('event_reward_instances', function (Blueprint $table) {
            $table->dropColumn(['promoter_identity_id', 'sponsor_identity_id']);
        });

        Schema::table('event_reward_definitions', function (Blueprint $table) {
            $table->dropColumn(['exclusive_promoter_split_id', 'sponsor_identity_id']);
        });
        
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn('promoter_split_id');
        });
    }
};
