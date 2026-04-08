<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\FollowController;
use App\Models\Customer;
use App\Models\Organizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class FollowControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'followers'];
    protected array $baselineTruncate = [
        'followers',
        'customers',
        'users',
    ];

    public function test_follow_and_unfollow_organizer_flow(): void
    {
        DB::table('customers')->insert([
            'id' => 601,
            'email' => 'follow@example.com',
            'username' => 'follow-user',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(601), [], 'sanctum');

        $followRequest = Request::create('/api/organizers/follow', 'POST', [
            'id' => 77,
            'type' => 'organizer',
        ]);
        $followResponse = app(FollowController::class)->follow($followRequest);
        $followPayload = $followResponse->getData(true);

        $this->assertEquals(200, $followResponse->getStatusCode());
        $this->assertTrue($followPayload['success']);
        $this->assertTrue($followPayload['is_followed']);
        $this->assertEquals(1, $followPayload['followers_count']);
        $this->assertDatabaseHas('followers', [
            'customer_id' => 601,
            'following_id' => 77,
            'following_type' => Organizer::class,
        ]);

        $unfollowRequest = Request::create('/api/organizers/unfollow', 'POST', [
            'id' => 77,
            'type' => 'organizer',
        ]);
        $unfollowResponse = app(FollowController::class)->unfollow($unfollowRequest);
        $unfollowPayload = $unfollowResponse->getData(true);

        $this->assertEquals(200, $unfollowResponse->getStatusCode());
        $this->assertTrue($unfollowPayload['success']);
        $this->assertFalse($unfollowPayload['is_followed']);
        $this->assertEquals(0, $unfollowPayload['followers_count']);
        $this->assertDatabaseCount('followers', 0);
    }

    public function test_follow_requires_valid_type(): void
    {
        DB::table('customers')->insert([
            'id' => 602,
            'email' => 'invalid-follow@example.com',
            'username' => 'invalid-follow',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(602), [], 'sanctum');

        $request = Request::create('/api/organizers/follow', 'POST', [
            'id' => 77,
            'type' => 'invalid',
        ]);

        $response = app(FollowController::class)->follow($request);
        $payload = $response->getData(true);

        $this->assertEquals(422, $response->getStatusCode());
        $this->assertFalse($payload['success']);
        $this->assertArrayHasKey('errors', $payload);
    }
}
