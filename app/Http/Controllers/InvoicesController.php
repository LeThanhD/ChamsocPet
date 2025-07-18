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

    $appointment = Appointment::with([
        'services',
        'service',
        'pet',
        'user' => function ($query) {
            $query->select(
                'UserID',
                'discount',
                'promotion_title', // 🔥 thêm dòng này
                'promotion_note',
                'is_vip',
                'total_completed_appointments'
            );
        }
    ])->where('AppointmentID', $request->appointment_id)->first();

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

    if ($request->has('medicine_ids') && !empty($request->medicine_ids)) {
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
    } else {
        $meds = \DB::table('appointment_medications')
            ->where('AppointmentID', $request->appointment_id)
            ->get();

        foreach ($meds as $med) {
            $medicine = Medications::where('MedicationID', $med->MedicationID)->first();
            if (!$medicine) continue;

            $lineTotal = $medicine->Price * $med->Quantity;
            $medicineTotal += $lineTotal;

            $medicineDetails[] = [
                'id' => $medicine->MedicationID,
                'name' => $medicine->Name,
                'price' => $medicine->Price,
                'quantity' => $med->Quantity,
                'subtotal' => $lineTotal,
            ];
        }
    }

    $total = $servicePrice + $medicineTotal;

    // 🔥 Áp dụng khuyến mãi từ user
    $user = $appointment->user;
    $discountPercent = 0;
    $discountTitle = null;
    $discountNote = null;


    if (!is_null($user->discount) && $user->discount > 0) {
        $discountPercent = $user->discount;
        $discountNote = $user->promotion_note ?? "Giảm $discountPercent% từ chương trình khuyến mãi";
    }
    elseif ($user->is_vip) {
        $discountPercent = 20;
        $discountNote = 'Khuyến mãi 20% cho khách VIP';
    } elseif ($user->total_completed_appointments > 0) {
        $discountPercent = 10;
        $discountNote = 'Khuyến mãi 10% cho khách hàng cũ';
    }

    // Ghi đè nếu có dữ liệu tùy chỉnh từ bảng users
    if (!empty($user->promotion_title)) {
        $discountTitle = $user->promotion_title;
    }

    if (!empty($user->promotion_note)) {
        $discountNote = $user->promotion_note;
    }

    $discountAmount = round($total * $discountPercent / 100, 2);
    $totalAfterDiscount = round($total - $discountAmount, 2);

    // ✅ Tạo Invoice
    $invoice = Invoices::create([
        'InvoiceID'     => 'INV' . strtoupper(Str::random(6)),
        'AppointmentID' => $appointment->AppointmentID,
        'PetID'         => $appointment->PetID,
        'ServicePrice'  => round($servicePrice, 2),
        'MedicineTotal' => round($medicineTotal, 2),
        'TotalAmount'   => $totalAfterDiscount,
        'Note'          => $discountNote ?? $discountTitle ?? null,
        'Status'        => 'Pending',
        'CreatedAt'     => now(),
    ]);

    // Lưu dịch vụ
    if ($services && $services->count() > 0) {
        $serviceIds = $services->pluck('ServiceID')->toArray();
        $invoice->services()->attach($serviceIds);
    }

    // Lưu thuốc
    foreach ($medicineDetails as $m) {
        InvoiceMedicine::create([
            'InvoiceID'  => $invoice->InvoiceID,
            'MedicineID' => $m['id'],
            'Quantity'   => $m['quantity'],
        ]);
    }

    // Gửi thông báo
    Notification::create([
        'user_id' => $appointment->UserID,
        'title' => 'Hóa đơn thanh toán',
        'message' => 'Hóa đơn cho lịch hẹn #' . $appointment->AppointmentID . ' đã được tạo. Tổng tiền (sau ưu đãi): ' . number_format($totalAfterDiscount) . ' VND.',
        'created_at' => now(),
    ]);

    return response()->json([
        'message' => 'Hóa đơn đã được tạo thành công',
        'data' => [
            'invoice' => $invoice,
            'total_after_discount' => $totalAfterDiscount,
            'discount' => [
                'percent' => $discountPercent,
                'title' => $discountTitle,
                'note' => $discountNote,
                'amount_saved' => $discountAmount,
            ],
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
    $invoice = Invoices::with([
        'appointment.services',
        'appointment.service',
        'appointment.user',
        'appointment.pet',
        'medications'
    ])->where('InvoiceID', $id)->first();

    if (!$invoice) {
        return response()->json(['message' => 'Not found'], 404);
    }

    $appointment = $invoice->appointment;

    if (!$appointment) {
        return response()->json(['error' => 'Không tìm thấy lịch hẹn'], 404);
    }

    // Xử lý thuốc
    $medicines = $invoice->medications->map(function ($m) {
        return [
            'MedicationID' => $m->MedicationID,
            'Name' => $m->Name,
            'Price' => $m->Price,
            'Quantity' => $m->pivot->Quantity,
        ];
    });

    // Đổ dữ liệu invoice
    $data = $invoice->toArray();
    $data['medications'] = $medicines;

    // 👇 Gộp tên thú cưng vào để Flutter dễ lấy
    $data['pet'] = $appointment->pet ? $appointment->pet->toArray() : null;

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
