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
    // ✅ Tạo hóa đơn
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'appointment_id' => 'required|exists:appointments,AppointmentID',
            'medicine_ids' => 'array',
            'medicine_ids.*.id' => 'required|exists:medications,MedicationID',
            'medicine_ids.*.quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $appointment = Appointment::with(['service', 'user'])->where('AppointmentID', $request->appointment_id)->first();
        if (!$appointment) {
            return response()->json(['message' => 'Lịch hẹn không tồn tại'], 404);
        }

        $servicePrice = $appointment->service->Price;
        $medicineTotal = 0;
        $medicineDetails = [];

        if ($request->medicine_ids) {
            foreach ($request->medicine_ids as $item) {
                $medicine = Medications::where('MedicationID', $item['id'])->first();
                if (!$medicine) continue;

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

        $invoice = Invoices::create([
            'InvoiceID' => 'INV' . strtoupper(Str::random(6)),
            'AppointmentID' => $appointment->AppointmentID,
            'PetID' => $appointment->PetID,
            'ServicePrice' => $servicePrice,
            'MedicineTotal' => $medicineTotal,
            'TotalAmount' => $total,
            'CreatedAt' => now(),
        ]);

        foreach ($medicineDetails as $m) {
            InvoiceMedicine::create([
                'InvoiceID' => $invoice->InvoiceID,
                'MedicineID' => $m['id'],
                'Quantity' => $m['quantity'],
            ]);
        }

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
                    'service' => [
                        'name' => $appointment->service->ServiceName,
                        'price' => $servicePrice,
                    ],
                    'medicines' => $medicineDetails
                ]
            ]
        ], 201);
    }

    // ✅ Danh sách hóa đơn theo role, search, user
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        $role = $request->query('role');
        $search = $request->query('search');

        $query = Invoices::with(['appointment.pet']);

        if ($role !== 'staff') {
            if (!$userId) return response()->json(['message' => 'Thiếu user_id'], 400);

            $query->whereHas('appointment', fn($q) => $q->where('UserID', $userId));
        }

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('InvoiceID', 'like', "%$search%")
                  ->orWhere('AppointmentID', 'like', "%$search%")
                  ->orWhereHas('appointment.pet', fn($q2) => $q2->where('name', 'like', "%$search%"));
            });
        }

        $invoices = $query->get();

        foreach ($invoices as $invoice) {
            $invoice->name = optional($invoice->appointment->pet)->Name;
        }

        return response()->json(['data' => $invoices]);
    }

    // ✅ Lấy hóa đơn theo user đăng nhập
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

    // ✅ Xem chi tiết hóa đơn
    public function show($id)
    {
        $invoice = Invoices::with(['appointment.pet', 'medicines'])
            ->where('InvoiceID', $id)
            ->first();

        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        $invoice->name = optional($invoice->appointment->pet)->Name;

        // Map đúng thuốc
        $medicines = $invoice->medicines->map(function ($m) {
            return [
                'MedicineID' => $m->MedicationID,
                'Name' => $m->Name,
                'Price' => $m->Price,
                'Quantity' => $m->pivot->Quantity,
            ];
        });

        $data = $invoice->toArray();
        $data['medicines'] = $medicines;

        return response()->json($data);
    }


    // ✅ Cập nhật hóa đơn
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

    // ✅ Xóa hóa đơn
    public function destroy($id)
    {
        $invoice = Invoices::where('InvoiceID', $id)->first();
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        InvoiceMedicine::where('InvoiceID', $invoice->InvoiceID)->delete();
        $invoice->delete();

        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
