<?php

namespace App\Http\Controllers;

use App\Models\Pet;
use App\Models\PetNotes;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PetController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('UserID');

        if (!$userId) {
            return response()->json(['error' => 'UserID is required'], 400);
        }

        $pets = Pet::with(['latestNote', 'user'])->where('UserID', $userId)->get();

        return response()->json($pets);
    }

    // 🚨 Thêm kiểm tra user hiện tại để đảm bảo chỉ xem pet của mình
    public function getPetsByUser($userId)
    {
        $authUser = auth()->user(); // lấy user hiện tại từ token
        if ($userId !== $authUser->UserID) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $pets = Pet::with(['latestNote', 'user'])->where('UserID', $userId)->get();
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

        $userId = auth()->user()->UserID; // Lấy user_id từ auth token

        $prefix = strtoupper(substr(preg_replace('/[^A-Z0-9]/', '', $userId), 0, 8));
        $suffix = strtoupper(preg_replace('/[^A-Z0-9]/', '', $validated['Name']));

        $lastPet = Pet::where('PetID', 'like', "PET{$prefix}%")
            ->orderByDesc('PetID')
            ->first();

        $nextNumber = 1;
        if ($lastPet && preg_match('/PET' . $prefix . '(\d+)/', $lastPet->PetID, $matches)) {
            $nextNumber = (int)$matches[1] + 1;
        }

        $petId = 'PET' . $prefix . $nextNumber . $suffix;

        $pet = Pet::create(array_merge(
            $request->only([
                'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
                'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
            ]),
            ['UserID' => $userId, 'PetID' => $petId] // Gán UserID từ auth
        ));

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

    public function update(Request $request, $id)
    {
        $pet = Pet::find($id);
        if (!$pet) {
            return response()->json(['message' => 'Pet not found'], 404);
        }

        $authUser = auth()->user();
        if ($pet->UserID !== $authUser->UserID) { // Kiểm tra xem pet có phải của user hiện tại không
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $pet->update($request->only([
            'Name', 'Gender', 'FurColor', 'Species', 'Breed', 'BirthDate',
            'Weight', 'fur_type', 'origin', 'vaccinated', 'last_vaccine_date', 'trained'
        ]));

        return response()->json($pet);
    }

    public function destroy($id)
    {
        $pet = Pet::find($id);
        if (!$pet) {
            return response()->json(['message' => 'Pet not found'], 404);
        }

        // Kiểm tra user có quyền xóa pet này không
        $authUser = auth()->user();
        if ($pet->UserID !== $authUser->UserID) { // Kiểm tra quyền sở hữu pet
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Xóa các bản ghi liên quan (appointments, notes)
        Appointment::where('PetID', $id)->delete();
        $pet->notes()->delete();
        $pet->delete();

        return response()->json(['message' => 'Pet deleted']);
    }
}
