<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ServiceCategories;

class ServiceCategoriesController extends Controller
{
    public function getList(Request $request)
{
    $data = $request->all();
    $data['search'] = $data['search'] ?? '';  // Lấy từ khóa tìm kiếm (nếu có)
    $data['page'] = $data['page'] ?? 1;        // Lấy trang (nếu có)
    $data['category'] = $data['category'] ?? ''; // Lọc theo CategoryID (nếu có)

    try {
        // Lọc theo tên dịch vụ và phân trang
        $query = Service::query();

        // Lọc theo CategoryID (nếu có)
        if ($data['category']) {
            $query->where('CategoryID', $data['category']);
        }

        // Tìm kiếm theo tên dịch vụ (nếu có)
        if ($data['search']) {
            $query->where('ServiceName', 'like', '%' . $data['search'] . '%');
        }

        // Phân trang với 10 kết quả mỗi trang
        $services = $query->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Lấy danh sách dịch vụ thành công!',
            'data' => $services
        ], 200);
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
            $item = ServiceCategories::findOrFail($id);
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

            $count = ServiceCategories::count();
            $categoryId = 'CAT' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $category = ServiceCategories::create([
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
            $category = ServiceCategories::findOrFail($id);
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
            $category = ServiceCategories::findOrFail($id);
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
