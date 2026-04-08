<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\IdentityManagementController;
use App\Models\Admin;
use App\Models\Identity;
use App\Services\IdentityModerationNotificationService;
use App\Services\IdentityModerationTransitionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class IdentityManagementControllerTest extends ActorFeatureTestCase
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

    public function test_index_defaults_to_professional_identities_only(): void
    {
        $professionalId = $this->seedIdentity('artist', 'pending', 1201, 'artist-1201');
        $this->seedIdentity('personal', 'active', 1202, 'personal-1202');

        $controller = $this->buildControllerWithNotificationMock();
        $view = $controller->index(Request::create('/admin/identity-management/profiles', 'GET'));
        $data = $view->getData();
        $identities = $data['identities'];

        $this->assertSame(1, $identities->total());
        $this->assertSame($professionalId, optional($identities->first())->id);
        $this->assertFalse((bool) ($data['includePersonal'] ?? true));
        $this->assertSame(1, $data['metrics']['total']);
    }

    public function test_index_can_include_personal_identities_when_requested(): void
    {
        $this->seedIdentity('artist', 'pending', 1203, 'artist-1203');
        $personalId = $this->seedIdentity('personal', 'active', 1204, 'personal-1204');

        $controller = $this->buildControllerWithNotificationMock();
        $view = $controller->index(Request::create('/admin/identity-management/profiles', 'GET', [
            'include_personal' => 1,
            'type' => 'personal',
        ]));
        $data = $view->getData();
        $identities = $data['identities'];

        $this->assertSame(1, $identities->total());
        $this->assertSame($personalId, optional($identities->first())->id);
        $this->assertTrue((bool) ($data['includePersonal'] ?? false));
    }

    public function test_request_info_normalizes_comma_separated_fields_from_backend_form(): void
    {
        $identityId = $this->seedIdentity('organizer', 'pending', 1205, 'org-1205');

        $admin = new Admin();
        $admin->id = 9201;
        auth('admin')->setUser($admin);

        $controller = $this->buildControllerWithNotificationMock('request_info');
        $request = Request::create('/admin/identity-management/profiles/' . $identityId . '/request-info', 'POST', [
            'reason' => 'Please upload additional documents',
            'fields' => "legal_name, contact_email\ncountry;contact_email",
        ]);

        $response = $controller->requestInfo($request, $identityId);

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());

        $identity = Identity::findOrFail($identityId);
        $meta = is_array($identity->meta) ? $identity->meta : [];

        $this->assertSame('pending', $identity->status);
        $this->assertSame('Please upload additional documents', data_get($meta, 'revision_request.reason'));
        $this->assertEquals(
            ['legal_name', 'contact_email', 'country'],
            data_get($meta, 'revision_request.fields')
        );
        $this->assertArrayHasKey('moderation_history', $meta);
        $this->assertSame(
            ['legal_name', 'contact_email', 'country'],
            data_get($meta, 'moderation_history.0.details.fields')
        );
    }

    private function buildControllerWithNotificationMock(?string $expectedAction = null): IdentityManagementController
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

        return new IdentityManagementController(
            $notificationService,
            new IdentityModerationTransitionService()
        );
    }

    private function seedIdentity(string $type, string $status, int $ownerId, string $slug): int
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
