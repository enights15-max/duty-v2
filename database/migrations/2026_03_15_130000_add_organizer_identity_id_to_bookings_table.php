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
        if (!Schema::hasTable('identities')) {
            return;
        }

        $hasLegacyOrganizerId = Schema::hasColumn('bookings', 'organizer_id');
        $hasBookingEventId = Schema::hasColumn('bookings', 'event_id');
        $hasEventOwnerIdentityId = $hasBookingEventId
            && Schema::hasTable('events')
            && Schema::hasColumn('events', 'owner_identity_id');

        if (!$hasLegacyOrganizerId && !$hasEventOwnerIdentityId) {
            return;
        }

        $legacyIdentityMap = $hasLegacyOrganizerId
            ? DB::table('identities')
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
                }, [])
            : [];

        $bookingSelectColumns = ['id'];
        if ($hasBookingEventId) {
            $bookingSelectColumns[] = 'event_id';
        }
        if ($hasLegacyOrganizerId) {
            $bookingSelectColumns[] = 'organizer_id';
        }

        DB::table('bookings')
            ->select($bookingSelectColumns)
            ->whereNull('organizer_identity_id')
            ->orderBy('id')
            ->chunkById(250, function ($bookings) use ($legacyIdentityMap, $hasLegacyOrganizerId, $hasEventOwnerIdentityId, $hasBookingEventId): void {
                $eventIds = $hasBookingEventId
                    ? collect($bookings)
                        ->pluck('event_id')
                        ->filter()
                        ->unique()
                        ->values()
                    : collect();

                $eventIdentityMap = $eventIds->isEmpty()
                    ? collect()
                    : ($hasEventOwnerIdentityId
                        ? DB::table('events')
                            ->whereIn('id', $eventIds)
                            ->pluck('owner_identity_id', 'id')
                        : collect());

                foreach ($bookings as $booking) {
                    $identityId = $hasBookingEventId
                        ? $eventIdentityMap->get($booking->event_id)
                        : null;

                    if ($identityId === null && $hasLegacyOrganizerId && $booking->organizer_id !== null) {
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
