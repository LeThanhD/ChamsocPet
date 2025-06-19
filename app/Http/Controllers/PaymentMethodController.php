<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PaymentMethod;

class PaymentMethodController extends Controller
{
    public function index()
    {
        return response()->json(PaymentMethod::all());
    }

    public function store(Request $request)
    {
        $method = PaymentMethod::create($request->all());
        return response()->json($method, 201);
    }

    public function update($id, Request $request)
    {
        $method = PaymentMethod::findOrFail($id);
        $method->update($request->all());
        return response()->json($method);
    }

    public function destroy($id)
    {
        PaymentMethod::destroy($id);
        return response()->json(['message' => 'Deleted']);
    }
}
