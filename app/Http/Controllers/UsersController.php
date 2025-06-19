<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Users;

class UsersController extends Controller
{
    // Tạo mã UserID dựa trên vai trò
    private function generateUserID($role)
    {
        $prefix = strtoupper($role);
        $latestUser = Users::where('Role', $role)
            ->where('UserID', 'like', $prefix . '%')
            ->orderBy('UserID', 'desc')
            ->first();

        $newNumber = $latestUser
            ? intval(substr($latestUser->UserID, strlen($prefix))) + 1
            : 1;

        return $prefix . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
    }

    // Tạo người dùng mới
    public function store(Request $request)
    {
        $validated = $request->validate([
            'username'     => 'required|unique:Users,Username',
            'password'     => 'required|min:8',
            'email'        => 'required|email|unique:Users,Email',
            'phone'        => ['required', 'regex:/^(0|\+84)[0-9]{9,10}$/'],
            'full_name'    => 'required',
            'birth_date'   => 'required|date',
            'address'      => 'required',
            'national_id'  => ['required', 'digits_between:9,12', 'unique:Users,NationalID'],
        ]);

        $role = 'owner'; // có thể lấy từ $request nếu client truyền lên

        $user = new Users();
        $user->UserID         = $this->generateUserID($role);
        $user->Username       = $validated['username'];
        $user->PasswordHash   = Hash::make($validated['password']);
        $user->Email          = $validated['email'];
        $user->Phone          = $validated['phone'];
        $user->FullName       = $validated['full_name'];
        $user->BirthDate      = $validated['birth_date'];
        $user->Address        = $validated['address'];
        $user->NationalID     = $validated['national_id'];
        $user->Gender         = 1;
        $user->ProfilePicture = null;
        $user->Role           = $role;
        $user->Status         = 'active';

        $user->save();

        return response()->json(['message' => 'Người dùng đã được tạo thành công!'], 201);
    }

    // Lấy danh sách người dùng (có phân trang & tìm kiếm)
    public function getList($page = 1, $search = '')
    {
        $query = Users::query();

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('Username', 'like', "%$search%")
                  ->orWhere('FullName', 'like', "%$search%")
                  ->orWhere('Email', 'like', "%$search%");
            });
        }

        $users = $query->paginate(10, ['*'], 'page', $page);

        return response()->json($users);
    }

    // Cập nhật người dùng
    public function update(Request $request, $id)
{
    $user = Users::where('UserID', $id)->firstOrFail();

    $validated = $request->validate([
        'email'        => "nullable|email|unique:Users,Email,$id,UserID",
        'phone'        => ['nullable', 'regex:/^(0|\+84)[0-9]{9,10}$/'],
        'full_name'    => 'nullable|string',
        'birth_date'   => 'nullable|date',
        'address'      => 'nullable|string',
        'national_id'  => "nullable|digits_between:9,12|unique:Users,NationalID,$id,UserID",
        'password'     => 'nullable|min:8', // ✅ thêm validate password nếu có
    ]);

    $user->fill([
        'Email'      => $validated['email'] ?? $user->Email,
        'Phone'      => $validated['phone'] ?? $user->Phone,
        'FullName'   => $validated['full_name'] ?? $user->FullName,
        'BirthDate'  => $validated['birth_date'] ?? $user->BirthDate,
        'Address'    => $validated['address'] ?? $user->Address,
        'NationalID' => $validated['national_id'] ?? $user->NationalID,
    ]);

    // ✅ Nếu người dùng có gửi mật khẩu mới
    if ($request->filled('password')) {
        $user->PasswordHash = Hash::make($request->password);
    }

    $user->save();

    return response()->json(['message' => 'Người dùng đã được cập nhật!']);
}


    // Xóa người dùng
    public function destroy($id)
    {
        $user = Users::where('UserID', $id)->firstOrFail();
        $user->delete();

        return response()->json(['message' => 'Người dùng đã được xóa!']);
    }

    public function login(Request $request)
{
    $request->validate([
        'username' => 'required',
        'password' => 'required',
    ]);

    $user = Users::where('Username', $request->username)->first();

    if (!$user || !Hash::check($request->password, $user->PasswordHash)) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $token = $user->createToken('api_token')->plainTextToken;

    return response()->json([
        'message' => 'Đăng nhập thành công',
        'token' => $token,
        'user' => [
            'id' => $user->UserID,
            'username' => $user->Username,
            'email' => $user->Email
        ]
    ]);
}


    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();
        return response()->json(['message' => 'Đăng xuất thành công']);
    }

}
