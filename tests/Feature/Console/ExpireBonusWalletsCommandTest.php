<?php

namespace Tests\Feature\Console;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class ExpireBonusWalletsCommandTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'bonus_wallets'];
    protected array $baselineTruncate = ['bonus_transactions', 'bonus_wallets', 'customers'];

    public function test_command_expires_due_bonus_credits(): void
    {
        Carbon::setTestNow(now());

        DB::table('customers')->insert([
            'id' => 901,
            'email' => 'bonus-command@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => '90100000-0000-4000-8000-000000000001',
            'user_id' => 901,
            'actor_type' => 'customer',
            'actor_id' => 901,
            'balance' => 60.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_transactions')->insert([
            'id' => '90100000-0000-4000-8000-000000000101',
            'bonus_wallet_id' => '90100000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'amount' => 60.00,
            'consumed_amount' => 0,
            'expired_amount' => 0,
            'reference_type' => 'loyalty_reward_bonus',
            'reference_id' => 'reward_901',
            'idempotency_key' => 'bonus_command_seed_901',
            'status' => 'completed',
            'expires_at' => now()->subMinute(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->artisan('bonus-wallets:expire')
            ->expectsOutput('Expired bonus wallets: 1')
            ->expectsOutput('Expired credits: 1')
            ->expectsOutput('Expired amount: 60.00')
            ->assertExitCode(0);

        $this->assertEquals(
            '0.00',
            number_format((float) DB::table('bonus_wallets')->where('actor_id', 901)->value('balance'), 2, '.', '')
        );

        Carbon::setTestNow();
    }
}
