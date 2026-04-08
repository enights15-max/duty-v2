<?php

namespace Tests\Feature;

use App\Services\NotificationService;
use App\Services\ReviewPromptNotificationService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Mockery;
use Tests\Support\ActorFeatureTestCase;

class ReviewPromptNotificationServiceTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = [];

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureSchema();
        $this->truncateTables([
            'review_prompt_deliveries',
            'customers',
            'users',
        ]);
    }

    public function test_notify_customer_marks_delivery_as_delivered_when_push_succeeds(): void
    {
        $this->seedCustomer(901);
        $deliveryId = $this->seedDelivery(901, 77, 55);

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')->once()->andReturn(true);
        $this->app->instance(NotificationService::class, $notificationService);

        app(ReviewPromptNotificationService::class)->notifyCustomerNowById(
            901,
            $this->promptPayload(),
            $deliveryId
        );

        $this->assertDatabaseHas('review_prompt_deliveries', [
            'id' => $deliveryId,
            'status' => 'delivered',
        ]);
        $this->assertNotNull(
            DB::table('review_prompt_deliveries')->where('id', $deliveryId)->value('delivered_at')
        );
    }

    public function test_notify_customer_marks_delivery_as_no_device_token_when_no_token_is_available(): void
    {
        $this->seedCustomer(902);
        $deliveryId = $this->seedDelivery(902, 78, 56);

        $notificationService = Mockery::mock(NotificationService::class);
        $notificationService->shouldReceive('notifyUser')->once()->andReturn(false);
        $this->app->instance(NotificationService::class, $notificationService);

        app(ReviewPromptNotificationService::class)->notifyCustomerNowById(
            902,
            $this->promptPayload(),
            $deliveryId
        );

        $this->assertDatabaseHas('review_prompt_deliveries', [
            'id' => $deliveryId,
            'status' => 'no_device_token',
        ]);

        $meta = json_decode((string) DB::table('review_prompt_deliveries')->where('id', $deliveryId)->value('meta'), true);
        $this->assertSame('review_prompt', $meta['notification']['data']['type'] ?? null);
    }

    public function test_notify_customer_marks_delivery_as_failed_when_customer_is_missing(): void
    {
        $deliveryId = $this->seedDelivery(999, 79, 57);

        app(ReviewPromptNotificationService::class)->notifyCustomerNowById(
            999,
            $this->promptPayload(),
            $deliveryId
        );

        $this->assertDatabaseHas('review_prompt_deliveries', [
            'id' => $deliveryId,
            'status' => 'failed',
        ]);
    }

    private function ensureSchema(): void
    {
        if (!Schema::hasTable('review_prompt_deliveries')) {
            Schema::create('review_prompt_deliveries', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->unsignedBigInteger('event_id');
                $table->string('status')->default('queued');
                $table->timestamp('dispatched_at')->nullable();
                $table->timestamp('delivered_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }
    }

    private function seedCustomer(int $id): void
    {
        DB::table('users')->insert([
            'id' => $id,
            'email' => "customer{$id}@example.com",
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('customers')->insert([
            'id' => $id,
            'email' => "customer{$id}@example.com",
            'password' => bcrypt('secret'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function seedDelivery(int $customerId, int $eventId, int $bookingId): int
    {
        return (int) DB::table('review_prompt_deliveries')->insertGetId([
            'customer_id' => $customerId,
            'booking_id' => $bookingId,
            'event_id' => $eventId,
            'status' => 'queued',
            'dispatched_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function promptPayload(): array
    {
        return [
            'event_id' => 77,
            'booking_id' => 55,
            'event_title' => 'Prompt Event',
            'targets' => [
                [
                    'target_type' => 'event',
                ],
            ],
        ];
    }
}
