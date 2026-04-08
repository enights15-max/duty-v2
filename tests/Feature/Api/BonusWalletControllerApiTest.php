<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\BonusWalletController;
use App\Models\Customer;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class BonusWalletControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'bonus_wallets'];
    protected array $baselineTruncate = ['bonus_transactions', 'bonus_wallets', 'customers'];

    public function test_customer_can_fetch_bonus_wallet_and_history(): void
    {
        DB::table('customers')->insert([
            'id' => 401,
            'email' => 'bonus-api@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => '40100000-0000-4000-8000-000000000001',
            'user_id' => 401,
            'actor_type' => 'customer',
            'actor_id' => 401,
            'balance' => 75.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_transactions')->insert([
            'id' => '40100000-0000-4000-8000-000000000101',
            'bonus_wallet_id' => '40100000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'amount' => 25.00,
            'reference_type' => 'reward_campaign',
            'reference_id' => 'campaign_1',
            'idempotency_key' => 'bonus_history_401',
            'status' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $walletRequest = Request::create('/api/customers/bonus-wallet', 'GET');
        $walletRequest->setUserResolver(fn () => Customer::findOrFail(401));
        $walletResponse = app(BonusWalletController::class)->getWallet($walletRequest);

        $historyRequest = Request::create('/api/customers/bonus-wallet/history', 'GET');
        $historyRequest->setUserResolver(fn () => Customer::findOrFail(401));
        $historyResponse = app(BonusWalletController::class)->getHistory($historyRequest);

        $walletPayload = $walletResponse->getData(true);
        $historyPayload = $historyResponse->getData(true);

        $this->assertTrue($walletPayload['success']);
        $this->assertIsNotString($walletPayload['wallet']['balance']);
        $this->assertSame(75, (int) $walletPayload['wallet']['balance']);
        $this->assertTrue($historyPayload['success']);
        $this->assertCount(1, $historyPayload['transactions']);
        $this->assertSame('reward_campaign', $historyPayload['transactions'][0]['reference_type']);
    }

    public function test_fetch_bonus_wallet_expires_due_balance_before_responding(): void
    {
        Carbon::setTestNow(now());

        DB::table('customers')->insert([
            'id' => 402,
            'email' => 'bonus-api-expired@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => '40200000-0000-4000-8000-000000000001',
            'user_id' => 402,
            'actor_type' => 'customer',
            'actor_id' => 402,
            'balance' => 35.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_transactions')->insert([
            'id' => '40200000-0000-4000-8000-000000000101',
            'bonus_wallet_id' => '40200000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'amount' => 35.00,
            'consumed_amount' => 0,
            'expired_amount' => 0,
            'reference_type' => 'loyalty_reward_bonus',
            'reference_id' => 'reward_402',
            'idempotency_key' => 'bonus_history_402',
            'status' => 'completed',
            'expires_at' => now()->subMinute(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $walletRequest = Request::create('/api/customers/bonus-wallet', 'GET');
        $walletRequest->setUserResolver(fn () => Customer::findOrFail(402));
        $walletResponse = app(BonusWalletController::class)->getWallet($walletRequest);
        $walletPayload = $walletResponse->getData(true);

        $this->assertTrue($walletPayload['success']);
        $this->assertIsNotString($walletPayload['wallet']['balance']);
        $this->assertSame(0, (int) $walletPayload['wallet']['balance']);
        $this->assertDatabaseHas('bonus_transactions', [
            'bonus_wallet_id' => '40200000-0000-4000-8000-000000000001',
            'reference_type' => 'bonus_expiration',
            'reference_id' => '40200000-0000-4000-8000-000000000101',
        ]);

        Carbon::setTestNow();
    }
}
