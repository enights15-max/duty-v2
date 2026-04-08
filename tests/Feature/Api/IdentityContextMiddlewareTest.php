<?php

namespace Tests\Feature\Api;

use App\Http\Middleware\IdentityContext;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Tests\Support\ActorFeatureTestCase;

class IdentityContextMiddlewareTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];

    public function test_customer_guard_resolves_user_membership_and_sets_active_identity_context(): void
    {
        [$customer, $identityId] = $this->seedCustomerWithActiveOrganizerIdentity(2001, 9001, 'actor-link@example.com', 31);

        $request = Request::create('/api/customers/wallet', 'GET', [], [], [], [
            'HTTP_X_IDENTITY_ID' => (string) $identityId,
        ]);
        $request->setUserResolver(fn () => $customer);

        $middleware = new IdentityContext();
        $response = $middleware->handle($request, function ($forwardedRequest) use ($identityId) {
            $activeIdentity = $forwardedRequest->get('active_identity');
            $this->assertNotNull($activeIdentity);
            $this->assertSame($identityId, (int) $activeIdentity->id);
            $this->assertSame(31, (int) $forwardedRequest->get('organizer_id_actor'));

            return response()->json(['status' => 'ok'], 200);
        });

        $this->assertEquals(200, $response->getStatusCode());
    }

    public function test_required_mode_rejects_when_identity_header_is_missing(): void
    {
        [$customer] = $this->seedCustomerWithActiveOrganizerIdentity(2002, 9002, 'missing-header@example.com', 44);

        $request = Request::create('/api/customers/wallet', 'GET');
        $request->setUserResolver(fn () => $customer);

        $middleware = new IdentityContext();
        $response = $middleware->handle($request, fn () => response()->json(['status' => 'ok']), 'required');

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertStringContainsString('X-Identity-Id header is required', (string) $response->getContent());
    }

    public function test_required_mode_rejects_invalid_or_inactive_identity_context(): void
    {
        [$customer] = $this->seedCustomerWithActiveOrganizerIdentity(2003, 9003, 'invalid-header@example.com', 55);

        $request = Request::create('/api/customers/wallet', 'GET', [], [], [], [
            'HTTP_X_IDENTITY_ID' => '999999',
        ]);
        $request->setUserResolver(fn () => $customer);

        $middleware = new IdentityContext();
        $response = $middleware->handle($request, fn () => response()->json(['status' => 'ok']), 'required');

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertStringContainsString('Invalid or inactive identity context', (string) $response->getContent());
    }

    private function seedCustomerWithActiveOrganizerIdentity(
        int $customerId,
        int $userId,
        string $email,
        int $legacyOrganizerId
    ): array {
        DB::table('users')->insert([
            'id' => $userId,
            'email' => $email,
            'username' => 'user_' . $userId,
            'first_name' => 'User',
            'last_name' => (string) $userId,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $customerId,
            'email' => $email,
            'username' => 'customer_' . $customerId,
            'fname' => 'Customer',
            'lname' => (string) $customerId,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => $userId,
            'display_name' => 'ORG ' . $legacyOrganizerId,
            'slug' => 'org-' . $legacyOrganizerId,
            'meta' => json_encode([
                'id' => $legacyOrganizerId,
                'legacy_source' => 'organizer',
                'legacy_id' => $legacyOrganizerId,
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => $userId,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $customer = new Customer();
        $customer->id = $customerId;
        $customer->email = $email;

        return [$customer, $identityId];
    }
}

