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
        if (!Schema::hasTable('section_titles')) {
            Schema::create('section_titles', function (Blueprint $table) {
                $table->id();
                $table->timestamps();
            });
        }

        Schema::table('section_titles', function (Blueprint $table) {
            if (!Schema::hasColumn('section_titles', 'category_title')) {
                $table->string('category_title')->nullable();
            }

            if (!Schema::hasColumn('section_titles', 'upcoming_event_title')) {
                $table->string('upcoming_event_title')->nullable();
            }

            if (!Schema::hasColumn('section_titles', 'features_title')) {
                $table->string('features_title')->nullable();
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
        if (!Schema::hasTable('section_titles')) {
            return;
        }

        Schema::table('section_titles', function (Blueprint $table) {
            if (Schema::hasColumn('section_titles', 'category_title')) {
                $table->dropColumn('category_title');
            }

            if (Schema::hasColumn('section_titles', 'upcoming_event_title')) {
                $table->dropColumn('upcoming_event_title');
            }

            if (Schema::hasColumn('section_titles', 'features_title')) {
                $table->dropColumn('features_title');
            }
        });
    }
};
