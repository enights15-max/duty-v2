<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\ReviewManagementController;
use App\Models\Admin;
use App\Models\Review;
use App\Services\ReviewModerationTransitionService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ReviewManagementControllerTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = [];

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
        ]);
    }

    public function test_index_defaults_to_pending_moderation_queue(): void
    {
        $organizerId = $this->seedOrganizer('Moderation Queue Org');
        $eventId = $this->seedEvent($organizerId, 'Pending Moderation Event');
        $this->seedReview(7001, $eventId, $organizerId, 'pending_moderation', 'Pending comment for moderation.');
        $this->seedReview(7002, $eventId, $organizerId, 'published', 'Already published.');

        $controller = new ReviewManagementController(new ReviewModerationTransitionService());
        $view = $controller->index(Request::create('/admin/review-management/reviews', 'GET'));
        $data = $view->getData();
        $reviews = $data['reviews'];

        $this->assertSame(1, $reviews->total());
        $this->assertSame('pending_moderation', optional($reviews->first())->status);
        $this->assertSame(2, $data['metrics']['total']);
        $this->assertSame(1, $data['metrics']['published']);
    }

    public function test_publish_updates_status_and_history(): void
    {
        $organizerId = $this->seedOrganizer('Review Publish Org');
        $eventId = $this->seedEvent($organizerId, 'Review Publish Event');
        $reviewId = $this->seedReview(7003, $eventId, $organizerId, 'pending_moderation', 'Needs approval.');

        $admin = new Admin();
        $admin->id = 9901;
        auth('admin')->setUser($admin);

        $controller = new ReviewManagementController(new ReviewModerationTransitionService());
        $response = $controller->publish(
            Request::create('/admin/review-management/reviews/' . $reviewId . '/publish', 'POST', ['note' => 'Looks valid']),
            $reviewId
        );

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());

        $review = Review::findOrFail($reviewId);
        $meta = is_array($review->meta) ? $review->meta : [];

        $this->assertSame('published', $review->status);
        $this->assertSame('publish', data_get($meta, 'moderation.last_action'));
        $this->assertSame(9901, data_get($meta, 'moderation.last_action_by_admin_id'));
        $this->assertSame('Looks valid', data_get($meta, 'moderation_history.0.details.note'));
    }

    public function test_reject_requires_reason_and_persists_audit_trail(): void
    {
        $organizerId = $this->seedOrganizer('Review Reject Org');
        $eventId = $this->seedEvent($organizerId, 'Review Reject Event');
        $reviewId = $this->seedReview(7004, $eventId, $organizerId, 'pending_moderation', 'Spam content.');

        $admin = new Admin();
        $admin->id = 9902;
        auth('admin')->setUser($admin);

        $controller = new ReviewManagementController(new ReviewModerationTransitionService());
        $response = $controller->reject(
            Request::create('/admin/review-management/reviews/' . $reviewId . '/reject', 'POST', ['reason' => 'Contains spam links']),
            $reviewId
        );

        $this->assertTrue(method_exists($response, 'isRedirect') && $response->isRedirect());

        $review = Review::findOrFail($reviewId);
        $meta = is_array($review->meta) ? $review->meta : [];

        $this->assertSame('rejected', $review->status);
        $this->assertSame('Contains spam links', data_get($meta, 'rejection_reason'));
        $this->assertSame(9902, data_get($meta, 'rejected_by_admin_id'));
        $this->assertSame('reject', data_get($meta, 'moderation_history.0.action'));
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

    private function seedOrganizer(string $name): int
    {
        $organizerId = (int) DB::table('organizers')->insertGetId([
            'email' => strtolower(str_replace(' ', '', $name)) . '@example.com',
            'username' => strtolower(str_replace(' ', '-', $name)),
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizer_infos')->insert([
            'organizer_id' => $organizerId,
            'name' => $name,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $organizerId;
    }

    private function seedEvent(int $organizerId, string $title): int
    {
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
            'title' => $title,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function seedReview(int $customerId, int $eventId, int $organizerId, string $status, string $comment): int
    {
        DB::table('users')->insert([
            'id' => $customerId,
            'email' => "review-customer{$customerId}@example.com",
            'username' => "review-customer-{$customerId}",
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
            'email' => "review-customer{$customerId}@example.com",
            'username' => "review-customer-{$customerId}",
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
            'comment' => $comment,
            'status' => $status,
            'meta' => json_encode([
                'target_type' => 'organizer',
                'event_snapshot' => ['id' => $eventId, 'title' => 'Seed Event'],
                'target_snapshot' => ['name' => 'Seed Organizer'],
            ]),
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
