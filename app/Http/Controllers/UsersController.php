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
use App\Models\Invoices;
use App\Models\UserLog;
use App\Models\Notification;
use App\Services\FirebaseService;
use App\Http\Controllers\InvoicesController; 
use Carbon\Carbon;
use App\Models\AppointmentHistory;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use App\Mail\VerifyEmailRegister;

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

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }


public function getUserFullDetail($id)
{
    // Lấy thông tin người dùng
    $user = Users::where('UserID', $id)->first();

    if (!$user) {
        return response()->json(['message' => 'Người dùng không tồn tại'], 404);
    }

    // Lấy danh sách PetID thuộc User này
    $petIDs = Pet::where('UserID', $id)->pluck('PetID')->toArray();

    // Thú cưng
    $pets = Pet::where('UserID', $id)->get(['Name as PetName', 'Species', 'Gender']);

    // Dịch vụ đã sử dụng (qua hóa đơn và bảng invoice_service)
    $serviceRecords = \DB::table('invoices')
        ->join('invoice_service', 'invoices.InvoiceID', '=', 'invoice_service.InvoiceID')
        ->join('services', 'invoice_service.ServiceID', '=', 'services.ServiceID')
        ->where(function ($query) use ($id, $petIDs) {
            $query->whereIn('invoices.PetID', $petIDs);
        })
        ->where('invoices.Status', 'paid')
        ->select('services.ServiceName', 'invoices.CreatedAt as Date')
        ->distinct()
        ->get();

    // Thuốc đã sử dụng (qua bảng invoice_medicines)
    $medicineRecords = \DB::table('invoices')
        ->join('invoice_medicines', 'invoices.InvoiceID', '=', 'invoice_medicines.InvoiceID')
        ->join('medications', 'invoice_medicines.MedicineID', '=', 'medications.MedicationID')
        ->join('pets', 'invoices.PetID', '=', 'pets.PetID')
        ->where('pets.UserID', $id)
        ->where('invoices.Status', 'paid')
        ->select('medications.Name as MedicineName', 'invoices.CreatedAt as Date')
        ->distinct()
        ->get();

    // Trả về kết quả
    return response()->json([
        'user' => [
            'UserID'     => $user->UserID,
            'FullName'   => $user->FullName,
            'Email'      => $user->Email,
            'BirthDate'  => $user->BirthDate,
            'Status'     => $user->Status,
            'Phone'      => $user->Phone,
            'Gender'     => $user->Gender,
            'Address'    => $user->Address,
            'NationalID' => $user->NationalID,
            'Role'       => $user->Role,
            'Image'      => $user->ProfilePicture,
        ],
        'pets' => $pets,
        'services' => $serviceRecords,
        'medicines' => $medicineRecords
    ]);
}
public function getUserPaymentHistory($userId)
{
    // Lấy thông tin người dùng
    $user = \DB::table('users')->where('UserID', $userId)->first();
    if (!$user) {
        return response()->json(['message' => 'Người dùng không tồn tại'], 404);
    }

    // Lấy danh sách PetID của người dùng
    $petIDs = \DB::table('pets')->where('UserID', $userId)->pluck('PetID');

    // Lấy lịch sử thanh toán của các hóa đơn thuộc các thú cưng này
    $paymentHistory = \DB::table('payments')
        ->join('invoices', 'payments.InvoiceID', '=', 'invoices.InvoiceID')
        ->whereIn('invoices.PetID', $petIDs)
        ->select(
            'payments.PaidAmount',
            'payments.PaymentTime',
            'invoices.InvoiceID',
            'invoices.PetID'
        )
        ->orderBy('payments.PaymentTime', 'desc')
        ->get();

    // Lấy dịch vụ theo từng hóa đơn
    $invoiceServices = \DB::table('invoice_service')
        ->join('services', 'invoice_service.ServiceID', '=', 'services.ServiceID')
        ->select('invoice_service.InvoiceID', 'services.ServiceName')
        ->get()
        ->groupBy('InvoiceID');

    // Lấy thuốc theo từng hóa đơn
    $invoiceMedicines = \DB::table('invoice_medicines')
        ->join('medications', 'invoice_medicines.MedicineID', '=', 'medications.MedicationID')
        ->select('invoice_medicines.InvoiceID', 'medications.Name as MedicineName')
        ->get()
        ->groupBy('InvoiceID');

    // Ghép dữ liệu lại
    $results = $paymentHistory->map(function ($item) use ($invoiceServices, $invoiceMedicines) {
        return [
            'invoice_id' => $item->InvoiceID,
            'pet_id' => $item->PetID,
            'paid_amount' => $item->PaidAmount,
            'payment_time' => $item->PaymentTime,
            'services' => $invoiceServices->get($item->InvoiceID)?->pluck('ServiceName')->toArray() ?? [],
            'medicines' => $invoiceMedicines->get($item->InvoiceID)?->pluck('MedicineName')->toArray() ?? [],
        ];
    });

    return response()->json([
        'user_id' => $userId,
        'user_name' => $user->FullName ?? 'Không rõ',
        'payments' => $results,
    ]);
}

  // Controller UsersController
