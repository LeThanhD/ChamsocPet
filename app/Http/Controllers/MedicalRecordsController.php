<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\MedicalRecords;

class MedicalRecordsController extends Controller
{
    function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = MedicalRecords::where(function ($query) use ($data) {
                $query->where("Diagnosis", "like", "%" . $data['search'] . "%")
                      ->orWhere("Treatment", "like", "%" . $data['search'] . "%");
            })
            ->offset(($data['page'] - 1) * 10)
            ->limit(10)
            ->get();

            return response()->json([
                "success" => true,
                "message" => "Lấy danh sách hồ sơ y tế thành công!",
                "data" => $list
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Lấy danh sách thất bại! " . $e->getMessage(),
                "data" => []
            ], 500);
        }
    }

    function getDetail($id)
    {
        try {
            $record = MedicalRecords::findOrFail($id);
            return response()->json([
                "success" => true,
                "message" => "Lấy chi tiết hồ sơ y tế thành công!",
                "data" => $record
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Không tìm thấy hồ sơ y tế! " . $e->getMessage(),
                "data" => null
            ], 404);
        }
    }

    function create(Request $request)
    {
        try {
            $request->validate([
                'PetID' => 'required|exists:pets,PetID',
                'UserID' => 'required|exists:users,UserID',
                'Diagnosis' => 'nullable|string',
                'Treatment' => 'nullable|string',
                'RecordDate' => 'required|date',
            ]);

            $recordId = $request->PetID . '_' . $request->UserID . '_' . date('Ymd', strtotime($request->RecordDate));
            $record = MedicalRecords::create(array_merge($request->all(), ['RecordID' => $recordId]));

            return response()->json([
                "success" => true,
                "message" => "Tạo hồ sơ y tế thành công!",
                "data" => $record
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Tạo thất bại! " . $e->getMessage(),
                "data" => null
            ], 500);
        }
    }

    function update(Request $request, $id)
    {
        try {
            $record = MedicalRecords::findOrFail($id);
            $record->update($request->all());

            return response()->json([
                "success" => true,
                "message" => "Cập nhật hồ sơ y tế thành công!",
                "data" => $record
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Cập nhật thất bại! " . $e->getMessage(),
                "data" => null
            ], 500);
        }
    }

    function delete($id)
    {
        try {
            $record = MedicalRecords::findOrFail($id);
            $record->delete();

            return response()->json([
                "success" => true,
                "message" => "Xóa hồ sơ y tế thành công!",
                "data" => null
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Xóa thất bại! " . $e->getMessage(),
                "data" => null
            ], 500);
        }
    }
}
