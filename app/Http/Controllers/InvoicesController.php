<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Invoice;
use Illuminate\Support\Facades\Validator;

class InvoiceController extends Controller
{
    // 1. Tạo hóa đơn
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID' => 'required|exists:Pets,PetID',
            'TotalAmount' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $invoice = Invoice::create([
            'PetID' => $request->PetID,
            'TotalAmount' => $request->TotalAmount,
        ]);

        return response()->json(['message' => 'Created successfully', 'data' => $invoice], 201);
    }

    // 2. Lấy tất cả hoặc 1 hóa đơn
    public function index(Request $request)
    {
        if ($request->has('id')) {
            $invoice = Invoice::find($request->id);
            if (!$invoice) return response()->json(['message' => 'Not found'], 404);
            return response()->json($invoice);
        }

        return response()->json(Invoice::all());
    }

    // 3. Cập nhật hóa đơn
    public function update(Request $request, $id)
    {
        $invoice = Invoice::find($id);
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        $validator = Validator::make($request->all(), [
            'TotalAmount' => 'sometimes|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $invoice->update($request->only(['TotalAmount']));
        return response()->json(['message' => 'Updated successfully', 'data' => $invoice], 200);
    }

    // 4. Xóa hóa đơn
    public function destroy($id)
    {
        $invoice = Invoice::find($id);
        if (!$invoice) return response()->json(['message' => 'Not found'], 404);

        $invoice->delete();
        return response()->json(['message' => 'Deleted successfully'], 200);
    }
}

