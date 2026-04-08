<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Event\ReservationController;
use App\Models\Admin;
use App\Models\Reservation\TicketReservation;
use App\Services\ReservationStatusNotificationService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class AdminReservationManagementControllerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'reservations', 'booking_payment_allocations', 'admins_permissions'];
    protected bool $baselineDefaultLanguage = true;
    protected array $baselineTruncate = [
        'ticket_reservation_action_logs',
        'ticket_reservations',
        'reservation_payments',
        'bookings',
        'event_contents',
        'tickets',
        'events',
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

    public function test_index_defaults_to_active_reservations(): void
    {
        $this->seedCustomer(1201);
        $eventId = $this->seedEvent(2201, 'Reservation Queue Event');
        $ticketId = $this->seedTicket(3201, $eventId, 'Queue Ticket', 12);

        $this->seedReservation(4201, [
            'customer_id' => 1201,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-ACTIVE-001',
            'status' => 'active',
        ]);

        $this->seedReservation(4202, [
            'customer_id' => 1201,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-COMP-001',
            'status' => 'completed',
            'amount_paid' => 200,
            'remaining_balance' => 0,
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET'));
        $data = $view->getData();

        $this->assertSame('active', $data['status']);
        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-ACTIVE-001', optional($data['reservations']->first())->reservation_code);
        $this->assertSame(2, $data['metrics']['total']);
        $this->assertSame(1, $data['metrics']['completed']);
    }

    public function test_index_exposes_refund_financial_snapshots_for_listing(): void
    {
        $this->seedCustomer(1204);
        $eventId = $this->seedEvent(2204, 'Reservation Refund Summary Event');
        $ticketId = $this->seedTicket(3204, $eventId, 'Summary Ticket', 7);

        $this->seedReservation(4205, [
            'customer_id' => 1204,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-SUMMARY-001',
            'status' => 'cancelled',
            'amount_paid' => 80,
            'remaining_balance' => 20,
        ]);

        DB::table('reservation_payments')->insert([
            [
                'reservation_id' => 4205,
                'payment_group' => 'initial_summary',
                'source_type' => 'wallet',
                'amount' => 40.00,
                'fee_amount' => 0.00,
                'total_amount' => 40.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_summary',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4205,
                'payment_group' => 'initial_summary',
                'source_type' => 'card',
                'amount' => 40.00,
                'fee_amount' => 4.00,
                'total_amount' => 44.00,
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => 'pi_summary',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4205,
                'payment_group' => 'refund_for_2',
                'source_type' => 'card_refund',
                'amount' => -20.00,
                'fee_amount' => -2.00,
                'total_amount' => -22.00,
                'reference_type' => 'stripe_refund',
                'reference_id' => 're_summary',
                'status' => 'reversed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'cancelled',
        ]));
        $data = $view->getData();
        $reservation = $data['reservations']->first();

        $this->assertSame('RSV-SUMMARY-001', optional($reservation)->reservation_code);
        $this->assertSame(22.00, (float) ($reservation->refund_financials['refunded_gross'] ?? 0));
        $this->assertSame(62.00, (float) ($reservation->refund_refundable_summary['gross_amount'] ?? 0));
    }

    public function test_admin_can_cancel_active_reservation_and_release_inventory(): void
    {
        $this->seedCustomer(1202);
        $eventId = $this->seedEvent(2202, 'Cancel Reservation Event');
        $ticketId = $this->seedTicket(3202, $eventId, 'Cancelable Ticket', 5);

        $this->seedReservation(4203, [
            'customer_id' => 1202,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-CANCEL-001',
            'quantity' => 2,
            'status' => 'active',
        ]);

        $admin = new Admin();
        $admin->id = 9901;
        auth('admin')->setUser($admin);

        $notificationService = Mockery::mock(ReservationStatusNotificationService::class);
        $notificationService->shouldReceive('notifyCustomer')
            ->once()
            ->with(
                Mockery::on(fn ($reservation) => $reservation instanceof TicketReservation && (int) $reservation->id === 4203),
                'cancelled',
                Mockery::type('array')
            );
        $this->app->instance(ReservationStatusNotificationService::class, $notificationService);

        $controller = app(ReservationController::class);
        $response = $controller->cancel(4203);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertSame('cancelled', DB::table('ticket_reservations')->where('id', 4203)->value('status'));
        $this->assertSame(7, (int) DB::table('tickets')->where('id', $ticketId)->value('ticket_available'));
        $this->assertDatabaseHas('ticket_reservation_action_logs', [
            'reservation_id' => 4203,
            'actor_type' => 'admin',
            'actor_id' => 9901,
            'action' => 'cancelled',
        ]);
    }

    public function test_admin_can_reactivate_expired_reservation_and_consume_inventory(): void
    {
        $this->seedCustomer(1203);
        $eventId = $this->seedEvent(2203, 'Reactivate Reservation Event');
        $ticketId = $this->seedTicket(3203, $eventId, 'Reactivate Ticket', 9);

        $this->seedReservation(4204, [
            'customer_id' => 1203,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REACT-001',
            'quantity' => 3,
            'status' => 'expired',
            'amount_paid' => 50,
            'remaining_balance' => 250,
            'expires_at' => now()->subDay(),
        ]);

        $admin = new Admin();
        $admin->id = 9902;
        auth('admin')->setUser($admin);

        $controller = app(ReservationController::class);
        $response = $controller->reactivate(
            Request::create('/admin/event-booking/reservations/4204/reactivate', 'POST', [
                'expires_at' => now()->addDays(5)->format('Y-m-d H:i:s'),
                'final_due_date' => now()->addDays(10)->format('Y-m-d H:i:s'),
            ]),
            4204
        );

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());
        $this->assertSame('active', DB::table('ticket_reservations')->where('id', 4204)->value('status'));
        $this->assertSame(6, (int) DB::table('tickets')->where('id', $ticketId)->value('ticket_available'));
        $this->assertNotNull(DB::table('ticket_reservations')->where('id', 4204)->value('expires_at'));
    }

    public function test_index_can_filter_refundable_reservations_and_export_csv(): void
    {
        $this->seedCustomer(1205);
        $eventId = $this->seedEvent(2205, 'Refund Filter Event');
        $ticketId = $this->seedTicket(3205, $eventId, 'Refund Filter Ticket', 10);

        $this->seedReservation(4206, [
            'customer_id' => 1205,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUNDABLE-001',
            'status' => 'cancelled',
            'amount_paid' => 100,
            'remaining_balance' => 0,
        ]);

        $this->seedReservation(4207, [
            'customer_id' => 1205,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-REFUNDED-001',
            'status' => 'defaulted',
            'amount_paid' => 100,
            'remaining_balance' => 0,
        ]);

        DB::table('reservation_payments')->insert([
            [
                'reservation_id' => 4206,
                'payment_group' => 'initial_filter_a',
                'source_type' => 'wallet',
                'amount' => 100.00,
                'fee_amount' => 0.00,
                'total_amount' => 100.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_filter_a',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4207,
                'payment_group' => 'initial_filter_b',
                'source_type' => 'wallet',
                'amount' => 100.00,
                'fee_amount' => 0.00,
                'total_amount' => 100.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_tx_filter_b',
                'status' => 'completed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4207,
                'payment_group' => 'refund_for_filter_b',
                'source_type' => 'wallet_refund',
                'amount' => -100.00,
                'fee_amount' => 0.00,
                'total_amount' => -100.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wallet_refund_filter_b',
                'status' => 'reversed',
                'paid_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'all',
            'refund_state' => 'refundable',
        ]));
        $data = $view->getData();

        $this->assertSame('refundable', $data['refundState']);
        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-REFUNDABLE-001', optional($data['reservations']->first())->reservation_code);

        $response = $controller->export(Request::create('/admin/event-booking/reservations/export', 'GET', [
            'status' => 'all',
            'refund_state' => 'refundable',
        ]));

        ob_start();
        $response->sendContent();
        $csv = ob_get_clean();

        $this->assertStringContainsString('RSV-REFUNDABLE-001', $csv);
        $this->assertStringNotContainsString('RSV-REFUNDED-001', $csv);
    }

    public function test_index_can_filter_reservations_due_soon(): void
    {
        $this->seedCustomer(1206);
        $eventId = $this->seedEvent(2206, 'Due Soon Event');
        $ticketId = $this->seedTicket(3206, $eventId, 'Due Soon Ticket', 6);

        $this->seedReservation(4208, [
            'customer_id' => 1206,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-DUE-2H',
            'status' => 'active',
            'amount_paid' => 10,
            'remaining_balance' => 90,
            'expires_at' => now()->addMinutes(90),
        ]);

        $this->seedReservation(4209, [
            'customer_id' => 1206,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-DUE-24H',
            'status' => 'active',
            'amount_paid' => 20,
            'remaining_balance' => 80,
            'expires_at' => now()->addHours(12),
        ]);

        $this->seedReservation(4210, [
            'customer_id' => 1206,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-NOT-DUE',
            'status' => 'active',
            'amount_paid' => 20,
            'remaining_balance' => 80,
            'expires_at' => now()->addDays(3),
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'all',
            'due_state' => 'due_2h',
        ]));
        $data = $view->getData();

        $this->assertSame('due_2h', $data['dueState']);
        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-DUE-2H', optional($data['reservations']->first())->reservation_code);
        $this->assertSame(2, (int) $data['metrics']['due_24h']);
        $this->assertSame(1, (int) $data['metrics']['due_2h']);
    }

    public function test_index_and_export_can_filter_by_refund_decision_reason_and_risk_flag(): void
    {
        $this->seedCustomer(1207);
        $eventId = $this->seedEvent(2207, 'Refund Decision Filter Event');
        $ticketId = $this->seedTicket(3207, $eventId, 'Refund Decision Ticket', 8);

        DB::table('admins')->insert([
            [
                'id' => 9001,
                'first_name' => 'Ops',
                'last_name' => 'Admin',
                'username' => 'ops-admin',
                'email' => 'ops-admin@example.com',
                'status' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9002,
                'first_name' => 'Support',
                'last_name' => 'Lead',
                'username' => 'support-lead',
                'email' => 'support-lead@example.com',
                'status' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $this->seedReservation(4211, [
            'customer_id' => 1207,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-DECISION-OPS',
            'status' => 'cancelled',
            'amount_paid' => 120,
            'remaining_balance' => 0,
        ]);

        $this->seedReservation(4212, [
            'customer_id' => 1207,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-DECISION-GOODWILL',
            'status' => 'defaulted',
            'amount_paid' => 120,
            'remaining_balance' => 0,
        ]);

        DB::table('ticket_reservation_action_logs')->insert([
            [
                'reservation_id' => 4211,
                'actor_type' => 'admin',
                'actor_id' => 9001,
                'action' => 'refund_processed',
                'meta' => json_encode([
                    'refund_reason_code' => 'operational_incident',
                    'refund_risk_flags' => ['gateway_refund', 'treasury_impact'],
                ], JSON_THROW_ON_ERROR),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'reservation_id' => 4212,
                'actor_type' => 'admin',
                'actor_id' => 9002,
                'action' => 'refund_processed',
                'meta' => json_encode([
                    'refund_reason_code' => 'goodwill_exception',
                    'refund_risk_flags' => ['customer_escalation'],
                ], JSON_THROW_ON_ERROR),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'all',
            'refund_reason_code' => 'operational_incident',
            'refund_risk_flag' => 'gateway_refund',
        ]));
        $data = $view->getData();

        $this->assertSame('operational_incident', $data['refundReasonCode']);
        $this->assertSame('gateway_refund', $data['refundRiskFlag']);
        $this->assertArrayHasKey('operational_incident', $data['refundReasonOptions']);
        $this->assertArrayHasKey('gateway_refund', $data['refundRiskFlagOptions']);
        $this->assertSame(1, $data['reservations']->total());
        $this->assertSame('RSV-DECISION-OPS', optional($data['reservations']->first())->reservation_code);
        $this->assertTrue((bool) data_get($data, 'decisionInsights.supported'));
        $this->assertSame(1, (int) data_get($data, 'decisionInsights.total_refund_decisions'));
        $this->assertSame(1, (int) data_get($data, 'decisionInsights.gateway_refund_count'));
        $this->assertSame(1, (int) data_get($data, 'decisionInsights.treasury_impact_count'));
        $this->assertSame('Operational incident', data_get($data, 'decisionInsights.top_reasons.0.label'));
        $this->assertSame('Gateway/card refund', data_get($data, 'decisionInsights.top_risk_flags.0.label'));
        $this->assertSame('Ops Admin', data_get($data, 'decisionInsights.top_admins.0.label'));

        $response = $controller->export(Request::create('/admin/event-booking/reservations/export', 'GET', [
            'status' => 'all',
            'refund_reason_code' => 'operational_incident',
            'refund_risk_flag' => 'gateway_refund',
        ]));

        ob_start();
        $response->sendContent();
        $csv = ob_get_clean();

        $this->assertStringContainsString('RSV-DECISION-OPS', $csv);
        $this->assertStringNotContainsString('RSV-DECISION-GOODWILL', $csv);
        $this->assertStringContainsString('Latest Refund Reason', $csv);
        $this->assertStringContainsString('Operational incident', $csv);
        $this->assertStringContainsString('Gateway/card refund; Treasury impact', $csv);
    }

    public function test_decision_insights_can_be_scoped_by_period(): void
    {
        $this->seedCustomer(1208);
        $eventId = $this->seedEvent(2208, 'Refund Decision Period Event');
        $ticketId = $this->seedTicket(3208, $eventId, 'Refund Period Ticket', 8);

        DB::table('admins')->insert([
            'id' => 9003,
            'first_name' => 'Finance',
            'last_name' => 'Ops',
            'username' => 'finance-ops',
            'email' => 'finance-ops@example.com',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->seedReservation(4213, [
            'customer_id' => 1208,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-PERIOD-NEW',
            'status' => 'cancelled',
            'amount_paid' => 140,
            'remaining_balance' => 0,
        ]);

        $this->seedReservation(4214, [
            'customer_id' => 1208,
            'event_id' => $eventId,
            'ticket_id' => $ticketId,
            'reservation_code' => 'RSV-PERIOD-OLD',
            'status' => 'cancelled',
            'amount_paid' => 240,
            'remaining_balance' => 0,
        ]);

        DB::table('ticket_reservation_action_logs')->insert([
            [
                'reservation_id' => 4213,
                'actor_type' => 'admin',
                'actor_id' => 9003,
                'action' => 'refund_processed',
                'meta' => json_encode([
                    'gross_amount' => 140.00,
                    'refund_reason_code' => 'event_cancelled',
                    'refund_risk_flags' => ['treasury_impact'],
                ], JSON_THROW_ON_ERROR),
                'created_at' => now()->subDays(5),
                'updated_at' => now()->subDays(5),
            ],
            [
                'reservation_id' => 4214,
                'actor_type' => 'admin',
                'actor_id' => 9003,
                'action' => 'refund_processed',
                'meta' => json_encode([
                    'gross_amount' => 240.00,
                    'refund_reason_code' => 'goodwill_exception',
                    'refund_risk_flags' => ['treasury_impact', 'manual_exception'],
                ], JSON_THROW_ON_ERROR),
                'created_at' => now()->subDays(45),
                'updated_at' => now()->subDays(45),
            ],
        ]);

        $controller = app(ReservationController::class);
        $view = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'all',
            'decision_period' => '30d',
        ]));
        $data = $view->getData();

        $this->assertSame('30d', $data['decisionPeriod']);
        $this->assertSame('Last 30 days', data_get($data, 'decisionInsights.selected_period_label'));
        $this->assertSame(1, (int) data_get($data, 'decisionInsights.total_refund_decisions'));
        $this->assertSame(140.0, (float) data_get($data, 'decisionInsights.total_refunded_gross'));
        $this->assertSame(1, (int) data_get($data, 'decisionInsights.treasury_impact_count'));
        $this->assertSame(140.0, (float) data_get($data, 'decisionInsights.treasury_impact_gross'));
        $this->assertSame('Event cancelled', data_get($data, 'decisionInsights.top_reasons.0.label'));

        $allTimeView = $controller->index(Request::create('/admin/event-booking/reservations', 'GET', [
            'status' => 'all',
            'decision_period' => 'all',
        ]));
        $allTimeData = $allTimeView->getData();

        $this->assertSame(2, (int) data_get($allTimeData, 'decisionInsights.total_refund_decisions'));
        $this->assertSame(380.0, (float) data_get($allTimeData, 'decisionInsights.total_refunded_gross'));
    }

    private function ensureReservationAdminSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
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
            'email' => "admin-reservation-{$id}@example.com",
            'fname' => 'Reservation',
            'lname' => 'Customer',
            'phone' => '8090000000',
            'country' => 'DO',
            'city' => 'Santo Domingo',
            'address' => 'Av. Admin',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedEvent(int $id, string $title): int
    {
        DB::table('events')->insert([
            'id' => $id,
            'organizer_id' => null,
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
            'customer_id' => 1201,
            'event_id' => 2201,
            'ticket_id' => 3201,
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
            'fname' => 'Reservation',
            'lname' => 'Customer',
            'email' => 'reservation@example.com',
            'phone' => '8090000000',
            'country' => 'DO',
            'state' => 'Distrito Nacional',
            'city' => 'Santo Domingo',
            'zip_code' => '10101',
            'address' => 'Av. Admin',
            'created_at' => $now,
            'updated_at' => $now,
        ], $overrides));
    }
}
