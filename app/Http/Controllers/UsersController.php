<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    public function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = User::where(function ($query) use ($data) {
                $query->where("FullName", "like", "%" . $data['search'] . "%")
                      ->orWhere("Username", "like", "%" . $data['search'] . "%")
                      ->orWhere("Email", "like", "%" . $data['search'] . "%");
            })
            ->offset(($data['page'] - 1) * 10)
            ->limit(10)
            ->get();

            return response()->json([
                "success" => true,
                "message" => "Lấy danh sách người dùng thành công!",
                "data" => $list
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Không thể lấy danh sách người dùng! " . $e->getMessage(),
                "data" => []
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Username' => 'required|unique:users',
            'PasswordHash' => 'required',
            'FullName' => 'required',
            'Email' => 'required|email|unique:users',
            'Role' => 'in:staff,owner',
            'Status' => 'in:active,inactive,banned'
        ]);

        if ($validator->fails()) {
            return response()->json([
                "success" => false,
                "message" => "Dữ liệu không hợp lệ!",
                "errors" => $validator->errors()
            ], 422);
        }

        try {
            $user = User::create($request->all());
            return response()->json([
                "success" => true,
                "message" => "Thêm người dùng thành công!",
                "data" => $user
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "success" => false,
                "message" => "Không thể thêm người dùng! " . $e->getMessage(),
                "data" => []
            ], 500);
        }
    }
}
