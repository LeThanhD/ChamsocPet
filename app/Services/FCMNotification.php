<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FCMNotification
{
    protected static function messaging()
    {
        // Đọc từ file JSON bạn tải về từ Firebase Console
        return (new Factory)
            ->withServiceAccount(base_path('firebase/firebase_credentials.json')) // đổi path nếu khác
            ->createMessaging();
    }

    public static function sendToUser($token, $title, $body)
    {
        $message = CloudMessage::withTarget('token', $token)
            ->withNotification(Notification::create($title, $body));

        return self::messaging()->send($message);
    }
}
