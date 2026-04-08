<?php

namespace Tests\Feature\Api;

use App\Models\Admin;
use App\Models\Review;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class AdminReviewModerationRouteTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'admins_permissions', 'subscriptions'];
    protected array $baselineTruncate = [
        'admins',
        'role_permissions',
        'subscriptions',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureReviewSchema();
        $this->truncateTables([
            'reviews',
            'bookings',
            'event_contents',
            'events',
            'organizer_infos',
            'organizers',
            'artists',
            'customers',
            'users',
            'admins',
            'role_permissions',
            'subscriptions',
        ]);
    }

    public function test_route_requires_admin_authentication(): void
    {
        $reviewId = $this->seedModeratedReview(7101, 'pending_moderation');

        $response = $this->postJson($this->apiUrl("/api/admin/reviews/{$reviewId}/publish"), [
            'note' => 'ok',
        ]);

        $response->assertStatus(401);
    }

    public function test_route_blocks_admin_without_required_permission(): void
    {
        $reviewId = $this->seedModeratedReview(7102, 'pending_moderation');
        $roleId = $this->seedRole('ReadOnly Admin', ['Event Management']);
        $admin = $this->seedAdmin(9201, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/reviews/{$reviewId}/publish"), [
            'note' => 'attempt',
        ]);

        $response
            ->assertStatus(403)
            ->assertJson([
                'status' => 'error',
                'message' => 'Forbidden.',
            ]);
    }

    public function test_route_index_returns_pending_queue_and_metrics(): void
    {
        $pendingId = $this->seedModeratedReview(7103, 'pending_moderation');
        $this->seedModeratedReview(7104, 'published');
        $roleId = $this->seedRole('Review Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9202, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->getJson($this->apiUrl('/api/admin/reviews?status=pending_moderation&per_page=10'));

        $response->assertStatus(200)->assertJson(['status' => 'success']);
        $this->assertCount(1, $response->json('reviews.data'));
        $this->assertEquals($pendingId, $response->json('reviews.data.0.id'));
        $this->assertEquals(2, $response->json('metrics.total'));
        $this->assertEquals(1, $response->json('metrics.published'));
    }

    public function test_route_publish_updates_status_with_permission(): void
    {
        $reviewId = $this->seedModeratedReview(7105, 'pending_moderation');
        $roleId = $this->seedRole('Review Moderator', ['Customer Management']);
        $admin = $this->seedAdmin(9203, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/reviews/{$reviewId}/publish"), [
            'note' => 'Approved by admin',
        ]);

        $response->assertStatus(200)->assertJson(['status' => 'success']);

        $review = Review::findOrFail($reviewId);
        $meta = is_array($review->meta) ? $review->meta : [];

        $this->assertSame('published', $review->status);
        $this->assertSame(9203, data_get($meta, 'published_by_admin_id'));
        $this->assertSame('Approved by admin', data_get($meta, 'moderation_history.0.details.note'));
    }

    public function test_route_reject_requires_reason_validation(): void
    {
        $reviewId = $this->seedModeratedReview(7106, 'pending_moderation');
        $roleId = $this->seedRole('Review Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9204, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->postJson($this->apiUrl("/api/admin/reviews/{$reviewId}/reject"), []);

        $response->assertStatus(422)->assertJson(['status' => 'validation_error']);
    }

    public function test_route_show_returns_review_detail(): void
    {
        $reviewId = $this->seedModeratedReview(7107, 'hidden');
        $roleId = $this->seedRole('Review Moderator', ['Identity Management']);
        $admin = $this->seedAdmin(9205, $roleId);
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $response = $this->getJson($this->apiUrl("/api/admin/reviews/{$reviewId}"));

        $response->assertStatus(200)->assertJson(['status' => 'success']);
        $this->assertEquals($reviewId, $response->json('review.id'));
        $this->assertEquals('hidden', $response->json('review.status'));
        $this->assertEquals('Completed', $response->json('review.booking.paymentStatus'));
    }

    private function ensureReviewSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('photo')->nullable();
                $table->string('email')->nullable();
                $table->string('username')->nullable();
                $table->string('password')->nullable();
                $table->integer('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('organizer_infos')) {
            Schema::create('organizer_infos', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('photo')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->date('start_date')->nullable();
                $table->time('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->time('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('organizer_identity_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->string('scan_status')->nullable();
                $table->timestamps();
            });
        }

        if (Schema::hasTable('events') && !Schema::hasColumn('events', 'owner_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('owner_identity_id')->nullable()->after('organizer_id');
            });
        }

        if (Schema::hasTable('bookings') && !Schema::hasColumn('bookings', 'organizer_identity_id')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->unsignedBigInteger('organizer_identity_id')->nullable()->after('organizer_id');
            });
        }

        if (!Schema::hasTable('reviews')) {
            Schema::create('reviews', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('reviewable_id');
                $table->string('reviewable_type');
                $table->tinyInteger('rating');
                $table->text('comment')->nullable();
                $table->string('status')->default('published');
                $table->json('meta')->nullable();
                $table->timestamp('submitted_at')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedModeratedReview(int $customerId, string $status): int
    {
        $organizerId = (int) DB::table('organizers')->insertGetId([
            'email' => "org{$customerId}@example.com",
            'username' => "org-{$customerId}",
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizer_infos')->insert([
            'organizer_id' => $organizerId,
            'name' => 'Organizer ' . $customerId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => $organizerId,
            'thumbnail' => 'event.jpg',
            'start_date' => now()->subDays(2)->toDateString(),
            'start_time' => '20:00:00',
            'end_date' => now()->subDay()->toDateString(),
            'end_time' => '23:00:00',
            'end_date_time' => now()->subDay()->toDateTimeString(),
            'event_type' => 'venue',
            'date_type' => 'single',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'title' => 'Moderation Event ' . $customerId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => $customerId,
            'email' => "moderation-customer{$customerId}@example.com",
            'username' => "moderation-customer-{$customerId}",
            'first_name' => 'Review',
            'last_name' => (string) $customerId,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $customerId,
            'fname' => 'Review',
            'lname' => (string) $customerId,
            'email' => "moderation-customer{$customerId}@example.com",
            'username' => "moderation-customer-{$customerId}",
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $bookingId = (int) DB::table('bookings')->insertGetId([
            'customer_id' => $customerId,
            'event_id' => $eventId,
            'organizer_id' => $organizerId,
            'paymentStatus' => 'Completed',
            'scan_status' => 'verified',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return (int) DB::table('reviews')->insertGetId([
            'customer_id' => $customerId,
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'reviewable_type' => \App\Models\Organizer::class,
            'reviewable_id' => $organizerId,
            'rating' => 4,
            'comment' => 'Review content ' . $customerId,
            'status' => $status,
            'meta' => json_encode([
                'target_type' => 'organizer',
                'event_snapshot' => ['id' => $eventId, 'title' => 'Moderation Event ' . $customerId],
                'target_snapshot' => ['name' => 'Organizer ' . $customerId],
            ]),
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
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

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
