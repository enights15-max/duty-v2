<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\AdminIdentityController;
use App\Models\Admin;
use App\Models\Identity;
use App\Services\IdentityModerationNotificationService;
use App\Services\IdentityModerationTransitionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class AdminIdentityModerationApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function test_approve_pending_identity_changes_status_to_active(): void
    {
        $identityId = $this->seedIdentity('pending', 'artist', 1001, 'artist-pending-1');
        $controller = $this->buildControllerWithNotificationMock('approved');

        $request = $this->buildAdminRequest('POST', [
            'note' => 'verified docs',
        ]);

        $response = $controller->approve($request, $identityId);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('success', $payload['status']);

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('active', $identity->status);
        $this->assertArrayHasKey('approved_at', $meta);
        $this->assertEquals(9001, $meta['approved_by_admin_id']);
        $this->assertSame('approved', $meta['moderation_history'][0]['action']);
        $this->assertArrayHasKey('action_id', $meta['moderation_history'][0]);
    }

    public function test_approve_non_pending_identity_returns_error(): void
    {
        $identityId = $this->seedIdentity('active', 'artist', 1002, 'artist-active-1');
        $controller = $this->buildControllerWithNotificationMock();

        $request = $this->buildAdminRequest('POST');
        $response = $controller->approve($request, $identityId);
        $payload = $response->getData(true);

        $this->assertEquals(400, $response->getStatusCode());
        $this->assertEquals('error', $payload['status']);
        $this->assertStringContainsString('Only pending identities can be approved.', $payload['message']);
    }

    public function test_request_info_keeps_status_pending_and_stores_revision_request(): void
    {
        $identityId = $this->seedIdentity('pending', 'organizer', 1003, 'org-pending-1');
        $controller = $this->buildControllerWithNotificationMock('request_info');

        $request = $this->buildAdminRequest('POST', [
            'reason' => 'Upload legal representative document',
            'fields' => ['legal_name', 'contact_email'],
        ]);

        $response = $controller->requestInfo($request, $identityId);
        $payload = $response->getData(true);

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertEquals('success', $payload['status']);

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('pending', $identity->status);
        $this->assertSame('Upload legal representative document', data_get($meta, 'revision_request.reason'));
        $this->assertEquals(['legal_name', 'contact_email'], data_get($meta, 'revision_request.fields'));
        $this->assertArrayHasKey('action_id', $meta['moderation_history'][0]);
    }

    public function test_reject_requires_reason_validation(): void
    {
        $identityId = $this->seedIdentity('pending', 'venue', 1004, 'venue-pending-1');
        $controller = $this->buildControllerWithNotificationMock();

        $request = $this->buildAdminRequest('POST');
        $response = $controller->reject($request, $identityId);
        $payload = $response->getData(true);

        $this->assertEquals(422, $response->getStatusCode());
        $this->assertEquals('validation_error', $payload['status']);
        $this->assertArrayHasKey('errors', $payload);
    }

    public function test_suspend_then_reactivate_flow_updates_status_and_metadata(): void
    {
        $identityId = $this->seedIdentity('active', 'venue', 1005, 'venue-active-1');
        $controller = $this->buildControllerWithNotificationMock();

        $suspendRequest = $this->buildAdminRequest('POST', [
            'reason' => 'Policy violation',
        ]);
        $suspendResponse = $controller->suspend($suspendRequest, $identityId);
        $suspendPayload = $suspendResponse->getData(true);

        $this->assertEquals(200, $suspendResponse->getStatusCode());
        $this->assertEquals('success', $suspendPayload['status']);

        $suspended = Identity::findOrFail($identityId);
        $suspendedMeta = is_array($suspended->meta) ? $suspended->meta : [];
        $this->assertSame('suspended', $suspended->status);
        $this->assertSame('Policy violation', $suspendedMeta['suspension_reason']);
        $this->assertArrayHasKey('action_id', $suspendedMeta['moderation_history'][0]);

        $reactivateRequest = $this->buildAdminRequest('POST', [
            'note' => 'Issue resolved',
        ]);
        $reactivateResponse = $controller->reactivate($reactivateRequest, $identityId);
        $reactivatePayload = $reactivateResponse->getData(true);

        $this->assertEquals(200, $reactivateResponse->getStatusCode());
        $this->assertEquals('success', $reactivatePayload['status']);

        $reactivated = Identity::findOrFail($identityId);
        $reactivatedMeta = is_array($reactivated->meta) ? $reactivated->meta : [];
        $this->assertSame('active', $reactivated->status);
        $this->assertArrayHasKey('reactivated_at', $reactivatedMeta);
        $this->assertArrayHasKey('action_id', $reactivatedMeta['moderation_history'][1]);
    }

    private function buildControllerWithNotificationMock(?string $expectedAction = null): AdminIdentityController
    {
        $notificationService = Mockery::mock(IdentityModerationNotificationService::class);

        if ($expectedAction !== null) {
            $notificationService
                ->shouldReceive('notifyOwner')
                ->once()
                ->withArgs(function ($identity, $action) use ($expectedAction) {
                    return $identity instanceof Identity && $action === $expectedAction;
                });
        } else {
            $notificationService->shouldReceive('notifyOwner')->zeroOrMoreTimes();
        }

        return new AdminIdentityController(
            $notificationService,
            new IdentityModerationTransitionService()
        );
    }

    private function buildAdminRequest(string $method, array $payload = []): Request
    {
        $request = Request::create('/api/admin/identities/test', $method, $payload);
        $admin = new Admin();
        $admin->id = 9001;
        $admin->role_id = null;

        $request->setUserResolver(fn () => $admin);

        return $request;
    }

    private function seedIdentity(string $status, string $type, int $ownerId, string $slug): int
    {
        DB::table('users')->insert([
            'id' => $ownerId,
            'email' => "owner{$ownerId}@example.com",
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return (int) DB::table('identities')->insertGetId([
            'type' => $type,
            'status' => $status,
            'owner_user_id' => $ownerId,
            'display_name' => strtoupper($type) . ' ' . $ownerId,
            'slug' => $slug,
            'meta' => json_encode([]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
