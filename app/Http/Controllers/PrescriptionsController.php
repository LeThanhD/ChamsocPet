<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Prescriptions;

class PrescriptionsController extends Controller
{
    function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = Prescriptions::where('Dosage', 'like', '%' . $data['search'] . '%')
                ->orWhere('Frequency', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách đơn thuốc thành công!',
                'data' => $list
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi lấy danh sách: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    function getDetail($id)
    {
        try {
            $item = Prescriptions::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết đơn thuốc thành công!',
                'data' => $item
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy đơn thuốc: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    function create(Request $request)
    {
        try {
            $request->validate([
                'RecordID' => 'required|exists:medicalrecords,RecordID',
                'MedicationID' => 'required|exists:medications,MedicationID',
                'Dosage' => 'nullable|string|max:100',
                'Frequency' => 'nullable|string|max:100',
                'Duration' => 'nullable|string|max:100',
            ]);

            $count = Prescriptions::count();
            $prescriptionId = 'PRE' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $item = Prescriptions::create([
                'PrescriptionID' => $prescriptionId,
                'RecordID' => $request->RecordID,
                'MedicationID' => $request->MedicationID,
                'Dosage' => $request->Dosage,
                'Frequency' => $request->Frequency,
                'Duration' => $request->Duration,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tạo đơn thuốc thành công!',
                'data' => $item
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi tạo đơn thuốc: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function update(Request $request, $id)
    {
        try {
            $item = Prescriptions::findOrFail($id);
            $item->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật đơn thuốc thành công!',
                'data' => $item
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi cập nhật: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function delete($id)
    {
        try {
            $item = Prescriptions::findOrFail($id);
            $item->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa đơn thuốc thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa đơn thuốc: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
