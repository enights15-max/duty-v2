<?php

namespace Tests\Feature;

use App\Http\Controllers\WebhookController;
use App\Models\Customer;
use App\Models\Identity;
use App\Models\PaymentMethod;
use App\Models\User;
use App\Services\ProfessionalBalanceService;
use App\Services\StripeService;
use App\Services\SubscriptionService;
use App\Services\WalletService;
use Closure;
use Illuminate\Support\Facades\DB;
use Mockery;
use ReflectionClass;
use Tests\Support\ActorFeatureTestCase;

class WebhookActorResolutionTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'payment_methods', 'identities', 'wallets'];
    protected array $baselineTruncate = [
        'payment_methods',
        'wallet_transactions',
        'wallets',
        'identity_balance_transactions',
        'identity_balances',
        'identity_members',
        'identities',
        'customers',
        'users',
    ];

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function test_resolve_actor_prefers_customer_for_customer_type(): void
    {
        DB::table('customers')->insert([
            'id' => 31,
            'email' => 'resolve-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 31,
            'email' => 'resolve-user@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->buildController();
        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('resolveActor');
        $method->setAccessible(true);

        $actor = $method->invoke($controller, 31, 'customer');

        $this->assertInstanceOf(Customer::class, $actor);
        $this->assertEquals(31, $actor->id);
    }

    public function test_handle_setup_intent_saves_payment_method_with_actor_fields(): void
    {
        DB::table('customers')->insert([
            'id' => 41,
            'email' => 'stripe-customer@example.com',
            'stripe_customer_id' => 'cus_actor_41',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->buildController();

        $setupIntent = (object) [
            'customer' => 'cus_actor_41',
            'payment_method' => 'pm_actor_41',
        ];

        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('handleSetupIntentSucceeded');
        $method->setAccessible(true);
        $method->invoke($controller, $setupIntent);

        $saved = PaymentMethod::where('stripe_payment_method_id', 'pm_actor_41')->first();

        $this->assertNotNull($saved);
        $this->assertEquals(41, (int) $saved->user_id);
        $this->assertEquals('customer', $saved->actor_type);
        $this->assertEquals(41, (int) $saved->actor_id);
        $this->assertEquals('visa', $saved->brand);
        $this->assertEquals('4242', $saved->last4);
    }

    public function test_handle_payment_intent_succeeded_uses_actor_metadata_and_credits_wallet(): void
    {
        DB::table('customers')->insert([
            'id' => 52,
            'email' => 'topup-actor@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->buildController(function ($walletService): void {
            $walletService->shouldReceive('credit')
                ->once()
                ->withArgs(function ($actor, float $amount, string $refType, string $refId, string $idempotencyKey, float $fee = 0, float $totalAmount = 0, ?array $meta = null): bool {
                    return $actor instanceof Customer
                        && (int) $actor->id === 52
                        && $amount === 125.75
                        && $refType === 'topup'
                        && $refId === 'pi_actor_topup_52'
                        && $idempotencyKey === 'TOPUP-pi_actor_topup_52'
                        && data_get($meta, 'gateway') === 'stripe'
                        && data_get($meta, 'gateway_family') === 'stripe_card'
                        && data_get($meta, 'requested_amount') === 125.75;
                });
        });

        $paymentIntent = (object) [
            'id' => 'pi_actor_topup_52',
            'amount' => 12575,
            'metadata' => (object) [
                'actor_id' => 52,
                'actor_type' => 'customer',
                'purpose' => 'topup',
                'requested_amount' => 125.75,
            ],
        ];

        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('handlePaymentIntentSucceeded');
        $method->setAccessible(true);
        $method->invoke($controller, $paymentIntent);

        $this->addToAssertionCount(1);
    }

    public function test_handle_payment_intent_succeeded_persists_topup_gateway_metadata_on_wallet_transaction(): void
    {
        DB::table('customers')->insert([
            'id' => 54,
            'email' => 'topup-history@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = new WebhookController(
            app(WalletService::class),
            Mockery::mock(ProfessionalBalanceService::class),
            Mockery::mock(StripeService::class),
            Mockery::mock(SubscriptionService::class)
        );

        $paymentIntent = (object) [
            'id' => 'pi_actor_topup_54',
            'amount' => 8880,
            'metadata' => (object) [
                'actor_id' => 54,
                'actor_type' => 'customer',
                'purpose' => 'topup',
                'requested_amount' => 88.8,
            ],
        ];

        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('handlePaymentIntentSucceeded');
        $method->setAccessible(true);
        $method->invoke($controller, $paymentIntent);

        $this->assertDatabaseHas('wallet_transactions', [
            'reference_type' => 'topup',
            'reference_id' => 'pi_actor_topup_54',
        ]);

        $meta = json_decode((string) DB::table('wallet_transactions')
            ->where('reference_id', 'pi_actor_topup_54')
            ->value('meta'), true);
        $this->assertSame('stripe', data_get($meta, 'gateway'));
        $this->assertSame('stripe_card', data_get($meta, 'gateway_family'));
        $this->assertSame('online_card_capture', data_get($meta, 'verification_strategy'));
        $this->assertEquals(88.8, (float) data_get($meta, 'requested_amount'));
    }

    public function test_handle_payment_intent_succeeded_credits_professional_identity_when_metadata_targets_profile(): void
    {
        DB::table('users')->insert([
            'id' => 53,
            'email' => 'artist-topup@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 53,
            'email' => 'artist-topup@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 953,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 53,
            'display_name' => 'Topup Artist',
            'slug' => 'topup-artist',
            'meta' => json_encode(['legacy_id' => 753]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $controller = $this->buildController(
            null,
            function ($professionalBalanceService): void {
                $professionalBalanceService->shouldReceive('creditArtistBalance')
                    ->once()
                    ->with(953, 753, 220.5)
                    ->andReturn([
                        'pre_balance' => 10.0,
                        'after_balance' => 230.5,
                    ]);
            }
        );

        $paymentIntent = (object) [
            'id' => 'pi_artist_topup_53',
            'amount' => 22050,
            'metadata' => (object) [
                'actor_id' => 53,
                'actor_type' => 'customer',
                'purpose' => 'topup',
                'requested_amount' => 220.5,
                'wallet_context' => 'professional',
                'identity_id' => 953,
            ],
        ];

        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('handlePaymentIntentSucceeded');
        $method->setAccessible(true);
        $method->invoke($controller, $paymentIntent);

        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 953,
            'type' => 'credit',
            'reference_type' => 'topup',
            'reference_id' => 'pi_artist_topup_53',
        ]);
        $meta = json_decode((string) DB::table('identity_balance_transactions')
            ->where('identity_id', 953)
            ->where('reference_id', 'pi_artist_topup_53')
            ->value('meta'), true);
        $this->assertSame('stripe', data_get($meta, 'gateway'));
        $this->assertSame('stripe_card', data_get($meta, 'gateway_family'));
    }

    private function buildController(?Closure $configureWalletMock = null, ?Closure $configureProfessionalBalanceMock = null): WebhookController
    {
        $walletService = Mockery::mock(WalletService::class);
        $professionalBalanceService = Mockery::mock(ProfessionalBalanceService::class);
        $subscriptionService = Mockery::mock(SubscriptionService::class);
        $stripeService = Mockery::mock(StripeService::class);

        if ($configureWalletMock) {
            $configureWalletMock($walletService);
        }

        if ($configureProfessionalBalanceMock) {
            $configureProfessionalBalanceMock($professionalBalanceService);
        }

        $stripeService->shouldReceive('retrievePaymentMethod')
            ->andReturn((object) [
                'card' => (object) [
                    'brand' => 'visa',
                    'last4' => '4242',
                    'exp_month' => 12,
                    'exp_year' => 2030,
                ],
            ]);

        return new WebhookController($walletService, $professionalBalanceService, $stripeService, $subscriptionService);
    }
}
