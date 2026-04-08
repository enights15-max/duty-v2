<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationBookingConversionService;
use App\Services\ReservationExpiryService;
use App\Services\StripeService;
use App\Services\TicketReservationService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class TicketReservationServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'bonus_wallets', 'booking_payment_allocations', 'reservations', 'identities', 'legacy_identity_sources', 'economy', 'event_treasury'];
    protected array $baselineTruncate = [
        'ticket_price_schedules',
        'event_financial_entries',
        'event_treasuries',
        'event_settlement_settings',
        'identity_balances',
        'identities',
        'organizers',
        'users',
        'booking_payment_allocations',
        'bookings',
        'reservation_payments',
        'ticket_reservations',
        'bonus_transactions',
        'bonus_wallets',
        'wallet_transactions',
        'wallets',
        'tickets',
        'events',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureReservationEventSchema();
        $this->ensureBookingSchema();
        $this->ensurePriceScheduleSchema();
        $this->seedOrganizerContext();
    }

    public function test_create_reservation_consumes_inventory_and_records_initial_payment(): void
    {
        $customer = $this->seedCustomer(601);
        $this->seedBalances($customer->id, walletBalance: 100, bonusBalance: 0);
        $this->seedEventAndTicket(7001, 100, 5, 'fixed', 30);

        $reservation = app(TicketReservationService::class)->createReservation($customer, [
            'ticket_id' => 7001,
            'quantity' => 2,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 30,
            'event_date' => '2026-09-01',
        ]);

        $this->assertSame('active', $reservation->status);
        $this->assertEquals(200.0, (float) $reservation->total_amount);
        $this->assertEquals(30.0, (float) $reservation->amount_paid);
        $this->assertEquals(170.0, (float) $reservation->remaining_balance);
        $this->assertEquals(3, (int) DB::table('tickets')->where('id', 7001)->value('ticket_available'));
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => $reservation->id,
            'source_type' => 'wallet',
            'amount' => '30.00',
        ]);
        $paymentMeta = json_decode((string) DB::table('reservation_payments')
            ->where('reservation_id', $reservation->id)
            ->where('source_type', 'wallet')
            ->value('meta'), true);
        $this->assertSame('wallet', data_get($paymentMeta, 'requested_gateway'));
        $this->assertSame('wallet', data_get($paymentMeta, 'gateway'));
        $this->assertSame('wallet', data_get($paymentMeta, 'source_gateway'));
        $this->assertSame('internal_balance', data_get($paymentMeta, 'gateway_family'));
        $this->assertDatabaseHas('event_treasuries', [
            'event_id' => 8001,
            'gross_collected' => '30.00',
        ]);
    }

    public function test_pay_reservation_can_complete_balance_with_mixed_sources(): void
    {
        $customer = $this->seedCustomer(602);
        $this->seedBalances($customer->id, walletBalance: 50, bonusBalance: 25);
        $this->seedEventAndTicket(7002, 100, 4, 'fixed', 20);

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_res_602']);
        app()->instance(StripeService::class, $stripeService);

        $service = app(TicketReservationService::class);

        $reservation = $service->createReservation($customer, [
            'ticket_id' => 7002,
            'quantity' => 1,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 20,
            'event_date' => '2026-09-02',
        ]);

        $updated = $service->payReservation($customer, $reservation, [
            'payment_amount' => 80,
            'gateway' => 'mixed',
            'apply_wallet_balance' => true,
            'apply_bonus_balance' => true,
            'stripe_payment_method_id' => 'pm_reservation_602',
        ]);

        $this->assertSame('completed', $updated->status);
        $this->assertEquals(0.0, (float) $updated->remaining_balance);
        $this->assertEquals(0.0, (float) DB::table('bonus_wallets')->where('actor_id', 602)->value('balance'));
        $this->assertEquals(0.0, (float) DB::table('wallets')->where('actor_id', 602)->value('balance'));
        $this->assertSame(1, $updated->bookings->count());
        $this->assertSame($updated->id, (int) $updated->bookings->first()->reservation_id);
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => $reservation->id,
            'source_type' => 'card',
            'amount' => '25.00',
        ]);
        $this->assertSame(4, DB::table('booking_payment_allocations')->where('booking_id', $updated->bookings->first()->id)->count());
        $cardAllocationMeta = json_decode((string) DB::table('booking_payment_allocations')
            ->where('booking_id', $updated->bookings->first()->id)
            ->where('source_type', 'card')
            ->value('meta'), true);
        $this->assertSame('mixed', data_get($cardAllocationMeta, 'requested_gateway'));
        $this->assertSame('mixed', data_get($cardAllocationMeta, 'source_gateway'));
        $this->assertSame('stripe_card', data_get($cardAllocationMeta, 'source_gateway_family'));
        $this->assertSame('mixed_with_stripe_remainder', data_get($cardAllocationMeta, 'verification_strategy'));
        $this->assertEquals(100.0, (float) DB::table('event_treasuries')->where('event_id', 8001)->value('gross_collected'));

        $convertedAgain = app(ReservationBookingConversionService::class)->convert($updated->fresh(['payments', 'event', 'ticket']));
        $this->assertSame(1, $convertedAgain->count());
        $this->assertSame(1, DB::table('bookings')->where('reservation_id', $updated->id)->count());
        $this->assertEquals(100.0, (float) DB::table('event_treasuries')->where('event_id', 8001)->value('gross_collected'));
    }

    public function test_full_payment_reservation_converts_into_unit_bookings_without_double_inventory_decrement(): void
    {
        $customer = $this->seedCustomer(603);
        $this->seedBalances($customer->id, walletBalance: 250, bonusBalance: 0);
        $this->seedEventAndTicket(7004, 100, 5, 'fixed', 30);

        $reservation = app(TicketReservationService::class)->createReservation($customer, [
            'ticket_id' => 7004,
            'quantity' => 2,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 200,
            'event_date' => '2026-09-03',
        ]);

        $this->assertSame('completed', $reservation->status);
        $this->assertNotNull($reservation->booking_order_number);
        $this->assertSame(2, $reservation->bookings->count());
        $this->assertSame(3, (int) DB::table('tickets')->where('id', 7004)->value('ticket_available'));
        $bookingIds = $reservation->bookings->pluck('id')->all();
        $this->assertSame(2, DB::table('booking_payment_allocations')->whereIn('booking_id', $bookingIds)->count());
        $this->assertEquals(
            200.0,
            (float) DB::table('booking_payment_allocations')->whereIn('booking_id', $bookingIds)->sum('amount')
        );
    }

    public function test_reservation_uses_current_scheduled_ticket_price(): void
    {
        $customer = $this->seedCustomer(604);
        $this->seedBalances($customer->id, walletBalance: 100, bonusBalance: 0);
        $this->seedEventAndTicket(7005, 100, 6, 'fixed', 30);

        DB::table('ticket_price_schedules')->insert([
            [
                'ticket_id' => 7005,
                'label' => 'Early Wave',
                'effective_from' => now()->subDays(2),
                'price' => 150.00,
                'sort_order' => 1,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'ticket_id' => 7005,
                'label' => 'Final Wave',
                'effective_from' => now()->addDays(10),
                'price' => 175.00,
                'sort_order' => 2,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $reservation = app(TicketReservationService::class)->createReservation($customer, [
            'ticket_id' => 7005,
            'quantity' => 1,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 30,
            'event_date' => '2026-09-04',
        ]);

        $this->assertEquals(150.0, (float) $reservation->reserved_unit_price);
        $this->assertEquals(150.0, (float) $reservation->total_amount);
        $this->assertEquals(120.0, (float) $reservation->remaining_balance);
    }

    public function test_reservation_preview_exposes_effective_gateway_contract_for_mixed_funding(): void
    {
        $customer = $this->seedCustomer(605);
        $this->seedBalances($customer->id, walletBalance: 25, bonusBalance: 0);
        $this->seedEventAndTicket(7006, 100, 6, 'fixed', 30);

        $preview = app(TicketReservationService::class)->previewCreateReservation($customer, [
            'ticket_id' => 7006,
            'quantity' => 1,
            'gateway' => 'mixed',
            'apply_wallet_balance' => true,
            'payment_amount' => 40,
            'event_date' => '2026-09-04',
        ]);

        $this->assertSame('mixed', $preview['payment_summary']['requested_gateway'] ?? null);
        $this->assertSame('mixed', $preview['payment_summary']['gateway'] ?? null);
        $this->assertSame('stripe_card', $preview['payment_summary']['gateway_family'] ?? null);
        $this->assertSame('mixed_with_stripe_remainder', $preview['payment_summary']['verification_strategy'] ?? null);
        $this->assertEquals(25.0, (float) ($preview['payment_summary']['wallet_amount'] ?? 0));
        $this->assertEquals(15.0, (float) ($preview['payment_summary']['card_amount'] ?? 0));
    }

    public function test_expiry_service_marks_reservation_expired_and_releases_inventory(): void
    {
        $this->seedEventAndTicket(7003, 80, 1, 'fixed', 20);
        DB::table('ticket_reservations')->insert([
            'id' => 9901,
            'customer_id' => 1,
            'event_id' => 8001,
            'ticket_id' => 7003,
            'reservation_code' => 'RSV-EXPIRE-1',
            'quantity' => 2,
            'reserved_unit_price' => 80.00,
            'total_amount' => 160.00,
            'deposit_required' => 20.00,
            'amount_paid' => 20.00,
            'remaining_balance' => 140.00,
            'status' => 'active',
            'expires_at' => now()->subHour(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        DB::table('tickets')->where('id', 7003)->update(['ticket_available' => 0]);

        $expired = app(ReservationExpiryService::class)->handle(now());

        $this->assertSame(1, $expired);
        $this->assertSame('expired', TicketReservation::findOrFail(9901)->status);
        $this->assertEquals(2, (int) DB::table('tickets')->where('id', 7003)->value('ticket_available'));
    }

    private function ensureReservationEventSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'event_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('event_type')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'date_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('date_type')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'start_date')) {
            Schema::table('events', function (Blueprint $table) {
                $table->date('start_date')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'organizer_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('organizer_id')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'owner_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('owner_identity_id')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'venue_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->nullable();
                $table->decimal('f_price', 15, 2)->nullable();
                $table->boolean('reservation_enabled')->default(false);
                $table->string('reservation_deposit_type', 32)->nullable();
                $table->decimal('reservation_deposit_value', 15, 2)->nullable();
                $table->dateTime('reservation_final_due_date')->nullable();
                $table->decimal('reservation_min_installment_amount', 15, 2)->nullable();
                $table->timestamps();
            });
        }
    }

    private function ensureBookingSchema(): void
    {
        Schema::dropIfExists('bookings');

        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->unsignedBigInteger('reservation_id')->nullable();
            $table->string('booking_id')->nullable();
            $table->string('order_number')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('organizer_id')->nullable();
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
            $table->text('variation')->nullable();
            $table->decimal('price', 15, 2)->default(0);
            $table->decimal('tax_percentage', 15, 2)->default(0);
            $table->decimal('commission_percentage', 15, 2)->default(0);
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
            $table->text('invoice')->nullable();
            $table->text('attachmentFile')->nullable();
            $table->string('event_date')->nullable();
            $table->boolean('scan_status')->default(false);
            $table->unsignedBigInteger('conversation_id')->nullable();
            $table->string('fcm_token')->nullable();
            $table->boolean('is_transferable')->default(true);
            $table->boolean('is_listed')->default(false);
            $table->decimal('listing_price', 15, 2)->default(0);
            $table->string('transfer_status')->nullable();
            $table->timestamps();
        });
    }

    private function ensurePriceScheduleSchema(): void
    {
        if (!Schema::hasTable('ticket_price_schedules')) {
            Schema::create('ticket_price_schedules', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->string('label')->nullable();
                $table->dateTime('effective_from');
                $table->decimal('price', 15, 2);
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id): Customer
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "reservation{$id}@example.com",
            'fname' => 'Reserve',
            'lname' => 'Customer',
            'phone' => '8090000000',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Av. Demo',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedBalances(int $customerId, float $walletBalance, float $bonusBalance): void
    {
        DB::table('wallets')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000011', $customerId),
            'user_id' => $customerId,
            'actor_type' => 'customer',
            'actor_id' => $customerId,
            'balance' => $walletBalance,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000012', $customerId),
            'user_id' => $customerId,
            'actor_type' => 'customer',
            'actor_id' => $customerId,
            'balance' => $bonusBalance,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEventAndTicket(
        int $ticketId,
        float $unitPrice,
        int $available,
        string $depositType,
        float $depositValue
    ): void {
        DB::table('events')->insert([
            'id' => 8001,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-09-01',
            'end_date_time' => now()->addMonths(2),
            'organizer_id' => null,
            'owner_identity_id' => 501,
            'venue_identity_id' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => $ticketId,
            'event_id' => 8001,
            'event_type' => 'venue',
            'title' => 'Preventa',
            'ticket_available_type' => 'limited',
            'ticket_available' => $available,
            'pricing_type' => 'normal',
            'price' => $unitPrice,
            'f_price' => $unitPrice,
            'reservation_enabled' => 1,
            'reservation_deposit_type' => $depositType,
            'reservation_deposit_value' => $depositValue,
            'reservation_final_due_date' => now()->addMonth(),
            'reservation_min_installment_amount' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedOrganizerContext(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'reservation-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'reservation-organizer',
            'email' => 'reservation-organizer@example.com',
            'amount' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Reservation Organizer',
            'slug' => 'reservation-organizer',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 41,
            'balance' => 0,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
