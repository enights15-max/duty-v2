<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('loyalty_rules') || !Schema::hasColumn('loyalty_rules', 'code')) {
            return;
        }

        $now = now();
        $columns = array_flip(Schema::getColumnListing('loyalty_rules'));

        $buildPayload = function (bool $includeCreatedAt = false) use ($columns, $now): array {
            $payload = [];

            foreach ([
                'label' => 'Asistencia confirmada',
                'description' => 'Puntos otorgados cuando la entrada es escaneada por primera vez.',
                'points' => 40,
                'is_active' => true,
                'updated_at' => $now,
            ] as $column => $value) {
                if (isset($columns[$column])) {
                    $payload[$column] = $value;
                }
            }

            if ($includeCreatedAt && isset($columns['created_at'])) {
                $payload['created_at'] = $now;
            }

            return $payload;
        };

        $existing = DB::table('loyalty_rules')->where('code', 'attendance_confirmed')->first();

        if ($existing) {
            DB::table('loyalty_rules')
                ->where('code', 'attendance_confirmed')
                ->update($buildPayload());

            return;
        }

        DB::table('loyalty_rules')->insert(array_merge([
            'code' => 'attendance_confirmed',
        ], $buildPayload(true)));
    }

    public function down(): void
    {
        if (
            !Schema::hasTable('loyalty_rules')
            || !Schema::hasColumn('loyalty_rules', 'code')
            || !Schema::hasColumn('loyalty_rules', 'is_active')
        ) {
            return;
        }

        $payload = ['is_active' => false];
        if (Schema::hasColumn('loyalty_rules', 'updated_at')) {
            $payload['updated_at'] = now();
        }

        DB::table('loyalty_rules')
            ->where('code', 'attendance_confirmed')
            ->update($payload);
    }
};
