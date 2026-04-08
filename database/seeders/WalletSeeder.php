<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Wallet;
use App\Models\WalletTransaction;

class WalletSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Target a specific user id (usually the first/admin user)
        $userId = 11;

        // Ensure wallet exists
        $wallet = Wallet::firstOrCreate(
            ['user_id' => $userId],
            ['balance' => 0.00, 'status' => 'active']
        );

        // Calculate and add balance based on hardcoded demo data
        $transactions = [
            [
                'type' => 'deposit',
                'amount' => 150.00,
                'description' => 'Initial Promo Deposit',
                'reference_id' => 'PROMO-2026',
            ],
            [
                'type' => 'purchase',
                'amount' => -25.00,
                'description' => 'Tickets for Neon Nights',
                'reference_id' => 'BKG-001',
            ],
            [
                'type' => 'deposit',
                'amount' => 50.00,
                'description' => 'Top-up via Credit Card ending in 4242',
                'reference_id' => 'CH_1M...',
            ],
        ];

        foreach ($transactions as $t) {
            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => $t['type'],
                'amount' => $t['amount'],
                'description' => $t['description'],
                'reference_id' => $t['reference_id'],
                'created_at' => now()->subDays(rand(1, 10)),
            ]);

            $wallet->balance += $t['amount'];
        }

        $wallet->save();
    }
}
