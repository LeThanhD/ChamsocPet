<?php

namespace App\Http\Controllers;

use App\Models\Pet;
use App\Models\PetNotes;
use App\Models\Appointment;
use Illuminate\Http\Request;
use App\Models\Invoices;
use App\Models\Payment;
use App\Models\Service;
use App\Models\Medication;


class PetController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        $role = $request->query('role');

        // Nếu không có user_id hoặc role, trả lỗi
        if (!$userId || !$role) {
            return response()->json(['error' => 'Thiếu user_id hoặc role'], 400);
        }

        // Nếu là nhân viên thì trả về toàn bộ thanh toán
        if ($role === 'staff') {
            return response()->json(Payment::orderByDesc('PaymentTime')->get());
        }

        // Nếu là người dùng thì chỉ trả thanh toán của họ
        $payments = Payment::where('UserID', $userId)
            ->orderByDesc('PaymentTime')
            ->get();

        return response()->json($payments);
    }


       public function getPetUsedServicesAndMedications($petId)
{
    // Lấy tất cả các cuộc hẹn của pet
    $appointments = Appointment::where('PetID', $petId)->pluck('AppointmentID');

    if ($appointments->isEmpty()) {
        return response()->json([
            'message' => 'Pet chưa có lịch hẹn nào.',
            'services' => [],
            'medications' => [],
        ]);
    }

    // Lấy các InvoiceID của các hóa đơn thuộc cuộc hẹn trên
    $invoiceIds = Invoices::whereIn('AppointmentID', $appointments)->pluck('InvoiceID');

    if ($invoiceIds->isEmpty()) {
        return response()->json([
            'message' => 'Pet chưa có hóa đơn nào.',
            'services' => [],
            'medications' => [],
        ]);
    }

    // Lấy danh sách InvoiceID đã có payment "đã duyệt" (hoặc trạng thái tương ứng)
    $paidInvoiceIds = Payment::whereIn('InvoiceID', $invoiceIds)
        ->where('Status', 'đã duyệt')
        ->pluck('InvoiceID');

    if ($paidInvoiceIds->isEmpty()) {
        return response()->json([
            'message' => 'Pet chưa sử dụng dịch vụ hay thuốc nào.',
            'services' => [],
            'medications' => [],
        ]);
    }

    // Lấy các hóa đơn đã được thanh toán (có trong danh sách paidInvoiceIds)
    $invoices = Invoices::with(['services', 'medications'])
        ->whereIn('InvoiceID', $paidInvoiceIds)
        ->get();

    // Gộp danh sách dịch vụ và thuốc từ tất cả hóa đơn, loại bỏ trùng lặp
    $allServices = collect();
    $allMedications = collect();

    foreach ($invoices as $invoice) {
        if ($invoice->services) {
            $allServices = $allServices->merge($invoice->services);
        }
        if ($invoice->medications) {
            $allMedications = $allMedications->merge($invoice->medications);
        }
    }

    // Loại trùng dựa trên ID
    $uniqueServices = $allServices->unique('ServiceID')->values();
    $uniqueMedications = $allMedications->unique('MedicationID')->values();

    return response()->json([
        'message' => 'Danh sách dịch vụ và thuốc đã sử dụng',
        'services' => $uniqueServices,
        'medications' => $uniqueMedications,
    ]);
}

    // Lấy thú cưng của user cụ thể (chỉ chính chủ mới xem được)
    public function getPetsByUser(Request $request, $userId)
    {
        $authUser = auth()->user();
        if ($userId !== $authUser->UserID) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $search = $request->query('search');
        $query = Pet::with(['latestNote', 'user'])->where('UserID', $userId);

        if ($search) {
            $query->where('Name', 'like', "%$search%");
        }

        return response()->json($query->get());
    }


    // ✅ Staff được xem toàn bộ thú cưng của mọi người, kèm tên chủ và phân trang
    public function getAllPetsForStaff(Request $request)
    {
        $role = $request->query('role');
        $search = $request->query('search'); // Lấy từ query string nếu có

        if ($role !== 'staff') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $query = Pet::with(['latestNote', 'user:UserID,FullName']);

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('Name', 'like', '%' . $search . '%')
                ->orWhereHas('user', function ($uq) use ($search) {
                    $uq->where('FullName', 'like', '%' . $search . '%');
                });
            });
        }

        $pets = $query->paginate(10);

        return response()->json($pets);
    }


    public function store(Request $request)
{
    $validated = $request->validate([
        'Name' => 'required|string',
        'Gender' => 'required|string',
        'FurColor' => 'required|string',
        'Species' => 'required|string',
        'Breed' => 'required|string',
        'BirthDate' => 'required|date',
        'Weight' => 'required|numeric',
        'fur_type' => 'nullable|string',
        'origin' => 'nullable|string',
        'vaccinated' => 'nullable|boolean',
        'last_vaccine_date' => 'nullable|date',
        'trained' => 'nullable|boolean',
        'HealthStatus' => 'nullable|string',
    ]);

    $userId = auth()->user()->UserID;

    // ✅ Tạo prefix từ UserID (6 ký tự in hoa không đặc biệt)
    $prefix = strtoupper(substr(preg_replace('/[^A-Z0-9]/', '', $userId), 0, 6));

    // ✅ Tạo chuỗi duy nhất từ thời gian: Hisv (giờ, phút, giây, mili)
    $unique = now()->format('Hisv'); // Ex: 154523678

    // ✅ Tạo PetID mới, đảm bảo không bao giờ trùng
    $petId = 'PET' . $prefix . $unique;

    // ✅ Tạo bản ghi thú cưng
    $pet = Pet::create(array_merge(
        $request->only([
            'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
            'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
        ]),
        ['UserID' => $userId, 'PetID' => $petId]
    ));

    // ✅ Nếu có ghi chú tình trạng sức khoẻ
    if (!empty($validated['HealthStatus'])) {
        PetNotes::create([
            'NoteID' => 'PNOTE' . now()->format('YmdHisv'),
            'PetID' => $petId,
            'Content' => $validated['HealthStatus'],
            'CreatedAt' => now(),
        ]);
    }

    return response()->json($pet, 201);
}


    public function update(Request $request, $petId)
{
    $pet = Pet::where('PetID', $petId)->first();
    if (!$pet) {
        return response()->json(['message' => 'Pet not found'], 404);
    }

    $validated = $request->validate([
        'Name' => 'required|string',
        'Gender' => 'required|string',
        'FurColor' => 'required|string',
        'Species' => 'required|string',
        'Breed' => 'required|string',
        'BirthDate' => 'required|date',
        'Weight' => 'required|numeric',
        'fur_type' => 'nullable|string',
        'origin' => 'nullable|string',
        'vaccinated' => 'nullable|boolean',
        'last_vaccine_date' => 'nullable|date',
        'trained' => 'nullable|boolean',
        'HealthStatus' => 'nullable|string',
    ]);

    $pet->update($request->only([
        'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
        'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
    ]));

    // ✅ Cập nhật ghi chú sức khỏe nếu có
    if (!empty($validated['HealthStatus'])) {
        $note = $pet->notes()->latest()->first();
        if ($note) {
            $note->update(['Content' => $validated['HealthStatus']]);
        } else {
            PetNotes::create([
                'NoteID' => 'PNOTE' . now()->format('YmdHisv'),
                'PetID' => $pet->PetID,
                'Content' => $validated['HealthStatus'],
                'CreatedAt' => now(),
            ]);
        }
    }

    return response()->json(['message' => 'Cập nhật thành công', 'pet' => $pet]);
}

   public function destroy(Request $request, $id)
{
    $pet = Pet::find($id);
    if (!$pet) {
        return response()->json(['message' => 'Pet not found'], 404);
    }

    $userId = $request->input('user_id'); // ✅ Lấy user_id từ client

    // ✅ Cho phép xoá nếu chính chủ (hoặc bạn có thể cho phép staff)
    if ($userId !== $pet->UserID) {
        return response()->json(['message' => 'Bạn không có quyền!'], 403);
    }

    // ✅ Tìm tất cả các cuộc hẹn liên quan đến thú cưng
    $appointments = Appointment::where('PetID', $id)->get();

    foreach ($appointments as $appointment) {
        // ✅ Xoá lịch sử cuộc hẹn trước
        $appointment->histories()->delete();

        // ✅ Sau đó xoá chính cuộc hẹn
        $appointment->delete();
    }

    // ✅ Sau đó xoá ghi chú sức khỏe và bản ghi thú cưng
    $pet->notes()->delete();
    $pet->delete();

    return response()->json(['message' => 'Pet deleted']);
}
}
