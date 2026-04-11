<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\MarketplaceController;
use App\Models\Customer;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class MarketplaceTransferActorTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace'];
    protected array $baselineTruncate = [
        'ticket_transfers',
        'bookings',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->app->instance(NotificationService::class, new class extends NotificationService {
            public function notifyUser($user, string $title, string $body, array $data = [])
            {
                return true;
            }
        });
    }

    public function test_transfer_changes_owner_and_records_ticket_transfer(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 401,
                'email' => 'owner@example.com',
                'username' => 'owner',
                'fname' => 'Owner',
                'lname' => 'One',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 402,
                'email' => 'recipient@example.com',
                'username' => 'recipient',
                'fname' => 'Recipient',
                'lname' => 'Two',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9201,
            'customer_id' => 401,
            'event_id' => 1,
            'email' => 'owner@example.com',
            'phone' => '111',
            'is_transferable' => 1,
            'is_listed' => 1,
            'listing_price' => 50.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(401), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9201/transfer', 'POST', [
            'recipient' => 'recipient@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9201);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9201,
            'customer_id' => 402,
            'is_listed' => 0,
            'email' => 'recipient@example.com',
        ]);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9201,
            'from_customer_id' => 401,
            'to_customer_id' => 402,
            'status' => 'accepted',
            'flow' => 'direct_owner_transfer',
        ]);
    }

    public function test_transfer_rejects_self_transfer(): void
    {
        DB::table('customers')->insert([
            'id' => 403,
            'email' => 'self@example.com',
            'username' => 'self',
            'fname' => 'Self',
            'lname' => 'User',
            'phone' => '333',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9202,
            'customer_id' => 403,
            'event_id' => 1,
            'email' => 'self@example.com',
            'phone' => '333',
            'is_transferable' => 1,
            'is_listed' => 0,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(403), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9202/transfer', 'POST', [
            'recipient' => 'self@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9202);
        $payload = $response->getData(true);

        $this->assertEquals(400, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('You cannot transfer a ticket to yourself.', $payload['message']);
        $this->assertDatabaseCount('ticket_transfers', 0);
    }

    public function test_transfer_rejects_unknown_recipient(): void
    {
        DB::table('customers')->insert([
            'id' => 404,
            'email' => 'known@example.com',
            'username' => 'known',
            'fname' => 'Known',
            'lname' => 'User',
            'phone' => '444',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9203,
            'customer_id' => 404,
            'event_id' => 1,
            'email' => 'known@example.com',
            'phone' => '444',
            'is_transferable' => 1,
            'is_listed' => 0,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(404), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9203/transfer', 'POST', [
            'recipient' => 'missing@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9203);
        $payload = $response->getData(true);

        $this->assertEquals(404, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Recipient user not found.', $payload['message']);
        $this->assertDatabaseCount('ticket_transfers', 0);
    }

    public function test_transfer_rejects_non_transferable_ticket(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 405,
                'email' => 'owner2@example.com',
                'username' => 'owner2',
                'fname' => 'Owner',
                'lname' => 'Two',
                'phone' => '555',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 406,
                'email' => 'recipient2@example.com',
                'username' => 'recipient2',
                'fname' => 'Recipient',
                'lname' => 'Three',
                'phone' => '666',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9204,
            'customer_id' => 405,
            'event_id' => 1,
            'email' => 'owner2@example.com',
            'phone' => '555',
            'is_transferable' => 0,
            'is_listed' => 1,
            'listing_price' => 75.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(405), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9204/transfer', 'POST', [
            'recipient' => 'recipient2@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9204);
        $payload = $response->getData(true);

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('This ticket is not transferable.', $payload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9204,
            'customer_id' => 405,
            'is_listed' => 1,
            'listing_price' => '75.00',
        ]);
        $this->assertDatabaseCount('ticket_transfers', 0);
    }

    public function test_outbox_excludes_marketplace_purchase_transfers(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 410,
                'email' => 'outbox@example.com',
                'username' => 'outbox',
                'fname' => 'Outbox',
                'lname' => 'User',
                'phone' => '710',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 411,
                'email' => 'other@example.com',
                'username' => 'other',
                'fname' => 'Other',
                'lname' => 'User',
                'phone' => '711',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_transfers')->insert([
            [
                'id' => 9301,
                'booking_id' => 1,
                'from_customer_id' => 410,
                'to_customer_id' => 411,
                'status' => 'accepted',
                'flow' => 'direct_owner_transfer',
                'notes' => 'Direct transfer via Mobile App',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9302,
                'booking_id' => 2,
                'from_customer_id' => 410,
                'to_customer_id' => 411,
                'status' => 'accepted',
                'flow' => 'marketplace_purchase',
                'notes' => 'Marketplace Purchase',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs(\App\Models\Customer::findOrFail(410), [], 'sanctum');

        $response = app(MarketplaceController::class)->outboxTransfers();
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $ids = array_column($payload['data'], 'id');
        $this->assertContains(9301, $ids, 'Gift transfer should appear in outbox');
        $this->assertNotContains(9302, $ids, 'Marketplace purchase should not appear in outbox');
    }
}
