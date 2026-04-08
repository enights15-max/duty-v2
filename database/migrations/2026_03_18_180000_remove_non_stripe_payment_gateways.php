<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('online_gateways')) {
            DB::table('online_gateways')
                ->where('keyword', '!=', 'stripe')
                ->delete();

            DB::table('online_gateways')
                ->where('keyword', 'stripe')
                ->update([
                    'status' => 1,
                    'mobile_status' => 1,
                ]);
        }

        if (Schema::hasTable('offline_gateways')) {
            DB::table('offline_gateways')->delete();
        }
    }

    public function down(): void
    {
        // Irreversible cleanup: legacy gateways are intentionally removed.
    }
};
