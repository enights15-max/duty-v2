<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\RewardCatalog;
use App\Services\LoyaltyService;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class LoyaltyServiceTest extends ActorFeatureTestCase
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

    public function test_award_from_rule_updates_balance_once_per_idempotent_reference(): void
    {
        DB::table('customers')->insert([
            'id' => 1201,
            'email' => 'loyalty-award@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1201);
        $service = app(LoyaltyService::class);

        $first = $service->awardFromRule($customer, 'follow_accept', 'follow', 'f-1201');
        $second = $service->awardFromRule($customer, 'follow_accept', 'follow', 'f-1201');

        $this->assertNotNull($first);
        $this->assertSame($first->id, $second->id);
        $this->assertSame(10, $service->summaryFor($customer)['current_points']);
        $this->assertDatabaseCount('loyalty_point_transactions', 1);
    }

    public function test_redeem_reward_debits_points_and_credits_bonus_wallet(): void
    {
        Carbon::setTestNow(now());

        DB::table('customers')->insert([
            'id' => 1202,
            'email' => 'loyalty-redeem@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1202);
        $service = app(LoyaltyService::class);

        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1202-a');
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1202-b');
        $service->awardFromRule($customer, 'published_review', 'review', 'rv-1202');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw-1202');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw2-1202');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw3-1202');

        $reward = RewardCatalog::query()->where('title', 'Bono RD$50')->firstOrFail();
        $redemption = $service->redeemReward($customer, $reward);

        $this->assertSame('completed', $redemption->status);
        $this->assertSame(5, $service->summaryFor($customer)['current_points']);
        $this->assertEquals('50.00', DB::table('bonus_wallets')->where('actor_type', 'customer')->where('actor_id', 1202)->value('balance'));
        $this->assertNotNull(data_get($redemption->meta, 'fulfillment.expires_at'));
        $this->assertEquals(
            now()->addDays(90)->toDateString(),
            Carbon::parse((string) data_get($redemption->meta, 'fulfillment.expires_at'))->toDateString()
        );
        $this->assertDatabaseHas('reward_redemptions', [
            'customer_id' => 1202,
            'reward_id' => $reward->id,
            'status' => 'completed',
        ]);
        Carbon::setTestNow();
    }

    public function test_redeem_perk_reward_generates_claim_code_and_completes(): void
    {
        DB::table('customers')->insert([
            'id' => 1203,
            'email' => 'loyalty-perk@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reward_catalog')->insert([
            'title' => 'Access pass backstage',
            'description' => 'Perk con reclamo directo.',
            'reward_type' => 'perk',
            'points_cost' => 120,
            'bonus_amount' => null,
            'is_active' => 1,
            'is_featured' => 0,
            'meta' => json_encode([
                'claim_code_prefix' => 'VIP',
                'instructions' => 'Muestra el codigo en la entrada VIP.',
                'claim_expires_in_days' => 10,
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1203);
        $service = app(LoyaltyService::class);
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1203-a');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw-1203-a');
        $service->awardFromRule($customer, 'follow_accept', 'follow', 'fw-1203-b');

        $reward = RewardCatalog::query()->where('title', 'Access pass backstage')->firstOrFail();
        $redemption = $service->redeemReward($customer, $reward);

        $this->assertSame('completed', $redemption->status);
        $this->assertSame('claim_code', data_get($redemption->meta, 'fulfillment.mode'));
        $this->assertStringStartsWith('VIP-', data_get($redemption->meta, 'fulfillment.claim_code'));
        $this->assertSame('Muestra el codigo en la entrada VIP.', data_get($redemption->meta, 'fulfillment.instructions'));
    }

    public function test_redeem_event_coupon_reward_creates_coupon_and_completes(): void
    {
        DB::table('customers')->insert([
            'id' => 1204,
            'email' => 'loyalty-coupon@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('reward_catalog')->insert([
            'title' => 'Coupon 15% weekend',
            'description' => 'Cupon para eventos seleccionados.',
            'reward_type' => 'event_coupon',
            'points_cost' => 200,
            'bonus_amount' => null,
            'is_active' => 1,
            'is_featured' => 0,
            'meta' => json_encode([
                'coupon_type' => 'percentage',
                'coupon_value' => 15,
                'event_ids' => [77, 88],
                'instructions' => 'Aplica este codigo en el checkout del evento elegible.',
                'coupon_expires_in_days' => 14,
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = Customer::findOrFail(1204);
        $service = app(LoyaltyService::class);
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1204-a');
        $service->awardFromRule($customer, 'event_purchase', 'booking_order', 'ord-1204-b');

        $reward = RewardCatalog::query()->where('title', 'Coupon 15% weekend')->firstOrFail();
        $redemption = $service->redeemReward($customer, $reward);

        $couponCode = data_get($redemption->meta, 'fulfillment.coupon_code');

        $this->assertSame('completed', $redemption->status);
        $this->assertSame('event_coupon', data_get($redemption->meta, 'fulfillment.mode'));
        $this->assertNotEmpty($couponCode);
        $this->assertDatabaseHas('coupons', [
            'code' => $couponCode,
            'type' => 'percentage',
        ]);
        $this->assertSame([77, 88], data_get($redemption->meta, 'fulfillment.event_ids'));
    }
}
