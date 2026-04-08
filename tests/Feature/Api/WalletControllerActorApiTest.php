<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\WalletController;
use App\Models\Customer;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class WalletControllerActorApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'withdrawal_requests', 'identities', 'legacy_identity_sources'];
    protected array $baselineTruncate = [
        'wallet_transactions',
        'wallets',
        'withdrawal_requests',
        'identity_balances',
        'identity_balance_transactions',
        'identity_members',
        'identities',
        'organizers',
        'artists',
        'venues',
        'customers',
        'users',
    ];

    public function test_customer_can_request_withdrawal_and_wallet_is_debited(): void
    {
        DB::table('customers')->insert([
            'id' => 201,
            'email' => 'wallet-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '20100000-0000-4000-8000-000000000001',
            'user_id' => 201,
            'actor_type' => 'customer',
            'actor_id' => 201,
            'balance' => 100.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet/withdraw', 'POST', [
            'amount' => 30,
            'method' => 'bank_transfer',
            'payment_details' => ['account' => '1234'],
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(201));

        $response = app(WalletController::class)->requestWithdrawal($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);

        $this->assertDatabaseHas('withdrawal_requests', [
            'customer_id' => 201,
            'amount' => '30.00',
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'wallet_id' => '20100000-0000-4000-8000-000000000001',
            'type' => 'debit',
            'amount' => '30.00',
            'reference_type' => 'withdrawal_hold',
            'status' => 'completed',
        ]);

        $this->assertEquals('70.00', DB::table('wallets')->where('id', '20100000-0000-4000-8000-000000000001')->value('balance'));
    }

    public function test_withdrawal_fails_when_wallet_has_insufficient_funds(): void
    {
        DB::table('customers')->insert([
            'id' => 202,
            'email' => 'wallet-low-funds@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '20200000-0000-4000-8000-000000000001',
            'user_id' => 202,
            'actor_type' => 'customer',
            'actor_id' => 202,
            'balance' => 20.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet/withdraw', 'POST', [
            'amount' => 30,
            'method' => 'bank_transfer',
            'payment_details' => ['account' => '1234'],
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(202));

        $response = app(WalletController::class)->requestWithdrawal($request);
        $payload = $response->getData(true);

        $this->assertEquals(400, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Insufficient funds for withdrawal.', $payload['message']);

        $this->assertDatabaseCount('withdrawal_requests', 0);
        $this->assertDatabaseCount('wallet_transactions', 0);
        $this->assertEquals('20.00', DB::table('wallets')->where('id', '20200000-0000-4000-8000-000000000001')->value('balance'));
    }

    public function test_get_wallet_rejects_non_customer_actor(): void
    {
        DB::table('users')->insert([
            'id' => 203,
            'email' => 'wallet-admin@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet', 'GET');
        $request->setUserResolver(fn () => User::findOrFail(203));

        $response = app(WalletController::class)->getWallet($request);
        $payload = $response->getData(true);

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Invalid authenticated actor.', $payload['message']);
    }

    public function test_preview_topup_returns_gateway_contract_metadata(): void
    {
        DB::table('customers')->insert([
            'id' => 208,
            'email' => 'wallet-topup-preview@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet/topup-preview', 'POST', [
            'amount' => 75,
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(208));

        $response = app(WalletController::class)->previewTopup($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertSame('stripe', data_get($payload, 'data.gateway'));
        $this->assertSame('stripe_card', data_get($payload, 'data.gateway_family'));
        $this->assertSame('online_card_capture', data_get($payload, 'data.verification_strategy'));
    }

    public function test_check_topup_status_rejects_transaction_from_other_actor(): void
    {
        DB::table('customers')->insert([
            'id' => 204,
            'email' => 'wallet-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 205,
            'email' => 'wallet-other@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '20400000-0000-4000-8000-000000000001',
            'user_id' => 204,
            'actor_type' => 'customer',
            'actor_id' => 204,
            'balance' => 50.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallet_transactions')->insert([
            'id' => '20400000-0000-4000-8000-000000000999',
            'wallet_id' => '20400000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'amount' => 25.00,
            'fee' => 0.00,
            'total_amount' => 25.00,
            'reference_type' => 'topup',
            'reference_id' => 'pi_shared_status',
            'idempotency_key' => 'TOPUP-pi_shared_status',
            'status' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet/topup-status/pi_shared_status', 'GET');
        $request->setUserResolver(fn () => Customer::findOrFail(205));

        $response = app(WalletController::class)->checkTopupStatus($request, 'pi_shared_status');
        $payload = $response->getData(true);

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Transaction does not belong to this actor.', $payload['message']);
    }

    public function test_confirm_topup_rejects_existing_transaction_from_other_actor(): void
    {
        DB::table('customers')->insert([
            'id' => 206,
            'email' => 'wallet-owner-confirm@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 207,
            'email' => 'wallet-other-confirm@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '20600000-0000-4000-8000-000000000001',
            'user_id' => 206,
            'actor_type' => 'customer',
            'actor_id' => 206,
            'balance' => 50.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallet_transactions')->insert([
            'id' => '20600000-0000-4000-8000-000000000999',
            'wallet_id' => '20600000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'amount' => 25.00,
            'fee' => 0.00,
            'total_amount' => 25.00,
            'reference_type' => 'topup',
            'reference_id' => 'pi_shared_confirm',
            'idempotency_key' => 'TOPUP-pi_shared_confirm',
            'status' => 'completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/customers/wallet/topup-confirm/pi_shared_confirm', 'POST');
        $request->setUserResolver(fn () => Customer::findOrFail(207));

        $response = app(WalletController::class)->confirmTopup($request, 'pi_shared_confirm');
        $payload = $response->getData(true);

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Transaction does not belong to this actor.', $payload['message']);
    }

    public function test_get_wallet_uses_active_professional_identity_balance(): void
    {
        DB::table('users')->insert([
            'id' => 301,
            'email' => 'organizer-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 301,
            'email' => 'organizer-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 901,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 301,
            'display_name' => 'Night Organizer',
            'slug' => 'night-organizer',
            'meta' => json_encode(['legacy_id' => 701]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 901,
            'user_id' => 301,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 701,
            'email' => 'organizer-owner@example.com',
            'amount' => 150.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 901,
            'legacy_type' => 'organizer',
            'legacy_id' => 701,
            'balance' => 150.00,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(301), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '901')
            ->getJson($this->apiUrl('/api/customers/wallet'));

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('wallet.id', '901')
            ->assertJsonPath('wallet.balance', 150)
            ->assertJsonPath('wallet.actor_type', 'organizer');
    }

    public function test_transfer_moves_funds_between_personal_wallets_by_wallet_id(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 302,
                'email' => 'sender-wallet@example.com',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 303,
                'email' => 'receiver-wallet@example.com',
                'password' => bcrypt('secret'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('wallets')->insert([
            [
                'id' => '30200000-0000-4000-8000-000000000001',
                'user_id' => 302,
                'actor_type' => 'customer',
                'actor_id' => 302,
                'balance' => 100.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '30300000-0000-4000-8000-000000000001',
                'user_id' => 303,
                'actor_type' => 'customer',
                'actor_id' => 303,
                'balance' => 20.00,
                'currency' => 'DOP',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs(Customer::findOrFail(302), [], 'sanctum');

        $response = $this->postJson($this->apiUrl('/api/customers/wallet/transfer'), [
            'amount' => 25,
            'target_wallet_id' => '30300000-0000-4000-8000-000000000001',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.amount', 25);

        $this->assertEquals('75.00', DB::table('wallets')->where('id', '30200000-0000-4000-8000-000000000001')->value('balance'));
        $this->assertEquals('45.00', DB::table('wallets')->where('id', '30300000-0000-4000-8000-000000000001')->value('balance'));

        $this->assertDatabaseHas('wallet_transactions', [
            'wallet_id' => '30200000-0000-4000-8000-000000000001',
            'type' => 'debit',
            'reference_type' => 'wallet_transfer',
            'status' => 'completed',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'wallet_id' => '30300000-0000-4000-8000-000000000001',
            'type' => 'credit',
            'reference_type' => 'wallet_transfer',
            'status' => 'completed',
        ]);
    }

    public function test_transfer_moves_funds_from_personal_wallet_to_professional_identity(): void
    {
        DB::table('users')->insert([
            'id' => 304,
            'email' => 'hybrid@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 304,
            'email' => 'hybrid@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '30400000-0000-4000-8000-000000000001',
            'user_id' => 304,
            'actor_type' => 'customer',
            'actor_id' => 304,
            'balance' => 200.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 904,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 304,
            'display_name' => 'Hybrid Organizer',
            'slug' => 'hybrid-organizer',
            'meta' => json_encode(['legacy_id' => 704]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 904,
            'user_id' => 304,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 704,
            'email' => 'hybrid@example.com',
            'amount' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 904,
            'legacy_type' => 'organizer',
            'legacy_id' => 704,
            'balance' => 10.00,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(304), [], 'sanctum');

        $response = $this->postJson($this->apiUrl('/api/customers/wallet/transfer'), [
            'amount' => 50,
            'target_wallet_id' => '904',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.target.actor_type', 'organizer');

        $this->assertEquals('150.00', DB::table('wallets')->where('id', '30400000-0000-4000-8000-000000000001')->value('balance'));
        $this->assertEquals('60.00', DB::table('identity_balances')->where('identity_id', 904)->value('balance'));
        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 904,
            'type' => 'credit',
            'reference_type' => 'wallet_transfer',
            'reference_id' => $response->json('data.reference_id'),
        ]);
    }

    public function test_transfer_moves_funds_from_professional_identity_to_personal_wallet(): void
    {
        DB::table('users')->insert([
            'id' => 305,
            'email' => 'pro-wallet@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 305,
            'email' => 'pro-wallet@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '30500000-0000-4000-8000-000000000001',
            'user_id' => 305,
            'actor_type' => 'customer',
            'actor_id' => 305,
            'balance' => 15.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            [
                'id' => 905,
                'type' => 'organizer',
                'status' => 'active',
                'owner_user_id' => 305,
                'display_name' => 'Pro Organizer',
                'slug' => 'pro-organizer',
                'meta' => json_encode(['legacy_id' => 705]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 906,
                'type' => 'personal',
                'status' => 'active',
                'owner_user_id' => 305,
                'display_name' => 'Personal',
                'slug' => 'personal-pro-owner',
                'meta' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('identity_members')->insert([
            [
                'identity_id' => 905,
                'user_id' => 305,
                'role' => 'owner',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'identity_id' => 906,
                'user_id' => 305,
                'role' => 'owner',
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('organizers')->insert([
            'id' => 705,
            'email' => 'pro-wallet@example.com',
            'amount' => 90.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 905,
            'legacy_type' => 'organizer',
            'legacy_id' => 705,
            'balance' => 90.00,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(305), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '905')
            ->postJson($this->apiUrl('/api/customers/wallet/transfer'), [
                'amount' => 40,
                'target_wallet_id' => '906',
            ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.source.actor_type', 'organizer');

        $this->assertEquals('50.00', DB::table('identity_balances')->where('identity_id', 905)->value('balance'));
        $this->assertEquals('55.00', DB::table('wallets')->where('id', '30500000-0000-4000-8000-000000000001')->value('balance'));
        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 905,
            'type' => 'debit',
            'reference_type' => 'wallet_transfer',
            'reference_id' => $response->json('data.reference_id'),
        ]);
    }

    public function test_get_history_returns_professional_ledger_entries_for_active_identity(): void
    {
        DB::table('users')->insert([
            'id' => 306,
            'email' => 'ledger@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 306,
            'email' => 'ledger@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 907,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 306,
            'display_name' => 'Ledger Organizer',
            'slug' => 'ledger-organizer',
            'meta' => json_encode(['legacy_id' => 706]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 907,
            'user_id' => 306,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 706,
            'email' => 'ledger@example.com',
            'amount' => 80.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 907,
            'legacy_type' => 'organizer',
            'legacy_id' => 706,
            'balance' => 80.00,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balance_transactions')->insert([
            'id' => '90700000-0000-4000-8000-000000000001',
            'identity_id' => 907,
            'type' => 'credit',
            'amount' => 20.00,
            'description' => 'Wallet transfer received',
            'reference_type' => 'wallet_transfer',
            'reference_id' => 'ledger-ref-1',
            'balance_before' => 60.00,
            'balance_after' => 80.00,
            'meta' => json_encode(['actor_type' => 'organizer']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(306), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '907')
            ->getJson($this->apiUrl('/api/customers/wallet/history'));

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'transactions')
            ->assertJsonPath('transactions.0.reference_id', 'ledger-ref-1')
            ->assertJsonPath('transactions.0.description', 'Wallet transfer received');
    }

    public function test_professional_withdrawal_debits_active_identity_balance_and_creates_contextual_request(): void
    {
        DB::table('users')->insert([
            'id' => 307,
            'email' => 'artist-withdraw@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 307,
            'email' => 'artist-withdraw@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 908,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 307,
            'display_name' => 'Withdraw Artist',
            'slug' => 'withdraw-artist',
            'meta' => json_encode(['legacy_id' => 707]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 908,
            'user_id' => 307,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 707,
            'email' => 'artist-withdraw@example.com',
            'amount' => 120.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 908,
            'legacy_type' => 'artist',
            'legacy_id' => 707,
            'balance' => 120.00,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(307), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '908')
            ->postJson($this->apiUrl('/api/customers/wallet/withdraw'), [
                'amount' => 35,
                'method' => 'bank_transfer',
                'payment_details' => ['account' => 'artist-iban'],
            ]);

        $response->assertOk()
            ->assertJsonPath('success', true);

        $this->assertEquals('85.00', DB::table('identity_balances')->where('identity_id', 908)->value('balance'));
        $this->assertDatabaseHas('withdrawal_requests', [
            'customer_id' => 307,
            'identity_id' => 908,
            'actor_type' => 'artist',
            'display_name' => 'Withdraw Artist',
            'amount' => '35.00',
            'status' => 'pending',
        ]);
        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 908,
            'type' => 'debit',
            'reference_type' => 'withdrawal_hold',
            'amount' => '35.00',
        ]);
    }

    public function test_get_withdrawals_returns_only_requests_for_active_identity_context(): void
    {
        DB::table('users')->insert([
            'id' => 308,
            'email' => 'withdraw-list@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 308,
            'email' => 'withdraw-list@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 909,
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 308,
            'display_name' => 'Withdraw Venue',
            'slug' => 'withdraw-venue',
            'meta' => json_encode(['legacy_id' => 708]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => 909,
            'user_id' => 308,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdrawal_requests')->insert([
            [
                'customer_id' => 308,
                'identity_id' => null,
                'actor_type' => 'personal',
                'display_name' => 'Personal',
                'amount' => 20.00,
                'method' => 'bank_transfer',
                'payment_details' => json_encode(['account' => 'personal']),
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'customer_id' => 308,
                'identity_id' => 909,
                'actor_type' => 'venue',
                'display_name' => 'Withdraw Venue',
                'amount' => 55.00,
                'method' => 'bank_transfer',
                'payment_details' => json_encode(['account' => 'venue']),
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Sanctum::actingAs(Customer::findOrFail(308), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', '909')
            ->getJson($this->apiUrl('/api/customers/wallet/withdrawals'));

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'withdrawals')
            ->assertJsonPath('withdrawals.0.identity_id', 909)
            ->assertJsonPath('withdrawals.0.actor_type', 'venue');
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
