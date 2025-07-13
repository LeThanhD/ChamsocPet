<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UsersController;
use App\Http\Controllers\PetController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\AppointmentHistoryController;
use App\Http\Controllers\InvoicesController;
use App\Http\Controllers\InvoiceDetailController;
use App\Http\Controllers\MedicalHistoryController;
use App\Http\Controllers\MedicalRecordsController;
use App\Http\Controllers\MedicationsController;
use App\Http\Controllers\PetNotesController;
use App\Http\Controllers\PrescriptionsController;
use App\Http\Controllers\ServiceCategoriesController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\UserLogsController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\OCRController;
use Illuminate\Http\Request;
use App\Models\Users;
use App\Http\Controllers\StatisticsController;



Route::get('/statistics', [StatisticsController::class, 'getStats']);

// 📸 Xử lý OCR hóa đơn từ ảnh (không cần đăng nhập)
Route::post('/ocr/extract', [OCRController::class, 'extractText']);

// 🔐 Đăng nhập
Route::get('/verify-email', [UsersController::class, 'verifyEmail']);
Route::post('/login', [UsersController::class, 'login'])->name('login');
Route::post('/logout', [UsersController::class, 'logout']);
Route::post('/check-email-verification', function (Request $request) {
    $user = Users::where('email', $request->email)->first();

    if (!$user) {
        return response()->json(['verified' => false, 'message' => 'Không tìm thấy người dùng'], 404);
    }

    return response()->json(['verified' => $user->hasVerifiedEmail()]);
});


// 👤 Đăng ký & quản lý người dùng
Route::prefix('/users')->controller(UsersController::class)->group(function () {
    Route::post('/', 'store');
    Route::get('/detail/{id}', 'getUserById');
    Route::get('/{page?}/{search?}', 'getList');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
    Route::post('/send-reset-code', 'sendResetCode');
    Route::post('/reset-password', 'resetPassword');
    Route::get('/statistics/TotalAmount/human', 'getSystemStatistics');
    Route::post('/force-reset-password', 'forceResetPassword');
    Route::get('/staff',  'index');
    Route::post('/update-token', 'updateToken');
    Route::get('/full/{id}/detail', 'getUserFullDetail');
    Route::get('/payment/history/total/Amount/{id}', 'getUserPaymentHistory');
    Route::get('/with/completed/appointments/all/histories', 'getUserWithCompletedAppointments');
});

Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
    Route::get('/every', 'getAllAppointmentsForStaff');
    Route::get('/all', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::put('/update-status/{id}', 'updateStatus');
    Route::get('/services', 'fetchServices');
    Route::get('/get-service-name', 'getServiceName');
    Route::delete('/{id}', 'destroy');
    Route::get('/check', 'checkConflict');
    Route::get('/check-all', 'checkAll');
    Route::put('/update-service/{id}', 'updateService');
    Route::get('/check-staff-availability', 'checkStaffAvailability');
    Route::get('/suggested-services', 'getSuggestedServicesByUser');
    Route::get('/{id}', 'show');
    Route::get('/services/by-species', 'fetchServicesBySpecies');
    Route::get('/staff/booked/slots',  'getAllBookedSlots');
    Route::get('/unseen/count', 'countUnseenAppointments');
    Route::post('/mark-seen/{id}', 'markAppointmentAsSeen');
    Route::get('/{id}/medications', 'getMedicationsByAppointment');
    Route::post('/{id}/medications/update', 'updateMedications');
});

Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
        Route::put('/confirm-payment/{id}', 'confirmPayment');
        Route::post('/mark-as-paid/{id}',  'markAsPaid');
        Route::get('/pending', 'getPendingPayments');
        Route::get('/check-paid', 'checkInvoicePaid');
        // Route::post('approve/{id}', 'approve');
        Route::put('/{id}/status',  'updateStatus');
        Route::get('/{id}', 'show');
    });
    
 Route::prefix('/invoices')->controller(InvoicesController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
        Route::get('/by-user', 'getByUser');
        Route::get('/{id}', 'show');
    });

// 🌐 Dịch vụ chung
Route::prefix('/services')->controller(ServiceController::class)->group(function () {
    Route::get('/all', 'index');
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
});

Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
    Route::delete('/{id}', 'destroy');
});

Route::prefix('/medications')->controller(MedicationsController::class)->group(function () {
    Route::post('/', 'create');
    Route::delete('/{id}', 'delete');
    Route::put('/{id}', 'update');
    Route::get('/in', 'index');
});

Route::prefix('/pets')->controller(PetController::class)->group(function () {
    Route::get('/all', 'getAllPetsForStaff');
    Route::delete('/{id}', 'destroy');
    Route::put('/{id}', 'update');
    Route::get('/{id}','show');
    Route::get('/{id}/used-services-medications',  'getPetUsedServicesAndMedications');
    Route::get('/accines/{id}', 'getPetVaccines');
    Route::get('/vaccines/all', 'getAllVaccines');
    Route::get('/detail/{id}/all',  'getPetDetailWithVaccines');
});

    Route::prefix('/notifications')->controller(NotificationController::class)->group(function () {
        Route::get('/', 'index');                    
        Route::post('/', 'store');                  
        Route::post('/send/{userId}', 'send');       
        Route::put('/{id}/read', 'markAsRead');     
        Route::delete('/{id}', 'destroy');    
        Route::get('/{user_id}', 'getUserNotifications');
        Route::get('unread-count', 'unreadCount');
        Route::delete('/clear', 'clearAll');

    });


Route::prefix('/appointment-history')->controller(AppointmentHistoryController::class)->group(function () {
    Route::get('/all', 'getAllHistories');
    Route::get('/', 'getUserHistories');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// ✨ Khách hàng hoặc nhân viên (auth)
Route::middleware(['auth:sanctum'])->group(function () {

    Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
        Route::post('approve/{id}', 'approve');
    });
    
    Route::prefix('/pets')->controller(PetController::class)->group(function () {
        Route::get('/', 'index');
        Route::get('/user/{userId}', 'getPetsByUser');
        Route::post('/', 'store');
    });

    
    Route::prefix('/medications')->controller(MedicationsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
    });
});

// 👨‍⚕️ Nhân viên
Route::middleware(['auth:sanctum', 'role:staff'])->group(function () {
    // Route::prefix('/notifications')->controller(NotificationController::class)->group(function () {
        
    // });

    Route::prefix('/medications')->controller(MedicationsController::class)->group(function () {
        Route::put('/{id}', 'update');
    });

    Route::prefix('/services')->controller(ServiceController::class)->group(function () {
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    Route::prefix('/pets')->controller(PetController::class)->group(function () {
        Route::get('/', 'index');
    });

    Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
        Route::get('/', 'index');
        Route::put('/{id}', 'update');
        Route::put('/end/{id}', 'endAppointment');
        Route::post('/{id}/approve', 'approve');
    });

    Route::prefix('/invoice-details')->controller(InvoiceDetailController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'store');
        Route::put('/update-service', 'updateService');
    });

    Route::prefix('/service-categories')->controller(ServiceCategoriesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });
});
