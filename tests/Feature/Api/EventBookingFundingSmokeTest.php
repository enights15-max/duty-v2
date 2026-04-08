<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventController;
use App\Models\BonusWallet;
use App\Models\Customer;
use App\Models\TicketTransfer;
use App\Models\Wallet;
use App\Services\BonusWalletService;
use App\Services\CheckoutFundingAllocatorService;
use App\Services\EventBookingGuardService;
use App\Services\NotificationService;
use App\Services\WalletService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class EventBookingFundingSmokeTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'economy'];
    protected array $baselineTruncate = [
        'platform_revenue_events',
        'fee_policies',
        'transactions',
        'organizers',
        'identity_balances',
        'earnings',
        'bookings',
        'tickets',
        'events',
        'identities',
        'identity_members',
        'basic_settings',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        Queue::fake();
        $this->ensureEventBookingTables();
    }

    public function test_store_booking_supports_bonus_only_funding_without_card(): void
    {
        $customer = $this->seedCustomer(1701, 'booking-bonus-only@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'bonus',
                'mode' => 'bonus',
                'payment_method' => 'bonus',
                'wallet_amount' => 0.0,
                'bonus_amount' => 100.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'bonus']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'bonus',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_bonus_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertSame('bonus', $payload['payment_summary']['mode']);
        $this->assertEquals(100.0, $payload['payment_summary']['bonus_amount']);
        $this->assertEquals(0.0, $payload['payment_summary']['wallet_amount']);
        $this->assertEquals(0.0, $payload['payment_summary']['card_amount']);
        $this->assertFalse($payload['payment_summary']['requires_card']);
    }

    public function test_store_booking_supports_wallet_only_funding_without_card(): void
    {
        $customer = $this->seedCustomer(1702, 'booking-wallet-only@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertSame('wallet', $payload['payment_summary']['mode']);
        $this->assertEquals(100.0, $payload['payment_summary']['wallet_amount']);
        $this->assertEquals(0.0, $payload['payment_summary']['bonus_amount']);
        $this->assertEquals(0.0, $payload['payment_summary']['card_amount']);
        $this->assertFalse($payload['payment_summary']['requires_card']);
    }

    public function test_store_booking_supports_bonus_and_wallet_without_card_when_total_is_fully_covered(): void
    {
        $customer = $this->seedCustomer(1703, 'booking-mixed-internal@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'mixed',
                'mode' => 'mixed',
                'payment_method' => 'mixed',
                'wallet_amount' => 70.0,
                'bonus_amount' => 30.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'mixed_internal']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'mixed',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
            'apply_bonus_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertSame('mixed', $payload['payment_summary']['mode']);
        $this->assertEquals(70.0, $payload['payment_summary']['wallet_amount']);
        $this->assertEquals(30.0, $payload['payment_summary']['bonus_amount']);
        $this->assertEquals(0.0, $payload['payment_summary']['card_amount']);
        $this->assertFalse($payload['payment_summary']['requires_card']);
        $this->assertTrue($payload['payment_summary']['is_fully_covered']);
    }

    public function test_store_booking_persists_organizer_identity_id_from_identity_owned_event(): void
    {
        $customer = $this->seedCustomer(1704, 'booking-identity-owned@example.com');
        $eventId = $this->seedEventWithTicket([
            'owner_identity_id' => 601,
            'organizer_id' => null,
        ]);

        DB::table('identities')->insert([
            'id' => 601,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1704,
            'display_name' => 'Identity Owned Organizer',
            'slug' => 'identity-owned-organizer',
            'meta' => json_encode([]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertDatabaseHas('bookings', [
            'customer_id' => $customer->id,
            'event_id' => $eventId,
            'organizer_identity_id' => 601,
        ]);
    }

    public function test_store_booking_notifies_customer_actor_even_without_matching_user_record(): void
    {
        $customer = $this->seedCustomerWithoutUser(1705, 'booking-customer-only@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet'],
            function ($notificationService) use ($customer): void {
                $notificationService->shouldReceive('notifyUser')
                    ->once()
                    ->with(
                        Mockery::on(fn ($actor) => $actor instanceof Customer && (int) $actor->id === (int) $customer->id),
                        Mockery::type('string'),
                        Mockery::type('string')
                    )
                    ->andReturnTrue();
            }
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertDatabaseHas('bookings', [
            'customer_id' => $customer->id,
            'event_id' => $eventId,
        ]);
    }

    public function test_store_booking_response_includes_thumbnail_and_total_for_ticket_success_screen(): void
    {
        $customer = $this->seedCustomer(1706, 'booking-success-screen@example.com');
        $eventId = $this->seedEventWithTicket([
            'title' => 'Visual Payload Event',
            'thumbnail' => 'visual-payload.jpg',
            'venue_name_snapshot' => 'Demo Venue',
        ]);

        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertSame('Visual Payload Event', $payload['booking_info']['event_title'] ?? null);
        $this->assertSame('Demo Venue', $payload['booking_info']['venue_name'] ?? null);
        $this->assertSame('100.00', $payload['booking_info']['total_paid'] ?? null);
        $this->assertStringContainsString(
            'assets/admin/img/event/thumbnail/visual-payload.jpg',
            (string) ($payload['booking_info']['thumbnail'] ?? '')
        );
    }

    public function test_store_booking_records_platform_revenue_event_for_primary_sale(): void
    {
        $customer = $this->seedCustomer(1716, 'booking-fee-ledger@example.com');
        $eventId = $this->seedEventWithTicket();
        DB::table('basic_settings')->where('id', 1)->update([
            'commission' => 10,
        ]);

        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);
        $bookingId = (int) DB::table('bookings')
            ->where('customer_id', $customer->id)
            ->where('event_id', $eventId)
            ->value('id');

        $this->assertTrue($payload['status']);
        $this->assertDatabaseHas('platform_revenue_events', [
            'operation_key' => 'primary_ticket_sale',
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'actor_customer_id' => $customer->id,
            'gross_amount' => '100.00',
            'fee_amount' => '10.00',
            'net_amount' => '90.00',
        ]);
    }

    public function test_store_booking_creates_pending_transfer_for_assigned_friend_ticket(): void
    {
        $buyer = $this->seedCustomer(1707, 'booking-gift-buyer@example.com');
        $recipient = $this->seedCustomer(1708, 'booking-gift-friend@example.com');
        $eventId = $this->seedEventWithTicket();

        $controller = $this->makeController(
            $buyer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 200.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 200.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet'],
            function ($notificationService): void {
                $notificationService->shouldReceive('notifyUser')
                    ->twice()
                    ->andReturnTrue();
            }
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
            'quantity' => 2,
            'total' => 200,
            'ticket_recipients' => [
                [
                    'slot_key' => '1:2',
                    'ticket_id' => 1,
                    'unit_index' => 2,
                    'recipient_id' => $recipient->id,
                ],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertSame(1, $payload['gift_transfers_created']);
        $this->assertDatabaseCount('bookings', 2);

        $transfer = TicketTransfer::query()->first();
        $this->assertNotNull($transfer);
        $this->assertSame($buyer->id, (int) $transfer->from_customer_id);
        $this->assertSame($recipient->id, (int) $transfer->to_customer_id);
        $this->assertSame('pending', $transfer->status);

        $this->assertDatabaseHas('bookings', [
            'id' => $transfer->booking_id,
            'customer_id' => $buyer->id,
            'transfer_status' => 'transfer_pending',
        ]);
    }

    public function test_store_booking_assigns_gift_to_the_selected_variation_slot_when_same_ticket_has_multiple_rows(): void
    {
        $buyer = $this->seedCustomer(1721, 'booking-variation-gift-buyer@example.com');
        $recipient = $this->seedCustomer(1722, 'booking-variation-gift-recipient@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'title' => 'Access',
            'pricing_type' => 'variation',
            'price' => 0,
            'variations' => json_encode([
                [
                    'name' => 'VIP',
                    'price' => 150,
                    'ticket_available_type' => 'limited',
                    'ticket_available' => 10,
                ],
                [
                    'name' => 'General',
                    'price' => 50,
                    'ticket_available_type' => 'limited',
                    'ticket_available' => 10,
                ],
            ]),
        ]);

        $controller = $this->makeController(
            $buyer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 200.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 200.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet'],
            function ($notificationService): void {
                $notificationService->shouldReceive('notifyUser')
                    ->twice()
                    ->andReturnTrue();
            }
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
            'quantity' => 2,
            'total' => 200,
            'selTickets' => [
                [
                    'ticket_id' => 1,
                    'name' => 'VIP',
                    'qty' => 1,
                    'price' => 150,
                    'early_bird_dicount' => 0,
                ],
                [
                    'ticket_id' => 1,
                    'name' => 'General',
                    'qty' => 1,
                    'price' => 50,
                    'early_bird_dicount' => 0,
                ],
            ],
            'ticket_recipients' => [
                [
                    'slot_key' => '1:2:1',
                    'ticket_id' => 1,
                    'unit_index' => 1,
                    'recipient_id' => $recipient->id,
                ],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['status']);
        $this->assertSame(1, $payload['gift_transfers_created']);

        $transfer = TicketTransfer::query()->first();
        $this->assertNotNull($transfer);

        $giftBooking = DB::table('bookings')->where('id', $transfer->booking_id)->first();
        $this->assertNotNull($giftBooking);
        $giftVariation = json_decode((string) $giftBooking->variation, true);
        $this->assertSame('General', $giftVariation[0]['name'] ?? null);
    }

    public function test_store_booking_rejects_ambiguous_legacy_slot_keys_for_mixed_variations_of_same_ticket(): void
    {
        $buyer = $this->seedCustomer(1723, 'booking-variation-ambiguous-buyer@example.com');
        $recipient = $this->seedCustomer(1724, 'booking-variation-ambiguous-recipient@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'title' => 'Access',
            'pricing_type' => 'variation',
            'price' => 0,
            'variations' => json_encode([
                [
                    'name' => 'VIP',
                    'price' => 150,
                    'ticket_available_type' => 'limited',
                    'ticket_available' => 10,
                ],
                [
                    'name' => 'General',
                    'price' => 50,
                    'ticket_available_type' => 'limited',
                    'ticket_available' => 10,
                ],
            ]),
        ]);

        $walletService = Mockery::mock(WalletService::class);
        $bonusWalletService = Mockery::mock(BonusWalletService::class);
        $guardService = Mockery::mock(EventBookingGuardService::class);
        $guardService->shouldReceive('resolveAuthenticatedBookingCustomer')
            ->once()
            ->andReturn(['authCustomer' => $buyer]);
        $guardService->shouldReceive('validateEventDateWindow')
            ->once()
            ->andReturn(null);

        $notificationService = Mockery::mock(NotificationService::class);

        $controller = new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
            notificationService: $notificationService,
            eventBookingGuardService: $guardService
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'quantity' => 2,
            'total' => 200,
            'selTickets' => [
                [
                    'ticket_id' => 1,
                    'name' => 'VIP',
                    'qty' => 1,
                    'price' => 150,
                    'early_bird_dicount' => 0,
                ],
                [
                    'ticket_id' => 1,
                    'name' => 'General',
                    'qty' => 1,
                    'price' => 50,
                    'early_bird_dicount' => 0,
                ],
            ],
            'ticket_recipients' => [
                [
                    'slot_key' => '1:1',
                    'ticket_id' => 1,
                    'unit_index' => 1,
                    'recipient_id' => $recipient->id,
                ],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(422, $response->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertSame('ticket_recipient_assignment_ambiguous', $payload['error_type']);
        $this->assertDatabaseCount('bookings', 0);
        $this->assertDatabaseCount('ticket_transfers', 0);
    }

    public function test_store_booking_blocks_purchase_when_customer_exceeds_ticket_limit(): void
    {
        $customer = $this->seedCustomer(1709, 'booking-limit@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 2,
        ]);

        DB::table('bookings')->insert([
            'customer_id' => $customer->id,
            'booking_id' => 'existing-limit-booking',
            'order_number' => 'existing-order',
            'event_id' => $eventId,
            'ticket_id' => 1,
            'fname' => 'Limit',
            'lname' => 'Buyer',
            'email' => 'booking-limit@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'price' => 100,
            'quantity' => 1,
            'paymentMethod' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'event_date' => now()->toDateString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $walletService = Mockery::mock(WalletService::class);
        $bonusWalletService = Mockery::mock(BonusWalletService::class);
        $guardService = Mockery::mock(EventBookingGuardService::class);
        $guardService->shouldReceive('resolveAuthenticatedBookingCustomer')
            ->once()
            ->andReturn(['authCustomer' => $customer]);
        $guardService->shouldReceive('validateEventDateWindow')
            ->once()
            ->andReturn(null);
        $guardService->shouldReceive('validateEventAgeRestriction')
            ->once()
            ->andReturn(null);

        $controller = new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
            notificationService: Mockery::mock(NotificationService::class),
            eventBookingGuardService: $guardService
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'quantity' => 2,
            'total' => 200,
            'selTickets' => [
                ['ticket_id' => 1, 'qty' => 2],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(422, $response->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertSame('purchase_limit_reached', $payload['error_type']);
        $this->assertStringContainsString('solo puede recibir 1 entrada(s) más', strtolower($payload['message']));
        $this->assertDatabaseCount('bookings', 1);
    }

    public function test_store_booking_allows_buyer_to_purchase_beyond_personal_limit_when_ticket_is_assigned_to_friend(): void
    {
        $buyer = $this->seedCustomer(1711, 'booking-limit-gift-buyer@example.com');
        $recipient = $this->seedCustomer(1712, 'booking-limit-gift-recipient@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 2,
        ]);

        DB::table('bookings')->insert([
            'customer_id' => $buyer->id,
            'booking_id' => 'buyer-limit-1',
            'order_number' => 'buyer-limit-1',
            'event_id' => $eventId,
            'ticket_id' => 1,
            'fname' => 'Limit',
            'lname' => 'Buyer',
            'email' => 'booking-limit-gift-buyer@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'price' => 100,
            'quantity' => 2,
            'paymentMethod' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'event_date' => now()->toDateString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->makeController(
            $buyer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet'],
            function ($notificationService): void {
                $notificationService->shouldReceive('notifyUser')
                    ->twice()
                    ->andReturnTrue();
            }
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
            'quantity' => 1,
            'total' => 100,
            'ticket_recipients' => [
                [
                    'slot_key' => '1:1',
                    'ticket_id' => 1,
                    'unit_index' => 1,
                    'recipient_id' => $recipient->id,
                ],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['status']);
        $this->assertSame(1, $payload['gift_transfers_created']);
        $this->assertDatabaseHas('ticket_transfers', [
            'to_customer_id' => $recipient->id,
            'status' => 'pending',
        ]);
    }

    public function test_store_booking_blocks_purchase_when_recipient_pending_gift_already_consumes_ticket_limit(): void
    {
        $buyer = $this->seedCustomer(1713, 'booking-limit-pending-buyer@example.com');
        $donor = $this->seedCustomer(1714, 'booking-limit-pending-donor@example.com');
        $recipient = $this->seedCustomer(1715, 'booking-limit-pending-recipient@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 1,
        ]);

        $pendingBookingId = DB::table('bookings')->insertGetId([
            'customer_id' => $donor->id,
            'booking_id' => 'pending-gift-booking',
            'order_number' => 'pending-gift-booking',
            'event_id' => $eventId,
            'ticket_id' => 1,
            'fname' => 'Pending',
            'lname' => 'Donor',
            'email' => 'booking-limit-pending-donor@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'price' => 100,
            'quantity' => 1,
            'paymentMethod' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'transfer_status' => 'transfer_pending',
            'event_date' => now()->toDateString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_transfers')->insert([
            'booking_id' => $pendingBookingId,
            'from_customer_id' => $donor->id,
            'to_customer_id' => $recipient->id,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $walletService = Mockery::mock(WalletService::class);
        $bonusWalletService = Mockery::mock(BonusWalletService::class);
        $guardService = Mockery::mock(EventBookingGuardService::class);
        $guardService->shouldReceive('resolveAuthenticatedBookingCustomer')
            ->once()
            ->andReturn(['authCustomer' => $buyer]);
        $guardService->shouldReceive('validateEventDateWindow')
            ->once()
            ->andReturn(null);
        $guardService->shouldReceive('validateEventAgeRestriction')
            ->once()
            ->andReturn(null);

        $controller = new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
            notificationService: Mockery::mock(NotificationService::class),
            eventBookingGuardService: $guardService
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'quantity' => 1,
            'total' => 100,
            'ticket_recipients' => [
                [
                    'slot_key' => '1:1',
                    'ticket_id' => 1,
                    'unit_index' => 1,
                    'recipient_id' => $recipient->id,
                ],
            ],
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(422, $response->getStatusCode());
        $this->assertFalse($payload['status']);
        $this->assertSame('purchase_limit_reached', $payload['error_type']);
        $this->assertStringContainsString('ya alcanzó el máximo', strtolower($payload['message']));
    }

    public function test_store_booking_does_not_count_receiver_request_transfers_against_final_holder_purchase_limit(): void
    {
        $buyer = $this->seedCustomer(1717, 'booking-limit-receiver-request-buyer@example.com');
        $owner = $this->seedCustomer(1718, 'booking-limit-receiver-request-owner@example.com');
        $eventId = $this->seedEventWithTicket();

        DB::table('tickets')->where('id', 1)->update([
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 1,
        ]);

        $pendingBookingId = DB::table('bookings')->insertGetId([
            'customer_id' => $owner->id,
            'booking_id' => 'receiver-request-booking',
            'order_number' => 'receiver-request-booking',
            'event_id' => $eventId,
            'ticket_id' => 1,
            'fname' => 'Owner',
            'lname' => 'Customer',
            'email' => 'booking-limit-receiver-request-owner@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'price' => 100,
            'quantity' => 1,
            'paymentMethod' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'transfer_status' => 'transfer_pending',
            'event_date' => now()->toDateString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_transfers')->insert([
            'booking_id' => $pendingBookingId,
            'from_customer_id' => $buyer->id,
            'to_customer_id' => $owner->id,
            'status' => 'pending',
            'flow' => 'receiver_request',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->makeController(
            $buyer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
            'quantity' => 1,
            'total' => 100,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['status']);
        $this->assertDatabaseCount('bookings', 2);
    }

    public function test_store_booking_persists_ticket_id_for_future_purchase_limit_checks(): void
    {
        $customer = $this->seedCustomer(1710, 'booking-ticket-id@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController(
            $customer,
            [
                'gateway' => 'wallet',
                'mode' => 'wallet',
                'payment_method' => 'wallet',
                'wallet_amount' => 100.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ],
            ['internal_capture' => 'wallet']
        );

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
            'apply_wallet_balance' => true,
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertDatabaseHas('bookings', [
            'customer_id' => $customer->id,
            'event_id' => $eventId,
            'ticket_id' => 1,
        ]);
    }

    private function makeController(Customer $customer, array $fundingPlan, array $paymentCapture, ?callable $configureNotification = null): EventController
    {
        $walletService = Mockery::mock(WalletService::class);
        $walletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(Mockery::type(Customer::class))
            ->andReturn(new Wallet(['balance' => 100.0]));

        $bonusWalletService = Mockery::mock(BonusWalletService::class);
        $bonusWalletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(Mockery::type(Customer::class))
            ->andReturn(new BonusWallet(['balance' => 100.0]));

        $guardService = Mockery::mock(EventBookingGuardService::class);
        $guardService->shouldReceive('resolveAuthenticatedBookingCustomer')
            ->once()
            ->andReturn(['authCustomer' => $customer]);
        $guardService->shouldReceive('validateEventDateWindow')
            ->once()
            ->andReturn(null);
        $guardService->shouldReceive('validateEventAgeRestriction')
            ->once()
            ->andReturn(null);

        $allocator = Mockery::mock(CheckoutFundingAllocatorService::class);
        $allocator->shouldReceive('allocate')
            ->once()
            ->andReturn($fundingPlan);

        $bookingFundingService = Mockery::mock(\App\Services\BookingFundingService::class);
        $bookingFundingService->shouldReceive('captureForBookings')
            ->once()
            ->andReturn($paymentCapture);

        $notificationService = Mockery::mock(NotificationService::class);
        if ($configureNotification) {
            $configureNotification($notificationService);
        } else {
            $notificationService->shouldReceive('notifyUser')
                ->once()
                ->andReturnNull();
        }

        return new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
            stripeService: Mockery::mock(\App\Services\StripeService::class),
            notificationService: $notificationService,
            eventBookingGuardService: $guardService,
            checkoutFundingAllocatorService: $allocator,
            bookingFundingService: $bookingFundingService
        );
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
            'fname' => 'Test',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedCustomerWithoutUser(int $id, string $email): Customer
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => $email,
            'fname' => 'Test',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedEventWithTicket(array $eventOverrides = []): int
    {
        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'commission' => 0,
            'tax' => 0,
            'base_currency_symbol' => 'RD$',
            'base_currency_symbol_position' => 'left',
            'base_currency_text' => 'DOP',
            'base_currency_text_position' => 'left',
            'base_currency_rate' => 1,
            'how_ticket_will_be_send' => 'delay',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        if (!DB::table('earnings')->exists()) {
            DB::table('earnings')->insert([
                'id' => 1,
                'total_revenue' => 0,
                'total_earning' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $eventId = (int) DB::table('events')->insertGetId(array_merge([
            'organizer_id' => null,
            'owner_identity_id' => null,
            'title' => 'Funding Smoke Event',
            'event_type' => 'offline',
            'start_date' => now()->toDateString(),
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ], $eventOverrides));

        DB::table('tickets')->insert([
            'id' => 1,
            'event_id' => $eventId,
            'title' => 'General',
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 10,
            'price' => 100,
            'max_ticket_buy_type' => 'unlimited',
            'max_buy_ticket' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function validPayload(int $eventId, array $overrides = []): array
    {
        return array_merge([
            'fname' => 'Test',
            'lname' => 'User',
            'email' => 'test@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'event_id' => $eventId,
            'gateway' => 'wallet',
            'gatewayType' => 'online',
            'quantity' => 1,
            'event_date' => now()->toDateString(),
            'total' => 100,
            'discount' => 0,
            'tax' => 0,
            'total_early_bird_dicount' => 0,
        ], $overrides);
    }

    private function ensureEventBookingTables(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('uniqid')->nullable();
                $table->decimal('commission', 10, 2)->default(0);
                $table->decimal('tax', 10, 2)->default(0);
                $table->string('base_currency_symbol')->nullable();
                $table->string('base_currency_symbol_position')->nullable();
                $table->string('base_currency_text')->nullable();
                $table->string('base_currency_text_position')->nullable();
                $table->decimal('base_currency_rate', 10, 2)->default(1);
                $table->string('how_ticket_will_be_send')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_transfers')) {
            Schema::create('ticket_transfers', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('booking_id');
                $table->unsignedBigInteger('from_customer_id');
                $table->unsignedBigInteger('to_customer_id');
                $table->string('status')->default('pending');
                $table->string('flow')->nullable();
                $table->text('notes')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'uniqid' => fn (Blueprint $table) => $table->unsignedBigInteger('uniqid')->nullable(),
            'commission' => fn (Blueprint $table) => $table->decimal('commission', 10, 2)->default(0),
            'tax' => fn (Blueprint $table) => $table->decimal('tax', 10, 2)->default(0),
            'base_currency_symbol' => fn (Blueprint $table) => $table->string('base_currency_symbol')->nullable(),
            'base_currency_symbol_position' => fn (Blueprint $table) => $table->string('base_currency_symbol_position')->nullable(),
            'base_currency_text' => fn (Blueprint $table) => $table->string('base_currency_text')->nullable(),
            'base_currency_text_position' => fn (Blueprint $table) => $table->string('base_currency_text_position')->nullable(),
            'base_currency_rate' => fn (Blueprint $table) => $table->decimal('base_currency_rate', 10, 2)->default(1),
            'how_ticket_will_be_send' => fn (Blueprint $table) => $table->string('how_ticket_will_be_send')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('basic_settings', $column)) {
                Schema::table('basic_settings', $definition);
            }
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('title')->nullable();
                $table->string('event_type')->nullable();
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('earnings')) {
            Schema::create('earnings', function (Blueprint $table): void {
                $table->id();
                $table->decimal('total_revenue', 15, 2)->default(0);
                $table->decimal('total_earning', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('admins')) {
            Schema::create('admins', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->string('payment_status')->nullable();
                $table->string('payment_method')->nullable();
                $table->decimal('grand_total', 15, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->decimal('commission', 15, 2)->default(0);
                $table->decimal('pre_balance', 15, 2)->default(0);
                $table->decimal('after_balance', 15, 2)->nullable();
                $table->string('gateway_type')->nullable();
                $table->string('currency_symbol')->nullable();
                $table->string('currency_symbol_position')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('transactions', 'organizer_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
            });
        }

        if (!Schema::hasColumn('transactions', 'venue_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('venue_id')->nullable();
            });
        }

        if (!Schema::hasColumn('transactions', 'venue_identity_id')) {
            Schema::table('transactions', function (Blueprint $table): void {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
            });
        }

        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_balances')) {
            Schema::create('identity_balances', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('identity_id')->unique();
                $table->string('legacy_type')->nullable();
                $table->unsignedBigInteger('legacy_id')->nullable();
                $table->decimal('balance', 15, 2)->default(0);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'venue_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_id')->nullable(),
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
            'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
            'start_date' => fn (Blueprint $table) => $table->date('start_date')->nullable(),
            'venue_name_snapshot' => fn (Blueprint $table) => $table->string('venue_name_snapshot')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('title')->nullable();
                $table->string('pricing_type')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->default(0);
                $table->decimal('price', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        foreach ([
            'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
            'title' => fn (Blueprint $table) => $table->string('title')->nullable(),
            'pricing_type' => fn (Blueprint $table) => $table->string('pricing_type')->nullable(),
            'ticket_available_type' => fn (Blueprint $table) => $table->string('ticket_available_type')->nullable(),
            'ticket_available' => fn (Blueprint $table) => $table->integer('ticket_available')->default(0),
            'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->default(0),
            'variations' => fn (Blueprint $table) => $table->longText('variations')->nullable(),
            'max_ticket_buy_type' => fn (Blueprint $table) => $table->string('max_ticket_buy_type')->nullable(),
            'max_buy_ticket' => fn (Blueprint $table) => $table->integer('max_buy_ticket')->default(0),
        ] as $column => $definition) {
            if (!Schema::hasColumn('tickets', $column)) {
                Schema::table('tickets', $definition);
            }
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('city')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('address')->nullable();
                $table->longText('variation')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('tax_percentage', 10, 2)->default(0);
                $table->decimal('commission_percentage', 10, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->decimal('commission', 15, 2)->default(0);
                $table->integer('quantity')->default(1);
                $table->decimal('discount', 15, 2)->default(0);
                $table->decimal('early_bird_discount', 15, 2)->default(0);
                $table->string('currencyText')->nullable();
                $table->string('currencyTextPosition')->nullable();
                $table->string('currencySymbol')->nullable();
                $table->string('currencySymbolPosition')->nullable();
                $table->string('paymentMethod')->nullable();
                $table->string('gatewayType')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->string('invoice')->nullable();
                $table->string('attachmentFile')->nullable();
                $table->date('event_date')->nullable();
                $table->unsignedBigInteger('conversation_id')->nullable();
                $table->string('fcm_token')->nullable();
                $table->integer('scan_status')->default(0);
                $table->string('transfer_status')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('bookings', 'transcation_type')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->integer('transcation_type')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'transfer_status')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('transfer_status')->nullable();
            });
        }

        foreach ([
            'booking_id' => fn (Blueprint $table) => $table->string('booking_id')->nullable(),
            'order_number' => fn (Blueprint $table) => $table->string('order_number')->nullable(),
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'organizer_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_identity_id')->nullable(),
            'ticket_id' => fn (Blueprint $table) => $table->unsignedBigInteger('ticket_id')->nullable(),
            'country' => fn (Blueprint $table) => $table->string('country')->nullable(),
            'state' => fn (Blueprint $table) => $table->string('state')->nullable(),
            'city' => fn (Blueprint $table) => $table->string('city')->nullable(),
            'zip_code' => fn (Blueprint $table) => $table->string('zip_code')->nullable(),
            'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
            'tax_percentage' => fn (Blueprint $table) => $table->decimal('tax_percentage', 10, 2)->default(0),
            'commission_percentage' => fn (Blueprint $table) => $table->decimal('commission_percentage', 10, 2)->default(0),
            'tax' => fn (Blueprint $table) => $table->decimal('tax', 15, 2)->default(0),
            'commission' => fn (Blueprint $table) => $table->decimal('commission', 15, 2)->default(0),
            'discount' => fn (Blueprint $table) => $table->decimal('discount', 15, 2)->default(0),
            'early_bird_discount' => fn (Blueprint $table) => $table->decimal('early_bird_discount', 15, 2)->default(0),
            'currencyText' => fn (Blueprint $table) => $table->string('currencyText')->nullable(),
            'currencyTextPosition' => fn (Blueprint $table) => $table->string('currencyTextPosition')->nullable(),
            'currencySymbol' => fn (Blueprint $table) => $table->string('currencySymbol')->nullable(),
            'currencySymbolPosition' => fn (Blueprint $table) => $table->string('currencySymbolPosition')->nullable(),
            'paymentMethod' => fn (Blueprint $table) => $table->string('paymentMethod')->nullable(),
            'gatewayType' => fn (Blueprint $table) => $table->string('gatewayType')->nullable(),
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'invoice' => fn (Blueprint $table) => $table->string('invoice')->nullable(),
            'attachmentFile' => fn (Blueprint $table) => $table->string('attachmentFile')->nullable(),
            'event_date' => fn (Blueprint $table) => $table->date('event_date')->nullable(),
            'conversation_id' => fn (Blueprint $table) => $table->unsignedBigInteger('conversation_id')->nullable(),
            'fcm_token' => fn (Blueprint $table) => $table->string('fcm_token')->nullable(),
            'scan_status' => fn (Blueprint $table) => $table->integer('scan_status')->default(0),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }
    }
}
