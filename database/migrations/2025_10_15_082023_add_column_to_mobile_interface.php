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
        if (!Schema::hasTable('online_gateways')) {
            Schema::create('online_gateways', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('keyword')->nullable();
                $table->longText('information')->nullable();
                $table->tinyInteger('status')->default(0);
                $table->timestamps();
            });
        }

        Schema::table('online_gateways', function (Blueprint $table) {
            if (!Schema::hasColumn('online_gateways', 'mobile_status')) {
                $table->tinyInteger('mobile_status')->default(0);
            }
            if (!Schema::hasColumn('online_gateways', 'mobile_information')) {
                $table->longText('mobile_information')->nullable();
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
        if (!Schema::hasTable('online_gateways')) {
            return;
        }

        Schema::table('online_gateways', function (Blueprint $table) {
            foreach (['mobile_status', 'mobile_information'] as $column) {
                if (Schema::hasColumn('online_gateways', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
