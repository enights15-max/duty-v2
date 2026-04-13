<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('loyalty_rules')) {
            Schema::create('loyalty_rules', function (Blueprint $table) {
                $table->id();
                $table->string('code', 64)->unique();
                $table->string('label');
                $table->string('description')->nullable();
                $table->integer('points')->default(0);
                $table->boolean('is_active')->default(true);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('loyalty_point_transactions')) {
            Schema::create('loyalty_point_transactions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('rule_id')->nullable();
                $table->string('type', 16)->default('credit');
                $table->integer('points');
                $table->integer('balance_after');
                $table->string('reference_type', 64);
                $table->string('reference_id', 128);
                $table->string('idempotency_key', 191)->unique();
                $table->json('meta')->nullable();
                $table->timestamps();

                $table->index(['customer_id', 'id']);
                $table->index(['reference_type', 'reference_id']);
            });
        }

        if (!Schema::hasTable('reward_catalog')) {
            Schema::create('reward_catalog', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->string('description')->nullable();
                $table->string('reward_type', 32)->default('bonus_credit');
                $table->integer('points_cost');
                $table->decimal('bonus_amount', 10, 2)->nullable();
                $table->boolean('is_active')->default(true);
                $table->boolean('is_featured')->default(false);
                $table->json('meta')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('reward_redemptions')) {
            Schema::create('reward_redemptions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('customer_id');
                $table->unsignedBigInteger('reward_id');
                $table->unsignedBigInteger('loyalty_transaction_id')->nullable();
                $table->uuid('bonus_transaction_id')->nullable();
                $table->string('reward_type', 32);
                $table->integer('points_cost');
                $table->string('status', 32)->default('processing');
                $table->json('meta')->nullable();
                $table->timestamp('fulfilled_at')->nullable();
                $table->timestamps();

                $table->index(['customer_id', 'status']);
            });
        }

        $now = now();

        if (Schema::hasTable('loyalty_rules') && Schema::hasColumn('loyalty_rules', 'code')) {
            $columns = array_flip(Schema::getColumnListing('loyalty_rules'));

            foreach ([
                [
                    'code' => 'event_purchase',
                    'label' => 'Compra de evento',
                    'description' => 'Puntos otorgados por una compra directa de tickets.',
                    'points' => 100,
                    'is_active' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'code' => 'marketplace_purchase',
                    'label' => 'Compra en marketplace',
                    'description' => 'Puntos otorgados por comprar tickets en blackmarket.',
                    'points' => 60,
                    'is_active' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'code' => 'published_review',
                    'label' => 'Review publicada',
                    'description' => 'Puntos otorgados cuando una review queda publicada.',
                    'points' => 25,
                    'is_active' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'code' => 'follow_accept',
                    'label' => 'Nuevo follow',
                    'description' => 'Puntos otorgados por seguir cuentas dentro de Duty.',
                    'points' => 10,
                    'is_active' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'code' => 'attendance_confirmed',
                    'label' => 'Asistencia confirmada',
                    'description' => 'Reservado para otorgar puntos al escanear entrada.',
                    'points' => 40,
                    'is_active' => false,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
            ] as $rule) {
                $payload = [];
                foreach ($rule as $column => $value) {
                    if (isset($columns[$column])) {
                        $payload[$column] = $value;
                    }
                }

                DB::table('loyalty_rules')->updateOrInsert(
                    ['code' => $rule['code']],
                    $payload
                );
            }
        }

        if (Schema::hasTable('reward_catalog') && Schema::hasColumn('reward_catalog', 'title')) {
            $columns = array_flip(Schema::getColumnListing('reward_catalog'));

            foreach ([
                [
                    'title' => 'Bono RD$50',
                    'description' => 'Canjea puntos por credito interno para tu proxima compra.',
                    'reward_type' => 'bonus_credit',
                    'points_cost' => 250,
                    'bonus_amount' => 50,
                    'is_active' => true,
                    'is_featured' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'title' => 'Bono RD$125',
                    'description' => 'Credito interno para compras de tickets o consumos futuros.',
                    'reward_type' => 'bonus_credit',
                    'points_cost' => 500,
                    'bonus_amount' => 125,
                    'is_active' => true,
                    'is_featured' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'title' => 'Perk VIP local',
                    'description' => 'Reward placeholder para perks manuales o benefits especiales.',
                    'reward_type' => 'perk',
                    'points_cost' => 1000,
                    'bonus_amount' => null,
                    'is_active' => true,
                    'is_featured' => false,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
            ] as $reward) {
                $payload = [];
                foreach ($reward as $column => $value) {
                    if (isset($columns[$column])) {
                        $payload[$column] = $value;
                    }
                }

                DB::table('reward_catalog')->updateOrInsert(
                    ['title' => $reward['title']],
                    $payload
                );
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('reward_redemptions');
        Schema::dropIfExists('reward_catalog');
        Schema::dropIfExists('loyalty_point_transactions');
        Schema::dropIfExists('loyalty_rules');
    }
};
