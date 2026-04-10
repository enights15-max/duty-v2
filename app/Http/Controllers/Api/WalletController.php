<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Identity;
use App\Models\IdentityBalanceTransaction;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\Customer;
use App\Models\User;
use App\Models\Wallet\WithdrawalRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use App\Services\FeeEngine;
use App\Services\ProfessionalBalanceService;
use App\Services\WalletService;

class WalletController extends Controller
{
    protected $walletService;
    protected $professionalBalanceService;
    protected $feeEngine;

    public function __construct(
        WalletService $walletService,
        ProfessionalBalanceService $professionalBalanceService,
        FeeEngine $feeEngine
    )
    {
        $this->walletService = $walletService;
        $this->professionalBalanceService = $professionalBalanceService;
        $this->feeEngine = $feeEngine;
    }

    /**
     * Get the current user's wallet balance and status.
     */
    public function getWallet(Request $request)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $context = $this->resolveWalletContext($request, $user);
        if ($context['kind'] === 'professional') {
            return response()->json([
                'success' => true,
                'wallet' => [
                    'id' => (string) $context['id'],
                    'balance' => round((float) $context['balance'], 2),
                    'currency' => 'DOP',
                    'status' => 'active',
                    'actor_type' => $context['actor_type'],
                    'display_name' => $context['display_name'],
                ],
            ]);
        }

        $wallet = $context['wallet'];

