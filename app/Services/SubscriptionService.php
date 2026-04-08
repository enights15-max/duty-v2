<?php

namespace App\Services;

use App\Models\SubscriptionPlan;
use App\Models\Subscription;
use Stripe\StripeClient;
use Carbon\Carbon;

class SubscriptionService
{
    protected $stripe;

    public function __construct()
    {
        $this->stripe = new StripeClient(config('services.stripe.secret'));
    }

    /**
     * Create a subscription checkout session for a user.
     */
    public function createCheckoutSession($user, SubscriptionPlan $plan, string $successUrl, string $cancelUrl): string
    {
        $actorType = $this->resolveActorType($user);
        $fullName = trim((string) (($user->first_name ?? $user->fname ?? '') . ' ' . ($user->last_name ?? $user->lname ?? '')));

        // 1. Ensure user has a Stripe Customer ID
        if (!$user->stripe_customer_id) {
            $customer = $this->stripe->customers->create([
                'email' => $user->email,
                'name' => $fullName !== '' ? $fullName : ($user->email ?? 'Duty Customer'),
                'metadata' => [
                    'user_id' => $user->id,
                    'actor_id' => $user->id,
                    'actor_type' => $actorType,
                ]
            ]);
            $user->update(['stripe_customer_id' => $customer->id]);
        }

        // 2. Create the Checkout Session
        $session = $this->stripe->checkout->sessions->create([
            'customer' => $user->stripe_customer_id,
            'payment_method_types' => ['card'],
            'line_items' => [
                [
                    'price' => $plan->stripe_price_id,
                    'quantity' => 1,
                ]
            ],
            'mode' => 'subscription',
            'success_url' => $successUrl,
            'cancel_url' => $cancelUrl,
            'metadata' => [
                'user_id' => $user->id,
                'actor_id' => $user->id,
                'actor_type' => $actorType,
                'plan_id' => $plan->id
            ]
        ]);

        return $session->url;
    }

    /**
     * Sync subscription details from a Stripe Subscription object.
     */
    public function syncSubscription($stripeSubscriptionId)
    {
        $stripeSub = $this->stripe->subscriptions->retrieve($stripeSubscriptionId);
        $userId = $stripeSub->metadata->user_id ?? null;
        $planId = $stripeSub->metadata->plan_id ?? null;

        if (!$userId || !$planId) {
            // Try to find user by customer ID if metadata is missing
            $user = User::where('stripe_customer_id', $stripeSub->customer)->first();
            $userId = $user?->id;

            // Try to find plan by stripe_price_id
            $plan = SubscriptionPlan::where('stripe_price_id', $stripeSub->items->data[0]->price->id)->first();
            $planId = $plan?->id;
        }

        if (!$userId || !$planId)
            return null;

        return Subscription::updateOrCreate(
            ['stripe_subscription_id' => $stripeSubscriptionId],
            [
                'user_id' => $userId,
                'subscription_plan_id' => $planId,
                'status' => $stripeSub->status,
                'starts_at' => Carbon::createFromTimestamp($stripeSub->current_period_start),
                'ends_at' => Carbon::createFromTimestamp($stripeSub->current_period_end),
                'canceled_at' => $stripeSub->canceled_at ? Carbon::createFromTimestamp($stripeSub->canceled_at) : null,
            ]
        );
    }

    /**
     * Terminate or cancel a local subscription record based on Stripe status.
     */
    public function cancelSubscription($stripeSubscriptionId)
    {
        $sub = Subscription::where('stripe_subscription_id', $stripeSubscriptionId)->first();
        if ($sub) {
            $sub->update([
                'status' => 'canceled',
                'canceled_at' => now(),
            ]);
        }
    }

    private function resolveActorType($user): string
    {
        $class = strtolower(get_class($user));
        if (str_contains($class, 'customer')) {
            return 'customer';
        }

        return 'user';
    }
}
