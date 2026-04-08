<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->string('review_status', 40)->nullable()->after('status');
            $table->text('review_notes')->nullable()->after('review_status');
            $table->timestamp('reviewed_at')->nullable()->after('review_notes');
            $table->unsignedBigInteger('reviewed_by_admin_id')->nullable()->after('reviewed_at');
        });

        DB::table('events')
            ->where('status', 1)
            ->update(['review_status' => 'approved']);

        DB::table('events')
            ->where('status', 0)
            ->where(function ($query) {
                $query->whereNotNull('owner_identity_id')
                    ->orWhereNotNull('venue_identity_id');
            })
            ->update(['review_status' => 'pending']);
    }

    public function down(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn([
                'review_status',
                'review_notes',
                'reviewed_at',
                'reviewed_by_admin_id',
            ]);
        });
    }
};
