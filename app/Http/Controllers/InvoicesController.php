<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Invoices;
use App\Models\Appointment;
use App\Models\Medications;
use App\Models\Notification;
use App\Models\InvoiceMedicine;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;


class InvoicesController extends Controller
{
    // Tạo hóa đơn
    public function store(Request $request)
{
    \Log::info('Dữ liệu tạo hóa đơn:', $request->all());

    $validator = Validator::make($request->all(), [
        'appointment_id' => 'required|exists:appointments,AppointmentID',
        'medicine_ids' => 'nullable|array',
        'medicine_ids.*.id' => 'required_with:medicine_ids|exists:medications,MedicationID',
        'medicine_ids.*.quantity' => 'required_with:medicine_ids|integer|min:1',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    $appointment = Appointment::with(['services', 'service', 'user', 'pet'])
    ->where('AppointmentID', $request->appointment_id)
    ->first();


    if (!$appointment) {
        return response()->json(['message' => 'Lịch hẹn không tồn tại'], 404);
    }

    // Tính tổng giá dịch vụ
    $services = $appointment->services;
    $servicePrice = 0;

    if ($services && $services->count() > 0) {
        $servicePrice = $services->sum('Price');
    } else {
        $service = $appointment->service;
        if (!$service) {
            return response()->json(['message' => 'Dịch vụ không tồn tại cho lịch hẹn này'], 404);
        }
        $servicePrice = $service->Price;
        $services = collect([$service]);
    }

    // Tính tổng giá thuốc
    $medicineTotal = 0;
    $medicineDetails = [];

    if ($request->medicine_ids) {
        foreach ($request->medicine_ids as $item) {
            $medicine = Medications::where('MedicationID', $item['id'])->first();
            if (!$medicine) {
                return response()->json(['message' => 'Thuốc với ID ' . $item['id'] . ' không tồn tại.'], 404);
            }

            $lineTotal = $medicine->Price * $item['quantity'];
            $medicineTotal += $lineTotal;

            $medicineDetails[] = [
                'id' => $medicine->MedicationID,
                'name' => $medicine->Name,
                'price' => $medicine->Price,
                'quantity' => $item['quantity'],
                'subtotal' => $lineTotal,
            ];
        }
    }

    $total = $servicePrice + $medicineTotal;

    // Tạo Invoice mới
    $invoice = Invoices::create([
        'InvoiceID' => 'INV' . strtoupper(Str::random(6)),
        'AppointmentID' => $appointment->AppointmentID,
        'PetID' => $appointment->PetID,
        'ServicePrice' => $servicePrice,
        'MedicineTotal' => $medicineTotal,
        'TotalAmount' => $total,
        'Status' => 'Chưa thanh toán',
        'CreatedAt' => now(),
    ]);

    // Lưu dịch vụ vào bảng trung gian invoice_service
    if ($services && $services->count() > 0) {
        $serviceIds = $services->pluck('ServiceID')->toArray();
        $invoice->services()->attach($serviceIds);
    }

    // Lưu chi tiết thuốc vào bảng trung gian invoice_medicines
    foreach ($medicineDetails as $m) {
        InvoiceMedicine::create([
            'InvoiceID' => $invoice->InvoiceID,
            'MedicineID' => $m['id'],
            'Quantity' => $m['quantity'],
        ]);
    }

    // Tạo thông báo
    Notification::create([
        'user_id' => $appointment->UserID,
        'title' => 'Hóa đơn thanh toán',
        'message' => 'Hóa đơn cho lịch hẹn #' . $appointment->AppointmentID . ' đã được tạo. Tổng tiền: ' . number_format($total) . ' VND.',
        'created_at' => now(),
    ]);

    return response()->json([
        'message' => 'Hóa đơn đã được tạo thành công',
        'data' => [
            'invoice' => $invoice,
            'details' => [
                'services' => $services->map(fn($s) => [
                    'id' => $s->ServiceID,
                    'name' => $s->ServiceName,
                    'price' => $s->Price,
                ]),
                'medicines' => $medicineDetails,
            ]
        ]
    ], 201);
}

    // Danh sách hóa đơn theo role, search, user
 public function index(Request $request)
{
    $userId = $request->query('user_id');
    $role = $request->query('role') ?? 'user';
    $search = $request->query('search');
    $status = $request->query('status'); // Thêm tham số status để lọc

    try {
        $query = Invoices::with(['appointment.pet']);

        if ($role !== 'staff') {
            if (!$userId) {
                return response()->json(['message' => 'Thiếu user_id'], 400);
            }
            $query->whereHas('appointment', fn($q) => $q->where('UserID', $userId));
        }

        if ($status) {
            // Giả sử bảng invoices có cột Status
            $query->where('Status', $status);
        }

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('InvoiceID', 'like', "%$search%")
                  ->orWhere('AppointmentID', 'like', "%$search%")
                  ->orWhereHas('appointment.pet', fn($q2) => $q2->where('Name', 'like', "%$search%"));
            });
        }

        // Sắp xếp theo trạng thái và thời gian tạo
        $query->orderBy('Status')->orderByDesc('CreatedAt');

        $invoices = $query->get();

        foreach ($invoices as $invoice) {
            $appointment = $invoice->appointment;
            $invoice->name = optional(optional($appointment)->pet)->Name ?? 'Không có thông tin thú cưng';
        }

        return response()->json(['data' => $invoices]);
    } catch (\Exception $e) {
        return response()->json(['message' => 'Lỗi server: ' . $e->getMessage()], 500);
    }
}

    // Lấy hóa đơn theo user đăng nhập
    public function getByUser(Request $request)
    {
        $userId = $request->user()->UserID;

        $invoices = Invoices::with(['appointment.pet'])
            ->whereHas('appointment', fn($q) => $q->where('UserID', $userId))
            ->get();

        foreach ($invoices as $invoice) {
            $invoice->name = optional($invoice->appointment->pet)->Name;
        }

        return response()->json(['data' => $invoices]);
    }

    // Xem chi tiết hóa đơn
   public function show($id)
{
    $invoice = Invoices::with(['appointment.services', 'appointment.service', 'appointment.user', 'appointment.pet', 'medications'])
        ->where('InvoiceID', $id)
        ->first();

    if (!$invoice) {
        return response()->json(['message' => 'Not found'], 404);
    }

    $appointment = $invoice->appointment;

    if (!$appointment) {
        return response()->json(['error' => 'Không tìm thấy lịch hẹn'], 404);
    }

    $medicines = $invoice->medications->map(function ($m) {
        return [
            'MedicationID' => $m->MedicationID,
            'Name' => $m->Name,
            'Price' => $m->Price,
            'Quantity' => $m->pivot->Quantity,
        ];
    });

    $data = $invoice->toArray();
    $data['medications'] = $medicines;

    return response()->json($data);
}

    // Cập nhật hóa đơn
    public function update(Request $request, $id)
    {
        $invoice = Invoices::where('InvoiceID', $id)->first();
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        $validator = Validator::make($request->all(), [
            'ServicePrice' => 'nullable|numeric|min:0',
            'MedicineTotal' => 'nullable|numeric|min:0',
            'TotalAmount' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $invoice->update($request->only(['ServicePrice', 'MedicineTotal', 'TotalAmount']));

        return response()->json(['message' => 'Updated successfully', 'data' => $invoice], 200);
    }

    // Xóa hóa đơn
    public function destroy($id)
    {
        $invoice = Invoices::where('InvoiceID', $id)->first();
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        InvoiceMedicine::where('InvoiceID', $invoice->InvoiceID)->delete();
        $invoice->delete();

        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
