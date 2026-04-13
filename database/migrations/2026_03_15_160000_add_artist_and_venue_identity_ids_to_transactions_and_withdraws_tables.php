<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('transactions') && !Schema::hasColumn('transactions', 'venue_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->index('venue_identity_id');
            });
        }

        if (Schema::hasTable('transactions') && !Schema::hasColumn('transactions', 'artist_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('artist_identity_id')->nullable();
                $table->index('artist_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && !Schema::hasColumn('withdraws', 'venue_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->index('venue_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && !Schema::hasColumn('withdraws', 'artist_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->unsignedBigInteger('artist_identity_id')->nullable();
                $table->index('artist_identity_id');
            });
        }

        $this->backfillIdentityIds('venue');
        $this->backfillIdentityIds('artist');
    }

    public function down(): void
    {
        if (Schema::hasTable('transactions') && Schema::hasColumn('transactions', 'venue_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->dropIndex(['venue_identity_id']);
                $table->dropColumn('venue_identity_id');
            });
        }

        if (Schema::hasTable('transactions') && Schema::hasColumn('transactions', 'artist_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->dropIndex(['artist_identity_id']);
                $table->dropColumn('artist_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && Schema::hasColumn('withdraws', 'venue_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->dropIndex(['venue_identity_id']);
                $table->dropColumn('venue_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && Schema::hasColumn('withdraws', 'artist_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->dropIndex(['artist_identity_id']);
                $table->dropColumn('artist_identity_id');
            });
        }
    }

    private function backfillIdentityIds(string $type): void
    {
        if (!Schema::hasTable('identities')) {
            return;
        }

        $identityMap = DB::table('identities')
            ->where('type', $type)
            ->get(['id', 'meta'])
            ->mapWithKeys(function ($identity) {
                $meta = json_decode($identity->meta ?? '{}', true) ?: [];
                $legacyId = $meta['legacy_id'] ?? $meta['id'] ?? null;

                if ($legacyId === null || $legacyId === '') {
                    return [];
                }

                return [(int) $legacyId => (int) $identity->id];
            });

        $legacyColumn = $type . '_id';
        $identityColumn = $type . '_identity_id';

        foreach ($identityMap as $legacyId => $identityId) {
            if (Schema::hasTable('transactions')) {
                DB::table('transactions')
                    ->whereNull($identityColumn)
                    ->where($legacyColumn, $legacyId)
                    ->update([$identityColumn => $identityId]);
            }

            if (Schema::hasTable('withdraws')) {
                DB::table('withdraws')
                    ->whereNull($identityColumn)
                    ->where($legacyColumn, $legacyId)
                    ->update([$identityColumn => $identityId]);
            }
        }
    }
};
