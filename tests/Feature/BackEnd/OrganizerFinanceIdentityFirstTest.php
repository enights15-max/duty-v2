<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Organizer\OrganizerWithdrawController;
use App\Http\Requests\WithdrawRequest;
use App\Models\Organizer;
use App\Models\Transaction;
use App\Models\Withdraw;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class OrganizerFinanceIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'marketplace'];
    protected array $baselineTruncate = [
        'users',
        'customers',
        'identities',
        'identity_members',
        'organizers',
        'organizer_infos',
        'transactions',
        'withdraws',
        'withdraw_payment_methods',
        'withdraw_method_inputs',
        'identity_balances',
        'basic_settings',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureFinanceTables();
        $this->seedOrganizerActor();
        $this->seedCurrencySettings();
    }

    public function test_transaction_scope_prefers_identity_and_only_falls_back_when_identity_is_missing(): void
    {
        DB::table('transactions')->insert([
            [
                'id' => 1,
                'transcation_id' => 'txn-1',
                'organizer_id' => 41,
                'organizer_identity_id' => 501,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'transcation_id' => 'txn-2',
                'organizer_id' => 41,
                'organizer_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3,
                'transcation_id' => 'txn-3',
                'organizer_id' => 41,
                'organizer_identity_id' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ids = Transaction::query()
            ->ownedByOrganizerActor(501, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([1, 2], $ids);
    }

    public function test_withdraw_scope_prefers_identity_and_only_falls_back_when_identity_is_missing(): void
    {
        DB::table('withdraws')->insert([
            [
                'id' => 11,
                'withdraw_id' => 'wd-11',
                'organizer_id' => 41,
                'organizer_identity_id' => 501,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 12,
                'withdraw_id' => 'wd-12',
                'organizer_id' => 41,
                'organizer_identity_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 13,
                'withdraw_id' => 'wd-13',
                'organizer_id' => 41,
                'organizer_identity_id' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $ids = Withdraw::query()
            ->ownedByOrganizerActor(501, 41)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $this->assertSame([11, 12], $ids);
    }

    public function test_organizer_withdraw_request_stores_identity_id_on_withdraw_and_transaction(): void
    {
        DB::table('withdraw_payment_methods')->insert([
            'id' => 7,
            'name' => 'Bank transfer',
            'min_limit' => 10,
            'max_limit' => 1000,
            'fixed_charge' => 5,
            'percentage_charge' => 10,
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraw_method_inputs')->insert([
            'id' => 17,
            'withdraw_payment_method_id' => 7,
            'name' => 'account_number',
            'type' => 'text',
            'required' => 1,
            'order_number' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Auth::guard('organizer')->login(Organizer::findOrFail(41));

        $request = WithdrawRequest::create('/organizer/withdraw/send-request', 'POST', [
            'withdraw_method' => 7,
            'withdraw_amount' => 100,
            'account_number' => '123456789',
        ]);

        $response = app(OrganizerWithdrawController::class)->send_request($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['status']);

        $this->assertDatabaseHas('withdraws', [
            'organizer_id' => 41,
            'organizer_identity_id' => 501,
            'method_id' => 7,
            'amount' => 100,
        ]);

        $this->assertDatabaseHas('transactions', [
            'organizer_id' => 41,
            'organizer_identity_id' => 501,
            'transcation_type' => 3,
            'grand_total' => 100,
        ]);
    }

    private function seedOrganizerActor(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'organizer-finance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'finance-organizer',
            'email' => 'finance-organizer@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 500,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Finance Organizer Identity',
            'slug' => 'finance-organizer-identity',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedCurrencySettings(): void
    {
        $defaults = [
            'uniqid' => 12345,
            'marketplace_commission' => 5,
            'base_currency_symbol' => '$',
            'base_currency_symbol_position' => 'left',
            'base_currency_text' => 'USD',
            'base_currency_text_position' => 'right',
            'base_currency_rate' => 1,
        ];

        if (!DB::table('basic_settings')->where('uniqid', 12345)->exists()) {
            DB::table('basic_settings')->insert(array_merge($defaults, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));
            return;
        }

        DB::table('basic_settings')
            ->where('uniqid', 12345)
            ->update($defaults);
    }

    private function ensureFinanceTables(): void
    {
        if (Schema::hasTable('basic_settings')) {
            $basicColumns = [
                'base_currency_symbol' => fn (Blueprint $table) => $table->string('base_currency_symbol')->nullable(),
                'base_currency_symbol_position' => fn (Blueprint $table) => $table->string('base_currency_symbol_position')->nullable(),
                'base_currency_text' => fn (Blueprint $table) => $table->string('base_currency_text')->nullable(),
                'base_currency_text_position' => fn (Blueprint $table) => $table->string('base_currency_text_position')->nullable(),
                'base_currency_rate' => fn (Blueprint $table) => $table->decimal('base_currency_rate', 10, 2)->default(1),
            ];

            foreach ($basicColumns as $column => $definition) {
                if (Schema::hasColumn('basic_settings', $column)) {
                    continue;
                }

                Schema::table('basic_settings', function (Blueprint $table) use ($definition): void {
                    $definition($table);
                });
            }
        }

        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->string('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('payment_method')->nullable();
                $table->integer('payment_status')->nullable();
                $table->decimal('grand_total', 15, 2)->default(0);
                $table->decimal('pre_balance', 15, 2)->nullable();
                $table->decimal('after_balance', 15, 2)->nullable();
                $table->decimal('commission', 15, 2)->nullable();
                $table->decimal('tax', 15, 2)->nullable();
                $table->string('gateway_type')->nullable();
                $table->string('currency_symbol')->nullable();
                $table->string('currency_symbol_position')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('withdraws')) {
            Schema::create('withdraws', function (Blueprint $table): void {
                $table->id();
                $table->string('withdraw_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('method_id')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->decimal('payable_amount', 15, 2)->default(0);
                $table->decimal('total_charge', 15, 2)->default(0);
                $table->string('additional_reference')->nullable();
                $table->longText('feilds')->nullable();
                $table->integer('status')->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('withdraw_payment_methods')) {
            Schema::create('withdraw_payment_methods', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->decimal('min_limit', 15, 2)->default(0);
                $table->decimal('max_limit', 15, 2)->default(0);
                $table->decimal('fixed_charge', 15, 2)->default(0);
                $table->decimal('percentage_charge', 15, 2)->default(0);
                $table->integer('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_balances')) {
            Schema::create('identity_balances', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('identity_id')->unique();
                $table->string('legacy_type')->nullable();
                $table->unsignedBigInteger('legacy_id')->nullable();
                $table->decimal('balance', 15, 2)->default(0);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('withdraw_method_inputs')) {
            Schema::create('withdraw_method_inputs', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('withdraw_payment_method_id')->nullable();
                $table->string('name')->nullable();
                $table->string('type')->nullable();
                $table->integer('required')->default(0);
                $table->integer('order_number')->default(0);
                $table->timestamps();
            });
        }
    }
}
