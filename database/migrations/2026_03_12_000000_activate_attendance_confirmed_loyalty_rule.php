<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        $existing = DB::table('loyalty_rules')->where('code', 'attendance_confirmed')->first();

        if ($existing) {
            DB::table('loyalty_rules')
                ->where('code', 'attendance_confirmed')
                ->update([
                    'label' => 'Asistencia confirmada',
                    'description' => 'Puntos otorgados cuando la entrada es escaneada por primera vez.',
                    'points' => 40,
                    'is_active' => true,
                    'updated_at' => $now,
                ]);

            return;
        }

        DB::table('loyalty_rules')->insert([
            'code' => 'attendance_confirmed',
            'label' => 'Asistencia confirmada',
            'description' => 'Puntos otorgados cuando la entrada es escaneada por primera vez.',
            'points' => 40,
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function down(): void
    {
        DB::table('loyalty_rules')
            ->where('code', 'attendance_confirmed')
            ->update([
                'is_active' => false,
                'updated_at' => now(),
            ]);
    }
};
