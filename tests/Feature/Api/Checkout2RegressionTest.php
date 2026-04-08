<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class Checkout2RegressionTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace'];
    protected array $baselineTruncate = [
        'ticket_contents',
        'tickets',
        'bookings',
        'events',
        'basic_settings',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureCheckout2Schema();
        $this->truncateCheckout2Tables();
        $this->seedCheckout2Defaults();
    }

    public function test_checkout2_requires_login_when_guest_checkout_is_disabled(): void
    {
        DB::table('basic_settings')->where('id', 1)->update([
            'event_guest_checkout_status' => 0,
            'updated_at' => now(),
        ]);

        $sanctumGuard = \Mockery::mock();
        $sanctumGuard->shouldReceive('check')->once()->andReturn(false);

        Auth::shouldReceive('guard')
            ->once()
            ->with('sanctum')
            ->andReturn($sanctumGuard);

        $response = app(EventController::class)->checkout2([]);

        $this->assertSame([
            'success' => false,
            'message' => 'login Required',
        ], $response);
    }

    public function test_checkout2_requires_at_least_one_ticket_selection_for_venue_event(): void
    {
        DB::table('events')->insert([
            'id' => 801,
            'event_type' => 'venue',
            'title' => 'Venue Empty Selection',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(EventController::class)->checkout2([
            'event_id' => 801,
            'quantity' => [0],
            'pricing_type' => 'variation',
            'seatData' => [],
        ]);

        $this->assertSame([
            'success' => false,
            'message' => 'Please Select at least one ticket',
        ], $response);
    }

    public function test_checkout2_uses_ticket_name_fallback_when_ticket_content_is_missing(): void
    {
        DB::table('events')->insert([
            'id' => 802,
            'event_type' => 'venue',
            'title' => 'Ticket Fallback Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 9001,
            'event_id' => 802,
            'event_type' => 'venue',
            'title' => null,
            'pricing_type' => 'normal',
            'price' => 450,
            'ticket_available_type' => 'limited',
            'ticket_available' => 20,
            'max_ticket_buy_type' => 'unlimited',
            'max_buy_ticket' => 0,
            'normal_ticket_slot_enable' => 0,
            'free_tickete_slot_enable' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(EventController::class)->checkout2([
            'event_id' => 802,
            'quantity' => [1],
            'pricing_type' => 'variation',
            'seatData' => [],
        ]);

        $this->assertIsArray($response);
        $this->assertTrue((bool) ($response['success'] ?? false));
        $this->assertSame('Ticket #9001', $response['selTickets'][0]['name'] ?? null);
    }

    private function ensureCheckout2Schema(): void
    {
        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->default(0);
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->default(0);
                $table->text('description')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('f_price', 15, 2)->nullable();
                $table->string('early_bird_discount')->default('disable');
                $table->decimal('early_bird_discount_amount', 15, 2)->default(0);
                $table->string('early_bird_discount_type')->default('fixed');
                $table->date('early_bird_discount_date')->nullable();
                $table->string('early_bird_discount_time')->nullable();
                $table->longText('variations')->nullable();
                $table->tinyInteger('normal_ticket_slot_enable')->default(0);
                $table->unsignedBigInteger('normal_ticket_slot_unique_id')->nullable();
                $table->tinyInteger('free_tickete_slot_enable')->default(0);
                $table->unsignedBigInteger('free_tickete_slot_unique_id')->nullable();
                $table->decimal('slot_seat_min_price', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_contents')) {
            Schema::create('ticket_contents', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->string('title')->nullable();
                $table->text('description')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('events', 'event_type')) {
            Schema::table('events', function (Blueprint $table): void {
                $table->string('event_type')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'paymentStatus')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('paymentStatus')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'variation')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->longText('variation')->nullable();
            });
        }

        if (!Schema::hasColumn('basic_settings', 'event_guest_checkout_status')) {
            Schema::table('basic_settings', function (Blueprint $table): void {
                $table->tinyInteger('event_guest_checkout_status')->default(1);
            });
        }
    }

    private function truncateCheckout2Tables(): void
    {
        foreach (['ticket_contents', 'tickets', 'bookings', 'events', 'basic_settings'] as $table) {
            if (Schema::hasTable($table)) {
                DB::table($table)->delete();
            }
        }
    }

    private function seedCheckout2Defaults(): void
    {
        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 1,
            'marketplace_commission' => 5.00,
            'event_guest_checkout_status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
