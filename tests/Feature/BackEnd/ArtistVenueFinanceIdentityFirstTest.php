<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Artist\WithdrawController as ArtistWithdrawController;
use App\Http\Controllers\BackEnd\Venue\WithdrawController as VenueWithdrawController;
use App\Models\Artist;
use App\Models\Transaction;
use App\Models\Venue;
use App\Models\Withdraw;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;
use Tests\Support\ActorFeatureTestCase;

class ArtistVenueFinanceIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'users',
        'identities',
        'identity_members',
        'artists',
        'venues',
        'transactions',
        'withdraws',
        'withdraw_payment_methods',
        'identity_balances',
        'basic_settings',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureFinanceTables();
        $this->seedActors();
        $this->seedCurrencySettings();
        Session::start();
    }

    public function test_artist_withdraw_request_stores_identity_id_on_withdraw_and_transaction(): void
    {
        DB::table('withdraw_payment_methods')->insert([
            'id' => 7,
            'name' => 'Artist payout',
            'min_limit' => 10,
            'max_limit' => 1000,
            'fixed_charge' => 5,
            'percentage_charge' => 10,
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Auth::guard('artist')->login(Artist::findOrFail(51));

        $request = Request::create('/artist/withdraw/store', 'POST', [
            'withdraw_method_id' => 7,
            'amount' => 100,
            'additional_reference' => 'artist-ref',
        ]);

        $response = app(ArtistWithdrawController::class)->store($request);

        $this->assertSame(302, $response->getStatusCode());
        $this->assertDatabaseHas('withdraws', [
            'artist_id' => 51,
            'artist_identity_id' => 601,
            'method_id' => 7,
            'amount' => 100,
        ]);
        $this->assertDatabaseHas('transactions', [
            'artist_id' => 51,
            'artist_identity_id' => 601,
            'transcation_type' => 3,
            'grand_total' => 100,
        ]);
        $this->assertSame(150.0, (float) DB::table('identity_balances')->where('identity_id', 601)->value('balance'));
        $this->assertSame(250.0, (float) DB::table('artists')->where('id', 51)->value('amount'));
    }

    public function test_venue_withdraw_request_stores_identity_id_on_withdraw_and_transaction(): void
    {
        DB::table('withdraw_payment_methods')->insert([
            'id' => 8,
            'name' => 'Venue payout',
            'min_limit' => 10,
            'max_limit' => 1000,
            'fixed_charge' => 10,
            'percentage_charge' => 5,
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Auth::guard('venue')->login(Venue::findOrFail(61));

        $request = Request::create('/venue/withdraw/store', 'POST', [
            'withdraw_method_id' => 8,
            'amount' => 120,
            'additional_reference' => 'venue-ref',
        ]);

        $response = app(VenueWithdrawController::class)->store($request);

        $this->assertSame(302, $response->getStatusCode());
        $this->assertDatabaseHas('withdraws', [
            'venue_id' => 61,
            'venue_identity_id' => 701,
            'method_id' => 8,
            'amount' => 120,
        ]);
        $this->assertDatabaseHas('transactions', [
            'venue_id' => 61,
            'venue_identity_id' => 701,
            'transcation_type' => 3,
            'grand_total' => 120,
        ]);
        $this->assertSame(280.0, (float) DB::table('identity_balances')->where('identity_id', 701)->value('balance'));
        $this->assertSame(400.0, (float) DB::table('venues')->where('id', 61)->value('amount'));
    }

    private function seedActors(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'artist-finance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 51,
            'name' => 'Finance Artist',
            'username' => 'finance-artist',
            'email' => 'finance-artist@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 250,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 601,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Finance Artist Identity',
            'slug' => 'finance-artist-identity',
            'meta' => json_encode(['legacy_id' => 51]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1002,
            'email' => 'venue-finance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('venues')->insert([
            'id' => 61,
            'name' => 'Finance Venue',
            'username' => 'finance-venue',
            'email' => 'finance-venue@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 400,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 701,
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 1002,
            'display_name' => 'Finance Venue Identity',
            'slug' => 'finance-venue-identity',
            'meta' => json_encode(['legacy_id' => 61]),
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
        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamp('email_verified_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamp('email_verified_at')->nullable();
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
                $table->tinyInteger('status')->default(1);
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
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->unsignedBigInteger('artist_identity_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->integer('payment_status')->nullable();
                $table->unsignedBigInteger('payment_method')->nullable();
                $table->decimal('grand_total', 15, 2)->default(0);
                $table->decimal('pre_balance', 15, 2)->default(0);
                $table->decimal('after_balance', 15, 2)->default(0);
                $table->string('gateway_type')->nullable();
                $table->string('currency_symbol')->nullable();
                $table->string('currency_symbol_position')->nullable();
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

        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('uniqid')->nullable();
                $table->decimal('marketplace_commission', 8, 2)->default(5.00);
                $table->string('base_currency_symbol')->nullable();
                $table->string('base_currency_symbol_position')->nullable();
                $table->string('base_currency_text')->nullable();
                $table->string('base_currency_text_position')->nullable();
                $table->decimal('base_currency_rate', 10, 2)->default(1);
                $table->timestamps();
            });
        }
    }
}
