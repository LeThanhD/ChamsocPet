<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Models\Users;
use App\Services\FirebaseService;
use App\Models\Appointment;
use App\Models\AppointmentHistory;
use App\Models\Invoices;
use DB;
use Str;

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
        $nextNumber = 1;

        if ($latest && preg_match('/^NOTI(\d+)$/', $latest->id, $matches)) {
            $nextNumber = (int)$matches[1] + 1;  // Đảm bảo làm việc với kiểu số ở đây
        }

        $notificationId = 'NOTI' . str_pad($nextNumber, 3, '0', STR_PAD_LEFT);

        // Lưu DB
        Notification::create([
            'id' => $notificationId,
            'user_id' => $userId,
            'title' => 'Thông báo thanh toán',
            'message' => $message,
            'is_read' => false,
        ]);
    }

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

    // ✅ Đánh dấu đã đọc
    public function markAsRead($id)
    {
        $notification = Notification::find($id);

        if (!$notification) {
            return response()->json(['message' => 'Thông báo không tồn tại'], 404);
        }

        $notification->is_read = true;
        $notification->save();

        return response()->json(['message' => 'Đã đánh dấu đã đọc']);
    }


    // ✅ Xoá lịch hẹn và gửi thông báo đẩy
   public function destroy($id)
{
    // Tìm thông báo theo ID
    $notification = Notification::find($id);

    // Nếu không tìm thấy
    if (!$notification) {
        return response()->json([
            'status' => 'error',
            'message' => 'Không tìm thấy thông báo với ID: ' . $id
        ], 404);
    }

    // Xóa thông báo
    $notification->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Thông báo đã được xóa.',
        'notification_id' => $id,
    ], 200);
}
}
