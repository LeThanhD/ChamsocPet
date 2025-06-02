<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ServiceCategory;

class ServiceCategoryController extends Controller
{
    function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = ServiceCategory::where('CategoryName', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách loại dịch vụ thành công!',
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
            $item = ServiceCategory::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết loại dịch vụ thành công!',
                'data' => $item
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy loại dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    function create(Request $request)
    {
        try {
            $request->validate([
                'CategoryName' => 'required|string|max:100',
            ]);

            $count = ServiceCategory::count();
            $categoryId = 'CAT' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $category = ServiceCategory::create([
                'CategoryID' => $categoryId,
                'CategoryName' => $request->CategoryName
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tạo loại dịch vụ thành công!',
                'data' => $category
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi tạo loại dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function update(Request $request, $id)
    {
        try {
            $category = ServiceCategory::findOrFail($id);
            $category->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật loại dịch vụ thành công!',
                'data' => $category
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
            $category = ServiceCategory::findOrFail($id);
            $category->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa loại dịch vụ thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa loại dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
