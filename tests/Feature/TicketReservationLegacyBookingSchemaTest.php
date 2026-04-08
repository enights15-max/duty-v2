<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationBookingConversionService;
use App\Services\StripeService;
use App\Services\TicketReservationService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class TicketReservationLegacyBookingSchemaTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'bonus_wallets', 'booking_payment_allocations', 'reservations'];
    protected array $baselineTruncate = [
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
        $this->ensureLegacyBookingSchema();
        $this->seedReservationContext();
    }

    public function test_completed_reservation_converts_when_bookings_table_has_no_ticket_id_column(): void
    {
        $customer = Customer::findOrFail(1701);

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_legacy_reservation']);
        app()->instance(StripeService::class, $stripeService);

        $service = app(TicketReservationService::class);

        $reservation = $service->createReservation($customer, [
            'ticket_id' => 17101,
            'quantity' => 1,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 100,
            'event_date' => '2026-11-10',
        ]);

        $completed = $service->payReservation($customer, $reservation, [
            'payment_amount' => 500,
            'gateway' => 'mixed',
            'apply_wallet_balance' => true,
            'apply_bonus_balance' => true,
            'stripe_payment_method_id' => 'pm_legacy_reservation',
        ]);

        $this->assertSame('completed', $completed->status);
        $this->assertNotNull($completed->booking_order_number);
        $this->assertSame(1, DB::table('bookings')->where('reservation_id', $completed->id)->count());
        $this->assertFalse(Schema::hasColumn('bookings', 'ticket_id'));
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => $completed->id,
            'source_type' => 'card',
            'amount' => '40.00',
        ]);

        $convertedAgain = app(ReservationBookingConversionService::class)->convert(
            TicketReservation::findOrFail($completed->id)
        );
        $this->assertSame(1, $convertedAgain->count());
    }

    private function ensureReservationEventSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->nullable();
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->nullable();
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

    private function ensureLegacyBookingSchema(): void
    {
        Schema::dropIfExists('bookings');

        Schema::create('bookings', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->unsignedBigInteger('reservation_id')->nullable();
            $table->string('booking_id')->nullable();
            $table->string('order_number')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('organizer_id')->nullable();
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

    private function seedReservationContext(): void
    {
        DB::table('customers')->insert([
            'id' => 1701,
            'email' => 'legacy-reservation@example.com',
            'fname' => 'Legacy',
            'lname' => 'Reservation',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '00001701-0000-4000-8000-000000000021',
            'user_id' => 1701,
            'actor_type' => 'customer',
            'actor_id' => 1701,
            'balance' => 560.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => '00001701-0000-4000-8000-000000000022',
            'user_id' => 1701,
            'actor_type' => 'customer',
            'actor_id' => 1701,
            'balance' => 0.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 18101,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-11-10',
            'end_date_time' => now()->addMonths(2),
            'organizer_id' => 44,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 17101,
            'event_id' => 18101,
            'event_type' => 'venue',
            'title' => 'Legacy Reservation Ticket',
            'ticket_available_type' => 'limited',
            'ticket_available' => 10,
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 4,
            'pricing_type' => 'normal',
            'price' => 600.00,
            'f_price' => 600.00,
            'reservation_enabled' => 1,
            'reservation_deposit_type' => 'fixed',
            'reservation_deposit_value' => 100.00,
            'reservation_final_due_date' => now()->addMonth(),
            'reservation_min_installment_amount' => 50.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
