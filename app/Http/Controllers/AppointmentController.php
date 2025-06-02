<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;
use Illuminate\Support\Facades\Validator;

class AppointmentController extends Controller
{
    // 1. Tạo cuộc hẹn mới
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID' => 'required|exists:Pets,PetID',
            'UserID' => 'required|exists:Users,UserID',
            'AppointmentDate' => 'required|date',
            'AppointmentTime' => 'required|date_format:H:i:s',
            'Reason' => 'required|string',
            'Status' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $appointment = Appointment::create($request->all());
        return response()->json(['message' => 'Created successfully', 'data' => $appointment], 201);
    }

    // 2. Lấy danh sách hoặc 1 cuộc hẹn
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $appointment = Appointment::find($request->id);
            if (!$appointment) return response()->json(['message' => 'Not found'], 404);
            return response()->json($appointment);
        }

        return response()->json(Appointment::all());
    }

    // 3. Cập nhật thông tin cuộc hẹn
    public function update(Request $request, $id)
    {
        $appointment = Appointment::find($id);
        if (!$appointment) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'AppointmentDate' => 'sometimes|date',
            'AppointmentTime' => 'sometimes|date_format:H:i:s',
            'Reason' => 'sometimes|string',
            'Status' => 'sometimes|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $appointment->update($request->only(['AppointmentDate', 'AppointmentTime', 'Reason', 'Status']));
        return response()->json(['message' => 'Updated successfully', 'data' => $appointment], 200);
    }

    // 4. Xóa cuộc hẹn
    public function destroy($id)
    {
        $appointment = Appointment::find($id);
        if (!$appointment) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $appointment->delete();
        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
