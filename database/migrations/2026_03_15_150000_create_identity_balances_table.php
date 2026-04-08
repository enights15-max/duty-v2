<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('identity_balances')) {
            Schema::create('identity_balances', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('identity_id')->unique();
                $table->string('legacy_type')->nullable();
                $table->unsignedBigInteger('legacy_id')->nullable()->index();
                $table->decimal('balance', 15, 2)->default(0);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identities')) {
            return;
        }

        $identities = DB::table('identities')
            ->select('id', 'type', 'meta')
            ->whereIn('type', ['organizer', 'artist', 'venue'])
            ->get();

        foreach ($identities as $identity) {
            $meta = json_decode($identity->meta ?? '[]', true) ?: [];
            $legacyId = $meta['legacy_id'] ?? $meta['id'] ?? null;
            $balance = 0;

            if ($legacyId && $identity->type === 'organizer' && Schema::hasTable('organizers')) {
                $balance = (float) (DB::table('organizers')->where('id', $legacyId)->value('amount') ?? 0);
            } elseif ($legacyId && $identity->type === 'artist' && Schema::hasTable('artists')) {
                $balance = (float) (DB::table('artists')->where('id', $legacyId)->value('amount') ?? 0);
            } elseif ($legacyId && $identity->type === 'venue' && Schema::hasTable('venues')) {
                $balance = (float) (DB::table('venues')->where('id', $legacyId)->value('amount') ?? 0);
            }

            DB::table('identity_balances')->updateOrInsert(
                ['identity_id' => $identity->id],
                [
                    'legacy_type' => $identity->type,
                    'legacy_id' => $legacyId,
                    'balance' => round($balance, 2),
                    'last_synced_at' => now(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('identity_balances');
    }
};
