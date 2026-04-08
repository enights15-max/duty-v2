<?php

namespace App\Console\Commands;

use App\Services\ReviewPromptDispatchService;
use Illuminate\Console\Command;

class DispatchReviewPromptsCommand extends Command
{
    protected $signature = 'reviews:dispatch-prompts';

    protected $description = 'Dispatch post-event review prompts for concluded attended events.';

    public function handle(ReviewPromptDispatchService $dispatchService): int
    {
        $summary = $dispatchService->dispatchPendingPrompts();

        $this->info('Review prompt dispatch completed.');
        $this->line('Customers scanned: ' . ($summary['customers_scanned'] ?? 0));
        $this->line('Queued deliveries: ' . ($summary['queued'] ?? 0));
        $this->line('Retried deliveries: ' . ($summary['retried'] ?? 0));
        $this->line('Skipped existing deliveries: ' . ($summary['skipped_existing'] ?? 0));

        return self::SUCCESS;
    }
}
