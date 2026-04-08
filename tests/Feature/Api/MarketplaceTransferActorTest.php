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

    public function test_transfer_creates_pending_request_without_changing_owner(): void
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
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(401), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9201/transfer', 'POST', [
            'recipient' => 'recipient@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9201);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode(), json_encode($payload));
        $this->assertTrue($payload['success']);
        $this->assertStringContainsString('Transfer request sent to', $payload['message']);
        $this->assertSame('pending', $payload['data']['status']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9201,
            'customer_id' => 401,
            'is_listed' => 0,
            'transfer_status' => 'transfer_pending',
            'email' => 'owner@example.com',
        ]);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9201,
            'from_customer_id' => 401,
            'to_customer_id' => 402,
            'status' => 'pending',
        ]);
    }

    public function test_accept_transfer_changes_owner_and_marks_request_as_accepted(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 410,
                'email' => 'owner-accept@example.com',
                'username' => 'owneraccept',
                'fname' => 'Owner',
                'lname' => 'Accept',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 411,
                'email' => 'recipient-accept@example.com',
                'username' => 'recipientaccept',
                'fname' => 'Recipient',
                'lname' => 'Accept',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9206,
            'customer_id' => 410,
            'event_id' => 1,
            'email' => 'owner-accept@example.com',
            'phone' => '111',
            'is_transferable' => 1,
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(410), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9206/transfer', 'POST', [
            'recipient' => 'recipient-accept@example.com',
        ]);
        $transferResponse = app(MarketplaceController::class)->transfer($request, 9206);
        $transferPayload = $transferResponse->getData(true);
        $this->assertEquals(200, $transferResponse->getStatusCode(), json_encode($transferPayload));

        Sanctum::actingAs(Customer::findOrFail(411), [], 'sanctum');
        $acceptResponse = app(MarketplaceController::class)->acceptTransfer($transferPayload['data']['transfer_id']);
        $acceptPayload = $acceptResponse->getData(true);

        $this->assertEquals(200, $acceptResponse->getStatusCode());
        $this->assertTrue($acceptPayload['success']);
        $this->assertEquals('Transfer accepted! The ticket is now yours.', $acceptPayload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9206,
            'customer_id' => 411,
            'is_listed' => 0,
            'transfer_status' => null,
            'email' => 'recipient-accept@example.com',
        ]);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9206,
            'from_customer_id' => 410,
            'to_customer_id' => 411,
            'status' => 'accepted',
        ]);
    }

    public function test_verify_and_transfer_accept_recipient_id(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 412,
                'email' => 'owner-id@example.com',
                'username' => 'ownerid',
                'fname' => 'Owner',
                'lname' => 'Id',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 413,
                'email' => 'recipient-id@example.com',
                'username' => 'recipientid',
                'fname' => 'Recipient',
                'lname' => 'Id',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9207,
            'customer_id' => 412,
            'event_id' => 1,
            'email' => 'owner-id@example.com',
            'phone' => '111',
            'is_transferable' => 1,
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(412), [], 'sanctum');

        $verifyRequest = Request::create('/api/customers/transfers/verify-recipient', 'POST', [
            'recipient_id' => 413,
        ]);
        $verifyResponse = app(MarketplaceController::class)->verifyRecipient($verifyRequest);
        $verifyPayload = $verifyResponse->getData(true);

        $this->assertEquals(200, $verifyResponse->getStatusCode(), json_encode($verifyPayload));
        $this->assertTrue($verifyPayload['success']);
        $this->assertSame(413, $verifyPayload['data']['id']);
        $this->assertSame('recipientid', $verifyPayload['data']['username']);

        $transferRequest = Request::create('/api/customers/bookings/9207/transfer', 'POST', [
            'recipient_id' => 413,
        ]);
        $transferResponse = app(MarketplaceController::class)->transfer($transferRequest, 9207);
        $transferPayload = $transferResponse->getData(true);

        $this->assertEquals(200, $transferResponse->getStatusCode(), json_encode($transferPayload));
        $this->assertTrue($transferPayload['success']);
        $this->assertSame('pending', $transferPayload['data']['status']);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9207,
            'from_customer_id' => 412,
            'to_customer_id' => 413,
            'status' => 'pending',
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

    public function test_transfer_rejects_when_pending_transfer_row_already_exists(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 407,
                'email' => 'owner3@example.com',
                'username' => 'owner3',
                'fname' => 'Owner',
                'lname' => 'Three',
                'phone' => '777',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 408,
                'email' => 'recipient3@example.com',
                'username' => 'recipient3',
                'fname' => 'Recipient',
                'lname' => 'Four',
                'phone' => '888',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 409,
                'email' => 'recipient4@example.com',
                'username' => 'recipient4',
                'fname' => 'Recipient',
                'lname' => 'Five',
                'phone' => '999',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9205,
            'customer_id' => 407,
            'event_id' => 1,
            'email' => 'owner3@example.com',
            'phone' => '777',
            'is_transferable' => 1,
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_transfers')->insert([
            'booking_id' => 9205,
            'from_customer_id' => 407,
            'to_customer_id' => 408,
            'notes' => 'Existing pending transfer',
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(407), [], 'sanctum');

        $request = Request::create('/api/customers/bookings/9205/transfer', 'POST', [
            'recipient' => 'recipient4@example.com',
        ]);

        $response = app(MarketplaceController::class)->transfer($request, 9205);
        $payload = $response->getData(true);

        $this->assertEquals(409, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('This ticket already has a pending transfer request.', $payload['message']);
        $this->assertDatabaseCount('ticket_transfers', 1);
        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9205,
            'to_customer_id' => 408,
            'status' => 'pending',
        ]);
    }

    public function test_transfer_qr_request_creates_pending_request_for_ticket_owner(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 414,
                'email' => 'owner-qr@example.com',
                'username' => 'ownerqr',
                'fname' => 'Owner',
                'lname' => 'Qr',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 415,
                'email' => 'requester-qr@example.com',
                'username' => 'requesterqr',
                'fname' => 'Requester',
                'lname' => 'Qr',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9208,
            'customer_id' => 414,
            'event_id' => 1,
            'email' => 'owner-qr@example.com',
            'phone' => '111',
            'is_transferable' => 1,
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(414), [], 'sanctum');
        $qrResponse = app(MarketplaceController::class)->transferQr(9208);
        $qrPayload = $qrResponse->getData(true);

        $this->assertEquals(200, $qrResponse->getStatusCode(), json_encode($qrPayload));
        $this->assertTrue($qrPayload['success']);
        $this->assertNotEmpty($qrPayload['data']['transfer_token']);

        Sanctum::actingAs(Customer::findOrFail(415), [], 'sanctum');
        $request = Request::create('/api/customers/transfers/request-from-scan', 'POST', [
            'transfer_token' => $qrPayload['data']['transfer_token'],
        ]);
        $response = app(MarketplaceController::class)->requestFromTicketScan($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode(), json_encode($payload));
        $this->assertTrue($payload['success']);
        $this->assertSame('receiver_request', $payload['data']['flow']);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9208,
            'from_customer_id' => 415,
            'to_customer_id' => 414,
            'status' => 'pending',
            'flow' => 'receiver_request',
        ]);

        $this->assertDatabaseHas('bookings', [
            'id' => 9208,
            'customer_id' => 414,
            'transfer_status' => 'transfer_pending',
        ]);
    }

    public function test_accepting_receiver_request_moves_booking_to_requester(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 416,
                'email' => 'owner-accept-qr@example.com',
                'username' => 'owneracceptqr',
                'fname' => 'Owner',
                'lname' => 'AcceptQr',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 417,
                'email' => 'requester-accept-qr@example.com',
                'username' => 'requesteracceptqr',
                'fname' => 'Requester',
                'lname' => 'AcceptQr',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            'id' => 9209,
            'customer_id' => 416,
            'event_id' => 1,
            'email' => 'owner-accept-qr@example.com',
            'phone' => '111',
            'is_transferable' => 1,
            'is_listed' => 0,
            'transfer_status' => null,
            'listing_price' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(416), [], 'sanctum');
        $qrResponse = app(MarketplaceController::class)->transferQr(9209);
        $qrPayload = $qrResponse->getData(true);

        Sanctum::actingAs(Customer::findOrFail(417), [], 'sanctum');
        $request = Request::create('/api/customers/transfers/request-from-scan', 'POST', [
            'transfer_token' => $qrPayload['data']['transfer_token'],
        ]);
        $transferResponse = app(MarketplaceController::class)->requestFromTicketScan($request);
        $transferPayload = $transferResponse->getData(true);

        Sanctum::actingAs(Customer::findOrFail(416), [], 'sanctum');
        $acceptResponse = app(MarketplaceController::class)->acceptTransfer($transferPayload['data']['transfer_id']);
        $acceptPayload = $acceptResponse->getData(true);

        $this->assertEquals(200, $acceptResponse->getStatusCode(), json_encode($acceptPayload));
        $this->assertTrue($acceptPayload['success']);
        $this->assertSame('Transfer approved. The ticket has been sent.', $acceptPayload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9209,
            'customer_id' => 417,
            'email' => 'requester-accept-qr@example.com',
            'transfer_status' => null,
        ]);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9209,
            'from_customer_id' => 417,
            'to_customer_id' => 416,
            'status' => 'accepted',
            'flow' => 'receiver_request',
        ]);
    }

    public function test_outbox_returns_only_user_initiated_transfers_and_excludes_marketplace_sales(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 470,
                'email' => 'starter@example.com',
                'username' => 'starter',
                'fname' => 'Start',
                'lname' => 'User',
                'phone' => '111',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 471,
                'email' => 'owner@example.com',
                'username' => 'ownerbox',
                'fname' => 'Owner',
                'lname' => 'Box',
                'phone' => '222',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 472,
                'email' => 'receiver@example.com',
                'username' => 'receiverbox',
                'fname' => 'Receiver',
                'lname' => 'Box',
                'phone' => '333',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('bookings')->insert([
            [
                'id' => 9210,
                'customer_id' => 470,
                'event_id' => 1,
                'email' => 'starter@example.com',
                'phone' => '111',
                'is_transferable' => 1,
                'is_listed' => 0,
                'transfer_status' => 'transfer_pending',
                'listing_price' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9211,
                'customer_id' => 471,
                'event_id' => 1,
                'email' => 'owner@example.com',
                'phone' => '222',
                'is_transferable' => 1,
                'is_listed' => 0,
                'transfer_status' => 'transfer_pending',
                'listing_price' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9212,
                'customer_id' => 470,
                'event_id' => 1,
                'email' => 'starter@example.com',
                'phone' => '111',
                'is_transferable' => 1,
                'is_listed' => 0,
                'transfer_status' => null,
                'listing_price' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_transfers')->insert([
            [
                'booking_id' => 9210,
                'from_customer_id' => 470,
                'to_customer_id' => 472,
                'notes' => 'Transfer request via Mobile App',
                'status' => 'pending',
                'flow' => 'owner_offer',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'booking_id' => 9211,
                'from_customer_id' => 470,
                'to_customer_id' => 471,
                'notes' => 'Transfer request via Ticket QR',
                'status' => 'pending',
                'flow' => 'receiver_request',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'booking_id' => 9212,
                'from_customer_id' => 470,
                'to_customer_id' => 472,
                'notes' => 'Marketplace Purchase',
                'status' => 'accepted',
                'flow' => 'owner_offer',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs(Customer::findOrFail(470), [], 'sanctum');

        $response = app(MarketplaceController::class)->outboxTransfers();
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode(), json_encode($payload));
        $this->assertTrue($payload['success']);
        $this->assertCount(2, $payload['data']);
        $this->assertSame('outgoing', $payload['data'][0]['direction']);
        $this->assertContains($payload['data'][0]['message_title'], ['Request sent', 'Transfer pending']);
        $this->assertContains($payload['data'][1]['message_title'], ['Request sent', 'Transfer pending']);
    }
}
