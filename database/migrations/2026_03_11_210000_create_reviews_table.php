<?php

use App\Models\Organizer;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->unsignedBigInteger('event_id')->nullable();
            $table->unsignedBigInteger('reviewable_id');
            $table->string('reviewable_type');
            $table->tinyInteger('rating');
            $table->text('comment')->nullable();
            $table->string('status')->default('published');
            $table->json('meta')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();

            $table->index(['customer_id', 'status'], 'reviews_customer_status_idx');
            $table->index(['reviewable_type', 'reviewable_id', 'status'], 'reviews_target_status_idx');
            $table->unique(
                ['customer_id', 'event_id', 'reviewable_type', 'reviewable_id'],
                'reviews_customer_event_target_unique'
            );
        });

        if (Schema::hasTable('organizer_reviews')) {
            $legacy = DB::table('organizer_reviews')->get();
            foreach ($legacy as $row) {
                DB::table('reviews')->updateOrInsert(
                    [
                        'customer_id' => $row->customer_id,
                        'event_id' => null,
                        'reviewable_type' => Organizer::class,
                        'reviewable_id' => $row->organizer_id,
                    ],
                    [
                        'booking_id' => null,
                        'rating' => $row->rating,
                        'comment' => $row->comment,
                        'status' => 'published',
                        'meta' => json_encode(['source' => 'organizer_reviews']),
                        'submitted_at' => $row->created_at,
                        'created_at' => $row->created_at,
                        'updated_at' => $row->updated_at,
                    ]
                );
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
