<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\ArtistTipController;
use App\Models\Artist;
use App\Models\Customer;
use App\Services\StripeService;
use Illuminate\Http\Request;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ArtistTipControllerApiTest extends ActorFeatureTestCase
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

    public function test_customer_can_tip_artist_after_concluded_event(): void
    {
        $this->seedCustomer(811, 'api-tipper811@example.com');
        $artistId = $this->seedArtist(911, 'DJ API');
        $bookingId = $this->seedConcludedArtistBooking(811, $artistId, 1101);
        $this->seedCustomerWallet(811, 15.00);
        $this->seedSavedPaymentMethod(811, 'pm_tip_811');

        $stripeService = \Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('chargeSavedCard')
            ->once()
            ->andReturn((object) ['id' => 'pi_tip_811']);
        $this->app->instance(StripeService::class, $stripeService);

        Sanctum::actingAs(Customer::findOrFail(811), [], 'sanctum');

        $request = Request::create('/api/customers/artists/' . $artistId . '/tip', 'POST', [
            'booking_id' => $bookingId,
            'amount' => 50,
            'apply_wallet_balance' => true,
            'stripe_payment_method_id' => 'pm_tip_811',
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(811));
        $response = app(ArtistTipController::class)->store($request, Artist::findOrFail($artistId));
        $payload = $response->getData(true);

        $this->assertSame(200, $response->status());
        $this->assertTrue($payload['success']);
        $this->assertSame('completed', $payload['data']['tip']['status']);
        $this->assertEquals(15, $payload['data']['payment_summary']['wallet_amount']);
        $this->assertEquals(35, $payload['data']['payment_summary']['card_amount']);
        $this->assertSame('mixed', $payload['data']['payment_summary']['gateway']);
        $this->assertSame('stripe_card', $payload['data']['payment_summary']['gateway_family']);
        $this->assertSame('mixed_with_stripe_remainder', $payload['data']['payment_summary']['verification_strategy']);
        $this->assertDatabaseHas('artist_tips', [
            'customer_id' => 811,
            'artist_id' => $artistId,
            'booking_id' => $bookingId,
            'status' => 'completed',
        ]);
    }

    public function test_tip_requires_booking_that_belongs_to_customer_and_event_artist(): void
    {
        $this->seedCustomer(812, 'api-tipper812@example.com');
        $artistId = $this->seedArtist(912, 'DJ Guard');
        $foreignBookingId = $this->seedConcludedArtistBooking(999, $artistId, 1102);

        Sanctum::actingAs(Customer::findOrFail(812), [], 'sanctum');

        $request = Request::create('/api/customers/artists/' . $artistId . '/tip', 'POST', [
            'booking_id' => $foreignBookingId,
            'amount' => 20,
            'apply_wallet_balance' => true,
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(812));
        $response = app(ArtistTipController::class)->store($request, Artist::findOrFail($artistId));
        $payload = $response->getData(true);

        $this->assertSame(403, $response->status());
        $this->assertSame('Only attendees of concluded events can tip this artist.', $payload['message']);
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

    private function seedCustomer(int $id, string $email): void
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => $email,
            'stripe_customer_id' => 'cus_' . $id,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedArtist(int $id, string $name): int
    {
        DB::table('artists')->insert([
            'id' => $id,
            'name' => $name,
            'email' => 'artist' . $id . '@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedConcludedArtistBooking(int $customerId, int $artistId, int $eventId): int
    {
        if (!DB::table('customers')->where('id', $customerId)->exists()) {
            $this->seedCustomer($customerId, 'customer' . $customerId . '@example.com');
        }

        DB::table('events')->insert([
            'id' => $eventId,
            'end_date_time' => now()->subDay()->toDateTimeString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'title' => 'Duty Tip API',
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

        $bookingId = $eventId + 6000;
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