public function getUserWithCompletedAppointments() 
{
    $users = Users::whereHas('appointments', function ($query) {
            $query->where('Status', 'Kết thúc');
        })
        ->select('UserID', 'FullName', 'BirthDate')
        ->distinct()
        ->get();

    return response()->json([
        'count' => $users->count(),
        'users' => $users
    ]);
}

 public function verifyEmail(Request $request)
{
    $token = $request->query('token');

    $record = \DB::table('email_verifications')->where('token', $token)->first();

    if (!$record) {
        return response()->json(['message' => 'Liên kết không hợp lệ hoặc đã hết hạn'], 400);
    }

    $data = json_decode($record->data, true);
    $role = $data['role'] ?? 'owner';

    $user = new Users();
    $user->UserID = $this->generateUserID($role);
    $user->Username = $data['username'];
    $user->PasswordHash = Hash::make($data['password']);
    $user->Email = $data['email'];
    $user->Phone = $data['phone'];
    $user->FullName = $data['full_name'];
    $user->BirthDate = $data['birth_date'];
    $user->Address = $data['address'];
    $user->NationalID = $data['national_id'];
    $user->Gender = $data['gender'] ?? 1;
    $user->Role = $role;
    $user->Status = 'active';
    $user->CreatedAt = now();
    $user->email_verified_at = now(); // ✅ Đánh dấu email đã xác minh
    $user->save();

    // ✅ Xóa token đã dùng
    \DB::table('email_verifications')->where('token', $token)->delete();

    return response()->json([
        'message' => '✅ Tài khoản đã được xác nhận và tạo thành công!',
        'verified' => true
    ]);
}


    public function getSystemStatistics(Request $request)
{
    $start = Carbon::now()->startOfMonth();
    $end = Carbon::now()->endOfMonth();

    // 👉 Tổng thu từ bảng payments (PaidAmount)
    $totalIncome = DB::table('payments')
        ->whereBetween('PaymentTime', [$start, $end])
        ->sum('PaidAmount');

    // 👉 Số người dùng đã hoàn tất lịch hẹn từ bảng AppointmentHistory
    $completedUsers = AppointmentHistory::with('appointment')
        ->where('StatusAfter', 'Kết thúc')
        ->whereBetween('UpdatedAt', [$start, $end])
        ->get()
        ->pluck('appointment.UserID')
        ->unique()
        ->count();

    return response()->json([
        'total_income' => $totalIncome,
        'completed_users' => $completedUsers,
    ]);
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

    public function updateToken(Request $request)
    {
        $user = Users::find($request->UserID);
        if (!$user) return response()->json(['message' => 'User không tồn tại'], 404);

        $user->fcm_token = $request->fcm_token;
        $user->save();

        return response()->json(['message' => '✅ Token cập nhật thành công']);
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

    try {
        $token = Str::random(64);

        // Lưu vào bảng tạm
        \DB::table('email_verifications')->updateOrInsert(
            ['email' => $validated['email']],
            [
                'token' => $token,
                'data' => json_encode($validated),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );

        // Gửi email xác minh
        Mail::to($validated['email'])->send(new VerifyEmailRegister($token));

        // Trả kết quả JSON
        return response()->json([
            'message' => '🎉 Đăng ký thành công! Vui lòng kiểm tra email để xác nhận tài khoản.'
        ], 200);

    } catch (\Exception $e) {
        // Nếu lỗi (mail hoặc bất kỳ lý do nào)
        return response()->json([
            'message' => 'Đăng ký thất bại do lỗi hệ thống!',
            'error' => $e->getMessage()
        ], 500);
    }
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
            'role'        => $user->Role,
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


    public function getPromotion($userID)
{
    $user = Users::where('UserID', $userID)->first();

    if (!$user) {
        return response()->json(['message' => 'User not found'], 404);
    }

    // Tính tổng tiền đã thanh toán
    $totalPaid = \DB::table('payments')
        ->where('UserID', $userID)
        ->sum('PaidAmount');

    // Gắn giá trị vào user (nếu cần cập nhật vào DB)
    if ($totalPaid >= 1000000 && !$user->is_vip) {
        $user->is_vip = true;
        $user->save();
    }

    $isOldCustomer = $user->total_completed_appointments > 0;

    // Gán ưu đãi
    $discount = 0;
    $promotionTitle = '';
    $promotionNote = '';

    if ($user->is_vip) {
        $discount = 20;
        $promotionTitle = "🎉 Ưu đãi VIP 20%";
        $promotionNote = "Bạn là khách VIP! Được giảm giá 20% và ưu tiên lịch hẹn.";
    } elseif ($isOldCustomer) {
        $discount = 10;
        $promotionTitle = "🔁 Ưu đãi khách cũ 10%";
        $promotionNote = "Cảm ơn bạn đã quay lại! Bạn được giảm 10% trên tổng đơn.";
    }

    return response()->json([
        'UserID' => $user->UserID,
        'FullName' => $user->FullName,
        'is_vip' => $user->is_vip,
        'total_paid' => $totalPaid,
        'discount' => $discount,
        'promotion_title' => $promotionTitle,
        'promotion_note' => $promotionNote,
    ]);
}


}
