<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pet;
use Illuminate\Support\Facades\Validator;

class PetController extends Controller
{
    public function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = Pet::where(function ($query) use ($data) {
                $query->where("Name", "like", "%" . $data['search'] . "%")
                      ->orWhere("Species", "like", "%" . $data['search'] . "%")
                      ->orWhere("Breed", "like", "%" . $data['search'] . "%");
            })
            ->offset(($data['page'] - 1) * 10)
            ->limit(10)
            ->get();

            return response()->json([
                "success" => true,
                "message" => "Lấy danh sách thú cưng thành công!",
                "data" => $list
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Không thể lấy danh sách thú cưng! " . $e->getMessage(),
                "data" => []
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Name' => 'required',
            'Species' => 'required',
            'Breed' => 'required',
            'BirthDate' => 'nullable|date',
            'Gender' => 'nullable|string|max:10',
            'Weight' => 'nullable|numeric',
            'FurColor' => 'nullable|string',
            'UserID' => 'required|exists:users,UserID'
        ]);

        if ($validator->fails()) {
            return response()->json([
                "success" => false,
                "message" => "Dữ liệu không hợp lệ!",
                "errors" => $validator->errors()
            ], 422);
        }

        try {
            $pet = Pet::create($request->all());
            return response()->json([
                "success" => true,
                "message" => "Thêm thú cưng thành công!",
                "data" => $pet
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Không thể thêm thú cưng! " . $e->getMessage(),
                "data" => []
            ], 500);
        }
    }
}
