<?php

namespace Tests\Feature;

use App\Models\Customer;
use Carbon\Carbon;
use App\Services\BonusWalletService;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class BonusWalletLedgerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'bonus_wallets'];
    protected array $baselineTruncate = ['bonus_transactions', 'bonus_wallets', 'customers'];

    protected BonusWalletService $bonusWalletService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->bonusWalletService = app(BonusWalletService::class);
    }

    public function test_can_credit_and_debit_bonus_wallet(): void
    {
        $customer = $this->createCustomerActor(301);

        $this->bonusWalletService->credit($customer, 120, 'reward_campaign', 'cmp_1', 'bonus_credit_301');
        $transaction = $this->bonusWalletService->debit($customer, 20, 'ticket_booking_bonus', 'ord_1', 'bonus_debit_301');

        $wallet = $this->bonusWalletService->getOrCreateWallet($customer);
        $this->assertEquals('100.00', number_format((float) $wallet->balance, 2, '.', ''));
        $this->assertSame('debit', $transaction->type);
    }

    public function test_bonus_wallet_requires_sufficient_balance(): void
    {
        $customer = $this->createCustomerActor(302);
        $this->bonusWalletService->credit($customer, 10, 'reward_campaign', 'cmp_2', 'bonus_credit_302');

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Insufficient bonus balance');

        $this->bonusWalletService->debit($customer, 15, 'ticket_booking_bonus', 'ord_2', 'bonus_debit_302');
    }

    public function test_due_bonus_credit_expires_and_reduces_wallet_balance(): void
    {
        $customer = $this->createCustomerActor(303);
        $expiredAt = now()->subHour();

        $this->bonusWalletService->credit(
            $customer,
            40,
            'reward_campaign',
            'cmp_3',
            'bonus_credit_303',
            'credit',
            $expiredAt
        );

        $wallet = $this->bonusWalletService->getOrCreateWallet($customer);

        $this->assertEquals('0.00', number_format((float) $wallet->balance, 2, '.', ''));
        $this->assertDatabaseHas('bonus_transactions', [
            'bonus_wallet_id' => $wallet->id,
            'reference_type' => 'bonus_expiration',
            'reference_id' => DB::table('bonus_transactions')
                ->where('bonus_wallet_id', $wallet->id)
                ->where('reference_type', 'reward_campaign')
                ->value('id'),
        ]);
    }

    public function test_debit_consumes_earliest_expiring_bonus_credit_first(): void
    {
        Carbon::setTestNow(now()->startOfDay());
        $customer = $this->createCustomerActor(304);

        $first = $this->bonusWalletService->credit(
            $customer,
            30,
            'reward_campaign',
            'cmp_4a',
            'bonus_credit_304_a',
            'credit',
            now()->addDay()
        );
        $second = $this->bonusWalletService->credit(
            $customer,
            20,
            'reward_campaign',
            'cmp_4b',
            'bonus_credit_304_b',
            'credit',
            now()->addDays(4)
        );

        $this->bonusWalletService->debit($customer, 25, 'ticket_booking_bonus', 'ord_304', 'bonus_debit_304');

        $this->assertEquals(
            '25.00',
            number_format((float) DB::table('bonus_transactions')->where('id', $first->id)->value('consumed_amount'), 2, '.', '')
        );
        $this->assertEquals(
            '0.00',
            number_format((float) DB::table('bonus_transactions')->where('id', $second->id)->value('consumed_amount'), 2, '.', '')
        );

        Carbon::setTestNow(now()->addDays(2));
        $wallet = $this->bonusWalletService->getOrCreateWallet($customer);

        $this->assertEquals('20.00', number_format((float) $wallet->balance, 2, '.', ''));
        $this->assertEquals(
            '5.00',
            number_format((float) DB::table('bonus_transactions')->where('id', $first->id)->value('expired_amount'), 2, '.', '')
        );
        Carbon::setTestNow();
    }

    private function createCustomerActor(int $id): Customer
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "bonus{$id}@example.com",
            'username' => "bonus_{$id}",
            'fname' => 'Bonus',
            'lname' => 'Customer',
            'status' => 1,
            'email_verified_at' => now(),
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }
}
