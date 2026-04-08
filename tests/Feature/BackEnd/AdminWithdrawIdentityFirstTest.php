<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\WithdrawController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;
use Tests\Support\ActorFeatureTestCase;

class AdminWithdrawIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'users',
        'customers',
        'identities',
        'identity_members',
        'organizers',
        'artists',
        'venues',
        'identity_balances',
        'transactions',
        'withdraws',
        'withdraw_payment_methods',
        'basic_settings',
        'mail_templates',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureAdminWithdrawTables();
        $this->seedCurrencySettings();
        $this->seedMailTemplates();
        Session::start();
    }

    public function test_admin_withdraw_index_hydrates_actor_name_from_identity_first(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'identity-organizer@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Identity First Organizer',
            'slug' => 'identity-first-organizer',
            'meta' => json_encode(['contact_email' => 'ops@identity-first.test']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraw_payment_methods')->insert([
            'id' => 7,
            'name' => 'Bank transfer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraws')->insert([
            'id' => 11,
            'withdraw_id' => 'wd-11',
            'organizer_identity_id' => 501,
            'organizer_id' => null,
            'method_id' => 7,
            'amount' => 100,
            'payable_amount' => 90,
            'total_charge' => 10,
            'status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $view = app(WithdrawController::class)->index();
        $data = $view->getData();
        $items = $data['collection']->items();

        $this->assertCount(1, $items);
        $this->assertSame('Identity First Organizer', $items[0]->actor_name);
        $this->assertSame('ops@identity-first.test', $items[0]->actor_email);
    }

    public function test_admin_can_approve_identity_only_withdraw_without_legacy_organizer_row(): void
    {
        DB::table('users')->insert([
            'id' => 1002,
            'email' => 'approve@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 502,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1002,
            'display_name' => 'Approve Identity Organizer',
            'slug' => 'approve-identity-organizer',
            'meta' => json_encode([]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraw_payment_methods')->insert([
            'id' => 8,
            'name' => 'Wire transfer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraws')->insert([
            'id' => 21,
            'withdraw_id' => 'wd-21',
            'organizer_identity_id' => 502,
            'organizer_id' => null,
            'method_id' => 8,
            'amount' => 250,
            'payable_amount' => 225,
            'total_charge' => 25,
            'status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('transactions')->insert([
            'id' => 31,
            'transcation_id' => 'txn-31',
            'booking_id' => 21,
            'transcation_type' => 3,
            'payment_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(WithdrawController::class)->approve(21);

        $this->assertSame(302, $response->getStatusCode());
        $this->assertDatabaseHas('withdraws', [
            'id' => 21,
            'status' => 1,
        ]);
        $this->assertDatabaseHas('transactions', [
            'id' => 31,
            'payment_status' => 1,
        ]);
    }

    public function test_admin_decline_returns_balance_to_legacy_organizer_and_marks_transaction_declined(): void
    {
        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'legacy-organizer',
            'email' => 'legacy-organizer@example.com',
            'amount' => 400,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1003,
            'email' => 'legacy-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 503,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1003,
            'display_name' => 'Legacy Linked Identity',
            'slug' => 'legacy-linked-identity',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraw_payment_methods')->insert([
            'id' => 9,
            'name' => 'Bank payout',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraws')->insert([
            'id' => 22,
            'withdraw_id' => 'wd-22',
            'organizer_identity_id' => 503,
            'organizer_id' => 41,
            'method_id' => 9,
            'amount' => 100,
            'payable_amount' => 90,
            'total_charge' => 10,
            'status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('transactions')->insert([
            'id' => 32,
            'transcation_id' => 'txn-32',
            'booking_id' => 22,
            'transcation_type' => 3,
            'payment_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(WithdrawController::class)->decline(22);

        $this->assertSame(302, $response->getStatusCode());
        $this->assertDatabaseHas('withdraws', [
            'id' => 22,
            'status' => 2,
        ]);
        $this->assertDatabaseHas('transactions', [
            'id' => 32,
            'payment_status' => 2,
        ]);
        $this->assertSame(500.0, (float) DB::table('identity_balances')->where('identity_id', 503)->value('balance'));
        $this->assertSame(400.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
    }

    public function test_admin_withdraw_index_hydrates_venue_actor_name_from_identity_first(): void
    {
        DB::table('users')->insert([
            'id' => 1004,
            'email' => 'venue-identity@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 504,
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 1004,
            'display_name' => 'Identity First Venue',
            'slug' => 'identity-first-venue',
            'meta' => json_encode(['contact_email' => 'ops@identity-venue.test']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraw_payment_methods')->insert([
            'id' => 10,
            'name' => 'Venue bank transfer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('withdraws')->insert([
            'id' => 33,
            'withdraw_id' => 'wd-33',
            'venue_identity_id' => 504,
            'venue_id' => null,
            'method_id' => 10,
            'amount' => 140,
            'payable_amount' => 126,
            'total_charge' => 14,
            'status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $view = app(WithdrawController::class)->index();
        $data = $view->getData();
        $items = collect($data['collection']->items())->keyBy('id');

        $this->assertSame('Identity First Venue', $items[33]->actor_name);
        $this->assertSame('ops@identity-venue.test', $items[33]->actor_email);
        $this->assertSame('venue', $items[33]->actor_type);
    }

    private function seedCurrencySettings(): void
    {
        $defaults = [
            'uniqid' => 12345,
            'website_title' => 'Duty',
            'smtp_status' => 0,
            'smtp_host' => 'localhost',
            'smtp_port' => 1025,
            'encryption' => 'TLS',
            'smtp_username' => 'demo',
            'smtp_password' => 'demo',
            'from_mail' => 'noreply@example.com',
            'from_name' => 'Duty',
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

        DB::table('basic_settings')->where('uniqid', 12345)->update($defaults);
    }

    private function seedMailTemplates(): void
    {
        $templates = [
            [
                'mail_type' => 'withdraw_approve',
                'mail_subject' => 'Withdraw approved',
                'mail_body' => 'Hello {organizer_username}, {withdraw_id} {current_balance} {withdraw_amount} {charge} {payable_amount} {withdraw_method} {website_title}',
            ],
            [
                'mail_type' => 'withdraw_rejected',
                'mail_subject' => 'Withdraw rejected',
                'mail_body' => 'Hello {organizer_username}, {withdraw_id} {current_balance} {website_title}',
            ],
        ];

        foreach ($templates as $template) {
            if (!DB::table('mail_templates')->where('mail_type', $template['mail_type'])->exists()) {
                DB::table('mail_templates')->insert($template);
                continue;
            }

            DB::table('mail_templates')
                ->where('mail_type', $template['mail_type'])
                ->update($template);
        }
    }

    private function ensureAdminWithdrawTables(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('uniqid')->nullable();
                $table->string('website_title')->nullable();
                $table->integer('smtp_status')->default(0);
                $table->string('smtp_host')->nullable();
                $table->integer('smtp_port')->nullable();
                $table->string('encryption')->nullable();
                $table->string('smtp_username')->nullable();
                $table->string('smtp_password')->nullable();
                $table->string('from_mail')->nullable();
                $table->string('from_name')->nullable();
                $table->string('base_currency_symbol')->nullable();
                $table->string('base_currency_symbol_position')->nullable();
                $table->string('base_currency_text')->nullable();
                $table->string('base_currency_text_position')->nullable();
                $table->decimal('base_currency_rate', 10, 2)->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('mail_templates')) {
            Schema::create('mail_templates', function (Blueprint $table): void {
                $table->id();
                $table->string('mail_type')->nullable();
                $table->string('mail_subject')->nullable();
                $table->longText('mail_body')->nullable();
            });
        }

        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('name')->nullable();
                $table->string('email')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('name')->nullable();
                $table->string('email')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('withdraw_payment_methods')) {
            Schema::create('withdraw_payment_methods', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('withdraws')) {
            Schema::create('withdraws', function (Blueprint $table): void {
                $table->id();
                $table->string('withdraw_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->unsignedBigInteger('artist_identity_id')->nullable();
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

        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->string('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->integer('payment_status')->nullable();
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
    }
}
