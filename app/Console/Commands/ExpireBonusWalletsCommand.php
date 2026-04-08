<?php

namespace App\Console\Commands;

use App\Services\BonusWalletService;
use Illuminate\Console\Command;

class ExpireBonusWalletsCommand extends Command
{
    protected $signature = 'bonus-wallets:expire';

    protected $description = 'Expire due bonus wallet credits and reconcile balances.';

    public function handle(BonusWalletService $bonusWalletService): int
    {
        $summary = $bonusWalletService->expireDueWallets();

        $this->info('Expired bonus wallets: ' . ($summary['wallets'] ?? 0));
        $this->info('Expired credits: ' . ($summary['credits'] ?? 0));
        $this->info('Expired amount: ' . number_format((float) ($summary['amount'] ?? 0), 2, '.', ''));

        return self::SUCCESS;
    }
}
