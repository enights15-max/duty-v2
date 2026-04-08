<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\ScannerApi\AdminScannerController;
use App\Http\Controllers\ScannerApi\OrganizerScannerController;
use Illuminate\Http\Request;
use Tests\TestCase;

class ScannerContractSmokeTest extends TestCase
{
    public function test_organizer_authentication_fail_returns_401_contract(): void
    {
        $response = app(OrganizerScannerController::class)->authentication_fail();
        $payload = $response->getData(true);

        $this->assertEquals(401, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertEquals('Unauthenticated.', $payload['message']);
    }

    public function test_admin_check_qrcode_invalid_format_returns_unverified(): void
    {
        $request = Request::create('/api/scanner/admin/check-qrcode', 'POST', [
            'booking_id' => 'invalid-format',
        ]);

        $response = app(AdminScannerController::class)->check_qrcode($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('error', $payload['alert_type']);
        $this->assertEquals('Unverified', $payload['message']);
    }
}
