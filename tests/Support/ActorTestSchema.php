<?php

namespace Tests\Support;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

trait ActorTestSchema
{
    protected function ensureUsersAndCustomersTables(): void
    {
        if (!Schema::hasTable('users')) {
            Schema::create('users', function (Blueprint $table) {
                $table->id();
                $table->string('email')->nullable();
                $table->string('username')->nullable();
                $table->string('first_name')->nullable();
                $table->string('last_name')->nullable();
                $table->string('contact_number')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamp('email_verified_at')->nullable();
                $table->string('stripe_customer_id')->nullable();
                $table->string('password')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('customers')) {
            Schema::create('customers', function (Blueprint $table) {
                $table->id();
                $table->string('email')->nullable();
                $table->string('username')->nullable();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('phone')->nullable();
                $table->string('photo')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamp('email_verified_at')->nullable();
                $table->string('stripe_customer_id')->nullable();
                $table->string('password')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'stripe_customer_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('stripe_customer_id')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'username')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('username')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'first_name')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('first_name')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'last_name')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('last_name')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'contact_number')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('contact_number')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'address')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('address')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'city')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('city')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'state')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('state')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'country')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('country')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'status')) {
            Schema::table('users', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'email_verified_at')) {
            Schema::table('users', function (Blueprint $table) {
                $table->timestamp('email_verified_at')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'stripe_customer_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('stripe_customer_id')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'username')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('username')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'fname')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('fname')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'lname')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('lname')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'phone')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('phone')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'photo')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('photo')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'address')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('address')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'city')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('city')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'state')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('state')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'country')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('country')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'status')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'email_verified_at')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->timestamp('email_verified_at')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'is_private')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->boolean('is_private')->default(false);
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'show_interested_events')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->boolean('show_interested_events')->default(true);
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'show_attended_events')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->boolean('show_attended_events')->default(true);
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'show_upcoming_attendance')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->boolean('show_upcoming_attendance')->default(true);
            });
        }
    }

    protected function ensureLanguagesTable(): void
    {
        if (!Schema::hasTable('languages')) {
            Schema::create('languages', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('code')->default('en');
                $table->string('direction')->default('ltr');
                $table->boolean('is_default')->default(false);
                $table->timestamps();
            });
        }
    }

