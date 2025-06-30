<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Models\Medications;

class MedicationsController extends Controller
{
    // ✅ Lấy danh sách thuốc với tìm kiếm + phân trang
    public function getList(Request $request)
    {
        $data['search'] = $request->input('search', '');
        $data['page'] = $request->input('page', 1);

        try {
            $list = Medications::where('Name', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get(['MedicationID', 'Name', 'Price', 'ImageURL', 'UsageInstructions']);

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

    // ✅ Lấy chi tiết thuốc theo ID
    public function getDetail($id)
    {
        try {
            $item = Medications::where('MedicationID', $id)->firstOrFail();

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

    // ✅ Tạo thuốc mới
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

    // ✅ Cập nhật thuốc
    public function update(Request $request, $id)
    {
        $medicine = Medications::where('MedicationID', $id)->first();

        if (!$medicine) {
            return response()->json(['message' => 'Không tìm thấy thuốc'], 404);
        }

        $medicine->update([
            'Name' => $request->input('Name'),
            'Price' => $request->input('Price'),
            'UsageInstructions' => $request->input('UsageInstructions'),
            'ImageURL' => $request->input('ImageURL'),
        ]);

        return response()->json([
            'message' => 'Cập nhật thành công',
            'data' => $medicine
        ], 200);
    }

    // ✅ Xóa thuốc
    public function delete($id, Request $request)
    {
        $role = $request->header('Role');

        if ($role !== 'staff') {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền xóa thuốc.',
            ], 403);
        }

        try {
            $medication = Medications::where('MedicationID', $id)->firstOrFail();
            $medication->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa thuốc thành công!',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa thuốc: ' . $e->getMessage(),
            ], 404);
        }
    }
}
