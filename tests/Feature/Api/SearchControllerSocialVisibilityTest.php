<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\SearchController;
use App\Models\Customer;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class SearchControllerSocialVisibilityTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'follows'];
    protected array $baselineTruncate = ['follows', 'customers', 'users'];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureEventsTables();
        $this->truncateTables(['bookings', 'wishlists', 'event_contents', 'events']);
    }

    public function test_user_profile_exposes_activity_visibility_payload(): void
    {
        DB::table('customers')->insert([
            'id' => 910,
            'email' => 'public-social@example.com',
            'username' => 'public-social',
            'show_interested_events' => 1,
            'show_attended_events' => 0,
            'show_upcoming_attendance' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = app(SearchController::class)->userProfile(910);
        $payload = $response->getData(true);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertTrue($payload['data']['can_view_activity']);
        $this->assertTrue($payload['data']['activity_visibility']['interested']);
        $this->assertFalse($payload['data']['activity_visibility']['attended']);
        $this->assertTrue($payload['data']['activity_visibility']['upcoming']);
    }

    public function test_upcoming_attendance_requires_activity_visibility_even_for_followers(): void
    {
        DB::table('customers')->insert([
            [
                'id' => 911,
                'email' => 'viewer@example.com',
                'username' => 'viewer',
                'is_private' => 0,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 912,
                'email' => 'private-target@example.com',
                'username' => 'private-target',
                'is_private' => 1,
                'show_interested_events' => 1,
                'show_attended_events' => 1,
                'show_upcoming_attendance' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('follows')->insert([
            'follower_id' => 911,
            'follower_type' => Customer::class,
            'followable_id' => 912,
            'followable_type' => Customer::class,
            'status' => 'accepted',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 3001,
            'status' => 1,
            'start_date' => now()->addDays(10)->toDateString(),
            'end_date_time' => now()->addDays(10)->toDateTimeString(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 3001,
            'title' => 'Hidden Going Event',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('bookings')->insert([
            'id' => 7001,
            'customer_id' => 912,
            'event_id' => 3001,
            'paymentStatus' => 'completed',
            'price' => 100,
            'tax' => 0,
            'discount' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(911), [], 'sanctum');

        $hiddenResponse = app(SearchController::class)->userUpcomingAttendance(912);
        $this->assertSame(403, $hiddenResponse->getStatusCode());

        DB::table('customers')->where('id', 912)->update([
            'show_upcoming_attendance' => 1,
            'updated_at' => now(),
        ]);

        $visibleResponse = app(SearchController::class)->userUpcomingAttendance(912);
        $payload = $visibleResponse->getData(true);

        $this->assertSame(200, $visibleResponse->getStatusCode());
        $this->assertTrue($payload['success']);
        $this->assertCount(1, $payload['data']);
        $this->assertSame('Hidden Going Event', $payload['data'][0]['title']);
    }

    private function ensureEventsTables(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->string('thumbnail')->nullable();
                $table->date('start_date')->nullable();
                $table->dateTime('end_date_time')->nullable();
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
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('paymentStatus')->nullable();
                $table->integer('scan_status')->default(0);
                $table->decimal('price', 10, 2)->default(0);
                $table->decimal('tax', 10, 2)->default(0);
                $table->decimal('discount', 10, 2)->default(0);
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
