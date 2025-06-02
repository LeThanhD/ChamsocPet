<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Medication;

class MedicationController extends Controller
{
    function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = Medication::where('Name', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách thuốc thành công!',
                'data' => $list
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi lấy danh sách: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    function getDetail($id)
    {
        try {
            $item = Medication::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy thông tin thuốc thành công!',
                'data' => $item
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy thuốc: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    function create(Request $request)
    {
        try {
            $request->validate([
                'Name' => 'required|string|max:100',
                'UsageInstructions' => 'nullable|string',
                'Quantity' => 'required|integer|min:0',
                'Unit' => 'required|string|max:20',
            ]);

            $count = Medication::count();
            $medicationId = 'MED' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $medication = Medication::create(array_merge(
                $request->all(),
                ['MedicationID' => $medicationId]
            ));

            return response()->json([
                'success' => true,
                'message' => 'Tạo thuốc thành công!',
                'data' => $medication
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi tạo thuốc: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function update(Request $request, $id)
    {
        try {
            $medication = Medication::findOrFail($id);
            $medication->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật thuốc thành công!',
                'data' => $medication
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
            $medication = Medication::findOrFail($id);
            $medication->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa thuốc thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa thuốc: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
