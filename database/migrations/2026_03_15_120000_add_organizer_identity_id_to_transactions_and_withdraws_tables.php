<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('transactions') && !Schema::hasColumn('transactions', 'organizer_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->index('organizer_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && !Schema::hasColumn('withdraws', 'organizer_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->index('organizer_identity_id');
            });
        }

        $this->backfillOrganizerIdentityIds();
    }

    public function down(): void
    {
        if (Schema::hasTable('transactions') && Schema::hasColumn('transactions', 'organizer_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->dropIndex(['organizer_identity_id']);
                $table->dropColumn('organizer_identity_id');
            });
        }

        if (Schema::hasTable('withdraws') && Schema::hasColumn('withdraws', 'organizer_identity_id')) {
            Schema::table('withdraws', function (Blueprint $table): void {
                $table->dropIndex(['organizer_identity_id']);
                $table->dropColumn('organizer_identity_id');
            });
        }
    }

    private function backfillOrganizerIdentityIds(): void
    {
        if (!Schema::hasTable('identities')) {
            return;
        }

        $identityMap = DB::table('identities')
            ->where('type', 'organizer')
            ->get(['id', 'meta'])
            ->mapWithKeys(function ($identity) {
                $meta = json_decode($identity->meta ?? '{}', true) ?: [];
                $legacyId = $meta['legacy_id'] ?? $meta['id'] ?? null;

                if ($legacyId === null || $legacyId === '') {
                    return [];
                }

                return [(int) $legacyId => (int) $identity->id];
            });

        foreach ($identityMap as $legacyOrganizerId => $identityId) {
            if (Schema::hasTable('transactions')) {
                DB::table('transactions')
                    ->whereNull('organizer_identity_id')
                    ->where('organizer_id', $legacyOrganizerId)
                    ->update(['organizer_identity_id' => $identityId]);
            }

            if (Schema::hasTable('withdraws')) {
                DB::table('withdraws')
                    ->whereNull('organizer_identity_id')
                    ->where('organizer_id', $legacyOrganizerId)
                    ->update(['organizer_identity_id' => $identityId]);
            }
        }
    }
};