    protected function ensureDefaultLanguage(): void
    {
        $this->ensureLanguagesTable();

        if (!DB::table('languages')->where('is_default', 1)->exists()) {
            DB::table('languages')->insert([
                'name' => 'English',
                'code' => 'en',
                'direction' => 'ltr',
                'is_default' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    protected function ensureLoyaltyTables(): void
    {
        if (!Schema::hasTable('loyalty_rules')) {
            Schema::create('loyalty_rules', function (Blueprint $table) {
                $table->id();
                $table->string('code', 64)->unique();
                $table->string('label');
                $table->string('description')->nullable();
                $table->integer('points')->default(0);
                $table->boolean('is_active')->default(true);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('loyalty_point_transactions')) {
            Schema::create('loyalty_point_transactions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('rule_id')->nullable();
                $table->string('type', 16)->default('credit');
                $table->integer('points');
                $table->integer('balance_after');
                $table->string('reference_type', 64);
                $table->string('reference_id', 128);
                $table->string('idempotency_key', 191)->unique();
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('reward_catalog')) {
            Schema::create('reward_catalog', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->string('description')->nullable();
                $table->string('reward_type', 32)->default('bonus_credit');
                $table->integer('points_cost');
                $table->decimal('bonus_amount', 10, 2)->nullable();
                $table->boolean('is_active')->default(true);
                $table->boolean('is_featured')->default(false);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('reward_redemptions')) {
            Schema::create('reward_redemptions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('reward_id');
                $table->unsignedBigInteger('loyalty_transaction_id')->nullable();
                $table->uuid('bonus_transaction_id')->nullable();
                $table->string('reward_type', 32);
                $table->integer('points_cost');
                $table->string('status', 32)->default('processing');
                $table->json('meta')->nullable();
                $table->timestamp('fulfilled_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('coupons')) {
            Schema::create('coupons', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('code')->unique();
                $table->string('type', 32);
                $table->decimal('value', 10, 2);
                $table->longText('events')->nullable();
                $table->dateTime('start_date');
                $table->dateTime('end_date');
                $table->timestamps();
            });
        }

        if (!DB::table('loyalty_rules')->where('code', 'event_purchase')->exists()) {
            DB::table('loyalty_rules')->insert([
                [
                    'code' => 'event_purchase',
                    'label' => 'Compra de evento',
                    'description' => 'Puntos otorgados por una compra directa de tickets.',
                    'points' => 100,
                    'is_active' => 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'code' => 'marketplace_purchase',
                    'label' => 'Compra en marketplace',
                    'description' => 'Puntos otorgados por comprar tickets en blackmarket.',
                    'points' => 60,
                    'is_active' => 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'code' => 'published_review',
                    'label' => 'Review publicada',
                    'description' => 'Puntos otorgados cuando una review queda publicada.',
                    'points' => 25,
                    'is_active' => 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'code' => 'follow_accept',
                    'label' => 'Nuevo follow',
                    'description' => 'Puntos otorgados por seguir cuentas dentro de Duty.',
                    'points' => 10,
                    'is_active' => 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        if (!DB::table('loyalty_rules')->where('code', 'attendance_confirmed')->exists()) {
            DB::table('loyalty_rules')->insert([
                'code' => 'attendance_confirmed',
                'label' => 'Asistencia confirmada',
                'description' => 'Puntos otorgados cuando la entrada es escaneada por primera vez.',
                'points' => 40,
                'is_active' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            DB::table('loyalty_rules')
                ->where('code', 'attendance_confirmed')
                ->update([
                    'is_active' => 1,
                    'points' => 40,
                    'updated_at' => now(),
                ]);
        }

        if (!DB::table('reward_catalog')->where('title', 'Bono RD$50')->exists()) {
            DB::table('reward_catalog')->insert([
                [
                    'title' => 'Bono RD$50',
                    'description' => 'Canjea puntos por credito interno para tu proxima compra.',
                    'reward_type' => 'bonus_credit',
                    'points_cost' => 250,
                    'bonus_amount' => 50,
                    'is_active' => 1,
                    'is_featured' => 1,
                    'meta' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'title' => 'Bono RD$125',
                    'description' => 'Credito interno para compras de tickets o consumos futuros.',
                    'reward_type' => 'bonus_credit',
                    'points_cost' => 500,
                    'bonus_amount' => 125,
                    'is_active' => 1,
                    'is_featured' => 1,
                    'meta' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'title' => 'Perk VIP local',
                    'description' => 'Canjea un perk con codigo reclamable dentro de Duty.',
                    'reward_type' => 'perk',
                    'points_cost' => 1000,
                    'bonus_amount' => null,
                    'is_active' => 1,
                    'is_featured' => 0,
                    'meta' => json_encode([
                        'instructions' => 'Presenta este codigo al organizer o al staff para reclamar el benefit.',
                        'claim_expires_in_days' => 45,
                    ]),
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }
    }

    protected function ensureWalletTables(): void
    {
        if (!Schema::hasTable('wallets')) {
            Schema::create('wallets', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('user_id')->nullable();
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->decimal('balance', 10, 2)->default(0.00);
                $table->char('currency', 3)->default('DOP');
                $table->enum('status', ['active', 'frozen'])->default('active');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('wallet_transactions')) {
            Schema::create('wallet_transactions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('wallet_id');
                $table->enum('type', ['credit', 'debit', 'hold_release']);
                $table->decimal('amount', 10, 2);
                $table->decimal('fee', 10, 2)->default(0);
                $table->decimal('total_amount', 10, 2)->default(0);
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->string('idempotency_key')->unique();
                $table->enum('status', ['pending', 'completed', 'failed', 'reversed'])->default('completed');
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('wallet_transactions', 'fee')) {
            Schema::table('wallet_transactions', function (Blueprint $table) {
                $table->decimal('fee', 10, 2)->default(0);
            });
        }

        if (!Schema::hasColumn('wallet_transactions', 'total_amount')) {
            Schema::table('wallet_transactions', function (Blueprint $table) {
                $table->decimal('total_amount', 10, 2)->default(0);
            });
        }
    }

    protected function ensureBonusWalletTables(): void
    {
        if (!Schema::hasTable('bonus_wallets')) {
            Schema::create('bonus_wallets', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('user_id')->nullable();
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->decimal('balance', 10, 2)->default(0.00);
                $table->char('currency', 3)->default('DOP');
                $table->enum('status', ['active', 'frozen'])->default('active');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bonus_transactions')) {
            Schema::create('bonus_transactions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('bonus_wallet_id');
                $table->enum('type', ['credit', 'debit', 'reversal']);
                $table->decimal('amount', 10, 2);
                $table->decimal('consumed_amount', 10, 2)->default(0);
                $table->decimal('expired_amount', 10, 2)->default(0);
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->string('idempotency_key')->unique();
                $table->enum('status', ['pending', 'completed', 'failed', 'reversed'])->default('completed');
                $table->timestamp('expires_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureBookingPaymentAllocationTable(): void
    {
        if (!Schema::hasTable('booking_payment_allocations')) {
            Schema::create('booking_payment_allocations', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id');
                $table->string('source_type', 32);
                $table->decimal('amount', 15, 2)->default(0);
                $table->decimal('fee_amount', 15, 2)->default(0);
                $table->decimal('total_amount', 15, 2)->default(0);
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureReservationTables(): void
    {
        if (!Schema::hasTable('ticket_reservations')) {
            Schema::create('ticket_reservations', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('ticket_id');
                $table->string('reservation_code')->unique();
                $table->string('booking_order_number')->nullable();
                $table->unsignedInteger('quantity')->default(1);
                $table->decimal('reserved_unit_price', 15, 2);
                $table->decimal('total_amount', 15, 2);
                $table->decimal('deposit_required', 15, 2)->default(0);
                $table->decimal('amount_paid', 15, 2)->default(0);
                $table->decimal('remaining_balance', 15, 2)->default(0);
                $table->string('deposit_type', 32)->nullable();
                $table->decimal('deposit_value', 15, 2)->nullable();
                $table->decimal('minimum_installment_amount', 15, 2)->nullable();
                $table->dateTime('final_due_date')->nullable();
                $table->dateTime('expires_at')->nullable();
                $table->string('event_date')->nullable();
                $table->string('status', 32)->default('active');
                $table->string('payment_method', 32)->nullable();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('city')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('address')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('reservation_payments')) {
            Schema::create('reservation_payments', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reservation_id');
                $table->string('payment_group', 64);
                $table->string('source_type', 32);
                $table->decimal('amount', 15, 2)->default(0);
                $table->decimal('fee_amount', 15, 2)->default(0);
                $table->decimal('total_amount', 15, 2)->default(0);
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->string('status', 32)->default('completed');
                $table->timestamp('paid_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensurePaymentMethodsTable(): void
    {
        if (!Schema::hasTable('payment_methods')) {
            Schema::create('payment_methods', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('user_id')->nullable();
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('stripe_payment_method_id')->unique();
                $table->string('brand')->nullable();
                $table->string('last4', 4)->nullable();
                $table->integer('exp_month')->nullable();
                $table->integer('exp_year')->nullable();
                $table->boolean('is_default')->default(false);
                $table->enum('status', ['active', 'revoked'])->default('active');
                $table->timestamps();
            });
        }
    }

    protected function ensureNfcTokensTable(): void
    {
        if (!Schema::hasTable('nfc_tokens')) {
            Schema::create('nfc_tokens', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('uid_hash')->unique();
                $table->string('pin_hash')->nullable();
                $table->enum('status', ['active', 'locked', 'lost', 'expired'])->default('active');
                $table->decimal('daily_limit', 10, 2)->default(5000.00);
                $table->decimal('daily_spent', 10, 2)->default(0.00);
                $table->timestamp('last_used_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureWithdrawalRequestsTable(): void
    {
        if (!Schema::hasTable('withdrawal_requests')) {
            Schema::create('withdrawal_requests', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->decimal('amount', 15, 2);
                $table->string('method');
                $table->json('payment_details')->nullable();
                $table->enum('status', ['pending', 'approved', 'rejected', 'completed'])->default('pending');
                $table->text('admin_notes')->nullable();
                $table->string('transaction_id')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureMarketplaceTables(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('uniqid')->nullable();
                $table->decimal('marketplace_commission', 8, 2)->default(5.00);
                $table->string('firebase_admin_json')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->integer('quantity')->default(1);
                $table->boolean('is_transferable')->default(true);
                $table->boolean('is_listed')->default(false);
                $table->string('transfer_status')->nullable();
                $table->decimal('listing_price', 15, 2)->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('title')->nullable();
                $table->string('thumbnail')->nullable();
                $table->timestamp('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('bookings', 'transfer_status')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->string('transfer_status')->nullable();
            });
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'organizer_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_identity_id')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('ticket_transfers')) {
            Schema::create('ticket_transfers', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id');
                $table->unsignedBigInteger('from_customer_id');
                $table->unsignedBigInteger('to_customer_id');
                $table->text('notes')->nullable();
                $table->string('status')->default('pending');
                $table->string('flow')->default('owner_offer');
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('ticket_transfers', 'status')) {
            Schema::table('ticket_transfers', function (Blueprint $table) {
                $table->string('status')->default('pending');
            });
        }

        if (!Schema::hasColumn('ticket_transfers', 'flow')) {
            Schema::table('ticket_transfers', function (Blueprint $table) {
                $table->string('flow')->default('owner_offer');
            });
        }
    }

    protected function ensureFollowsTable(): void
    {
        if (!Schema::hasTable('follows')) {
            Schema::create('follows', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('follower_id');
                $table->string('follower_type');
                $table->unsignedBigInteger('followable_id');
                $table->string('followable_type');
                $table->string('status')->default('accepted');
                $table->timestamps();

                $table->unique(
                    ['follower_id', 'follower_type', 'followable_id', 'followable_type'],
                    'follows_unique_pair'
                );
            });
        }

        if (!Schema::hasColumn('follows', 'status')) {
            Schema::table('follows', function (Blueprint $table) {
                $table->string('status')->default('accepted');
            });
        }
    }

    protected function ensureFollowersTable(): void
    {
        // Legacy shim: maps old baseline label `followers` to the new `follows` schema.
        $this->ensureFollowsTable();
    }

    protected function ensureSubscriptionPlansTable(): void
    {
        if (!Schema::hasTable('subscription_plans')) {
            Schema::create('subscription_plans', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->text('description')->nullable();
                $table->decimal('price', 10, 2);
                $table->string('currency', 3)->default('DOP');
                $table->string('stripe_price_id')->nullable();
                $table->enum('status', ['active', 'inactive'])->default('active');
                $table->json('features')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureIdentityTables(): void
    {
        if (!Schema::hasTable('identities')) {
            Schema::create('identities', function (Blueprint $table) {
                $table->id();
                $table->string('type', 32);
                $table->string('status', 32)->default('pending');
                $table->unsignedBigInteger('owner_user_id');
                $table->string('display_name');
                $table->string('slug')->unique();
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_members')) {
            Schema::create('identity_members', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('identity_id');
                $table->unsignedBigInteger('user_id');
                $table->string('role', 32)->default('staff');
                $table->json('permissions')->nullable();
                $table->string('status', 32)->default('active');
                $table->timestamps();
            });
        }
    }

    protected function ensureLegacyIdentitySourceTables(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('photo')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('username')->nullable();
                $table->string('password')->nullable();
                $table->string('status')->default('1');
                $table->decimal('amount', 20, 2)->nullable();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('facebook')->nullable();
                $table->string('twitter')->nullable();
                $table->string('linkedin')->nullable();
                $table->string('theme_version')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('organizer_infos')) {
            Schema::create('organizer_infos', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->string('name')->nullable();
                $table->string('country')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('zip_code')->nullable();
                $table->text('address')->nullable();
                $table->longText('details')->nullable();
                $table->string('designation')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('slug')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->string('zip_code')->nullable();
                $table->decimal('latitude', 10, 8)->nullable();
                $table->decimal('longitude', 11, 8)->nullable();
                $table->text('description')->nullable();
                $table->string('image')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 20, 2)->default(0.00);
                $table->rememberToken();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->string('photo')->nullable();
                $table->text('details')->nullable();
                $table->string('facebook')->nullable();
                $table->string('twitter')->nullable();
                $table->string('linkedin')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 20, 2)->default(0.00);
                $table->timestamp('email_verified_at')->nullable();
                $table->rememberToken();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->timestamps();
            });
        } else {
            if (!Schema::hasColumn('events', 'organizer_id')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->unsignedBigInteger('organizer_id')->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'venue_id')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->unsignedBigInteger('venue_id')->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'owner_identity_id')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->unsignedBigInteger('owner_identity_id')->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'venue_identity_id')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->unsignedBigInteger('venue_identity_id')->nullable();
                });
            }
        }
    }

    protected function ensureDiscoveryCatalogTables(): void
    {
        $this->ensureLegacyIdentitySourceTables();

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->text('address')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_artist')) {
            Schema::create('event_artist', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id');
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('events', 'status')) {
            Schema::table('events', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
            });
        }

        if (!Schema::hasColumn('events', 'thumbnail')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('thumbnail')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'start_date')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('start_date')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'end_date_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('end_date_time')->nullable();
            });
        }
    }

    protected function ensureAdminPermissionTables(): void
    {
        if (!Schema::hasTable('role_permissions')) {
            Schema::create('role_permissions', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->text('permissions')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('admins')) {
            Schema::create('admins', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('role_id')->nullable();
                $table->string('first_name')->nullable();
                $table->string('last_name')->nullable();
                $table->string('image')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('address')->nullable();
                $table->text('details')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }
    }

    protected function ensureSubscriptionsTable(): void
    {
        if (!Schema::hasTable('subscriptions')) {
            Schema::create('subscriptions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('user_id');
                $table->uuid('subscription_plan_id')->nullable();
                $table->string('stripe_subscription_id')->nullable();
                $table->string('status', 32)->default('active');
                $table->timestamp('starts_at')->nullable();
                $table->timestamp('ends_at')->nullable();
                $table->timestamp('canceled_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function truncateTables(array $tables): void
    {
        foreach ($tables as $table) {
            if (Schema::hasTable($table)) {
                DB::table($table)->delete();
            }
        }
    }
}
