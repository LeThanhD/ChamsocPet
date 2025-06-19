<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Controllers
use App\Http\Controllers\UsersController;
use App\Http\Controllers\PetController;
use App\Http\Controllers\AppointmentHistoryController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\InvoicesController;
use App\Http\Controllers\InvoiceDetailController;
use App\Http\Controllers\MedicalHistoryController;
use App\Http\Controllers\MedicalRecordsController;
use App\Http\Controllers\MedicationController;
use App\Http\Controllers\PetNotesController;
use App\Http\Controllers\PrescriptionsController;
use App\Http\Controllers\ServiceCategoriesController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\UserLogsController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentController;

// ✅ Public routes (không cần token)

Route::post('/login', [UsersController::class, 'login'])->name('login');
Route::post('/users', [UsersController::class, 'store']);

// ✅ Protected routes (cần token Sanctum)

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user-profile', function (Request $request) {
        return response()->json([
            'message' => 'Dữ liệu bảo vệ thành công',
            'user' => $request->user()
        ]);
    });

    Route::post('/logout', [UsersController::class, 'logout']);

    // 🧑‍💼 User routes (sau khi đăng nhập)
    Route::prefix('/users')->controller(UsersController::class)->group(function () {
        Route::get('/{page?}/{search?}', 'getList');   
        Route::put('/{id}', 'update');                
        Route::delete('/{id}', 'destroy');          
    });

    // 🐶 Pet routes
    Route::prefix('/pets')->controller(PetController::class)->group(function () {
        Route::get('/list', 'getList');
        Route::post('/create', 'store');
    });

    // 📅 Appointment history routes
    Route::prefix('/appointment-history')->controller(AppointmentHistoryController::class)->group(function () {
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 🗓 Appointment routes
    Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 🧾 Invoice routes
    Route::prefix('/invoices')->controller(InvoicesController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 🧾 Invoice detail routes
    Route::prefix('/invoice-details')->controller(InvoiceDetailController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 📖 Medical history
    Route::prefix('/medical-histories')->controller(MedicalHistoryController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 📋 Medical records
    Route::prefix('/medical-records')->controller(MedicalRecordsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💊 Medications
    Route::prefix('/medications')->controller(MedicationController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 📒 Pet notes
    Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💊 Prescriptions
    Route::prefix('/prescriptions')->controller(PrescriptionsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 🧾 Service Categories
    Route::prefix('/service-categories')->controller(ServiceCategoriesController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💼 Services
    Route::prefix('/services')->controller(ServiceController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 📓 User Logs
    Route::prefix('/user-logs')->controller(UserLogsController::class)->group(function () {
        Route::get('/', 'getList');
        Route::get('/{id}', 'getDetail');
        Route::post('/', 'create');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'delete');
    });

    // 💳 Payment Methods
    Route::prefix('/payment-methods')->controller(PaymentMethodController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });

    // 💰 Payments
    Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::put('/{id}', 'update');
        Route::delete('/{id}', 'destroy');
    });
});
