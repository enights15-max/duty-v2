<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\SubscriptionController;
use App\Models\Customer;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class SubscriptionControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'subscription_plans'];
    protected array $baselineTruncate = [
        'subscription_plans',
        'customers',
        'users',
    ];

    public function test_index_returns_only_active_subscription_plans(): void
    {
        DB::table('subscription_plans')->insert([
            [
                'id' => '70100000-0000-4000-8000-000000000001',
                'name' => 'VIP Active',
                'description' => 'Active plan',
                'price' => 19.99,
                'currency' => 'DOP',
                'stripe_price_id' => 'price_active',
                'status' => 'active',
                'features' => json_encode(['badge' => true]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '70100000-0000-4000-8000-000000000002',
                'name' => 'VIP Disabled',
                'description' => 'Inactive plan',
                'price' => 9.99,
                'currency' => 'DOP',
                'stripe_price_id' => 'price_inactive',
                'status' => 'inactive',
                'features' => json_encode(['badge' => false]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $response = app(SubscriptionController::class)->index();
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('success', $payload['status']);
        $this->assertCount(1, $payload['data']);
        $this->assertEquals('VIP Active', $payload['data'][0]['name']);
    }

    public function test_subscribe_returns_checkout_url_for_customer_actor(): void
    {
        DB::table('customers')->insert([
            'id' => 703,
            'email' => 'vip-customer@example.com',
            'fname' => 'VIP',
            'lname' => 'Customer',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('subscription_plans')->insert([
            'id' => '70300000-0000-4000-8000-000000000001',
            'name' => 'VIP Monthly',
            'description' => 'Monthly access',
            'price' => 15.00,
            'currency' => 'DOP',
            'stripe_price_id' => 'price_vip_monthly',
            'status' => 'active',
            'features' => json_encode(['priority_support' => true]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->app->instance(SubscriptionService::class, new class extends SubscriptionService {
            public function __construct()
            {
            }

            public function createCheckoutSession($user, \App\Models\SubscriptionPlan $plan, string $successUrl, string $cancelUrl): string
            {
                return 'https://checkout.example.com/session_' . $user->id . '_' . $plan->id;
            }
        });

        $request = Request::create('/api/customers/subscriptions/subscribe', 'POST', [
            'plan_id' => '70300000-0000-4000-8000-000000000001',
            'success_url' => 'https://app.example.com/success',
            'cancel_url' => 'https://app.example.com/cancel',
        ]);
        $request->setUserResolver(fn () => Customer::findOrFail(703));

        $response = app(SubscriptionController::class)->subscribe($request);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('success', $payload['status']);
        $this->assertStringContainsString('https://checkout.example.com/session_703_', $payload['checkout_url']);
    }
}
