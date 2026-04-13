<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

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
            return;
        }

        $columns = array_flip(Schema::getColumnListing('online_gateways'));
        if (!isset($columns['keyword']) || !isset($columns['name'])) {
            return;
        }

        foreach ([
            [
                'name' => 'Authorize.net',
                'keyword' => 'authorize.net',
                'information' => '',
                'status' => 0,
                'mobile_status' => 0,
                'mobile_information' => '',
            ],
            [
                'name' => 'Monnify',
                'keyword' => 'monnify',
                'information' => '',
                'status' => 0,
                'mobile_status' => 0,
                'mobile_information' => '',
            ],
        ] as $gateway) {
            $payload = [];
            foreach ($gateway as $column => $value) {
                if (isset($columns[$column])) {
                    $payload[$column] = $value;
                }
            }

            if (isset($columns['created_at'])) {
                $payload['created_at'] = now();
            }

            if (isset($columns['updated_at'])) {
                $payload['updated_at'] = now();
            }

            DB::table('online_gateways')->updateOrInsert(
                ['keyword' => $gateway['keyword']],
                $payload
            );
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (!Schema::hasTable('online_gateways') || !Schema::hasColumn('online_gateways', 'keyword')) {
            return;
        }

        DB::table('online_gateways')
            ->whereIn('keyword', ['authorize.net', 'monnify'])
            ->delete();
    }
};
