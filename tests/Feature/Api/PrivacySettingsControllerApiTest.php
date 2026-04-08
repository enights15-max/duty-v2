<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\PrivacySettingsController;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class PrivacySettingsControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = ['customers', 'users'];

    public function test_show_returns_customer_social_privacy_settings(): void
    {
        DB::table('customers')->insert([
            'id' => 901,
            'email' => 'privacy@example.com',
            'username' => 'privacy-user',
            'is_private' => 1,
            'show_interested_events' => 0,
            'show_attended_events' => 1,
            'show_upcoming_attendance' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(901), [], 'sanctum');

        $response = app(PrivacySettingsController::class)->show();
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertTrue($payload['data']['is_private']);
        $this->assertFalse($payload['data']['show_interested_events']);
        $this->assertTrue($payload['data']['show_attended_events']);
        $this->assertFalse($payload['data']['show_upcoming_attendance']);
    }

    public function test_update_persists_customer_social_privacy_settings(): void
    {
        DB::table('customers')->insert([
            'id' => 902,
            'email' => 'privacy-update@example.com',
            'username' => 'privacy-update',
            'is_private' => 0,
            'show_interested_events' => 1,
            'show_attended_events' => 1,
            'show_upcoming_attendance' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(902), [], 'sanctum');

        $request = Request::create('/api/customers/privacy-settings', 'PUT', [
            'is_private' => true,
            'show_interested_events' => false,
            'show_attended_events' => false,
            'show_upcoming_attendance' => true,
        ]);

        $response = app(PrivacySettingsController::class)->update($request);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertTrue($payload['data']['is_private']);
        $this->assertFalse($payload['data']['show_interested_events']);
        $this->assertFalse($payload['data']['show_attended_events']);
        $this->assertTrue($payload['data']['show_upcoming_attendance']);

        $this->assertDatabaseHas('customers', [
            'id' => 902,
            'is_private' => 1,
            'show_interested_events' => 0,
            'show_attended_events' => 0,
            'show_upcoming_attendance' => 1,
        ]);
    }
}
