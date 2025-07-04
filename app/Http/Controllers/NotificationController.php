<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Models\Users;
use App\Services\FirebaseService;

class NotificationController extends Controller
{
    // ✅ Gửi thông báo từ controller khác (có thêm data)
    public function send($userId, $message, $extraData = [])
    {
        $user = Users::find($userId);
        if (!$user || !$user->fcm_token) return;

        // Chuẩn bị dữ liệu gửi kèm
        $dataPayload = array_merge([
            'action' => 'payment_approved',
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ], $extraData);

        // Gửi FCM bằng FirebaseService
        $firebase = new FirebaseService();
        $firebase->sendNotificationWithData($user->fcm_token, 'Thông báo thanh toán', $message, $dataPayload);

        // Sinh mã NOTIxxx
        $latest = Notification::orderByDesc('id')->first();
        $nextIdNumber = 1;
        if ($latest && preg_match('/^NOTI(\d+)$/', $latest->id, $matches)) {
            $nextIdNumber = (int)$matches[1] + 1;
        }
        $notificationId = 'NOTI' . str_pad($nextIdNumber, 3, '0', STR_PAD_LEFT);

        // Lưu DB
        Notification::create([
            'id' => $notificationId,
            'user_id' => $userId,
            'title' => 'Thông báo thanh toán',
            'message' => $message,
            'is_read' => false,
        ]);
    }

    // ✅ Client gửi để tạo thông báo + gửi FCM
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|string',
            'title' => 'required|string',
            'message' => 'required|string',
        ]);

        $user = Users::find($request->user_id);
        if (!$user || !$user->fcm_token) {
            return response()->json(['message' => 'Không có token FCM'], 400);
        }

        // Gửi FCM bằng FirebaseService
        $firebase = new FirebaseService();
        try {
            $firebase->sendNotificationWithData($user->fcm_token, $request->title, $request->message, [
                'action' => 'payment_approved',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['message' => '❌ Lỗi gửi FCM', 'error' => $e->getMessage()], 500);
        }

        // Sinh mã NOTIxxx
        $latest = Notification::orderByDesc('id')->first();
        $nextIdNumber = 1;
        if ($latest && preg_match('/^NOTI(\d+)$/', $latest->id, $matches)) {
            $nextIdNumber = (int)$matches[1] + 1;
        }
        $notificationId = 'NOTI' . str_pad($nextIdNumber, 3, '0', STR_PAD_LEFT);

        // Lưu DB
        Notification::create([
            'id' => $notificationId,
            'user_id' => $request->user_id,
            'title' => $request->title,
            'message' => $request->message,
            'is_read' => false,
        ]);

        return response()->json(['message' => '📢 Đã gửi và lưu thông báo']);
    }

    // ✅ Lấy danh sách thông báo
    public function index(Request $request)
    {
        $userId = $request->query('UserID');
        $search = $request->query('search');

        if (!$userId) {
            return response()->json(['message' => 'Thiếu UserID'], 400);
        }

        $user = Users::where('UserID', $userId)->first();
        if (!$user) {
            return response()->json(['message' => 'Không tìm thấy người dùng'], 404);
        }

        $query = Notification::query();
        if ($user->Role !== 'staff') {
            $query->where('user_id', $user->UserID);
        }

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%$search%")
                  ->orWhere('message', 'like', "%$search%");
            });
        }

        $notifications = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $notifications
        ]);
    }

    // ✅ Trả về danh sách thông báo theo user
    public function getUserNotifications($userId)
    {
        return Notification::where('user_id', $userId)
            ->orderByDesc('id')
            ->get();
    }

    // ✅ Đánh dấu đã đọc
    public function markAsRead($id)
    {
        $notification = Notification::find($id);
        if (!$notification) {
            return response()->json(['message' => 'Không tìm thấy thông báo'], 404);
        }

        $notification->is_read = true;
        $notification->save();

        return response()->json(['message' => 'Đã đánh dấu đã đọc']);
    }

    // ✅ Xoá thông báo
    public function destroy($id)
    {
        $notification = Notification::find($id);
        if (!$notification) {
            return response()->json(['message' => 'Không tìm thấy thông báo'], 404);
        }

        $notification->delete();

        return response()->json(['message' => 'Đã xóa thông báo']);
    }
}
