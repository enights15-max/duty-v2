<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventController;
use App\Models\BonusWallet;
use App\Models\Customer;
use App\Models\Wallet;
use App\Services\BonusWalletService;
use App\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class CheckoutVerifyRegressionTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace', 'wallets', 'bonus_wallets'];
    protected array $baselineTruncate = [
        'bonus_transactions',
        'bonus_wallets',
        'wallet_transactions',
        'wallets',
        'bookings',
        'events',
        'customers',
        'users',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureCheckoutVerifySchema();
        $this->truncateCheckoutTables();
        $this->seedCheckoutDefaults();
    }

    public function test_checkout_verify_returns_controlled_response_when_event_has_no_tickets(): void
    {
        DB::table('events')->insert([
            'id' => 501,
            'event_type' => 'venue',
            'title' => 'No Tickets Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'event_guest_checkout_status' => 0,
            'event_id' => 501,
            'quantity' => 1,
            'pricing_type' => 'normal',
        ]);
        $response = app(EventController::class)->checkoutVerify($request);

        $this->assertSame([
            'success' => false,
            'message' => 'No tickets available for the selected event.',
        ], $response);
    }

    public function test_checkout_verify_uses_ticket_name_fallback_when_ticket_content_is_missing(): void
    {
        DB::table('events')->insert([
            'id' => 502,
            'event_type' => 'venue',
            'title' => 'Fallback Name Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 7001,
            'event_id' => 502,
            'event_type' => 'venue',
            'pricing_type' => 'normal',
            'price' => 500,
            'ticket_available_type' => 'limited',
            'ticket_available' => 50,
            'max_ticket_buy_type' => 'unlimited',
            'max_buy_ticket' => 0,
            'normal_ticket_slot_enable' => 0,
            'free_tickete_slot_enable' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'event_guest_checkout_status' => 1,
            'event_id' => 502,
            'quantity' => 1,
            'pricing_type' => 'normal',
        ]);
        $response = app(EventController::class)->checkoutVerify($request);
        $this->assertIsArray($response);
        $this->assertTrue((bool) ($response['success'] ?? false));
        $this->assertSame('Ticket #7001', $response['selTickets'][0]['name'] ?? null);
    }

    public function test_checkout_verify_accepts_sanctum_customer_context_for_purchase_limit_checks(): void
    {
        $customer = Customer::query()->create([
            'id' => 9101,
            'email' => 'checkout-regression@example.com',
            'username' => 'checkout_regression',
            'fname' => 'Checkout',
            'lname' => 'Regression',
            'password' => bcrypt('secret'),
        ]);

        $customerGuard = \Mockery::mock();
        $customerGuard->shouldReceive('check')->andReturn(false);
        $customerGuard->shouldReceive('user')->andReturn(null);

        $sanctumGuard = \Mockery::mock();
        $sanctumGuard->shouldReceive('user')->andReturn($customer);

        Auth::shouldReceive('guard')
            ->with('customer')
            ->andReturn($customerGuard);
        Auth::shouldReceive('guard')
            ->with('sanctum')
            ->andReturn($sanctumGuard);

        DB::table('events')->insert([
            'id' => 503,
            'event_type' => 'venue',
            'title' => 'Sanctum Checkout Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 7002,
            'event_id' => 503,
            'event_type' => 'venue',
            'pricing_type' => 'normal',
            'price' => 400,
            'ticket_available_type' => 'limited',
            'ticket_available' => 25,
            'max_ticket_buy_type' => 'unlimited',
            'max_buy_ticket' => 0,
            'normal_ticket_slot_enable' => 0,
            'free_tickete_slot_enable' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'event_guest_checkout_status' => 0,
            'event_id' => 503,
            'quantity' => 1,
            'pricing_type' => 'normal',
        ]);
        $response = app(EventController::class)->checkoutVerify($request);

        $this->assertIsArray($response);
        $this->assertTrue((bool) ($response['success'] ?? false));
        $this->assertSame(7002, $response['selTickets'][0]['ticket_id'] ?? null);
    }

    public function test_checkout_verify_returns_server_side_payment_summary_for_internal_balances(): void
    {
        $customer = new Customer([
            'id' => 9102,
            'email' => 'checkout-funding@example.com',
            'username' => 'checkout_funding',
            'fname' => 'Checkout',
            'lname' => 'Funding',
            'password' => bcrypt('secret'),
            'email_verified_at' => now(),
            'phone_verified_at' => now(),
        ]);

        $customerGuard = \Mockery::mock();
        $customerGuard->shouldReceive('check')->andReturn(false);
        $customerGuard->shouldReceive('user')->andReturn($customer);

        $sanctumGuard = \Mockery::mock();
        $sanctumGuard->shouldReceive('user')->andReturn(null);

        Auth::shouldReceive('guard')
            ->with('customer')
            ->andReturn($customerGuard);
        Auth::shouldReceive('guard')
            ->with('sanctum')
            ->andReturn($sanctumGuard);

        $walletService = \Mockery::mock(WalletService::class);
        $walletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(\Mockery::type(Customer::class))
            ->andReturn(new Wallet(['balance' => 70.0]));

        $bonusWalletService = \Mockery::mock(BonusWalletService::class);
        $bonusWalletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(\Mockery::type(Customer::class))
            ->andReturn(new BonusWallet(['balance' => 30.0]));

        DB::table('events')->insert([
            'id' => 504,
            'event_type' => 'venue',
            'title' => 'Funding Preview Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 7003,
            'event_id' => 504,
            'event_type' => 'venue',
            'pricing_type' => 'normal',
            'price' => 120,
            'ticket_available_type' => 'limited',
            'ticket_available' => 25,
            'max_ticket_buy_type' => 'unlimited',
            'max_buy_ticket' => 0,
            'normal_ticket_slot_enable' => 0,
            'free_tickete_slot_enable' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/event/checkout-verify', 'POST', [
            'event_guest_checkout_status' => 1,
            'event_id' => 504,
            'quantity' => 1,
            'pricing_type' => 'normal',
            'gateway' => 'mixed',
            'apply_wallet_balance' => true,
            'apply_bonus_balance' => true,
        ]);
        $controller = new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
        );
        $response = $controller->checkoutVerify($request);

        $this->assertIsArray($response);
        $this->assertTrue((bool) ($response['success'] ?? false));
        $this->assertSame(30.0, $response['payment_summary']['bonus_amount'] ?? null);
        $this->assertSame(70.0, $response['payment_summary']['wallet_amount'] ?? null);
        $this->assertSame(20.0, $response['payment_summary']['card_amount'] ?? null);
        $this->assertSame(70.0, $response['payment_summary']['available_wallet_balance'] ?? null);
        $this->assertSame(30.0, $response['payment_summary']['available_bonus_balance'] ?? null);
        $this->assertTrue((bool) ($response['payment_summary']['requires_card'] ?? false));
    }

    private function ensureCheckoutVerifySchema(): void
    {
        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->default(0);
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->default(0);
                $table->text('description')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('f_price', 15, 2)->nullable();
                $table->string('early_bird_discount')->default('disable');
                $table->decimal('early_bird_discount_amount', 15, 2)->default(0);
                $table->string('early_bird_discount_type')->default('fixed');
                $table->date('early_bird_discount_date')->nullable();
                $table->string('early_bird_discount_time')->nullable();
                $table->longText('variations')->nullable();
                $table->tinyInteger('normal_ticket_slot_enable')->default(0);
                $table->unsignedBigInteger('normal_ticket_slot_unique_id')->nullable();
                $table->tinyInteger('free_tickete_slot_enable')->default(0);
                $table->unsignedBigInteger('free_tickete_slot_unique_id')->nullable();
                $table->decimal('slot_seat_min_price', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_contents')) {
            Schema::create('ticket_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->string('title')->nullable();
                $table->text('description')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('events', 'event_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('event_type')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'paymentStatus')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->string('paymentStatus')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'variation')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->longText('variation')->nullable();
            });
        }

        if (!Schema::hasColumn('customers', 'phone_verified_at')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->timestamp('phone_verified_at')->nullable();
            });
        }

        if (!Schema::hasColumn('basic_settings', 'tax')) {
            Schema::table('basic_settings', function (Blueprint $table) {
                $table->decimal('tax', 10, 2)->default(0);
            });
        }

        if (!Schema::hasColumn('basic_settings', 'event_guest_checkout_status')) {
            Schema::table('basic_settings', function (Blueprint $table) {
                $table->tinyInteger('event_guest_checkout_status')->default(1);
            });
        }
    }

    private function truncateCheckoutTables(): void
    {
        foreach (['ticket_contents', 'tickets', 'bookings', 'events', 'basic_settings'] as $table) {
            if (Schema::hasTable($table)) {
                DB::table($table)->delete();
            }
        }
    }

    private function seedCheckoutDefaults(): void
    {
        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 1,
            'marketplace_commission' => 5.00,
            'event_guest_checkout_status' => 1,
            'tax' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
