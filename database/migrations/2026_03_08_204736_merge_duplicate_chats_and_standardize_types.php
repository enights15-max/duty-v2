<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use App\Models\Chat;
use App\Models\ChatMessage;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Standardize types to full class names if they use shorthands
        // We'll do this for initiator_type, participant_type in chats
        // and sender_type in chat_messages

        $mapping = [
            'customer' => 'App\\Models\\Customer',
            'organizer' => 'App\\Models\\Organizer',
            'artist' => 'App\\Models\\Artist',
            'venue' => 'App\\Models\\Venue',
        ];

        foreach ($mapping as $short => $full) {
            DB::table('chats')->where('initiator_type', $short)->update(['initiator_type' => $full]);
            DB::table('chats')->where('participant_type', $short)->update(['participant_type' => $full]);
            DB::table('chat_messages')->where('sender_type', $short)->update(['sender_type' => $full]);
        }

        // 2. Merge duplicate bidirectional chats
        $chats = DB::table('chats')->get();
        $processed = [];

        foreach ($chats as $chat) {
            if (in_array($chat->id, $processed))
                continue;

            // Find the opposite chat
            $duplicate = DB::table('chats')
                ->where('id', '!=', $chat->id)
                ->where('initiator_id', $chat->participant_id)
                ->where('initiator_type', $chat->participant_type)
                ->where('participant_id', $chat->initiator_id)
                ->where('participant_type', $chat->initiator_type)
                ->first();

            if ($duplicate) {
                // Move messages from duplicate (higher ID usually, but we'll take the first one as primary)
                DB::table('chat_messages')
                    ->where('chat_id', $duplicate->id)
                    ->update(['chat_id' => $chat->id]);

                // Update primary chat's last_message if the duplicate has a newer one
                if ($duplicate->last_message_at > $chat->last_message_at) {
                    DB::table('chats')->where('id', $chat->id)->update([
                        'last_message' => $duplicate->last_message,
                        'last_message_at' => $duplicate->last_message_at,
                    ]);
                }

                // Delete the duplicate
                DB::table('chats')->where('id', $duplicate->id)->delete();
                $processed[] = $duplicate->id;
            }

            $processed[] = $chat->id;
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No easy way to separate merged chats without data loss or tracking, 
        // so we'll just leave them merged.
    }
};
