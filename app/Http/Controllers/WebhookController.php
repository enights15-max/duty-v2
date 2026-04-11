<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Identity;
use App\Models\IdentityBalanceTransaction;
use App\Services\WalletService;
use App\Services\ProfessionalBalanceService;
use App\Models\User;
use App\Models\Customer;
use App\Models\PaymentMethod;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class WebhookController extends Controller
{
    protected $walletService;
    protected $professionalBalanceService;
    protected $stripeService;
    protected $subscriptionService;

    public function __construct(
        WalletService $walletService,
        ProfessionalBalanceService $professionalBalanceService,
        \App\Services\StripeService $stripeService,
        \App\Services\SubscriptionService $subscriptionService
    )
    {
        $this->walletService = $walletService;
        $this->professionalBalanceService = $professionalBalanceService;
        $this->stripeService = $stripeService;
        $this->subscriptionService = $subscriptionService;
    }

    public function handleStripe(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $endpointSecret = config('services.stripe.webhook_secret');

        $event = null;

        if (empty($endpointSecret)) {
            Log::error("Stripe Webhook Error: Missing webhook secret configuration");
            return response()->json(['error' => 'Webhook secret is not configured'], 500);
        }

        if (empty($sigHeader)) {
            Log::warning("Stripe Webhook Error: Missing signature header");
            return response()->json(['error' => 'Missing Stripe-Signature header'], 400);
        }

        try {
            $event = \Stripe\Webhook::constructEvent(
                $payload,
                $sigHeader,
                $endpointSecret
            );
        } catch (\UnexpectedValueException $e) {
            // Invalid payload
            Log::error("Stripe Webhook Error: Invalid Payload", ['error' => $e->getMessage()]);
            return response()->json(['error' => 'Invalid Payload'], 400);
        } catch (\Stripe\Exception\SignatureVerificationException $e) {
            // Invalid signature
            Log::error("Stripe Webhook Error: Invalid Signature", ['error' => $e->getMessage()]);
            return response()->json(['error' => 'Invalid Signature'], 400);
        }

        // Handle the event
        switch ($event->type) {
            case 'payment_intent.succeeded':
                $paymentIntent = $event->data->object;
                Log::info("Stripe Webhook: payment_intent.succeeded", ['id' => $paymentIntent->id]);
                $this->handlePaymentIntentSucceeded($paymentIntent);
                break;
            case 'setup_intent.succeeded':
                $setupIntent = $event->data->object;
                Log::info("Stripe Webhook: setup_intent.succeeded", ['id' => $setupIntent->id]);
                $this->handleSetupIntentSucceeded($setupIntent);
                break;
            case 'customer.subscription.created':
            case 'customer.subscription.updated':
            case 'invoice.paid':
                $obj = $event->data->object;
                $subId = $obj->subscription ?? $obj->id;
                if ($subId && str_starts_with($subId, 'sub_')) {
                    $this->subscriptionService->syncSubscription($subId);
                    Log::info("Stripe Webhook: Subscription synced", ['id' => $subId, 'type' => $event->type]);
                }
                break;
            case 'customer.subscription.deleted':
                $subscription = $event->data->object;
                $this->subscriptionService->cancelSubscription($subscription->id);
                Log::info("Stripe Webhook: Subscription canceled", ['id' => $subscription->id]);
                break;
            default:
                Log::info("Stripe Webhook: Received unhandled event type", ['type' => $event->type]);
        }

        return response()->json(['status' => 'success']);
    }

    protected function handlePaymentIntentSucceeded($paymentIntent)
    {
        $metadata = $paymentIntent->metadata ?? (object) [];
        $purpose = (string) ($metadata->purpose ?? '');
        if ($purpose !== 'topup') {
            return;
        }

        $actorId = (int) ($metadata->actor_id ?? $metadata->user_id ?? 0);
        $actorType = (string) ($metadata->actor_type ?? $metadata->user_type ?? 'customer');
        $amountDOP = (float) ($metadata->requested_amount ?? (($paymentIntent->amount ?? 0) / 100));

        if ($actorId <= 0) {
            Log::error('Wallet Topup Failed: Missing actor metadata', ['payment_intent' => $paymentIntent->id ?? null]);
            return;
        }

        try {
            $walletContext = strtolower((string) ($metadata->wallet_context ?? 'personal'));
            $identityId = (int) ($metadata->identity_id ?? 0);

            if ($walletContext === 'professional' && $identityId > 0) {
                $identity = Identity::query()
                    ->where('id', $identityId)
                    ->whereIn('type', ['organizer', 'artist', 'venue'])
                    ->where('status', 'active')
                    ->first();

                if (!$identity) {
                    Log::error("Wallet Topup Failed: Professional identity not found", ['identity_id' => $identityId]);
                    return;
                }

                $this->creditProfessionalTopup($identity, (float) $amountDOP, (string) $paymentIntent->id);
                Log::info("Professional wallet topup success via webhook", [
                    'identity_id' => $identityId,
                    'actor_type' => $identity->type,
                    'amount' => $amountDOP,
                ]);

                return;
            }

            $actor = $this->resolveActor($actorId, $actorType);
            if (!$actor) {
                Log::error("Wallet Topup Failed: Actor not found", ['actor_id' => $actorId, 'actor_type' => $actorType]);
                return;
            }

            $this->walletService->credit(
                $actor,
                (float) $amountDOP,
                'topup',
                $paymentIntent->id,
                'TOPUP-' . $paymentIntent->id,
                0,
                0,
                $this->buildTopupTransactionMeta($amountDOP)
            );

            Log::info("Wallet Topup Success via Webhook", [
                'actor_id' => $actorId,
                'actor_type' => $actorType,
                'amount' => $amountDOP,
            ]);
        } catch (\Throwable $e) {
            Log::error("Wallet Topup Failed", ['error' => $e->getMessage()]);
        }
    }

    private function creditProfessionalTopup(Identity $identity, float $amount, string $paymentIntentId): IdentityBalanceTransaction
    {
        $identityId = (int) $identity->id;
        $legacyId = (int) ($identity->meta['legacy_id'] ?? $identity->meta['id'] ?? 0);

        return DB::transaction(function () use ($identity, $identityId, $legacyId, $amount, $paymentIntentId) {
            $existing = IdentityBalanceTransaction::query()
                ->where('identity_id', $identityId)
                ->where('type', 'credit')
                ->where('reference_type', 'topup')
                ->where('reference_id', $paymentIntentId)
                ->first();

            if ($existing) {
                return $existing;
            }

            $result = match ($identity->type) {
                'organizer' => $this->professionalBalanceService->creditOrganizerBalance($identityId, $legacyId ?: null, $amount),
                'artist' => $this->professionalBalanceService->creditArtistBalance($identityId, $legacyId ?: null, $amount),
                'venue' => $this->professionalBalanceService->creditVenueBalance($identityId, $legacyId ?: null, $amount),
                default => throw new \RuntimeException('Unsupported professional balance type for webhook topup.'),
            };

            return IdentityBalanceTransaction::query()->create([
                'identity_id' => $identityId,
                'type' => 'credit',
                'amount' => $amount,
                'description' => 'Wallet topup',
                'reference_type' => 'topup',
                'reference_id' => $paymentIntentId,
                'balance_before' => $result['pre_balance'] ?? 0,
                'balance_after' => $result['after_balance'] ?? 0,
                'meta' => array_merge([
                    'actor_type' => $identity->type,
                    'display_name' => $identity->display_name,
                ], $this->buildTopupTransactionMeta($amount)),
            ]);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function buildTopupTransactionMeta(float $amount): array
    {
        return array_merge(
            app(\App\Services\EventPaymentVerificationService::class)->buildGatewayContract('stripe', 'stripe'),
            [
                'requested_amount' => round($amount, 2),
            ]
        );
    }

    protected function handleSetupIntentSucceeded($setupIntent)
    {
        $customerId = $setupIntent->customer;
        $paymentMethodId = $setupIntent->payment_method;

        if (!$customerId || !$paymentMethodId) {
            return;
        }

        try {
            $user = Customer::where('stripe_customer_id', $customerId)->first();
            if (!$user) {
                // Also check User (Admin/Organizer) just in case
                $user = User::where('stripe_customer_id', $customerId)->first();
            }

            if (!$user) {
                Log::error("Stripe Webhook: SetupIntent succeeded but user not found", ['customer' => $customerId]);
                return;
            }

            // Retrieve payment method details from Stripe to get card metadata
            $pmData = $this->stripeService->retrievePaymentMethod($paymentMethodId);
            $card = $pmData->card ?? null;

            $update = [
                'user_id' => $user->id,
                'brand' => $card->brand ?? 'unknown',
                'last4' => $card->last4 ?? '****',
                'exp_month' => $card->exp_month ?? null,
                'exp_year' => $card->exp_year ?? null,
                'status' => 'active',
                'actor_type' => $user instanceof Customer ? 'customer' : 'user',
                'actor_id' => $user->id,
            ];

            PaymentMethod::updateOrCreate(
                ['stripe_payment_method_id' => $paymentMethodId],
                $update
            );

            Log::info("Payment Method Saved via Webhook", ['user_id' => $user->id, 'pm' => $paymentMethodId]);

        } catch (\Exception $e) {
            Log::error("Failed to save Payment Method via Webhook", ['error' => $e->getMessage()]);
        }
    }

    private function resolveActor(int $userId, string $userType)
    {
        $normalizedType = strtolower(trim($userType));
        $customerAliases = ['customer', Customer::class, 'app\\models\\customer'];
        $userAliases = ['user', User::class, 'app\\models\\user'];

        if (in_array($normalizedType, array_map('strtolower', $customerAliases), true)) {
            return Customer::find($userId);
        }

        if (in_array($normalizedType, array_map('strtolower', $userAliases), true)) {
            return User::find($userId);
        }

        // Unknown type: fallback to customer first for API wallet flows, then user.
        return Customer::find($userId) ?? User::find($userId);
    }
}
