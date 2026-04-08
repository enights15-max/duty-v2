<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\TicketReservationController;
use App\Models\Customer;
use App\Services\StripeService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class TicketReservationControllerApiTest extends ActorFeatureTestCase
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
        $this->ensureBookingSchema();
        $this->seedReservationContext();
    }

    public function test_customer_can_create_and_pay_reservation_via_api_controller(): void
    {
        $customer = Customer::findOrFail(701);

        $storeRequest = Request::create('/api/customers/reservations', 'POST', [
            'ticket_id' => 7101,
            'quantity' => 1,
            'gateway' => 'wallet',
            'apply_wallet_balance' => true,
            'payment_amount' => 20,
            'event_date' => '2026-10-01',
        ]);
        $storeRequest->setUserResolver(fn () => $customer);

        $storeResponse = app(TicketReservationController::class)->store($storeRequest);
        $storePayload = $storeResponse->getData(true);

        $this->assertSame(201, $storeResponse->getStatusCode());
        $this->assertTrue($storePayload['success']);

        $reservationId = (int) $storePayload['reservation']['id'];

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_controller_701']);
        app()->instance(StripeService::class, $stripeService);

        $payRequest = Request::create("/api/customers/reservations/{$reservationId}/pay", 'POST', [
            'payment_amount' => 80,
            'gateway' => 'mixed',
            'apply_wallet_balance' => true,
            'apply_bonus_balance' => true,
            'stripe_payment_method_id' => 'pm_controller_701',
        ]);
        $payRequest->setUserResolver(fn () => $customer);

        $payResponse = app(TicketReservationController::class)->pay($payRequest, $reservationId);
        $payPayload = $payResponse->getData(true);

        $this->assertSame(200, $payResponse->getStatusCode());
        $this->assertTrue($payPayload['success']);
        $this->assertSame('completed', $payPayload['reservation']['status']);
        $this->assertCount(1, $payPayload['reservation']['bookings']);
        $this->assertSame($reservationId, $payPayload['reservation']['bookings'][0]['reservation_id']);
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => $reservationId,
            'source_type' => 'card',
            'amount' => '20.00',
        ]);
        $this->assertSame(4, DB::table('booking_payment_allocations')->where('booking_id', $payPayload['reservation']['bookings'][0]['id'])->count());
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
                $table->timestamps();
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

    private function seedReservationContext(): void
    {
        DB::table('customers')->insert([
            'id' => 701,
            'email' => 'reservation-api@example.com',
            'fname' => 'API',
            'lname' => 'Customer',
            'phone' => '8090000001',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Calle API',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wallets')->insert([
            'id' => '00000701-0000-4000-8000-000000000021',
            'user_id' => 701,
            'actor_type' => 'customer',
            'actor_id' => 701,
            'balance' => 60.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bonus_wallets')->insert([
            'id' => '00000701-0000-4000-8000-000000000022',
            'user_id' => 701,
            'actor_type' => 'customer',
            'actor_id' => 701,
            'balance' => 20.00,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 8101,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-10-01',
            'end_date_time' => now()->addMonths(3),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('tickets')->insert([
            'id' => 7101,
            'event_id' => 8101,
            'event_type' => 'venue',
            'title' => 'Reserva API',
            'ticket_available_type' => 'limited',
            'ticket_available' => 10,
            'pricing_type' => 'normal',
            'price' => 100.00,
            'f_price' => 100.00,
            'reservation_enabled' => 1,
            'reservation_deposit_type' => 'fixed',
            'reservation_deposit_value' => 20.00,
            'reservation_final_due_date' => now()->addMonths(2),
            'reservation_min_installment_amount' => 10.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
