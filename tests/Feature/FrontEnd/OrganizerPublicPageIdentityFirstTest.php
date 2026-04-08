<?php

namespace Tests\Feature\FrontEnd;

use App\Http\Controllers\FrontEnd\OrganizerController;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\View\View;
use Tests\Support\ActorFeatureTestCase;

class OrganizerPublicPageIdentityFirstTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = [
        'users_customers',
        'identities',
        'legacy_identity_sources',
    ];

    protected array $baselineTruncate = [
        'identities',
        'identity_members',
        'events',
        'event_contents',
        'event_categories',
        'organizer_infos',
        'organizers',
        'languages',
        'basic_settings',
    ];

    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureLanguageTable();
        $this->ensureBasicSettingsTable();
        $this->ensureOrganizerSchema();
        $this->ensureEventTimingColumns();
    }

    public function test_organizer_public_page_uses_identity_first_profile_data(): void
    {
        DB::table('organizers')->insert([
            'id' => 801,
            'username' => 'legacy_host',
            'email' => 'legacy-host@example.com',
            'photo' => 'legacy-host.jpg',
            'status' => 1,
            'created_at' => now()->subDays(18),
            'updated_at' => now()->subDays(18),
        ]);

        DB::table('organizer_infos')->insert([
            'organizer_id' => 801,
            'language_id' => 1,
            'name' => 'Legacy Host',
            'details' => 'Legacy organizer bio',
            'city' => 'Santo Domingo',
            'country' => 'DO',
            'address' => 'Zona Colonial',
            'created_at' => now()->subDays(18),
            'updated_at' => now()->subDays(18),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 9801,
            'display_name' => 'Identity Host',
            'slug' => 'identity-host',
            'meta' => json_encode([
                'legacy_id' => 801,
                'legacy_source' => 'organizer',
                'details' => 'Identity organizer bio',
                'facebook' => 'https://facebook.com/identity-host',
            ]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_categories')->insert([
            'id' => 81,
            'language_id' => 1,
            'name' => 'Party',
            'slug' => 'party',
            'status' => 1,
            'serial_number' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 8101,
            'status' => 1,
            'organizer_id' => null,
            'owner_identity_id' => $identityId,
            'thumbnail' => 'identity-host-event.jpg',
            'start_date' => now()->addDays(6)->toDateString(),
            'start_time' => '21:00:00',
            'duration' => '4h',
            'end_date_time' => now()->addDays(6)->addHours(4),
            'date_type' => 'single',
            'event_type' => 'venue',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => 8101,
            'language_id' => 1,
            'title' => 'Identity Host Night',
            'slug' => 'identity-host-night',
            'description' => 'Identity-first organizer event.',
            'address' => 'Zona Colonial',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $view = app(OrganizerController::class)->details(request(), $identityId, 'identity-host');

        $this->assertInstanceOf(View::class, $view);
        $this->assertSame('frontend.organizer.details', $view->getName());
        $this->assertFalse($view->getData()['admin']);
        $this->assertSame('Identity Host', $view->getData()['organizer_info']->name);
        $this->assertSame('legacy_host', $view->getData()['organizer']->username);
        $this->assertCount(1, $view->getData()['events']);
        $this->assertSame(8101, $view->getData()['events']->first()->id);
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

    private function ensureLanguageTable(): void
    {
        if (!Schema::hasTable('languages')) {
            Schema::create('languages', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('code')->nullable();
                $table->tinyInteger('is_default')->default(0);
                $table->timestamps();
            });
        }

        if (Schema::hasTable('languages') && DB::table('languages')->count() === 0) {
            DB::table('languages')->insert([
                'id' => 1,
                'name' => 'English',
                'code' => 'en',
                'is_default' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    private function ensureOrganizerSchema(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table) {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('photo')->nullable();
                $table->string('facebook')->nullable();
                $table->string('linkedin')->nullable();
                $table->string('twitter')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('organizer_infos')) {
            Schema::create('organizer_infos', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->text('details')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->string('address')->nullable();
                $table->string('zip_code')->nullable();
                $table->string('designation')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_categories')) {
            Schema::create('event_categories', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('name')->nullable();
                $table->string('slug')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->integer('serial_number')->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->decimal('price', 8, 2)->nullable();
                $table->decimal('f_price', 8, 2)->nullable();
                $table->string('pricing_type')->nullable();
                $table->timestamps();
            });
        }
    }

    private function ensureEventTimingColumns(): void
    {
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->string('duration')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('date_type')->nullable();
                $table->string('event_type')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id')->nullable();
                $table->string('title')->nullable();
                $table->string('slug')->nullable();
                $table->text('description')->nullable();
                $table->string('address')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasColumn('events', 'start_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('start_time')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'duration')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('duration')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'owner_identity_id')) {
            Schema::table('events', function (Blueprint $table) {
                $table->unsignedBigInteger('owner_identity_id')->nullable()->after('organizer_id');
            });
        }

        if (!Schema::hasColumn('events', 'status')) {
            Schema::table('events', function (Blueprint $table) {
                $table->tinyInteger('status')->default(1);
            });
        }

        if (!Schema::hasColumn('events', 'date_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('date_type')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'event_type')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('event_type')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'thumbnail')) {
            Schema::table('events', function (Blueprint $table) {
                $table->string('thumbnail')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'start_date')) {
            Schema::table('events', function (Blueprint $table) {
                $table->date('start_date')->nullable();
            });
        }

        if (!Schema::hasColumn('events', 'end_date_time')) {
            Schema::table('events', function (Blueprint $table) {
                $table->dateTime('end_date_time')->nullable();
            });
        }

        if (Schema::hasTable('event_contents') && !Schema::hasColumn('event_contents', 'description')) {
            Schema::table('event_contents', function (Blueprint $table) {
                $table->text('description')->nullable();
            });
        }

        if (Schema::hasTable('event_contents') && !Schema::hasColumn('event_contents', 'address')) {
            Schema::table('event_contents', function (Blueprint $table) {
                $table->string('address')->nullable();
            });
        }
    }
}
