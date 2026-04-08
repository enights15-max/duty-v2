<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\OrganizerScannerController;
use App\Models\Organizer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class LegacyOrganizerScannerControllerIdentityOwnershipTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'discovery_catalog', 'marketplace'];
    protected array $baselineTruncate = [
        'users',
        'customers',
        'identities',
        'identity_members',
        'organizers',
        'organizer_infos',
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

        $this->ensureScannerBookingTables();
        $this->seedOrganizerIdentityActor();
    }

    public function test_legacy_scanner_controller_can_verify_booking_for_identity_owned_event(): void
    {
        $this->seedIdentityOwnedEvent(801, 9101, null);

        DB::table('bookings')->insert([
            'id' => 80101,
            'event_id' => 801,
            'organizer_id' => 999,
            'booking_id' => 'legacy-bk-801',
            'order_number' => 'legacy-ord-801',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(611), [], 'organizer_sanctum');

        $request = Request::create('/api/organizer/check-qrcode', 'POST', [
            'booking_id' => 'legacy-bk-801__seat-a',
        ]);

        $response = app(OrganizerScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['alert_type']);
        $this->assertSame('Verified', $payload['message']);
        $this->assertDatabaseHas('bookings', [
            'id' => 80101,
            'scan_status' => 1,
        ]);
    }

    public function test_legacy_scanner_controller_rejects_booking_from_other_identity(): void
    {
        DB::table('users')->insert([
            'id' => 9102,
            'email' => 'legacy-other-organizer-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 9102,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9102,
            'display_name' => 'Legacy Other Scanner Organizer',
            'slug' => 'legacy-other-scanner-organizer',
            'meta' => json_encode(['legacy_id' => 777]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->seedIdentityOwnedEvent(802, 9102, 777);

        DB::table('bookings')->insert([
            'id' => 80201,
            'event_id' => 802,
            'organizer_id' => 777,
            'booking_id' => 'legacy-bk-802',
            'order_number' => 'legacy-ord-802',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Organizer::findOrFail(611), [], 'organizer_sanctum');

        $request = Request::create('/api/organizer/check-qrcode', 'POST', [
            'booking_id' => 'legacy-bk-802__seat-a',
        ]);

        $response = app(OrganizerScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('error', $payload['alert_type']);
        $this->assertSame('you do not have permission', $payload['message']);
    }

    private function seedOrganizerIdentityActor(): void
    {
        DB::table('users')->insert([
            'id' => 9101,
            'email' => 'legacy-scanner-organizer-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 611,
            'username' => 'legacy-scanner-organizer',
            'email' => 'legacy-scanner-organizer@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 9101,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9101,
            'display_name' => 'Legacy Scanner Organizer Identity',
            'slug' => 'legacy-scanner-organizer-identity',
            'meta' => json_encode(['legacy_id' => 611]),
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
            'slug' => 'legacy-scanner-owned-event-' . $eventId,
            'thumbnail' => 'legacy-scanner-owned-event-' . $eventId . '.jpg',
            'date_type' => 'single',
            'start_date' => now()->addDays(5)->toDateString(),
            'start_time' => '20:00:00',
            'duration' => '3h',
            'event_type' => 'venue',
            'address' => 'Legacy Scanner Avenue',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $languageId,
            'title' => 'Legacy Scanner Event ' . $eventId,
            'slug' => 'legacy-scanner-event-' . $eventId,
            'address' => 'Legacy Scanner Avenue',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureScannerBookingTables(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->integer('status')->default(1);
                $table->timestamp('email_verified_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('slug')->nullable();
                $table->string('thumbnail')->nullable();
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->time('start_time')->nullable();
                $table->string('duration')->nullable();
                $table->string('event_type')->nullable();
                $table->string('address')->nullable();
                $table->integer('status')->default(1);
                $table->timestamps();
            });
        }

        foreach ([
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'slug' => fn (Blueprint $table) => $table->string('slug')->nullable(),
            'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
            'date_type' => fn (Blueprint $table) => $table->string('date_type')->nullable(),
            'start_date' => fn (Blueprint $table) => $table->date('start_date')->nullable(),
            'start_time' => fn (Blueprint $table) => $table->time('start_time')->nullable(),
            'duration' => fn (Blueprint $table) => $table->string('duration')->nullable(),
            'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
            'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
            'status' => fn (Blueprint $table) => $table->integer('status')->default(1),
        ] as $column => $definition) {
            if (!Schema::hasColumn('events', $column)) {
                Schema::table('events', $definition);
            }
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id');
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id'),
            'language_id' => fn (Blueprint $table) => $table->unsignedBigInteger('language_id'),
            'title' => fn (Blueprint $table) => $table->string('title')->nullable(),
            'slug' => fn (Blueprint $table) => $table->string('slug')->nullable(),
            'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
            'city' => fn (Blueprint $table) => $table->string('city')->nullable(),
            'state' => fn (Blueprint $table) => $table->string('state')->nullable(),
            'country' => fn (Blueprint $table) => $table->string('country')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('event_contents', $column)) {
                Schema::table('event_contents', $definition);
            }
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->string('booking_id')->nullable();
                $table->string('order_number')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->integer('scan_status')->default(0);
                $table->text('scanned_tickets')->nullable();
                $table->timestamps();
            });
        }

        foreach ([
            'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
            'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
            'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
            'organizer_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_identity_id')->nullable(),
            'booking_id' => fn (Blueprint $table) => $table->string('booking_id')->nullable(),
            'order_number' => fn (Blueprint $table) => $table->string('order_number')->nullable(),
            'paymentStatus' => fn (Blueprint $table) => $table->string('paymentStatus')->nullable(),
            'scan_status' => fn (Blueprint $table) => $table->integer('scan_status')->default(0),
            'scanned_tickets' => fn (Blueprint $table) => $table->text('scanned_tickets')->nullable(),
        ] as $column => $definition) {
            if (!Schema::hasColumn('bookings', $column)) {
                Schema::table('bookings', $definition);
            }
        }
    }
}
