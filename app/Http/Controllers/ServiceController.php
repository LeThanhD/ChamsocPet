<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\Service;

class ServiceController extends Controller
{
    // ✅ Lấy danh sách dịch vụ với phân trang và tìm kiếm
    public function index(Request $request)
    {
        try {
            // Kiểm tra điều kiện phân trang và tìm kiếm
            $services = Service::when($request->has('search'), function($query) use ($request) {
                return $query->where('ServiceName', 'like', '%' . $request->search . '%');
            })
            ->paginate(10); // Lấy danh sách dịch vụ phân trang
           
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

    // ✅ Lấy danh sách dịch vụ theo từ khoá
    public function getList(Request $request)
    {
        // Lấy dữ liệu từ request
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';  // Lấy từ khóa tìm kiếm (nếu có)
        $data['page'] = $data['page'] ?? 1;        // Lấy trang (nếu có)

        try {
            // Tìm kiếm và phân trang dịch vụ
            $services = Service::where('ServiceName', 'like', '%' . $data['search'] . '%')
                ->paginate(10);  // Phân trang với 10 kết quả mỗi trang

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách dịch vụ thành công!',
                'data' => $services  // Trả về dữ liệu phân trang
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi lấy danh sách: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    // ✅ Lấy chi tiết dịch vụ theo ID
    public function getDetail($id)
    {
        try {
            $item = Service::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết dịch vụ thành công!',
                'data' => $item
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    // ✅ Thêm mới dịch vụ
    public function create(Request $request)
    {
        try {
            $request->validate([
                'ServiceName' => 'required|string|max:100',
                'Description' => 'nullable|string',
                'Price' => 'required|numeric',
                'CategoryID' => 'required|string|exists:servicecategories,CategoryID',
            ]);

            $service = Service::create([
                'ServiceName' => $request->ServiceName,
                'Description' => $request->Description,
                'Price' => $request->Price,
                'CategoryID' => $request->CategoryID
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tạo dịch vụ thành công!',
                'data' => $service
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi tạo dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    // ✅ Cập nhật dịch vụ
    public function update(Request $request, $id)
    {
        try {
            $service = Service::findOrFail($id);

            $request->validate([
                'ServiceName' => 'sometimes|string|max:100',
                'Description' => 'nullable|string',
                'Price' => 'sometimes|numeric',
                'CategoryID' => 'sometimes|string|exists:servicecategories,CategoryID',
            ]);

            $service->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật dịch vụ thành công!',
                'data' => $service
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi cập nhật: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    // ✅ Xoá dịch vụ
    public function delete($id)
    {
        try {
            $service = Service::findOrFail($id);
            $service->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa dịch vụ thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa dịch vụ: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
