<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\MarketplaceController;
use App\Models\Customer;
use App\Services\NotificationService;
use App\Services\StripeService;
use App\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class MarketplacePurchaseActorTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'payment_methods', 'marketplace', 'loyalty', 'economy'];
    protected array $baselineTruncate = [
        'loyalty_point_transactions',
        'platform_revenue_events',
        'fee_policies',
        'payment_methods',
        'wallet_transactions',
        'wallets',
        'ticket_transfers',
        'bookings',
        'events',
        'basic_settings',
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

    public function test_marketplace_purchase_moves_funds_and_transfers_booking(): void
    {
        $this->seedFutureEvent(1);

        DB::table('customers')->insert([
            ['id' => 301, 'email' => 'buyer@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
            ['id' => 302, 'email' => 'seller@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('wallets')->insert([
            [
                'id' => '30100000-0000-4000-8000-000000000001',
                'user_id' => 301,
                'actor_type' => 'customer',
                'actor_id' => 301,
                'balance' => 150.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '30200000-0000-4000-8000-000000000001',
                'user_id' => 302,
                'actor_type' => 'customer',
                'actor_id' => 302,
                'balance' => 0.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'marketplace_commission' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9001,
            'customer_id' => 302,
            'event_id' => 1,
            'email' => 'seller@example.com',
            'phone' => '000000',
            'price' => 120.00,
            'quantity' => 1,
            'is_transferable' => 1,
            'is_listed' => 1,
            'listing_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $buyer = Customer::findOrFail(301);
        Sanctum::actingAs($buyer, [], 'sanctum');

        $response = app(MarketplaceController::class)->purchase(Request::create('/api/customers/marketplace/purchase/9001', 'POST'), 9001);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertEquals('Ticket purchased successfully!', $payload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9001,
            'customer_id' => 301,
            'is_listed' => 0,
            'listing_price' => '0.00',
        ]);

        $this->assertDatabaseHas('ticket_transfers', [
            'booking_id' => 9001,
            'from_customer_id' => 302,
            'to_customer_id' => 301,
            'status' => 'accepted',
            'flow' => 'marketplace_purchase',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'type' => 'debit',
            'amount' => '100.00',
            'reference_type' => 'Marketplace Purchase',
            'reference_id' => '9001',
            'idempotency_key' => 'MP_BUY_WALLET_marketplace_booking_9001_buyer_301',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'type' => 'credit',
            'amount' => '90.00',
            'reference_type' => 'Marketplace Sale',
            'reference_id' => '9001',
            'idempotency_key' => 'MP_SELL_marketplace_booking_9001_buyer_301',
        ]);
        $this->assertDatabaseHas('platform_revenue_events', [
            'operation_key' => 'marketplace_resale',
            'booking_id' => 9001,
            'actor_customer_id' => 301,
            'target_customer_id' => 302,
            'fee_amount' => '10.00',
            'net_amount' => '90.00',
        ]);
        $marketplaceDebitMeta = json_decode((string) DB::table('wallet_transactions')
            ->where('reference_type', 'Marketplace Purchase')
            ->where('reference_id', '9001')
            ->value('meta'), true);
        $this->assertSame('wallet', data_get($marketplaceDebitMeta, 'source_gateway'));
        $this->assertSame('mixed', data_get($marketplaceDebitMeta, 'requested_gateway'));

        $revenueMeta = json_decode((string) DB::table('platform_revenue_events')
            ->where('operation_key', 'marketplace_resale')
            ->where('booking_id', 9001)
            ->value('metadata'), true);
        $this->assertSame('mixed', data_get($revenueMeta, 'requested_gateway'));
        $this->assertSame('wallet', data_get($revenueMeta, 'gateway'));
        $this->assertSame('internal_balance', data_get($revenueMeta, 'gateway_family'));
        $this->assertDatabaseHas('loyalty_point_transactions', [
            'customer_id' => 301,
            'reference_type' => 'marketplace_booking',
            'reference_id' => '9001',
            'points' => 60,
        ]);
        $this->assertEquals('50.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 301)->value('balance'));
        $this->assertEquals('90.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 302)->value('balance'));
    }

    public function test_marketplace_purchase_rolls_back_on_seller_credit_failure(): void
    {
        $this->seedFutureEvent(1);

        DB::table('customers')->insert([
            ['id' => 311, 'email' => 'buyer-rollback@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
            ['id' => 312, 'email' => 'seller-rollback@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('wallets')->insert([
            [
                'id' => '31100000-0000-4000-8000-000000000001',
                'user_id' => 311,
                'actor_type' => 'customer',
                'actor_id' => 311,
                'balance' => 120.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '31200000-0000-4000-8000-000000000001',
                'user_id' => 312,
                'actor_type' => 'customer',
                'actor_id' => 312,
                'balance' => 5.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'marketplace_commission' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9002,
            'customer_id' => 312,
            'event_id' => 1,
            'email' => 'seller-rollback@example.com',
            'phone' => '000000',
            'price' => 120.00,
            'quantity' => 1,
            'is_transferable' => 1,
            'is_listed' => 1,
            'listing_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->app->bind(WalletService::class, function () {
            return new class extends WalletService {
                public function credit($actor, float $amount, string $refType, string $refId, string $idempotencyKey, float $fee = 0, float $totalAmount = 0, ?array $meta = null): \App\Models\WalletTransaction
                {
                    throw new \RuntimeException('Simulated seller credit failure');
                }
            };
        });

        Sanctum::actingAs(Customer::findOrFail(311), [], 'sanctum');

        $response = app(MarketplaceController::class)->purchase(Request::create('/api/customers/marketplace/purchase/9002', 'POST'), 9002);
        $payload = $response->getData(true);

        $this->assertEquals(500, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertStringContainsString('Simulated seller credit failure', $payload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9002,
            'customer_id' => 312,
            'is_listed' => 1,
            'listing_price' => '100.00',
        ]);

        $this->assertDatabaseCount('ticket_transfers', 0);
        $this->assertDatabaseCount('wallet_transactions', 0);
        $this->assertEquals('120.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 311)->value('balance'));
        $this->assertEquals('5.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 312)->value('balance'));
    }

    public function test_marketplace_purchase_refunds_captured_card_when_post_charge_flow_fails(): void
    {
        $this->seedFutureEvent(3);

        DB::table('customers')->insert([
            ['id' => 341, 'email' => 'buyer-card@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
            ['id' => 342, 'email' => 'seller-card@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('wallets')->insert([
            [
                'id' => '34100000-0000-4000-8000-000000000001',
                'user_id' => 341,
                'actor_type' => 'customer',
                'actor_id' => 341,
                'balance' => 0.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '34200000-0000-4000-8000-000000000001',
                'user_id' => 342,
                'actor_type' => 'customer',
                'actor_id' => 342,
                'balance' => 5.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'marketplace_commission' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9005,
            'customer_id' => 342,
            'event_id' => 3,
            'email' => 'seller-card@example.com',
            'phone' => '000000',
            'price' => 120.00,
            'quantity' => 1,
            'is_transferable' => 1,
            'is_listed' => 1,
            'listing_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->seedSavedPaymentMethod(341, 'pm_marketplace_9005');

        $stripeService = Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->with(
                Mockery::on(fn ($buyer) => $buyer instanceof Customer && (int) $buyer->id === 341),
                Mockery::on(fn ($amount) => abs((float) $amount - 121.05) < 0.001),
                'DOP',
                'Marketplace Purchase #9005',
                'pm_marketplace_9005',
                Mockery::on(fn (array $metadata) => ($metadata['purchase_source'] ?? null) === 'marketplace')
            )
            ->andReturn((object) ['id' => 'pi_marketplace_9005']);
        $stripeService->shouldReceive('refundPaymentIntent')
            ->once()
            ->with('pi_marketplace_9005', null, ['reason' => 'marketplace_purchase_failed'])
            ->andReturn((object) ['id' => 're_marketplace_9005']);
        $this->app->instance(StripeService::class, $stripeService);

        $this->app->bind(WalletService::class, function () {
            return new class extends WalletService {
                public function credit($actor, float $amount, string $refType, string $refId, string $idempotencyKey, float $fee = 0, float $totalAmount = 0, ?array $meta = null): \App\Models\WalletTransaction
                {
                    throw new \RuntimeException('Simulated seller credit failure after card capture');
                }
            };
        });

        Sanctum::actingAs(Customer::findOrFail(341), [], 'sanctum');

        $response = app(MarketplaceController::class)->purchase(
            Request::create('/api/customers/marketplace/purchase/9005', 'POST', [
                'apply_wallet_balance' => false,
                'stripe_payment_method_id' => 'pm_marketplace_9005',
            ]),
            9005
        );
        $payload = $response->getData(true);

        $this->assertEquals(500, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertStringContainsString('Simulated seller credit failure after card capture', $payload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 9005,
            'customer_id' => 342,
            'is_listed' => 1,
            'listing_price' => '100.00',
        ]);
        $this->assertDatabaseCount('ticket_transfers', 0);
        $this->assertDatabaseCount('wallet_transactions', 0);
        $this->assertEquals('0.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 341)->value('balance'));
        $this->assertEquals('5.00', DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 342)->value('balance'));
    }

    public function test_marketplace_purchase_preview_returns_wallet_summary_and_shortage(): void
    {
        $this->seedFutureEvent(1);

        DB::table('customers')->insert([
            ['id' => 321, 'email' => 'preview-buyer@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
            ['id' => 322, 'email' => 'preview-seller@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('wallets')->insert([
            [
                'id' => '32100000-0000-4000-8000-000000000001',
                'user_id' => 321,
                'actor_type' => 'customer',
                'actor_id' => 321,
                'balance' => 20.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '32200000-0000-4000-8000-000000000001',
                'user_id' => 322,
                'actor_type' => 'customer',
                'actor_id' => 322,
                'balance' => 0.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'marketplace_commission' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 9003,
            'customer_id' => 322,
            'event_id' => 1,
            'email' => 'preview-seller@example.com',
            'phone' => '000000',
            'price' => 150.00,
            'quantity' => 1,
            'is_transferable' => 1,
            'is_listed' => 1,
            'listing_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(321), [], 'sanctum');

        $response = app(MarketplaceController::class)->purchasePreview(
            Request::create('/api/customers/marketplace/purchase-preview/9003', 'GET'),
            9003
        );
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertFalse($payload['data']['can_purchase']);
        $this->assertEquals(20.0, $payload['data']['wallet_balance']);
        $this->assertEquals(120.0, $payload['data']['required_amount']);
        $this->assertEquals(100.0, $payload['data']['shortage_amount']);
        $this->assertEquals(120.0, $payload['data']['payment_summary']['total_to_pay']);
        $this->assertEquals(20.0, $payload['data']['payment_summary']['processing_fee']);
        $this->assertEquals(100.0, $payload['data']['payment_summary']['card_total_charge']);
        $this->assertSame('mixed', $payload['data']['payment_summary']['requested_gateway']);
        $this->assertSame('mixed', $payload['data']['payment_summary']['gateway']);
        $this->assertSame('stripe_card', $payload['data']['payment_summary']['gateway_family']);
        $this->assertSame('mixed_with_stripe_remainder', $payload['data']['payment_summary']['verification_strategy']);
        $this->assertEquals(90.0, $payload['data']['seller_summary']['net_amount']);
        $this->assertEquals(10.0, $payload['data']['seller_summary']['fee_amount']);
    }

    public function test_marketplace_purchase_preview_rejects_transfer_pending_listing(): void
    {
        $this->seedFutureEvent(2);

        DB::table('customers')->insert([
            ['id' => 331, 'email' => 'pending-buyer@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
            ['id' => 332, 'email' => 'pending-seller@example.com', 'password' => bcrypt('secret'), 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('bookings')->insert([
            'id' => 9004,
            'customer_id' => 332,
            'event_id' => 2,
            'email' => 'pending-seller@example.com',
            'phone' => '000000',
            'paymentStatus' => 'completed',
            'price' => 140.00,
            'quantity' => 1,
            'is_transferable' => 1,
            'is_listed' => 1,
            'transfer_status' => 'transfer_pending',
            'listing_price' => 100.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(331), [], 'sanctum');

        $response = app(MarketplaceController::class)->purchasePreview(
            Request::create('/api/customers/marketplace/purchase-preview/9004', 'GET'),
            9004
        );
        $payload = $response->getData(true);

        $this->assertEquals(404, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertSame('Ticket no longer available.', $payload['message']);
    }

    private function seedFutureEvent(int $id): void
    {
        DB::table('events')->insert([
            'id' => $id,
            'title' => 'Marketplace Event ' . $id,
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedSavedPaymentMethod(int $customerId, string $paymentMethodId): void
    {
        DB::table('payment_methods')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000099', $customerId),
            'user_id' => $customerId,
            'actor_type' => 'customer',
            'actor_id' => $customerId,
            'stripe_payment_method_id' => $paymentMethodId,
            'brand' => 'visa',
            'last4' => '4242',
            'exp_month' => '12',
            'exp_year' => '2030',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
