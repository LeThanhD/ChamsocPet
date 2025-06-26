<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;
use App\Models\Pet;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class AppointmentController extends Controller
{
    // Tạo cuộc hẹn mới
    public function store(Request $request)
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'PetID' => 'required|exists:Pets,PetID',
            'ServiceID' => 'required|exists:Services,ServiceID',
            'AppointmentDate' => 'required|date',
            'AppointmentTime' => 'required|date_format:H:i:s',
            'Reason' => 'required|string',
            'Status' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $pet = Pet::find($request->PetID);
        if (!$pet) {
            return response()->json(['message' => 'Pet not found'], 404);
        }

        $lastAppointment = Appointment::orderBy('AppointmentID', 'desc')->first();
        $lastNumber = 0;

        if ($lastAppointment && preg_match('/APP(\d+)/', $lastAppointment->AppointmentID, $matches)) {
            $lastNumber = intval($matches[1]);
        }

        $nextNumber = str_pad($lastNumber + 1, 3, '0', STR_PAD_LEFT);
        $sanitizedPetName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $pet->Name));
        $appointmentId = "APP{$nextNumber}{$sanitizedPetName}";

        $appointment = Appointment::create([
            'AppointmentID'     => $appointmentId,
            'PetID'             => $request->PetID,
            'UserID'            => $user->UserID,
            'ServiceID'         => $request->ServiceID,
            'AppointmentDate'   => $request->AppointmentDate,
            'AppointmentTime'   => $request->AppointmentTime,
            'Reason'            => $request->Reason,
            'Status'            => $request->Status,
        ]);

        return response()->json([
            'message' => 'Created successfully',
            'data' => $appointment->load(['user', 'service', 'pet']),
        ], 201);
    }

    // Lấy danh sách lịch hẹn của người dùng đang đăng nhập
            public function index(Request $request)
    {
        $userId = $request->query('UserID'); // Lấy từ URL ?UserID=abc

        if (!$userId) {
            return response()->json(['message' => 'Missing UserID'], 400);
        }

        $appointments = Appointment::with(['user', 'pet', 'service'])
            ->where('UserID', $userId)
            ->orderBy('AppointmentDate', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $appointments,
        ]);
    }



    // Cập nhật lịch hẹn
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
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $appointment->update($request->only([
            'AppointmentDate', 'AppointmentTime', 'Reason', 'Status',
        ]));

        return response()->json([
            'message' => 'Updated successfully',
            'data' => $appointment->load(['user', 'service', 'pet']),
        ]);
    }

    // Xoá thú cưng + lịch hẹn liên quan
    public function destroy($id)
    {
        $pet = Pet::find($id);
        if (!$pet) {
            return response()->json(['message' => 'Pet not found'], 404);
        }

        $pet->notes()->delete();
        Appointment::where('PetID', $pet->PetID)->delete();
        $pet->delete();

        return response()->json(['message' => 'Pet and related appointments deleted']);
    }
}
