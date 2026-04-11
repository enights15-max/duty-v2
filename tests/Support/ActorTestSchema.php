<?php

namespace Tests\Support;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

trait ActorTestSchema
{
    protected function ensureEventRewardTables(): void
    {
        if (!Schema::hasTable('event_reward_definitions')) {
            Schema::create('event_reward_definitions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title');
                $table->text('description')->nullable();
                $table->string('reward_type', 32)->default('perk');
                $table->string('trigger_mode', 32)->default('on_ticket_scan');
                $table->string('fulfillment_mode', 32)->default('qr_claim');
                $table->unsignedInteger('inventory_limit')->nullable();
                $table->unsignedInteger('per_ticket_quantity')->default(1);
                $table->text('eligible_ticket_ids')->nullable();
                $table->text('station_scope')->nullable();
                $table->text('meta')->nullable();
                $table->string('status', 32)->default('active');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_reward_instances')) {
            Schema::create('event_reward_instances', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('reward_definition_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->string('ticket_unit_key', 120)->nullable();
                $table->unsignedInteger('instance_index')->default(1);
                $table->string('claim_code')->unique();
                $table->text('claim_qr_payload')->nullable();
                $table->string('status', 32)->default('reserved');
                $table->timestamp('activated_at')->nullable();
                $table->timestamp('claimed_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->unsignedBigInteger('claimed_by_identity_id')->nullable();
                $table->unsignedBigInteger('claimed_station_id')->nullable();
                $table->text('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_reward_claim_logs')) {
            Schema::create('event_reward_claim_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reward_instance_id');
                $table->string('action', 32);
                $table->unsignedBigInteger('actor_identity_id')->nullable();
                $table->unsignedBigInteger('station_id')->nullable();
                $table->string('reason_code', 64)->nullable();
                $table->text('meta')->nullable();
                $table->timestamp('occurred_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureEconomyTables(): void
    {
        if (!Schema::hasTable('fee_policies')) {
            Schema::create('fee_policies', function (Blueprint $table) {
                $table->id();
                $table->string('operation_key', 64)->unique();
                $table->string('label');
                $table->text('description')->nullable();
                $table->string('fee_type', 32)->default('percentage');
                $table->decimal('percentage_value', 8, 4)->nullable();
                $table->decimal('fixed_value', 12, 2)->nullable();
                $table->decimal('minimum_fee', 12, 2)->nullable();
                $table->decimal('maximum_fee', 12, 2)->nullable();
                $table->string('charged_to', 32)->default('seller');
                $table->string('currency', 8)->default('DOP');
                $table->boolean('is_active')->default(true);
                $table->text('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('platform_revenue_events')) {
            Schema::create('platform_revenue_events', function (Blueprint $table) {
                $table->id();
                $table->string('idempotency_key')->unique();
                $table->unsignedBigInteger('policy_id')->nullable();
                $table->string('operation_key', 64);
                $table->string('reference_type', 64)->nullable();
                $table->string('reference_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('transfer_id')->nullable();
                $table->unsignedBigInteger('actor_customer_id')->nullable();
                $table->unsignedBigInteger('target_customer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('owner_identity_type', 32)->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->decimal('gross_amount', 15, 2)->default(0);
                $table->decimal('fee_amount', 15, 2)->default(0);
                $table->decimal('net_amount', 15, 2)->default(0);
                $table->decimal('total_charge_amount', 15, 2)->default(0);
                $table->string('charged_to', 32)->default('seller');
                $table->string('currency', 8)->default('DOP');
                $table->string('status', 32)->default('completed');
                $table->text('metadata')->nullable();
                $table->timestamp('occurred_at')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureEventTreasuryTables(): void
    {
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

        if (!Schema::hasTable('event_lineups')) {
            Schema::create('event_lineups', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('source_type', 32)->default('artist');
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->unsignedBigInteger('identity_id')->nullable();
                $table->string('display_name')->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'end_date_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('end_date_time')->nullable();
            });
        }

        if (!Schema::hasTable('event_settlement_settings')) {
            Schema::create('event_settlement_settings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->unique();
                $table->string('hold_mode', 48)->default('auto_after_grace_period');
                $table->unsignedInteger('grace_period_hours')->default(72);
                $table->unsignedInteger('refund_window_hours')->default(72);
                $table->boolean('auto_release_owner_share')->default(false);
                $table->boolean('auto_release_collaborator_shares')->default(false);
                $table->boolean('require_admin_approval')->default(false);
                $table->text('notes')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_treasuries')) {
            Schema::create('event_treasuries', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->unique();
                $table->decimal('gross_collected', 15, 2)->default(0);
                $table->decimal('refunded_amount', 15, 2)->default(0);
                $table->decimal('platform_fee_total', 15, 2)->default(0);
                $table->decimal('reserved_for_owner', 15, 2)->default(0);
                $table->decimal('reserved_for_collaborators', 15, 2)->default(0);
                $table->decimal('released_to_wallet', 15, 2)->default(0);
                $table->decimal('available_for_settlement', 15, 2)->default(0);
                $table->timestamp('hold_until')->nullable();
                $table->timestamp('admin_release_approved_at')->nullable();
                $table->unsignedBigInteger('admin_release_approved_by_admin_id')->nullable();
                $table->string('settlement_status', 32)->default('collecting');
                $table->boolean('auto_payout_enabled')->default(false);
                $table->unsignedInteger('auto_payout_delay_hours')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('event_treasuries') && !Schema::hasColumn('event_treasuries', 'admin_release_approved_at')) {
            Schema::table('event_treasuries', function (Blueprint $table) {
                $table->timestamp('admin_release_approved_at')->nullable();
            });
        }

        if (Schema::hasTable('event_treasuries') && !Schema::hasColumn('event_treasuries', 'admin_release_approved_by_admin_id')) {
            Schema::table('event_treasuries', function (Blueprint $table) {
                $table->unsignedBigInteger('admin_release_approved_by_admin_id')->nullable();
            });
        }

        if (!Schema::hasTable('event_financial_entries')) {
            Schema::create('event_financial_entries', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('treasury_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->string('idempotency_key')->unique();
                $table->string('entry_type', 64);
                $table->string('reference_type', 64)->nullable();
                $table->string('reference_id')->nullable();
                $table->unsignedBigInteger('actor_customer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('owner_identity_type', 32)->nullable();
                $table->unsignedBigInteger('target_identity_id')->nullable();
                $table->string('target_identity_type', 32)->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->decimal('gross_amount', 15, 2)->default(0);
                $table->decimal('fee_amount', 15, 2)->default(0);
                $table->decimal('net_amount', 15, 2)->default(0);
                $table->string('currency', 8)->default('DOP');
                $table->string('status', 32)->default('reserved');
                $table->text('metadata')->nullable();
                $table->timestamp('occurred_at')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('event_financial_entries') && !Schema::hasColumn('event_financial_entries', 'target_identity_id')) {
            Schema::table('event_financial_entries', function (Blueprint $table) {
                $table->unsignedBigInteger('target_identity_id')->nullable();
            });
        }

        if (Schema::hasTable('event_financial_entries') && !Schema::hasColumn('event_financial_entries', 'target_identity_type')) {
            Schema::table('event_financial_entries', function (Blueprint $table) {
                $table->string('target_identity_type', 32)->nullable();
            });
        }

        if (!Schema::hasTable('event_collaborator_splits')) {
            Schema::create('event_collaborator_splits', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('identity_id');
                $table->string('identity_type', 32);
                $table->unsignedBigInteger('legacy_id')->nullable();
                $table->string('role_type', 32)->default('artist');
                $table->string('split_type', 32)->default('percentage');
                $table->decimal('split_value', 8, 4)->default(0);
                $table->string('basis', 32)->default('net_event_revenue');
                $table->string('status', 32)->default('confirmed');
                $table->string('release_mode', 32)->default('claim_required');
                $table->boolean('requires_claim')->default(true);
                $table->boolean('auto_release')->default(false);
                $table->text('notes')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('event_collaborator_splits') && !Schema::hasColumn('event_collaborator_splits', 'release_mode')) {
            Schema::table('event_collaborator_splits', function (Blueprint $table) {
                $table->string('release_mode', 32)->default('claim_required')->after('status');
            });
        }

        if (!Schema::hasTable('event_collaborator_earnings')) {
            Schema::create('event_collaborator_earnings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('split_id');
                $table->unsignedBigInteger('identity_id');
                $table->string('identity_type', 32);
                $table->string('role_type', 32)->default('artist');
                $table->decimal('amount_reserved', 15, 2)->default(0);
                $table->decimal('amount_claimed', 15, 2)->default(0);
                $table->string('status', 32)->default('pending_event_completion');
                $table->timestamp('released_at')->nullable();
                $table->timestamp('claimed_at')->nullable();
                $table->timestamp('last_calculated_at')->nullable();
                $table->text('metadata')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_collaborator_mode_audit_logs')) {
            Schema::create('event_collaborator_mode_audit_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('split_id');
                $table->unsignedBigInteger('earning_id')->nullable();
                $table->unsignedBigInteger('identity_id');
                $table->unsignedBigInteger('actor_identity_id')->nullable();
                $table->string('actor_identity_type', 32)->nullable();
                $table->boolean('previous_requires_claim')->default(true);
                $table->boolean('previous_auto_release')->default(false);
                $table->boolean('new_requires_claim')->default(true);
                $table->boolean('new_auto_release')->default(false);
                $table->string('source', 48)->default('manual_toggle');
                $table->text('metadata')->nullable();
                $table->timestamps();
            });
        }
    }

    protected function ensureUsersAndCustomersTables(): void
    {
        if (!Schema::hasTable('users')) {
            Schema::create('users', function (Blueprint $table) {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('first_name')->nullable();
                $table->string('last_name')->nullable();
                $table->string('phone')->nullable();
                $table->string('contact_number')->nullable();
                $table->string('country')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('address')->nullable();
                $table->string('stripe_customer_id')->nullable();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
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
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('city')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('address')->nullable();
                $table->string('photo')->nullable();
                $table->string('stripe_customer_id')->nullable();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('password')->nullable();
                $table->boolean('is_private')->default(false);
                $table->boolean('show_interested_events')->default(true);
                $table->boolean('show_attended_events')->default(true);
                $table->boolean('show_upcoming_attendance')->default(true);
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'username')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('username')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'stripe_customer_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('stripe_customer_id')->nullable();
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

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'phone')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('phone')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'contact_number')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('contact_number')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'country')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('country')->nullable();
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

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'address')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('address')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'email_verified_at')) {
            Schema::table('users', function (Blueprint $table) {
                $table->timestamp('email_verified_at')->nullable();
            });
        }

        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'status')) {
            Schema::table('users', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'stripe_customer_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('stripe_customer_id')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'email_verified_at')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->timestamp('email_verified_at')->nullable();
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

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'country')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('country')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'state')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('state')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'city')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('city')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'zip_code')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('zip_code')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'address')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('address')->nullable();
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

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'photo')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->string('photo')->nullable();
            });
        }

        if (Schema::hasTable('customers') && !Schema::hasColumn('customers', 'status')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
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

    protected function ensureReviewsTable(): void
    {
        if (Schema::hasTable('reviews')) {
            return;
        }

        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('reviewable_id');
            $table->string('reviewable_type');
            $table->unsignedTinyInteger('rating');
            $table->text('comment')->nullable();
            $table->string('status', 32)->default('published');
            $table->json('meta')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();
        });
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

        if (!Schema::hasColumn('wallet_transactions', 'meta')) {
            Schema::table('wallet_transactions', function (Blueprint $table) {
                $table->json('meta')->nullable();
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

        if (!Schema::hasColumn('booking_payment_allocations', 'meta')) {
            Schema::table('booking_payment_allocations', function (Blueprint $table) {
                $table->json('meta')->nullable();
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

        if (!Schema::hasColumn('reservation_payments', 'meta')) {
            Schema::table('reservation_payments', function (Blueprint $table) {
                $table->json('meta')->nullable();
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
                $table->unsignedBigInteger('identity_id')->nullable();
                $table->string('actor_type', 32)->nullable();
                $table->string('display_name')->nullable();
                $table->decimal('amount', 15, 2);
                $table->string('method');
                $table->json('payment_details')->nullable();
                $table->enum('status', ['pending', 'approved', 'rejected', 'completed'])->default('pending');
                $table->text('admin_notes')->nullable();
                $table->string('transaction_id')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('withdrawal_requests') && !Schema::hasColumn('withdrawal_requests', 'identity_id')) {
            Schema::table('withdrawal_requests', function (Blueprint $table) {
                $table->unsignedBigInteger('identity_id')->nullable();
            });
        }

        if (Schema::hasTable('withdrawal_requests') && !Schema::hasColumn('withdrawal_requests', 'actor_type')) {
            Schema::table('withdrawal_requests', function (Blueprint $table) {
                $table->string('actor_type', 32)->nullable();
            });
        }

        if (Schema::hasTable('withdrawal_requests') && !Schema::hasColumn('withdrawal_requests', 'display_name')) {
            Schema::table('withdrawal_requests', function (Blueprint $table) {
                $table->string('display_name')->nullable();
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
                $table->string('fname')->nullable();
                $table->string('lname')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->decimal('price', 15, 2)->default(0);
                $table->integer('quantity')->default(1);
                $table->boolean('is_transferable')->default(true);
                $table->boolean('is_listed')->default(false);
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
                $table->string('review_status', 40)->nullable();
                $table->text('review_notes')->nullable();
                $table->timestamp('reviewed_at')->nullable();
                $table->unsignedBigInteger('reviewed_by_admin_id')->nullable();
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
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'review_status' => fn (Blueprint $table) => $table->string('review_status', 40)->nullable(),
            'review_notes' => fn (Blueprint $table) => $table->text('review_notes')->nullable(),
            'reviewed_at' => fn (Blueprint $table) => $table->timestamp('reviewed_at')->nullable(),
            'reviewed_by_admin_id' => fn (Blueprint $table) => $table->unsignedBigInteger('reviewed_by_admin_id')->nullable(),
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
                $table->string('status', 32)->nullable();
                $table->string('flow', 64)->nullable();
                $table->timestamps();
            });
        } else {
            if (!Schema::hasColumn('ticket_transfers', 'status')) {
                Schema::table('ticket_transfers', fn ($t) => $t->string('status', 32)->nullable());
            }
            if (!Schema::hasColumn('ticket_transfers', 'flow')) {
                Schema::table('ticket_transfers', fn ($t) => $t->string('flow', 64)->nullable());
            }
        }
    }

    protected function ensureFollowersTable(): void
    {
        if (!Schema::hasTable('follows')) {
            Schema::create('follows', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('follower_id');
                $table->string('follower_type')->nullable();
                $table->unsignedBigInteger('followable_id');
                $table->string('followable_type')->nullable();
                $table->string('status', 32)->default('accepted');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('followers')) {
            Schema::create('followers', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('following_id');
                $table->string('following_type');
                $table->timestamps();
            });
        }
    }

    protected function ensureLoyaltyTables(): void
    {
        if (!Schema::hasTable('loyalty_rules')) {
            Schema::create('loyalty_rules', function (Blueprint $table) {
                $table->id();
                $table->string('code', 64)->unique();
                $table->string('label')->nullable();
                $table->text('description')->nullable();
                $table->unsignedInteger('points')->default(0);
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
                $table->integer('points')->default(0);
                $table->integer('balance_after')->default(0);
                $table->string('reference_type', 64)->nullable();
                $table->string('reference_id')->nullable();
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
                $table->string('name')->nullable();
                $table->string('code')->unique();
                $table->string('type', 32);
                $table->decimal('value', 10, 2)->default(0);
                $table->text('events')->nullable();
                $table->dateTime('start_date')->nullable();
                $table->dateTime('end_date')->nullable();
                $table->timestamps();
            });
        }

        $now = now();
        $rules = [
            ['code' => 'event_purchase', 'label' => 'Compra de evento', 'points' => 100, 'is_active' => true],
            ['code' => 'marketplace_purchase', 'label' => 'Compra en marketplace', 'points' => 60, 'is_active' => true],
            ['code' => 'published_review', 'label' => 'Review publicada', 'points' => 25, 'is_active' => true],
            ['code' => 'follow_accept', 'label' => 'Nuevo follow', 'points' => 10, 'is_active' => true],
            ['code' => 'attendance_confirmed', 'label' => 'Asistencia confirmada', 'points' => 40, 'is_active' => false],
        ];

        foreach ($rules as $rule) {
            if (!DB::table('loyalty_rules')->where('code', $rule['code'])->exists()) {
                DB::table('loyalty_rules')->insert(array_merge($rule, [
                    'created_at' => $now,
                    'updated_at' => $now,
                ]));
            }
        }

        if (!DB::table('reward_catalog')->where('title', 'Bono RD$50')->exists()) {
            DB::table('reward_catalog')->insert([
                'title' => 'Bono RD$50',
                'description' => 'Canjea puntos por credito interno para tu proxima compra.',
                'reward_type' => 'bonus_credit',
                'points_cost' => 250,
                'bonus_amount' => 50,
                'is_active' => true,
                'is_featured' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
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

        if (!Schema::hasTable('identity_balances')) {
            Schema::create('identity_balances', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('identity_id')->unique();
                $table->string('legacy_type')->nullable();
                $table->unsignedBigInteger('legacy_id')->nullable();
                $table->decimal('balance', 15, 2)->default(0);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_balance_transactions')) {
            Schema::create('identity_balance_transactions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->unsignedBigInteger('identity_id');
                $table->string('type', 32);
                $table->decimal('amount', 15, 2);
                $table->string('description')->nullable();
                $table->string('reference_type')->nullable();
                $table->string('reference_id')->nullable();
                $table->decimal('balance_before', 15, 2)->default(0);
                $table->decimal('balance_after', 15, 2)->default(0);
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
                $table->string('review_status', 40)->nullable();
                $table->text('review_notes')->nullable();
                $table->timestamp('reviewed_at')->nullable();
                $table->unsignedBigInteger('reviewed_by_admin_id')->nullable();
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
            if (!Schema::hasColumn('events', 'review_status')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->string('review_status', 40)->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'review_notes')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->text('review_notes')->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'reviewed_at')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->timestamp('reviewed_at')->nullable();
                });
            }
            if (!Schema::hasColumn('events', 'reviewed_by_admin_id')) {
                Schema::table('events', function (Blueprint $table) {
                    $table->unsignedBigInteger('reviewed_by_admin_id')->nullable();
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
                $table->unsignedBigInteger('event_category_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->text('address')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('event_contents', 'event_category_id')) {
            Schema::table('event_contents', function (Blueprint $table) {
                $table->unsignedBigInteger('event_category_id')->nullable();
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

        if (!Schema::hasTable('event_categories')) {
            Schema::create('event_categories', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->string('slug')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->integer('serial_number')->default(0);
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

        if (!Schema::hasColumn('events', 'start_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('start_time')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'duration')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('duration')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'end_date_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('end_date_time')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'date_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('date_type')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'event_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('event_type')->nullable();
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
