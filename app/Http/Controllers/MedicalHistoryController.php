<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\MedicalHistory;
use Illuminate\Support\Facades\Validator;

class MedicalHistoryController extends Controller
{
    // 1. Tạo lịch sử khám bệnh
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID' => 'required|exists:Pets,PetID',
            'VisitDate' => 'required|date',
            'Symptoms' => 'nullable|string',
            'Diagnosis' => 'nullable|string',
            'Treatment' => 'nullable|string',
            'Notes' => 'nullable|string',
            'UserID' => 'required|exists:Users,UserID',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history = MedicalHistory::create($request->all());
        return response()->json(['message' => 'Created successfully', 'data' => $history], 201);
    }

    // 2. Lấy toàn bộ hoặc 1 lịch sử
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $history = MedicalHistory::find($request->id);
            if (!$history) return response()->json(['message' => 'Not found'], 404);
            return response()->json($history);
        }

        return response()->json(MedicalHistory::all());
    }

    // 3. Cập nhật lịch sử
    public function update(Request $request, $id)
    {
        $history = MedicalHistory::find($id);
        if (!$history) return response()->json(['message' => 'Not found'], 404);

        $validator = Validator::make($request->all(), [
            'Symptoms' => 'nullable|string',
            'Diagnosis' => 'nullable|string',
            'Treatment' => 'nullable|string',
            'Notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $history->update($request->only(['Symptoms', 'Diagnosis', 'Treatment', 'Notes']));
        return response()->json(['message' => 'Updated successfully', 'data' => $history], 200);
    }

    // 4. Xóa lịch sử
    public function destroy($id)
    {
        $history = MedicalHistory::find($id);
        if (!$history) return response()->json(['message' => 'Not found'], 404);

        $history->delete();
        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
