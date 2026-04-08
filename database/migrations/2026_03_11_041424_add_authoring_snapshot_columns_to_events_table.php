<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('events', function (Blueprint $table) {
            $table->string('venue_source', 32)->nullable()->after('venue_identity_id');
            $table->string('venue_name_snapshot')->nullable()->after('venue_source');
            $table->string('venue_address_snapshot')->nullable()->after('venue_name_snapshot');
            $table->string('venue_city_snapshot')->nullable()->after('venue_address_snapshot');
            $table->string('venue_state_snapshot')->nullable()->after('venue_city_snapshot');
            $table->string('venue_country_snapshot')->nullable()->after('venue_state_snapshot');
            $table->string('venue_postal_code_snapshot')->nullable()->after('venue_country_snapshot');
            $table->string('venue_google_place_id')->nullable()->after('venue_postal_code_snapshot');

            $table->index('venue_source');
        });
    }

    public function down()
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropIndex(['venue_source']);
            $table->dropColumn([
                'venue_source',
                'venue_name_snapshot',
                'venue_address_snapshot',
                'venue_city_snapshot',
                'venue_state_snapshot',
                'venue_country_snapshot',
                'venue_postal_code_snapshot',
                'venue_google_place_id',
            ]);
        });
    }
};
