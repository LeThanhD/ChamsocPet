<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use Illuminate\Support\Facades\URL;
use Carbon\Carbon;
use App\Services\FirebaseService;
use App\Models\Users;

class PaymentController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        $role = strtolower($request->query('role'));

        if (!$userId || !$role) {
            return response()->json(['error' => 'Thiếu thông tin người dùng'], 400);
        }

        $query = Payment::query();

        if ($role !== 'staff') {
            $query->where('UserID', $userId);
        }

        $payments = $query->orderBy('PaymentTime', 'desc')->get();

        $result = $payments->map(function ($payment) {
            return [
                'PaymentID' => $payment->PaymentID,
                'InvoiceID' => $payment->InvoiceID,
                'PaidAmount' => $payment->PaidAmount,
                'Note' => $payment->Note,
                'PaymentTime' => $payment->PaymentTime,
                'status' => $payment->status,
            ];
        });

        return response()->json($result);
    }

    public function store(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1000',
            'description' => 'nullable|string|max:255',
            'invoice_id' => 'nullable|string',
            'user_id' => 'required|string',
        ]);

        $datePart = Carbon::now()->format('Ymd');
        $lastPayment = Payment::where('PaymentID', 'like', "PAY-$datePart-%")
            ->orderByDesc('PaymentID')
            ->first();

        $nextNumber = $lastPayment ? ((int) substr($lastPayment->PaymentID, -4)) + 1 : 1;
        $customId = sprintf("PAY-%s-%04d", $datePart, $nextNumber);

        $payment = Payment::create([
            'PaymentID' => $customId,
            'InvoiceID' => $request->input('invoice_id'),
            'PaidAmount' => $request->input('amount'),
            'Note' => $request->input('description', 'Thanh toán không ghi chú'),
            'PaymentTime' => now(),
            'status' => 'chờ duyệt',
            'UserID' => $request->input('user_id'),
        ]);

        $momoNumber = '0336414465';
        $momoName = 'Le Thi Truc Mai';
        $paymentNote = "Thanh toan ma don #{$payment->PaymentID}";
        $qrCodeUrl = URL::to('storage/images/image.png');
        $paymentUrl = "https://nhantien.momo.vn/$momoNumber?amount={$payment->PaidAmount}&note=" . urlencode($paymentNote);

        return response()->json([
            'payment' => [
                'PaymentID' => $payment->PaymentID,
                'InvoiceID' => $payment->InvoiceID,
                'PaidAmount' => $payment->PaidAmount,
                'Note' => $payment->Note,
                'PaymentTime' => $payment->PaymentTime,
                'status' => $payment->status,
            ],
            'momo_number' => $momoNumber,
            'momo_name' => $momoName,
            'payment_note' => $paymentNote,
            'qr_code_url' => $qrCodeUrl,
            'payment_url' => $paymentUrl,
        ], 201);
    }

    public function confirmPayment($id)
    {
        $payment = Payment::where('PaymentID', $id)->firstOrFail();

        if ($payment->status !== 'chờ duyệt') {
            return response()->json(['message' => 'Thanh toán không ở trạng thái chờ duyệt'], 400);
        }

        return response()->json([
            'message' => 'Đã ghi nhận yêu cầu chờ duyệt',
            'payment' => [
                'PaymentID' => $payment->PaymentID,
                'PaidAmount' => $payment->PaidAmount,
                'Note' => $payment->Note,
                'PaymentTime' => $payment->PaymentTime,
                'status' => $payment->status,
            ]
        ]);
    }

    // Đổi tên từ checkPaid thành checkInvoicePaid
    public function checkInvoicePaid(Request $request)
    {
        $invoiceId = $request->query('invoice_id');

        if (!$invoiceId) {
            return response()->json(['error' => 'Thiếu invoice_id'], 400);
        }

        $payments = Payment::where('InvoiceID', $invoiceId)->get();

        return response()->json($payments);
    }


    public function approve($id)
    {
        try {
            // Tìm đơn thanh toán
            $payment = Payment::where('PaymentID', $id)->first();

            if (!$payment) {
                return response()->json([
                    'message' => 'Không tìm thấy đơn thanh toán'
                ], 404);
            }

            // Kiểm tra trạng thái
            if (strtolower($payment->status) === 'đã duyệt') {
                return response()->json([
                    'message' => 'Đơn thanh toán này đã được duyệt trước đó.'
                ], 409); // Conflict
            }

            // ✅ Cập nhật trạng thái
            $payment->status = 'đã duyệt';
            $payment->user_confirmed = 1;
            $payment->save();

            // ✅ Lấy user thanh toán
            $userId = $payment->UserID ?? $payment->user_id;
            $user = Users::where('UserID', $userId)->first();
            if (!$user) {
                return response()->json(['message' => 'Không tìm thấy người dùng liên quan'], 404);
            }

            // ✅ Chuẩn bị nội dung thông báo
            $title = 'Thanh toán thành công';
            $message = "Đơn thanh toán #{$payment->PaymentID} đã được duyệt vào lúc " . now()->format('H:i d/m/Y');

            // ✅ Gửi thông báo FCM
            if ($user->fcm_token) {
                $firebase = app(FirebaseService::class);
                $firebase->sendNotification($user->fcm_token, $title, $message);
            }

            // ✅ Gửi và lưu vào DB qua controller
            $notificationController = app(NotificationController::class);
            $notificationController->send($userId, $message);

            return response()->json([
                'message' => '✅ Thanh toán đã được duyệt',
                'payment' => [
                    'PaymentID' => $payment->PaymentID,
                    'PaidAmount' => $payment->PaidAmount,
                    'Note' => $payment->Note,
                    'PaymentTime' => $payment->PaymentTime,
                    'status' => $payment->status,
                ]
            ], 200);
        } catch (\Throwable $e) {
            \Log::error("❌ Lỗi duyệt thanh toán: " . $e->getMessage());

            return response()->json([
                'message' => 'Lỗi xử lý: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getStatus($id)
    {
        $payment = Payment::where('PaymentID', $id)->firstOrFail();
        return response()->json(['status' => $payment->status]);
    }

    public function update($id, Request $request)
    {
        $payment = Payment::where('PaymentID', $id)->firstOrFail();
        $payment->update($request->all());

        return response()->json([
            'PaymentID' => $payment->PaymentID,
            'PaidAmount' => $payment->PaidAmount,
            'Note' => $payment->Note,
            'status' => $payment->status,
        ]);
    }

    public function show($id)
    {
        $payment = Payment::where('PaymentID', $id)->first();

        if (!$payment) {
            return response()->json(['message' => 'Không tìm thấy thanh toán'], 404);
        }

        return response()->json([
            'payment' => [
                'PaymentID' => $payment->PaymentID,
                'InvoiceID' => $payment->InvoiceID,
                'PaidAmount' => $payment->PaidAmount,
                'Note' => $payment->Note,
                'PaymentTime' => $payment->PaymentTime,
                'status' => $payment->status,
                'UserID' => $payment->UserID,
            ]
        ]);
    }



    public function destroy($id)
    {
        Payment::where('PaymentID', $id)->delete();
        return response()->json(['message' => 'Deleted']);
    }
}