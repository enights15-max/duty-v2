<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\EventController;
use App\Models\BonusWallet;
use App\Models\Customer;
use App\Models\Wallet;
use App\Services\BonusWalletService;
use App\Services\CheckoutFundingAllocatorService;
use App\Services\EventBookingGuardService;
use App\Services\NotificationService;
use App\Services\WalletService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class EventBookingLoyaltyAwardTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'loyalty'];
    protected array $baselineTruncate = [
        'loyalty_point_transactions',
        'bookings',
        'tickets',
        'events',
        'basic_settings',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        Queue::fake();
        $this->ensureEventBookingTables();
    }

    public function test_completed_direct_booking_awards_loyalty_points(): void
    {
        $customer = $this->seedCustomer(1601, 'booking-loyalty-complete@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController($customer);

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gatewayType' => 'online',
            'paymentStatus' => 'completed',
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertDatabaseHas('loyalty_point_transactions', [
            'customer_id' => $customer->id,
            'reference_type' => 'booking_order',
            'points' => 100,
            'type' => 'credit',
        ]);
    }

    public function test_pending_direct_booking_does_not_award_loyalty_points(): void
    {
        $customer = $this->seedCustomer(1602, 'booking-loyalty-pending@example.com');
        $eventId = $this->seedEventWithTicket();
        $controller = $this->makeController($customer);

        $request = Request::create('/api/event-booking', 'POST', $this->validPayload($eventId, [
            'gatewayType' => 'online',
            'paymentStatus' => 'pending',
        ]));

        $response = $controller->store_booking($request);
        $payload = $response->getData(true);

        $this->assertTrue($payload['status']);
        $this->assertDatabaseCount('loyalty_point_transactions', 0);
    }

    private function makeController(Customer $customer): EventController
    {
        $walletService = Mockery::mock(WalletService::class);
        $walletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(Mockery::type(Customer::class))
            ->andReturn(new Wallet(['balance' => 0.0]));

        $bonusWalletService = Mockery::mock(BonusWalletService::class);
        $bonusWalletService->shouldReceive('getOrCreateWallet')
            ->once()
            ->with(Mockery::type(Customer::class))
            ->andReturn(new BonusWallet(['balance' => 0.0]));

        $guardService = Mockery::mock(EventBookingGuardService::class);
        $guardService->shouldReceive('resolveAuthenticatedBookingCustomer')
            ->once()
            ->andReturn(['authCustomer' => $customer]);
        $guardService->shouldReceive('validateEventDateWindow')
            ->once()
            ->andReturn(null);
        $guardService->shouldReceive('validateEventAgeRestriction')
            ->once()
            ->andReturn(null);

        $allocator = Mockery::mock(CheckoutFundingAllocatorService::class);
        $allocator->shouldReceive('allocate')
            ->once()
            ->andReturn([
                'gateway' => 'stripe',
                'mode' => 'card',
                'payment_method' => 'stripe',
                'wallet_amount' => 0.0,
                'bonus_amount' => 0.0,
                'card_amount' => 0.0,
                'processing_fee' => 0.0,
                'total_to_charge' => 100.0,
                'is_fully_covered' => true,
                'requires_card' => false,
            ]);

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')
            ->once()
            ->andReturnNull();

        return new EventController(
            walletService: $walletService,
            bonusWalletService: $bonusWalletService,
            stripeService: Mockery::mock(\App\Services\StripeService::class),
            notificationService: $notificationService,
            eventBookingGuardService: $guardService,
            checkoutFundingAllocatorService: $allocator,
            bookingFundingService: Mockery::mock(\App\Services\BookingFundingService::class)
        );
    }

    private function seedCustomer(int $id, string $email): Customer
    {
        DB::table('users')->insert([
            'id' => $id,
            'email' => $email,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $id,
            'email' => $email,
            'fname' => 'Test',
            'lname' => 'Customer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedEventWithTicket(): int
    {
        DB::table('basic_settings')->insert([
            'id' => 1,
            'uniqid' => 12345,
            'commission' => 0,
            'tax' => 0,
            'how_ticket_will_be_send' => 'manual',
            'base_currency_symbol' => 'RD$',
            'base_currency_symbol_position' => 'left',
            'base_currency_text' => 'DOP',
            'base_currency_text_position' => 'left',
            'base_currency_rate' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => null,
            'owner_identity_id' => null,
            'title' => 'Loyalty Booking Event',
            'event_type' => 'offline',
            'start_date' => now()->toDateString(),
            'end_date_time' => now()->addDay(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 1,
            'event_id' => $eventId,
            'title' => 'General',
            'pricing_type' => 'normal',
            'ticket_available_type' => 'limited',
            'ticket_available' => 10,
            'price' => 100,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function validPayload(int $eventId, array $overrides = []): array
    {
        return array_merge([
            'fname' => 'Test',
            'lname' => 'User',
            'email' => 'test@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'address' => 'Santo Domingo',
            'event_id' => $eventId,
            'gateway' => 'stripe',
            'gatewayType' => 'online',
            'quantity' => 1,
            'event_date' => now()->toDateString(),
            'total' => 100,
            'discount' => 0,
            'tax' => 0,
            'total_early_bird_dicount' => 0,
        ], $overrides);
    }

    private function ensureEventBookingTables(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('uniqid')->nullable();
                $table->decimal('commission', 10, 2)->default(0);
                $table->decimal('tax', 10, 2)->default(0);
                $table->string('how_ticket_will_be_send')->nullable();
                $table->string('base_currency_symbol')->nullable();
                $table->string('base_currency_symbol_position')->nullable();
                $table->string('base_currency_text')->nullable();
                $table->string('base_currency_text_position')->nullable();
                $table->decimal('base_currency_rate', 10, 2)->default(1);
                $table->timestamps();
            });
        }

        foreach ([
            'uniqid' => fn (Blueprint $table) => $table->unsignedBigInteger('uniqid')->nullable(),
            'commission' => fn (Blueprint $table) => $table->decimal('commission', 10, 2)->default(0),
            'tax' => fn (Blueprint $table) => $table->decimal('tax', 10, 2)->default(0),
            'how_ticket_will_be_send' => fn (Blueprint $table) => $table->string('how_ticket_will_be_send')->nullable(),
            'base_currency_symbol' => fn (Blueprint $table) => $table->string('base_currency_symbol')->nullable(),
            'base_currency_symbol_position' => fn (Blueprint $table) => $table->string('base_currency_symbol_position')->nullable(),
            'base_currency_text' => fn (Blueprint $table) => $table->string('base_currency_text')->nullable(),
            'base_currency_text_position' => fn (Blueprint $table) => $table->string('base_currency_text_position')->nullable(),
            'base_currency_rate' => fn (Blueprint $table) => $table->decimal('base_currency_rate', 10, 2)->default(1),
        ] as $column => $definition) {
            if (!Schema::hasColumn('basic_settings', $column)) {
                Schema::table('basic_settings', $definition);
            }
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('title')->nullable();
                $table->string('event_type')->nullable();
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
            'start_date' => fn (Blueprint $table) => $table->date('start_date')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('earnings')) {
            Schema::create('earnings', function (Blueprint $table): void {
                $table->id();
                $table->decimal('total_revenue', 15, 2)->default(0);
                $table->decimal('total_earning', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->string('payment_status')->nullable();
                $table->string('payment_method')->nullable();
                $table->decimal('grand_total', 15, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->decimal('commission', 15, 2)->default(0);
                $table->decimal('pre_balance', 15, 2)->default(0);
                $table->decimal('after_balance', 15, 2)->nullable();
                $table->string('gateway_type')->nullable();
                $table->string('currency_symbol')->nullable();
                $table->string('currency_symbol_position')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('title')->nullable();
                $table->string('pricing_type')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->default(0);
                $table->decimal('price', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        foreach ([
            'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
            'title' => fn (Blueprint $table) => $table->string('title')->nullable(),
            'pricing_type' => fn (Blueprint $table) => $table->string('pricing_type')->nullable(),
            'ticket_available_type' => fn (Blueprint $table) => $table->string('ticket_available_type')->nullable(),
            'ticket_available' => fn (Blueprint $table) => $table->integer('ticket_available')->default(0),
            'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->default(0),
        ] as $column => $definition) {
            if (!Schema::hasColumn('tickets', $column)) {
                Schema::table('tickets', $definition);
            }
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('city')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('address')->nullable();
                $table->longText('variation')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('tax_percentage', 10, 2)->default(0);
                $table->decimal('commission_percentage', 10, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->decimal('commission', 15, 2)->default(0);
                $table->integer('quantity')->default(1);
                $table->decimal('discount', 15, 2)->default(0);
                $table->decimal('early_bird_discount', 15, 2)->default(0);
                $table->string('currencyText')->nullable();
                $table->string('currencyTextPosition')->nullable();
                $table->string('currencySymbol')->nullable();
                $table->string('currencySymbolPosition')->nullable();
                $table->string('paymentMethod')->nullable();
                $table->string('gatewayType')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->string('invoice')->nullable();
                $table->string('attachmentFile')->nullable();
                $table->date('event_date')->nullable();
                $table->unsignedBigInteger('conversation_id')->nullable();
                $table->string('fcm_token')->nullable();
                $table->integer('scan_status')->default(0);
                $table->timestamps();
            });
        }

        foreach ([
            'booking_id' => fn (Blueprint $table) => $table->string('booking_id')->nullable(),
            'order_number' => fn (Blueprint $table) => $table->string('order_number')->nullable(),
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'organizer_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_identity_id')->nullable(),
            'ticket_id' => fn (Blueprint $table) => $table->unsignedBigInteger('ticket_id')->nullable(),
            'country' => fn (Blueprint $table) => $table->string('country')->nullable(),
            'state' => fn (Blueprint $table) => $table->string('state')->nullable(),
            'city' => fn (Blueprint $table) => $table->string('city')->nullable(),
            'zip_code' => fn (Blueprint $table) => $table->string('zip_code')->nullable(),
            'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
            'tax_percentage' => fn (Blueprint $table) => $table->decimal('tax_percentage', 10, 2)->default(0),
            'commission_percentage' => fn (Blueprint $table) => $table->decimal('commission_percentage', 10, 2)->default(0),
            'tax' => fn (Blueprint $table) => $table->decimal('tax', 15, 2)->default(0),
            'commission' => fn (Blueprint $table) => $table->decimal('commission', 15, 2)->default(0),
            'discount' => fn (Blueprint $table) => $table->decimal('discount', 15, 2)->default(0),
            'early_bird_discount' => fn (Blueprint $table) => $table->decimal('early_bird_discount', 15, 2)->default(0),
            'currencyText' => fn (Blueprint $table) => $table->string('currencyText')->nullable(),
            'currencyTextPosition' => fn (Blueprint $table) => $table->string('currencyTextPosition')->nullable(),
            'currencySymbol' => fn (Blueprint $table) => $table->string('currencySymbol')->nullable(),
            'currencySymbolPosition' => fn (Blueprint $table) => $table->string('currencySymbolPosition')->nullable(),
            'paymentMethod' => fn (Blueprint $table) => $table->string('paymentMethod')->nullable(),
            'gatewayType' => fn (Blueprint $table) => $table->string('gatewayType')->nullable(),
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'invoice' => fn (Blueprint $table) => $table->string('invoice')->nullable(),
            'attachmentFile' => fn (Blueprint $table) => $table->string('attachmentFile')->nullable(),
            'event_date' => fn (Blueprint $table) => $table->date('event_date')->nullable(),
            'conversation_id' => fn (Blueprint $table) => $table->unsignedBigInteger('conversation_id')->nullable(),
            'fcm_token' => fn (Blueprint $table) => $table->string('fcm_token')->nullable(),
            'scan_status' => fn (Blueprint $table) => $table->integer('scan_status')->default(0),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }

        if (!DB::table('earnings')->exists()) {
            DB::table('earnings')->insert([
                'id' => 1,
                'total_revenue' => 0,
                'total_earning' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
