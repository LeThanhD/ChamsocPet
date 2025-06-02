<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PetController;
use App\Http\Controllers\AppointmentHistoryController;
use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\InvoiceController;
use App\Http\Controllers\InvoiceDetailController;
use App\Http\Controllers\MedicalHistoryController;
use App\Http\Controllers\MedicalRecordController;
use App\Http\Controllers\MedicationController;
use App\Http\Controllers\PetNoteController;
use App\Http\Controllers\PrescriptionController;
use App\Http\Controllers\ServiceCategoryController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\UserLogController;

// User Routes
Route::prefix('users')->controller(UserController::class)->group(function () {
    Route::post('/list', 'getList');
    Route::post('/create', 'store');
});

// Pet Routes
Route::prefix('pets')->controller(PetController::class)->group(function () {
    Route::post('/list', 'getList');
    Route::post('/create', 'store');
});

// Appointment History Routes
Route::prefix('appointment-history')->controller(AppointmentHistoryController::class)->group(function () {
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// Appointment Routes
Route::prefix('appointments')->controller(AppointmentController::class)->group(function () {
    Route::get('/', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// Invoice Routes
Route::prefix('invoices')->controller(InvoiceController::class)->group(function () {
    Route::get('/', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// Invoice Detail Routes
Route::prefix('invoice-details')->controller(InvoiceDetailController::class)->group(function () {
    Route::get('/', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// Medical History Routes
Route::prefix('medical-histories')->controller(MedicalHistoryController::class)->group(function () {
    Route::get('/', 'index');
    Route::post('/', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

// Medical Record Routes
Route::prefix('medical-records')->controller(MedicalRecordController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

// Medications Routes
Route::prefix('medications')->controller(MedicationController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

//PetNodes Routes
Route::prefix('pet-notes')->controller(PetNoteController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

//Prescriptions Routes
Route::prefix('prescriptions')->controller(PrescriptionController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

//ServiceCategory Routes
Route::prefix('service-categories')->controller(ServiceCategoryController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

//Service Routes
Route::prefix('services')->controller(ServiceController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});

//UsersLog Routes
Route::prefix('user-logs')->controller(UserLogController::class)->group(function () {
    Route::get('/', 'getList');
    Route::get('/{id}', 'getDetail');
    Route::post('/', 'create');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'delete');
});
