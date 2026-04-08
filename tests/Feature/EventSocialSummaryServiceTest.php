<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Event;
use App\Services\EventSocialSummaryService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class EventSocialSummaryServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'follows'];
    protected array $baselineTruncate = ['follows', 'customers', 'users'];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureEventsTables();
        $this->truncateTables(['bookings', 'wishlists', 'events']);
    }

    public function test_build_filters_people_by_privacy_and_follow_rules(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 920,
                'email' => 'viewer-social@example.com',
                'username' => 'viewer-social',
                'is_private' => 0,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 921,
                'email' => 'public-interest@example.com',
                'username' => 'public-interest',
                'is_private' => 0,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 922,
                'email' => 'private-hidden@example.com',
                'username' => 'private-hidden',
                'is_private' => 1,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 923,
                'email' => 'private-followed@example.com',
                'username' => 'private-followed',
                'is_private' => 1,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('follows')->insert([
            'follower_id' => 920,
            'follower_type' => Customer::class,
            'followable_id' => 923,
            'followable_type' => Customer::class,
            'status' => 'accepted',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 3200,
            'status' => 1,
            'start_date' => now()->addDays(14)->toDateString(),
            'end_date_time' => now()->addDays(14)->toDateTimeString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('wishlists')->insert([
            ['customer_id' => 921, 'event_id' => 3200, 'created_at' => now(), 'updated_at' => now()],
            ['customer_id' => 922, 'event_id' => 3200, 'created_at' => now(), 'updated_at' => now()],
            ['customer_id' => 923, 'event_id' => 3200, 'created_at' => now(), 'updated_at' => now()],
        ]);

        DB::table('bookings')->insert([
            ['customer_id' => 921, 'event_id' => 3200, 'paymentStatus' => 'completed', 'created_at' => now(), 'updated_at' => now()],
            ['customer_id' => 922, 'event_id' => 3200, 'paymentStatus' => 'completed', 'created_at' => now(), 'updated_at' => now()],
            ['customer_id' => 923, 'event_id' => 3200, 'paymentStatus' => 'completed', 'created_at' => now(), 'updated_at' => now()],
        ]);

        $viewer = Customer::findOrFail(920);
        $event = Event::findOrFail(3200);

        $payload = app(EventSocialSummaryService::class)->build($event, $viewer);

        $interestedIds = array_column($payload['interested_people'], 'id');
        $attendingIds = array_column($payload['attending_people'], 'id');
        $followedInterestedIds = array_column($payload['followed_interested_people'], 'id');

        $this->assertSame(3, $payload['interested_count']);
        $this->assertSame(3, $payload['attending_count']);
        $this->assertSame([921, 923], $interestedIds);
        $this->assertSame([921, 923], $attendingIds);
        $this->assertSame([923], $followedInterestedIds);
    }

    private function ensureEventsTables(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('wishlists')) {
            Schema::create('wishlists', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('event_id');
                $table->timestamps();
            });
        }
    }
}
