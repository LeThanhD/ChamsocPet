<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;
use App\Models\AppointmentHistory;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class AppointmentHistoryController extends Controller
{
    // ✅ Tạo mới lịch sử
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'AppointmentID' => 'required|exists:Appointments,AppointmentID',
            'StatusBefore'  => 'required|string',
            'StatusAfter'   => 'required|string',
            'Note'          => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history = AppointmentHistory::create([
            'HistoryID'     => 'HIS' . strtoupper(Str::random(6)),
            'AppointmentID' => $request->AppointmentID,
            'UpdatedAt'     => now(),
            'StatusBefore'  => $request->StatusBefore,
            'StatusAfter'   => $request->StatusAfter,
            'Note'          => $request->Note,
        ]);

        return response()->json([
            'message' => 'Lưu lịch sử thành công',
            'data'    => $history,
        ], 201);
    }

    // ✅ Lấy tất cả lịch sử (cho nhân viên)
    public function getAllHistories()
    {
        $histories = AppointmentHistory::with([
            'appointment.user',
            'appointment.pet',
            'appointment.service',
            'appointment.staff' // ✅ Thêm để lấy dữ liệu người phụ trách
        ])->orderBy('UpdatedAt', 'desc')->get();

        return response()->json([
            'success' => true,
            'data'    => $histories,
        ]);
    }

    // ✅ Lấy lịch sử theo UserID (chỉ hiển thị lịch sử của người dùng đó)
    public function getUserHistories(Request $request)
    {
        $userId = $request->query('UserID');
        if (!$userId) {
            return response()->json(['message' => 'Thiếu UserID'], 400);
        }

        $histories = AppointmentHistory::whereHas('appointment', function ($query) use ($userId) {
            $query->where('UserID', $userId);
        })->with([
            'appointment.user',
            'appointment.pet',
            'appointment.service',
            'appointment.staff' // ✅ Thêm để lấy dữ liệu người phụ trách
        ])->orderBy('UpdatedAt', 'desc')->get();

        return response()->json([
            'success' => true,
            'data'    => $histories,
        ]);
    }

    // ✅ Cập nhật thông tin lịch sử
    public function update(Request $request, $id)
    {
        $history = AppointmentHistory::find($id);
        if (!$history) {
            return response()->json(['message' => 'Không tìm thấy lịch sử'], 404);
        }

        $validator = Validator::make($request->all(), [
            'StatusBefore' => 'sometimes|required|string',
            'StatusAfter'  => 'sometimes|required|string',
            'Note'         => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history->update($request->only(['StatusBefore', 'StatusAfter', 'Note']));

        return response()->json([
            'message' => 'Cập nhật thành công',
            'data'    => $history,
        ]);
    }

    // ✅ Cập nhật trạng thái và tạo lịch sử nếu kết thúc
    public function updateStatus(Request $request, $id)
    {
        $appointment = Appointment::find($id);
        if (!$appointment) {
            return response()->json(['message' => 'Không tìm thấy cuộc hẹn'], 404);
        }

        $statusBefore = $appointment->Status;
        $statusAfter  = $request->input('Status');

        $appointment->Status = $statusAfter;
        $appointment->save();

        if ($statusAfter === 'Kết thúc') {
            AppointmentHistory::create([
                'HistoryID'     => 'HIS' . strtoupper(Str::random(6)),
                'AppointmentID' => $appointment->AppointmentID,
                'UpdatedAt'     => now(),
                'StatusBefore'  => $statusBefore,
                'StatusAfter'   => $statusAfter,
                'Note'          => 'Cuộc hẹn đã hoàn tất',
            ]);
        }

        return response()->json(['message' => 'Cập nhật trạng thái thành công']);
    }

    // ✅ Xoá lịch sử cuộc hẹn
    public function destroy($id)
    {
        $history = AppointmentHistory::find($id);
        if (!$history) {
            return response()->json(['message' => 'Không tìm thấy lịch sử'], 404);
        }

        $history->delete();
        return response()->json(['message' => 'Xoá thành công']);
    }
}
