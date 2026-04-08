<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\EconomyController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class AdminEconomyDashboardGatewayAnalyticsTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'legacy_identity_sources', 'discovery_catalog', 'economy', 'marketplace', 'booking_payment_allocations', 'reservations', 'event_treasury'];
    protected bool $baselineDefaultLanguage = true;
    protected array $baselineTruncate = [
        'platform_revenue_events',
        'booking_payment_allocations',
        'reservation_payments',
        'ticket_reservations',
        'bookings',
        'event_contents',
        'events',
    ];

    public function test_dashboard_exposes_gateway_telemetry_and_respects_event_scope(): void
    {
        DB::table('events')->insert([
            [
                'id' => 901,
                'end_date_time' => now()->addDays(10),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 902,
                'end_date_time' => now()->addDays(10),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 901,
                'language_id' => 1,
                'title' => 'Gateway Event A',
                'slug' => 'gateway-event-a',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 902,
                'language_id' => 1,
                'title' => 'Gateway Event B',
                'slug' => 'gateway-event-b',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('ticket_reservations')->insert([
            'id' => 7001,
            'customer_id' => 1,
            'event_id' => 901,
            'ticket_id' => 1,
            'reservation_code' => 'RSV-GATEWAY-901',
            'reserved_unit_price' => 25.00,
            'total_amount' => 25.00,
            'amount_paid' => 25.00,
            'remaining_balance' => 0.00,
            'status' => 'completed',
            'created_at' => now()->subDays(2),
            'updated_at' => now()->subDays(2),
        ]);

        DB::table('reservation_payments')->insert([
            'reservation_id' => 7001,
            'payment_group' => 'gateway_group_1',
            'source_type' => 'wallet',
            'amount' => 25.00,
            'fee_amount' => 0.00,
            'total_amount' => 25.00,
            'reference_type' => 'wallet_transaction',
            'reference_id' => 'wallet_tx_7001',
            'status' => 'completed',
            'paid_at' => now()->subDay(),
            'meta' => json_encode([
                'requested_gateway' => 'mixed',
                'source_gateway' => 'wallet',
                'source_gateway_family' => 'internal_balance',
                'source_verification_strategy' => 'wallet_balance',
            ]),
            'created_at' => now()->subDay(),
            'updated_at' => now()->subDay(),
        ]);

        DB::table('bookings')->insert([
            [
                'id' => 8001,
                'customer_id' => 1,
                'event_id' => 901,
                'email' => 'buyer-a@example.com',
                'phone' => '000000',
                'price' => 60.00,
                'quantity' => 1,
                'created_at' => now()->subHours(5),
                'updated_at' => now()->subHours(5),
            ],
            [
                'id' => 8002,
                'customer_id' => 1,
                'event_id' => 902,
                'email' => 'buyer-b@example.com',
                'phone' => '000000',
                'price' => 40.00,
                'quantity' => 1,
                'created_at' => now()->subHours(4),
                'updated_at' => now()->subHours(4),
            ],
        ]);

        DB::table('booking_payment_allocations')->insert([
            [
                'booking_id' => 8001,
                'source_type' => 'card',
                'amount' => 55.00,
                'fee_amount' => 5.00,
                'total_amount' => 60.00,
                'reference_type' => 'stripe_payment_intent',
                'reference_id' => 'pi_8001',
                'meta' => json_encode([
                    'requested_gateway' => 'mixed',
                    'source_gateway' => 'card',
                    'source_gateway_family' => 'stripe_card',
                    'source_verification_strategy' => 'mixed_with_stripe_remainder',
                ]),
                'created_at' => now()->subHours(3),
                'updated_at' => now()->subHours(3),
            ],
            [
                'booking_id' => 8002,
                'source_type' => 'wallet',
                'amount' => 40.00,
                'fee_amount' => 0.00,
                'total_amount' => 40.00,
                'reference_type' => 'wallet_transaction',
                'reference_id' => 'wt_8002',
                'meta' => json_encode([
                    'requested_gateway' => 'wallet',
                    'source_gateway' => 'wallet',
                    'source_gateway_family' => 'internal_balance',
                    'source_verification_strategy' => 'wallet_balance',
                ]),
                'created_at' => now()->subHours(2),
                'updated_at' => now()->subHours(2),
            ],
        ]);

        DB::table('platform_revenue_events')->insert([
            [
                'idempotency_key' => 'gateway_telemetry_1',
                'operation_key' => 'marketplace_card_processing',
                'reference_type' => 'booking',
                'reference_id' => '8001',
                'booking_id' => 8001,
                'event_id' => 901,
                'gross_amount' => 60.00,
                'fee_amount' => 5.00,
                'net_amount' => 55.00,
                'total_charge_amount' => 60.00,
                'charged_to' => 'buyer',
                'currency' => 'DOP',
                'status' => 'completed',
                'metadata' => json_encode([
                    'requested_gateway' => 'stripe',
                    'gateway' => 'stripe',
                    'gateway_family' => 'stripe_card',
                    'verification_strategy' => 'online_card_capture',
                ]),
                'occurred_at' => now()->subHour(),
                'created_at' => now()->subHour(),
                'updated_at' => now()->subHour(),
            ],
            [
                'idempotency_key' => 'gateway_telemetry_2',
                'operation_key' => 'marketplace_resale',
                'reference_type' => 'booking',
                'reference_id' => '8002',
                'booking_id' => 8002,
                'event_id' => 902,
                'gross_amount' => 40.00,
                'fee_amount' => 4.00,
                'net_amount' => 36.00,
                'total_charge_amount' => 40.00,
                'charged_to' => 'seller',
                'currency' => 'DOP',
                'status' => 'completed',
                'metadata' => json_encode([
                    'requested_gateway' => 'wallet',
                    'gateway' => 'wallet',
                    'gateway_family' => 'internal_balance',
                    'verification_strategy' => 'wallet_balance',
                ]),
                'occurred_at' => now()->subMinutes(30),
                'created_at' => now()->subMinutes(30),
                'updated_at' => now()->subMinutes(30),
            ],
        ]);

        $request = Request::create('/admin/event-booking/economy', 'GET', [
            'preset' => '7d',
            'event_id' => 901,
        ]);
        $this->app->instance('request', $request);

        $view = app(EconomyController::class)->dashboard();
        $data = $view->getData();

        $this->assertSame(3, (int) data_get($data, 'gatewayTelemetry.summary.total_records'));
        $this->assertSame(3, (int) data_get($data, 'gatewayTelemetry.summary.source_count'));
        $this->assertSame(2, (int) data_get($data, 'gatewayTelemetry.summary.gateway_family_count'));
        $this->assertSame(2, (int) data_get($data, 'gatewayTelemetry.summary.mixed_requested_records'));

        $sourceLabels = collect(data_get($data, 'gatewayTelemetry.by_source', []))->pluck('source_label')->all();
        $this->assertContains('Reservation payments', $sourceLabels);
        $this->assertContains('Booking allocations', $sourceLabels);
        $this->assertContains('Revenue ledger', $sourceLabels);

        $familyRows = collect(data_get($data, 'gatewayTelemetry.by_gateway_family', []))->keyBy('gateway_family');
        $this->assertSame(2, (int) data_get($familyRows, 'stripe_card.record_count'));
        $this->assertSame(1, (int) data_get($familyRows, 'internal_balance.record_count'));

        $recentEventIds = collect(data_get($data, 'gatewayTelemetry.recent_records', []))
            ->pluck('event_id')
            ->filter()
            ->unique()
            ->values()
            ->all();
        $this->assertSame([901], $recentEventIds);
        $this->assertSame('Gateway Event A', data_get($data, 'gatewayTelemetry.recent_records.0.event_label'));
    }
}
