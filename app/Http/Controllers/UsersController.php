<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use App\Models\Users;
use App\Models\Pet;
use App\Models\Appointment;
use App\Models\MedicalRecord;
use App\Models\Prescription;
use App\Models\Invoice;
use App\Models\UserLog;
use App\Models\Notification;

class UsersController extends Controller
{
    private function generateUserID($role)
    {
        if (!is_string($role)) {
            throw new \InvalidArgumentException('Role must be a string');
        }

        $prefix = strtoupper(trim($role));

        $latestUser = Users::whereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($role))])
            ->where('UserID', 'like', $prefix . '%')
            ->orderBy('UserID', 'desc')
            ->first();

        $newNumber = 1;
        if ($latestUser) {
            $userId = $latestUser->UserID;
            if (is_string($userId) && strlen($userId) > strlen($prefix)) {
                $numberPart = substr($userId, strlen($prefix));
                $newNumber = intval($numberPart) + 1;
            }
        }

        return $prefix . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
    }

    public function index(Request $request)
    {
        $role = $request->query('role');

        $query = Users::query();

        if ($role) {
            $query->whereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($role))]);
        }

        $users = $query->get(['UserID', 'FullName', 'Email', 'Role']);

        return response()->json(['data' => $users]);
    }

    public function sendResetCode(Request $request)
    {
        $request->validate([
            'username' => 'required|exists:users,Username',
            'phone' => 'required',
        ]);

        $user = Users::where('Username', $request->username)
                    ->where('Phone', $request->phone)
                    ->first();

        if (!$user) {
            return response()->json(['message' => 'Sai tên đăng nhập hoặc số điện thoại'], 400);
        }

        $code = rand(100000, 999999);
        $user->VerificationCode = $code;
        $user->save();

        return response()->json([
            'message' => 'Mã xác nhận đã được gửi',
            'code' => $code
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'phone' => 'required|exists:users,phone',
            'code' => 'required',
            'password' => 'required|min:6|confirmed',
        ]);

        $user = Users::where('Phone', $request->phone)->first();

        if ($user->VerificationCode !== $request->code) {
            return response()->json(['message' => 'Mã xác nhận không đúng'], 400);
        }

        $user->PasswordHash = bcrypt($request->password);
        $user->VerificationCode = null;
        $user->save();

        return response()->json(['message' => 'Mật khẩu đã được đổi thành công']);
    }

    public function forceResetPassword(Request $request)
    {
        $request->validate([
            'username' => 'required|exists:users,Username',
            'phone'    => 'required',
            'password' => 'required|min:6',
        ]);

        $user = Users::where('Username', $request->username)
                     ->where('Phone', $request->phone)
                     ->first();

        if (!$user) {
            return response()->json(['message' => 'Sai tên tài khoản hoặc số điện thoại'], 404);
        }

        $user->PasswordHash = bcrypt($request->password);
        $user->save();

        return response()->json(['message' => 'Mật khẩu đã được cập nhật thành công!'], 200);
    }

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
            'gender'       => 'nullable|in:0,1',
            'role'         => 'nullable|in:staff,owner',
        ]);

        $role = $validated['role'] ?? 'owner';
        $user = new Users();

        $user->UserID       = $this->generateUserID($role);
        $user->Username     = $validated['username'];
        $user->PasswordHash = Hash::make($validated['password']);
        $user->Email        = $validated['email'];
        $user->Phone        = $validated['phone'];
        $user->FullName     = $validated['full_name'];
        $user->BirthDate    = $validated['birth_date'];
        $user->Address      = $validated['address'];
        $user->NationalID   = $validated['national_id'];
        $user->Gender       = $validated['gender'] ?? 1;
        $user->Role         = $role;
        $user->Status       = 'active';
        $user->CreatedAt    = now();
        $user->save();

        return response()->json([
            'message' => 'Người dùng đã được tạo thành công!',
            'user_id' => $user->UserID,
        ], 201);
    }

    public function getUserById($id)
    {
        $user = Users::where('UserID', $id)->first();

        if (!$user) {
            return response()->json(['message' => 'Người dùng không tồn tại'], 404);
        }

        return response()->json([
            'id'          => $user->UserID,
            'name'        => $user->FullName,
            'gender'      => $user->Gender,
            'birth_date'  => $user->BirthDate,
            'address'     => $user->Address,
            'phone'       => $user->Phone,
            'email'       => $user->Email,
            'citizen_id'  => $user->NationalID,
            'image'       => is_string($user->ProfilePicture) ? $user->ProfilePicture : '',
        ]);
    }

    public function getList(Request $request)
    {
        $page = (int) $request->query('page', 1);
        $search = $request->query('search', '');
        $role = $request->query('role', '');

        $query = Users::query();

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('Username', 'like', "%$search%")
                  ->orWhere('FullName', 'like', "%$search%")
                  ->orWhere('Email', 'like', "%$search%")
                  ->orWhere('Phone', 'like', "%$search%")
                  ->orWhere('UserID', 'like', "%$search%")
                  ->orWhere('NationalID', 'like', "%$search%")
                  ->orWhere('Address', 'like', "%$search%")
                  ->orWhere('Role', 'like', "%$search%")
                  ->orWhere('Status', 'like', "%$search%")
                  ->orWhereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($search))]);
            });
        }

        if (!empty($role)) {
            $query->whereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($role))]);
        }

        $users = $query->paginate(10, ['*'], 'page', $page);
        return response()->json($users);
    }

    public function update(Request $request, $id)
    {
        $user = Users::where('UserID', $id)->firstOrFail();

        $validated = $request->validate([
            'email'         => "nullable|email|unique:Users,Email,$id,UserID",
            'phone'         => ['nullable', 'regex:/^(0|\\+84)[0-9]{9,10}$/'],
            'full_name'     => 'nullable|string',
            'birth_date'    => 'nullable|date',
            'address'       => 'nullable|string',
            'national_id'   => "nullable|digits_between:9,12|unique:Users,NationalID,$id,UserID",
            'gender'        => 'nullable|in:0,1',
            'password'      => 'nullable|min:8',
            'profile_picture' => 'nullable|file|image|max:2048',
        ]);

        $user->Email       = $validated['email'] ?? $user->Email;
        $user->Phone       = $validated['phone'] ?? $user->Phone;
        $user->FullName    = $validated['full_name'] ?? $user->FullName;
        $user->BirthDate   = $validated['birth_date'] ?? $user->BirthDate;
        $user->Address     = $validated['address'] ?? $user->Address;
        $user->NationalID  = $validated['national_id'] ?? $user->NationalID;
        $user->Gender      = $validated['gender'] ?? $user->Gender;

        if ($request->hasFile('profile_picture')) {
            $file = $request->file('profile_picture');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->storeAs('public/images', $filename);
            $user->ProfilePicture = 'images/' . $filename;
        }

        if ($request->filled('password')) {
            $user->PasswordHash = Hash::make($request->password);
        }

        $user->save();
        return response()->json(['message' => 'Người dùng đã được cập nhật!']);
    }

    public function destroy($id)
    {
        $user = Users::where('UserID', $id)->firstOrFail();

        Pet::where('UserID', $id)->delete();
        Appointment::where('UserID', $id)->delete();
        MedicalRecord::where('UserID', $id)->delete();
        Prescription::where('UserID', $id)->delete();
        Invoice::where('UserID', $id)->delete();
        UserLog::where('UserID', $id)->delete();

        $user->delete();
        return response()->json(['message' => 'Đã xoá người dùng và tất cả dữ liệu liên quan!']);
    }

    public function logout(Request $request)
    {
        if (Auth::check()) {
            Auth::logout();
        }

        return response()->json(['message' => 'Đăng xuất thành công']);
    }
}
