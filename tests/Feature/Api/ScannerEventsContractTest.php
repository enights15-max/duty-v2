<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\ScannerApi\AdminScannerController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ScannerEventsContractTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['admins_permissions', 'marketplace', 'discovery_catalog'];
    protected array $baselineTruncate = ['admins', 'events', 'event_contents', 'tickets', 'wishlists'];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureScannerEventTables();
    }

    public function test_admin_events_returns_success_even_when_event_has_no_tickets(): void
    {
        DB::table('admins')->insert([
            'id' => 501,
            'username' => 'scanner-contract-admin',
            'email' => 'scanner-contract-admin@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $languageId = (int) DB::table('languages')->where('is_default', 1)->value('id');

        DB::table('events')->insert([
            'id' => 501,
            'slug' => 'scanner-no-ticket',
            'thumbnail' => 'scanner-no-ticket.jpg',
            'date_type' => 'single',
            'start_date' => now()->toDateString(),
            'start_time' => '20:00:00',
            'duration' => '4h',
            'event_type' => 'venue',
            'address' => 'QA Scanner Avenue',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 501,
            'language_id' => $languageId,
            'title' => 'Scanner Contract Event',
            'slug' => 'scanner-contract-event',
            'address' => 'QA Scanner Avenue',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'DO',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/scanner/admin/events', 'GET', [], [], [], [
            'HTTP_ACCEPT_LANGUAGE' => 'en',
        ]);

        $response = app(AdminScannerController::class)->events($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode(), json_encode($payload));
        $this->assertSame('success', $payload['status']);
        $this->assertIsArray($payload['events']['events']);
        $this->assertSame(501, $payload['events']['events'][0]['id']);
        $this->assertNull($payload['events']['events'][0]['start_price']);
    }

    private function ensureScannerEventTables(): void
    {
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

        $eventColumns = [
            'slug' => 'string',
            'date_type' => 'string',
            'start_date' => 'date',
            'start_time' => 'string',
            'duration' => 'string',
            'event_type' => 'string',
            'address' => 'string',
        ];

        foreach ($eventColumns as $column => $type) {
            if (Schema::hasColumn('events', $column)) {
                continue;
            }

            Schema::table('events', function (Blueprint $table) use ($column, $type): void {
                match ($type) {
                    'date' => $table->date($column)->nullable(),
                    default => $table->string($column)->nullable(),
                };
            });
        }
    }
}
