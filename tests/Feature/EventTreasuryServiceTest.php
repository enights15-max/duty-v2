<?php

namespace Tests\Feature;

use App\Models\EventFinancialEntry;
use App\Models\EventCollaboratorSplit;
use App\Models\EventTreasury;
use App\Models\Identity;
use App\Services\EventCollaboratorSplitService;
use App\Services\EventTreasuryService;
use App\Services\NotificationService;
use Carbon\Carbon;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class EventTreasuryServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'reservations', 'event_treasury'];
    protected array $baselineTruncate = [
        'event_settlement_settings',
        'event_financial_entries',
        'event_collaborator_mode_audit_logs',
        'event_treasuries',
        'reservation_payments',
        'ticket_reservations',
        'transactions',
        'identity_balances',
        'organizers',
        'venues',
        'events',
        'users',
        'customers',
        'identities',
        'identity_members',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureTransactionTable();
        $this->ensureFcmTokenTable();
        $this->seedOrganizerContext();
    }

    public function test_store_professional_owner_reserves_owner_share_inside_event_treasury_without_crediting_wallet(): void
    {
        $booking = (object) [
            'id' => 9001,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_id' => null,
            'organizer_identity_id' => 501,
            'price' => 250.00,
            'commission' => 40.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 301,
            'acquisition_source' => 'primary_purchase',
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
            ],
        ];

        storeProfessionalOwner($booking);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertSame(250.0, (float) $treasury->gross_collected);
        $this->assertSame(40.0, (float) $treasury->platform_fee_total);
        $this->assertSame(210.0, (float) $treasury->reserved_for_owner);
        $this->assertSame(210.0, (float) $treasury->available_for_settlement);

        $entry = EventFinancialEntry::query()->where('booking_id', 9001)->first();
        $this->assertNotNull($entry);
        $this->assertSame(EventFinancialEntry::TYPE_OWNER_SHARE_RESERVED, $entry->entry_type);
        $this->assertSame(501, (int) $entry->owner_identity_id);
        $this->assertSame('organizer', $entry->owner_identity_type);
        $this->assertSame(210.0, (float) $entry->net_amount);

        $this->assertSame(300.0, (float) DB::table('identity_balances')->where('identity_id', 501)->value('balance'));
        $this->assertSame(300.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
    }

    public function test_store_professional_owner_is_idempotent_for_the_same_booking(): void
    {
        $booking = (object) [
            'id' => 9002,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 15.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 302,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
            ],
        ];

        storeProfessionalOwner($booking);
        storeProfessionalOwner($booking);

        $this->assertSame(1, EventFinancialEntry::query()->where('booking_id', 9002)->count());

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame(100.0, (float) $treasury->gross_collected);
        $this->assertSame(15.0, (float) $treasury->platform_fee_total);
        $this->assertSame(85.0, (float) $treasury->reserved_for_owner);
    }

    public function test_store_transcation_keeps_professional_balance_preview_flat_when_treasury_is_active(): void
    {
        $booking = (object) [
            'id' => 9003,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_id' => null,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 15.00,
            'tax' => 0.00,
            'transcation_type' => 1,
            'paymentStatus' => 1,
            'paymentMethod' => 'wallet',
            'gatewayType' => 'online',
            'currencySymbol' => '$',
            'currencySymbolPosition' => 'left',
            'currencyText' => 'DOP',
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
            ],
        ];

        storeTranscation($booking);

        $transaction = DB::table('transactions')->where('booking_id', 9003)->first();

        $this->assertNotNull($transaction);
        $this->assertSame(300.0, (float) $transaction->pre_balance);
        $this->assertSame(300.0, (float) $transaction->after_balance);
    }

    public function test_treasury_hold_until_respects_event_settlement_settings(): void
    {
        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9004,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 200.00,
            'commission' => 30.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 303,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => DB::table('events')->where('id', 801)->value('end_date_time'),
            ],
        ];

        storeProfessionalOwner($booking);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertNotNull($treasury->hold_until);

        $expected = now()->addDays(5)->addHours(24);
        $actual = \Carbon\Carbon::parse($treasury->hold_until);

        $this->assertSame($expected->format('Y-m-d H'), $actual->format('Y-m-d H'));
        $this->assertFalse((bool) $treasury->auto_payout_enabled);
        $this->assertSame(24, (int) $treasury->auto_payout_delay_hours);
    }

    public function test_mark_settlement_hold_sets_treasury_status_and_records_entry(): void
    {
        $service = app(EventTreasuryService::class);

        $entry = $service->markSettlementHold(
            801,
            'reservation_refund_processed',
            now()->addHours(12),
            ['reservation_id' => 9991],
            'test_refund_hold_801'
        );

        $this->assertNotNull($entry);
        $this->assertSame(EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED, $entry->entry_type);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame('settlement_hold', $treasury->settlement_status);
        $this->assertNotNull($treasury->hold_until);
    }

    public function test_open_refund_window_for_schedule_change_uses_refund_window_hours(): void
    {
        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 72,
            'refund_window_hours' => 36,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $service = app(EventTreasuryService::class);
        $entry = $service->openRefundWindowForScheduleChange(801, [
            'changed_by_type' => 'organizer',
        ]);

        $this->assertNotNull($entry);
        $this->assertSame(EventFinancialEntry::TYPE_REFUND_WINDOW_OPENED, $entry->entry_type);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame('settlement_hold', $treasury->settlement_status);

        $existingHold = \Carbon\Carbon::parse(
            DB::table('events')->where('id', 801)->value('end_date_time')
        )->addHours(72);
        $refundWindowHold = now()->addHours(36);
        $expected = $existingHold->greaterThan($refundWindowHold)
            ? $existingHold
            : $refundWindowHold;
        $actual = \Carbon\Carbon::parse($treasury->hold_until);
        $this->assertSame($expected->format('Y-m-d H'), $actual->format('Y-m-d H'));
    }

    public function test_sync_reservation_refunds_reduces_treasury_without_double_counting(): void
    {
        DB::table('ticket_reservations')->insert([
            'id' => 8801,
            'customer_id' => 1701,
            'event_id' => 801,
            'ticket_id' => 301,
            'reservation_code' => 'RSV-TREASURY-8801',
            'quantity' => 1,
            'reserved_unit_price' => 100.00,
            'total_amount' => 100.00,
            'deposit_required' => 20.00,
            'amount_paid' => 100.00,
            'remaining_balance' => 0.00,
            'status' => 'cancelled',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reservation_payments')->insert([
            [
                'id' => 9901,
                'reservation_id' => 8801,
                'payment_group' => 'initial_8801',
                'source_type' => 'wallet',
                'amount' => 40.00,
                'fee_amount' => 0.00,
                'total_amount' => 40.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_8801',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9902,
                'reservation_id' => 8801,
                'payment_group' => 'initial_8801',
                'source_type' => 'wallet_refund',
                'amount' => -15.00,
                'fee_amount' => 0.00,
                'total_amount' => -15.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_refund_tx_8801',
                'status' => 'reversed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $service = app(EventTreasuryService::class);
        $reservation = \App\Models\Reservation\TicketReservation::query()->with(['event', 'payments'])->findOrFail(8801);

        $service->syncReservationRevenue($reservation);
        $service->syncReservationRefunds($reservation);
        $service->syncReservationRefunds($reservation);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame(40.0, (float) $treasury->gross_collected);
        $this->assertSame(15.0, (float) $treasury->refunded_amount);
        $this->assertSame(25.0, (float) $treasury->reserved_for_owner);
        $this->assertSame(25.0, (float) $treasury->available_for_settlement);

        $refundEntry = EventFinancialEntry::query()
            ->where('entry_type', EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED)
            ->where('reference_id', '9902')
            ->first();

        $this->assertNotNull($refundEntry);
        $this->assertSame(-15.0, (float) $refundEntry->gross_amount);
        $this->assertSame(-15.0, (float) $refundEntry->net_amount);
        $this->assertSame(1, EventFinancialEntry::query()
            ->where('entry_type', EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED)
            ->where('reference_id', '9902')
            ->count());
    }

    public function test_refresh_settlement_state_marks_event_as_awaiting_settlement_during_grace_period(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => Carbon::parse('2026-04-01 08:00:00'),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 72,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9010,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 150.00,
            'commission' => 20.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 305,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => '2026-04-01 08:00:00',
            ],
        ];

        storeProfessionalOwner($booking);

        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, Carbon::parse('2026-04-01 20:00:00'));

        $this->assertNotNull($snapshot);
        $this->assertSame(EventTreasury::STATUS_AWAITING_SETTLEMENT, $snapshot['status']);
        $this->assertTrue($snapshot['event_completed']);
        $this->assertGreaterThan(0, $snapshot['remaining_hold_hours']);
        $this->assertSame(130.0, (float) $snapshot['claimable_amount']);
        $this->assertFalse($snapshot['can_release_now']);
    }

    public function test_refresh_settlement_state_marks_event_as_eligible_after_hold_expires(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => Carbon::parse('2026-04-01 08:00:00'),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9011,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 120.00,
            'commission' => 12.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 306,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => '2026-04-01 08:00:00',
            ],
        ];

        storeProfessionalOwner($booking);

        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, Carbon::parse('2026-04-03 12:00:00'));

        $this->assertNotNull($snapshot);
        $this->assertSame(EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT, $snapshot['status']);
        $this->assertSame(108.0, (float) $snapshot['claimable_amount']);
        $this->assertTrue($snapshot['can_release_now']);
    }

    public function test_refresh_settlement_state_marks_event_as_settled_when_claimable_amount_is_zero(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => Carbon::parse('2026-04-01 08:00:00'),
        ]);

        DB::table('event_treasuries')->insert([
            'event_id' => 801,
            'gross_collected' => 100.00,
            'refunded_amount' => 0.00,
            'platform_fee_total' => 10.00,
            'reserved_for_owner' => 90.00,
            'reserved_for_collaborators' => 0.00,
            'released_to_wallet' => 90.00,
            'available_for_settlement' => 90.00,
            'hold_until' => Carbon::parse('2026-04-02 08:00:00'),
            'settlement_status' => EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT,
            'auto_payout_enabled' => false,
            'auto_payout_delay_hours' => 24,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, Carbon::parse('2026-04-03 12:00:00'));

        $this->assertNotNull($snapshot);
        $this->assertSame(EventTreasury::STATUS_SETTLED, $snapshot['status']);
        $this->assertSame(0.0, (float) $snapshot['claimable_amount']);
        $this->assertFalse($snapshot['can_release_now']);
    }

    public function test_claim_owner_share_to_wallet_releases_claimable_amount_to_professional_balance(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9012,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 307,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        $claim = app(EventTreasuryService::class)->claimOwnerShareToWallet(801);

        $this->assertSame(90.0, (float) ($claim['claimed_amount'] ?? 0));
        $this->assertSame(300.0, (float) data_get($claim, 'balance_transaction.balance_before'));
        $this->assertSame(390.0, (float) data_get($claim, 'balance_transaction.balance_after'));

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame(90.0, (float) $treasury->released_to_wallet);
        $this->assertSame(EventTreasury::STATUS_SETTLED, $treasury->settlement_status);
        $this->assertSame(390.0, (float) DB::table('identity_balances')->where('identity_id', 501)->value('balance'));
        $this->assertSame(390.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));

        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
            'status' => 'released',
        ]);
        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 501,
            'type' => 'credit',
            'reference_type' => 'event_treasury_release',
        ]);
    }

    public function test_admin_approval_unlocks_event_that_requires_manual_settlement_review(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9020,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 401,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        $before = app(EventTreasuryService::class)->settlementSnapshot(801, now());
        $this->assertSame(EventTreasury::STATUS_SETTLEMENT_HOLD, $before['status']);
        $this->assertTrue($before['needs_admin_approval']);

        $approval = app(EventTreasuryService::class)->approveOwnerRelease(801, 9911, now());
        $after = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $this->assertFalse((bool) ($approval['already_approved'] ?? true));
        $this->assertSame(EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT, $after['status']);
        $this->assertFalse($after['needs_admin_approval']);
        $this->assertTrue($after['can_release_now']);
        $this->assertSame(9911, (int) $after['admin_release_approved_by_admin_id']);

        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED,
            'reference_type' => 'admin',
            'reference_id' => '9911',
            'status' => 'approved',
        ]);
    }

    public function test_admin_release_can_credit_owner_wallet_directly_from_settlement_queue(): void
    {
        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9021,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 120.00,
            'commission' => 12.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 402,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        $result = app(EventTreasuryService::class)->releaseOwnerShareByAdmin(801, 9922, now());

        $this->assertSame(108.0, (float) data_get($result, 'claim.claimed_amount'));
        $this->assertSame(408.0, (float) DB::table('identity_balances')->where('identity_id', 501)->value('balance'));
        $this->assertSame(408.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $this->assertNotNull($treasury);
        $this->assertSame(108.0, (float) $treasury->released_to_wallet);
        $this->assertSame(EventTreasury::STATUS_SETTLED, $treasury->settlement_status);

        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
            'status' => 'released',
        ]);

        $releaseMetadata = DB::table('event_financial_entries')
            ->where('event_id', 801)
            ->where('entry_type', EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET)
            ->orderByDesc('id')
            ->value('metadata');

        $this->assertStringContainsString('admin_release', (string) $releaseMetadata);
        $this->assertStringContainsString('9922', (string) $releaseMetadata);
    }

    public function test_collaborator_reserve_reduces_owner_claimable_amount(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9013,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 308,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        app(EventCollaboratorSplitService::class)->syncEventCollaboratorEarnings(801, now());
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertSame(36.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT, $snapshot['status']);
        $this->assertSame(54.0, (float) $snapshot['claimable_amount']);
        $this->assertTrue($snapshot['can_release_now']);
    }

    public function test_collaborator_claim_releases_reserved_share_to_their_wallet(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9014,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 309,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        $split = EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        $service = app(EventCollaboratorSplitService::class);
        $service->syncEventCollaboratorEarnings(801, now());
        $earning = $split->fresh('earning')->earning;

        $this->assertNotNull($earning);
        $claim = $service->claimEarningToWallet($earning->id, Identity::query()->findOrFail(601), now(), false);

        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $this->assertSame(36.0, (float) ($claim['claimed_amount'] ?? 0));
        $this->assertNotNull($treasury);
        $this->assertSame(36.0, (float) $treasury->released_to_wallet);
        $this->assertSame(0.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(86.0, (float) DB::table('identity_balances')->where('identity_id', 601)->value('balance'));
        $this->assertSame(54.0, (float) $snapshot['claimable_amount']);

        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET,
            'target_identity_id' => 601,
            'target_identity_type' => 'artist',
            'status' => 'released',
        ]);
        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => 601,
            'type' => 'credit',
            'reference_type' => 'event_collaborator_earning_claim',
        ]);
    }

    public function test_settlement_report_includes_collaborator_reconciliation_for_unreleased_split_amounts(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9014,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 309,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'release_mode' => EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        $report = app(EventTreasuryService::class)->buildSettlementReportData(801, now());

        $this->assertSame(36.0, (float) data_get($report, 'reconciliation.collaborator_claimable_amount'));
        $this->assertSame(0.0, (float) data_get($report, 'reconciliation.collaborator_pending_amount'));
        $this->assertSame(0.0, (float) data_get($report, 'reconciliation.collaborator_claimed_amount'));
        $this->assertSame(54.0, (float) data_get($report, 'reconciliation.owner_claimable_amount'));
        $this->assertSame(90.0, (float) data_get($report, 'reconciliation.total_unreleased_amount'));
        $this->assertSame(0.0, (float) data_get($report, 'reconciliation.unreleased_balance_delta'));
        $this->assertSame(36.0, (float) data_get($report, 'collaborator_reconciliation.reserved_for_collaborators'));
        $this->assertSame(90.0, (float) data_get($report, 'collaborator_reconciliation.basis_breakdown.0.max_basis_amount'));
        $this->assertSame('claim_required', data_get($report, 'collaborator_reconciliation.split_allocations.0.effective_release_mode'));
        $this->assertSame(90.0, (float) data_get($report, 'collaborator_reconciliation.split_allocations.0.basis_amount'));
    }

    public function test_settlement_report_tracks_collaborator_wallet_release_in_reconciliation(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9015,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 310,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        $split = EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'release_mode' => EventCollaboratorSplit::RELEASE_MODE_CLAIM_REQUIRED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        $service = app(EventCollaboratorSplitService::class);
        $service->syncEventCollaboratorEarnings(801, now());
        $earning = $split->fresh('earning')->earning;
        $service->claimEarningToWallet($earning->id, Identity::query()->findOrFail(601), now(), false);

        $report = app(EventTreasuryService::class)->buildSettlementReportData(801, now());

        $this->assertSame(36.0, (float) data_get($report, 'reconciliation.collaborator_released_to_wallet'));
        $this->assertSame(36.0, (float) data_get($report, 'reconciliation.collaborator_claimed_amount'));
        $this->assertSame(0.0, (float) data_get($report, 'reconciliation.reserved_for_collaborators'));
        $this->assertSame(0.0, (float) data_get($report, 'reconciliation.owner_released_to_wallet'));
        $this->assertSame(54.0, (float) data_get($report, 'reconciliation.total_unreleased_amount'));
        $this->assertSame(36.0, (float) data_get($report, 'collaborator_reconciliation.released_to_wallet'));
        $this->assertSame(36.0, (float) data_get($report, 'collaborator_reconciliation.claimed_amount'));
        $this->assertSame(36.0, (float) data_get($report, 'collaborator_reconciliation.basis_breakdown.0.claimed_amount'));
    }

    public function test_fixed_collaborator_split_reserves_fixed_amount_from_event_distributable(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9016,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 311,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_FIXED,
            'split_value' => 20,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        app(EventCollaboratorSplitService::class)->syncEventCollaboratorEarnings(801, now());
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertSame(20.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(70.0, (float) $snapshot['claimable_amount']);
        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'amount_reserved' => 20.00,
        ]);
    }

    public function test_fixed_splits_apply_before_percentage_splits_on_remaining_amount(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9017,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 312,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_FIXED,
            'split_value' => 20,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        DB::table('identities')->insert([
            'id' => 602,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 1003,
            'display_name' => 'Second Treasury Artist',
            'slug' => 'second-treasury-artist',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1003,
            'email' => 'artist-two@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1003,
            'email' => 'artist-two@example.com',
            'fname' => 'Artist',
            'lname' => 'Two',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 43,
            'name' => 'Second Treasury Artist',
            'username' => 'second-treasury-artist',
            'email' => 'artist-two@example.com',
            'amount' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 602,
            'balance' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 602,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 50,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        $sync = app(EventCollaboratorSplitService::class)->syncEventCollaboratorEarnings(801, now());
        $treasury = EventTreasury::query()->where('event_id', 801)->first();
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $this->assertSame(90.0, (float) ($sync['distributable_amount'] ?? 0));
        $this->assertNotNull($treasury);
        $this->assertSame(55.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(35.0, (float) $snapshot['claimable_amount']);

        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'amount_reserved' => 20.00,
        ]);
        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 602,
            'amount_reserved' => 35.00,
        ]);
    }

    public function test_gross_ticket_sales_basis_reserves_against_gross_collected(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9018,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 313,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 10,
            'basis' => EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        app(EventCollaboratorSplitService::class)->syncEventCollaboratorEarnings(801, now());
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertSame(10.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(80.0, (float) $snapshot['claimable_amount']);
        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'amount_reserved' => 10.00,
        ]);
    }

    public function test_mixed_basis_allocations_are_capped_to_distributable_amount_for_safety(): void
    {
        $this->seedArtistContext();

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9019,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 314,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_FIXED,
            'split_value' => 50,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        DB::table('identities')->insert([
            'id' => 602,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 1003,
            'display_name' => 'Second Treasury Artist',
            'slug' => 'second-treasury-artist',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1003,
            'email' => 'artist-two@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1003,
            'email' => 'artist-two@example.com',
            'fname' => 'Artist',
            'lname' => 'Two',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 43,
            'name' => 'Second Treasury Artist',
            'username' => 'second-treasury-artist',
            'email' => 'artist-two@example.com',
            'amount' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 602,
            'balance' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 602,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_FIXED,
            'split_value' => 50,
            'basis' => EventCollaboratorSplit::BASIS_GROSS_TICKET_SALES,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        app(EventCollaboratorSplitService::class)->syncEventCollaboratorEarnings(801, now());
        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $treasury = EventTreasury::query()->where('event_id', 801)->first();

        $this->assertNotNull($treasury);
        $this->assertSame(90.0, (float) $treasury->reserved_for_collaborators);
        $this->assertSame(0.0, (float) $snapshot['claimable_amount']);

        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'amount_reserved' => 45.00,
        ]);
        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 602,
            'amount_reserved' => 45.00,
        ]);
    }

    public function test_refresh_settlement_state_auto_releases_collaborator_shares_marked_for_auto_release(): void
    {
        $this->seedArtistContext();

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')
            ->once()
            ->withArgs(function ($user, string $title, string $body, array $data) {
                return (int) $user->id === 1002
                    && $title === 'Duty: ganancia acreditada'
                    && str_contains($body, 'Treasury Artist Identity')
                    && ($data['type'] ?? null) === 'collaboration_auto_release'
                    && ($data['event_id'] ?? null) === '801'
                    && ($data['identity_id'] ?? null) === '601';
            })
            ->andReturn(true);
        $this->app->instance(NotificationService::class, $notificationService);

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9015,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 310,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'requires_claim' => false,
            'auto_release' => true,
        ]);

        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $this->assertSame(EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT, $snapshot['status']);
        $this->assertSame(54.0, (float) $snapshot['claimable_amount']);
        $this->assertSame(86.0, (float) DB::table('identity_balances')->where('identity_id', 601)->value('balance'));

        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'status' => 'claimed',
        ]);
        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET,
            'target_identity_id' => 601,
            'target_identity_type' => 'artist',
        ]);

        $entryMetadata = DB::table('event_financial_entries')
            ->where('event_id', 801)
            ->where('entry_type', EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET)
            ->orderByDesc('id')
            ->value('metadata');

        $this->assertSame(
            'auto_release',
            data_get(json_decode((string) $entryMetadata, true), 'release_source')
        );
    }

    public function test_refresh_settlement_state_auto_releases_inherited_collaborator_shares_when_event_policy_enables_it(): void
    {
        $this->seedArtistContext();

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')
            ->once()
            ->withArgs(function ($user, string $title, string $body, array $data) {
                return (int) $user->id === 1002
                    && $title === 'Duty: ganancia acreditada'
                    && str_contains($body, 'Treasury Artist Identity')
                    && ($data['type'] ?? null) === 'collaboration_auto_release'
                    && ($data['event_id'] ?? null) === '801'
                    && ($data['identity_id'] ?? null) === '601';
            })
            ->andReturn(true);
        $this->app->instance(NotificationService::class, $notificationService);

        DB::table('events')->where('id', 801)->update([
            'end_date_time' => now()->subDays(5),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => 801,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 48,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 1,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $booking = (object) [
            'id' => 9020,
            'event_id' => 801,
            'customer_id' => 1701,
            'organizer_identity_id' => 501,
            'price' => 100.00,
            'commission' => 10.00,
            'currencyText' => 'DOP',
            'paymentStatus' => 1,
            'ticket_id' => 315,
            'evnt' => (object) [
                'id' => 801,
                'owner_identity_id' => 501,
                'end_date_time' => now()->subDays(5)->toDateTimeString(),
            ],
        ];

        storeProfessionalOwner($booking);

        EventCollaboratorSplit::query()->create([
            'event_id' => 801,
            'identity_id' => 601,
            'identity_type' => 'artist',
            'role_type' => 'artist',
            'split_type' => EventCollaboratorSplit::TYPE_PERCENTAGE,
            'split_value' => 40,
            'basis' => EventCollaboratorSplit::BASIS_NET_EVENT_REVENUE,
            'status' => EventCollaboratorSplit::STATUS_CONFIRMED,
            'release_mode' => EventCollaboratorSplit::RELEASE_MODE_INHERIT,
            'requires_claim' => true,
            'auto_release' => false,
        ]);

        $snapshot = app(EventTreasuryService::class)->settlementSnapshot(801, now());

        $this->assertSame(EventTreasury::STATUS_ELIGIBLE_FOR_PAYOUT, $snapshot['status']);
        $this->assertSame(54.0, (float) $snapshot['claimable_amount']);
        $this->assertSame(86.0, (float) DB::table('identity_balances')->where('identity_id', 601)->value('balance'));

        $this->assertDatabaseHas('event_collaborator_earnings', [
            'event_id' => 801,
            'identity_id' => 601,
            'status' => 'claimed',
        ]);
        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => 801,
            'entry_type' => EventFinancialEntry::TYPE_COLLABORATOR_SHARE_RELEASED_TO_WALLET,
            'target_identity_id' => 601,
            'target_identity_type' => 'artist',
        ]);
    }

    private function seedOrganizerContext(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'treasury-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1701,
            'email' => 'ticket-buyer@example.com',
            'fname' => 'Ticket',
            'lname' => 'Buyer',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'treasury-organizer',
            'email' => 'treasury-organizer@example.com',
            'amount' => 300,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Treasury Organizer Identity',
            'slug' => 'treasury-organizer-identity',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 41,
            'balance' => 300,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 801,
            'organizer_id' => null,
            'venue_id' => null,
            'owner_identity_id' => 501,
            'venue_identity_id' => null,
            'end_date_time' => now()->addDays(5),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedArtistContext(): void
    {
        DB::table('users')->insert([
            'id' => 1002,
            'email' => 'treasury-artist@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 601,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 1002,
            'display_name' => 'Treasury Artist Identity',
            'slug' => 'treasury-artist-identity',
            'meta' => json_encode([]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 601,
            'legacy_type' => 'artist',
            'legacy_id' => null,
            'balance' => 50,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureTransactionTable(): void
    {
        if (!Schema::hasTable('transactions')) {
            Schema::create('transactions', function (Blueprint $table): void {
                $table->id();
                $table->string('transcation_id')->nullable();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->integer('transcation_type')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
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
    }

    private function ensureFcmTokenTable(): void
    {
        if (!Schema::hasTable('fcm_tokens')) {
            Schema::create('fcm_tokens', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('user_id')->nullable();
                $table->string('token')->nullable();
                $table->string('platform')->nullable();
                $table->timestamps();
            });
        }
    }
}
