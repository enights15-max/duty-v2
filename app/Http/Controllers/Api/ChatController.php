<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\ChatMessage;
use App\Models\Customer;
use App\Models\Organizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get all conversations for the authenticated user/organizer.
     */
    public function index(Request $request)
    {
        $user = Auth::guard('sanctum')->user();

        if ($user instanceof Customer) {
            $chats = Chat::with('organizer.organizer_info')
                ->where('customer_id', $user->id)
                ->orderBy('last_message_at', 'desc')
                ->get();
        } elseif ($user instanceof Organizer) {
            $chats = Chat::with('customer')
                ->where('organizer_id', $user->id)
                ->orderBy('last_message_at', 'desc')
                ->get();
        } else {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return response()->json([
            'status' => 'success',
            'data' => $chats
        ]);
    }

    /**
     * Get messages for a specific chat.
     */
    public function show($id)
    {
        $user = Auth::guard('sanctum')->user();
        $chat = Chat::findOrFail($id);

        // Authorization check
        if (
            ($user instanceof Customer && $chat->customer_id != $user->id) ||
            ($user instanceof Organizer && $chat->organizer_id != $user->id)
        ) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $messages = ChatMessage::where('chat_id', $id)
            ->orderBy('created_at', 'asc')
            ->get();

        // Mark messages as read
        $senderType = $user instanceof Customer ? 'organizer' : 'customer';
        ChatMessage::where('chat_id', $id)
            ->where('sender_type', $senderType)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'status' => 'success',
            'data' => $messages
        ]);
    }

    /**
     * Send a new message.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'chat_id' => 'required|exists:chats,id',
            'message' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::guard('sanctum')->user();
        $chat = Chat::findOrFail($request->chat_id);

        if ($user instanceof Customer) {
            $senderId = $user->id;
            $senderType = 'customer';
        } elseif ($user instanceof Organizer) {
            $senderId = $user->id;
            $senderType = 'organizer';
        } else {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $message = ChatMessage::create([
            'chat_id' => $chat->id,
            'sender_id' => $senderId,
            'sender_type' => $senderType,
            'message' => $request->message,
        ]);

        // Update chat metadata
        $chat->update([
            'last_message' => $request->message,
            'last_message_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $message
        ]);
    }

    /**
     * Start or find a conversation between a customer and an organizer.
     */
    public function startChat(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'organizer_id' => 'required|exists:organizers,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::guard('sanctum')->user();
        if (!$user instanceof Customer) {
            return response()->json(['error' => 'Only customers can start a chat'], 403);
        }

        $chat = Chat::firstOrCreate([
            'customer_id' => $user->id,
            'organizer_id' => $request->organizer_id,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $chat
        ]);
    }

    /**
     * Get unread messages count for the user.
     */
    public function unreadCount()
    {
        $user = Auth::guard('sanctum')->user();

        if ($user instanceof Customer) {
            $count = ChatMessage::whereHas('chat', function ($q) use ($user) {
                $q->where('customer_id', $user->id);
            })->where('sender_type', 'organizer')
                ->where('is_read', false)
                ->count();
        } elseif ($user instanceof Organizer) {
            $count = ChatMessage::whereHas('chat', function ($q) use ($user) {
                $q->where('organizer_id', $user->id);
            })->where('sender_type', 'customer')
                ->where('is_read', false)
                ->count();
        } else {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return response()->json([
            'status' => 'success',
            'unread_count' => $count
        ]);
    }
}
