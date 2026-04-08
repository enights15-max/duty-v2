<?php

namespace Tests\Feature;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class SettlementIdentityFirstHelpersTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'users',
        'customers',
        'identities',
        'identity_members',
        'organizers',
        'identity_balances',
        'transactions',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureSettlementTables();
        $this->seedOrganizerIdentity();
    }

    public function test_store_transcation_prefers_booking_organizer_identity_and_resolves_legacy_balance_context(): void
    {
        $booking = (object) [
            'id' => 71,
            'organizer_id' => null,
            'organizer_identity_id' => 501,
            'evnt' => (object) ['owner_identity_id' => 501],
            'price' => 100,
            'commission' => 15,
            'tax' => 0,
            'transcation_type' => 1,
            'paymentStatus' => 1,
            'paymentMethod' => 'Stripe',
            'gatewayType' => 'online',
            'currencySymbol' => '$',
            'currencySymbolPosition' => 'left',
        ];

        storeTranscation($booking);

        $transaction = DB::table('transactions')->where('booking_id', 71)->first();

        $this->assertNotNull($transaction);
        $this->assertSame(41, (int) $transaction->organizer_id);
        $this->assertSame(501, (int) $transaction->organizer_identity_id);
        $this->assertSame(300.0, (float) $transaction->pre_balance);
        $this->assertSame(385.0, (float) $transaction->after_balance);
    }

    public function test_store_organizer_credits_canonical_identity_balance_without_mutating_legacy_mirror_by_default(): void
    {
        storeOrganizer([
            'organizer_id' => null,
            'organizer_identity_id' => 501,
            'price' => 200,
            'commission' => 20,
        ]);

        $this->assertSame(300.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
        $this->assertSame(480.0, (float) DB::table('identity_balances')->where('identity_id', 501)->value('balance'));
    }

    private function seedOrganizerIdentity(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'settlement-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'settlement-organizer',
            'email' => 'settlement-organizer@example.com',
            'amount' => 300,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Settlement Organizer Identity',
            'slug' => 'settlement-organizer-identity',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureSettlementTables(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->string('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->integer('payment_status')->nullable();
                $table->string('payment_method')->nullable();
                $table->decimal('grand_total', 15, 2)->default(0);
                $table->decimal('pre_balance', 15, 2)->nullable();
                $table->decimal('after_balance', 15, 2)->nullable();
                $table->decimal('commission', 15, 2)->nullable();
                $table->decimal('tax', 15, 2)->nullable();
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
    }
}
