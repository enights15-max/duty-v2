<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventWaitlistController;
use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class EventWaitlistControllerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = [
        'event_waitlist_subscriptions',
        'bookings',
        'tickets',
        'events',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureSchema();
    }

    public function test_store_rejects_past_events_even_when_primary_inventory_is_sold_out(): void
    {
        $customer = $this->seedCustomer(4101, 'waitlist-past@example.com');
        Sanctum::actingAs($customer, [], 'sanctum');

        DB::table('events')->insert([
            'id' => 5101,
            'title' => 'Past Sold Out Event',
            'end_date_time' => now()->subHour(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 6101,
            'event_id' => 5101,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(EventWaitlistController::class)->store(5101);
        $payload = $response->getData(true);

        $this->assertSame(409, $response->getStatusCode());
        $this->assertSame('error', $payload['status']);
        $this->assertSame('La waitlist no está disponible para eventos finalizados.', $payload['message']);
        $this->assertDatabaseCount('event_waitlist_subscriptions', 0);
    }

    public function test_store_subscribes_customer_when_event_is_sold_out_and_no_marketplace_inventory_exists(): void
    {
        $customer = $this->seedCustomer(4102, 'waitlist-active@example.com');
        Sanctum::actingAs($customer, [], 'sanctum');

        DB::table('events')->insert([
            'id' => 5102,
            'title' => 'Future Sold Out Event',
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 6102,
            'event_id' => 5102,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(EventWaitlistController::class)->store(5102);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame('success', $payload['status']);
        $this->assertTrue($payload['data']['viewer_waitlist_subscribed']);
        $this->assertTrue($payload['data']['show_waitlist_cta']);
        $this->assertDatabaseHas('event_waitlist_subscriptions', [
            'event_id' => 5102,
            'customer_id' => $customer->id,
            'status' => 'active',
        ]);
    }

    public function test_store_allows_waitlist_when_only_marketplace_listing_is_not_visible(): void
    {
        $customer = $this->seedCustomer(4103, 'waitlist-hidden-marketplace@example.com');
        $seller = $this->seedCustomer(4104, 'marketplace-seller@example.com');
        Sanctum::actingAs($customer, [], 'sanctum');

        DB::table('events')->insert([
            'id' => 5103,
            'title' => 'Future Sold Out Event With Hidden Listing',
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 6103,
            'event_id' => 5103,
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 7103,
            'customer_id' => $seller->id,
            'event_id' => 5103,
            'paymentStatus' => 'completed',
            'quantity' => 1,
            'is_transferable' => true,
            'is_listed' => true,
            'transfer_status' => 'transfer_pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(EventWaitlistController::class)->store(5103);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame('success', $payload['status']);
        $this->assertTrue($payload['data']['viewer_waitlist_subscribed']);
        $this->assertTrue($payload['data']['show_waitlist_cta']);
        $this->assertSame(1, DB::table('event_waitlist_subscriptions')->where('event_id', 5103)->count());
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
                $table->boolean('is_transferable')->default(true);
                $table->boolean('is_listed')->default(false);
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

        if (!Schema::hasTable('event_waitlist_subscriptions')) {
            Schema::create('event_waitlist_subscriptions', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->index();
                $table->unsignedBigInteger('customer_id')->index();
                $table->string('status', 20)->default('active')->index();
                $table->string('notified_reason', 40)->nullable();
                $table->timestamp('notified_at')->nullable();
                $table->timestamps();
                $table->unique(['event_id', 'customer_id'], 'event_waitlist_unique_subscription');
            });
        }
    }

    private function seedCustomer(int $id, string $email): Customer
    {
        DB::table('users')->insert([
            'id' => $id,
            'email' => $email,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $id,
            'email' => $email,
            'fname' => 'Waitlist',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }
}
