<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PetNotes;
use Illuminate\Support\Facades\Validator;

class PetNotesController extends Controller
{
    public function getList()
    {
        $notes = PetNotes::with(['pet', 'user', 'service'])->get();
        return response()->json($notes);
    }

    public function getDetail($id)
    {
        $note = PetNotes::with(['pet', 'user', 'service'])->find($id);
        if (!$note) {
            return response()->json(['message' => 'Note not found'], 404);
        }
        return response()->json($note);
    }

    private function generateUniqueNoteID()
{
    return DB::transaction(function () {
        // Lock table để tránh tạo trùng trong quá trình song song
        DB::statement('LOCK TABLES PetNotes WRITE');

        // Lấy bản ghi có NoteID cao nhất
        $lastNote = PetNotes::orderByDesc(DB::raw('CAST(SUBSTRING(NoteID, 6) AS UNSIGNED)'))->first();

        $nextNumber = 1;
        if ($lastNote) {
            $lastNumber = (int)substr($lastNote->NoteID, 5);
            $nextNumber = $lastNumber + 1;
        }

        // Mã mới
        $newId = 'PNOTE' . str_pad($nextNumber, 5, '0', STR_PAD_LEFT);

        DB::statement('UNLOCK TABLES');

        return $newId;
    });
}

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID'     => 'required|exists:Pets,PetID',
            'Content'   => 'required|string',
            'CreatedAt' => 'required|date',
            'ServiceID' => 'required|exists:Services,ServiceID',
            'CreatedBy' => 'nullable|exists:Users,UserID'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $note = PetNotes::create([
            'NoteID'     => $this->generateUniqueNoteID(),
            'PetID'      => $request->PetID,
            'Content'    => $request->Content,
            'CreatedAt'  => $request->CreatedAt,
            'ServiceID'  => $request->ServiceID,
            'CreatedBy'  => $request->CreatedBy
        ]); 


        return response()->json(['message' => 'Note created', 'data' => $note], 201);
    }

    public function updateService(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID'     => 'required|exists:Pets,PetID',
            'ServiceID' => 'required|exists:Services,ServiceID',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $note = PetNotes::where('PetID', $request->PetID)
                        ->orderByDesc('CreatedAt')
                        ->first();

        if (!$note) {
            return response()->json(['message' => 'No note found for this pet'], 404);
        }

        $note->ServiceID = $request->ServiceID;
        $note->save();

        return response()->json(['message' => 'Service updated for pet note', 'data' => $note]);
    }
}
