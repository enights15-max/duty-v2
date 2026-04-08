<?php

namespace App\Services;

use App\Models\FcmToken;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    public function notifyUser($user, string $title, string $body, array $data = [])
    {
        if (!$user || !is_object($user) || empty($user->id)) {
            Log::warning('NotificationService notifyUser skipped: invalid notifiable actor provided.');
            return false;
        }

        $tokens = FcmToken::where('user_id', $user->id)
            ->whereNotNull('token')
            ->pluck('token')
            ->toArray();

        if (empty($tokens)) {
            Log::info("No FCM tokens found for user ID: {$user->id}");
            return false;
        }

        return $this->sendMulticast($tokens, $title, $body, $data);
    }

    /**
     * Send a push notification to a list of tokens.
     */
    public function sendMulticast(array $tokens, string $title, string $body, array $data = [])
    {
        try {
            $messaging = $this->getMessaging();

            // FCM expects all data values to be strings
            $formattedData = array_map(function ($value) {
                return (string) $value;
            }, $data);

            $message = CloudMessage::new()
                ->withNotification(Notification::create($title, $body))
                ->withData($formattedData);

            $report = $messaging->sendMulticast($message, $tokens);

            if ($report->hasFailures()) {
                foreach ($report->failures()->getItems() as $failure) {
                    $token = $failure->target()->value();
                    // If target not found or unregistered, cleanup the token
                    if (
                        $failure->error()->getMessage() === 'Requested entity was not found.' ||
                        str_contains($failure->error()->getMessage(), 'unregistered')
                    ) {
                        FcmToken::where('token', $token)->delete();
                    }
                    Log::error("FCM Failure for token {$token}: " . $failure->error()->getMessage());
                }
            }

            return true;
        } catch (\Exception $e) {
            Log::error("NotificationService Error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Initialize Firebase Messaging.
     */
    protected function getMessaging()
    {
        $firebase_admin_json = DB::table('basic_settings')
            ->where('uniqid', 12345)
            ->value('firebase_admin_json');

        if (!$firebase_admin_json) {
            throw new \Exception("Firebase admin JSON not configured in basic_settings.");
        }

        $path = public_path('assets/file/') . $firebase_admin_json;

        if (!file_exists($path)) {
            // Fallback for local testing or different paths
            $path = storage_path('app/firebase/' . $firebase_admin_json);
            if (!file_exists($path)) {
                throw new \Exception("Firebase credentials file not found at {$path}");
            }
        }

        $factory = (new Factory)->withServiceAccount($path);
        return $factory->createMessaging();
    }
}
