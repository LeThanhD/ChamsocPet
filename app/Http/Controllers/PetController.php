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
use App\Http\Controllers\InvoicesController; 
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Http\Controllers\PetNotesController; 
use App\Models\Vaccine;

class PetController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        $role = $request->query('role');

        if (!$userId || !$role) {
            return response()->json(['error' => 'Thiếu user_id hoặc role'], 400);
        }

        if ($role === 'staff') {
            return response()->json(Payment::orderByDesc('PaymentTime')->get());
        }

        $payments = Payment::where('UserID', $userId)
            ->orderByDesc('PaymentTime')
            ->get();

        return response()->json($payments);
    }

    public function getPetUsedServicesAndMedications($petId)
    {
        $appointments = Appointment::where('PetID', $petId)->pluck('AppointmentID');

        if ($appointments->isEmpty()) {
            return response()->json([
                'message' => 'Pet chưa có lịch hẹn nào.',
                'services' => [],
                'medications' => [],
            ]);
        }

        $invoiceIds = Invoices::whereIn('AppointmentID', $appointments)->pluck('InvoiceID');

        if ($invoiceIds->isEmpty()) {
            return response()->json([
                'message' => 'Pet chưa có h\u00f3a \u0111\u01a1n n\u00e0o.',
                'services' => [],
                'medications' => [],
            ]);
        }

        $paidPayments = Payment::whereIn('InvoiceID', $invoiceIds)
            ->where('Status', '\u0111\u00e3 duy\u1ec7t')
            ->get();

        if ($paidPayments->isEmpty()) {
            return response()->json([
                'message' => 'Pet ch\u01b0a s\u1eed d\u1ee5ng d\u1ecbch v\u1ee5 hay thu\u1ed1c n\u00e0o.',
                'services' => [],
                'medications' => [],
            ]);
        }

        $paidInvoiceIds = $paidPayments->pluck('InvoiceID')->toArray();
        $paymentTimes = $paidPayments->pluck('PaymentTime', 'InvoiceID');

        $invoices = Invoices::with(['services', 'medications'])
            ->whereIn('InvoiceID', $paidInvoiceIds)
            ->get();

        $serviceResults = [];
        $medicationResults = [];

        foreach ($invoices as $invoice) {
            $usedTime = $paymentTimes[$invoice->InvoiceID] ?? null;

            foreach ($invoice->services as $service) {
                $serviceResults[] = [
                    'ServiceID' => $service->ServiceID,
                    'ServiceName' => $service->ServiceName,
                    'Description' => $service->Description,
                    'Price' => $service->Price,
                    'CategoryID' => $service->CategoryID,
                    'InvoiceID' => $invoice->InvoiceID,
                    'UsedTime' => $usedTime,
                ];
            }

            foreach ($invoice->medications as $med) {
                $medicationResults[] = [
                    'MedicationID' => $med->MedicationID,
                    'Name' => $med->Name,
                    'Price' => $med->Price,
                    'InvoiceID' => $invoice->InvoiceID,
                    'UsedTime' => $usedTime,
                ];
            }
        }

        return response()->json([
            'message' => 'Danh s\u00e1ch d\u1ecbch v\u1ee5 v\u00e0 thu\u1ed1c \u0111\u00e3 s\u1eed d\u1ee5ng',
            'services' => $serviceResults,
            'medications' => $medicationResults,
        ]);
    }

    public function getPetsByUser(Request $request, $userId)
    {
        $authUser = auth()->user();
        if ($userId !== $authUser->UserID) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $search = $request->query('search');
        $query = Pet::with(['latestNote', 'user'])->where('UserID', $userId)->where('status', 1);

        if ($search) {
            $query->where('Name', 'like', "%$search%");
        }

        return response()->json($query->get());
    }

    public function getAllPetsForStaff(Request $request)
    {
        $role = $request->query('role');
        $search = $request->query('search');

        if ($role !== 'staff') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $query = Pet::with(['latestNote', 'user:UserID,FullName'])->where('status', 1);

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('Name', 'like', "%$search%")
                  ->orWhereHas('user', function ($uq) use ($search) {
                      $uq->where('FullName', 'like', "%$search%");
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
            'vaccines' => 'nullable|array',
        ]);

        $userId = auth()->user()->UserID;
        $prefix = strtoupper(substr(preg_replace('/[^A-Z0-9]/', '', $userId), 0, 6));
        $unique = now()->format('Hisv');
        $petId = 'PET' . $prefix . $unique;

        $pet = Pet::create(array_merge(
            $request->only([
                'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
                'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
            ]),
            ['UserID' => $userId, 'PetID' => $petId, 'status' => 1]
        ));

        if (!empty($validated['HealthStatus'])) {
            $noteId = PetNotes::generateUniqueNoteID();
            PetNotes::create([
                'NoteID' => $noteId,
                'PetID' => $petId,
                'Content' => $validated['HealthStatus'],
                'CreatedAt' => now(),
                'CreatedBy' => $userId,
            ]);
        }

        // Vaccine logic giữ nguyên...

        return response()->json($pet, 201);
    }

  public function destroy(Request $request, $id)
{
    $pet = Pet::find($id);
    if (!$pet) {
        return response()->json(['message' => 'Pet not found'], 404);
    }

    $userId = $request->input('user_id');

    if ($userId !== $pet->UserID) {
        return response()->json(['message' => 'Bạn không có quyền!'], 403);
    }

    if ($pet->status == 0) {
        return response()->json(['message' => 'Thú cưng đã bị xoá trước đó.'], 400);
    }

    // ❌ Nếu thú cưng đã có lịch hẹn thì không cho xoá
    $hasAppointments = Appointment::where('PetID', $id)->exists();
    if ($hasAppointments) {
        return response()->json(['message' => 'Không thể xoá thú cưng đã có lịch hẹn.'], 400);
    }

    // ✅ Xoá mềm thú cưng
    $pet->status = 0;
    $pet->save();

    // ✅ Xoá ghi chú sức khoẻ
    $pet->notes()->delete();

    return response()->json(['message' => 'Thú cưng đã được xoá (mềm).']);
}

