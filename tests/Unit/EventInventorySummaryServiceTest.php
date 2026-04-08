<?php

namespace Tests\Unit;

use App\Models\Event;
use App\Services\EventInventorySummaryService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class EventInventorySummaryServiceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureSchema();
        $this->truncateTables();
    }

    public function test_sold_out_future_event_without_marketplace_exposes_waitlist_cta(): void
    {
        DB::table('events')->insert([
            'id' => 1001,
            'title' => 'Waitlist Eligible Event',
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 2001,
            'event_id' => 1001,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $summary = app(EventInventorySummaryService::class)->summarizeEvent(
            Event::query()->findOrFail(1001)
        );

        $this->assertTrue($summary['primary_sold_out']);
        $this->assertFalse($summary['show_marketplace_fallback']);
        $this->assertTrue($summary['show_waitlist_cta']);
        $this->assertFalse($summary['is_past_event']);
    }

    public function test_sold_out_event_with_marketplace_inventory_hides_waitlist_cta(): void
    {
        DB::table('customers')->insert([
            'id' => 4002,
            'email' => 'seller-marketplace@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 1002,
            'title' => 'Marketplace Rescue Event',
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 2002,
            'event_id' => 1002,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 3002,
            'customer_id' => 4002,
            'event_id' => 1002,
            'paymentStatus' => 'completed',
            'quantity' => 1,
            'is_listed' => 1,
            'is_transferable' => 1,
            'transfer_status' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $summary = app(EventInventorySummaryService::class)->summarizeEvent(
            Event::query()->findOrFail(1002)
        );

        $this->assertTrue($summary['primary_sold_out']);
        $this->assertTrue($summary['show_marketplace_fallback']);
        $this->assertFalse($summary['show_waitlist_cta']);
        $this->assertSame('sold_out_marketplace', $summary['availability_state']);
    }

    public function test_transfer_pending_listing_does_not_trigger_marketplace_fallback(): void
    {
        DB::table('customers')->insert([
            'id' => 4004,
            'email' => 'seller-pending-transfer@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 1004,
            'title' => 'Pending Transfer Listing',
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 2004,
            'event_id' => 1004,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 3004,
            'customer_id' => 4004,
            'event_id' => 1004,
            'paymentStatus' => 'completed',
            'quantity' => 1,
            'is_listed' => 1,
            'is_transferable' => 1,
            'transfer_status' => 'transfer_pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $summary = app(EventInventorySummaryService::class)->summarizeEvent(
            Event::query()->findOrFail(1004)
        );

        $this->assertSame(0, $summary['marketplace_available_count']);
        $this->assertFalse($summary['show_marketplace_fallback']);
        $this->assertTrue($summary['show_waitlist_cta']);
        $this->assertSame('sold_out', $summary['availability_state']);
    }

    public function test_past_event_ignores_listings_when_computing_marketplace_fallback(): void
    {
        DB::table('customers')->insert([
            'id' => 4005,
            'email' => 'seller-past-event@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 1005,
            'title' => 'Past Event With Stale Listing',
            'end_date_time' => now()->subHour(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 2005,
            'event_id' => 1005,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 3005,
            'customer_id' => 4005,
            'event_id' => 1005,
            'paymentStatus' => 'completed',
            'quantity' => 1,
            'is_listed' => 1,
            'is_transferable' => 1,
            'transfer_status' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $summary = app(EventInventorySummaryService::class)->summarizeEvent(
            Event::query()->findOrFail(1005)
        );

        $this->assertTrue($summary['is_past_event']);
        $this->assertSame(0, $summary['marketplace_available_count']);
        $this->assertFalse($summary['show_marketplace_fallback']);
        $this->assertFalse($summary['show_waitlist_cta']);
    }

    public function test_past_event_never_exposes_waitlist_cta_even_when_primary_inventory_is_sold_out(): void
    {
        DB::table('events')->insert([
            'id' => 1003,
            'title' => 'Past Event',
            'end_date_time' => now()->subHour(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 2003,
            'event_id' => 1003,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $summary = app(EventInventorySummaryService::class)->summarizeEvent(
            Event::query()->findOrFail(1003)
        );

        $this->assertTrue($summary['primary_sold_out']);
        $this->assertTrue($summary['is_past_event']);
        $this->assertFalse($summary['show_waitlist_cta']);
    }

    private function ensureSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->string('title')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('pricing_type')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->default(0);
                $table->longText('variations')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->integer('quantity')->default(1);
                $table->boolean('is_listed')->default(false);
                $table->boolean('is_transferable')->default(true);
                $table->string('transfer_status')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'customer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('customer_id')->nullable(),
            'is_transferable' => fn (Blueprint $table) => $table->boolean('is_transferable')->default(true),
            'transfer_status' => fn (Blueprint $table) => $table->string('transfer_status')->nullable(),
        ] as $column => $definition) {
            if (Schema::hasTable('bookings') && !Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }

        if (!Schema::hasTable('customers')) {
            Schema::create('customers', function (Blueprint $table): void {
                $table->id();
                $table->string('email')->nullable();
                $table->timestamps();
            });
        }
    }

    private function truncateTables(): void
    {
        DB::table('bookings')->delete();
        DB::table('tickets')->delete();
        DB::table('events')->delete();
        if (Schema::hasTable('customers')) {
            DB::table('customers')->delete();
        }
    }
}
