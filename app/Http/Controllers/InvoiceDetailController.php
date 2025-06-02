<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\InvoiceDetail;
use Illuminate\Support\Facades\Validator;

class InvoiceDetailController extends Controller
{
    // 1. Tạo chi tiết hóa đơn
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

        $detail = InvoiceDetail::create($request->all());
        return response()->json(['message' => 'Created successfully', 'data' => $detail], 201);
    }

    // 2. Lấy danh sách tất cả hoặc 1 dòng chi tiết
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $detail = InvoiceDetail::find($request->id);
            if (!$detail) return response()->json(['message' => 'Not found'], 404);
            return response()->json($detail);
        }

        return response()->json(InvoiceDetail::all());
    }

    // 3. Cập nhật dòng chi tiết
    public function update(Request $request, $id)
    {
        $detail = InvoiceDetail::find($id);
        if (!$detail) return response()->json(['message' => 'Not found'], 404);

        $validator = Validator::make($request->all(), [
            'Quantity' => 'sometimes|integer|min:1',
            'UnitPrice' => 'sometimes|numeric|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $detail->update($request->only(['Quantity', 'UnitPrice']));
        return response()->json(['message' => 'Updated successfully', 'data' => $detail], 200);
    }

    // 4. Xóa dòng chi tiết
    public function destroy($id)
    {
        $detail = InvoiceDetail::find($id);
        if (!$detail) return response()->json(['message' => 'Not found'], 404);

        $detail->delete();
        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}
