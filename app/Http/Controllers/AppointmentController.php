<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;
use App\Models\AppointmentHistory;
use App\Models\Pet;
use App\Models\Notification;
use App\Models\Users;
use App\Models\Medications;
use App\Models\Invoices;
use App\Models\Service;
use App\Models\InvoiceDetail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\InvoicesController;
use Kreait\Firebase\Messaging;
use App\Services\FirebaseService;


class AppointmentController extends Controller
{
    // ✅ Tạo lịch hẹn
 // ✅ Tạo lịch hẹn
public function store(Request $request)
{
    $user = Auth::user();
    $userId = $user ? $user->UserID : $request->input('UserID');

    if (!$userId) {
        return response()->json(['message' => 'User chưa được xác thực hoặc thiếu UserID'], 401);
    }

    // Validate input data
    $validator = Validator::make($request->all(), [
        'PetID' => 'required|array|min:1',
        'PetID.*' => 'exists:Pets,PetID',
        'ServiceIDs' => 'required|array|min:1',
        'ServiceIDs.*' => 'exists:Services,ServiceID',
        'AppointmentDate' => 'required|date',
        'AppointmentTime' => 'required|date_format:H:i:s',
        'Reason' => 'nullable|string',
        'Status' => 'required|string',
        'StaffID' => 'nullable|exists:users,UserID',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    // Tạo lịch hẹn cho từng Pet, kiểm tra trùng lịch
    $appointments = [];

    // Kiểm tra trùng lịch cho tất cả PetID trong yêu cầu
    foreach ($request->PetID as $petId) {
        $pet = Pet::find($petId);
        if (!$pet) return response()->json(['message' => 'Pet not found'], 404);

        // Kiểm tra trùng lịch hẹn cho pet của người dùng
        $existingAppointments = Appointment::where('UserID', $userId)
            ->where('AppointmentDate', $request->AppointmentDate)
            ->where('AppointmentTime', $request->AppointmentTime)
            ->whereIn('PetID', $request->PetID) // Kiểm tra tất cả các PetID
            ->where('Status', '!=', 'Kết thúc')
            ->exists();

        if ($existingAppointments) {
            return response()->json(['message' => 'Một hoặc nhiều thú cưng đã có lịch hẹn vào ngày giờ này.'], 409);
        }

        // Kiểm tra lịch hẹn của người dùng khác tại cùng ngày và giờ
        $otherUsersAppointments = Appointment::where('AppointmentDate', $request->AppointmentDate)
            ->where('AppointmentTime', $request->AppointmentTime)
            ->where('Status', '!=', 'Kết thúc')
            ->where('UserID', '!=', $userId)  // Đảm bảo không trùng lịch với chính người dùng
            ->exists();

        if ($otherUsersAppointments) {
            return response()->json(['message' => 'Đã có người dùng khác đặt lịch hẹn vào thời gian này'], 409);
        }

        // Generate unique AppointmentID
        $appointmentId = 'APP' . strtoupper(Str::random(6));

        // Chọn nhân viên nếu chưa có
        $staffId = $request->input('StaffID') ?? Users::where('role', 'staff')->inRandomOrder()->value('UserID');

        // Create the appointment record
        $appointment = Appointment::create([
            'AppointmentID' => $appointmentId,
            'PetID' => $petId,
            'UserID' => $userId,
            'AppointmentDate' => $request->AppointmentDate,
            'AppointmentTime' => $request->AppointmentTime,
            'Reason' => $request->Reason,
            'Status' => $request->Status,
            'StaffID' => $staffId,
        ]);

        // Store the services for the appointment
        foreach ($request->ServiceIDs as $serviceID) {
            DB::table('appointment_service')->insert([
                'appointment_id' => $appointmentId,
                'service_id' => $serviceID,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Append the created appointment to the array
        $appointments[] = $appointment->load(['user', 'services', 'pet', 'staff']);
    }

    return response()->json([
        'message' => 'Created successfully',
        'data' => $appointments,
    ], 201);
}


    // ✅ Lấy lịch hẹn theo người dùng
    public function index(Request $request)
{
    $userId = $request->query('UserID');
    $search = $request->query('search');
    $status = $request->query('status');

    // Kiểm tra xem UserID có tồn tại không
    if (!$userId) {
        return response()->json(['message' => 'Missing UserID'], 400);
    }

    $appointments = Appointment::with(['user', 'pet', 'services', 'staff'])
        ->where('UserID', $userId) // Lọc theo UserID
        ->when($status && $status !== 'all', function ($query) use ($status) {
            // Kiểm tra nếu status không phải 'all' thì loại bỏ 'Kết thúc'
            $query->where('Status', '!=', 'Kết thúc');
        })
        ->when($search, function ($query, $search) {
            // Tìm kiếm theo tên thú cưng và dịch vụ
            $query->whereHas('pet', function ($q) use ($search) {
                $q->where('Name', 'like', "%$search%");
            })
            ->orWhereHas('services', function ($q) use ($search) {
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
            ELSE 8 END") // Sắp xếp theo trạng thái
        ->orderBy('AppointmentDate', 'desc') // Sắp xếp theo ngày
        ->get()
        ->map(function ($appointment) {
            // Chuyển đổi dịch vụ để trả về các trường cần thiết
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
        'data' => $appointments,  // Trả về danh sách các cuộc hẹn
    ]);
}


    // ✅ Lấy tất cả lịch hẹn cho nhân viên
   public function getAllAppointmentsForStaff(Request $request)
    {
        $role = $request->query('role');

        // ✅ Chấp nhận cả staff và doctor
        if (!in_array($role, ['staff', 'doctor'])) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // ✅ Lấy danh sách lịch hẹn theo từng vai trò
        $appointments = Appointment::with(['user', 'pet', 'services', 'staff'])
            ->when($role === 'doctor', function ($query) {
                // Bác sĩ chỉ xem lịch hẹn ở trạng thái "Chờ thêm thuốc"
                $query->where('Status', 'Chờ thêm thuốc');
            })
            ->when($role === 'staff', function ($query) {
                // Nhân viên thấy tất cả lịch trừ "Kết thúc"
                $query->where('Status', '!=', 'Kết thúc');
            })
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

public function checkAll(Request $request)
{
    $staffId = $request->query('staff_id');
    $date = $request->query('date');
    
    if (!$staffId || !$date) {
        return response()->json(['message' => 'Thiếu thông tin'], 400);  // Thiếu staff_id hoặc date
    }

    // Lấy danh sách các thời gian đã đặt cho nhân viên trong ngày
    $bookedTimes = DB::table('appointments')
        ->whereDate('AppointmentDate', $date)
        ->where('StaffID', $staffId)
        ->whereIn('Status', ['Đã duyệt', 'Đang khám', 'Chờ khám', 'Hoàn tất dịch vụ'])
        ->pluck('AppointmentTime');

    return response()->json([
        'booked_times' => $bookedTimes,  // Trả về các thời gian đã đặt cho nhân viên
    ]);
}

    // ✅ Lấy danh sách giờ đã được đặt trong ngày
    public function checkStaffAvailability(Request $request)
{
    $staffId = $request->query('staff_id');
    $date = $request->query('date');
    $time = $request->query('time');
    $userId = $request->query('user_id');  // Thêm thông tin người dùng

    // Kiểm tra xem có truyền đủ thông tin không
    if (!$staffId || !$date || !$time || !$userId) {
        return response()->json(['message' => 'Thiếu thông tin'], 400);
    }

    // Kiểm tra lịch hẹn đã có của nhân viên trong thời gian đó của người dùng khác
    $existingAppointments = Appointment::where('StaffID', $staffId)
        ->where('AppointmentDate', $date)
        ->where('AppointmentTime', $time)
        ->where('UserID', '!=', $userId)  // Kiểm tra lịch của người dùng khác
        ->whereIn('Status', ['Đã duyệt', 'Chờ khám', 'Đang khám', 'Hoàn tất dịch vụ', 'Chờ thêm thuốc'])  // Kiểm tra các trạng thái từ 'Đã duyệt' trở lên
        ->exists();

    // Trả về kết quả
    if ($existingAppointments) {
        return response()->json(['available' => false]);
    } else {
        return response()->json(['available' => true]);
    }
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
public function destroy(Request $request, $id)
{
    $appointment = Appointment::find($id);

    if (!$appointment) {
        return response()->json([
            'status' => 'error',
            'message' => 'Không tìm thấy lịch hẹn với ID: ' . $id
        ], 404);
    }

    // Không cho xóa nếu đã ở trạng thái "Đã xóa"
    if ($appointment->Status === 'Đã xóa') {
        return response()->json([
            'status' => 'error',
            'message' => 'Lịch hẹn đã bị xóa trước đó.'
        ], 403);
    }

    // Kiểm tra UserID
    if (!$appointment->UserID) {
        return response()->json([
            'status' => 'error',
            'message' => 'Không có UserID cho lịch hẹn này.'
        ], 400);
    }

    // Lý do xóa
    $reason = $request->input('reason', '');
    if (empty($reason)) {
        return response()->json([
            'status' => 'error',
            'message' => 'Lý do xóa lịch hẹn là bắt buộc.'
        ], 400);
    }

    if ($reason === 'Khác') {
        $reason = $request->input('custom_reason', '');
        if (empty($reason)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Lý do xóa không thể bỏ trống khi chọn "Khác".'
            ], 400);
        }
    }

    // ✅ Cập nhật trạng thái thành "Đã xóa"
    $appointment->Status = 'Đã xóa';
    $appointment->save();

    // Gửi thông báo nếu có FCM token
    $user = Users::find($appointment->UserID);
    if ($user && $user->fcm_token) {
        $firebase = new FirebaseService();
        $firebase->sendNotificationWithData(
            $user->fcm_token,
            'Lịch hẹn đã bị xóa',
            "Lý do: $reason",
            [
                'action' => 'appointment_deleted',
                'appointment_id' => $appointment->AppointmentID,
                'reason' => $reason,
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]
        );

        // Tạo thông báo DB
        $lastNotificationId = Notification::max('id') ?? 'NOTI000';
        preg_match('/^NOTI(\d+)$/', $lastNotificationId, $matches);
        $nextNumber = str_pad((int)($matches[1] ?? 0) + 1, 3, '0', STR_PAD_LEFT);
        $notificationId = 'NOTI' . $nextNumber;

        Notification::create([
            'id' => $notificationId,
            'user_id' => $user->UserID,
            'title' => 'Lịch hẹn đã bị xóa',
            'message' => "Lý do: $reason",
            'is_read' => false,
            'action' => 'appointment_deleted',
        ]);
    }

    return response()->json([
        'status' => 'success',
        'message' => "Lịch hẹn đã được xóa với lý do: $reason",
        'appointment_id' => $appointment->AppointmentID,
    ]);
}


public function fetchServicesBySpecies(Request $request)
{
    $species = $request->query('species'); 
    $keyword = $request->query('keyword'); 

    if (!$species) {
        return response()->json(['message' => 'Thiếu tham số species'], 400);
    }

    $query = DB::table('services')->where('CategoryID', $species);

    if ($keyword) {
        $query->where('ServiceName', 'like', '%' . $keyword . '%');
    }

    $services = $query->get();

    return response()->json([
        'success' => true,
        'data' => $services
    ]);
}

public function getAllBookedSlots(Request $request)
{
    $staffId = $request->query('staff_id');

    if (!$staffId) {
        return response()->json(['message' => 'Thiếu staff_id'], 400);
    }

    // ✅ Chỉ lấy các trạng thái từ "Đã duyệt" trở lên
    $appointments = Appointment::where('StaffID', $staffId)
        ->whereIn('Status', ['Đã duyệt', 'Chờ khám', 'Đang khám', 'Hoàn tất dịch vụ', 'Chờ thêm thuốc']) 
        ->orderBy('AppointmentDate')
        ->get(['AppointmentDate', 'AppointmentTime', 'Status']);

    if ($appointments->isEmpty()) {
        return response()->json(['message' => 'Appointment not found'], 404);
    }

    return response()->json([
        'success' => true,
        'data' => $appointments
    ]);
}

    public function countUnseenAppointments()
    {
        $count = Appointment::where('is_seen', 0)
                            ->where('Status', '!=', 'Kết thúc') // Tuỳ logic nếu cần
                            ->count();

        return response()->json(['unseen_count' => $count]);
    }


    public function markAppointmentAsSeen($id)
    {
        $appointment = Appointment::find($id);
        if ($appointment) {
            $appointment->is_seen = 1;
            $appointment->save();
        }

        return response()->json(['message' => 'Đã đánh dấu đã xem']);
    }

    public function getMedicationsByAppointment($appointmentId)
{
    $medications = DB::table('appointment_medications')
        ->join('medications', 'appointment_medications.MedicationID', '=', 'medications.MedicationID')
        ->where('appointment_medications.AppointmentID', $appointmentId)
        ->select('medications.*', 'appointment_medications.Quantity')
        ->get();

    return response()->json(['data' => $medications]);
}


public function updateMedications(Request $request, $appointmentId)
{
    $validator = Validator::make($request->all(), [
        'medications' => 'required|array',
        'medications.*.MedicationID' => 'required|string|exists:medications,MedicationID',
        'medications.*.Quantity' => 'required|integer|min:1',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    // Xóa thuốc cũ
    DB::table('appointment_medications')->where('AppointmentID', $appointmentId)->delete();

    // Thêm thuốc mới
    foreach ($request->medications as $med) {
        DB::table('appointment_medications')->insert([
            'AppointmentID' => $appointmentId,
            'MedicationID' => $med['MedicationID'],
            'Quantity' => $med['Quantity'],
            // Bỏ created_at và updated_at nếu không có cột trong bảng
        ]);
    }

    return response()->json(['message' => 'Cập nhật thuốc thành công']);
}

public function getSuggestedServicesByUser(Request $request)
{
    $userId = $request->query('user_id');

    if (!$userId) {
        return response()->json(['message' => 'Thiếu user_id'], 400);
    }

    // Lấy danh sách các InvoiceID đã thanh toán của user
    $paidInvoiceIds = DB::table('invoices')
        ->join('payments', 'invoices.InvoiceID', '=', 'payments.InvoiceID')
        ->join('appointments', 'invoices.AppointmentID', '=', 'appointments.AppointmentID')
        ->where('appointments.UserID', $userId)
        ->where('payments.status', 'đã duyệt')
        ->pluck('invoices.InvoiceID');

    if ($paidInvoiceIds->isEmpty()) {
        return response()->json([]);
    }

    // Lấy danh sách dịch vụ đã từng dùng (không cần đếm số lần)
    $services = DB::table('invoice_service')
        ->join('services', 'invoice_service.ServiceID', '=', 'services.ServiceID')
        ->whereIn('invoice_service.InvoiceID', $paidInvoiceIds)
        ->select('invoice_service.ServiceID', 'services.ServiceName')
        ->distinct()
        ->get();

    return response()->json($services);
}

}