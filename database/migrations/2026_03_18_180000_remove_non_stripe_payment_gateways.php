<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('online_gateways') && Schema::hasColumn('online_gateways', 'keyword')) {
            DB::table('online_gateways')
                ->where('keyword', '!=', 'stripe')
                ->delete();

            $payload = [];
            if (Schema::hasColumn('online_gateways', 'status')) {
                $payload['status'] = 1;
            }
            if (Schema::hasColumn('online_gateways', 'mobile_status')) {
                $payload['mobile_status'] = 1;
            }

            if ($payload !== []) {
                DB::table('online_gateways')
                    ->where('keyword', 'stripe')
                    ->update($payload);
            }
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
