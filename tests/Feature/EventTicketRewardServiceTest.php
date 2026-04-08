<?php

namespace Tests\Feature;

use App\Models\Event\Booking;
use App\Services\EventTicketRewardService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class EventTicketRewardServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace', 'event_rewards'];
    protected array $baselineTruncate = [
        'event_reward_claim_logs',
        'event_reward_instances',
        'event_reward_definitions',
        'bookings',
        'events',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureRewardBookingColumns();
    }

    public function test_issue_for_bookings_creates_reserved_and_immediate_activated_instances(): void
    {
        DB::table('events')->insert([
            'id' => 61,
            'title' => 'Immediate reward event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $bookingId = (int) DB::table('bookings')->insertGetId([
            'event_id' => 61,
            'ticket_id' => 910,
            'booking_id' => 'bk-reward-61',
            'order_number' => 'ord-reward-61',
            'paymentStatus' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_definitions')->insert([
            [
                'id' => 601,
                'event_id' => 61,
                'title' => 'Welcome drink',
                'reward_type' => 'drink',
                'trigger_mode' => 'on_ticket_scan',
                'fulfillment_mode' => 'qr_claim',
                'eligible_ticket_ids' => json_encode([910]),
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 602,
                'event_id' => 61,
                'title' => 'Instant merch pickup',
                'reward_type' => 'merch',
                'trigger_mode' => 'on_booking_completed',
                'fulfillment_mode' => 'qr_claim',
                'eligible_ticket_ids' => json_encode([910]),
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $instances = app(EventTicketRewardService::class)->issueForBookings([
            Booking::findOrFail($bookingId),
        ]);

        $this->assertCount(2, $instances);
        $this->assertDatabaseHas('event_reward_instances', [
            'reward_definition_id' => 601,
            'booking_id' => $bookingId,
            'status' => 'reserved',
        ]);
        $this->assertDatabaseHas('event_reward_instances', [
            'reward_definition_id' => 602,
            'booking_id' => $bookingId,
            'status' => 'activated',
        ]);
        $this->assertDatabaseHas('event_reward_claim_logs', [
            'action' => 'issued',
        ]);
        $this->assertDatabaseHas('event_reward_claim_logs', [
            'action' => 'activated',
        ]);
    }

    public function test_issue_for_bookings_honors_ticket_eligibility_and_per_ticket_quantity(): void
    {
        DB::table('events')->insert([
            'id' => 62,
            'title' => 'Eligibility event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $eligibleBookingId = (int) DB::table('bookings')->insertGetId([
            'event_id' => 62,
            'ticket_id' => 920,
            'booking_id' => 'bk-reward-62-a',
            'order_number' => 'ord-reward-62-a',
            'paymentStatus' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $ineligibleBookingId = (int) DB::table('bookings')->insertGetId([
            'event_id' => 62,
            'ticket_id' => 930,
            'booking_id' => 'bk-reward-62-b',
            'order_number' => 'ord-reward-62-b',
            'paymentStatus' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_definitions')->insert([
            'id' => 603,
            'event_id' => 62,
            'title' => 'Two vouchers',
            'reward_type' => 'voucher',
            'trigger_mode' => 'on_ticket_scan',
            'fulfillment_mode' => 'qr_claim',
            'per_ticket_quantity' => 2,
            'eligible_ticket_ids' => json_encode([920]),
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        app(EventTicketRewardService::class)->issueForBookings([
            Booking::findOrFail($eligibleBookingId),
            Booking::findOrFail($ineligibleBookingId),
        ]);

        $this->assertSame(
            2,
            DB::table('event_reward_instances')
                ->where('booking_id', $eligibleBookingId)
                ->where('reward_definition_id', 603)
                ->count()
        );
        $this->assertSame(
            0,
            DB::table('event_reward_instances')
                ->where('booking_id', $ineligibleBookingId)
                ->where('reward_definition_id', 603)
                ->count()
        );
    }

    private function ensureRewardBookingColumns(): void
    {
        foreach ([
            'booking_id' => fn (Blueprint $table) => $table->string('booking_id')->nullable(),
            'order_number' => fn (Blueprint $table) => $table->string('order_number')->nullable(),
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'ticket_id' => fn (Blueprint $table) => $table->unsignedBigInteger('ticket_id')->nullable(),
            'variation' => fn (Blueprint $table) => $table->longText('variation')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }
    }
}
