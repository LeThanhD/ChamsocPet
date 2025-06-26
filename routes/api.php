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

// 🔐 Đăng nhập
Route::post('/login', [UsersController::class, 'login'])->name('login');

// 👤 Đăng ký & quản lý người dùng
Route::prefix('/users')->controller(UsersController::class)->group(function () {
    Route::post('/', 'store');
    Route::get('/detail/{id}', 'getUserById');
    Route::get('/{page?}/{search?}', 'getList');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {                    
        Route::get('/all', 'index');  
     });
// 🌐 Dịch vụ chung (không cần auth)
Route::prefix('/services')->controller(ServiceController::class)->group(function () {
    Route::get('/all', 'index'); // cho mọi user
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
});

// 🌐 Khách hàng hoặc nhân viên (phải đăng nhập)
Route::middleware(['auth:sanctum'])->group(function () {

    // 🐾 Pets - khách hàng
    Route::prefix('/pets')->controller(PetController::class)->group(function () {
        Route::get('/', 'index'); 
        Route::get('/user/{userId}', 'getPetsByUser'); // khách lấy theo ID của mình
        Route::post('/', 'store'); // kiểm tra từ auth()->user()
    });

    // 📅 Appointments - khách hàng
    Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
        Route::post('/', 'store');                               
        Route::put('/{id}', 'update');// cập nhật
        Route::delete('/{id}', 'destroy'); // xoá thú cưng + lịch hẹn                  
    });

    // 💊 Medications - khách hàng chỉ xem
    Route::prefix('/medications')->controller(MedicationsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
    });
});

// 👨‍⚕️ Nhân viên
Route::middleware(['auth:sanctum', 'role:staff'])->group(function () {

    // 🐾 Pets - full quyền
    Route::prefix('/pets')->controller(PetController::class)->group(function () {
        Route::get('/', 'index');     // full list
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 📅 Lịch sử lịch hẹn
    Route::prefix('/appointment-history')->controller(AppointmentHistoryController::class)->group(function () {
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 📅 Appointments - staff
    Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
        Route::get('/', 'index');        // xem tất cả
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 💰 Hóa đơn
    Route::prefix('/invoices')->controller(InvoicesController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    Route::prefix('/invoice-details')->controller(InvoiceDetailController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 🏥 Lịch sử khám bệnh
    Route::prefix('/medical-histories')->controller(MedicalHistoryController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 📋 Hồ sơ bệnh án
    Route::prefix('/medical-records')->controller(MedicalRecordsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💊 Thuốc - thêm sửa xóa
    Route::prefix('/medications')->controller(MedicationsController::class)->group(function () {
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 📝 Ghi chú thú cưng
    Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'store');
        Route::put('/update-service', 'updateService');
    });

    // 📃 Đơn thuốc
    Route::prefix('/prescriptions')->controller(PrescriptionsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 📂 Danh mục dịch vụ
    Route::prefix('/service-categories')->controller(ServiceCategoriesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 🛠️ Dịch vụ
    Route::prefix('/services')->controller(ServiceController::class)->group(function () {
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 🧾 Nhật ký người dùng
    Route::prefix('/user-logs')->controller(UserLogsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💳 Phương thức thanh toán
    Route::prefix('/payment-methods')->controller(PaymentMethodController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 💵 Thanh toán
    Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });
});
