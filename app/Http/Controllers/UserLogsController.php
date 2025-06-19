<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\UserLogs;

class UserLogsController extends Controller
{
    public function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $logs = UserLogs::where('ActionType', 'like', '%' . $data['search'] . '%')
                ->orderBy('ActionTime', 'desc')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách nhật ký người dùng thành công!',
                'data' => $logs
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi lấy danh sách: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    public function getDetail($id)
    {
        try {
            $log = UserLogs::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết nhật ký thành công!',
                'data' => $log
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy log: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    public function create(Request $request)
    {
        try {
            $request->validate([
                'UserID' => 'required|string|exists:users,UserID',
                'ActionType' => 'required|string|max:50',
                'ActionDetail' => 'nullable|string',
                'ActionTime' => 'nullable|date'
            ]);

            $count = UserLogs::count();
            $logId = 'USRLOG' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $log = UserLogs::create([
                'LogID' => $logId,
                'UserID' => $request->UserID,
                'ActionType' => $request->ActionType,
                'ActionDetail' => $request->ActionDetail,
                'ActionTime' => $request->ActionTime ?? now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tạo nhật ký người dùng thành công!',
                'data' => $log
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi tạo nhật ký: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $log = UserLogs::findOrFail($id);

            $request->validate([
                'UserID' => 'sometimes|string|exists:users,UserID',
                'ActionType' => 'sometimes|string|max:50',
                'ActionDetail' => 'nullable|string',
                'ActionTime' => 'nullable|date'
            ]);

            $log->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật nhật ký thành công!',
                'data' => $log
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi cập nhật: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    public function delete($id)
    {
        try {
            $log = UserLogs::findOrFail($id);
            $log->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa nhật ký thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa log: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
