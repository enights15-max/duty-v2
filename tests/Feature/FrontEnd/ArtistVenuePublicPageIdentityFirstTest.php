<?php

namespace Tests\Feature\FrontEnd;

use App\Http\Controllers\FrontEnd\ArtistController;
use App\Http\Controllers\FrontEnd\VenueController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\View\View;
use Tests\Support\ActorFeatureTestCase;

class ArtistVenuePublicPageIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [
        'users_customers',
        'identities',
        'follows',
        'legacy_identity_sources',
        'discovery_catalog',
    ];

    protected array $baselineTruncate = [
        'identities',
        'identity_members',
        'follows',
        'event_artist',
        'event_contents',
        'events',
        'venues',
        'artists',
        'languages',
        'basic_settings',
    ];

    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureBasicSettingsTable();
        $this->ensureEventTimingColumns();
    }

    public function test_artist_public_page_uses_identity_first_profile_data(): void
    {
        DB::table('artists')->insert([
            'id' => 601,
            'name' => 'Legacy Pulse',
            'username' => 'legacy_pulse',
            'details' => 'Legacy artist bio',
            'status' => 1,
            'created_at' => now()->subDays(12),
            'updated_at' => now()->subDays(12),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 9601,
            'display_name' => 'Pulse Identity',
            'slug' => 'pulse-identity',
            'meta' => json_encode([
                'legacy_id' => 601,
                'legacy_source' => 'artist',
                'details' => 'Identity artist bio',
                'facebook' => 'https://facebook.com/pulse',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 6101,
            'status' => 1,
            'thumbnail' => 'pulse-event.jpg',
            'start_date' => now()->addDays(8),
            'end_date_time' => now()->addDays(8)->addHours(4),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 6101,
            'language_id' => 1,
            'title' => 'Pulse Identity Live',
            'slug' => 'pulse-identity-live',
            'address' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_artist')->insert([
            'event_id' => 6101,
            'artist_id' => 601,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $view = app(ArtistController::class)->details(request(), $identityId, 'pulse-identity');

        $this->assertInstanceOf(View::class, $view);
        $this->assertSame('frontend.artist.details', $view->getName());
        $this->assertSame('Pulse Identity', $view->getData()['artist']->name);
        $this->assertSame('legacy_pulse', $view->getData()['artist']->username);
        $this->assertSame('Pulse Identity Live', $view->getData()['events']->first()->title);
        $this->assertStringContainsString('pulse-identity-live', $view->getData()['events']->first()->event_url);
    }

    public function test_venue_public_page_uses_identity_first_profile_data(): void
    {
        DB::table('venues')->insert([
            'id' => 701,
            'name' => 'Legacy Dome',
            'slug' => 'legacy-dome',
            'username' => 'legacy_dome',
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'status' => 1,
            'created_at' => now()->subDays(20),
            'updated_at' => now()->subDays(20),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 9701,
            'display_name' => 'Dome Identity',
            'slug' => 'dome-identity',
            'meta' => json_encode([
                'legacy_id' => 701,
                'legacy_source' => 'venue',
                'address_line' => 'Av. Lincoln',
                'city' => 'Santo Domingo',
                'country' => 'DO',
                'facebook' => 'https://facebook.com/dome',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            [
                'id' => 7101,
                'status' => 1,
                'venue_id' => null,
                'venue_identity_id' => $identityId,
                'thumbnail' => 'dome-upcoming.jpg',
                'start_date' => now()->addDays(4),
                'start_time' => '20:00:00',
                'end_date_time' => now()->addDays(4)->addHours(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 7102,
                'status' => 1,
                'venue_id' => 701,
                'venue_identity_id' => null,
                'thumbnail' => 'dome-past.jpg',
                'start_date' => now()->subDays(10),
                'start_time' => '19:00:00',
                'end_date_time' => now()->subDays(10)->addHours(3),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_contents')->insert([
            [
                'event_id' => 7101,
                'language_id' => 1,
                'title' => 'Dome Future Night',
                'slug' => 'dome-future-night',
                'address' => 'Av. Lincoln',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => 7102,
                'language_id' => 1,
                'title' => 'Dome Classics',
                'slug' => 'dome-classics',
                'address' => 'Av. Lincoln',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $view = app(VenueController::class)->details(request(), $identityId, 'dome-identity');

        $this->assertInstanceOf(View::class, $view);
        $this->assertSame('frontend.venue.details', $view->getName());
        $this->assertSame('Dome Identity', $view->getData()['venue']->name);
        $this->assertSame('legacy_dome', $view->getData()['venue']->username);
        $this->assertCount(2, $view->getData()['events']);
        $this->assertSame('Dome Future Night', $view->getData()['events']->first()->title);
        $this->assertStringContainsString('dome-future-night', $view->getData()['events']->first()->event_url);
    }

    private function ensureBasicSettingsTable(): void
    {
        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table) {
                $table->id();
                $table->tinyInteger('google_recaptcha_status')->default(0);
                $table->timestamps();
            });
        } elseif (!Schema::hasColumn('basic_settings', 'google_recaptcha_status')) {
            Schema::table('basic_settings', function (Blueprint $table) {
                $table->tinyInteger('google_recaptcha_status')->default(0);
            });
        }

        DB::table('basic_settings')->insert([
            'google_recaptcha_status' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function ensureEventTimingColumns(): void
    {
        if (!Schema::hasColumn('events', 'start_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('start_time')->nullable();
            });
        }
    }
}
