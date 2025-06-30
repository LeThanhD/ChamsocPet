<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Invoices;
use App\Models\Appointment;
use App\Models\Medication;
use App\Models\Notification;
use App\Models\InvoiceMedicine;
use Illuminate\Support\Facades\Validator;

class InvoicesController extends Controller
{
    // ✅ Tạo hóa đơn từ lịch hẹn và danh sách thuốc
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
                $medicine = Medication::find($item['id']);
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
            'AppointmentID' => $appointment->AppointmentID,
            'PetID' => $appointment->PetID,
            'ServicePrice' => $servicePrice,
            'MedicineTotal' => $medicineTotal,
            'TotalAmount' => $total,
            'CreatedAt' => now(),
        ]);

        // ✅ Lưu chi tiết thuốc nếu có
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

    // ✅ Lấy hóa đơn theo user đăng nhập
    public function getByUser(Request $request)
    {
        $userId = $request->user()->UserID;

        $invoices = Invoices::whereHas('appointment', function ($q) use ($userId) {
            $q->where('UserID', $userId);
        })->with('appointment')->get();

        return response()->json(['data' => $invoices]);
    }

    // ✅ Hiển thị chi tiết một hóa đơn
    public function show($id)
    {
        $invoice = Invoices::with(['appointment', 'medicines'])->find($id);
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        return response()->json($invoice);
    }

    // ✅ Lấy danh sách tất cả hoặc một hóa đơn cụ thể
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $invoice = Invoices::with('appointment')->find($request->id);
            if (!$invoice) return response()->json(['message' => 'Not found'], 404);
            return response()->json($invoice);
        }

        return response()->json(Invoices::with('appointment')->get());
    }

    // ✅ Cập nhật hóa đơn
    public function update(Request $request, $id)
    {
        $invoice = Invoices::find($id);
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
        $invoice = Invoices::find($id);
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        InvoiceMedicine::where('InvoiceID', $invoice->InvoiceID)->delete();
        $invoice->delete();

        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
