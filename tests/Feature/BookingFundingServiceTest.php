<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Services\BookingFundingService;
use App\Services\BonusWalletService;
use App\Services\Payments\PaymentGatewayRegistry;
use App\Services\StripeService;
use App\Services\WalletService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class BookingFundingServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'bonus_wallets', 'booking_payment_allocations'];
    protected array $baselineTruncate = [
        'booking_payment_allocations',
        'bonus_transactions',
        'bonus_wallets',
        'wallet_transactions',
        'wallets',
        'bookings',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureBookingTable();
    }

    public function test_capture_for_bookings_debits_all_sources_and_persists_allocations(): void
    {
        $customer = $this->seedCustomer(501);
        $this->seedWallets($customer->id, 100, 60);
        $bookings = $this->seedBookings($customer->id);

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_mixed_501']);

        app()->instance(StripeService::class, $stripeService);

        $service = app(BookingFundingService::class);

        $capture = $service->captureForBookings(
            $customer,
            $bookings,
            [
                'mode' => 'mixed',
                'bonus_amount' => 30.0,
                'wallet_amount' => 40.0,
                'card_amount' => 30.0,
                'card_processing_fee' => 0.0,
                'card_total_charge' => 30.0,
            ],
            'pm_saved_501',
            'DOP'
        );

        $this->assertSame('pi_mixed_501', $capture['stripe_payment_intent_id']);
        $this->assertEquals(60.0, (float) DB::table('wallets')->where('actor_id', 501)->value('balance'));
        $this->assertEquals(30.0, (float) DB::table('bonus_wallets')->where('actor_id', 501)->value('balance'));
        $this->assertSame(6, DB::table('booking_payment_allocations')->count());
        $this->assertDatabaseHas('booking_payment_allocations', [
            'booking_id' => 9001,
            'source_type' => 'card',
            'amount' => '15.00',
        ]);
        $allocationMeta = json_decode((string) DB::table('booking_payment_allocations')
            ->where('booking_id', 9001)
            ->where('source_type', 'card')
            ->value('meta'), true);
        $this->assertSame('mixed', data_get($allocationMeta, 'requested_gateway'));
        $this->assertSame('mixed', data_get($allocationMeta, 'source_gateway'));
        $this->assertSame('stripe_card', data_get($allocationMeta, 'gateway_family'));
    }

    public function test_capture_for_bookings_restores_internal_balances_when_card_charge_fails(): void
    {
        $customer = $this->seedCustomer(502);
        $this->seedWallets($customer->id, 80, 20);
        $bookings = $this->seedBookings($customer->id, 9101);

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andThrow(new \Exception('Stripe declined payment intent'));

        app()->instance(StripeService::class, $stripeService);

        $service = app(BookingFundingService::class);

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Stripe declined payment intent');

        try {
            $service->captureForBookings(
                $customer,
                $bookings,
                [
                    'mode' => 'mixed',
                    'bonus_amount' => 20.0,
                    'wallet_amount' => 30.0,
                    'card_amount' => 10.0,
                    'card_processing_fee' => 0.0,
                    'card_total_charge' => 10.0,
                ],
                'pm_saved_502',
                'DOP'
            );
        } finally {
            $this->assertEquals(80.0, (float) DB::table('wallets')->where('actor_id', 502)->value('balance'));
            $this->assertEquals(20.0, (float) DB::table('bonus_wallets')->where('actor_id', 502)->value('balance'));
            $this->assertDatabaseHas('wallet_transactions', [
                'reference_type' => 'ticket_booking_wallet_reversal',
            ]);
            $this->assertDatabaseHas('bonus_transactions', [
                'reference_type' => 'ticket_booking_bonus_reversal',
            ]);
            $this->assertDatabaseCount('booking_payment_allocations', 0);
        }
    }

    private function ensureBookingTable(): void
    {
        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->decimal('tax', 15, 2)->default(0);
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id): Customer
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "capture{$id}@example.com",
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedWallets(int $customerId, float $walletBalance, float $bonusBalance): void
    {
        DB::table('wallets')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000001', $customerId),
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
            'id' => sprintf('%08d-0000-4000-8000-000000000002', $customerId),
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

    /**
     * @return Collection<int, \App\Models\Event\Booking>
     */
    private function seedBookings(int $customerId, int $firstId = 9001): Collection
    {
        DB::table('bookings')->insert([
            [
                'id' => $firstId,
                'customer_id' => $customerId,
                'booking_id' => 'booking_a',
                'order_number' => 'order_shared',
                'price' => 50.00,
                'tax' => 0.00,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => $firstId + 1,
                'customer_id' => $customerId,
                'booking_id' => 'booking_b',
                'order_number' => 'order_shared',
                'price' => 50.00,
                'tax' => 0.00,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        return \App\Models\Event\Booking::query()->whereIn('id', [$firstId, $firstId + 1])->orderBy('id')->get();
    }
}
