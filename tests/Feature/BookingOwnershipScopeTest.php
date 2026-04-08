<?php

namespace Tests\Feature;

use App\Models\Event\Booking;
use App\Models\Reservation\TicketReservation;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class BookingOwnershipScopeTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['marketplace', 'reservations', 'legacy_identity_sources'];
    protected array $baselineTruncate = [
        'bookings',
        'ticket_reservations',
        'events',
        'organizers',
        'identity_members',
        'identities',
        'users',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        if (!Schema::hasColumn('bookings', 'organizer_id')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->unsignedBigInteger('organizer_id')->nullable()->after('event_id');
            });
        }
    }

    public function test_booking_scope_prefers_event_owner_identity_and_only_falls_back_when_identity_is_missing(): void
    {
        DB::table('events')->insert([
            [
                'id' => 3001,
                'organizer_id' => 41,
                'owner_identity_id' => 501,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3002,
                'organizer_id' => 41,
                'owner_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3003,
                'organizer_id' => 41,
                'owner_identity_id' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            ['id' => 1, 'event_id' => 3001, 'organizer_id' => 41, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'event_id' => 3002, 'organizer_id' => 41, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'event_id' => 3003, 'organizer_id' => 41, 'created_at' => now(), 'updated_at' => now()],
        ]);

        $ids = Booking::query()
            ->ownedByOrganizerActor(501, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([1, 2], $ids);
    }

    public function test_reservation_scope_prefers_event_owner_identity_and_only_falls_back_when_identity_is_missing(): void
    {
        DB::table('events')->insert([
            [
                'id' => 4001,
                'organizer_id' => 41,
                'owner_identity_id' => 501,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4002,
                'organizer_id' => 41,
                'owner_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4003,
                'organizer_id' => 41,
                'owner_identity_id' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_reservations')->insert([
            [
                'id' => 11,
                'customer_id' => 1,
                'event_id' => 4001,
                'ticket_id' => 1,
                'reservation_code' => 'RSV-4001',
                'quantity' => 1,
                'reserved_unit_price' => 100,
                'total_amount' => 100,
                'deposit_required' => 25,
                'amount_paid' => 25,
                'remaining_balance' => 75,
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 12,
                'customer_id' => 1,
                'event_id' => 4002,
                'ticket_id' => 1,
                'reservation_code' => 'RSV-4002',
                'quantity' => 1,
                'reserved_unit_price' => 100,
                'total_amount' => 100,
                'deposit_required' => 25,
                'amount_paid' => 25,
                'remaining_balance' => 75,
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 13,
                'customer_id' => 1,
                'event_id' => 4003,
                'ticket_id' => 1,
                'reservation_code' => 'RSV-4003',
                'quantity' => 1,
                'reserved_unit_price' => 100,
                'total_amount' => 100,
                'deposit_required' => 25,
                'amount_paid' => 25,
                'remaining_balance' => 75,
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ids = TicketReservation::query()
            ->ownedByOrganizerActor(501, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([11, 12], $ids);
    }
}
