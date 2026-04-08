<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\PaymentMethod;
use App\Models\User;
use App\Models\Wallet;
use App\Services\WalletService;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class ActorScopeAndWalletServiceTest extends ActorFeatureTestCase
{
    protected WalletService $walletService;
    protected array $baselineSchema = ['users_customers', 'wallets', 'payment_methods'];
    protected array $baselineTruncate = [
        'wallet_transactions',
        'wallets',
        'payment_methods',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->walletService = app(WalletService::class);
    }

    public function test_wallet_service_separates_wallets_by_actor_type_and_id(): void
    {
        // Same numeric id across different actor tables should not share a wallet.
        DB::table('customers')->insert([
            'id' => 1,
            'email' => 'customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1,
            'email' => 'user@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1);
        $user = User::findOrFail(1);

        $this->walletService->credit($customer, 100, 'topup', 'c1', 'actor-customer-1');
        $this->walletService->credit($user, 50, 'topup', 'u1', 'actor-user-1');

        $customerWallet = Wallet::forActor($customer)->first();
        $userWallet = Wallet::forActor($user)->first();

        $this->assertNotNull($customerWallet);
        $this->assertNotNull($userWallet);
        $this->assertNotEquals($customerWallet->id, $userWallet->id);
        $this->assertEquals('customer', $customerWallet->actor_type);
        $this->assertEquals('user', $userWallet->actor_type);
        $this->assertEquals(100.0, (float) $customerWallet->balance);
        $this->assertEquals(50.0, (float) $userWallet->balance);
    }

    public function test_payment_method_scope_filters_by_actor(): void
    {
        DB::table('customers')->insert([
            'id' => 7,
            'email' => 'scope-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 7,
            'email' => 'scope-user@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('payment_methods')->insert([
            [
                'id' => '11111111-1111-4111-8111-111111111111',
                'user_id' => 7,
                'actor_type' => 'customer',
                'actor_id' => 7,
                'stripe_payment_method_id' => 'pm_customer_1',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '22222222-2222-4222-8222-222222222222',
                'user_id' => 7,
                'actor_type' => 'user',
                'actor_id' => 7,
                'stripe_payment_method_id' => 'pm_user_1',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $customer = Customer::findOrFail(7);
        $user = User::findOrFail(7);

        $customerMethods = PaymentMethod::forActor($customer)->pluck('stripe_payment_method_id')->all();
        $userMethods = PaymentMethod::forActor($user)->pluck('stripe_payment_method_id')->all();

        $this->assertEquals(['pm_customer_1'], $customerMethods);
        $this->assertEquals(['pm_user_1'], $userMethods);
    }

}
