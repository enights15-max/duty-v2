<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {

        if (!Schema::hasTable('fcm_tokens')) {
            return;
        }
        Schema::table('fcm_tokens', function (Blueprint $table) {
            $table->string('message_title')->nullable();
            $table->text('message_description')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('fcm_tokens', function (Blueprint $table) {
            $table->dropColumn('message_title');
            $table->dropColumn('message_description');
        });
    }
};
