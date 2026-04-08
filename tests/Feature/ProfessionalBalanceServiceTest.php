<?php

namespace Tests\Feature;

use App\Services\ProfessionalBalanceService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\Support\ActorFeatureTestCase;

class ProfessionalBalanceServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities', 'legacy_identity_sources', 'marketplace'];
    protected array $baselineTruncate = [
        'users',
        'identities',
        'identity_members',
        'organizers',
        'artists',
        'venues',
        'identity_balances',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureLegacyActorTables();
        $this->seedActors();
    }

    public function test_credit_organizer_balance_uses_identity_balance_as_canonical_without_mutating_legacy_mirror_by_default(): void
    {
        $service = app(ProfessionalBalanceService::class);

        $mutation = $service->creditOrganizerBalance(501, 41, 75);

        $this->assertSame(500.0, (float) $mutation['pre_balance']);
        $this->assertSame(575.0, (float) $mutation['after_balance']);

        $this->assertDatabaseHas('identity_balances', [
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 41,
            'balance' => 575,
        ]);

        $this->assertSame(500.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
    }

    public function test_debit_organizer_balance_reads_existing_identity_balance_without_mutating_legacy_mirror_by_default(): void
    {
        DB::table('identity_balances')->insert([
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 41,
            'balance' => 640,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->where('id', 41)->update(['amount' => 640]);

        $service = app(ProfessionalBalanceService::class);
        $mutation = $service->debitOrganizerBalance(501, 41, 90);

        $this->assertSame(640.0, (float) $mutation['pre_balance']);
        $this->assertSame(550.0, (float) $mutation['after_balance']);
        $this->assertSame(550.0, (float) DB::table('identity_balances')->where('identity_id', 501)->value('balance'));
        $this->assertSame(640.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
    }

    public function test_credit_artist_balance_uses_identity_balance_as_canonical_without_mutating_legacy_mirror_by_default(): void
    {
        $service = app(ProfessionalBalanceService::class);

        $mutation = $service->creditArtistBalance(601, 51, 25);

        $this->assertSame(200.0, (float) $mutation['pre_balance']);
        $this->assertSame(225.0, (float) $mutation['after_balance']);
        $this->assertDatabaseHas('identity_balances', [
            'identity_id' => 601,
            'legacy_type' => 'artist',
            'legacy_id' => 51,
            'balance' => 225,
        ]);
        $this->assertSame(200.0, (float) DB::table('artists')->where('id', 51)->value('amount'));
    }

    public function test_debit_venue_balance_reads_existing_identity_balance_without_mutating_legacy_mirror_by_default(): void
    {
        DB::table('identity_balances')->insert([
            'identity_id' => 701,
            'legacy_type' => 'venue',
            'legacy_id' => 61,
            'balance' => 450,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('venues')->where('id', 61)->update(['amount' => 450]);

        $service = app(ProfessionalBalanceService::class);
        $mutation = $service->debitVenueBalance(701, 61, 80);

        $this->assertSame(450.0, (float) $mutation['pre_balance']);
        $this->assertSame(370.0, (float) $mutation['after_balance']);
        $this->assertSame(370.0, (float) DB::table('identity_balances')->where('identity_id', 701)->value('balance'));
        $this->assertSame(450.0, (float) DB::table('venues')->where('id', 61)->value('amount'));
    }

    public function test_sync_legacy_mirror_copies_canonical_balance_explicitly_when_needed(): void
    {
        DB::table('identity_balances')->insert([
            'identity_id' => 501,
            'legacy_type' => 'organizer',
            'legacy_id' => 41,
            'balance' => 725,
            'last_synced_at' => now()->subHour(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->where('id', 41)->update(['amount' => 500]);

        $balance = app(ProfessionalBalanceService::class)->syncLegacyOrganizerMirror(501, 41);

        $this->assertSame(725.0, (float) $balance);
        $this->assertSame(725.0, (float) DB::table('organizers')->where('id', 41)->value('amount'));
    }

    private function ensureLegacyActorTables(): void
    {
        if (!Schema::hasTable('organizers')) {
            Schema::create('organizers', function (Blueprint $table): void {
                $table->id();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamp('email_verified_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('artists')) {
            Schema::create('artists', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamp('email_verified_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('venues')) {
            Schema::create('venues', function (Blueprint $table): void {
                $table->id();
                $table->string('name')->nullable();
                $table->string('username')->nullable();
                $table->string('email')->nullable();
                $table->string('password')->nullable();
                $table->tinyInteger('status')->default(1);
                $table->decimal('amount', 15, 2)->default(0);
                $table->timestamp('email_verified_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('identity_balances')) {
            Schema::create('identity_balances', function (Blueprint $table): void {
                $table->id();
                $table->unsignedBigInteger('identity_id')->unique();
                $table->string('legacy_type')->nullable();
                $table->unsignedBigInteger('legacy_id')->nullable();
                $table->decimal('balance', 15, 2)->default(0);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedActors(): void
    {
        DB::table('users')->insert([
            'id' => 1001,
            'email' => 'balance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('organizers')->insert([
            'id' => 41,
            'username' => 'balance-organizer',
            'email' => 'balance-organizer@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 500,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1002,
            'email' => 'artist-balance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('artists')->insert([
            'id' => 51,
            'name' => 'Balance Artist',
            'username' => 'balance-artist',
            'email' => 'balance-artist@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 200,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->insert([
            'id' => 1003,
            'email' => 'venue-balance-user@example.com',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('venues')->insert([
            'id' => 61,
            'name' => 'Balance Venue',
            'username' => 'balance-venue',
            'email' => 'balance-venue@example.com',
            'password' => bcrypt('secret'),
            'status' => 1,
            'amount' => 300,
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 501,
            'type' => 'organizer',
            'status' => 'active',
            'owner_user_id' => 1001,
            'display_name' => 'Balance Organizer Identity',
            'slug' => 'balance-organizer-identity',
            'meta' => json_encode(['legacy_id' => 41]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 601,
            'type' => 'artist',
            'status' => 'active',
            'owner_user_id' => 1002,
            'display_name' => 'Balance Artist Identity',
            'slug' => 'balance-artist-identity',
            'meta' => json_encode(['legacy_id' => 51]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('identities')->insert([
            'id' => 701,
            'type' => 'venue',
            'status' => 'active',
            'owner_user_id' => 1003,
            'display_name' => 'Balance Venue Identity',
            'slug' => 'balance-venue-identity',
            'meta' => json_encode(['legacy_id' => 61]),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
