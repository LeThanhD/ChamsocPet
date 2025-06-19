<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PetNotes;

class PetNotesController extends Controller
{
    function getList(Request $request)
    {
        $data = $request->all();
        $data['search'] = $data['search'] ?? '';
        $data['page'] = $data['page'] ?? 1;

        try {
            $list = PetNotes::where('Content', 'like', '%' . $data['search'] . '%')
                ->offset(($data['page'] - 1) * 10)
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách ghi chú thành công!',
                'data' => $list
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi lấy danh sách: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    function getDetail($id)
    {
        try {
            $note = PetNotes::findOrFail($id);
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết ghi chú thành công!',
                'data' => $note
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy ghi chú: ' . $e->getMessage(),
                'data' => null
            ], 404);
        }
    }

    function create(Request $request)
    {
        try {
            $request->validate([
                'PetID' => 'required|exists:pets,PetID',
                'CreatedBy' => 'required|exists:users,UserID',
                'Content' => 'required|string',
                'ServiceID' => 'nullable|exists:services,ServiceID',
            ]);

            $count = PetNotes::count();
            $noteId = 'PNOTE' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);

            $note = PetNotes::create([
                'NoteID' => $noteId,
                'PetID' => $request->PetID,
                'CreatedBy' => $request->CreatedBy,
                'Content' => $request->Content,
                'CreatedAt' => now(),
                'ServiceID' => $request->ServiceID,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tạo ghi chú thành công!',
                'data' => $note
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tạo ghi chú: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function update(Request $request, $id)
    {
        try {
            $note = PetNotes::findOrFail($id);
            $note->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật ghi chú thành công!',
                'data' => $note
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi cập nhật: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    function delete($id)
    {
        try {
            $note = PetNotes::findOrFail($id);
            $note->delete();

            return response()->json([
                'success' => true,
                'message' => 'Xóa ghi chú thành công!',
                'data' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi xóa: ' . $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
