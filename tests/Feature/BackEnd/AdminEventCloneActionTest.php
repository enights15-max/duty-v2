<?php

namespace Tests\Feature\BackEnd;

use App\Http\Controllers\BackEnd\Event\EventController;
use App\Models\Event;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class AdminEventCloneActionTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['admins_permissions'];
    protected array $baselineTruncate = [
        'admins',
        'role_permissions',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureCloneSchema();
        $this->truncateTables([
            'event_artist',
            'slot_seats',
            'slot_images',
            'slots',
            'ticket_price_schedules',
            'variation_contents',
            'ticket_contents',
            'tickets',
            'event_lineups',
            'event_dates',
            'event_images',
            'event_contents',
            'events',
            'artists',
        ]);
        $this->seedCloneAssets();
    }

    protected function tearDown(): void
    {
        $this->cleanupCloneAssets();

        parent::tearDown();
    }

    public function test_admin_can_clone_event_from_list_and_new_draft_keeps_related_data(): void
    {
        $artistId = (int) DB::table('artists')->insertGetId([
            'name' => 'Clone Artist',
            'username' => 'clone-artist',
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $sourceEventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 12,
            'venue_id' => 4,
            'venue_source' => 'registered',
            'thumbnail' => 'clone-test-thumb.jpg',
            'status' => 1,
            'countdown_status' => 1,
            'date_type' => 'multiple',
            'start_date' => '2026-05-12',
            'start_time' => '20:00:00',
            'duration' => '2h 30m',
            'end_date' => '2026-05-12',
            'end_time' => '22:30:00',
            'end_date_time' => '2026-05-13 00:30:00',
            'is_featured' => 'yes',
            'event_type' => 'venue',
            'latitude' => '18.4861',
            'longitude' => '-69.9312',
            'ticket_image' => 'clone-test-ticket-image.jpg',
            'ticket_logo' => 'clone-test-ticket-logo.jpg',
            'ticket_slot_image' => 'clone-test-ticket-slot.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $sourceEventId,
            'language_id' => 1,
            'event_category_id' => 9,
            'title' => 'Clone Source Event',
            'slug' => 'clone-source-event',
            'description' => 'Source description for clone flow.',
            'refund_policy' => 'No refunds.',
            'meta_keywords' => 'clone,source',
            'meta_description' => 'Clone source meta description.',
            'google_calendar_id' => 'google-cal-1',
            'address' => 'Street 1',
            'country' => 'Dominican Republic',
            'state' => 'Distrito Nacional',
            'city' => 'Santo Domingo',
            'zip_code' => '10101',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_images')->insert([
            'event_id' => $sourceEventId,
            'image' => 'clone-test-gallery.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_dates')->insert([
            'event_id' => $sourceEventId,
            'start_date' => '2026-05-12',
            'start_time' => '20:00:00',
            'end_date' => '2026-05-12',
            'end_time' => '23:30:00',
            'duration' => '3h 30m',
            'start_date_time' => '2026-05-12 20:00:00',
            'end_date_time' => '2026-05-12 23:30:00',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_artist')->insert([
            'event_id' => $sourceEventId,
            'artist_id' => $artistId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_lineups')->insert([
            [
                'event_id' => $sourceEventId,
                'artist_id' => $artistId,
                'source_type' => 'artist',
                'display_name' => 'Clone Artist',
                'sort_order' => 1,
                'is_headliner' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => $sourceEventId,
                'artist_id' => null,
                'source_type' => 'manual',
                'display_name' => 'Manual Guest',
                'sort_order' => 2,
                'is_headliner' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $sourceVariations = json_encode([
            [
                'name' => 'VIP',
                'price' => 1500,
                'ticket_available_type' => 'limited',
                'ticket_available' => 50,
                'max_ticket_buy_type' => 'limited',
                'v_max_ticket_buy' => 4,
                'slot_enable' => 1,
                'slot_unique_id' => 910001,
                'slot_seat_min_price' => 200,
            ],
        ]);

        $sourceTicketId = (int) DB::table('tickets')->insertGetId([
            'event_id' => $sourceEventId,
            'event_type' => 'venue',
            'title' => 'Main ticket',
            'ticket_available_type' => 'limited',
            'ticket_available' => 120,
            'max_ticket_buy_type' => 'limited',
            'max_buy_ticket' => 6,
            'description' => 'Source ticket description.',
            'pricing_type' => 'variation',
            'price' => 0,
            'f_price' => 1500,
            'early_bird_discount_type' => 'disable',
            'early_bird_discount' => 'disable',
            'normal_ticket_slot_enable' => 1,
            'normal_ticket_slot_unique_id' => 810001,
            'free_tickete_slot_enable' => 0,
            'free_tickete_slot_unique_id' => 820001,
            'slot_seat_min_price' => 0,
            'reservation_enabled' => 1,
            'reservation_deposit_type' => 'percentage',
            'reservation_deposit_value' => 20,
            'reservation_final_due_date' => '2026-05-01',
            'reservation_min_installment_amount' => 100,
            'variations' => $sourceVariations,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_contents')->insert([
            'language_id' => 1,
            'ticket_id' => $sourceTicketId,
            'title' => 'VIP access',
            'description' => 'Fast lane and premium area.',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('variation_contents')->insert([
            'language_id' => 1,
            'ticket_id' => $sourceTicketId,
            'name' => 'VIP',
            'key' => '0',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('ticket_price_schedules')->insert([
            'ticket_id' => $sourceTicketId,
            'label' => 'Launch price',
            'effective_from' => '2026-04-01 00:00:00',
            'price' => 1200,
            'sort_order' => 1,
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $sourceSlotId = (int) DB::table('slots')->insertGetId([
            'event_id' => $sourceEventId,
            'ticket_id' => $sourceTicketId,
            'slot_enable' => 1,
            'slot_unique_id' => 910001,
            'pos_x' => '20',
            'pos_y' => '30',
            'width' => '140',
            'height' => '40',
            'name' => 'VIP Row',
            'type' => 1,
            'number_of_seat' => 8,
            'price' => 1500,
            'border_color' => '#000000',
            'font_size' => '12',
            'is_deactive' => 0,
            'is_booked' => 0,
            'pricing_type' => 'variation',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('slot_seats')->insert([
            'slot_id' => $sourceSlotId,
            'name' => 'A1',
            'type' => 1,
            'price' => 1500,
            'is_deactive' => 0,
        ]);

        DB::table('slot_images')->insert([
            'event_id' => $sourceEventId,
            'ticket_id' => $sourceTicketId,
            'slot_unique_id' => 910001,
            'image' => 'clone-test-map-image.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $request = Request::create("/admin/event/{$sourceEventId}/clone", 'POST', [
            'language' => 'en',
        ]);
        $response = app(EventController::class)->cloneEvent($request, $sourceEventId);

        $clonedEvent = Event::query()->where('id', '<>', $sourceEventId)->latest('id')->first();

        $this->assertNotNull($clonedEvent);
        $this->assertTrue($response->isRedirection());
        $this->assertSame(route('admin.event_management.edit_event', [
            'id' => $clonedEvent->id,
            'language' => 'en',
        ]), $response->headers->get('Location'));

        $this->assertSame(0, (int) $clonedEvent->status);
        $this->assertSame('no', $clonedEvent->is_featured);
        $this->assertSame($sourceEventId + 1, $clonedEvent->id);
        $this->assertNotSame('clone-test-thumb.jpg', $clonedEvent->thumbnail);
        $this->assertTrue(is_file(public_path('assets/admin/img/event/thumbnail/' . $clonedEvent->thumbnail)));
        $this->assertTrue(is_file(public_path('assets/admin/img/event_ticket/' . $clonedEvent->ticket_image)));
        $this->assertTrue(is_file(public_path('assets/admin/img/event_ticket_logo/' . $clonedEvent->ticket_logo)));

        $clonedContent = DB::table('event_contents')->where('event_id', $clonedEvent->id)->first();
        $this->assertSame('Clone Source Event (Copy)', $clonedContent->title);
        $this->assertSame('clone-source-event-(copy)', $clonedContent->slug);
        $this->assertNull($clonedContent->google_calendar_id);

        $this->assertSame(1, DB::table('event_images')->where('event_id', $clonedEvent->id)->count());
        $this->assertSame(1, DB::table('event_dates')->where('event_id', $clonedEvent->id)->count());
        $this->assertSame(1, DB::table('event_artist')->where('event_id', $clonedEvent->id)->count());
        $this->assertSame(2, DB::table('event_lineups')->where('event_id', $clonedEvent->id)->count());

        $clonedTicket = DB::table('tickets')->where('event_id', $clonedEvent->id)->first();
        $this->assertNotNull($clonedTicket);
        $this->assertNotSame(810001, (int) $clonedTicket->normal_ticket_slot_unique_id);

        $clonedVariations = json_decode((string) $clonedTicket->variations, true);
        $this->assertIsArray($clonedVariations);
        $this->assertNotSame(910001, (int) $clonedVariations[0]['slot_unique_id']);
        $this->assertSame(1, DB::table('ticket_contents')->where('ticket_id', $clonedTicket->id)->count());
        $this->assertSame(1, DB::table('variation_contents')->where('ticket_id', $clonedTicket->id)->count());
        $this->assertSame(1, DB::table('ticket_price_schedules')->where('ticket_id', $clonedTicket->id)->count());

        $clonedSlot = DB::table('slots')->where('ticket_id', $clonedTicket->id)->first();
        $this->assertNotNull($clonedSlot);
        $this->assertNotSame(910001, (int) $clonedSlot->slot_unique_id);
        $this->assertSame(1, DB::table('slot_seats')->where('slot_id', $clonedSlot->id)->count());

        $clonedSlotImage = DB::table('slot_images')->where('ticket_id', $clonedTicket->id)->first();
        $this->assertNotNull($clonedSlotImage);
        $this->assertNotSame('clone-test-map-image.jpg', $clonedSlotImage->image);
        $this->assertNotSame(910001, (int) $clonedSlotImage->slot_unique_id);
        $this->assertTrue(is_file(public_path('assets/admin/img/map-image/' . $clonedSlotImage->image)));
    }

    private function ensureCloneSchema(): void
    {
        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->integer('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->string('venue_source')->nullable();
                $table->string('thumbnail')->nullable();
                $table->tinyInteger('status')->default(0);
                $table->tinyInteger('countdown_status')->default(0);
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->time('start_time')->nullable();
                $table->string('duration')->nullable();
                $table->date('end_date')->nullable();
                $table->time('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('is_featured')->nullable();
                $table->string('event_type')->nullable();
                $table->string('latitude')->nullable();
                $table->string('longitude')->nullable();
                $table->string('ticket_image')->nullable();
                $table->string('ticket_logo')->nullable();
                $table->string('ticket_slot_image')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('event_category_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->text('description')->nullable();
                $table->text('refund_policy')->nullable();
                $table->text('meta_keywords')->nullable();
                $table->text('meta_description')->nullable();
                $table->string('google_calendar_id')->nullable();
                $table->string('address')->nullable();
                $table->string('country')->nullable();
                $table->string('state')->nullable();
                $table->string('city')->nullable();
                $table->string('zip_code')->nullable();
                $table->unsignedBigInteger('country_id')->nullable();
                $table->unsignedBigInteger('state_id')->nullable();
                $table->unsignedBigInteger('city_id')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_images')) {
            Schema::create('event_images', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('image')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_dates')) {
            Schema::create('event_dates', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->date('start_date')->nullable();
                $table->time('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->time('end_time')->nullable();
                $table->string('duration')->nullable();
                $table->dateTime('start_date_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_artist')) {
            Schema::create('event_artist', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('artist_id');
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

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->string('event_type')->nullable();
                $table->string('title')->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->nullable();
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->nullable();
                $table->text('description')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 12, 2)->nullable();
                $table->decimal('f_price', 12, 2)->nullable();
                $table->string('early_bird_discount_type')->nullable();
                $table->string('early_bird_discount')->nullable();
                $table->decimal('early_bird_discount_amount', 12, 2)->nullable();
                $table->date('early_bird_discount_date')->nullable();
                $table->time('early_bird_discount_time')->nullable();
                $table->longText('variations')->nullable();
                $table->longText('trans_vars')->nullable();
                $table->tinyInteger('normal_ticket_slot_enable')->nullable();
                $table->unsignedBigInteger('normal_ticket_slot_unique_id')->nullable();
                $table->tinyInteger('free_tickete_slot_enable')->nullable();
                $table->unsignedBigInteger('free_tickete_slot_unique_id')->nullable();
                $table->decimal('slot_seat_min_price', 12, 2)->nullable();
                $table->tinyInteger('reservation_enabled')->nullable();
                $table->string('reservation_deposit_type')->nullable();
                $table->decimal('reservation_deposit_value', 12, 2)->nullable();
                $table->date('reservation_final_due_date')->nullable();
                $table->decimal('reservation_min_installment_amount', 12, 2)->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_contents')) {
            Schema::create('ticket_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('ticket_id');
                $table->string('title')->nullable();
                $table->text('description')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('variation_contents')) {
            Schema::create('variation_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->unsignedBigInteger('ticket_id');
                $table->string('name')->nullable();
                $table->string('key')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_price_schedules')) {
            Schema::create('ticket_price_schedules', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->string('label')->nullable();
                $table->dateTime('effective_from')->nullable();
                $table->decimal('price', 12, 2)->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('slots')) {
            Schema::create('slots', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->tinyInteger('slot_enable')->nullable();
                $table->unsignedBigInteger('slot_unique_id')->nullable();
                $table->string('pos_x')->nullable();
                $table->string('pos_y')->nullable();
                $table->string('rotate')->nullable();
                $table->string('background_color')->nullable();
                $table->string('width')->nullable();
                $table->string('height')->nullable();
                $table->string('round')->nullable();
                $table->string('name')->nullable();
                $table->integer('type')->nullable();
                $table->integer('number_of_seat')->nullable();
                $table->decimal('price', 12, 2)->nullable();
                $table->string('border_color')->nullable();
                $table->string('font_size')->nullable();
                $table->tinyInteger('is_deactive')->default(0);
                $table->tinyInteger('is_booked')->default(0);
                $table->string('pricing_type')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('slot_images')) {
            Schema::create('slot_images', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('slot_unique_id')->nullable();
                $table->string('image')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('slot_seats')) {
            Schema::create('slot_seats', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->integer('type')->nullable();
                $table->unsignedBigInteger('slot_id');
                $table->decimal('price', 12, 2)->nullable();
                $table->tinyInteger('is_deactive')->default(0);
            });
        }
    }

    private function seedCloneAssets(): void
    {
        $assets = [
            'assets/admin/img/event/thumbnail/clone-test-thumb.jpg',
            'assets/admin/img/event-gallery/clone-test-gallery.jpg',
            'assets/admin/img/event_ticket/clone-test-ticket-image.jpg',
            'assets/admin/img/event_ticket/clone-test-ticket-slot.jpg',
            'assets/admin/img/event_ticket_logo/clone-test-ticket-logo.jpg',
            'assets/admin/img/map-image/clone-test-map-image.jpg',
        ];

        foreach ($assets as $asset) {
            $path = public_path($asset);
            File::ensureDirectoryExists(dirname($path));
            file_put_contents($path, 'clone-test');
        }
    }

    private function cleanupCloneAssets(): void
    {
        $patterns = [
            public_path('assets/admin/img/event/thumbnail/clone-test-thumb*'),
            public_path('assets/admin/img/event-gallery/clone-test-gallery*'),
            public_path('assets/admin/img/event_ticket/clone-test-ticket-image*'),
            public_path('assets/admin/img/event_ticket/clone-test-ticket-slot*'),
            public_path('assets/admin/img/event_ticket_logo/clone-test-ticket-logo*'),
            public_path('assets/admin/img/map-image/clone-test-map-image*'),
        ];

        foreach ($patterns as $pattern) {
            foreach (glob($pattern) ?: [] as $file) {
                @unlink($file);
            }
        }
    }
}
