<?php

namespace Tests\Unit;

use App\Services\EventTicketNameResolverService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class EventTicketNameResolverServiceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureLanguagesTable();
        $this->ensureTicketContentsTable();

        Schema::disableForeignKeyConstraints();
        DB::table('ticket_contents')->delete();
        DB::table('languages')->delete();
        Schema::enableForeignKeyConstraints();
    }

    public function test_resolve_returns_preferred_language_title_when_available(): void
    {
        $service = app(EventTicketNameResolverService::class);

        DB::table('languages')->insert([
            'id' => 1,
            'name' => 'Spanish',
            'code' => 'es',
            'direction' => 'ltr',
            'is_default' => 1,
        ]);

        DB::table('ticket_contents')->insert([
            'ticket_id' => 77,
            'language_id' => 1,
            'title' => 'Entrada VIP',
        ]);

        $name = $service->resolve(77, 'Fallback', 1);

        $this->assertSame('Entrada VIP', $name);
    }

    public function test_resolve_falls_back_to_any_ticket_content_when_preferred_missing(): void
    {
        $service = app(EventTicketNameResolverService::class);

        DB::table('ticket_contents')->insert([
            'ticket_id' => 88,
            'language_id' => 2,
            'title' => 'General EN',
        ]);

        $name = $service->resolve(88, 'Fallback', 1);

        $this->assertSame('General EN', $name);
    }

    public function test_resolve_falls_back_to_ticket_title_when_no_content_exists(): void
    {
        $service = app(EventTicketNameResolverService::class);

        $name = $service->resolve(99, 'Fallback Title', 1);

        $this->assertSame('Fallback Title', $name);
    }

    public function test_resolve_uses_default_language_when_language_id_is_not_provided(): void
    {
        $service = app(EventTicketNameResolverService::class);

        DB::table('languages')->insert([
            'id' => 3,
            'name' => 'English',
            'code' => 'en',
            'direction' => 'ltr',
            'is_default' => 1,
        ]);

        DB::table('ticket_contents')->insert([
            'ticket_id' => 120,
            'language_id' => 3,
            'title' => 'Default Lang Title',
        ]);

        $name = $service->resolve(120, 'Fallback');

        $this->assertSame('Default Lang Title', $name);
    }

    public function test_resolve_returns_generated_ticket_label_when_everything_is_missing(): void
    {
        $service = app(EventTicketNameResolverService::class);

        $name = $service->resolve(456);

        $this->assertSame('Ticket #456', $name);
    }

    private function ensureLanguagesTable(): void
    {
        if (Schema::hasTable('languages')) {
            return;
        }

        Schema::create('languages', function (Blueprint $table): void {
            $table->increments('id');
            $table->string('name')->nullable();
            $table->string('code')->nullable();
            $table->string('direction')->nullable();
            $table->tinyInteger('is_default')->default(0);
            $table->timestamps();
        });
    }

    private function ensureTicketContentsTable(): void
    {
        if (Schema::hasTable('ticket_contents')) {
            return;
        }

        Schema::create('ticket_contents', function (Blueprint $table): void {
            $table->increments('id');
            $table->unsignedBigInteger('ticket_id');
            $table->unsignedBigInteger('language_id')->nullable();
            $table->string('title')->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }
}
