<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\LoyaltyController;
use App\Models\Customer;
use App\Models\RewardCatalog;
use App\Services\LoyaltyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class LoyaltyControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'bonus_wallets', 'loyalty'];
    protected array $baselineTruncate = [
        'reward_redemptions',
        'loyalty_point_transactions',
        'bonus_transactions',
        'bonus_wallets',
        'coupons',
        'customers',
    ];

    public function test_customer_can_fetch_loyalty_summary_history_rewards_and_redeem(): void
    {
        DB::table('customers')->insert([
            'id' => 1301,
            'email' => 'loyalty-api@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1301);
        $service = app(LoyaltyService::class);
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1301-a');
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1301-b');
        $service->awardFromRule($customer, 'published_review', 'review', 'rv-1301');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw-1301');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw2-1301');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw3-1301');

        $summaryRequest = Request::create('/api/customers/loyalty/summary', 'GET');
        $summaryRequest->setUserResolver(fn () => $customer);
        $summaryResponse = app(LoyaltyController::class)->summary($summaryRequest);

        $historyRequest = Request::create('/api/customers/loyalty/history', 'GET');
        $historyRequest->setUserResolver(fn () => $customer);
        $historyResponse = app(LoyaltyController::class)->history($historyRequest);

        $rewardsRequest = Request::create('/api/customers/loyalty/rewards', 'GET');
        $rewardsRequest->setUserResolver(fn () => $customer);
        $rewardsResponse = app(LoyaltyController::class)->rewards($rewardsRequest);

        $reward = RewardCatalog::query()->where('title', 'Bono RD$50')->firstOrFail();
        $redeemRequest = Request::create('/api/customers/loyalty/rewards/' . $reward->id . '/redeem', 'POST');
        $redeemRequest->setUserResolver(fn () => $customer);
        $redeemResponse = app(LoyaltyController::class)->redeem($redeemRequest, $reward);

        $summaryPayload = $summaryResponse->getData(true);
        $historyPayload = $historyResponse->getData(true);
        $rewardsPayload = $rewardsResponse->getData(true);
        $redeemPayload = $redeemResponse->getData(true);

        $this->assertTrue($summaryPayload['success']);
        $this->assertSame(255, $summaryPayload['data']['current_points']);
        $this->assertCount(6, $historyPayload['data']['items']);
        $this->assertNotEmpty($rewardsPayload['data']['items']);
        $this->assertTrue($redeemPayload['success']);
        $this->assertSame(5, $redeemPayload['data']['summary']['current_points']);
        $this->assertSame('bonus_credit', $redeemPayload['data']['redemption']['meta']['fulfillment']['mode']);
    }

    public function test_customer_redemptions_return_fulfillment_details_for_event_coupon_rewards(): void
    {
        DB::table('customers')->insert([
            'id' => 1302,
            'email' => 'loyalty-api-coupon@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reward_catalog')->insert([
            'title' => 'Coupon fijo RD$200',
            'description' => 'Reward coupon canjeable en checkout.',
            'reward_type' => 'event_coupon',
            'points_cost' => 200,
            'bonus_amount' => null,
            'is_active' => 1,
            'is_featured' => 0,
            'meta' => json_encode([
                'coupon_type' => 'fixed',
                'coupon_value' => 200,
                'instructions' => 'Usa este codigo en checkout.',
                'coupon_expires_in_days' => 21,
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1302);
        $service = app(LoyaltyService::class);
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1302-a');
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1302-b');

        $reward = RewardCatalog::query()->where('title', 'Coupon fijo RD$200')->firstOrFail();
        $redeemRequest = Request::create('/api/customers/loyalty/rewards/' . $reward->id . '/redeem', 'POST');
        $redeemRequest->setUserResolver(fn () => $customer);
        app(LoyaltyController::class)->redeem($redeemRequest, $reward);

        $redemptionsRequest = Request::create('/api/customers/loyalty/redemptions', 'GET');
        $redemptionsRequest->setUserResolver(fn () => $customer);
        $redemptionsResponse = app(LoyaltyController::class)->redemptions($redemptionsRequest);
        $payload = $redemptionsResponse->getData(true);

        $this->assertTrue($payload['success']);
        $first = $payload['data']['items'][0] ?? null;
        $this->assertNotNull($first);
        $this->assertSame('event_coupon', $first['meta']['fulfillment']['mode']);
        $this->assertNotEmpty($first['meta']['fulfillment']['coupon_code']);
    }
}
