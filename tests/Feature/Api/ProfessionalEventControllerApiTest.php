<?php

namespace Tests\Feature\Api;

use App\Models\Customer;
use App\Models\EventFinancialEntry;
use App\Models\EventTreasury;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalEventControllerApiTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'event_rewards'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'customers',
        'users',
    ];
    protected bool $baselineDefaultLanguage = true;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureProfessionalEventSchema();
        $this->truncateTables([
            'artists',
            'venues',
            'basic_settings',
            'event_categories',
            'event_financial_entries',
            'event_settlement_settings',
            'event_treasuries',
            'events',
            'event_contents',
            'event_dates',
            'event_images',
            'event_artist',
            'identity_balance_transactions',
            'identity_balances',
            'organizers',
            'event_lineups',
            'ticket_price_schedules',
            'tickets',
            'event_reward_claim_logs',
            'event_reward_instances',
            'event_reward_definitions',
        ]);

        if (!DB::table('basic_settings')->exists()) {
            DB::table('basic_settings')->insert([
                'id' => 1,
                'event_country_status' => 0,
                'event_state_status' => 0,
            ]);
        }
    }

    public function test_organizer_identity_can_create_event_with_external_venue_and_mixed_lineup(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $artistId = $this->seedArtist('DJ Nova');
        $categoryId = $this->seedCategory();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'slider_images' => [999],
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'yes',
                'age_limit' => 18,
                'start_date' => '2026-05-01',
                'start_time' => '20:00',
                'end_date' => '2026-05-02',
                'end_time' => '01:00',
                'venue_source' => 'external',
                'venue_name' => 'Club Aurora',
                'venue_address' => 'Av. Libertad 123',
                'venue_city' => 'Santo Domingo',
                'venue_state' => 'Distrito Nacional',
                'venue_country' => 'Dominican Republic',
                'venue_postal_code' => '10101',
                'venue_google_place_id' => 'place_demo_aurora',
                'latitude' => '18.4861',
                'longitude' => '-69.9312',
                'artist_ids' => [$artistId],
                'manual_artists' => ['Guest MC', 'B2B Surprise'],
                'lineup_order' => ['manual:Guest MC', 'artist:' . $artistId, 'manual:B2B Surprise'],
                'headliner_key' => 'artist:' . $artistId,
                'manual_artists_text' => "Guest MC\nB2B Surprise",
                'en_title' => 'Duty Opening Night',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('A', 40),
                'en_refund_policy' => 'No refunds after ticket validation.',
                'en_meta_keywords' => 'duty,opening,night',
                'en_meta_description' => 'Launch event',
                'hold_mode' => 'auto_after_grace_period',
                'grace_period_hours' => 48,
                'refund_window_hours' => 24,
                'auto_release_owner_share' => '1',
                'require_admin_approval' => '1',
            ]
        );

        $response->assertCreated();
        $response->assertJsonPath('data.venue_source', 'external');
        $response->assertJsonPath('data.settlement_settings.hold_mode', 'auto_after_grace_period');
        $response->assertJsonPath('data.settlement_settings.grace_period_hours', 48);
        $response->assertJsonPath('data.settlement_settings.auto_release_owner_share', true);
        $response->assertJsonCount(3, 'data.lineup');
        $response->assertJsonPath('data.lineup.0.source_type', 'manual');
        $response->assertJsonPath('data.lineup.0.display_name', 'Guest MC');
        $response->assertJsonPath('data.lineup.1.source_type', 'artist');
        $response->assertJsonPath('data.lineup.1.artist_id', $artistId);
        $response->assertJsonPath('data.lineup.1.is_headliner', true);
        $response->assertJsonPath('data.headliner_key', 'artist:' . $artistId);

        $eventId = (int) $response->json('data.id');

        $this->assertDatabaseHas('events', [
            'id' => $eventId,
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'venue_source' => 'external',
            'venue_name_snapshot' => 'Club Aurora',
            'venue_address_snapshot' => 'Av. Libertad 123',
        ]);

        $this->assertDatabaseHas('event_contents', [
            'event_id' => $eventId,
            'title' => 'Duty Opening Night',
            'address' => 'Av. Libertad 123',
            'city' => 'Santo Domingo',
        ]);
        $this->assertDatabaseHas('event_settlement_settings', [
            'event_id' => $eventId,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 48,
            'refund_window_hours' => 24,
            'auto_release_owner_share' => 1,
            'require_admin_approval' => 1,
        ]);

        $this->assertSame(1, DB::table('event_artist')->where('event_id', $eventId)->count());
        $this->assertSame(3, DB::table('event_lineups')->where('event_id', $eventId)->count());
        $this->assertDatabaseHas('event_lineups', [
            'event_id' => $eventId,
            'source_type' => 'artist',
            'artist_id' => $artistId,
            'sort_order' => 2,
            'is_headliner' => 1,
        ]);
        $this->assertDatabaseHas('event_lineups', [
            'event_id' => $eventId,
            'source_type' => 'manual',
            'display_name' => 'Guest MC',
            'sort_order' => 1,
            'is_headliner' => 0,
        ]);
    }

    public function test_organizer_identity_can_update_event_to_registered_venue_and_replace_lineup(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $artistId = $this->seedArtist('DJ Pulse', 32);
        $categoryId = $this->seedCategory();
        $venueId = $this->seedVenue();

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-06-01',
            'start_time' => '22:00',
            'end_date' => '2026-06-02',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(10),
            'status' => 1,
            'is_featured' => 'no',
            'thumbnail' => 'existing-thumb.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Existing Event',
            'slug' => 'existing-event',
            'description' => str_repeat('B', 40),
            'address' => 'Old Address',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_lineups')->insert([
            'event_id' => $eventId,
            'artist_id' => null,
            'source_type' => 'manual',
            'display_name' => 'Old Guest',
            'sort_order' => 1,
            'is_headliner' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}"),
            [
                'event_id' => $eventId,
                'gallery_images' => 1,
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'yes',
                'age_limit' => 21,
                'start_date' => '2026-06-10',
                'start_time' => '21:00',
                'end_date' => '2026-06-11',
                'end_time' => '03:00',
                'venue_source' => 'registered',
                'venue_id' => $venueId,
                'artist_ids' => [$artistId],
                'manual_artists' => ['New Guest'],
                'lineup_order' => ['artist:' . $artistId, 'manual:New Guest'],
                'headliner_key' => 'manual:New Guest',
                'manual_artists_text' => 'New Guest',
                'en_title' => 'Updated Event',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('C', 45),
                'en_refund_policy' => 'Updated policy',
                'en_meta_keywords' => 'updated,event',
                'en_meta_description' => 'Updated description',
                'latitude' => '18.4900',
                'longitude' => '-69.9300',
                'hold_mode' => 'manual_admin',
                'grace_period_hours' => 72,
                'refund_window_hours' => 96,
                'auto_release_owner_share' => '0',
                'require_admin_approval' => '1',
            ]
        );

        $response->assertOk();
        $response->assertJsonPath('data.venue_source', 'registered');
        $response->assertJsonPath('data.settlement_settings.hold_mode', 'manual_admin');
        $response->assertJsonPath('data.settlement_settings.auto_release_owner_share', false);
        $response->assertJsonCount(2, 'data.lineup');
        $response->assertJsonPath('data.lineup.0.artist_id', $artistId);
        $response->assertJsonPath('data.lineup.1.display_name', 'New Guest');
        $response->assertJsonPath('data.lineup.1.is_headliner', true);
        $response->assertJsonPath('data.headliner_key', 'manual:New Guest');

        $this->assertDatabaseHas('events', [
            'id' => $eventId,
            'venue_id' => $venueId,
            'venue_source' => 'registered',
            'venue_name_snapshot' => 'Duty Arena',
            'venue_address_snapshot' => 'Calle 50',
        ]);

        $this->assertDatabaseHas('event_contents', [
            'event_id' => $eventId,
            'title' => 'Updated Event',
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
        ]);
        $this->assertDatabaseHas('event_settlement_settings', [
            'event_id' => $eventId,
            'hold_mode' => 'manual_admin',
            'grace_period_hours' => 72,
            'refund_window_hours' => 96,
            'auto_release_owner_share' => 0,
            'require_admin_approval' => 1,
        ]);

        $this->assertSame(2, DB::table('event_lineups')->where('event_id', $eventId)->count());
        $this->assertDatabaseMissing('event_lineups', [
            'event_id' => $eventId,
            'display_name' => 'Old Guest',
        ]);
        $this->assertDatabaseHas('event_lineups', [
            'event_id' => $eventId,
            'display_name' => 'New Guest',
            'sort_order' => 2,
            'is_headliner' => 1,
        ]);
    }

    public function test_organizer_identity_can_create_manual_venue_event_for_mobile_authoring(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'slider_files' => [
                    UploadedFile::fake()->image('gallery-1.jpg', 1170, 570),
                ],
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'no',
                'start_date' => '2026-06-15',
                'start_time' => '18:00',
                'end_date' => '2026-06-16',
                'end_time' => '00:30',
                'venue_source' => 'manual',
                'venue_name' => 'Secret Rooftop',
                'venue_address' => 'Calle Proyecto 42',
                'venue_city' => 'Santo Domingo',
                'venue_state' => 'Distrito Nacional',
                'venue_country' => 'Dominican Republic',
                'venue_postal_code' => '10210',
                'en_title' => 'Manual Venue Night',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Manual venue copy ', 3),
                'en_refund_policy' => 'Manual venue policy.',
                'en_meta_keywords' => 'manual,venue',
                'en_meta_description' => 'Manual venue event',
            ]
        );

        $response->assertCreated();
        $response->assertJsonPath('data.venue_source', 'manual');
        $response->assertJsonPath('data.mobile_authoring_supported', true);
        $response->assertJsonPath('data.venue_summary.name', 'Secret Rooftop');
        $response->assertJsonPath('data.venue_summary.address', 'Calle Proyecto 42');

        $eventId = (int) $response->json('data.id');

        $showResponse = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl("/api/customers/professional/events/{$eventId}"));

        $showResponse->assertOk();
        $showResponse->assertJsonPath('data.form_defaults.venue_source', 'manual');
        $showResponse->assertJsonPath('data.form_defaults.venue_name', 'Secret Rooftop');
        $showResponse->assertJsonPath('data.form_defaults.venue_address', 'Calle Proyecto 42');

        $this->assertDatabaseHas('events', [
            'id' => $eventId,
            'venue_source' => 'manual',
            'venue_name_snapshot' => 'Secret Rooftop',
            'venue_address_snapshot' => 'Calle Proyecto 42',
            'latitude' => null,
            'longitude' => null,
        ]);

        $this->assertDatabaseHas('event_contents', [
            'event_id' => $eventId,
            'title' => 'Manual Venue Night',
            'address' => 'Calle Proyecto 42',
            'city' => 'Santo Domingo',
            'country' => 'Dominican Republic',
        ]);
    }

    public function test_organizer_identity_can_create_event_with_direct_gallery_file_uploads(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'slider_files' => [
                    UploadedFile::fake()->image('gallery-1.jpg', 1170, 570),
                    UploadedFile::fake()->image('gallery-2.jpg', 1170, 570),
                ],
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'no',
                'start_date' => '2026-07-04',
                'start_time' => '19:00',
                'end_date' => '2026-07-05',
                'end_time' => '01:00',
                'venue_source' => 'registered',
                'venue_id' => $this->seedVenue(),
                'en_title' => 'Gallery Upload Event',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Direct upload copy ', 3),
                'en_refund_policy' => 'Standard policy applies.',
                'en_meta_keywords' => 'gallery,upload',
                'en_meta_description' => 'Testing direct gallery uploads',
            ]
        );

        $response->assertCreated();

        $eventId = (int) $response->json('data.id');

        $this->assertSame(2, DB::table('event_images')->where('event_id', $eventId)->count());
        $this->assertDatabaseHas('events', [
            'id' => $eventId,
            'venue_source' => 'registered',
            'venue_id' => 77,
        ]);
    }

    public function test_organizer_identity_can_create_online_event_with_price_schedules(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'slider_files' => [
                    UploadedFile::fake()->image('gallery-1.jpg', 1170, 570),
                ],
                'event_type' => 'online',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'no',
                'start_date' => '2026-08-10',
                'start_time' => '19:00',
                'end_date' => '2026-08-10',
                'end_time' => '23:00',
                'meeting_url' => 'https://example.com/live/duty',
                'ticket_available_type' => 'limited',
                'ticket_available' => 100,
                'max_ticket_buy_type' => 'limited',
                'max_buy_ticket' => 4,
                'price' => 120,
                'early_bird_discount_type' => 'disable',
                'pricing_type' => 'normal',
                'price_schedules' => [
                    [
                        'label' => 'Launch',
                        'effective_from' => now()->subDays(2)->toIso8601String(),
                        'price' => 90,
                    ],
                    [
                        'label' => 'General',
                        'effective_from' => now()->addDays(10)->toIso8601String(),
                        'price' => 140,
                    ],
                ],
                'en_title' => 'Online Launch',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Online launch copy ', 3),
                'en_refund_policy' => 'Digital access only.',
                'en_meta_keywords' => 'online,launch',
                'en_meta_description' => 'Online launch event',
            ]
        );

        $response->assertCreated();
        $eventId = (int) $response->json('data.id');

        $ticketId = (int) DB::table('tickets')->where('event_id', $eventId)->value('id');
        $this->assertGreaterThan(0, $ticketId);
        $this->assertSame(2, DB::table('ticket_price_schedules')->where('ticket_id', $ticketId)->count());
        $response->assertJsonPath('data.ticket_pricing.current_price', 90);
        $response->assertJsonPath('data.ticket_pricing.next_schedule.price', 140);
        $response->assertJsonPath('data.ticket_settings.meeting_url', 'https://example.com/live/duty');
        $response->assertJsonPath('data.mobile_authoring_supported', true);
    }

    public function test_organizer_identity_can_create_event_with_reward_definitions_payload(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();
        $venueId = $this->seedVenue();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'slider_files' => [
                    UploadedFile::fake()->image('gallery-1.jpg', 1170, 570),
                ],
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'no',
                'start_date' => '2026-08-22',
                'start_time' => '20:00',
                'end_date' => '2026-08-23',
                'end_time' => '02:00',
                'venue_source' => 'registered',
                'venue_id' => $venueId,
                'reward_definitions_payload' => json_encode([
                    [
                        'title' => 'Welcome drink',
                        'description' => 'Un trago de cortesía al ingresar.',
                        'reward_type' => 'welcome_drink',
                        'trigger_mode' => 'on_ticket_scan',
                        'fulfillment_mode' => 'qr_claim',
                        'per_ticket_quantity' => 1,
                        'inventory_limit' => 120,
                        'claim_code_prefix' => 'DRINK',
                        'status' => 'active',
                    ],
                ], JSON_THROW_ON_ERROR),
                'en_title' => 'Rewarded Venue Night',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Reward venue copy ', 3),
                'en_refund_policy' => 'No refunds after check-in.',
                'en_meta_keywords' => 'rewards,venue',
                'en_meta_description' => 'Reward-ready event',
            ]
        );

        $response->assertCreated();
        $eventId = (int) $response->json('data.id');

        $response->assertJsonPath('data.reward_definitions.0.title', 'Welcome drink');
        $response->assertJsonPath('data.reward_definitions.0.reward_type', 'welcome_drink');
        $response->assertJsonPath('data.reward_definitions.0.claim_code_prefix', 'DRINK');

        $showResponse = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl("/api/customers/professional/events/{$eventId}"));

        $showResponse->assertOk();
        $showResponse->assertJsonPath('data.form_defaults.reward_definitions.0.title', 'Welcome drink');
        $showResponse->assertJsonPath('data.form_defaults.reward_definitions.0.trigger_mode', 'on_ticket_scan');

        $this->assertDatabaseHas('event_reward_definitions', [
            'event_id' => $eventId,
            'title' => 'Welcome drink',
            'reward_type' => 'welcome_drink',
            'trigger_mode' => 'on_ticket_scan',
            'inventory_limit' => 120,
            'per_ticket_quantity' => 1,
            'status' => 'active',
        ]);
    }

    public function test_organizer_identity_can_create_multiple_date_venue_event_and_receive_date_payload(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();
        $venueId = $this->seedVenue();

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl('/api/customers/professional/events'),
            [
                'thumbnail' => UploadedFile::fake()->image('thumb.jpg', 320, 230),
                'slider_files' => [
                    UploadedFile::fake()->image('gallery-1.jpg', 1170, 570),
                ],
                'event_type' => 'venue',
                'date_type' => 'multiple',
                'status' => 1,
                'is_featured' => 'no',
                'venue_source' => 'registered',
                'venue_id' => $venueId,
                'm_start_date' => ['2026-08-20', '2026-08-27'],
                'm_start_time' => ['20:00', '21:00'],
                'm_end_date' => ['2026-08-21', '2026-08-28'],
                'm_end_time' => ['02:00', '03:30'],
                'en_title' => 'Duty Residency',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Multiple dates copy ', 3),
                'en_refund_policy' => 'No refunds after each session starts.',
                'en_meta_keywords' => 'residency,duty',
                'en_meta_description' => 'Multiple date event',
            ]
        );

        $response->assertCreated();
        $response->assertJsonPath('data.date_type', 'multiple');
        $response->assertJsonPath('data.mobile_authoring_supported', true);
        $response->assertJsonPath('data.start_date', '2026-08-20');
        $response->assertJsonPath('data.end_date', '2026-08-28');
        $response->assertJsonCount(2, 'data.dates');
        $response->assertJsonPath('data.dates.0.start_date', '2026-08-20');
        $response->assertJsonPath('data.dates.1.end_time', '03:30');

        $eventId = (int) $response->json('data.id');
        $this->assertSame(2, DB::table('event_dates')->where('event_id', $eventId)->count());
        $this->assertDatabaseHas('events', [
            'id' => $eventId,
            'start_date' => '2026-08-20',
            'end_date' => '2026-08-28',
            'venue_source' => 'registered',
        ]);
    }

    public function test_organizer_identity_can_list_only_managed_events(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();

        $managedEventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'venue_source' => 'registered',
            'venue_id' => $this->seedVenue(),
            'venue_name_snapshot' => 'Duty Arena',
            'venue_address_snapshot' => 'Calle 50',
            'start_date' => '2026-09-01',
            'start_time' => '21:00',
            'end_date' => '2026-09-02',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(30),
            'status' => 1,
            'is_featured' => 'no',
            'thumbnail' => 'managed.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $managedEventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Managed Event',
            'slug' => 'managed-event',
            'description' => str_repeat('Managed copy ', 4),
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('events')->insert([
            'id' => 999,
            'organizer_id' => 9999,
            'owner_identity_id' => 9999,
            'event_type' => 'venue',
            'date_type' => 'multiple',
            'venue_source' => 'manual',
            'start_date' => '2026-09-05',
            'start_time' => '19:00',
            'end_date' => '2026-09-05',
            'end_time' => '23:00',
            'end_date_time' => now()->addDays(31),
            'status' => 1,
            'is_featured' => 'no',
            'thumbnail' => 'other.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl('/api/customers/professional/events'));

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.id', $managedEventId);
        $response->assertJsonPath('data.0.title', 'Managed Event');
        $response->assertJsonPath('data.0.mobile_authoring_supported', true);
    }

    public function test_registered_venue_cannot_manage_organizer_owned_event_from_same_account_centre(): void
    {
        $organizerIdentityId = $this->seedOrganizerIdentity();
        [$venueIdentityId, $venueCustomerId] = $this->seedVenueIdentity();
        $categoryId = $this->seedCategory();

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $organizerIdentityId,
            'venue_id' => 77,
            'venue_identity_id' => $venueIdentityId,
            'venue_source' => 'registered',
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-11-01',
            'start_time' => '20:00',
            'end_date' => '2026-11-02',
            'end_time' => '02:00',
            'end_date_time' => now()->addDays(60),
            'status' => 1,
            'review_status' => 'approved',
            'thumbnail' => 'shared-venue-event.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Organizer Event At Shared Venue',
            'slug' => 'organizer-event-shared-venue',
            'description' => str_repeat('Shared venue copy ', 3),
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail($venueCustomerId), [], 'sanctum');

        $indexResponse = $this->withHeader('X-Identity-Id', (string) $venueIdentityId)
            ->get($this->apiUrl('/api/customers/professional/events'));

        $indexResponse->assertOk();
        $indexResponse->assertJsonCount(0, 'data');

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $organizerShowResponse = $this->withHeader('X-Identity-Id', (string) $organizerIdentityId)
            ->get($this->apiUrl("/api/customers/professional/events/{$eventId}"));

        $organizerShowResponse->assertOk();
        $organizerShowResponse->assertJsonPath('data.id', $eventId);
        $organizerShowResponse->assertJsonPath('data.management_summary.managed_by_type', 'organizer');
        $organizerShowResponse->assertJsonPath('data.management_summary.managed_by_identity_id', $organizerIdentityId);
        $organizerShowResponse->assertJsonPath('data.venue_summary.venue_id', 77);
        $organizerShowResponse->assertJsonPath('data.hosting_venue_summary.venue_identity_id', $venueIdentityId);
    }

    public function test_organizer_identity_can_claim_event_treasury_into_professional_wallet(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();

        DB::table('organizers')->insert([
            'id' => 901,
            'username' => 'duty-organizer',
            'email' => 'organizer-owner@example.com',
            'amount' => 500,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_balances')->insert([
            'identity_id' => $identityId,
            'legacy_type' => 'organizer',
            'legacy_id' => 901,
            'balance' => 500,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'start_date' => '2026-03-25',
            'start_time' => '20:00',
            'end_date' => '2026-03-25',
            'end_time' => '23:30',
            'end_date_time' => now()->subDays(5),
            'status' => 1,
            'review_status' => 'approved',
            'thumbnail' => 'claimable-event.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Claimable Treasury Event',
            'slug' => 'claimable-treasury-event',
            'description' => str_repeat('Claimable treasury copy ', 3),
            'address' => 'Av. Hold 101',
            'city' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_settlement_settings')->insert([
            'event_id' => $eventId,
            'hold_mode' => 'auto_after_grace_period',
            'grace_period_hours' => 24,
            'refund_window_hours' => 24,
            'auto_release_owner_share' => 0,
            'auto_release_collaborator_shares' => 0,
            'require_admin_approval' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_treasuries')->insert([
            'event_id' => $eventId,
            'gross_collected' => 100,
            'refunded_amount' => 0,
            'platform_fee_total' => 10,
            'reserved_for_owner' => 90,
            'reserved_for_collaborators' => 0,
            'released_to_wallet' => 0,
            'available_for_settlement' => 90,
            'hold_until' => now()->subDay(),
            'settlement_status' => EventTreasury::STATUS_AWAITING_SETTLEMENT,
            'auto_payout_enabled' => 0,
            'auto_payout_delay_hours' => 24,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->post($this->apiUrl("/api/customers/professional/events/{$eventId}/claim"));

        $response->assertOk();
        $response->assertJsonPath('claim.claimed_amount', 90);
        $response->assertJsonPath('data.treasury_summary.status', EventTreasury::STATUS_SETTLED);
        $response->assertJsonPath('data.treasury_summary.claimable_amount', 0);

        $this->assertSame(590.0, (float) DB::table('identity_balances')->where('identity_id', $identityId)->value('balance'));
        $this->assertSame(590.0, (float) DB::table('organizers')->where('id', 901)->value('amount'));

        $this->assertDatabaseHas('identity_balance_transactions', [
            'identity_id' => $identityId,
            'reference_type' => 'event_treasury_release',
        ]);

        $this->assertDatabaseHas('event_financial_entries', [
            'event_id' => $eventId,
            'entry_type' => EventFinancialEntry::TYPE_OWNER_SHARE_RELEASED_TO_WALLET,
        ]);
    }

    public function test_organizer_identity_can_fetch_detailed_payload_for_mobile_editing(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $artistId = $this->seedArtist('DJ Orbit', 45);
        $categoryId = $this->seedCategory();
        $this->seedVenue();

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'venue_source' => 'external',
            'venue_name_snapshot' => 'Alt Warehouse',
            'venue_address_snapshot' => 'Av. Central 10',
            'venue_city_snapshot' => 'Santo Domingo',
            'venue_state_snapshot' => 'Distrito Nacional',
            'venue_country_snapshot' => 'Dominican Republic',
            'venue_postal_code_snapshot' => '10110',
            'venue_google_place_id' => 'place_alt_warehouse',
            'latitude' => 18.4700000,
            'longitude' => -69.9100000,
            'start_date' => '2026-10-01',
            'start_time' => '22:00',
            'end_date' => '2026-10-02',
            'end_time' => '04:00',
            'end_date_time' => now()->addDays(45),
            'status' => 1,
            'is_featured' => 'yes',
            'age_limit' => 18,
            'thumbnail' => 'editor-thumb.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Editable Event',
            'slug' => 'editable-event',
            'description' => str_repeat('Editable copy ', 4),
            'refund_policy' => 'No refunds',
            'meta_keywords' => 'editable,event',
            'meta_description' => 'Editable meta description',
            'address' => 'Av. Central 10',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'Dominican Republic',
            'zip_code' => '10110',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_images')->insert([
            [
                'event_id' => $eventId,
                'image' => 'gallery-a.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => $eventId,
                'image' => 'gallery-b.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('event_artist')->insert([
            'event_id' => $eventId,
            'artist_id' => $artistId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_lineups')->insert([
            [
                'event_id' => $eventId,
                'artist_id' => $artistId,
                'source_type' => 'artist',
                'display_name' => 'DJ Orbit',
                'sort_order' => 1,
                'is_headliner' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'event_id' => $eventId,
                'artist_id' => null,
                'source_type' => 'manual',
                'display_name' => 'Special Guest',
                'sort_order' => 2,
                'is_headliner' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('tickets')->insert([
            'event_id' => $eventId,
            'event_type' => 'venue',
            'price' => 1500,
            'f_price' => 1500,
            'pricing_type' => 'normal',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)
            ->get($this->apiUrl("/api/customers/professional/events/{$eventId}"));

        $response->assertOk();
        $response->assertJsonPath('data.id', $eventId);
        $response->assertJsonPath('data.form_defaults.title', 'Editable Event');
        $response->assertJsonPath('data.form_defaults.category_id', $categoryId);
        $response->assertJsonPath('data.form_defaults.venue_source', 'external');
        $response->assertJsonPath('data.form_defaults.venue_name', 'Alt Warehouse');
        $response->assertJsonPath('data.form_defaults.manual_artists_text', "Special Guest");
        $response->assertJsonPath('data.form_defaults.hold_mode', 'auto_after_grace_period');
        $response->assertJsonPath('data.form_defaults.grace_period_hours', 72);
        $response->assertJsonPath('data.form_defaults.auto_release_owner_share', false);
        $response->assertJsonPath('data.selected_artists.0.id', $artistId);
        $response->assertJsonPath('data.lineup.0.key', 'artist:' . $artistId);
        $response->assertJsonPath('data.lineup.0.is_headliner', true);
        $response->assertJsonPath('data.lineup.1.key', 'manual:Special Guest');
        $response->assertJsonPath('data.headliner_key', 'artist:' . $artistId);
        $response->assertJsonPath('data.gallery.0.image', 'gallery-a.jpg');
        $response->assertJsonPath('data.ticket_pricing.current_price', 1500);
        $response->assertJsonPath('data.mobile_authoring_supported', true);
    }

    public function test_update_archives_existing_reward_definition_with_issued_instances_instead_of_deleting_it(): void
    {
        $identityId = $this->seedOrganizerIdentity();
        $categoryId = $this->seedCategory();
        $venueId = $this->seedVenue();

        $eventId = (int) DB::table('events')->insertGetId([
            'organizer_id' => 901,
            'owner_identity_id' => $identityId,
            'event_type' => 'venue',
            'date_type' => 'single',
            'venue_source' => 'registered',
            'venue_id' => $venueId,
            'venue_name_snapshot' => 'Duty Arena',
            'venue_address_snapshot' => 'Calle 50',
            'start_date' => '2026-10-10',
            'start_time' => '20:00',
            'end_date' => '2026-10-11',
            'end_time' => '01:30',
            'end_date_time' => now()->addDays(30),
            'status' => 1,
            'is_featured' => 'no',
            'thumbnail' => 'reward-edit.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_contents')->insert([
            'event_id' => $eventId,
            'language_id' => $this->defaultLanguageId(),
            'event_category_id' => $categoryId,
            'title' => 'Reward Editable Event',
            'slug' => 'reward-editable-event',
            'description' => str_repeat('Editable reward copy ', 3),
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $rewardDefinitionId = (int) DB::table('event_reward_definitions')->insertGetId([
            'event_id' => $eventId,
            'title' => 'Legacy Welcome Drink',
            'description' => 'Legacy reward',
            'reward_type' => 'welcome_drink',
            'trigger_mode' => 'on_ticket_scan',
            'fulfillment_mode' => 'qr_claim',
            'per_ticket_quantity' => 1,
            'status' => 'active',
            'meta' => json_encode(['claim_code_prefix' => 'LEGACY']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('event_reward_instances')->insert([
            'event_id' => $eventId,
            'reward_definition_id' => $rewardDefinitionId,
            'booking_id' => null,
            'ticket_id' => null,
            'customer_id' => null,
            'ticket_unit_key' => '1',
            'instance_index' => 1,
            'claim_code' => 'LEGACY-000001-01-AAAA',
            'claim_qr_payload' => 'duty://event-reward-claim?code=LEGACY-000001-01-AAAA',
            'status' => 'reserved',
            'meta' => json_encode(['reward_type' => 'welcome_drink']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs(Customer::findOrFail(101), [], 'sanctum');

        $response = $this->withHeader('X-Identity-Id', (string) $identityId)->post(
            $this->apiUrl("/api/customers/professional/events/{$eventId}"),
            [
                'event_id' => $eventId,
                'gallery_images' => 1,
                'event_type' => 'venue',
                'date_type' => 'single',
                'status' => 1,
                'is_featured' => 'no',
                'start_date' => '2026-10-10',
                'start_time' => '20:00',
                'end_date' => '2026-10-11',
                'end_time' => '01:30',
                'venue_source' => 'registered',
                'venue_id' => $venueId,
                'reward_definitions_payload' => json_encode([], JSON_THROW_ON_ERROR),
                'en_title' => 'Reward Editable Event',
                'en_category_id' => $categoryId,
                'en_description' => str_repeat('Editable reward copy ', 3),
                'en_refund_policy' => 'Policy',
                'en_meta_keywords' => 'reward,edit',
                'en_meta_description' => 'Reward edit event',
                'latitude' => '18.4900',
                'longitude' => '-69.9300',
            ]
        );

        $response->assertOk();
        $response->assertJsonCount(0, 'data.reward_definitions');

        $this->assertDatabaseHas('event_reward_definitions', [
            'id' => $rewardDefinitionId,
            'event_id' => $eventId,
            'status' => 'inactive',
        ]);

        $archivedMeta = json_decode((string) DB::table('event_reward_definitions')
            ->where('id', $rewardDefinitionId)
            ->value('meta'), true);

        $this->assertTrue((bool) ($archivedMeta['archived_from_authoring_sync'] ?? false));
        $this->assertDatabaseHas('event_reward_instances', [
            'reward_definition_id' => $rewardDefinitionId,
            'claim_code' => 'LEGACY-000001-01-AAAA',
        ]);
    }

    private function ensureProfessionalEventSchema(): void
    {
        $this->ensureIdentityTables();
        $this->ensureLegacyIdentitySourceTables();
        $this->ensureEventTreasuryTables();

        if (!Schema::hasTable('basic_settings')) {
            Schema::create('basic_settings', function (Blueprint $table) {
                $table->id();
                $table->tinyInteger('event_country_status')->default(0);
                $table->tinyInteger('event_state_status')->default(0);
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('photo')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('address')->nullable();
                $table->string('city')->nullable();
                $table->string('state')->nullable();
                $table->string('country')->nullable();
                $table->string('zip_code')->nullable();
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->tinyInteger('status')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('event_categories')) {
            Schema::create('event_categories', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('language_id');
                $table->string('name');
                $table->tinyInteger('status')->default(1);
                $table->unsignedInteger('serial_number')->default(1);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('venue_id')->nullable();
                $table->unsignedBigInteger('organizer_id')->nullable();
                $table->unsignedBigInteger('owner_identity_id')->nullable();
                $table->unsignedBigInteger('venue_identity_id')->nullable();
                $table->string('venue_source', 32)->nullable();
                $table->string('venue_name_snapshot')->nullable();
                $table->string('venue_address_snapshot')->nullable();
                $table->string('venue_city_snapshot')->nullable();
                $table->string('venue_state_snapshot')->nullable();
                $table->string('venue_country_snapshot')->nullable();
                $table->string('venue_postal_code_snapshot')->nullable();
                $table->string('venue_google_place_id')->nullable();
                $table->string('thumbnail')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->integer('age_limit')->nullable();
                $table->tinyInteger('countdown_status')->default(1);
                $table->string('date_type')->nullable();
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->string('duration')->nullable();
                $table->date('end_date')->nullable();
                $table->string('end_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
                $table->string('is_featured')->nullable();
                $table->string('event_type')->nullable();
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->string('meeting_url')->nullable();
                $table->string('review_status', 40)->nullable();
                $table->text('review_notes')->nullable();
                $table->timestamp('reviewed_at')->nullable();
                $table->unsignedBigInteger('reviewed_by_admin_id')->nullable();
                $table->timestamps();
            });
        } else {
            foreach ([
                'venue_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_id')->nullable(),
                'organizer_id' => fn (Blueprint $table) => $table->unsignedBigInteger('organizer_id')->nullable(),
                'owner_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('owner_identity_id')->nullable(),
                'venue_identity_id' => fn (Blueprint $table) => $table->unsignedBigInteger('venue_identity_id')->nullable(),
                'venue_source' => fn (Blueprint $table) => $table->string('venue_source', 32)->nullable(),
                'venue_name_snapshot' => fn (Blueprint $table) => $table->string('venue_name_snapshot')->nullable(),
                'venue_address_snapshot' => fn (Blueprint $table) => $table->string('venue_address_snapshot')->nullable(),
                'venue_city_snapshot' => fn (Blueprint $table) => $table->string('venue_city_snapshot')->nullable(),
                'venue_state_snapshot' => fn (Blueprint $table) => $table->string('venue_state_snapshot')->nullable(),
                'venue_country_snapshot' => fn (Blueprint $table) => $table->string('venue_country_snapshot')->nullable(),
                'venue_postal_code_snapshot' => fn (Blueprint $table) => $table->string('venue_postal_code_snapshot')->nullable(),
                'venue_google_place_id' => fn (Blueprint $table) => $table->string('venue_google_place_id')->nullable(),
                'thumbnail' => fn (Blueprint $table) => $table->string('thumbnail')->nullable(),
                'status' => fn (Blueprint $table) => $table->tinyInteger('status')->default(1),
                'age_limit' => fn (Blueprint $table) => $table->integer('age_limit')->nullable(),
                'countdown_status' => fn (Blueprint $table) => $table->tinyInteger('countdown_status')->default(1),
                'date_type' => fn (Blueprint $table) => $table->string('date_type')->nullable(),
                'start_date' => fn (Blueprint $table) => $table->date('start_date')->nullable(),
                'start_time' => fn (Blueprint $table) => $table->string('start_time')->nullable(),
                'duration' => fn (Blueprint $table) => $table->string('duration')->nullable(),
                'end_date' => fn (Blueprint $table) => $table->date('end_date')->nullable(),
                'end_time' => fn (Blueprint $table) => $table->string('end_time')->nullable(),
                'is_featured' => fn (Blueprint $table) => $table->string('is_featured')->nullable(),
                'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
                'latitude' => fn (Blueprint $table) => $table->decimal('latitude', 10, 7)->nullable(),
                'longitude' => fn (Blueprint $table) => $table->decimal('longitude', 10, 7)->nullable(),
                'meeting_url' => fn (Blueprint $table) => $table->string('meeting_url')->nullable(),
                'review_status' => fn (Blueprint $table) => $table->string('review_status', 40)->nullable(),
                'review_notes' => fn (Blueprint $table) => $table->text('review_notes')->nullable(),
                'reviewed_at' => fn (Blueprint $table) => $table->timestamp('reviewed_at')->nullable(),
                'reviewed_by_admin_id' => fn (Blueprint $table) => $table->unsignedBigInteger('reviewed_by_admin_id')->nullable(),
            ] as $column => $definition) {
                if (!Schema::hasColumn('events', $column)) {
                    Schema::table('events', $definition);
                }
            }
        }

        if (!Schema::hasTable('event_contents')) {
            Schema::create('event_contents', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->unsignedBigInteger('language_id');
                $table->unsignedBigInteger('event_category_id');
                $table->string('title');
                $table->string('slug');
                $table->text('description')->nullable();
                $table->text('refund_policy')->nullable();
                $table->text('meta_keywords')->nullable();
                $table->text('meta_description')->nullable();
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
        } else {
            foreach ([
                'event_category_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_category_id')->nullable(),
                'title' => fn (Blueprint $table) => $table->string('title')->nullable(),
                'slug' => fn (Blueprint $table) => $table->string('slug')->nullable(),
                'description' => fn (Blueprint $table) => $table->text('description')->nullable(),
                'refund_policy' => fn (Blueprint $table) => $table->text('refund_policy')->nullable(),
                'meta_keywords' => fn (Blueprint $table) => $table->text('meta_keywords')->nullable(),
                'meta_description' => fn (Blueprint $table) => $table->text('meta_description')->nullable(),
                'address' => fn (Blueprint $table) => $table->string('address')->nullable(),
                'country' => fn (Blueprint $table) => $table->string('country')->nullable(),
                'state' => fn (Blueprint $table) => $table->string('state')->nullable(),
                'city' => fn (Blueprint $table) => $table->string('city')->nullable(),
                'zip_code' => fn (Blueprint $table) => $table->string('zip_code')->nullable(),
                'country_id' => fn (Blueprint $table) => $table->unsignedBigInteger('country_id')->nullable(),
                'state_id' => fn (Blueprint $table) => $table->unsignedBigInteger('state_id')->nullable(),
                'city_id' => fn (Blueprint $table) => $table->unsignedBigInteger('city_id')->nullable(),
            ] as $column => $definition) {
                if (!Schema::hasColumn('event_contents', $column)) {
                    Schema::table('event_contents', $definition);
                }
            }
        }

        if (!Schema::hasTable('event_dates')) {
            Schema::create('event_dates', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id');
                $table->date('start_date')->nullable();
                $table->string('start_time')->nullable();
                $table->date('end_date')->nullable();
                $table->string('end_time')->nullable();
                $table->string('duration')->nullable();
                $table->dateTime('start_date_time')->nullable();
                $table->dateTime('end_date_time')->nullable();
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
                $table->string('source_type', 32);
                $table->string('display_name');
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_headliner')->default(false);
                $table->timestamps();
            });
        } else {
            foreach ([
                'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
                'artist_id' => fn (Blueprint $table) => $table->unsignedBigInteger('artist_id')->nullable(),
                'source_type' => fn (Blueprint $table) => $table->string('source_type', 32)->nullable(),
                'display_name' => fn (Blueprint $table) => $table->string('display_name')->nullable(),
                'sort_order' => fn (Blueprint $table) => $table->unsignedInteger('sort_order')->default(0),
                'is_headliner' => fn (Blueprint $table) => $table->boolean('is_headliner')->default(false),
            ] as $column => $definition) {
                if (!Schema::hasColumn('event_lineups', $column)) {
                    Schema::table('event_lineups', $definition);
                }
            }
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->string('event_type')->nullable();
                $table->string('pricing_type')->nullable();
                $table->decimal('price', 15, 2)->nullable();
                $table->decimal('f_price', 15, 2)->nullable();
                $table->string('ticket_available_type')->nullable();
                $table->integer('ticket_available')->nullable();
                $table->string('max_ticket_buy_type')->nullable();
                $table->integer('max_buy_ticket')->nullable();
                $table->string('early_bird_discount')->nullable();
                $table->string('early_bird_discount_type')->nullable();
                $table->decimal('early_bird_discount_amount', 15, 2)->nullable();
                $table->date('early_bird_discount_date')->nullable();
                $table->string('early_bird_discount_time')->nullable();
                $table->string('meeting_url')->nullable();
                $table->boolean('reservation_enabled')->default(false);
                $table->string('reservation_deposit_type', 32)->nullable();
                $table->decimal('reservation_deposit_value', 15, 2)->nullable();
                $table->dateTime('reservation_final_due_date')->nullable();
                $table->decimal('reservation_min_installment_amount', 15, 2)->nullable();
                $table->timestamps();
            });
        } else {
            foreach ([
                'event_id' => fn (Blueprint $table) => $table->unsignedBigInteger('event_id')->nullable(),
                'event_type' => fn (Blueprint $table) => $table->string('event_type')->nullable(),
                'pricing_type' => fn (Blueprint $table) => $table->string('pricing_type')->nullable(),
                'price' => fn (Blueprint $table) => $table->decimal('price', 15, 2)->nullable(),
                'f_price' => fn (Blueprint $table) => $table->decimal('f_price', 15, 2)->nullable(),
                'ticket_available_type' => fn (Blueprint $table) => $table->string('ticket_available_type')->nullable(),
                'ticket_available' => fn (Blueprint $table) => $table->integer('ticket_available')->nullable(),
                'max_ticket_buy_type' => fn (Blueprint $table) => $table->string('max_ticket_buy_type')->nullable(),
                'max_buy_ticket' => fn (Blueprint $table) => $table->integer('max_buy_ticket')->nullable(),
                'early_bird_discount' => fn (Blueprint $table) => $table->string('early_bird_discount')->nullable(),
                'early_bird_discount_type' => fn (Blueprint $table) => $table->string('early_bird_discount_type')->nullable(),
                'early_bird_discount_amount' => fn (Blueprint $table) => $table->decimal('early_bird_discount_amount', 15, 2)->nullable(),
                'early_bird_discount_date' => fn (Blueprint $table) => $table->date('early_bird_discount_date')->nullable(),
                'early_bird_discount_time' => fn (Blueprint $table) => $table->string('early_bird_discount_time')->nullable(),
                'meeting_url' => fn (Blueprint $table) => $table->string('meeting_url')->nullable(),
                'reservation_enabled' => fn (Blueprint $table) => $table->boolean('reservation_enabled')->default(false),
                'reservation_deposit_type' => fn (Blueprint $table) => $table->string('reservation_deposit_type', 32)->nullable(),
                'reservation_deposit_value' => fn (Blueprint $table) => $table->decimal('reservation_deposit_value', 15, 2)->nullable(),
                'reservation_final_due_date' => fn (Blueprint $table) => $table->dateTime('reservation_final_due_date')->nullable(),
                'reservation_min_installment_amount' => fn (Blueprint $table) => $table->decimal('reservation_min_installment_amount', 15, 2)->nullable(),
            ] as $column => $definition) {
                if (!Schema::hasColumn('tickets', $column)) {
                    Schema::table('tickets', $definition);
                }
            }
        }

        if (!Schema::hasTable('ticket_price_schedules')) {
            Schema::create('ticket_price_schedules', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->string('label')->nullable();
                $table->dateTime('effective_from');
                $table->decimal('price', 15, 2);
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('ticket_reservations')) {
            Schema::create('ticket_reservations', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('ticket_id');
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedInteger('quantity')->default(1);
                $table->string('status')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bookings')) {
            Schema::create('bookings', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('event_id')->nullable();
                $table->unsignedBigInteger('ticket_id')->nullable();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedInteger('quantity')->default(1);
                $table->string('paymentStatus')->nullable();
                $table->string('status')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedOrganizerIdentity(): int
    {
        DB::table('users')->insert([
            'id' => 11,
            'email' => 'organizer-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 101,
            'email' => 'organizer-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => 11,
            'type' => 'organizer',
            'status' => 'active',
            'display_name' => 'Duty Organizer',
            'slug' => 'duty-organizer',
            'meta' => json_encode(['legacy_id' => 901]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => 11,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $identityId;
    }

    private function seedArtist(string $username, int $id = 31): int
    {
        DB::table('artists')->insert([
            'id' => $id,
            'name' => $username,
            'username' => $username,
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $id;
    }

    private function seedVenue(): int
    {
        DB::table('venues')->insert([
            'id' => 77,
            'name' => 'Duty Arena',
            'username' => 'duty-arena',
            'address' => 'Calle 50',
            'city' => 'Santo Domingo',
            'state' => 'Distrito Nacional',
            'country' => 'Dominican Republic',
            'zip_code' => '10210',
            'latitude' => 18.5000000,
            'longitude' => -69.9300000,
            'status' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return 77;
    }

    private function seedVenueIdentity(): array
    {
        DB::table('users')->insert([
            'id' => 22,
            'email' => 'venue-owner@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => 202,
            'email' => 'venue-owner@example.com',
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->seedVenue();

        $identityId = (int) DB::table('identities')->insertGetId([
            'owner_user_id' => 22,
            'type' => 'venue',
            'status' => 'active',
            'display_name' => 'Duty Arena',
            'slug' => 'duty-arena',
            'meta' => json_encode(['legacy_id' => 77]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identity_members')->insert([
            'identity_id' => $identityId,
            'user_id' => 22,
            'role' => 'owner',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return [$identityId, 202];
    }

    private function seedCategory(): int
    {
        return (int) DB::table('event_categories')->insertGetId([
            'language_id' => $this->defaultLanguageId(),
            'name' => 'Nightlife',
            'status' => 1,
            'serial_number' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function defaultLanguageId(): int
    {
        return (int) DB::table('languages')->where('is_default', 1)->value('id');
    }

    private function apiUrl(string $path): string
    {
        return 'http://localhost' . $path;
    }
}
