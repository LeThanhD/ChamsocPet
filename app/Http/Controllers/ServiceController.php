<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;

class ServiceController extends Controller
{
    public function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = Service::where('ServiceName', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách dịch vụ thành công!',
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

    public function create(Request $request)
    {
        try {
            $request->validate([
                'ServiceName' => 'required|string|max:100',
                'Description' => 'nullable|string',
                'Price' => 'required|numeric',
                'CategoryID' => 'required|string|exists:servicecategories,CategoryID',
            ]);

            $count = Service::count();
            $serviceId = 'SERV' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $service = Service::create([
                'ServiceID' => $serviceId,
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
