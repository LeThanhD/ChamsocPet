<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Models\Users;

class NotificationController extends Controller
{
    // ✅ Lấy danh sách thông báo theo UserID + tìm kiếm
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

        // Tạo query builder
        $query = Notification::query();

        if ($user->Role !== 'staff') {
            $query->where('user_id', $user->UserID);
        }

        // Nếu có từ khóa tìm kiếm
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

    // ✅ Đánh dấu thông báo là đã đọc
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

    // ✅ Tạo thông báo mới với ID dạng NOTI001, NOTI002,...
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|string|max:50',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
        ]);

        $latest = Notification::orderBy('id', 'desc')->first();
        $nextIdNumber = $latest ? (int) substr($latest->id, 4) + 1 : 1;
        $notificationId = 'NOTI' . str_pad($nextIdNumber, 3, '0', STR_PAD_LEFT);

        $notification = Notification::create([
            'id' => $notificationId,
            'user_id' => $request->user_id,
            'title' => $request->title,
            'message' => $request->message,
            'created_at' => now(),
        ]);

        return response()->json([
            'message' => 'Tạo thông báo thành công',
            'data' => $notification
        ]);
    }

    // ✅ Xóa thông báo
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
