<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {

        if (!Schema::hasTable('events')) {
            return;
        }
        Schema::table('events', function (Blueprint $table) {
            if (!Schema::hasColumn('events', 'review_status')) {
                $table->string('review_status', 40)->nullable();
            }

            if (!Schema::hasColumn('events', 'review_notes')) {
                $table->text('review_notes')->nullable();
            }

            if (!Schema::hasColumn('events', 'reviewed_at')) {
                $table->timestamp('reviewed_at')->nullable();
            }

            if (!Schema::hasColumn('events', 'reviewed_by_admin_id')) {
                $table->unsignedBigInteger('reviewed_by_admin_id')->nullable();
            }
        });

        if (Schema::hasColumn('events', 'status') && Schema::hasColumn('events', 'review_status')) {
            DB::table('events')
                ->where('status', 1)
                ->update(['review_status' => 'approved']);
        }

        if (
            Schema::hasColumn('events', 'status')
            && Schema::hasColumn('events', 'review_status')
        ) {
            $hasOwnerIdentityId = Schema::hasColumn('events', 'owner_identity_id');
            $hasVenueIdentityId = Schema::hasColumn('events', 'venue_identity_id');

            if (!$hasOwnerIdentityId && !$hasVenueIdentityId) {
                return;
            }

            DB::table('events')
                ->where('status', 0)
                ->where(function ($query) use ($hasOwnerIdentityId, $hasVenueIdentityId) {
                    if ($hasOwnerIdentityId) {
                        $query->whereNotNull('owner_identity_id');
                    }

                    if ($hasVenueIdentityId) {
                        $method = $hasOwnerIdentityId ? 'orWhereNotNull' : 'whereNotNull';
                        $query->{$method}('venue_identity_id');
                    }
                })
                ->update(['review_status' => 'pending']);
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('events')) {
            return;
        }

        Schema::table('events', function (Blueprint $table) {
            $columns = [];
            foreach ([
                'review_status',
                'review_notes',
                'reviewed_at',
                'reviewed_by_admin_id',
            ] as $column) {
                if (Schema::hasColumn('events', $column)) {
                    $columns[] = $column;
                }
            }

            if ($columns !== []) {
                $table->dropColumn($columns);
            }
        });
    }
};
