<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\ScannerApi\AdminScannerController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ScannerAttendanceLoyaltyTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'marketplace', 'loyalty'];
    protected array $baselineTruncate = ['loyalty_point_transactions', 'bookings', 'customers', 'users'];

    protected function setUp(): void
    {
        parent::setUp();
        $this->ensureScannerBookingColumns();
    }

    public function test_admin_qr_scan_marks_attendance_and_awards_loyalty(): void
    {
        DB::table('users')->insert([
            'id' => 1701,
            'email' => 'scanner-admin-loyalty@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 1701,
            'email' => 'scanner-admin-loyalty@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 17001,
            'customer_id' => 1701,
            'event_id' => 88,
            'booking_id' => 'bk-1701',
            'order_number' => 'ord-1701',
            'paymentStatus' => 'completed',
            'scan_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create('/api/scanner/admin/check-qrcode', 'POST', [
            'booking_id' => 'bk-1701__slot-a',
        ]);

        $response = app(AdminScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame('success', $payload['alert_type']);
        $this->assertSame('Verified', $payload['message']);
        $this->assertDatabaseHas('bookings', [
            'id' => 17001,
            'scan_status' => 1,
        ]);
        $this->assertDatabaseHas('loyalty_point_transactions', [
            'customer_id' => 1701,
            'reference_type' => 'booking_attendance',
            'reference_id' => 'ord-1701',
            'points' => 40,
        ]);

        $repeatResponse = app(AdminScannerController::class)->check_qrcode($request);
        $repeatPayload = $repeatResponse->getData(true);

        $this->assertSame('error', $repeatPayload['alert_type']);
        $this->assertSame('Already Scanned', $repeatPayload['message']);
        $this->assertSame(1, DB::table('loyalty_point_transactions')->count());
    }

    private function ensureScannerBookingColumns(): void
    {
        if (!Schema::hasColumn('bookings', 'booking_id')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('booking_id')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'order_number')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('order_number')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'paymentStatus')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->string('paymentStatus')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'scanned_tickets')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->longText('scanned_tickets')->nullable();
            });
        }

        if (!Schema::hasColumn('bookings', 'scan_status')) {
            Schema::table('bookings', function (Blueprint $table): void {
                $table->integer('scan_status')->default(0);
            });
        }
    }
}
