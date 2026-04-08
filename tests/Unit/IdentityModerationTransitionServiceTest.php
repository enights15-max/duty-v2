<?php

namespace Tests\Unit;

use App\Models\Identity;
use App\Services\IdentityModerationTransitionService;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;
use RuntimeException;

class IdentityModerationTransitionServiceTest extends TestCase
{
  public function test_pending_identity_can_be_approved_and_history_is_recorded(): void
  {
    $service = new IdentityModerationTransitionService();
    $identity = new Identity([
      'type' => 'artist',
      'status' => 'pending',
      'display_name' => 'DJ Test',
      'meta' => [
        'rejection_reason' => 'old reason',
        'revision_request' => ['reason' => 'old request'],
      ],
    ]);

    $context = $service->apply($identity, 'approve', 11, ['note' => 'all good']);
    $meta = is_array($identity->meta) ? $identity->meta : [];

    $this->assertSame('active', $identity->status);
    $this->assertSame('all good', $context['note']);
    $this->assertArrayHasKey('action_id', $context);
    $this->assertArrayHasKey('approved_at', $meta);
    $this->assertSame(11, $meta['approved_by_admin_id']);
    $this->assertArrayNotHasKey('rejection_reason', $meta);
    $this->assertArrayNotHasKey('revision_request', $meta);
    $this->assertSame('approved', $meta['moderation_history'][0]['action']);
    $this->assertArrayHasKey('action_id', $meta['moderation_history'][0]);
  }

  public function test_request_info_keeps_status_pending_and_stores_fields(): void
  {
    $service = new IdentityModerationTransitionService();
    $identity = new Identity([
      'type' => 'venue',
      'status' => 'pending',
      'display_name' => 'Venue A',
      'meta' => [],
    ]);

    $context = $service->apply($identity, 'request_info', 19, [
      'reason' => 'Please upload legal docs',
      'fields' => ['legal_name', 'contact_email'],
    ]);
    $meta = is_array($identity->meta) ? $identity->meta : [];

    $this->assertSame('pending', $identity->status);
    $this->assertSame('Please upload legal docs', $context['reason']);
    $this->assertSame(['legal_name', 'contact_email'], $context['fields']);
    $this->assertArrayHasKey('action_id', $context);
    $this->assertSame('Please upload legal docs', $meta['revision_request']['reason']);
    $this->assertSame(['legal_name', 'contact_email'], $meta['revision_request']['fields']);
    $this->assertSame('request_info', $meta['moderation_history'][0]['action']);
    $this->assertArrayHasKey('action_id', $meta['moderation_history'][0]);
  }

  public function test_invalid_transition_throws_runtime_exception(): void
  {
    $this->expectException(RuntimeException::class);
    $this->expectExceptionMessage('Only pending identities can be approved.');

    $service = new IdentityModerationTransitionService();
    $identity = new Identity([
      'type' => 'artist',
      'status' => 'active',
      'display_name' => 'DJ Active',
      'meta' => [],
    ]);

    $service->apply($identity, 'approve', 1, []);
  }

  public function test_reject_requires_reason(): void
  {
    $this->expectException(InvalidArgumentException::class);
    $this->expectExceptionMessage('Reject reason is required.');

    $service = new IdentityModerationTransitionService();
    $identity = new Identity([
      'type' => 'organizer',
      'status' => 'pending',
      'display_name' => 'Org Test',
      'meta' => [],
    ]);

    $service->apply($identity, 'reject', 2, []);
  }
}
