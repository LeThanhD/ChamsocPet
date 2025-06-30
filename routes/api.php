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

// 🔐 Đăng nhập
Route::post('/login', [UsersController::class, 'login'])->name('login');
Route::post('/logout', [UsersController::class, 'logout']);

// 👤 Đăng ký & quản lý người dùng
Route::prefix('/users')->controller(UsersController::class)->group(function () {
    Route::post('/', 'store');
    Route::get('/detail/{id}', 'getUserById');
    Route::get('/{page?}/{search?}', 'getList');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
    Route::post('/send-reset-code', 'sendResetCode');
    Route::post('/reset-password', 'resetPassword');
    Route::post('/force-reset-password', 'forceResetPassword');
    Route::get('/staff',  'index');

});

Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
    Route::get('/every', 'getAllAppointmentsForStaff');
    Route::get('/all', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::put('/update-status/{id}', 'updateStatus');
    Route::delete('/{id}', 'destroy');
    Route::get('/check', 'checkConflict');
    Route::get('/check-all', 'getBookedTimes');

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
});

Route::prefix('/pets')->controller(PetController::class)->group(function () {
    Route::get('/all', 'getAllPetsForStaff');
    Route::delete('/{id}', 'destroy');
    Route::put('/{id}', 'update');
});

 Route::prefix('/notifications')->controller(NotificationController::class)->group(function () {
        Route::get('/', 'index');
        Route::put('/{id}/read', 'markAsRead');
        Route::delete('/{id}', 'destroy');
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
    Route::prefix('/notifications')->controller(NotificationController::class)->group(function () {
        Route::post('/', 'store');
    });

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
        Route::delete('/{id}', 'destroy');
        Route::put('/end/{id}', 'endAppointment');
    });

    Route::prefix('/invoices')->controller(InvoicesController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
        Route::get('/by-user', 'getByUser');
        Route::get('/{id}', 'show');
    });

    Route::prefix('/invoice-details')->controller(InvoiceDetailController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    Route::prefix('/medical-histories')->controller(MedicalHistoryController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    Route::prefix('/medical-records')->controller(MedicalRecordsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'store');
        Route::put('/update-service', 'updateService');
    });

    Route::prefix('/prescriptions')->controller(PrescriptionsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    Route::prefix('/service-categories')->controller(ServiceCategoriesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    Route::prefix('/user-logs')->controller(UserLogsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    Route::prefix('/payment-methods')->controller(PaymentMethodController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });
});
