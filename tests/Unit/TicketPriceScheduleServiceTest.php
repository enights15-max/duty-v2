<?php

namespace Tests\Unit;

use App\Models\Event\Ticket;
use App\Services\TicketPriceScheduleService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class TicketPriceScheduleServiceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureTicketSchema();
        $this->truncateTables();
    }

    public function test_resolve_for_ticket_prefers_latest_active_schedule_before_now(): void
    {
        DB::table('tickets')->insert([
            'id' => 901,
            'event_id' => 1001,
            'pricing_type' => 'normal',
            'price' => 100.00,
            'f_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_price_schedules')->insert([
            [
                'ticket_id' => 901,
                'label' => 'Launch',
                'effective_from' => now()->subDays(7),
                'price' => 120.00,
                'sort_order' => 1,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'ticket_id' => 901,
                'label' => 'Phase 2',
                'effective_from' => now()->subDay(),
                'price' => 140.00,
                'sort_order' => 2,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'ticket_id' => 901,
                'label' => 'Final',
                'effective_from' => now()->addDays(5),
                'price' => 180.00,
                'sort_order' => 3,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ticket = Ticket::findOrFail(901);
        $pricing = app(TicketPriceScheduleService::class)->resolveForTicket($ticket);

        $this->assertTrue($pricing['has_schedule']);
        $this->assertSame(140.0, $pricing['effective_price']);
        $this->assertSame('Phase 2', $pricing['current_schedule']['label']);
        $this->assertSame(180.0, $pricing['next_schedule']['price']);
    }

    public function test_resolve_event_start_price_uses_effective_schedule_price_for_normal_ticket(): void
    {
        DB::table('tickets')->insert([
            [
                'id' => 902,
                'event_id' => 1002,
                'pricing_type' => 'normal',
                'price' => 120.00,
                'f_price' => 120.00,
                'variations' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 903,
                'event_id' => 1002,
                'pricing_type' => 'variation',
                'price' => null,
                'f_price' => 200.00,
                'variations' => json_encode([
                    ['name' => 'VIP', 'price' => 200],
                    ['name' => 'GA', 'price' => 160],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_price_schedules')->insert([
            'ticket_id' => 902,
            'label' => 'Wave 1',
            'effective_from' => now()->subDay(),
            'price' => 90.00,
            'sort_order' => 1,
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $payload = app(TicketPriceScheduleService::class)->resolveEventStartPrice(1002);

        $this->assertSame(902, $payload['ticket']->id);
        $this->assertSame(90.0, $payload['start_price']);
    }

    public function test_resolve_for_ticket_prefers_highest_sort_order_when_effective_from_ties(): void
    {
        $anchor = now()->subHour();

        DB::table('tickets')->insert([
            'id' => 904,
            'event_id' => 1003,
            'pricing_type' => 'normal',
            'price' => 80.00,
            'f_price' => 80.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_price_schedules')->insert([
            [
                'ticket_id' => 904,
                'label' => 'Wave A',
                'effective_from' => $anchor,
                'price' => 95.00,
                'sort_order' => 1,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'ticket_id' => 904,
                'label' => 'Wave B',
                'effective_from' => $anchor,
                'price' => 110.00,
                'sort_order' => 5,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $pricing = app(TicketPriceScheduleService::class)->resolveForTicket(
            Ticket::findOrFail(904),
            $anchor->copy()->addMinute()
        );

        $this->assertTrue($pricing['has_schedule']);
        $this->assertSame(110.0, $pricing['effective_price']);
        $this->assertSame('Wave B', $pricing['current_schedule']['label']);
    }

    public function test_resolve_event_start_price_ignores_variation_rows_without_numeric_price(): void
    {
        DB::table('tickets')->insert([
            'id' => 905,
            'event_id' => 1004,
            'pricing_type' => 'variation',
            'price' => null,
            'f_price' => null,
            'variations' => json_encode([
                ['name' => 'VIP', 'price' => null],
                ['name' => 'GA', 'price' => 160],
                ['name' => 'Broken', 'price' => ''],
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $payload = app(TicketPriceScheduleService::class)->resolveEventStartPrice(1004);

        $this->assertSame(905, $payload['ticket']->id);
        $this->assertSame(160.0, $payload['start_price']);
    }

    private function ensureTicketSchema(): void
    {
        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->nullable();
                $table->decimal('f_price', 15, 2)->nullable();
                $table->longText('variations')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_price_schedules')) {
            Schema::create('ticket_price_schedules', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->string('label')->nullable();
                $table->dateTime('effective_from');
                $table->decimal('price', 15, 2);
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }
    }

    private function truncateTables(): void
    {
        DB::table('ticket_price_schedules')->delete();
        DB::table('tickets')->delete();
    }
}
