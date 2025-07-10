<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PetNotes;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str; // ✅ Import thư viện Str

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

    // ✅ Hàm tạo NoteID không bị trùn
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PetID'     => 'required|exists:Pets,PetID',
            'Content'   => 'required|string',
            'ServiceID' => 'nullable|exists:Services,ServiceID',
            'CreatedAt' => 'nullable|date',
            'CreatedBy' => 'nullable|exists:Users,UserID'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $note = PetNotes::create([
            'NoteID'     => PetNotes::generateUniqueNoteID(),
            'PetID'      => $request->PetID,
            'Content'    => $request->Content,
            'ServiceID'  => $request->ServiceID ?? null,
            'CreatedAt'  => $request->CreatedAt ?? now(),
            'CreatedBy'  => $request->CreatedBy ?? auth()->id() ?? null
        ]);

        return response()->json([
            'message' => 'Note created',
            'data' => $note
        ], 201);
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

    public function destroy($id)
    {
        $note = PetNotes::find($id);

        if (!$note) {
            return response()->json(['message' => 'Note not found'], 404);
        }

        $note->delete();

        return response()->json(['message' => 'Note deleted successfully'], 200);
    }
}
