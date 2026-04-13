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

        if (!Schema::hasColumn('bookings', 'ticket_id')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->index('ticket_id');
            });
        }

        $this->backfillTicketIds();
    }

    public function down(): void
    {
        if (!Schema::hasTable('bookings') || !Schema::hasColumn('bookings', 'ticket_id')) {
            return;
        }

        Schema::table('bookings', function (Blueprint $table): void {
            $table->dropIndex(['ticket_id']);
            $table->dropColumn('ticket_id');
        });
    }

    private function backfillTicketIds(): void
    {
        if (!Schema::hasColumn('bookings', 'ticket_id')) {
            return;
        }

        $hasEventId = Schema::hasColumn('bookings', 'event_id');
        $hasVariation = Schema::hasColumn('bookings', 'variation');
        $hasTicketsByEvent = Schema::hasTable('tickets') && Schema::hasColumn('tickets', 'event_id');

        if (!$hasVariation && !$hasEventId) {
            return;
        }

        $bookingSelectColumns = ['id'];
        if ($hasEventId) {
            $bookingSelectColumns[] = 'event_id';
        }
        if ($hasVariation) {
            $bookingSelectColumns[] = 'variation';
        }

        DB::table('bookings')
            ->select($bookingSelectColumns)
            ->whereNull('ticket_id')
            ->orderBy('id')
            ->chunkById(250, function ($bookings) use ($hasEventId, $hasVariation, $hasTicketsByEvent): void {
                $eventIds = $hasEventId
                    ? collect($bookings)
                        ->pluck('event_id')
                        ->filter()
                        ->unique()
                        ->values()
                    : collect();

                $singleTicketMap = !$hasTicketsByEvent || $eventIds->isEmpty()
                    ? collect()
                    : DB::table('tickets')
                        ->select('event_id', DB::raw('MIN(id) as ticket_id'), DB::raw('COUNT(*) as ticket_count'))
                        ->whereIn('event_id', $eventIds)
                        ->groupBy('event_id')
                        ->get()
                        ->keyBy('event_id');

                foreach ($bookings as $booking) {
                    $ticketId = $hasVariation
                        ? $this->extractTicketIdFromVariation($booking->variation)
                        : null;

                    if ($ticketId === null && $hasEventId) {
                        $summary = $singleTicketMap->get($booking->event_id);
                        if ($summary && (int) $summary->ticket_count === 1) {
                            $ticketId = (int) $summary->ticket_id;
                        }
                    }

                    if ($ticketId === null) {
                        continue;
                    }

                    DB::table('bookings')
                        ->where('id', $booking->id)
                        ->update(['ticket_id' => $ticketId]);
                }
            });
    }

    private function extractTicketIdFromVariation(?string $variation): ?int
    {
        if (empty($variation)) {
            return null;
        }

        $decoded = json_decode($variation, true);

        if (!is_array($decoded) || empty($decoded)) {
            return null;
        }

        $first = $decoded[0] ?? null;
        if (!is_array($first)) {
            return null;
        }

        $ticketId = $first['ticket_id'] ?? null;

        return is_numeric($ticketId) ? (int) $ticketId : null;
    }
};
