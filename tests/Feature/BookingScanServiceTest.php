<?php

namespace Tests\Feature;

use App\Models\Event\Booking;
use App\Services\BookingScanService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class BookingScanServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace', 'loyalty', 'event_rewards'];
    protected array $baselineTruncate = [
        'loyalty_point_transactions',
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
        $this->ensureScannerBookingColumns();
    }

    public function test_first_scan_sets_attendance_and_awards_loyalty_once(): void
    {
        DB::table('users')->insert([
            'id' => 1401,
            'email' => 'scan-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1401,
            'email' => 'scan-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $bookingId = (int) DB::table('bookings')->insertGetId([
            'customer_id' => 1401,
            'event_id' => 51,
            'booking_id' => 'bk-scan-1401',
            'order_number' => 'ord-scan-1401',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = Booking::findOrFail($bookingId);
        $service = app(BookingScanService::class);

        $first = $service->setTicketScanStatus($booking, 'unit-1', true);
        $second = $service->setTicketScanStatus($booking->fresh(), 'unit-1', true);

        $this->assertTrue($first['changed']);
        $this->assertFalse($second['changed']);
        $this->assertSame(1, (int) $booking->fresh()->scan_status);
        $this->assertSame(['unit-1'], json_decode((string) $booking->fresh()->scanned_tickets, true));
        $this->assertDatabaseHas('loyalty_point_transactions', [
            'customer_id' => 1401,
            'reference_type' => 'booking_attendance',
            'reference_id' => 'ord-scan-1401',
            'points' => 40,
            'type' => 'credit',
        ]);
        $this->assertSame(1, DB::table('loyalty_point_transactions')->count());
    }

    public function test_unscanning_last_ticket_clears_scan_status(): void
    {
        $bookingId = (int) DB::table('bookings')->insertGetId([
            'customer_id' => 1501,
            'event_id' => 52,
            'booking_id' => 'bk-scan-1501',
            'order_number' => 'ord-scan-1501',
            'paymentStatus' => 'completed',
            'scan_status' => 1,
            'scanned_tickets' => json_encode(['ticket-1']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $service = app(BookingScanService::class);
        $result = $service->setTicketScanStatus(Booking::findOrFail($bookingId), 'ticket-1', false);

        $this->assertTrue($result['changed']);
        $this->assertSame(0, (int) Booking::findOrFail($bookingId)->scan_status);
        $this->assertNull(Booking::findOrFail($bookingId)->scanned_tickets);
    }

    public function test_first_scan_activates_reserved_ticket_rewards(): void
    {
        DB::table('users')->insert([
            'id' => 1601,
            'email' => 'reward-scan-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1601,
            'email' => 'reward-scan-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 53,
            'title' => 'Reward scan event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $bookingId = (int) DB::table('bookings')->insertGetId([
            'customer_id' => 1601,
            'event_id' => 53,
            'ticket_id' => 320,
            'booking_id' => 'bk-scan-reward-1601',
            'order_number' => 'ord-scan-reward-1601',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_definitions')->insert([
            'id' => 501,
            'event_id' => 53,
            'title' => 'Welcome drink',
            'reward_type' => 'drink',
            'trigger_mode' => 'on_ticket_scan',
            'fulfillment_mode' => 'qr_claim',
            'per_ticket_quantity' => 1,
            'eligible_ticket_ids' => json_encode([320]),
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = Booking::findOrFail($bookingId);
        app(\App\Services\EventTicketRewardService::class)->issueForBookings([$booking]);

        $instance = DB::table('event_reward_instances')->where('booking_id', $bookingId)->first();
        $this->assertNotNull($instance);
        $this->assertSame('reserved', $instance->status);

        $result = app(BookingScanService::class)->setTicketScanStatus($booking->fresh(), 'unit-1', true);

        $this->assertTrue($result['changed']);
        $this->assertDatabaseHas('event_reward_instances', [
            'booking_id' => $bookingId,
            'reward_definition_id' => 501,
            'status' => 'activated',
        ]);
        $this->assertSame(
            2,
            DB::table('event_reward_claim_logs')
                ->where('reward_instance_id', $instance->id)
                ->count()
        );
        $this->assertDatabaseHas('event_reward_claim_logs', [
            'reward_instance_id' => $instance->id,
            'action' => 'activated',
        ]);
    }

    private function ensureScannerBookingColumns(): void
    {
        if (!Schema::hasColumn('bookings', 'booking_id')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('booking_id')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'order_number')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('order_number')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'paymentStatus')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('paymentStatus')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'scanned_tickets')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->longText('scanned_tickets')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'scan_status')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->integer('scan_status')->default(0);
            });
        }

        if (!Schema::hasColumn('bookings', 'ticket_id')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->unsignedBigInteger('ticket_id')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'variation')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->longText('variation')->nullable();
            });
        }
    }
}
