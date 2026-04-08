<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Services\WalletService;

class WalletLedgerTest extends TestCase
{
    use RefreshDatabase;

    protected $walletService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->walletService = app(WalletService::class);
    }

    public function test_can_credit_wallet_and_prevent_duplicate_idempotency_keys()
    {
        $user = User::factory()->create();
        $amount = 1000.50;
        $idempotencyKey = 'unique_topup_123';

        // 1. Initial Credit
        $transaction1 = $this->walletService->credit($user, $amount, 'topup', 'intent_1', $idempotencyKey);

        $this->assertEquals($amount, $user->wallet->balance);
        $this->assertEquals('completed', $transaction1->status);

        // 2. Duplicate Credit with same idempotency key should return the existing transaction
        // and NOT double the balance.
        $transaction2 = $this->walletService->credit($user, $amount, 'topup', 'intent_1', $idempotencyKey);

        $user->wallet->refresh();
        $this->assertEquals($amount, $user->wallet->balance); // Still 1000.50
        $this->assertEquals($transaction1->id, $transaction2->id); // Returned same exact transaction model
    }

    public function test_can_debit_wallet()
    {
        $user = User::factory()->create();
        // Setup initial balance
        $this->walletService->credit($user, 1000, 'topup', 'setup', 'key_1');

        // Debit 300
        $transaction = $this->walletService->debit($user, 300, 'ticket', 'tkt_1', 'key_2');

        $user->wallet->refresh();
        $this->assertEquals(700, $user->wallet->balance);
        $this->assertEquals('debit', $transaction->type);
    }

    public function test_insufficient_funds_throws_exception()
    {
        $user = User::factory()->create();
        $this->walletService->credit($user, 500, 'topup', 'setup', 'key_1');

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Insufficient funds');

        // Trying to spend 600 when only 500 is available
        $this->walletService->debit($user, 600, 'ticket', 'tkt_1', 'key_2');
    }
}
