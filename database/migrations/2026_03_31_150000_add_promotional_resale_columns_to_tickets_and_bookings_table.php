<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('tickets') && !Schema::hasColumn('tickets', 'allow_promotional_resale')) {
            Schema::table('tickets', function (Blueprint $table): void {
                $table->boolean('allow_promotional_resale')
                    ->default(true)
                    ->after('reservation_min_installment_amount');
            });
        }

        if (Schema::hasTable('bookings')) {
            Schema::table('bookings', function (Blueprint $table): void {
                if (!Schema::hasColumn('bookings', 'is_resellable')) {
                    $table->boolean('is_resellable')
                        ->default(true)
                        ->after('is_transferable');
                }

                if (!Schema::hasColumn('bookings', 'resale_restriction_reason')) {
                    $table->string('resale_restriction_reason', 64)
                        ->nullable()
                        ->after('is_resellable');
                }

                if (!Schema::hasColumn('bookings', 'acquisition_source')) {
                    $table->string('acquisition_source', 64)
                        ->nullable()
                        ->after('resale_restriction_reason');
                }

                if (!Schema::hasColumn('bookings', 'coupon_code')) {
                    $table->string('coupon_code', 191)
                        ->nullable()
                        ->after('acquisition_source');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('tickets') && Schema::hasColumn('tickets', 'allow_promotional_resale')) {
            Schema::table('tickets', function (Blueprint $table): void {
                $table->dropColumn('allow_promotional_resale');
            });
        }

        if (Schema::hasTable('bookings')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $columns = [];
                foreach (['is_resellable', 'resale_restriction_reason', 'acquisition_source', 'coupon_code'] as $column) {
                    if (Schema::hasColumn('bookings', $column)) {
                        $columns[] = $column;
                    }
                }

                if ($columns !== []) {
                    $table->dropColumn($columns);
                }
            });
        }
    }
};
