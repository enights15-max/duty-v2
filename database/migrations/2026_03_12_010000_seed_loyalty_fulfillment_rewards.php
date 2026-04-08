<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('reward_catalog')) {
            return;
        }

        $now = now();

        $perk = DB::table('reward_catalog')->where('title', 'Perk VIP local')->first();
        if ($perk) {
            $meta = json_decode((string) ($perk->meta ?? '[]'), true);
            if (!is_array($meta)) {
                $meta = [];
            }

            $meta = array_merge([
                'instructions' => 'Presenta este codigo al organizer o al staff para reclamar el benefit.',
                'claim_expires_in_days' => 45,
                'delivery_channel' => 'in_person',
            ], $meta);

            DB::table('reward_catalog')
                ->where('id', $perk->id)
                ->update([
                    'meta' => json_encode($meta),
                    'updated_at' => $now,
                ]);
        }

        if (!DB::table('reward_catalog')->where('title', 'Cupon evento RD$150')->exists()) {
            DB::table('reward_catalog')->insert([
                'title' => 'Cupon evento RD$150',
                'description' => 'Descuento fijo aplicable en checkout para eventos elegibles de Duty.',
                'reward_type' => 'event_coupon',
                'points_cost' => 650,
                'bonus_amount' => null,
                'is_active' => true,
                'is_featured' => false,
                'meta' => json_encode([
                    'coupon_type' => 'fixed',
                    'coupon_value' => 150,
                    'coupon_expires_in_days' => 30,
                    'instructions' => 'Usa este codigo en checkout para descontar RD$150 de una compra elegible.',
                ]),
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('reward_catalog')) {
            return;
        }

        DB::table('reward_catalog')->where('title', 'Cupon evento RD$150')->delete();
    }
};
