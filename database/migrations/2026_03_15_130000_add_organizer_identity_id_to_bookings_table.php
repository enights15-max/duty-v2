<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('bookings')) {
            return;
        }

        if (!Schema::hasColumn('bookings', 'organizer_identity_id')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->index('organizer_identity_id');
            });
        }

        $this->backfillOrganizerIdentityId();
    }

    public function down(): void
    {
        if (!Schema::hasTable('bookings') || !Schema::hasColumn('bookings', 'organizer_identity_id')) {
            return;
        }

        Schema::table('bookings', function (Blueprint $table): void {
            $table->dropIndex(['organizer_identity_id']);
            $table->dropColumn('organizer_identity_id');
        });
    }

    private function backfillOrganizerIdentityId(): void
    {
        $legacyIdentityMap = DB::table('identities')
            ->where('type', 'organizer')
            ->get(['id', 'meta'])
            ->reduce(function (array $carry, object $identity): array {
                $meta = json_decode($identity->meta ?? '{}', true) ?: [];
                $legacyId = $meta['legacy_id'] ?? $meta['id'] ?? null;

                if ($legacyId === null || $legacyId === '') {
                    return $carry;
                }

                $carry[(string) $legacyId] = (int) $identity->id;

                return $carry;
            }, []);

        DB::table('bookings')
            ->select('id', 'event_id', 'organizer_id')
            ->whereNull('organizer_identity_id')
            ->orderBy('id')
            ->chunkById(250, function ($bookings) use ($legacyIdentityMap): void {
                $eventIds = collect($bookings)
                    ->pluck('event_id')
                    ->filter()
                    ->unique()
                    ->values();

                $eventIdentityMap = $eventIds->isEmpty()
                    ? collect()
                    : DB::table('events')
                        ->whereIn('id', $eventIds)
                        ->pluck('owner_identity_id', 'id');

                foreach ($bookings as $booking) {
                    $identityId = $eventIdentityMap->get($booking->event_id);

                    if ($identityId === null && $booking->organizer_id !== null) {
                        $identityId = $legacyIdentityMap[(string) $booking->organizer_id] ?? null;
                    }

                    if ($identityId === null) {
                        continue;
                    }

                    DB::table('bookings')
                        ->where('id', $booking->id)
                        ->update(['organizer_identity_id' => (int) $identityId]);
                }
            });
    }
};
