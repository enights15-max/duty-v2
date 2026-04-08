<?php

namespace Tests\Feature;

use App\Models\Artist;
use App\Models\Customer;
use App\Services\ArtistTipService;
use App\Services\StripeService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ArtistTipServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'payment_methods'];
    protected array $baselineTruncate = [
        'artist_tips',
        'wallet_transactions',
        'wallets',
        'payment_methods',
        'event_artist',
        'event_lineups',
        'event_contents',
        'bookings',
        'events',
        'artists',
        'customers',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureArtistTipSchema();
    }

    public function test_submit_completes_mixed_tip_and_credits_artist_wallet(): void
    {
        $customer = $this->seedCustomer(801, 'tipper801@example.com');
        $artist = $this->seedArtist(901, 'DJ Reactor');
        $bookingId = $this->seedConcludedArtistBooking($customer->id, $artist->id, 1001);
        $this->seedCustomerWallet($customer->id, 35.00);
        $this->seedSavedPaymentMethod($customer->id, 'pm_tip_801');

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_tip_801']);

        app()->instance(StripeService::class, $stripeService);
        $service = app(ArtistTipService::class);
        $tip = $service->submit($customer, $artist, [
            'booking_id' => $bookingId,
            'amount' => 100,
            'apply_wallet_balance' => true,
            'stripe_payment_method_id' => 'pm_tip_801',
        ]);

        $this->assertSame('completed', $tip->status);
        $this->assertSame('pi_tip_801', $tip->stripe_payment_intent_id);
        $this->assertEquals(35.0, (float) $tip->wallet_amount);
        $this->assertEquals(65.0, (float) $tip->card_amount);
        $this->assertSame('mixed', data_get($tip->meta, 'payment_summary.gateway'));
        $this->assertSame('stripe_card', data_get($tip->meta, 'payment_summary.gateway_family'));
        $this->assertSame('mixed_with_stripe_remainder', data_get($tip->meta, 'payment_summary.verification_strategy'));
        $this->assertEquals(0.0, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', $customer->id)->value('balance'));
        $this->assertEquals(100.0, (float) DB::table('wallets')->where('actor_type', 'artist')->where('actor_id', $artist->id)->value('balance'));
        $this->assertDatabaseHas('wallet_transactions', [
            'reference_type' => 'artist_tip_credit',
            'reference_id' => (string) $tip->id,
        ]);
    }

    public function test_submit_restores_internal_balances_when_card_charge_fails(): void
    {
        $customer = $this->seedCustomer(802, 'tipper802@example.com');
        $artist = $this->seedArtist(902, 'DJ Rollback');
        $bookingId = $this->seedConcludedArtistBooking($customer->id, $artist->id, 1002);
        $this->seedCustomerWallet($customer->id, 20.00);
        $this->seedSavedPaymentMethod($customer->id, 'pm_tip_802');

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andThrow(new \Exception('Stripe tip charge failed'));

        app()->instance(StripeService::class, $stripeService);
        $service = app(ArtistTipService::class);

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Stripe tip charge failed');

        try {
            $service->submit($customer, $artist, [
                'booking_id' => $bookingId,
                'amount' => 60,
                'apply_wallet_balance' => true,
                'stripe_payment_method_id' => 'pm_tip_802',
            ]);
        } finally {
            $this->assertEquals(20.0, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', $customer->id)->value('balance'));
            $this->assertEquals(0.0, (float) DB::table('wallets')->where('actor_type', 'artist')->where('actor_id', $artist->id)->value('balance'));
            $this->assertDatabaseHas('wallet_transactions', [
                'reference_type' => 'artist_tip_credit_reversal',
            ]);
            $this->assertDatabaseHas('wallet_transactions', [
                'reference_type' => 'artist_tip_wallet_reversal',
            ]);
            $this->assertDatabaseHas('artist_tips', [
                'customer_id' => $customer->id,
                'artist_id' => $artist->id,
                'status' => 'failed',
            ]);
        }
    }

    private function ensureArtistTipSchema(): void
    {
        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->string('photo')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('thumbnail')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_lineups')) {
            Schema::create('event_lineups', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->string('source_type')->nullable();
                $table->string('display_name')->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_headliner')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_artist')) {
            Schema::create('event_artist', function (Blueprint $table) {
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id');
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artist_tips')) {
            Schema::create('artist_tips', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('artist_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->decimal('amount', 10, 2);
                $table->decimal('wallet_amount', 10, 2)->default(0);
                $table->decimal('card_amount', 10, 2)->default(0);
                $table->char('currency', 3)->default('DOP');
                $table->string('status', 32)->default('processing');
                $table->uuid('customer_wallet_transaction_id')->nullable();
                $table->uuid('artist_wallet_transaction_id')->nullable();
                $table->string('stripe_payment_intent_id')->nullable();
                $table->json('meta')->nullable();
                $table->timestamp('completed_at')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id, string $email): Customer
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => $email,
            'stripe_customer_id' => 'cus_' . $id,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Customer::findOrFail($id);
    }

    private function seedArtist(int $id, string $name): Artist
    {
        DB::table('artists')->insert([
            'id' => $id,
            'name' => $name,
            'email' => 'artist' . $id . '@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Artist::findOrFail($id);
    }

    private function seedConcludedArtistBooking(int $customerId, int $artistId, int $eventId): int
    {
        DB::table('events')->insert([
            'id' => $eventId,
            'end_date_time' => now()->subDay()->toDateTimeString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'title' => 'Duty Tip Flow',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_lineups')->insert([
            'event_id' => $eventId,
            'artist_id' => $artistId,
            'source_type' => 'registered',
            'display_name' => 'Artist ' . $artistId,
            'sort_order' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $bookingId = $eventId + 5000;
        DB::table('bookings')->insert([
            'id' => $bookingId,
            'customer_id' => $customerId,
            'event_id' => $eventId,
            'paymentStatus' => 'Completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $bookingId;
    }

    private function seedCustomerWallet(int $customerId, float $balance): void
    {
        DB::table('wallets')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000001', $customerId),
            'user_id' => $customerId,
            'actor_type' => 'customer',
            'actor_id' => $customerId,
            'balance' => $balance,
            'currency' => 'DOP',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedSavedPaymentMethod(int $customerId, string $paymentMethodId): void
    {
        DB::table('payment_methods')->insert([
            'id' => sprintf('%08d-0000-4000-8000-000000000099', $customerId),
            'user_id' => $customerId,
            'actor_type' => 'customer',
            'actor_id' => $customerId,
            'stripe_payment_method_id' => $paymentMethodId,
            'brand' => 'visa',
            'last4' => '4242',
            'exp_month' => '12',
            'exp_year' => '2030',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
