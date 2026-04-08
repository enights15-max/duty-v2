<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\EconomyController;
use App\Models\EventFinancialEntry;
use App\Models\EventTreasury;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Tests\Support\ActorFeatureTestCase;

class AdminSettlementReviewControllerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'discovery_catalog', 'economy', 'event_treasury', 'reservations', 'admins_permissions'];
    protected bool $baselineDefaultLanguage = true;
    protected array $baselineTruncate = [
        'event_financial_entries',
        'event_treasuries',
        'event_settlement_settings',
        'reservation_payments',
        'ticket_reservations',
        'event_contents',
        'events',
        'identity_balances',
        'identities',
    ];

    public function test_settlement_queue_exposes_metrics_and_selected_event_detail(): void
    {
        $this->seedSettlementFixtures();

        $controller = app(EconomyController::class);
        $view = $controller->settlementShow(
            request()->create('/admin/event-booking/economy/settlements/801', 'GET', [
                'approval' => 'required',
            ]),
            801
        );

        $data = $view->getData();

        $this->assertSame(1, (int) data_get($data, 'summaryCards.total_events'));
        $this->assertSame(1, (int) data_get($data, 'summaryCards.needs_approval_count'));
        $this->assertSame('required', data_get($data, 'filters.approval'));
        $this->assertSame('Pending Approval Event', data_get($data, 'selectedSettlement.title'));
        $this->assertTrue((bool) data_get($data, 'selectedSettlement.snapshot.needs_admin_approval'));
        $this->assertSame(90.0, (float) data_get($data, 'selectedSettlement.snapshot.claimable_amount'));
        $this->assertSame(90.0, (float) data_get($data, 'summaryCards.claimable_total'));
        $this->assertSame(2, (int) data_get($data, 'selectedSettlement.detail.refund_operations.total_reservations'));
        $this->assertSame(1, (int) data_get($data, 'selectedSettlement.detail.refund_operations.refundable_reservations_count'));
        $this->assertSame(1, (int) data_get($data, 'selectedSettlement.detail.refund_operations.refunded_reservations_count'));
        $this->assertSame(50.0, (float) data_get($data, 'selectedSettlement.detail.refund_operations.refundable_gross'));
        $this->assertSame(40.0, (float) data_get($data, 'selectedSettlement.detail.refund_operations.refunded_gross'));
        $this->assertSame('Reservation Refund Processed', data_get($data, 'selectedSettlement.detail.refund_operations.hold_reason_label'));
        $this->assertSame('Operational incident', data_get($data, 'selectedSettlement.detail.refund_operations.latest_refund_decision.reason_label'));
        $this->assertSame('Finance Admin', data_get($data, 'selectedSettlement.detail.refund_operations.latest_refund_decision.admin_label'));
        $this->assertSame(['Treasury impact', 'Gateway/card refund'], data_get($data, 'selectedSettlement.detail.refund_operations.latest_refund_decision.risk_flag_labels'));
        $this->assertSame('Gateway mismatch after venue-side escalation.', data_get($data, 'selectedSettlement.detail.refund_operations.latest_refund_decision.admin_note'));
        $this->assertSame(100.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.gross_collected'));
        $this->assertSame(90.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.net_after_platform_fees'));
        $this->assertSame(90.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.owner_reserved_unreleased'));
        $this->assertSame(0.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.collaborator_claimable_amount'));
        $this->assertSame(0.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.unreleased_balance_delta'));
        $this->assertSame(0.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.releasable_now'));
        $this->assertSame(90.0, (float) data_get($data, 'selectedSettlement.detail.reconciliation.blocked_release_amount'));
        $this->assertSame('Admin approval required', data_get($data, 'selectedSettlement.detail.reconciliation.block_reason_label'));
        $this->assertSame(0.0, (float) data_get($data, 'selectedSettlement.detail.collaborator_reconciliation.reserved_for_collaborators'));
        $this->assertSame([], data_get($data, 'selectedSettlement.detail.collaborator_reconciliation.split_allocations'));
        $this->assertStringContainsString('event_id=801', (string) data_get($data, 'selectedSettlement.detail.refund_operations.refundable_queue_url'));
        $this->assertSame('Finance Admin', data_get($data, 'selectedSettlement.detail.settlement_actions.0.admin_label'));
        $this->assertSame('release', data_get($data, 'selectedSettlement.detail.settlement_actions.0.action_type'));
        $this->assertSame(90.0, (float) data_get($data, 'selectedSettlement.detail.settlement_actions.0.amount'));
        $this->assertSame('Settlement release approved', data_get($data, 'selectedSettlement.detail.recent_entries.1.entry_label'));
        $this->assertSame('Admin approved owner release for this treasury.', data_get($data, 'selectedSettlement.detail.recent_entries.1.entry_summary'));
    }

    public function test_settlement_queue_and_event_can_be_exported_as_csv(): void
    {
        $this->seedSettlementFixtures();

        $controller = app(EconomyController::class);

        $queueResponse = $controller->exportSettlements(
            request()->create('/admin/event-booking/economy/settlements/export', 'GET', [
                'approval' => 'required',
            ])
        );

        $this->assertInstanceOf(StreamedResponse::class, $queueResponse);
        $this->assertStringContainsString('text/csv', (string) $queueResponse->headers->get('Content-Type'));

        $queueCsv = $this->captureStreamedResponse($queueResponse);
        $this->assertStringContainsString('Pending Approval Event', $queueCsv);
        $this->assertStringContainsString('Claimable Amount', $queueCsv);
        $this->assertStringContainsString('Admin approval required', $queueCsv);
        $this->assertStringContainsString('Latest Refund Reason', $queueCsv);
        $this->assertStringContainsString('Operational incident', $queueCsv);
        $this->assertStringContainsString('Gateway mismatch after venue-side escalation.', $queueCsv);

        $eventResponse = $controller->exportSettlementEvent(
            request()->create('/admin/event-booking/economy/settlements/801/export', 'GET'),
            801
        );

        $this->assertInstanceOf(StreamedResponse::class, $eventResponse);
        $this->assertStringContainsString('text/csv', (string) $eventResponse->headers->get('Content-Type'));

        $eventCsv = $this->captureStreamedResponse($eventResponse);
        $this->assertStringContainsString('summary,event,"Pending Approval Event",801', $eventCsv);
        $this->assertStringContainsString('reconciliation,"Gross Collected",100', $eventCsv);
        $this->assertStringContainsString('collaborator_reconciliation,"Reserved For Collaborators",0', $eventCsv);
        $this->assertStringContainsString('refund_decision,"Reason Label","Operational incident"', $eventCsv);
        $this->assertStringContainsString('refund_decision,"Admin Note","Gateway mismatch after venue-side escalation."', $eventCsv);
        $this->assertStringContainsString('timeline,"Settlement release approved",0,Approved', $eventCsv);
    }

    private function seedSettlementFixtures(): void
    {
        DB::table('users')->insert([
            'id' => 1501,
            'username' => 'treasury-admin-review',
            'email' => 'treasury-admin-review@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'owner_user_id' => 1501,
            'display_name' => 'Treasury Organizer',
            'slug' => 'treasury-organizer',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 601,
            'email' => 'guest@example.com',
            'fname' => 'Guest',
            'lname' => 'Buyer',
            'username' => 'guest-buyer',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('admins')->insert([
            'id' => 41,
            'first_name' => 'Finance',
            'last_name' => 'Admin',
            'username' => 'finance-admin',
            'email' => 'finance-admin@example.com',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 801,
                'owner_identity_id' => 501,
                'status' => 1,
                'end_date_time' => now()->subDays(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 802,
                'owner_identity_id' => 501,
                'status' => 1,
                'end_date_time' => now()->subDays(9),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 801,
                'language_id' => 1,
                'title' => 'Pending Approval Event',
                'slug' => 'pending-approval-event',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 802,
                'language_id' => 1,
                'title' => 'Settled Event',
                'slug' => 'settled-event',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_settlement_settings')->insert([
            [
                'event_id' => 801,
                'hold_mode' => 'auto_after_grace_period',
                'grace_period_hours' => 24,
                'refund_window_hours' => 48,
                'auto_release_owner_share' => 0,
                'auto_release_collaborator_shares' => 0,
                'require_admin_approval' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 802,
                'hold_mode' => 'auto_after_grace_period',
                'grace_period_hours' => 24,
                'refund_window_hours' => 48,
                'auto_release_owner_share' => 0,
                'auto_release_collaborator_shares' => 0,
                'require_admin_approval' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_treasuries')->insert([
            [
                'event_id' => 801,
                'gross_collected' => 100,
                'refunded_amount' => 0,
                'platform_fee_total' => 10,
                'reserved_for_owner' => 90,
                'reserved_for_collaborators' => 0,
                'released_to_wallet' => 0,
                'available_for_settlement' => 90,
                'hold_until' => now()->subHours(1),
                'settlement_status' => EventTreasury::STATUS_SETTLEMENT_HOLD,
                'auto_payout_enabled' => 0,
                'auto_payout_delay_hours' => 24,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 802,
                'gross_collected' => 120,
                'refunded_amount' => 0,
                'platform_fee_total' => 12,
                'reserved_for_owner' => 108,
                'reserved_for_collaborators' => 0,
                'released_to_wallet' => 108,
                'available_for_settlement' => 108,
                'hold_until' => now()->subDays(3),
                'settlement_status' => EventTreasury::STATUS_SETTLED,
                'auto_payout_enabled' => 0,
                'auto_payout_delay_hours' => 24,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_reservations')->insert([
            [
                'id' => 901,
                'customer_id' => 601,
                'event_id' => 801,
                'ticket_id' => 77,
                'reservation_code' => 'RSV-REFUND-901',
                'quantity' => 1,
                'reserved_unit_price' => 50,
                'total_amount' => 50,
                'deposit_required' => 50,
                'amount_paid' => 50,
                'remaining_balance' => 0,
                'status' => 'cancelled',
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(1),
            ],
            [
                'id' => 902,
                'customer_id' => 601,
                'event_id' => 801,
                'ticket_id' => 77,
                'reservation_code' => 'RSV-REFUNDED-902',
                'quantity' => 1,
                'reserved_unit_price' => 40,
                'total_amount' => 40,
                'deposit_required' => 40,
                'amount_paid' => 40,
                'remaining_balance' => 0,
                'status' => 'defaulted',
                'created_at' => now()->subDays(3),
                'updated_at' => now()->subDays(2),
            ],
        ]);

        DB::table('reservation_payments')->insert([
            [
                'id' => 1001,
                'reservation_id' => 901,
                'payment_group' => 'grp_901_card',
                'source_type' => 'card',
                'amount' => 45,
                'fee_amount' => 5,
                'total_amount' => 50,
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => 'pi_901',
                'status' => 'completed',
                'paid_at' => now()->subDays(2),
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'id' => 1002,
                'reservation_id' => 902,
                'payment_group' => 'grp_902_wallet',
                'source_type' => 'wallet',
                'amount' => 40,
                'fee_amount' => 0,
                'total_amount' => 40,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wt_902',
                'status' => 'completed',
                'paid_at' => now()->subDays(3),
                'created_at' => now()->subDays(3),
                'updated_at' => now()->subDays(3),
            ],
            [
                'id' => 1003,
                'reservation_id' => 902,
                'payment_group' => 'refund_for_1002',
                'source_type' => 'wallet_refund',
                'amount' => -40,
                'fee_amount' => 0,
                'total_amount' => -40,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wt_902_refund',
                'status' => 'reversed',
                'paid_at' => now()->subDays(1),
                'created_at' => now()->subDays(1),
                'updated_at' => now()->subDays(1),
            ],
        ]);

        $treasuryId = (int) DB::table('event_treasuries')->where('event_id', 801)->value('id');

        DB::table('event_financial_entries')->insert([
            'treasury_id' => $treasuryId,
            'event_id' => 801,
            'idempotency_key' => 'settlement_hold_801',
            'entry_type' => EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED,
            'reference_type' => 'event',
            'reference_id' => '801',
            'gross_amount' => 0,
            'fee_amount' => 0,
            'net_amount' => 0,
            'currency' => 'DOP',
            'status' => 'hold',
            'metadata' => json_encode([
                'reason' => 'reservation_refund_processed',
                'hold_until' => now()->addHours(24)->toIso8601String(),
                'refund_reason_code' => 'operational_incident',
                'refund_reason_label' => 'Operational incident',
                'refund_admin_note' => 'Gateway mismatch after venue-side escalation.',
                'refund_risk_flags' => ['treasury_impact', 'gateway_refund'],
                'refund_risk_flag_labels' => ['Treasury impact', 'Gateway/card refund'],
                'processed_by_admin_id' => 41,
            ]),
            'occurred_at' => now()->subHours(5),
            'created_at' => now()->subHours(5),
            'updated_at' => now()->subHours(5),
        ]);

        DB::table('event_financial_entries')->insert([
            'treasury_id' => $treasuryId,
            'event_id' => 801,
            'idempotency_key' => 'settlement_approval_801',
            'entry_type' => EventFinancialEntry::TYPE_SETTLEMENT_RELEASE_APPROVED,
            'reference_type' => 'admin',
            'reference_id' => '41',
            'gross_amount' => 0,
            'fee_amount' => 0,
            'net_amount' => 0,
            'currency' => 'DOP',
            'status' => 'approved',
            'metadata' => json_encode([
                'approved_by_admin_id' => 41,
                'previous_status' => EventTreasury::STATUS_SETTLEMENT_HOLD,
            ]),
            'occurred_at' => now()->subHours(4),
            'created_at' => now()->subHours(4),
            'updated_at' => now()->subHours(4),
        ]);

        DB::table('event_financial_entries')->insert([
            'treasury_id' => $treasuryId,
            'event_id' => 801,
            'idempotency_key' => 'settlement_release_801',
            'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
            'reference_type' => 'identity_balance_transaction',
            'reference_id' => 'ibt_801',
            'owner_identity_id' => 501,
            'owner_identity_type' => 'organizer',
            'gross_amount' => 0,
            'fee_amount' => 0,
            'net_amount' => -90,
            'currency' => 'DOP',
            'status' => 'released',
            'metadata' => json_encode([
                'claimed_amount' => 90,
                'release_source' => 'admin_release',
                'approved_by_admin_id' => 41,
            ]),
            'occurred_at' => now()->subHours(2),
            'created_at' => now()->subHours(2),
            'updated_at' => now()->subHours(2),
        ]);
    }

    private function captureStreamedResponse(StreamedResponse $response): string
    {
        ob_start();
        $response->sendContent();
        return (string) ob_get_clean();
    }
}
