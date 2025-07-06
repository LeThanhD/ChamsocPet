<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;
use App\Models\AppointmentHistory;
use App\Models\Pet;
use App\Models\Notification;
use App\Models\User;
use App\Models\Medications;
use App\Models\Invoices;
use App\Models\Service;
use App\Models\InvoiceDetail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AppointmentController extends Controller
{
    // ✅ Tạo lịch hẹn
   public function store(Request $request)
{
    $user = Auth::user();
    $userId = $user ? $user->UserID : $request->input('UserID');

    if (!$userId) {
        return response()->json(['message' => 'User chưa được xác thực hoặc thiếu UserID'], 401);
    }

    $validator = Validator::make($request->all(), [
        'PetID' => 'required|exists:Pets,PetID',
        'ServiceIDs' => 'required|array|min:1',               // ✅ Danh sách dịch vụ
        'ServiceIDs.*' => 'exists:Services,ServiceID',        // ✅ Từng ID phải hợp lệ
        'AppointmentDate' => 'required|date',
        'AppointmentTime' => 'required|date_format:H:i:s',
        'Reason' => 'nullable|string',
        'Status' => 'required|string',
        'StaffID' => 'nullable|exists:users,UserID',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    $pet = Pet::find($request->PetID);
    if (!$pet) return response()->json(['message' => 'Pet not found'], 404);

    $lastAppointment = Appointment::orderBy('AppointmentID', 'desc')->first();
    $lastNumber = 0;

    if ($lastAppointment && preg_match('/APP(\d+)/', $lastAppointment->AppointmentID, $matches)) {
        $lastNumber = intval($matches[1]);
    }

    $nextNumber = str_pad($lastNumber + 1, 3, '0', STR_PAD_LEFT);
    $sanitizedPetName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $pet->Name));
    $appointmentId = "APP{$nextNumber}{$sanitizedPetName}";

    $staffId = $request->input('StaffID') ?? User::where('role', 'staff')->inRandomOrder()->value('UserID');

    // ✅ Tạo cuộc hẹn KHÔNG cần ServiceID đơn
    $appointment = Appointment::create([
        'AppointmentID' => $appointmentId,
        'PetID' => $request->PetID,
        'UserID' => $userId,
        'AppointmentDate' => $request->AppointmentDate,
        'AppointmentTime' => $request->AppointmentTime,
        'Reason' => $request->Reason,
        'Status' => $request->Status,
        'StaffID' => $staffId,
    ]);

    // ✅ Lưu vào bảng appointment_service
    foreach ($request->ServiceIDs as $serviceID) {
        DB::table('appointment_service')->insert([
            'appointment_id' => $appointmentId,
            'service_id' => $serviceID,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    return response()->json([
        'message' => 'Created successfully',
        'data' => $appointment->load(['user', 'services', 'pet', 'staff']),
    ], 201);
}

    // ✅ Lấy lịch hẹn theo người dùng
        public function index(Request $request)
    {
        $userId = $request->query('UserID');
        $search = $request->query('search');
        $status = $request->query('status');

        if (!$userId) {
            return response()->json(['message' => 'Missing UserID'], 400);
        }

        $appointments = Appointment::with(['user', 'pet', 'services', 'staff'])
            ->where('UserID', $userId)
            ->when($status !== null && $status !== 'all', function ($query) {
                $query->where('Status', '!=', 'Kết thúc');
            }) // Cho phép truyền status=all để hiển thị tất cả trạng thái
            ->when($search, function ($query, $search) {
                $query->whereHas('pet', function ($q) use ($search) {
                    $q->where('Name', 'like', "%$search%");
                })->orWhereHas('services', function ($q) use ($search) {
                    $q->where('ServiceName', 'like', "%$search%");
                });
            })
            ->orderByRaw("CASE 
                WHEN Status = 'Chưa duyệt' THEN 1
                WHEN Status = 'Đã duyệt' THEN 2
                WHEN Status = 'Chờ khám' THEN 3
                WHEN Status = 'Đang khám' THEN 4
                WHEN Status = 'Hoàn tất dịch vụ' THEN 5
                WHEN Status = 'Chờ thêm thuốc' THEN 6
                WHEN Status = 'Kết thúc' THEN 7
                ELSE 8 END")
            ->orderBy('AppointmentDate', 'desc')
            ->get()
            ->map(function ($appointment) {
                $appointment->services->transform(function ($service) {
                    return [
                        'ServiceID' => $service->ServiceID,
                        'ServiceName' => $service->ServiceName,
                        'Price' => $service->Price,
                    ];
                });
                return $appointment;
            });

        return response()->json([
            'success' => true,
            'data' => $appointments,
        ]);
    }

    // ✅ Lấy tất cả lịch hẹn cho nhân viên
    public function getAllAppointmentsForStaff(Request $request)
    {
        $role = $request->query('role');
        if ($role !== 'staff') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $appointments = Appointment::with(['user', 'pet', 'services', 'staff'])
            ->orderBy('AppointmentDate', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $appointments,
        ]);
    }

    // ✅ Cập nhật trạng thái cuộc hẹn và lưu lịch sử nếu cần
    public function updateStatus(Request $request, $id)
{
    $appointment = Appointment::find($id);
    if (!$appointment) {
        return response()->json(['message' => 'Appointment not found'], 404);
    }

    $statusBefore = $appointment->Status;
    $statusAfter = $request->input('Status');

    $appointment->Status = $statusAfter;

    // Nếu chưa có nhân viên được chỉ định, tự động chọn một nhân viên ngẫu nhiên
    if (!$appointment->StaffID) {
        $staff = User::where('role', 'staff')->inRandomOrder()->first();
        $appointment->StaffID = $staff ? $staff->UserID : null;
    }

    $appointment->save();

    // Xử lý khi trạng thái là "Kết thúc"
    if ($statusAfter === 'Kết thúc') {
        AppointmentHistory::create([
            'HistoryID' => 'HIS' . strtoupper(Str::random(6)),
            'AppointmentID' => $appointment->AppointmentID,
            'UpdatedAt' => now(),
            'StatusBefore' => $statusBefore,
            'StatusAfter' => $statusAfter,
            'Note' => 'Cuộc hẹn đã hoàn tất',
        ]);
    }

    // Xử lý khi trạng thái là "Đã duyệt"
    if ($statusAfter === 'Đã duyệt') {
        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Lịch hẹn đã được duyệt',
            'message' => 'Lịch hẹn của bạn vào ngày ' . $appointment->AppointmentDate . ' đã được duyệt.',
        ]);
    }

    // Xử lý khi trạng thái là "Đang khám"
    if ($statusAfter === 'Đang khám') {
        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Lịch hẹn đang được khám',
            'message' => 'Lịch hẹn của bạn vào ngày ' . $appointment->AppointmentDate . ' đang được khám.',
        ]);
    }

    // Xử lý khi trạng thái là "Hoàn tất dịch vụ"
    if ($statusAfter === 'Hoàn tất dịch vụ') {
        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Dịch vụ đã hoàn tất',
            'message' => 'Dịch vụ cho lịch hẹn của bạn vào ngày ' . $appointment->AppointmentDate . ' đã hoàn tất.',
        ]);
    }

    // Xử lý khi trạng thái là "Chờ thêm thuốc"
    if ($statusAfter === 'Chờ thêm thuốc') {
        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Lịch hẹn chờ thêm thuốc',
            'message' => 'Lịch hẹn của bạn vào ngày ' . $appointment->AppointmentDate . ' đang chờ thêm thuốc.',
        ]);
    }
    return response()->json(['message' => 'Cập nhật trạng thái thành công']);
}

