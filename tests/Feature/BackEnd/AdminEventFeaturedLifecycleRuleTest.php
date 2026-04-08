<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Event\EventController;
use App\Models\Event;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class AdminEventFeaturedLifecycleRuleTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureEventSchema();
        Schema::disableForeignKeyConstraints();
        Event::query()->delete();
        Schema::enableForeignKeyConstraints();
        $this->startSession();
    }

    public function test_expired_event_cannot_be_marked_featured(): void
    {
        $event = Event::query()->create([
            'event_type' => 'venue',
            'date_type' => 'single',
            'end_date_time' => now()->subDay(),
            'is_featured' => 'no',
            'status' => 1,
        ]);

        $response = app(EventController::class)->updateFeatured(
            Request::create("/admin/event/{$event->id}/update-featured", 'POST', ['is_featured' => 'yes']),
            $event->id
        );

        $this->assertTrue($response->isRedirection());
        $this->assertSame('no', $event->fresh()->is_featured);
    }

    public function test_current_event_can_be_marked_featured(): void
    {
        $event = Event::query()->create([
            'event_type' => 'venue',
            'date_type' => 'single',
            'end_date_time' => now()->addDay(),
            'is_featured' => 'no',
            'status' => 1,
        ]);

        $response = app(EventController::class)->updateFeatured(
            Request::create("/admin/event/{$event->id}/update-featured", 'POST', ['is_featured' => 'yes']),
            $event->id
        );

        $this->assertTrue($response->isRedirection());
        $this->assertSame('yes', $event->fresh()->is_featured);
    }

    private function ensureEventSchema(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->string('event_type')->nullable();
                $table->string('date_type')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('is_featured')->nullable();
                $table->tinyInteger('status')->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_dates')) {
            Schema::create('event_dates', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }
    }
}
