<?php

namespace Tests\Feature\Api;

use App\Http\Controllers\Api\OrganizerController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use stdClass;
use Tests\TestCase;

class OrganizerProfileFormatterTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureSchema();
        DB::table('organizers')->delete();
        DB::table('tickets')->delete();
    }

    public function test_formatter_handles_event_without_tickets(): void
    {
        DB::table('organizers')->insert([
            'id' => 36,
            'username' => 'qa_launch_organizer',
            'status' => '1',
        ]);

        $event = new stdClass();
        $event->id = 9001;
        $event->date_type = 'single';
        $event->start_date = now()->addDays(7)->toDateString();
        $event->start_time = '20:00:00';
        $event->organizer_id = 36;
        $event->event_type = 'venue';
        $event->duration = '4h';
        $event->address = 'Santo Domingo';
        $event->thumbnail = 'missing-thumb.jpg';
        $event->slug = 'no-ticket-event';
        $event->title = 'No Ticket Event';

        $controller = app(OrganizerController::class);
        $method = new \ReflectionMethod($controller, 'formatEventForApi');
        $method->setAccessible(true);

        $formatted = $method->invoke($controller, $event, null);

        $this->assertSame(9001, $formatted['id']);
        $this->assertSame('qa_launch_organizer', $formatted['organizer']);
        $this->assertSame(0, $formatted['start_price']);
    }

    private function ensureSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('username')->nullable();
                $table->string('status')->default('1');
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 10, 2)->nullable();
                $table->decimal('f_price', 10, 2)->nullable();
            });
        }
    }
}
