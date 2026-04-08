<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\ScannerApi\OrganizerScannerController;
use App\Models\Organizer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class OrganizerScannerIdentityOwnershipTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'discovery_catalog', 'marketplace', 'event_rewards'];
    protected array $baselineTruncate = [
        'users',
        'customers',
        'identities',
        'identity_members',
        'organizers',
        'organizer_infos',
        'event_reward_claim_logs',
        'event_reward_instances',
        'event_reward_definitions',
        'events',
        'event_contents',
        'tickets',
        'wishlists',
        'bookings',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureScannerEventTables();
        $this->ensureScannerBookingColumns();
        $this->seedOrganizerIdentityActor();
    }

    public function test_scanner_events_lists_identity_owned_event_even_when_legacy_organizer_id_is_missing(): void
    {
        $languageId = (int) DB::table('languages')->where('is_default', 1)->value('id');

        DB::table('events')->insert([
            'id' => 701,
            'organizer_id' => null,
            'owner_identity_id' => 9001,
            'slug' => 'identity-owned-scanner-event',
            'thumbnail' => 'identity-owned-scanner-event.jpg',
            'date_type' => 'single',
            'start_date' => now()->addDays(7)->toDateString(),
            'start_time' => '21:00:00',
            'duration' => '4h',
            'event_type' => 'venue',
            'address' => 'Scanner Identity Avenue',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 701,
            'language_id' => $languageId,
            'title' => 'Identity Scanner Event',
            'slug' => 'identity-scanner-event',
            'address' => 'Scanner Identity Avenue',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(601), [], 'organizer_sanctum');

        $request = Request::create('/api/scanner/organizer/events', 'GET', [], [], [], [
            'HTTP_ACCEPT_LANGUAGE' => 'en',
        ]);

        $response = app(OrganizerScannerController::class)->events($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['status']);
        $this->assertSame(701, $payload['events']['events'][0]['id']);
        $this->assertSame('Identity Scanner Event', $payload['events']['events'][0]['title']);
    }

    public function test_scanner_can_verify_booking_for_identity_owned_event_even_when_booking_legacy_organizer_id_differs(): void
    {
        $this->seedIdentityOwnedEvent(702, 9001, null);

        DB::table('bookings')->insert([
            'id' => 70201,
            'event_id' => 702,
            'organizer_id' => 999,
            'booking_id' => 'bk-702',
            'order_number' => 'ord-702',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(601), [], 'organizer_sanctum');

        $request = Request::create('/api/scanner/organizer/check-qrcode', 'POST', [
            'booking_id' => 'bk-702__seat-a',
        ]);

        $response = app(OrganizerScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['alert_type']);
        $this->assertSame('Verified', $payload['message']);

        $this->assertDatabaseHas('bookings', [
            'id' => 70201,
            'scan_status' => 1,
        ]);
    }

    public function test_scanner_rejects_booking_when_event_belongs_to_another_identity(): void
    {
        DB::table('users')->insert([
            'id' => 9002,
            'email' => 'other-organizer-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 9002,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9002,
            'display_name' => 'Other Scanner Organizer',
            'slug' => 'other-scanner-organizer',
            'meta' => json_encode(['legacy_id' => 777]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->seedIdentityOwnedEvent(703, 9002, 777);

        DB::table('bookings')->insert([
            'id' => 70301,
            'event_id' => 703,
            'organizer_id' => 777,
            'booking_id' => 'bk-703',
            'order_number' => 'ord-703',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(601), [], 'organizer_sanctum');

        $request = Request::create('/api/scanner/organizer/check-qrcode', 'POST', [
            'booking_id' => 'bk-703__seat-a',
        ]);

        $response = app(OrganizerScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('error', $payload['alert_type']);
        $this->assertSame('you do not have permission', $payload['message']);
    }

    public function test_scanner_can_claim_activated_reward_code_using_legacy_alias_payload(): void
    {
        $this->seedIdentityOwnedEvent(704, 9001, null);

        DB::table('bookings')->insert([
            'id' => 70401,
            'event_id' => 704,
            'organizer_id' => 601,
            'booking_id' => 'bk-704',
            'order_number' => 'ord-704',
            'paymentStatus' => 'completed',
            'scan_status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_definitions')->insert([
            'id' => 74001,
            'event_id' => 704,
            'title' => 'Welcome drink',
            'reward_type' => 'drink',
            'trigger_mode' => 'on_ticket_scan',
            'fulfillment_mode' => 'qr_claim',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_instances')->insert([
            'id' => 74011,
            'event_id' => 704,
            'reward_definition_id' => 74001,
            'booking_id' => 70401,
            'claim_code' => 'DRINK-000704-01-ABCD',
            'claim_qr_payload' => 'duty://event-reward-claim?code=DRINK-000704-01-ABCD',
            'status' => 'activated',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(601), [], 'organizer_sanctum');

        $request = Request::create('/api/scanner/organizer/claim-reward', 'POST', [
            'reward_claim_code' => 'DRINK-000704-01-ABCD',
        ]);

        $response = app(OrganizerScannerController::class)->claimReward($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['status']);
        $this->assertSame('success', $payload['alert_type']);
        $this->assertSame('Reward claimed successfully', $payload['message']);
        $this->assertDatabaseHas('event_reward_instances', [
            'id' => 74011,
            'status' => 'claimed',
        ]);
        $this->assertDatabaseHas('event_reward_claim_logs', [
            'reward_instance_id' => 74011,
            'action' => 'claimed',
        ]);
    }

    private function seedOrganizerIdentityActor(): void
    {
        DB::table('users')->insert([
            'id' => 9001,
            'email' => 'scanner-organizer-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 601,
            'username' => 'scanner-organizer',
            'email' => 'scanner-organizer@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 9001,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9001,
            'display_name' => 'Scanner Organizer Identity',
            'slug' => 'scanner-organizer-identity',
            'meta' => json_encode(['legacy_id' => 601]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedIdentityOwnedEvent(int $eventId, int $ownerIdentityId, ?int $legacyOrganizerId): void
    {
        $languageId = (int) DB::table('languages')->where('is_default', 1)->value('id');

        DB::table('events')->insert([
            'id' => $eventId,
            'organizer_id' => $legacyOrganizerId,
            'owner_identity_id' => $ownerIdentityId,
            'slug' => 'scanner-owned-event-' . $eventId,
            'thumbnail' => 'scanner-owned-event-' . $eventId . '.jpg',
            'date_type' => 'single',
            'start_date' => now()->addDays(5)->toDateString(),
            'start_time' => '20:00:00',
            'duration' => '3h',
            'event_type' => 'venue',
            'address' => 'Scanner Owned Address',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $languageId,
            'title' => 'Scanner Owned Event ' . $eventId,
            'slug' => 'scanner-owned-event-' . $eventId,
            'address' => 'Scanner Owned Address',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureScannerEventTables(): void
    {
        $eventColumns = [
            'slug' => 'string',
            'thumbnail' => 'string',
            'date_type' => 'string',
            'start_date' => 'date',
            'start_time' => 'string',
            'duration' => 'string',
            'event_type' => 'string',
            'address' => 'string',
            'status' => 'integer',
        ];

        foreach ($eventColumns as $column => $type) {
            if (Schema::hasColumn('events', $column)) {
                continue;
            }

            Schema::table('events', function (Blueprint $table) use ($column, $type): void {
                match ($type) {
                    'date' => $table->date($column)->nullable(),
                    'integer' => $table->integer($column)->default(1),
                    default => $table->string($column)->nullable(),
                };
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->decimal('price', 10, 2)->nullable();
                $table->decimal('f_price', 10, 2)->nullable();
                $table->string('pricing_type')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('wishlists')) {
            Schema::create('wishlists', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->timestamps();
            });
        }
    }

    private function ensureScannerBookingColumns(): void
    {
        $bookingColumns = [
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'booking_id' => fn (Blueprint $table) => $table->string('booking_id')->nullable(),
            'order_number' => fn (Blueprint $table) => $table->string('order_number')->nullable(),
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'scanned_tickets' => fn (Blueprint $table) => $table->longText('scanned_tickets')->nullable(),
            'scan_status' => fn (Blueprint $table) => $table->integer('scan_status')->default(0),
        ];

        foreach ($bookingColumns as $column => $definition) {
            if (Schema::hasColumn('bookings', $column)) {
                continue;
            }

            Schema::table('bookings', function (Blueprint $table) use ($definition): void {
                $definition($table);
            });
        }
    }
}
