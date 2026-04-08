<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\MarketplaceController;
use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class MarketplaceIndexVisibilityActorTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace'];
    protected array $baselineTruncate = [
        'bookings',
        'event_contents',
        'events',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureEventContentSchema();
    }

    public function test_index_only_returns_visible_marketplace_listings(): void
    {
        $viewer = $this->seedCustomer(6101, 'viewer@example.com');
        $seller = $this->seedCustomer(6102, 'seller@example.com');

        DB::table('events')->insert([
            [
                'id' => 6201,
                'title' => 'Future Visible Event',
                'end_date_time' => now()->addDay(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6202,
                'title' => 'Past Hidden Event',
                'end_date_time' => now()->subHour(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'id' => 6301,
                'event_id' => 6201,
                'title' => 'Future Visible Event',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6302,
                'event_id' => 6202,
                'title' => 'Past Hidden Event',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            [
                'id' => 6401,
                'customer_id' => $seller->id,
                'event_id' => 6201,
                'paymentStatus' => 'completed',
                'price' => 120,
                'quantity' => 1,
                'is_transferable' => true,
                'is_listed' => true,
                'transfer_status' => null,
                'listing_price' => 80,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6402,
                'customer_id' => $seller->id,
                'event_id' => 6201,
                'paymentStatus' => 'completed',
                'price' => 120,
                'quantity' => 1,
                'is_transferable' => true,
                'is_listed' => true,
                'transfer_status' => 'transfer_pending',
                'listing_price' => 70,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6403,
                'customer_id' => $seller->id,
                'event_id' => 6202,
                'paymentStatus' => 'completed',
                'price' => 120,
                'quantity' => 1,
                'is_transferable' => true,
                'is_listed' => true,
                'transfer_status' => null,
                'listing_price' => 60,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6404,
                'customer_id' => $viewer->id,
                'event_id' => 6201,
                'paymentStatus' => 'completed',
                'price' => 120,
                'quantity' => 1,
                'is_transferable' => true,
                'is_listed' => true,
                'transfer_status' => null,
                'listing_price' => 90,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs($viewer, [], 'sanctum');

        $response = app(MarketplaceController::class)->index(
            Request::create('/api/customers/marketplace', 'GET')
        );

        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertCount(1, $payload['data']);
        $this->assertSame(6401, $payload['data'][0]['id']);
        $this->assertSame('Future Visible Event', $payload['data'][0]['event']['title']);
    }

    private function ensureEventContentSchema(): void
    {
        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'is_transferable' => fn (Blueprint $table) => $table->boolean('is_transferable')->default(true),
            'transfer_status' => fn (Blueprint $table) => $table->string('transfer_status')->nullable(),
            'listing_price' => fn (Blueprint $table) => $table->decimal('listing_price', 15, 2)->default(0),
            'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->default(0),
        ] as $column => $definition) {
            if (Schema::hasTable('bookings') && !Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
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
            'fname' => 'Marketplace',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }
}
