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
            'ServiceID' => 'required|exists:Services,ServiceID',
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

        $staffId = $request->input('StaffID');
        if (!$staffId) {
            $staff = User::where('role', 'staff')->inRandomOrder()->first();
            $staffId = $staff ? $staff->UserID : null;
        }

        $appointment = Appointment::create([
            'AppointmentID' => $appointmentId,
            'PetID' => $request->PetID,
            'UserID' => $userId,
            'ServiceID' => $request->ServiceID,
            'AppointmentDate' => $request->AppointmentDate,
            'AppointmentTime' => $request->AppointmentTime,
            'Reason' => $request->Reason,
            'Status' => $request->Status,
            'StaffID' => $staffId,
        ]);

        return response()->json([
            'message' => 'Created successfully',
            'data' => $appointment->load(['user', 'service', 'pet', 'staff']),
        ], 201);
    }
    // ✅ Lấy lịch hẹn theo người dùng
    public function index(Request $request)
{
    $userId = $request->query('UserID');
    $search = $request->query('search');
    $status = $request->query('status'); // <--- Thêm dòng này

    if (!$userId) {
        return response()->json(['message' => 'Missing UserID'], 400);
    }

    $appointments = Appointment::with(['user', 'pet', 'service', 'staff'])
        ->where('UserID', $userId)
        ->when($status !== 'all', function ($query) {
            $query->where('Status', '!=', 'Kết thúc');
        }) // <--- Cho phép truyền status=all để hiển thị hết
        ->when($search, function ($query, $search) {
            $query->whereHas('pet', function ($q) use ($search) {
                $q->where('Name', 'like', "%$search%");
            })->orWhereHas('service', function ($q) use ($search) {
                $q->where('ServiceName', 'like', "%$search%");
            });
        })
        ->orderBy('AppointmentDate', 'desc')
        ->get();

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

        $appointments = Appointment::with(['user', 'pet', 'service', 'staff'])
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

        if (!$appointment->StaffID) {
            $staff = User::where('role', 'staff')->inRandomOrder()->first();
            $appointment->StaffID = $staff ? $staff->UserID : null;
        }

        $appointment->save();

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

        if ($statusAfter === 'Đã duyệt') {
            Notification::create([
                'user_id' => $appointment->UserID,
                'title' => 'Lịch hẹn đã được duyệt',
                'message' => 'Lịch hẹn của bạn vào ngày ' . $appointment->AppointmentDate . ' đã được duyệt.',
            ]);
        }

        return response()->json(['message' => 'Cập nhật trạng thái thành công']);
    }

    
    // ✅ Kiểm tra trùng giờ hẹn
    public function checkConflict(Request $request)
    {
        $exists = Appointment::where('PetID', $request->pet_id)
            ->where('AppointmentDate', $request->date)
            ->where('AppointmentTime', $request->time)
            ->exists();

        return response()->json(['exists' => $exists]);
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
        $appointment = Appointment::with(['user', 'pet', 'staff', 'service'])->where('AppointmentID', $id)->first();

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
            'data' => $appointment->load(['user', 'service', 'pet', 'staff']),
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

    // ❌ Chặn xóa nếu lịch hẹn đã được duyệt hoặc đã kết thúc
    if (in_array($appointment->Status, ['Đã duyệt', 'Kết thúc'])) {
        return response()->json(['message' => 'Không thể xóa lịch hẹn đã được duyệt hoặc đã kết thúc'], 403);
    }

    // Xóa lịch sử liên quan
    AppointmentHistory::where('AppointmentID', $appointment->AppointmentID)->delete();

    // Xóa hóa đơn nếu có
    Invoices::where('AppointmentID', $appointment->AppointmentID)->delete();

    // Xóa cuộc hẹn
    $appointment->delete();

    return response()->json(['message' => 'Appointment deleted successfully']);
}

}