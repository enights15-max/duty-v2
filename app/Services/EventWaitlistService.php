<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Event;
use App\Models\EventWaitlistSubscription;

class EventWaitlistService
{
    public function __construct(
        private EventInventorySummaryService $inventorySummaryService,
        private NotificationService $notificationService,
    ) {
    }

    public function summaryForEvent(Event $event, ?Customer $viewer = null): array
    {
        $activeQuery = EventWaitlistSubscription::query()
            ->where('event_id', (int) $event->id)
            ->where('status', 'active');

        $eligibility = $this->eligibilityForEvent($event);

        return [
            'waitlist_count' => (clone $activeQuery)->count(),
            'viewer_waitlist_subscribed' => $viewer
                ? (clone $activeQuery)->where('customer_id', (int) $viewer->id)->exists()
                : false,
            'show_waitlist_cta' => (bool) ($eligibility['can_join'] ?? false),
            'waitlist_reason' => $eligibility['reason'] ?? null,
        ];
    }

    public function eligibilityForEvent(Event $event): array
    {
        $inventory = $this->inventorySummaryService->summarizeEvent($event);

        if (($inventory['is_past_event'] ?? false) === true) {
            return [
                'can_join' => false,
                'reason' => 'event_ended',
                'inventory' => $inventory,
            ];
        }

        if (!($inventory['primary_sold_out'] ?? false)) {
            return [
                'can_join' => false,
                'reason' => 'primary_inventory_available',
                'inventory' => $inventory,
            ];
        }

        if (($inventory['show_marketplace_fallback'] ?? false) === true) {
            return [
                'can_join' => false,
                'reason' => 'marketplace_inventory_available',
                'inventory' => $inventory,
            ];
        }

        return [
            'can_join' => true,
            'reason' => 'eligible',
            'inventory' => $inventory,
        ];
    }

    public function subscribe(Event $event, Customer $customer): EventWaitlistSubscription
    {
        return EventWaitlistSubscription::query()->updateOrCreate(
            [
                'event_id' => (int) $event->id,
                'customer_id' => (int) $customer->id,
            ],
            [
                'status' => 'active',
                'notified_reason' => null,
                'notified_at' => null,
            ]
        );
    }

    public function unsubscribe(Event $event, Customer $customer): void
    {
        EventWaitlistSubscription::query()
            ->where('event_id', (int) $event->id)
            ->where('customer_id', (int) $customer->id)
            ->delete();
    }

    public function notifyMarketplaceAvailability(Event $event): int
    {
        $summary = $this->inventorySummaryService->summarizeEvent($event);

        if (!($summary['primary_sold_out'] ?? false)) {
            return 0;
        }

        if ((int) ($summary['marketplace_available_count'] ?? 0) <= 0) {
            return 0;
        }

        return $this->notifySubscribers(
            $event,
            'marketplace',
            'Entradas disponibles nuevamente',
            'La taquilla oficial está agotada, pero ya hay entradas disponibles en blackmarket para ' . $this->eventTitle($event) . '.'
        );
    }

    public function notifyPrimaryInventoryAvailability(Event $event): int
    {
        $summary = $this->inventorySummaryService->summarizeEvent($event);

        if ($summary['primary_sold_out'] ?? false) {
            return 0;
        }

        return $this->notifySubscribers(
            $event,
            'primary_inventory',
            'Nuevas entradas disponibles',
            'Volvieron a aparecer entradas oficiales para ' . $this->eventTitle($event) . '.'
        );
    }

    private function notifySubscribers(
        Event $event,
        string $reason,
        string $title,
        string $body,
    ): int {
        $cooldownThreshold = now()->subMinutes(30);
        $subscriptions = EventWaitlistSubscription::query()
            ->with('customer')
            ->where('event_id', (int) $event->id)
            ->where('status', 'active')
            ->where(function ($query) use ($reason, $cooldownThreshold): void {
                $query->whereNull('notified_at')
                    ->orWhere('notified_reason', '!=', $reason)
                    ->orWhere('notified_at', '<', $cooldownThreshold);
            })
            ->get();

        if ($subscriptions->isEmpty()) {
            return 0;
        }

        $notifiedIds = [];

        foreach ($subscriptions as $subscription) {
            $customer = $subscription->customer;
            if (!$customer) {
                continue;
            }

            $sent = $this->notificationService->notifyUser(
                $customer,
                $title,
                $body,
                [
                    'type' => 'event_waitlist_update',
                    'event_id' => (string) $event->id,
                    'reason' => $reason,
                ]
            );

            if (!$sent) {
                continue;
            }

            $notifiedIds[] = (int) $subscription->id;
        }

        if ($notifiedIds !== []) {
            EventWaitlistSubscription::query()
                ->whereIn('id', $notifiedIds)
                ->update([
                    'notified_reason' => $reason,
                    'notified_at' => now(),
                    'updated_at' => now(),
                ]);
        }

        return count($notifiedIds);
    }

    private function eventTitle(Event $event): string
    {
        return (string) ($event->title
            ?? $event->information?->title
            ?? 'tu evento');
    }
}
