<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AppointmentHistory;
use Illuminate\Support\Facades\Validator;

class AppointmentHistoryController extends Controller
{
    // Tạo mới lịch sử cuộc hẹn
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'AppointmentID' => 'required|exists:Appointments,AppointmentID',
            'StatusBefore' => 'required|string',
            'StatusAfter' => 'required|string',
            'Note' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history = AppointmentHistory::create($request->all());
        return response()->json(['message' => 'Created successfully', 'data' => $history], 201);
    }

    // Cập nhật lịch sử cuộc hẹn
    public function update(Request $request, $id)
    {
        $history = AppointmentHistory::find($id);
        if (!$history) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'StatusBefore' => 'sometimes|required|string',
            'StatusAfter' => 'sometimes|required|string',
            'Note' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history->update($request->only(['StatusBefore', 'StatusAfter', 'Note']));
        return response()->json(['message' => 'Updated successfully', 'data' => $history], 200);
    }

    // Xóa lịch sử cuộc hẹn
    public function destroy($id)
    {
        $history = AppointmentHistory::find($id);
        if (!$history) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $history->delete();
        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
