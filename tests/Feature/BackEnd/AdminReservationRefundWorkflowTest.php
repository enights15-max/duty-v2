<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Event\ReservationController;
use App\Models\Admin;
use App\Models\EventFinancialEntry;
use App\Models\EventTreasury;
use App\Models\Reservation\TicketReservation;
use App\Services\EventTreasuryService;
use App\Services\ReservationStatusNotificationService;
use App\Services\StripeService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class AdminReservationRefundWorkflowTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'wallets', 'bonus_wallets', 'reservations', 'booking_payment_allocations', 'admins_permissions', 'identities', 'legacy_identity_sources', 'economy', 'event_treasury'];
    protected bool $baselineDefaultLanguage = true;
    protected array $baselineTruncate = [
        'event_settlement_settings',
        'event_financial_entries',
        'event_treasuries',
        'ticket_reservation_action_logs',
        'reservation_payments',
        'ticket_reservations',
        'bonus_transactions',
        'bonus_wallets',
        'wallet_transactions',
        'wallets',
        'bookings',
        'event_contents',
        'tickets',
        'events',
        'identity_balances',
        'identities',
        'organizers',
        'customers',
        'users',
    ];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureReservationAdminSchema();
        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldIgnoreMissing();
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);
    }

    public function test_admin_can_partially_refund_cancelled_reservation_per_source(): void
    {
        $this->seedCustomer(1301);
        $eventId = $this->seedEvent(2301, 'Refund Queue Event');
        $ticketId = $this->seedTicket(3301, $eventId, 'Refundable Ticket', 10);
        $this->seedWallet(1301, 10.00);
        $this->seedBonusWallet(1301, 5.00);

        $this->seedReservation(4301, [
            'customer_id' => 1301,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUND-001',
            'status' => 'cancelled',
            'amount_paid' => 190.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            [
                'reservation_id' => 4301,
                'payment_group' => 'initial_a',
                'source_type' => 'bonus_wallet',
                'amount' => 30.00,
                'fee_amount' => 0.00,
                'total_amount' => 30.00,
                'reference_type' => 'bonus_transaction',
                'reference_id' => 'bonus_tx_original',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4301,
                'payment_group' => 'initial_a',
                'source_type' => 'wallet',
                'amount' => 60.00,
                'fee_amount' => 0.00,
                'total_amount' => 60.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_original',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4301,
                'payment_group' => 'initial_a',
                'source_type' => 'card',
                'amount' => 100.00,
                'fee_amount' => 8.00,
                'total_amount' => 108.00,
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => 'pi_refund_4301',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $stripeService = Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('refundPaymentIntent')
            ->once()
            ->with('pi_refund_4301', 54.00, Mockery::on(function (array $metadata) {
                return ($metadata['reservation_id'] ?? null) === '4301'
                    && ($metadata['reservation_payment_id'] ?? null) !== null;
            }))
            ->andReturn((object) ['id' => 're_4301_partial']);
        $this->app->instance(StripeService::class, $stripeService);

        $admin = new Admin();
        $admin->id = 9911;
        auth('admin')->setUser($admin);

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(
                Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 4301),
                'refund_processed',
                Mockery::on(fn (array $context) => (float) ($context['gross_amount'] ?? 0) === 89.0)
            );
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $request = Request::create('/admin/event-booking/reservations/4301/refund', 'POST', [
            'refund_bonus_wallet' => '10.00',
            'refund_wallet' => '25.00',
            'refund_card' => '54.00',
            'refund_reason_code' => 'operational_incident',
            'refund_admin_note' => 'Payment issue detected during post-event reconciliation.',
            'refund_risk_flags' => ['treasury_impact', 'gateway_refund'],
        ]);

        $controller = app(ReservationController::class);
        $response = $controller->refund($request, 4301);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertEquals(35.00, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 1301)->value('balance'));
        $this->assertEquals(15.00, (float) DB::table('bonus_wallets')->where('actor_type', 'customer')->where('actor_id', 1301)->value('balance'));

        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4301,
            'source_type' => 'bonus_wallet_refund',
            'payment_group' => 'refund_for_1',
            'total_amount' => -10.00,
            'status' => 'reversed',
        ]);
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4301,
            'source_type' => 'wallet_refund',
            'payment_group' => 'refund_for_2',
            'total_amount' => -25.00,
            'status' => 'reversed',
        ]);
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4301,
            'source_type' => 'card_refund',
            'payment_group' => 'refund_for_3',
            'reference_type' => 'stripe_refund',
            'reference_id' => 're_4301_partial',
            'amount' => -50.00,
            'fee_amount' => -4.00,
            'total_amount' => -54.00,
            'status' => 'reversed',
        ]);
        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 4301,
            'actor_type' => 'admin',
            'actor_id' => 9911,
            'action' => 'refund_processed',
        ]);
        $actionLog = DB::table('ticket_reservation_action_logs')
            ->where('reservation_id', 4301)
            ->where('action', 'refund_processed')
            ->latest('id')
            ->first();
        $actionMeta = json_decode((string) $actionLog->meta, true);
        $this->assertSame('operational_incident', $actionMeta['refund_reason_code'] ?? null);
        $this->assertSame('Operational incident', $actionMeta['refund_reason_label'] ?? null);
        $this->assertSame('Payment issue detected during post-event reconciliation.', $actionMeta['refund_admin_note'] ?? null);
        $this->assertSame(['treasury_impact', 'gateway_refund'], $actionMeta['refund_risk_flags'] ?? []);
    }

    public function test_admin_can_still_process_full_refund_when_no_source_amounts_are_provided(): void
    {
        $this->seedCustomer(1303);
        $eventId = $this->seedEvent(2303, 'Refund Full Fallback');
        $ticketId = $this->seedTicket(3303, $eventId, 'Refundable Ticket', 10);
        $this->seedWallet(1303, 10.00);
        $this->seedBonusWallet(1303, 5.00);

        $this->seedReservation(4303, [
            'customer_id' => 1303,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUND-003',
            'status' => 'cancelled',
            'amount_paid' => 98.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            [
                'reservation_id' => 4303,
                'payment_group' => 'initial_c',
                'source_type' => 'wallet',
                'amount' => 40.00,
                'fee_amount' => 0.00,
                'total_amount' => 40.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_original_full',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4303,
                'payment_group' => 'initial_c',
                'source_type' => 'card',
                'amount' => 54.00,
                'fee_amount' => 4.00,
                'total_amount' => 58.00,
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => 'pi_refund_4303',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $stripeService = Mockery::mock(StripeService::class);
        $stripeService->shouldReceive('refundPaymentIntent')
            ->once()
            ->with('pi_refund_4303', 58.00, Mockery::type('array'))
            ->andReturn((object) ['id' => 're_4303']);
        $this->app->instance(StripeService::class, $stripeService);

        $admin = new Admin();
        $admin->id = 9913;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4303/refund', 'POST', [
            'refund_reason_code' => 'event_cancelled',
            'refund_admin_note' => 'Full balance returned after cancellation.',
            'refund_risk_flags' => ['gateway_refund'],
        ]);

        $controller = app(ReservationController::class);
        $response = $controller->refund($request, 4303);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertEquals(50.00, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 1303)->value('balance'));
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4303,
            'source_type' => 'wallet_refund',
            'total_amount' => -40.00,
            'status' => 'reversed',
        ]);
        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4303,
            'source_type' => 'card_refund',
            'reference_id' => 're_4303',
            'total_amount' => -58.00,
            'status' => 'reversed',
        ]);
    }

    public function test_admin_refund_reduces_professional_event_treasury(): void
    {
        $this->seedOrganizerContext();
        $this->seedCustomer(1310);
        $eventId = $this->seedEvent(2310, 'Treasury Refund Event', 501);
        $ticketId = $this->seedTicket(3310, $eventId, 'Treasury Ticket', 10);
        $this->seedWallet(1310, 0.00);

        $this->seedReservation(4310, [
            'customer_id' => 1310,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-TREASURY-4310',
            'status' => 'cancelled',
            'amount_paid' => 60.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            'id' => 9310,
            'reservation_id' => 4310,
            'payment_group' => 'initial_treasury',
            'source_type' => 'wallet',
            'amount' => 60.00,
            'fee_amount' => 0.00,
            'total_amount' => 60.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_treasury_4310',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $reservation = TicketReservation::query()->with(['event', 'payments'])->findOrFail(4310);
        app(EventTreasuryService::class)->syncReservationRevenue($reservation);

        $admin = new Admin();
        $admin->id = 9920;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4310/refund', 'POST', [
            'refund_wallet' => '25.00',
            'refund_reason_code' => 'dispute_resolution',
            'refund_admin_note' => 'Approved partial refund after manual dispute review.',
            'refund_risk_flags' => ['treasury_impact', 'customer_escalation', 'manual_exception'],
        ]);

        $response = app(ReservationController::class)->refund($request, 4310);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());

        $treasury = EventTreasury::query()->where('event_id', $eventId)->first();
        $this->assertNotNull($treasury);
        $this->assertSame(60.0, (float) $treasury->gross_collected);
        $this->assertSame(25.0, (float) $treasury->refunded_amount);
        $this->assertSame(35.0, (float) $treasury->reserved_for_owner);
        $this->assertSame(35.0, (float) $treasury->available_for_settlement);
        $this->assertSame('settlement_hold', $treasury->settlement_status);

        $this->assertDatabaseHas('reservation_payments', [
            'reservation_id' => 4310,
            'source_type' => 'wallet_refund',
            'total_amount' => -25.00,
            'status' => 'reversed',
        ]);

        $this->assertSame(1, EventFinancialEntry::query()
            ->where('event_id', $eventId)
            ->where('entry_type', EventFinancialEntry::TYPE_RESERVATION_REFUND_PROCESSED)
            ->count());

        $holdEntry = EventFinancialEntry::query()
            ->where('event_id', $eventId)
            ->where('entry_type', EventFinancialEntry::TYPE_SETTLEMENT_HOLD_OPENED)
            ->latest('id')
            ->first();
        $this->assertNotNull($holdEntry);
        $this->assertSame('dispute_resolution', data_get($holdEntry->metadata, 'refund_reason_code'));
        $this->assertSame('Approved partial refund after manual dispute review.', data_get($holdEntry->metadata, 'refund_admin_note'));
        $this->assertSame(['treasury_impact', 'customer_escalation', 'manual_exception'], data_get($holdEntry->metadata, 'refund_risk_flags', []));
    }

    public function test_admin_cannot_request_refund_above_source_balance(): void
    {
        $this->seedCustomer(1304);
        $eventId = $this->seedEvent(2304, 'Refund Source Guard');
        $ticketId = $this->seedTicket(3304, $eventId, 'Refundable Ticket', 10);
        $this->seedWallet(1304, 0.00);

        $this->seedReservation(4304, [
            'customer_id' => 1304,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUND-004',
            'status' => 'cancelled',
            'amount_paid' => 20.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 4304,
            'payment_group' => 'initial_d',
            'source_type' => 'wallet',
            'amount' => 20.00,
            'fee_amount' => 0.00,
            'total_amount' => 20.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_source_guard',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $admin = new Admin();
        $admin->id = 9914;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4304/refund', 'POST', [
            'refund_wallet' => '25.00',
            'refund_reason_code' => 'goodwill_exception',
            'refund_admin_note' => 'Requested amount exceeded available refundable balance.',
        ]);

        $controller = app(ReservationController::class);
        $response = $controller->refund($request, 4304);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertDatabaseCount('reservation_payments', 1);
        $this->assertEquals(0.00, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 1304)->value('balance'));
    }

    public function test_admin_cannot_refund_active_reservation(): void
    {
        $this->seedCustomer(1302);
        $eventId = $this->seedEvent(2302, 'Active Refund Guard');
        $ticketId = $this->seedTicket(3302, $eventId, 'Guard Ticket', 8);

        $this->seedReservation(4302, [
            'customer_id' => 1302,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUND-GUARD',
            'status' => 'active',
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 4302,
            'payment_group' => 'initial_b',
            'source_type' => 'wallet',
            'amount' => 20.00,
            'fee_amount' => 0.00,
            'total_amount' => 20.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_guard',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $admin = new Admin();
        $admin->id = 9912;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4302/refund', 'POST', [
            'refund_reason_code' => 'operational_incident',
            'refund_admin_note' => 'Guard case should not refund active reservations.',
        ]);

        $controller = app(ReservationController::class);
        $response = $controller->refund($request, 4302);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertDatabaseCount('reservation_payments', 1);
    }

    public function test_admin_refund_requires_gateway_risk_flag_when_card_source_is_refunded(): void
    {
        $this->seedCustomer(1311);
        $eventId = $this->seedEvent(2311, 'Gateway Flag Guard');
        $ticketId = $this->seedTicket(3311, $eventId, 'Gateway Guard Ticket', 6);

        $this->seedReservation(4311, [
            'customer_id' => 1311,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-GATEWAY-FLAG',
            'status' => 'cancelled',
            'amount_paid' => 108.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 4311,
            'payment_group' => 'initial_gateway_guard',
            'source_type' => 'card',
            'amount' => 100.00,
            'fee_amount' => 8.00,
            'total_amount' => 108.00,
            'reference_type' => 'stripe_payment_intent',
            'reference_id' => 'pi_gateway_guard',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $stripeService = Mockery::mock(StripeService::class);
        $stripeService->shouldNotReceive('refundPaymentIntent');
        $this->app->instance(StripeService::class, $stripeService);

        $admin = new Admin();
        $admin->id = 9921;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4311/refund', 'POST', [
            'refund_card' => '54.00',
            'refund_reason_code' => 'operational_incident',
            'refund_admin_note' => 'Card refund requested without the required gateway risk flag.',
        ]);

        $response = app(ReservationController::class)->refund($request, 4311);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertDatabaseCount('reservation_payments', 1);
        $this->assertDatabaseMissing('ticket_reservation_action_logs', [
            'reservation_id' => 4311,
            'action' => 'refund_processed',
        ]);
    }

    public function test_admin_refund_requires_high_value_flag_for_large_refunds(): void
    {
        $this->seedCustomer(1312);
        $eventId = $this->seedEvent(2312, 'High Value Guard');
        $ticketId = $this->seedTicket(3312, $eventId, 'High Value Ticket', 4);
        $this->seedWallet(1312, 0.00);

        $this->seedReservation(4312, [
            'customer_id' => 1312,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-HIGH-VALUE',
            'status' => 'cancelled',
            'amount_paid' => 6000.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 4312,
            'payment_group' => 'initial_high_value_guard',
            'source_type' => 'wallet',
            'amount' => 6000.00,
            'fee_amount' => 0.00,
            'total_amount' => 6000.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_high_value_guard',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $admin = new Admin();
        $admin->id = 9922;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4312/refund', 'POST', [
            'refund_wallet' => '6000.00',
            'refund_reason_code' => 'event_cancelled',
            'refund_admin_note' => 'Large event cancellation refund missing the high value flag for governance testing.',
        ]);

        $response = app(ReservationController::class)->refund($request, 4312);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertDatabaseCount('reservation_payments', 1);
        $this->assertEquals(0.00, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 1312)->value('balance'));
    }

    public function test_admin_goodwill_refund_requires_manual_exception_flag(): void
    {
        $this->seedCustomer(1313);
        $eventId = $this->seedEvent(2313, 'Goodwill Guard');
        $ticketId = $this->seedTicket(3313, $eventId, 'Goodwill Ticket', 5);
        $this->seedWallet(1313, 0.00);

        $this->seedReservation(4313, [
            'customer_id' => 1313,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-GOODWILL-GUARD',
            'status' => 'cancelled',
            'amount_paid' => 120.00,
            'remaining_balance' => 0.00,
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 4313,
            'payment_group' => 'initial_goodwill_guard',
            'source_type' => 'wallet',
            'amount' => 120.00,
            'fee_amount' => 0.00,
            'total_amount' => 120.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_goodwill_guard',
            'status' => 'completed',
            'paid_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $admin = new Admin();
        $admin->id = 9923;
        auth('admin')->setUser($admin);

        $request = Request::create('/admin/event-booking/reservations/4313/refund', 'POST', [
            'refund_wallet' => '25.00',
            'refund_reason_code' => 'goodwill_exception',
            'refund_admin_note' => 'Customer retention exception after goodwill review and account history analysis.',
        ]);

        $response = app(ReservationController::class)->refund($request, 4313);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertDatabaseCount('reservation_payments', 1);
        $this->assertEquals(0.00, (float) DB::table('wallets')->where('actor_type', 'customer')->where('actor_id', 1313)->value('balance'));
    }

    private function ensureReservationAdminSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'owner_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('owner_identity_id')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'venue_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('venue_identity_id')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'thumbnail')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('thumbnail')->nullable();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'end_date_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('end_date_time')->nullable();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->default('limited');
                $table->integer('ticket_available')->default(0);
                $table->string('pricing_type')->default('normal');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reservation_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_reservation_action_logs')) {
            Schema::create('ticket_reservation_action_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('reservation_id');
                $table->string('actor_type', 32)->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('action', 64);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id): void
    {
        DB::table('customers')->insert([
            'id' => $id,
            'email' => "refund-admin-{$id}@example.com",
            'fname' => 'Refund',
            'lname' => 'Customer',
            'phone' => '8090000000',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Av. Refund',
            'password' => bcrypt('secret'),
            'stripe_customer_id' => 'cus_' . $id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedWallet(int $customerId, float $balance): void
    {
        DB::table('wallets')->insert([
            'id' => 'wallet-' . $customerId . '-0000-4000-8000-000000000001',
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

    private function seedBonusWallet(int $customerId, float $balance): void
    {
        DB::table('bonus_wallets')->insert([
            'id' => 'bonus-' . $customerId . '-0000-4000-8000-000000000001',
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

    private function seedEvent(int $id, string $title, ?int $ownerIdentityId = null): int
    {
        DB::table('events')->insert([
            'id' => $id,
            'organizer_id' => null,
            'owner_identity_id' => $ownerIdentityId,
            'venue_identity_id' => null,
            'thumbnail' => 'demo-event.jpg',
            'end_date_time' => now()->addMonth(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $languageId = (int) DB::table('languages')->where('is_default', 1)->value('id');

        DB::table('event_contents')->insert([
            'event_id' => $id,
            'language_id' => $languageId,
            'title' => $title,
            'slug' => strtolower(str_replace(' ', '-', $title)),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedTicket(int $id, int $eventId, string $title, int $available): int
    {
        DB::table('tickets')->insert([
            'id' => $id,
            'event_id' => $eventId,
            'title' => $title,
            'ticket_available_type' => 'limited',
            'ticket_available' => $available,
            'pricing_type' => 'normal',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedReservation(int $id, array $overrides): void
    {
        $now = now();

        DB::table('ticket_reservations')->insert(array_merge([
            'id' => $id,
            'customer_id' => 1301,
            'event_id' => 2301,
            'ticket_id' => 3301,
            'reservation_code' => 'RSV-SEED-' . $id,
            'booking_order_number' => null,
            'quantity' => 1,
            'reserved_unit_price' => 300,
            'total_amount' => 300,
            'deposit_required' => 60,
            'amount_paid' => 60,
            'remaining_balance' => 240,
            'deposit_type' => 'percentage',
            'deposit_value' => 20,
            'minimum_installment_amount' => 50,
            'final_due_date' => $now->copy()->addWeek(),
            'expires_at' => $now->copy()->addDays(3),
            'event_date' => $now->copy()->addMonth()->format('Y-m-d H:i:s'),
            'status' => 'active',
            'payment_method' => 'mixed',
            'fname' => 'Refund',
            'lname' => 'Customer',
            'email' => 'refund@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'state' => 'Distrito Nacional',
            'city' => 'Santo Domingo',
            'zip_code' => '10100',
            'address' => 'Av. Refund',
            'created_at' => $now,
            'updated_at' => $now,
        ], $overrides));
    }

    private function seedOrganizerContext(): void
    {
        DB::table('users')->insert([
            'id' => 1901,
            'email' => 'admin-refund-organizer@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 91,
            'username' => 'admin-refund-organizer',
            'email' => 'admin-refund-organizer@example.com',
            'amount' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1901,
            'display_name' => 'Admin Refund Organizer',
            'slug' => 'admin-refund-organizer',
            'meta' => json_encode(['legacy_id' => 91]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 91,
            'balance' => 0,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