public function getPetVaccines($petId)
    {
        $vaccines = DB::table('pet_vaccine as pv')
            ->join('vaccines as v', 'pv.VaccineID', '=', 'v.VaccineID')
            ->where('pv.PetID', $petId)
            ->select('v.VaccineID', 'v.Name', 'pv.VaccinatedAt')
            ->orderBy('pv.VaccinatedAt', 'desc')
            ->get();

        return response()->json([
            'message' => 'Danh sách vaccine đã tiêm',
            'data' => $vaccines
        ]);
    }

    public function update(Request $request, $id)
{
    $pet = Pet::find($id);
    if (!$pet) {
        return response()->json(['message' => 'Không tìm thấy thú cưng'], 404);
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
        'vaccines' => 'nullable|array',
    ]);

    // ✅ Cập nhật thông tin thú cưng
    $pet->update($request->only([
        'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
        'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
    ]));

    // ✅ Cập nhật ghi chú sức khỏe (xoá cũ, thêm mới)
    if (!empty($validated['HealthStatus'])) {
        $pet->notes()->delete(); // hoặc chỉ update nếu có sẵn
        $noteId = PetNotes::generateUniqueNoteID();
        PetNotes::create([
            'NoteID' => $noteId,
            'PetID' => $pet->PetID,
            'Content' => $validated['HealthStatus'],
            'CreatedAt' => now(),
            'CreatedBy' => auth()->user()->UserID,
        ]);
    }

    // ✅ Cập nhật vaccine nếu có
    if (!empty($validated['vaccines'])) {
        DB::table('pet_vaccine')->where('PetID', $pet->PetID)->delete();

        foreach ($validated['vaccines'] as $vaccineId) {
            DB::table('pet_vaccine')->insert([
                'PetID' => $pet->PetID,
                'VaccineID' => $vaccineId,
                'VaccinatedAt' => now(),
            ]);
        }
    }

    return response()->json([
        'message' => 'Cập nhật thú cưng thành công!',
        'data' => $pet
    ]);
}


    public function getAllVaccines()
    {
        $vaccines = DB::table('vaccines')
            ->select('VaccineID', 'Name', 'Description')
            ->orderBy('Name')
            ->get();

        return response()->json([
            'message' => 'Danh sách tất cả các loại vaccine',
            'data' => $vaccines
        ]);
    }




public function getPetDetailWithVaccines($petId)
{
    $pet = Pet::with(['latestNote', 'user', 'vaccines'])->where('PetID', $petId)->first();

    if (!$pet) {
        return response()->json(['message' => 'Không tìm thấy thú cưng'], 404);
    }

    // Lấy danh sách tên vaccine (nếu có)
    $vaccineNames = $pet->vaccines->map(function ($vaccine) {
        return $vaccine->Name;
    });

    // Nếu không có vaccine => "Chưa tiêm"
    $vaccinated = $vaccineNames->isNotEmpty();
    $latestVaccineDate = $vaccinated
        ? optional($pet->vaccines->sortByDesc('pivot.VaccinatedAt')->first())->pivot->VaccinatedAt
        : null;

    return response()->json([
        'message' => 'Thông tin chi tiết thú cưng',
        'data' => [
            'PetID' => $pet->PetID,
            'Name' => $pet->Name,
            'Species' => $pet->Species,
            'Breed' => $pet->Breed,
            'FurColor' => $pet->FurColor,
            'Weight' => $pet->Weight,
            'BirthDate' => $pet->BirthDate,
            'fur_type' => $pet->fur_type,
            'origin' => $pet->origin,
            'Gender' => $pet->Gender,
            'HealthNote' => optional($pet->latestNote)->Content ?? null,
            'trained' => $pet->trained,
            'owner' => $pet->user->FullName ?? null,
            'vaccinated' => $vaccinated ? 'Đã tiêm' : 'Chưa tiêm',
            'latest_vaccine_date' => $latestVaccineDate ?? 'Không rõ',
            'vaccine_names' => $vaccineNames->values(),
        ]
    ]);
}

}