// Lấy danh sách dịch vụ
public function fetchServices(Request $request)
{
    // Lấy tất cả dịch vụ từ bảng 'Services'
    $services = DB::table('services')->get();  // Lấy tất cả các dịch vụ từ bảng

    if ($services->isEmpty()) {
        return response()->json(['message' => 'Không có dịch vụ nào'], 404);
    }

    // Trả về dữ liệu đúng định dạng, bỏ phần phân trang nếu không cần thiết
    return response()->json([
        'success' => true,
        'data' => $services,  // data là một list dịch vụ
    ], 200);
}


// Cập nhật dịch vụ cho một cuộc hẹn
    // Controller
    public function updateService(Request $request, $id)
{
    // Kiểm tra ID lịch hẹn
    $appointment = Appointment::find($id);
    if (!$appointment) {
        return response()->json(['message' => 'Appointment not found'], 404);
    }

    // Lấy danh sách ServiceIDs từ request
    $serviceIDs = $request->input('ServiceIDs'); // ← array

    if (!is_array($serviceIDs) || empty($serviceIDs)) {
        return response()->json(['message' => 'No services provided'], 400);
    }

    // Xóa các dịch vụ cũ trước
    DB::table('appointment_service')->where('appointment_id', $id)->delete();

    $validServices = [];

    foreach ($serviceIDs as $serviceID) {
        $exists = Service::where('ServiceID', $serviceID)->exists();

        if ($exists) {
            DB::table('appointment_service')->insert([
                'appointment_id' => $id,
                'service_id' => $serviceID,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $service = Service::find($serviceID);
            $validServices[] = $service->ServiceName;
        }
    }

    return response()->json([
        'message' => 'Services updated successfully',
        'appointment_id' => $id,
        'services' => $validServices
    ]);
}

    // ✅ Lấy danh sách giờ đã được đặt trong ngày
    public function getBookedTimes(Request $request)
    {
        $date = $request->query('date');

        if (!$date) {
            return response()->json(['error' => 'Thiếu ngày'], 400);
        }

        $bookedTimes = DB::table('appointments')
            ->whereDate('AppointmentDate', $date)
            ->where('Status', 'Đã duyệt')
            ->pluck('AppointmentTime')
            ->map(function ($time) {
                return Carbon::createFromFormat('H:i:s', $time)->format('H:i');
            })
            ->unique()
            ->values();

        return response()->json(['booked_times' => $bookedTimes]);
    }

    public function show($id)
    {
        $appointment = Appointment::with(['user', 'pet', 'staff', 'services'])->where('AppointmentID', $id)->first();

        if (!$appointment) {
            return response()->json(['message' => 'Appointment not found'], 404);
        }

        return response()->json(['data' => $appointment], 200);
    }

    // ✅ Kết thúc lịch hẹn, chọn thuốc, tạo hóa đơn và gửi thông báo
    public function endAppointment(Request $request, $id)
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return response()->json(['message' => 'Lịch hẹn không tồn tại'], 404);
        }

        if (auth()->user()->role !== 'staff') {
            return response()->json(['message' => 'Không có quyền'], 403);
        }

        $appointment->Status = 'Kết thúc';
        $appointment->save();

        AppointmentHistory::create([
            'HistoryID' => 'HIS' . strtoupper(Str::random(6)),
            'AppointmentID' => $appointment->AppointmentID,
            'UpdatedAt' => now(),
            'StatusBefore' => 'Đã duyệt',
            'StatusAfter' => 'Kết thúc',
            'Note' => 'Cuộc hẹn đã hoàn tất',
        ]);

        $service = $appointment->service;
        $total = $service ? $service->Price : 0;

        $invoice = Invoices::create([
            'InvoiceID' => 'INV' . strtoupper(Str::random(6)),
            'AppointmentID' => $appointment->AppointmentID,
            'UserID' => $appointment->UserID,
            'InvoiceDate' => now(),
            'TotalAmount' => 0, // tạm thời
        ]);

        $medicineCost = 0;

        if (is_array($request->medicine_ids)) {
            foreach ($request->medicine_ids as $id) {
                $medicine = Medications::find($id);
                if ($medicine) {
                    InvoiceDetail::create([
                        'InvoiceDetailID' => 'IND' . strtoupper(Str::random(6)),
                        'InvoiceID' => $invoice->InvoiceID,
                        'MedicationID' => $medicine->MedicationID,
                        'Quantity' => 1,
                        'Price' => $medicine->Price,
                    ]);
                    $medicineCost += $medicine->Price;
                }
            }
        }

        $invoice->TotalAmount = $total + $medicineCost;
        $invoice->save();

        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Hoàn tất lịch hẹn',
            'body' => 'Hóa đơn đã được tạo. Tổng tiền: ' . number_format($invoice->TotalAmount) . 'đ',
        ]);

        return response()->json([
            'message' => 'Lịch hẹn đã kết thúc và hóa đơn đã được tạo.',
            'invoice' => $invoice,
        ]);
    }

    public function approve($id)
    {
        $appointment = Appointment::findOrFail($id);
        $appointment->Status = 'Đã duyệt';
        $appointment->save();

        Notification::create([
            'user_id' => $appointment->UserID,
            'title' => 'Lịch hẹn đã được duyệt',
            'body' => 'Lịch hẹn #' . $appointment->AppointmentID . ' của bạn đã được duyệt.',
        ]);

        return response()->json(['message' => 'Lịch hẹn đã được duyệt'], 200);
    }


    // ✅ Cập nhật thông tin lịch hẹn
    public function update(Request $request, $id)
    {
        $appointment = Appointment::find($id);
        if (!$appointment) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'AppointmentDate' => 'sometimes|date',
            'AppointmentTime' => 'sometimes|date_format:H:i:s',
            'Reason' => 'sometimes|string',
            'Status' => 'sometimes|string',
            'StaffID' => 'sometimes|exists:users,UserID',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $appointment->update($request->only([
            'AppointmentDate', 'AppointmentTime', 'Reason', 'Status', 'StaffID',
        ]));

        return response()->json([
            'message' => 'Updated successfully',
            'data' => $appointment->load(['user', 'services', 'pet', 'staff']),
        ]);
    }

    // ✅ Xóa thú cưng và các cuộc hẹn liên quan
    // public function destroy($id)
    // {
    //     $pet = Pet::find($id);
    //     if (!$pet) {
    //         return response()->json(['message' => 'Pet not found'], 404);
    //     }

    //     $pet->notes()->delete();
    //     Appointment::where('PetID', $pet->PetID)->delete();
    //     $pet->delete();

    //     return response()->json(['message' => 'Pet and related appointments deleted']);
    // }

    // ✅ Xóa một lịch hẹn cụ thể
   public function destroy($id)
    {
        $appointment = Appointment::find($id);
        if (!$appointment) {
            return response()->json(['message' => 'Appointment not found'], 404);
        }

        // Chỉ cho phép xóa khi trạng thái là 'Chưa duyệt' hoặc 'Đã duyệt'
        if (!in_array($appointment->Status, ['Chưa duyệt', 'Đã duyệt'])) {
            return response()->json(['message' => 'Chỉ có thể xóa lịch hẹn ở trạng thái Chưa duyệt hoặc Đã duyệt'], 403);
        }

        // Xóa các dịch vụ liên quan trong bảng trung gian appointment_service
        DB::table('appointment_service')->where('appointment_id', $appointment->AppointmentID)->delete();

        // Xóa lịch sử liên quan
        AppointmentHistory::where('AppointmentID', $appointment->AppointmentID)->delete();

        // Xóa hóa đơn nếu có
        Invoices::where('AppointmentID', $appointment->AppointmentID)->delete();

        // Xóa cuộc hẹn
        $appointment->delete();

       return response()->json([
            'message' => 'những lịch hẹn chưa duyệt hoặc đã duyệt thôi'
        ], 403);

    }
}