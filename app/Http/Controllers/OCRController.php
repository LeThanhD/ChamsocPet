<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use thiagoalessio\TesseractOCR\TesseractOCR;

class OCRController extends Controller
{
    /**
     * Nhận ảnh từ client, trích xuất nội dung chuyển khoản
     */
    public function extractText(Request $request)
    {
        // 1. Kiểm tra đầu vào là hình ảnh
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:5120',
        ]);

        // 2. Lưu ảnh vào storage/public/ocr_uploads
        $path = $request->file('image')->store('ocr_uploads', 'public');
        $imagePath = storage_path("app/public/{$path}");

        // 3. Gọi Tesseract để nhận diện văn bản
        try {
            $text = (new TesseractOCR($imagePath))
                ->lang('eng+vie') // hỗ trợ tiếng Anh + Việt
                ->run();
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Không thể nhận dạng văn bản từ ảnh.',
                'exception' => $e->getMessage()
            ], 500);
        }

        // 4. Trích xuất thông tin từ text
        $matchTransactionId = null;
        $matchAmount = null;

        // Ví dụ trích mã giao dịch (có thể cần điều chỉnh regex tùy ngân hàng)
        if (preg_match('/(Mã giao dịch|Transaction ID)[^\w]*([A-Z0-9]{6,})/i', $text, $matches)) {
            $matchTransactionId = $matches[2];
        }

        // Ví dụ trích số tiền (dạng 1.000.000 hoặc 1,000,000)
        if (preg_match('/(Số tiền|Amount)[^\d]*([\d\.,]+)/i', $text, $matches)) {
            $matchAmount = $matches[2];
        }

        // 5. Trả kết quả về client
        return response()->json([
            'success' => true,
            'text' => $text,
            'transaction_id' => $matchTransactionId,
            'amount' => $matchAmount,
            'image_url' => asset("storage/{$path}"),
        ]);
    }
}
