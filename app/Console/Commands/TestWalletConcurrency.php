<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestWalletConcurrency extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'wallet:test-concurrency {user_id} {amount} {--idempotency_key=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Simulate concurrent wallet debits for testing purposes';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle(\App\Services\WalletService $walletService)
    {
        $userId = $this->argument('user_id');
        $amount = (float) $this->argument('amount');
        $idempotencyKey = $this->option('idempotency_key') ?? 'test_' . uniqid();

        $user = \App\Models\User::find($userId);
        if (!$user) {
            $this->error("User not found: {$userId}");
            return Command::FAILURE;
        }

        $this->info("User: {$user->email} | Balance: {$user->wallet?->balance}");
        $this->info("Attempting debit: {$amount} | Key: {$idempotencyKey}");

        try {
            $transaction = $walletService->debit($user, $amount, 'concurrency_test', 'test', $idempotencyKey);
            $this->info("SUCCESS: Transaction ID: {$transaction->id}");
            return Command::SUCCESS;
        } catch (\Exception $e) {
            $this->error("FAILED: " . $e->getMessage());
            return Command::FAILURE;
        }
    }
}
