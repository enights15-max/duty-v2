<?php

namespace Tests\Feature\Api;

use App\Models\Admin;
use App\Models\Identity;
use App\Services\IdentityModerationNotificationService;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class AdminIdentityModerationRouteTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'admins_permissions', 'subscriptions'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'admins',
        'role_permissions',
        'subscriptions',
        'customers',
        'users',
    ];

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function test_route_requires_admin_authentication(): void
    {
        $identityId = $this->seedIdentity('pending', 'artist', 1101, 'route-auth-required');
        $this->bindNotificationNoop();

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/approve"), [
            'note' => 'ok',
        ]);

        $response->assertStatus(401);
    }

    public function test_route_blocks_admin_without_required_permission(): void
    {
        $identityId = $this->seedIdentity('pending', 'artist', 1102, 'route-forbidden');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('ReadOnly Admin', ['Event Management']);
        $admin = $this->seedAdmin(9101, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/approve"), [
            'note' => 'attempt',
        ]);

        $response
            ->assertStatus(403)
            ->assertJson([
                'status' => 'error',
                'message' => 'Forbidden.',
            ]);
    }

    public function test_route_allows_identity_management_permission_and_approves(): void
    {
        $identityId = $this->seedIdentity('pending', 'organizer', 1103, 'route-identity-management-ok');
        $this->bindNotificationExpectCalls(1);

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9102, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/approve"), [
            'note' => 'verified by moderator',
        ]);

        $response->assertStatus(200)->assertJson(['status' => 'success']);

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('active', $identity->status);
        $this->assertEquals(9102, $meta['approved_by_admin_id']);
    }

    public function test_route_allows_customer_management_permission_for_backward_compatibility(): void
    {
        $identityId = $this->seedIdentity('pending', 'venue', 1104, 'route-customer-management-ok');
        $this->bindNotificationExpectCalls(1);

        $roleId = $this->seedRole('Legacy Customer Admin', ['Customer Management']);
        $admin = $this->seedAdmin(9103, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/reject"), [
            'reason' => 'Insufficient legal evidence',
        ]);

        $response->assertStatus(200)->assertJson(['status' => 'success']);

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('rejected', $identity->status);
        $this->assertSame('Insufficient legal evidence', $meta['rejection_reason']);
        $this->assertEquals(9103, $meta['rejected_by_admin_id']);
    }

    public function test_route_returns_400_for_invalid_transition_even_with_permissions(): void
    {
        $identityId = $this->seedIdentity('active', 'artist', 1105, 'route-invalid-transition');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9104, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/approve"), [
            'note' => 'should fail',
        ]);

        $response
            ->assertStatus(400)
            ->assertJson([
                'status' => 'error',
                'message' => 'Only pending identities can be approved.',
            ]);
    }

    public function test_route_request_info_updates_revision_request_with_permissions(): void
    {
        $identityId = $this->seedIdentity('pending', 'organizer', 1106, 'route-request-info-ok');
        $this->bindNotificationExpectCalls(1);

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9105, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/request-info"), [
            'reason' => 'Please upload legal documents',
            'fields' => ['legal_name', 'contact_email'],
        ]);

        $response->assertStatus(200)->assertJson(['status' => 'success']);

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('pending', $identity->status);
        $this->assertSame('Please upload legal documents', data_get($meta, 'revision_request.reason'));
        $this->assertEquals(['legal_name', 'contact_email'], data_get($meta, 'revision_request.fields'));
        $this->assertEquals(9105, data_get($meta, 'revision_request.requested_by_admin_id'));
    }

    public function test_route_request_info_requires_reason_validation(): void
    {
        $identityId = $this->seedIdentity('pending', 'organizer', 1107, 'route-request-info-validation');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9106, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/request-info"), []);

        $response
            ->assertStatus(422)
            ->assertJson([
                'status' => 'validation_error',
            ]);
    }

    public function test_route_suspend_then_reactivate_flow_with_permissions(): void
    {
        $identityId = $this->seedIdentity('active', 'venue', 1108, 'route-suspend-reactivate-ok');
        $this->bindNotificationExpectCalls(2);

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9107, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $suspendResponse = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/suspend"), [
            'reason' => 'Violation',
        ]);
        $suspendResponse->assertStatus(200)->assertJson(['status' => 'success']);

        $suspended = Identity::findOrFail($identityId);
        $suspendedMeta = is_array($suspended->meta) ? $suspended->meta : [];
        $this->assertSame('suspended', $suspended->status);
        $this->assertSame('Violation', $suspendedMeta['suspension_reason']);
        $this->assertEquals(9107, $suspendedMeta['suspended_by_admin_id']);

        $reactivateResponse = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/reactivate"), [
            'note' => 'Resolved',
        ]);
        $reactivateResponse->assertStatus(200)->assertJson(['status' => 'success']);

        $reactivated = Identity::findOrFail($identityId);
        $reactivatedMeta = is_array($reactivated->meta) ? $reactivated->meta : [];
        $this->assertSame('active', $reactivated->status);
        $this->assertEquals(9107, $reactivatedMeta['reactivated_by_admin_id']);
        $this->assertCount(2, $reactivatedMeta['moderation_history'] ?? []);
    }

    public function test_route_reactivate_invalid_transition_returns_400(): void
    {
        $identityId = $this->seedIdentity('active', 'artist', 1109, 'route-reactivate-invalid');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9108, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/identities/{$identityId}/reactivate"), [
            'note' => 'not allowed',
        ]);

        $response
            ->assertStatus(400)
            ->assertJson([
                'status' => 'error',
                'message' => 'Only suspended identities can be reactivated.',
            ]);
    }

    public function test_route_index_returns_filtered_paginated_data_with_permissions(): void
    {
        $artistPendingId = $this->seedIdentity('pending', 'artist', 1110, 'route-index-pending-artist');
        $this->seedIdentity('active', 'venue', 1111, 'route-index-active-venue');
        $pendingVenueId = $this->seedIdentity('pending', 'venue', 1112, 'route-index-pending-venue');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9109, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->getJson($this->apiUrl('/api/admin/identities?status=pending&type=artist&per_page=1'));

        $response->assertStatus(200)->assertJson(['status' => 'success']);
        $firstPageData = $response->json('identities.data');
        $this->assertCount(1, $firstPageData);
        $this->assertEquals($artistPendingId, $firstPageData[0]['id']);
        $this->assertEquals(1, $response->json('identities.per_page'));

        $ownerFiltered = $this->getJson($this->apiUrl('/api/admin/identities?owner_id=1112&q=route-owner1112@example.com&per_page=50'));
        $ownerFiltered->assertStatus(200)->assertJson(['status' => 'success']);
        $ownerData = $ownerFiltered->json('identities.data');
        $this->assertCount(1, $ownerData);
        $this->assertEquals($pendingVenueId, $ownerData[0]['id']);
    }

    public function test_route_show_returns_identity_with_owner_and_members(): void
    {
        $identityId = $this->seedIdentity('pending', 'organizer', 1113, 'route-show-detail');
        $this->seedIdentityMember($identityId, 1114, 'manager');
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9110, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->getJson($this->apiUrl("/api/admin/identities/{$identityId}"));
        $response
            ->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $this->assertEquals($identityId, $response->json('identity.id'));
        $this->assertEquals(1113, $response->json('identity.owner.id'));
        $this->assertCount(1, $response->json('identity.members'));
        $this->assertEquals(1114, $response->json('identity.members.0.user_id'));
        $this->assertEquals(1114, $response->json('identity.members.0.user.id'));
    }

    public function test_route_show_returns_404_when_identity_does_not_exist(): void
    {
        $this->bindNotificationNoop();

        $roleId = $this->seedRole('Identity Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9111, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->getJson($this->apiUrl('/api/admin/identities/999999'));
        $response->assertStatus(404);
    }

    private function bindNotificationNoop(): void
    {
        $mock = Mockery::mock(IdentityModerationNotificationService::class);
        $mock->shouldReceive('notifyOwner')->zeroOrMoreTimes();
        $this->app->instance(IdentityModerationNotificationService::class, $mock);
    }

    private function bindNotificationExpectCalls(int $times): void
    {
        $mock = Mockery::mock(IdentityModerationNotificationService::class);
        $mock->shouldReceive('notifyOwner')->times($times);
        $this->app->instance(IdentityModerationNotificationService::class, $mock);
    }

    private function seedRole(string $name, array $permissions): int
    {
        return (int) DB::table('role_permissions')->insertGetId([
            'name' => $name,
            'permissions' => json_encode($permissions),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedAdmin(int $id, ?int $roleId): Admin
    {
        DB::table('admins')->insert([
            'id' => $id,
            'role_id' => $roleId,
            'first_name' => 'Admin',
            'last_name' => (string) $id,
            'username' => 'admin-' . $id,
            'email' => "admin{$id}@example.com",
            'password' => bcrypt('secret'),
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Admin::findOrFail($id);
    }

    private function seedIdentity(string $status, string $type, int $ownerId, string $slug): int
    {
        DB::table('users')->insert([
            'id' => $ownerId,
            'email' => "route-owner{$ownerId}@example.com",
            'username' => "owner-{$ownerId}",
            'first_name' => 'Owner',
            'last_name' => (string) $ownerId,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return (int) DB::table('identities')->insertGetId([
            'type' => $type,
            'status' => $status,
            'owner_user_id' => $ownerId,
            'display_name' => strtoupper($type) . ' ROUTE ' . $ownerId,
            'slug' => $slug,
            'meta' => json_encode([]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedIdentityMember(int $identityId, int $userId, string $role): void
    {
        DB::table('users')->insert([
            'id' => $userId,
            'email' => "member{$userId}@example.com",
            'username' => "member-{$userId}",
            'first_name' => 'Member',
            'last_name' => (string) $userId,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => $userId,
            'role' => $role,
            'permissions' => json_encode([]),
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
