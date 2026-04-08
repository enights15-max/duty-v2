<?php

namespace App\Console\Commands;

use App\Models\Event\Ticket;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class ActivateGatedTicketsCommand extends Command
{
    protected $signature = 'tickets:activate-gated';
    protected $description = 'Activate tickets whose gate_trigger_date has passed or whose gate ticket has sold out.';

    public function handle(): int
    {
        // 1. Date-triggered gates: activate paused tickets whose trigger date has passed.
        $dateActivated = Ticket::where('gate_trigger', 'date')
            ->whereNotNull('gate_trigger_date')
            ->where('gate_trigger_date', '<=', now())
            ->where('sale_status', 'paused')
            ->update(['sale_status' => 'active']);

        // 2. Sold-out-triggered gates: activate paused tickets whose gate ticket is now at 0 stock.
        $soldOutActivated = 0;
        $gatedTickets = Ticket::where('gate_trigger', 'sold_out')
            ->whereNotNull('gate_ticket_id')
            ->where('sale_status', 'paused')
            ->with('gateTicket')
            ->get();

        foreach ($gatedTickets as $gated) {
            $source = $gated->gateTicket;
            if (!$source) {
                continue;
            }

            $isDepeleted = $source->ticket_available_type === 'limited'
                && (int) ($source->ticket_available ?? 0) <= 0;

            if ($isDepeleted) {
                $gated->sale_status = 'active';
                $gated->save();
                $soldOutActivated++;
            }
        }

        $total = $dateActivated + $soldOutActivated;

        if ($total > 0) {
            Log::info('Gated tickets activated by scheduler.', [
                'date_activated' => $dateActivated,
                'sold_out_activated' => $soldOutActivated,
            ]);
            $this->info("Activated {$total} gated ticket(s).");
        } else {
            $this->info('No gated tickets to activate.');
        }

        return self::SUCCESS;
    }
}
