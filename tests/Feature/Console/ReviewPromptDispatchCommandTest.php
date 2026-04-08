<?php

namespace Tests\Feature\Console;

use App\Jobs\SendReviewPromptNotificationJob;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ReviewPromptDispatchCommandTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = [];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureReviewPromptSchema();
        $this->truncateTables([
            'review_prompt_deliveries',
            'reviews',
            'bookings',
            'event_lineups',
            'event_contents',
            'events',
            'organizer_infos',
            'organizers',
            'artists',
            'customers',
            'users',
        ]);
    }

    public function test_command_creates_prompt_delivery_and_dispatches_job_once(): void
    {
        Queue::fake();

        $organizerId = $this->seedOrganizer('Prompt Org');
        $eventId = $this->seedEvent($organizerId, 'Prompt Event');
        $this->seedCustomer(801);
        $this->seedBooking(801, $eventId, $organizerId);

        $this->artisan('reviews:dispatch-prompts')
            ->expectsOutput('Review prompt dispatch completed.')
            ->assertExitCode(0);

        $this->assertDatabaseHas('review_prompt_deliveries', [
            'customer_id' => 801,
            'event_id' => $eventId,
            'status' => 'queued',
        ]);

        Queue::assertPushed(SendReviewPromptNotificationJob::class, 1);

        $this->artisan('reviews:dispatch-prompts')->assertExitCode(0);
        $this->assertSame(1, DB::table('review_prompt_deliveries')->count());
    }

    public function test_command_skips_events_without_pending_targets(): void
    {
        Queue::fake();

        $organizerId = $this->seedOrganizer('Reviewed Org');
        $eventId = $this->seedEvent($organizerId, 'Reviewed Event');
        $bookingId = $this->seedBooking(802, $eventId, $organizerId);
        $this->seedCustomer(802);
        $this->seedReview(802, $bookingId, $eventId, \App\Models\Event::class, $eventId);
        $this->seedReview(802, $bookingId, $eventId, \App\Models\Organizer::class, $organizerId);

        $this->artisan('reviews:dispatch-prompts')->assertExitCode(0);

        $this->assertSame(0, DB::table('review_prompt_deliveries')->count());
        Queue::assertNothingPushed();
    }

    public function test_command_retries_stale_failed_delivery(): void
    {
        Queue::fake();

        $organizerId = $this->seedOrganizer('Retry Org');
        $eventId = $this->seedEvent($organizerId, 'Retry Event');
        $this->seedCustomer(803);
        $bookingId = $this->seedBooking(803, $eventId, $organizerId);

        DB::table('review_prompt_deliveries')->insert([
            'customer_id' => 803,
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'status' => 'no_device_token',
            'dispatched_at' => now()->subHours(8),
            'created_at' => now()->subHours(8),
            'updated_at' => now()->subHours(8),
            'meta' => json_encode([
                'dispatch_attempts' => 1,
            ]),
        ]);

        $this->artisan('reviews:dispatch-prompts')
            ->expectsOutput('Retried deliveries: 1')
            ->assertExitCode(0);

        $this->assertDatabaseHas('review_prompt_deliveries', [
            'customer_id' => 803,
            'event_id' => $eventId,
            'status' => 'queued',
        ]);

        $meta = DB::table('review_prompt_deliveries')
            ->where('customer_id', 803)
            ->where('event_id', $eventId)
            ->value('meta');
        $decoded = json_decode((string) $meta, true);

        $this->assertSame(2, (int) ($decoded['dispatch_attempts'] ?? 0));
        Queue::assertPushed(SendReviewPromptNotificationJob::class, 1);
    }

    public function test_command_does_not_retry_recent_or_delivered_prompt(): void
    {
        Queue::fake();

        $organizerId = $this->seedOrganizer('Delivered Org');
        $eventId = $this->seedEvent($organizerId, 'Delivered Event');
        $bookingId = $this->seedBooking(804, $eventId, $organizerId);
        $this->seedCustomer(804);
        $recentEventId = $this->seedEvent($organizerId, 'Recent Queue Event');
        $recentBookingId = $this->seedBooking(805, $recentEventId, $organizerId);
        $this->seedCustomer(805);

        DB::table('review_prompt_deliveries')->insert([
            [
                'customer_id' => 804,
                'booking_id' => $bookingId,
                'event_id' => $eventId,
                'status' => 'delivered',
                'dispatched_at' => now()->subHours(10),
                'delivered_at' => now()->subHours(10),
                'created_at' => now()->subHours(10),
                'updated_at' => now()->subHours(10),
            ],
            [
                'customer_id' => 805,
                'booking_id' => $recentBookingId,
                'event_id' => $recentEventId,
                'status' => 'queued',
                'dispatched_at' => now()->subMinutes(30),
                'delivered_at' => null,
                'created_at' => now()->subMinutes(30),
                'updated_at' => now()->subMinutes(30),
            ],
        ]);

        $this->artisan('reviews:dispatch-prompts')
            ->expectsOutput('Retried deliveries: 0')
            ->assertExitCode(0);

        Queue::assertNothingPushed();
        $this->assertSame(2, DB::table('review_prompt_deliveries')->count());
    }

    private function ensureReviewPromptSchema(): void
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
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_lineups')) {
            Schema::create('event_lineups', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id')->nullable();
                $table->string('source_type')->nullable();
                $table->string('display_name')->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_headliner')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
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
                $table->unique(
                    ['customer_id', 'event_id', 'reviewable_type', 'reviewable_id'],
                    'reviews_customer_event_target_unique'
                );
            });
        }

        if (!Schema::hasTable('review_prompt_deliveries')) {
            Schema::create('review_prompt_deliveries', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id');
                $table->string('status')->default('queued');
                $table->timestamp('dispatched_at')->nullable();
                $table->timestamp('delivered_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->unique(['customer_id', 'event_id'], 'review_prompt_deliveries_customer_event_unique');
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
            'language_id' => 1,
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
            'language_id' => 1,
            'title' => $title,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $eventId;
    }

    private function seedCustomer(int $id): void
    {
        DB::table('users')->insert([
            'id' => $id,
            'email' => "prompt{$id}@example.com",
            'username' => "prompt-{$id}",
            'first_name' => 'Prompt',
            'last_name' => (string) $id,
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $id,
            'fname' => 'Prompt',
            'lname' => (string) $id,
            'email' => "prompt{$id}@example.com",
            'username' => "prompt-{$id}",
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedBooking(int $customerId, int $eventId, int $organizerId): int
    {
        return (int) DB::table('bookings')->insertGetId([
            'customer_id' => $customerId,
            'event_id' => $eventId,
            'organizer_id' => $organizerId,
            'paymentStatus' => 'Completed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedReview(int $customerId, int $bookingId, int $eventId, string $reviewableType, int $reviewableId): void
    {
        DB::table('reviews')->insert([
            'customer_id' => $customerId,
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'reviewable_type' => $reviewableType,
            'reviewable_id' => $reviewableId,
            'rating' => 5,
            'comment' => 'Already reviewed',
            'status' => 'published',
            'meta' => json_encode([]),
            'submitted_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