        return response()->json([
            'success' => true,
            'wallet' => [
                'id' => $wallet->id,
                'balance' => round((float) $wallet->balance, 2),
                'currency' => $wallet->currency,
                'status' => $wallet->status,
                'actor_type' => 'personal',
                'display_name' => 'Personal',
            ]
        ]);
    }

    /**
     * Get the transaction history.
     */
    public function getHistory(Request $request)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $context = $this->resolveWalletContext($request, $user);
        if ($context['kind'] === 'professional') {
            $ledgerTransactions = IdentityBalanceTransaction::query()
                ->where('identity_id', (int) $context['id'])
                ->latest()
                ->get([
                    'id',
                    'type',
                    'amount',
                    'reference_id',
                    'description',
                    'created_at',
                ])
                ->map(fn (IdentityBalanceTransaction $transaction) => [
                    'id' => (string) $transaction->id,
                    'type' => $transaction->type,
                    'amount' => $transaction->amount,
                    'reference_id' => $transaction->reference_id,
                    'description' => $transaction->description,
                    'created_at' => optional($transaction->created_at)?->toISOString(),
                ]);

            $commercialTransactions = $this->professionalCommercialTransactions($context);

            return response()->json([
                'success' => true,
                'transactions' => $ledgerTransactions
                    ->concat($commercialTransactions)
                    ->sortByDesc('created_at')
                    ->take(50)
                    ->values(),
            ]);
        }

        $wallet = $context['wallet'];

        $transactions = WalletTransaction::where('wallet_id', $wallet->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'transactions' => $transactions
        ]);
    }

    /**
     * Transfer funds between personal wallet and professional balances.
     */
    public function transfer(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'target_wallet_id' => 'required|string',
        ]);

        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        try {
            $sourceContext = $this->resolveWalletContext($request, $user);
            $targetContext = $this->resolveTargetContext((string) $request->input('target_wallet_id'), $user);

            if (!$targetContext) {
                return response()->json([
                    'success' => false,
                    'message' => 'Target wallet or profile could not be resolved.',
                ], 404);
            }

            if ($this->contextKey($sourceContext) === $this->contextKey($targetContext)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You cannot transfer funds to the same wallet or profile.',
                ], 422);
            }

            $amount = round((float) $request->input('amount'), 2);
            $referenceId = (string) Str::uuid();

            $result = DB::transaction(function () use ($sourceContext, $targetContext, $amount, $referenceId) {
                $sourcePreview = $this->previewBalance($sourceContext, $amount, true);
                if (($sourcePreview['after_balance'] ?? 0) < 0) {
                    throw new \RuntimeException('Insufficient funds for transfer.');
                }

                $sourceMutation = $this->mutateContextBalance(
                    $sourceContext,
                    $amount,
                    true,
                    $referenceId
                );
                $targetMutation = $this->mutateContextBalance(
                    $targetContext,
                    $amount,
                    false,
                    $referenceId
                );

                return [
                    'source' => $sourceMutation,
                    'target' => $targetMutation,
                ];
            });

            return response()->json([
                'success' => true,
                'message' => 'Transfer completed successfully.',
                'data' => [
                    'reference_id' => $referenceId,
                    'amount' => $amount,
                    'source' => $result['source'],
                    'target' => $result['target'],
                ],
            ]);
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Transfer failed. Please try again.',
            ], 500);
        }
    }

    public function previewTopup(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $amountDOP = (float) $request->input('amount');

        return response()->json([
            'success' => true,
            'data' => $this->buildTopupSummary($amountDOP),
        ]);
    }

    /**
     * Create a Stripe PaymentIntent to top up the wallet.
     */
    public function createTopupIntent(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }
        $amountDOP = (float) $request->input('amount');
        $context = $this->resolveWalletContext($request, $user);
            $summary = $this->buildTopupSummary($amountDOP);
            $totalToCharge = (float) ($summary['total_charge'] ?? $amountDOP);
        $totalCents = round($totalToCharge * 100);

        try {
            \Stripe\Stripe::setApiKey(config('services.stripe.secret'));

            $actorType = $this->resolveActorType($user);
            $metadata = [
                'actor_id' => $user->id,
                'actor_type' => $actorType,
                // Backward compatibility for legacy webhook/clients.
                'user_id' => $user->id,
                'user_type' => $actorType,
                'purpose' => 'topup',
                'requested_amount' => $amountDOP,
                'wallet_context' => $context['kind'],
            ];

            if ($context['kind'] === 'professional') {
                $metadata['identity_id'] = (string) $context['id'];
                $metadata['identity_type'] = (string) $context['actor_type'];
            } else {
                $metadata['wallet_id'] = (string) $context['id'];
            }

            $paymentIntent = \Stripe\PaymentIntent::create([
                'amount' => $totalCents,
                'currency' => 'dop',
                'customer' => $user->stripe_customer_id,
                'metadata' => $metadata,
                // Add idempotency dynamically
            ]);

            return response()->json([
                'success' => true,
                'client_secret' => $paymentIntent->client_secret,
                'total_charge' => $totalToCharge,
                'net_amount' => $amountDOP,
                'payment_summary' => $summary,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    private function buildTopupSummary(float $amountDOP): array
    {
        $breakdown = $this->feeEngine->quoteBuyerChargeForNet(
            FeeEngine::OP_WALLET_TOPUP,
            $amountDOP,
            ['currency' => 'DOP']
        );
        $gatewayDescriptor = app(\App\Services\EventPaymentVerificationService::class)->describeGateway('stripe');

        $processingFee = (float) ($breakdown['fee_amount'] ?? 0);
        $totalCharge = (float) ($breakdown['total_charge_amount'] ?? $amountDOP);

        return [
            'gateway' => $gatewayDescriptor['gateway'] ?? null,
            'gateway_family' => $gatewayDescriptor['gateway_family'] ?? null,
            'verification_strategy' => $gatewayDescriptor['verification_strategy'] ?? null,
            'requested_amount' => round($amountDOP, 2),
            'processing_fee' => round($processingFee, 2),
            'total_charge' => round($totalCharge, 2),
            'currency' => 'DOP',
            'fee_policy' => [
                'operation_key' => FeeEngine::OP_WALLET_TOPUP,
                'policy_id' => $breakdown['policy_id'] ?? null,
                'policy_source' => $breakdown['policy_source'] ?? 'fallback',
                'fee_type' => $breakdown['fee_type'] ?? null,
                'charged_to' => $breakdown['charged_to'] ?? null,
            ],
        ];
    }

    /**
     * Get the user's withdrawal requests.
     */
    public function getWithdrawals(Request $request)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $context = $this->resolveWalletContext($request, $user);
        $withdrawals = WithdrawalRequest::where('customer_id', $user->id)
            ->when(
                $context['kind'] === 'professional',
                fn ($query) => $query->where('identity_id', (int) $context['id']),
                fn ($query) => $query->whereNull('identity_id')
            )
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'withdrawals' => $withdrawals
        ]);
    }

    /**
     * Submit a new withdrawal request.
     */
    public function requestWithdrawal(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:10', // Minimum $10
            'method' => 'required|string',
            'payment_details' => 'required|array',
        ]);

        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }
        $amount = (float) $request->input('amount');
        $context = $this->resolveWalletContext($request, $user);

        return \Illuminate\Support\Facades\DB::transaction(function () use ($user, $amount, $request, $context) {
            if (($context['balance'] ?? 0) < $amount) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient funds for withdrawal.'
                ], 400);
            }

            $withdrawal = WithdrawalRequest::create([
                'customer_id' => $user->id,
                'identity_id' => $context['kind'] === 'professional' ? (int) $context['id'] : null,
                'actor_type' => $context['actor_type'],
                'display_name' => $context['display_name'],
                'amount' => $amount,
                'method' => $request->input('method'),
                'payment_details' => $request->input('payment_details'),
                'status' => 'pending',
            ]);

            $this->applyWithdrawalHoldToContext($context, $user, $amount, $withdrawal);

            return response()->json([
                'success' => true,
                'message' => 'Withdrawal request submitted successfully.',
                'withdrawal' => $withdrawal
            ]);
        });
    }

    /**
     * Check the status of a topup by PaymentIntent ID.
     */
    public function checkTopupStatus(Request $request, $paymentIntentId)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        $transaction = WalletTransaction::where('idempotency_key', 'TOPUP-' . $paymentIntentId)->first();
        if ($transaction && !$this->transactionBelongsToActor($transaction, $user)) {
            return response()->json([
                'success' => false,
                'message' => 'Transaction does not belong to this actor.',
            ], 403);
        }

        $professionalTransaction = $this->findOwnedProfessionalTopupTransaction($user, (string) $paymentIntentId);

        return response()->json([
            'success' => true,
            'status' => ($transaction || $professionalTransaction) ? 'processed' : 'pending',
            'transaction' => $transaction ?: $professionalTransaction,
        ]);
    }

    /**
     * Confirm a topup by verifying the PaymentIntent directly with Stripe.
     * This is a fallback for when webhooks can't reach the server.
     * Safe to call multiple times thanks to idempotency keys.
     */
    public function confirmTopup(Request $request, $paymentIntentId)
    {
        $user = $request->user();
        if (!$user instanceof Customer) {
            return response()->json(['success' => false, 'message' => 'Invalid authenticated actor.'], 403);
        }

        try {
            // Check if already processed
            $existing = WalletTransaction::where('idempotency_key', 'TOPUP-' . $paymentIntentId)->first();
            if ($existing) {
                if (!$this->transactionBelongsToActor($existing, $user)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Transaction does not belong to this actor.',
                    ], 403);
                }

                return response()->json([
                    'success' => true,
                    'status' => 'processed',
                    'transaction' => $existing,
                ]);
            }

            $existingProfessional = $this->findOwnedProfessionalTopupTransaction($user, (string) $paymentIntentId);
            if ($existingProfessional) {
                return response()->json([
                    'success' => true,
                    'status' => 'processed',
                    'transaction' => $existingProfessional,
                ]);
            }

            // Verify with Stripe
            \Stripe\Stripe::setApiKey(config('services.stripe.secret'));
            $paymentIntent = \Stripe\PaymentIntent::retrieve($paymentIntentId);

            if ($paymentIntent->status !== 'succeeded') {
                return response()->json([
                    'success' => true,
                    'status' => 'pending',
                    'stripe_status' => $paymentIntent->status,
                ]);
            }

            // Verify this payment belongs to this actor.
            $piActorId = (int) ($paymentIntent->metadata->actor_id ?? $paymentIntent->metadata->user_id ?? 0);
            $piActorType = strtolower((string) ($paymentIntent->metadata->actor_type ?? $paymentIntent->metadata->user_type ?? 'customer'));
            $piPurpose = $paymentIntent->metadata->purpose ?? '';

            if ($piActorId !== $user->id || $piActorType !== $this->resolveActorType($user) || $piPurpose !== 'topup') {
                return response()->json(['success' => false, 'message' => 'Payment does not belong to this actor.'], 403);
            }

            $amountDOP = $paymentIntent->metadata->requested_amount ?? ($paymentIntent->amount / 100);
            $totalCharge = (float) ($paymentIntent->amount / 100);
            $fee = $totalCharge - (float) $amountDOP;
            $context = $this->resolveTopupContextFromPaymentIntent($paymentIntent, $user);
            if (!$context) {
                return response()->json([
                    'success' => false,
                    'message' => 'Top-up context could not be resolved.',
                ], 422);
            }

            if ($context['kind'] === 'professional') {
                $transaction = $this->applyProfessionalTopup(
                    $context,
                    (float) $amountDOP,
                    (string) $paymentIntent->id,
                    $fee,
                    $totalCharge,
                    $this->buildTopupTransactionMeta((float) $amountDOP, $fee, $totalCharge)
                );
            } else {
                $transaction = $this->walletService->credit(
                    $user,
                    (float) $amountDOP,
                    'topup',
                    $paymentIntent->id,
                    'TOPUP-' . $paymentIntent->id,
                    $fee,
                    $totalCharge,
                    $this->buildTopupTransactionMeta((float) $amountDOP, $fee, $totalCharge)
                );
            }

            return response()->json([
                'success' => true,
                'status' => 'processed',
                'transaction' => $transaction,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    private function transactionBelongsToActor(WalletTransaction $transaction, $actor): bool
    {
        return Wallet::forActor($actor)
            ->where('id', $transaction->wallet_id)
            ->exists();
    }

    private function findOwnedProfessionalTopupTransaction(Customer $customer, string $paymentIntentId): ?IdentityBalanceTransaction
    {
        $identityIds = $this->ownedProfessionalIdentityIdsForCustomer($customer);
        if (empty($identityIds)) {
            return null;
        }

        return IdentityBalanceTransaction::query()
            ->whereIn('identity_id', $identityIds)
            ->where('type', 'credit')
            ->where('reference_type', 'topup')
            ->where('reference_id', $paymentIntentId)
            ->latest()
            ->first();
    }

    private function ownedProfessionalIdentityIdsForCustomer(Customer $customer): array
    {
        $ownerUserId = $this->resolveOwnerUserIdForCustomer($customer);
        if (!$ownerUserId) {
            return [];
        }

        return Identity::query()
            ->where('owner_user_id', $ownerUserId)
            ->whereIn('type', ['organizer', 'artist', 'venue'])
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();
    }

    private function resolveOwnerUserIdForCustomer(Customer $customer): ?int
    {
        if (empty($customer->email)) {
            return null;
        }

        return User::query()
            ->where('email', $customer->email)
            ->value('id');
    }

    private function identityBelongsToCustomer(Identity $identity, Customer $customer): bool
    {
        $ownerUserId = $this->resolveOwnerUserIdForCustomer($customer);
        if (!$ownerUserId) {
            return false;
        }

        if ((int) $identity->owner_user_id === $ownerUserId) {
            return true;
        }

        return DB::table('identity_members')
            ->where('identity_id', $identity->id)
            ->where('user_id', $ownerUserId)
            ->where('status', 'active')
            ->exists();
    }

    private function resolveTopupContextFromPaymentIntent($paymentIntent, Customer $customer): ?array
    {
        $walletContext = strtolower((string) ($paymentIntent->metadata->wallet_context ?? 'personal'));
        if ($walletContext !== 'professional') {
            $wallet = $this->walletService->getOrCreateWallet($customer);

            return [
                'kind' => 'personal',
                'actor_type' => 'personal',
                'display_name' => 'Personal',
                'id' => $wallet->id,
                'wallet' => $wallet,
                'customer' => $customer,
                'balance' => round((float) $wallet->balance, 2),
            ];
        }

        $identityId = (int) ($paymentIntent->metadata->identity_id ?? 0);
        if ($identityId <= 0) {
            return null;
        }

        $identity = Identity::query()
            ->where('id', $identityId)
            ->whereIn('type', ['organizer', 'artist', 'venue'])
            ->where('status', 'active')
            ->first();

        if (!$identity || !$this->identityBelongsToCustomer($identity, $customer)) {
            return null;
        }

        return $this->professionalContext($identity);
    }

    private function applyProfessionalTopup(array $context, float $amount, string $paymentIntentId, float $fee = 0, float $totalCharge = 0, array $meta = []): IdentityBalanceTransaction
    {
        $identity = $context['identity'];
        $identityId = (int) $identity->id;
        $legacyId = $context['legacy_id'] ?? null;

        return DB::transaction(function () use ($identity, $identityId, $legacyId, $amount, $paymentIntentId, $fee, $totalCharge, $meta) {
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
                'organizer' => $this->professionalBalanceService->creditOrganizerBalance($identityId, $legacyId, $amount),
                'artist' => $this->professionalBalanceService->creditArtistBalance($identityId, $legacyId, $amount),
                'venue' => $this->professionalBalanceService->creditVenueBalance($identityId, $legacyId, $amount),
                default => throw new \RuntimeException('Unsupported professional balance type for top-up.'),
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
                    'fee' => $fee,
                    'total_charge' => $totalCharge,
                ], $meta),
            ]);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function buildTopupTransactionMeta(float $amount, float $fee, float $totalCharge): array
    {
        return array_merge(
            app(\App\Services\EventPaymentVerificationService::class)->buildGatewayContract('stripe', 'stripe'),
            [
                'requested_amount' => round($amount, 2),
                'fee' => round($fee, 2),
                'total_charge' => round($totalCharge, 2),
            ]
        );
    }

    private function applyWithdrawalHoldToContext(array $context, Customer $customer, float $amount, WithdrawalRequest $withdrawal): void
    {
        if ($context['kind'] === 'professional') {
            $identity = $context['identity'];
            $identityId = (int) $identity->id;
            $legacyId = $context['legacy_id'] ?? null;

            $result = match ($identity->type) {
                'organizer' => $this->professionalBalanceService->debitOrganizerBalance($identityId, $legacyId, $amount),
                'artist' => $this->professionalBalanceService->debitArtistBalance($identityId, $legacyId, $amount),
                'venue' => $this->professionalBalanceService->debitVenueBalance($identityId, $legacyId, $amount),
                default => throw new \RuntimeException('Unsupported professional balance type for withdrawal.'),
            };

            IdentityBalanceTransaction::query()->create([
                'identity_id' => $identityId,
                'type' => 'debit',
                'amount' => $amount,
                'description' => 'Withdrawal hold',
                'reference_type' => 'withdrawal_hold',
                'reference_id' => (string) $withdrawal->id,
                'balance_before' => $result['pre_balance'] ?? 0,
                'balance_after' => $result['after_balance'] ?? 0,
                'meta' => [
                    'actor_type' => $identity->type,
                    'display_name' => $identity->display_name,
                ],
            ]);

            return;
        }

        $this->walletService->debit(
            $customer,
            $amount,
            'withdrawal_hold',
            (string) $withdrawal->id,
            'WD-REQ-' . $withdrawal->id
        );
    }

    private function resolveWalletContext(Request $request, Customer $customer): array
    {
        $identity = $request->get('active_identity');

        if (!$identity instanceof Identity) {
            $requestedIdentityId = (int) ($request->header('X-Identity-Id') ?? $request->input('identity_id') ?? 0);
            if ($requestedIdentityId > 0) {
                $candidate = Identity::query()
                    ->where('id', $requestedIdentityId)
                    ->whereIn('type', ['organizer', 'artist', 'venue'])
                    ->where('status', 'active')
                    ->first();

                if ($candidate && $this->identityBelongsToCustomer($candidate, $customer)) {
                    $identity = $candidate;
                }
            }
        }

        if ($identity instanceof Identity && in_array($identity->type, ['organizer', 'artist', 'venue'], true)) {
            return $this->professionalContext($identity);
        }

        $wallet = $this->walletService->getOrCreateWallet($customer);

        return [
            'kind' => 'personal',
            'actor_type' => 'personal',
            'display_name' => 'Personal',
            'id' => $wallet->id,
            'wallet' => $wallet,
            'customer' => $customer,
            'balance' => round((float) $wallet->balance, 2),
        ];
    }

    private function resolveTargetContext(string $target, Customer $viewer): ?array
    {
        $normalized = trim($target);
        if ($normalized === '') {
            return null;
        }

        if (str_contains($normalized, '@')) {
            $customer = Customer::where('email', $normalized)->first();
            if ($customer) {
                $wallet = $this->walletService->getOrCreateWallet($customer);

                return [
                    'kind' => 'personal',
                    'actor_type' => 'personal',
                    'display_name' => 'Personal',
                    'id' => $wallet->id,
                    'wallet' => $wallet,
                    'customer' => $customer,
                    'balance' => round((float) $wallet->balance, 2),
                ];
            }
        }

        if (ctype_digit($normalized)) {
            $identity = Identity::where('id', (int) $normalized)
                ->where('status', 'active')
                ->first();

            if ($identity) {
                if ($identity->type === 'personal') {
                    $customer = $this->resolveCustomerForIdentity($identity, $viewer);
                    if (!$customer) {
                        return null;
                    }

                    $wallet = $this->walletService->getOrCreateWallet($customer);

                    return [
                        'kind' => 'personal',
                        'actor_type' => 'personal',
                        'display_name' => 'Personal',
                        'id' => $wallet->id,
                        'wallet' => $wallet,
                        'customer' => $customer,
                        'balance' => round((float) $wallet->balance, 2),
                    ];
                }

                if (in_array($identity->type, ['organizer', 'artist', 'venue'], true)) {
                    return $this->professionalContext($identity);
                }
            }
        }

        $wallet = Wallet::find($normalized);
        if (!$wallet) {
            return null;
        }

        $actorType = strtolower((string) ($wallet->actor_type ?? 'customer'));
        if ($actorType === 'customer') {
            $customer = Customer::find($wallet->actor_id ?: $wallet->user_id);
            if (!$customer) {
                return null;
            }

            return [
                'kind' => 'personal',
                'actor_type' => 'personal',
                'display_name' => 'Personal',
                'id' => $wallet->id,
                'wallet' => $wallet,
                'customer' => $customer,
                'balance' => round((float) $wallet->balance, 2),
            ];
        }

        if ($actorType === 'artist') {
            $identity = Identity::where('type', 'artist')
                ->where(function ($query) use ($wallet) {
                    $query->where('meta->id', (int) $wallet->actor_id)
                        ->orWhere('meta->legacy_id', (int) $wallet->actor_id);
                })
                ->where('status', 'active')
                ->first();

            if ($identity) {
                return $this->professionalContext($identity);
            }
        }

        if ($actorType === 'user') {
            $user = User::find($wallet->actor_id ?: $wallet->user_id);
            if ($user) {
                $customer = Customer::where('email', $user->email)->first();
                if ($customer) {
                    return [
                        'kind' => 'personal',
                        'actor_type' => 'personal',
                        'display_name' => 'Personal',
                        'id' => $wallet->id,
                        'wallet' => $wallet,
                        'customer' => $customer,
                        'balance' => round((float) $wallet->balance, 2),
                    ];
                }
            }
        }

        return null;
    }

    private function professionalContext(Identity $identity): array
    {
        $legacyId = (int) ($identity->meta['legacy_id'] ?? $identity->meta['id'] ?? 0);
        $balance = match ($identity->type) {
            'organizer' => $this->professionalBalanceService->currentOrganizerBalance((int) $identity->id, $legacyId ?: null),
            'artist' => $this->professionalBalanceService->currentArtistBalance((int) $identity->id, $legacyId ?: null),
            'venue' => $this->professionalBalanceService->currentVenueBalance((int) $identity->id, $legacyId ?: null),
            default => 0.0,
        };

        return [
            'kind' => 'professional',
            'actor_type' => $identity->type,
            'display_name' => $identity->display_name,
            'id' => (string) $identity->id,
            'identity' => $identity,
            'legacy_id' => $legacyId ?: null,
            'balance' => round((float) $balance, 2),
        ];
    }

    private function professionalCommercialTransactions(array $context)
    {
        if (($context['kind'] ?? null) !== 'professional') {
            return collect();
        }

        if (!Schema::hasTable('transactions')) {
            return collect();
        }

        $identityId = (int) ($context['id'] ?? 0);
        $legacyId = $context['legacy_id'] ?? null;

        $query = Transaction::query()
            ->when(
                ($context['actor_type'] ?? null) === 'organizer',
                fn ($builder) => $builder->ownedByOrganizerActor($identityId, $legacyId)
            )
            ->when(
                ($context['actor_type'] ?? null) === 'venue',
                fn ($builder) => $builder->ownedByVenueActor($identityId, $legacyId)
            )
            ->when(
                ($context['actor_type'] ?? null) === 'artist',
                fn ($builder) => $builder->ownedByArtistActor($identityId, $legacyId)
            )
            ->latest()
            ->limit(50)
            ->get();

        return $query->map(function (Transaction $transaction) {
            $preBalance = round((float) ($transaction->pre_balance ?? 0), 2);
            $afterBalance = $transaction->after_balance !== null
                ? round((float) $transaction->after_balance, 2)
                : null;
            $delta = $afterBalance !== null
                ? round($afterBalance - $preBalance, 2)
                : round((float) ($transaction->grand_total ?? 0) - (float) ($transaction->commission ?? 0), 2);

            return [
                'id' => 'txn-' . $transaction->id,
                'type' => $delta < 0 ? 'debit' : 'credit',
                'amount' => abs($delta),
                'reference_id' => (string) ($transaction->booking_id ?: $transaction->transcation_id),
                'description' => $this->professionalTransactionDescription($transaction),
                'created_at' => optional($transaction->created_at)?->toISOString(),
            ];
        });
    }

    private function professionalTransactionDescription(Transaction $transaction): string
    {
        return match ((int) $transaction->transcation_type) {
            1 => 'Event booking income',
            4 => ((float) ($transaction->after_balance ?? 0) < (float) ($transaction->pre_balance ?? 0))
                ? 'Balance adjustment out'
                : 'Balance adjustment in',
            default => 'Professional wallet activity',
        };
    }

    private function resolveCustomerForIdentity(Identity $identity, ?Customer $fallback = null): ?Customer
    {
        if ($identity->type !== 'personal') {
            return null;
        }

        if ($fallback && (int) $identity->owner_user_id > 0) {
            $owner = User::find((int) $identity->owner_user_id);
            if ($owner && !empty($owner->email) && $owner->email === $fallback->email) {
                return $fallback;
            }
        }

        $owner = User::find((int) $identity->owner_user_id);
        if (!$owner || empty($owner->email)) {
            return null;
        }

        return Customer::where('email', $owner->email)->first();
    }

    private function contextKey(array $context): string
    {
        return implode(':', [
            $context['kind'] ?? 'unknown',
            $context['actor_type'] ?? 'unknown',
            (string) ($context['id'] ?? '0'),
        ]);
    }

    private function previewBalance(array $context, float $amount, bool $isDebit): array
    {
        if ($context['kind'] === 'professional') {
            $identity = $context['identity'];
            $identityId = (int) $identity->id;
            $legacyId = $context['legacy_id'] ?? null;

            return match ($identity->type) {
                'organizer' => $isDebit
                    ? $this->professionalBalanceService->previewOrganizerDebit($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->previewOrganizerCredit($identityId, $legacyId, $amount),
                'artist' => $isDebit
                    ? $this->professionalBalanceService->previewArtistDebit($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->previewArtistCredit($identityId, $legacyId, $amount),
                'venue' => $isDebit
                    ? $this->professionalBalanceService->previewVenueDebit($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->previewVenueCredit($identityId, $legacyId, $amount),
                default => ['pre_balance' => 0.0, 'after_balance' => 0.0],
            };
        }

        $wallet = $context['wallet'];
        $pre = round((float) $wallet->balance, 2);

        return [
            'pre_balance' => $pre,
            'after_balance' => round($pre + ($isDebit ? -$amount : $amount), 2),
        ];
    }

    private function mutateContextBalance(array $context, float $amount, bool $isDebit, string $referenceId): array
    {
        if ($context['kind'] === 'professional') {
            $identity = $context['identity'];
            $identityId = (int) $identity->id;
            $legacyId = $context['legacy_id'] ?? null;

            $result = match ($identity->type) {
                'organizer' => $isDebit
                    ? $this->professionalBalanceService->debitOrganizerBalance($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->creditOrganizerBalance($identityId, $legacyId, $amount),
                'artist' => $isDebit
                    ? $this->professionalBalanceService->debitArtistBalance($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->creditArtistBalance($identityId, $legacyId, $amount),
                'venue' => $isDebit
                    ? $this->professionalBalanceService->debitVenueBalance($identityId, $legacyId, $amount)
                    : $this->professionalBalanceService->creditVenueBalance($identityId, $legacyId, $amount),
                default => throw new \RuntimeException('Unsupported professional balance type.'),
            };

            $description = $isDebit ? 'Wallet transfer sent' : 'Wallet transfer received';

            IdentityBalanceTransaction::query()->create([
                'identity_id' => $identityId,
                'type' => $isDebit ? 'debit' : 'credit',
                'amount' => $amount,
                'description' => $description,
                'reference_type' => 'wallet_transfer',
                'reference_id' => $referenceId,
                'balance_before' => $result['pre_balance'] ?? 0,
                'balance_after' => $result['after_balance'] ?? 0,
                'meta' => [
                    'actor_type' => $identity->type,
                    'display_name' => $identity->display_name,
                ],
            ]);

            return [
                'kind' => 'professional',
                'actor_type' => $identity->type,
                'display_name' => $identity->display_name,
                'id' => (string) $identity->id,
                'reference_id' => $referenceId,
                'balance_before' => $result['pre_balance'] ?? 0,
                'balance_after' => $result['after_balance'] ?? 0,
            ];
        }

        $customer = $context['customer'];
        $idempotencyKey = ($isDebit ? 'WALLET-TRANSFER-OUT-' : 'WALLET-TRANSFER-IN-') . $referenceId . '-' . ($context['id'] ?? 'wallet');

        $transaction = $isDebit
            ? $this->walletService->debit($customer, $amount, 'wallet_transfer', $referenceId, $idempotencyKey)
            : $this->walletService->credit($customer, $amount, 'wallet_transfer', $referenceId, $idempotencyKey);

        if (Schema::hasColumn('wallet_transactions', 'description')) {
            $description = $isDebit ? 'Wallet transfer sent' : 'Wallet transfer received';
            $transaction->description = $description;
            $transaction->save();
        }

        $transaction->wallet->refresh();

        return [
            'kind' => 'personal',
            'actor_type' => 'personal',
            'display_name' => 'Personal',
            'id' => (string) $transaction->wallet_id,
            'reference_id' => $referenceId,
            'balance_before' => round((float) $context['balance'], 2),
            'balance_after' => round((float) $transaction->wallet->balance, 2),
            'transaction_id' => $transaction->id,
        ];
    }

    private function resolveActorType($actor): string
    {
        if ($actor instanceof User) {
            return 'user';
        }

        return 'customer';
    }
}
