<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('basic_settings', function (Blueprint $table) {
            if (!Schema::hasColumn('basic_settings', 'app_default_country_iso2')) {
                $table->string('app_default_country_iso2', 2)->nullable()->after('timezone');
            }

            if (!Schema::hasColumn('basic_settings', 'app_supported_country_iso2s')) {
                $table->text('app_supported_country_iso2s')->nullable()->after('app_default_country_iso2');
            }
        });

        DB::table('basic_settings')
            ->whereNull('app_default_country_iso2')
            ->update([
                'app_default_country_iso2' => 'DO',
            ]);

        DB::table('basic_settings')
            ->whereNull('app_supported_country_iso2s')
            ->update([
                'app_supported_country_iso2s' => json_encode(['DO']),
            ]);
    }

    public function down(): void
    {
        Schema::table('basic_settings', function (Blueprint $table) {
            if (Schema::hasColumn('basic_settings', 'app_supported_country_iso2s')) {
                $table->dropColumn('app_supported_country_iso2s');
            }

            if (Schema::hasColumn('basic_settings', 'app_default_country_iso2')) {
                $table->dropColumn('app_default_country_iso2');
            }
        });
    }
};
