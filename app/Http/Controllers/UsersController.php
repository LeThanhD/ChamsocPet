<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Users;

class UsersController extends Controller
{
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

    // ✅ Đăng nhập người dùng (KHÔNG ĐỤNG TỚI)
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required'
        ]);

        $user = Users::where('Username', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->PasswordHash)) {
            return response()->json(['message' => 'Sai tài khoản hoặc mật khẩu'], 401);
        }

        $token = $user->createToken('authToken')->plainTextToken;

        return response()->json([
        'token' => $token,
        'user'  => [
            'UserID'   => $user->UserID,
            'FullName' => $user->FullName,
            'Email'    => $user->Email,
            'Role'     => $user->Role,
            'Image'    => $user->ProfilePicture ?? '',
        ]
    ]);
    }

    // ✅ Đăng ký người dùng (KHÔNG ĐỤNG TỚI)
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
            'role'         => 'nullable|in:customer,staff,owner',
        ]);

        $user = new Users();
        $user->UserID = 'OWNER' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        $user->Username = $validated['username'];
        $user->PasswordHash = Hash::make($validated['password']);
        $user->Email = $validated['email'];
        $user->Phone = $validated['phone'];
        $user->FullName = $validated['full_name'];
        $user->BirthDate = $validated['birth_date'];
        $user->Address = $validated['address'];
        $user->NationalID = $validated['national_id'];
        $user->Gender = 1;
        $user->Role = $request->input('role', 'customer');
        $user->Status = 'active';
        $user->CreatedAt = now();
        $user->save();

        return response()->json(['message' => 'Người dùng đã được tạo thành công!'], 201);
    }


    // ✅ Lấy thông tin người dùng theo UserID (dùng trong Flutter ProfilePage)
    public function getUserById($id)
    {
        $user = Users::where('UserID', $id)->first();

        if (!$user) {
            return response()->json(['message' => 'Người dùng không tồn tại'], 404);
        }

        return response()->json([
            'name' => $user->FullName,
            'image' => is_string($user->ProfilePicture) ? $user->ProfilePicture : ''
    ]);

    }

    // ✅ Lấy danh sách người dùng
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

    // ✅ Cập nhật người dùng
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
            'password'     => 'nullable|min:8',
        ]);

        $user->fill([
            'Email'      => $validated['email'] ?? $user->Email,
            'Phone'      => $validated['phone'] ?? $user->Phone,
            'FullName'   => $validated['full_name'] ?? $user->FullName,
            'BirthDate'  => $validated['birth_date'] ?? $user->BirthDate,
            'Address'    => $validated['address'] ?? $user->Address,
            'NationalID' => $validated['national_id'] ?? $user->NationalID,
        ]);

        if ($request->filled('password')) {
            $user->PasswordHash = Hash::make($request->password);
        }

        $user->save();

        return response()->json(['message' => 'Người dùng đã được cập nhật!']);
    }

    // ✅ Xoá người dùng
    public function destroy($id)
    {
        $user = Users::where('UserID', $id)->firstOrFail();
        $user->delete();

        return response()->json(['message' => 'Người dùng đã được xóa!']);
    }

    // ✅ Đăng xuất
    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();
        return response()->json(['message' => 'Đăng xuất thành công']);
    }
}
