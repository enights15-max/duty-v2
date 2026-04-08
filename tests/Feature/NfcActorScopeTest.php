<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\NfcToken;
use App\Models\User;
use App\Services\NFCService;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class NfcActorScopeTest extends ActorFeatureTestCase
{
    protected NFCService $nfcService;
    protected array $baselineSchema = ['users_customers', 'nfc_tokens'];
    protected array $baselineTruncate = [
        'nfc_tokens',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->nfcService = app(NFCService::class);
    }

    public function test_link_token_persists_actor_fields_for_customer(): void
    {
        DB::table('customers')->insert([
            'id' => 5,
            'email' => 'nfc-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(5);
        $token = $this->nfcService->linkToken($customer, 'UID-RAW-123', '1234');

        $this->assertNotNull($token->id);
        $this->assertEquals('customer', $token->actor_type);
        $this->assertEquals(5, (int) $token->actor_id);
        $this->assertEquals(5, (int) $token->user_id);
        $this->assertEquals('active', $token->status);
        $this->assertNotEmpty($token->uid_hash);
        $this->assertNotEmpty($token->pin_hash);
    }

    public function test_nfc_scope_for_actor_isolated_by_actor_type(): void
    {
        DB::table('customers')->insert([
            'id' => 11,
            'email' => 'scope-nfc-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 11,
            'email' => 'scope-nfc-user@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('nfc_tokens')->insert([
            [
                'id' => '33333333-3333-4333-8333-333333333333',
                'user_id' => 11,
                'actor_type' => 'customer',
                'actor_id' => 11,
                'uid_hash' => 'hash_customer',
                'pin_hash' => null,
                'status' => 'active',
                'daily_limit' => 5000.00,
                'daily_spent' => 0.00,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '44444444-4444-4444-8444-444444444444',
                'user_id' => 11,
                'actor_type' => 'user',
                'actor_id' => 11,
                'uid_hash' => 'hash_user',
                'pin_hash' => null,
                'status' => 'active',
                'daily_limit' => 5000.00,
                'daily_spent' => 0.00,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $customer = Customer::findOrFail(11);
        $user = User::findOrFail(11);

        $customerTokenIds = NfcToken::forActor($customer)->pluck('id')->all();
        $userTokenIds = NfcToken::forActor($user)->pluck('id')->all();

        $this->assertEquals(['33333333-3333-4333-8333-333333333333'], $customerTokenIds);
        $this->assertEquals(['44444444-4444-4444-8444-444444444444'], $userTokenIds);
    }

}
