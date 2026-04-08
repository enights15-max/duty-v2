<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\PaymentMethodController;
use App\Models\Customer;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class PaymentMethodsActorApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'payment_methods'];
    protected array $baselineTruncate = [
        'payment_methods',
        'customers',
        'users',
    ];
    protected bool $baselineDefaultLanguage = true;

    public function test_authenticated_customer_receives_only_its_actor_payment_methods(): void
    {
        DB::table('customers')->insert([
            'id' => 55,
            'email' => 'api-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 56,
            'email' => 'other-customer@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('payment_methods')->insert([
            [
                'id' => '55555555-5555-4555-8555-555555555551',
                'user_id' => 55,
                'actor_type' => 'customer',
                'actor_id' => 55,
                'stripe_payment_method_id' => 'pm_visible_1',
                'status' => 'active',
                'is_default' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '55555555-5555-4555-8555-555555555552',
                'user_id' => 55,
                'actor_type' => 'user',
                'actor_id' => 55,
                'stripe_payment_method_id' => 'pm_hidden_user_actor',
                'status' => 'active',
                'is_default' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '55555555-5555-4555-8555-555555555553',
                'user_id' => 56,
                'actor_type' => 'customer',
                'actor_id' => 56,
                'stripe_payment_method_id' => 'pm_hidden_other_customer',
                'status' => 'active',
                'is_default' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '55555555-5555-4555-8555-555555555554',
                'user_id' => 55,
                'actor_type' => 'customer',
                'actor_id' => 55,
                'stripe_payment_method_id' => 'pm_hidden_revoked',
                'status' => 'revoked',
                'is_default' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $customer = Customer::findOrFail(55);
        Sanctum::actingAs($customer, [], 'sanctum');

        $response = app(PaymentMethodController::class)->index();
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('success', $payload['status']);
        $this->assertCount(1, $payload['data']);
        $this->assertEquals('pm_visible_1', $payload['data'][0]['stripe_payment_method_id']);
    }

    public function test_payment_methods_endpoint_requires_authentication(): void
    {
        $response = app(PaymentMethodController::class)->index();
        $payload = $response->getData(true);

        $this->assertEquals(401, $response->getStatusCode());
        $this->assertEquals('Unauthenticated', $payload['message']);
    }
}
