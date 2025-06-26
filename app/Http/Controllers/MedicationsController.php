<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Medications;

class MedicationsController extends Controller
{
    // Lấy danh sách thuốc với tìm kiếm + phân trang
    public function getList(Request $request)
    {
        // Khách hàng có thể tìm kiếm thuốc và xem danh sách thuốc
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = Medications::where('Name', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get(['Name', 'Price', 'ImageURL', 'UsageInstructions']);

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


    // Lấy chi tiết thuốc theo ID
    // Lấy chi tiết thuốc cho khách hàng
    public function getDetail($id)
    {
        try {
            $item = Medications::findOrFail($id);  // Tìm thuốc theo ID
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

    // Tạo thuốc mới
    public function create(Request $request)
    {
        try {
            $request->validate([
                'Name' => 'required|string|max:100',
                'UsageInstructions' => 'nullable|string',
                'Quantity' => 'required|integer|min:0',
                'Unit' => 'required|string|max:20',
                'ImageURL' => 'nullable|url|max:255',
                'Price' => 'required|integer|min:0'
            ]);

            $count = Medications::count();
            $medicationId = 'MED' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $medication = Medications::create(array_merge(
                $request->only([
                    'Name',
                    'UsageInstructions',
                    'Quantity',
                    'Unit',
                    'ImageURL',
                    'Price'
                ]),
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

    // Cập nhật thuốc
    public function update(Request $request, $id)
    {
        try {
            $medication = Medications::findOrFail($id);
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

    // Xóa thuốc
    public function delete($id)
    {
        try {
            $medication = Medications::findOrFail($id);
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
