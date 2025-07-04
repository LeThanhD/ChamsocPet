<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\InvoiceDetail;
use Illuminate\Support\Facades\Validator;

class InvoiceDetailController extends Controller
{
    // ✅ 1. Tạo chi tiết hóa đơn
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'InvoiceID' => 'required|exists:Invoices,InvoiceID',
            'ServiceID' => 'nullable|exists:Services,ServiceID',
            'MedicationID' => 'nullable|exists:Medications,MedicationID',
            'Quantity' => 'required|integer|min:1',
            'UnitPrice' => 'required|numeric|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $detail = InvoiceDetail::create($request->only([
            'InvoiceID', 'ServiceID', 'MedicationID', 'Quantity', 'UnitPrice'
        ]));

        return response()->json([
            'message' => 'Created successfully',
            'data' => $detail
        ], 201);
    }

    // ✅ 2. Lấy tất cả chi tiết hoặc theo id, kèm thông tin thuốc/dịch vụ
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $detail = InvoiceDetail::with(['medication', 'service'])->find($request->id);
            if (!$detail) {
                return response()->json(['message' => 'Not found'], 404);
            }
            return response()->json($detail);
        }

        $details = InvoiceDetail::with(['medication', 'service'])->get();
        return response()->json($details);
    }

    // ✅ 3. Lấy chi tiết theo InvoiceID
    public function getByInvoice($invoiceId)
    {
        $details = InvoiceDetail::with(['medication', 'service'])
            ->where('InvoiceID', $invoiceId)
            ->get();

        return response()->json($details);
    }

    // ✅ 4. Cập nhật dòng chi tiết
    public function update(Request $request, $id)
    {
        $detail = InvoiceDetail::find($id);
        if (!$detail) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Quantity' => 'sometimes|integer|min:1',
            'UnitPrice' => 'sometimes|numeric|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $detail->update($request->only(['Quantity', 'UnitPrice']));

        return response()->json([
            'message' => 'Updated successfully',
            'data' => $detail
        ]);
    }

    // ✅ 5. Xóa dòng chi tiết
    public function destroy($id)
    {
        $detail = InvoiceDetail::find($id);
        if (!$detail) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $detail->delete();

        return response()->json(['message' => 'Deleted successfully']);
    }
}
