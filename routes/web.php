<!-- <?php 

// use Illuminate\Support\Facades\Route;
// use App\Http\Controllers\UsersController;
// use App\Http\Controllers\PetController;
// use App\Http\Controllers\AppointmentHistoryController;
// use App\Http\Controllers\AppointmentController;
// use App\Http\Controllers\InvoicesController;
// use App\Http\Controllers\InvoiceDetailController;
// use App\Http\Controllers\MedicalHistoryController;
// use App\Http\Controllers\MedicalRecordsController;
// use App\Http\Controllers\MedicationController;
// use App\Http\Controllers\PetNotesController;
// use App\Http\Controllers\PrescriptionsController;
// use App\Http\Controllers\ServiceCategoriesController;
// use App\Http\Controllers\ServiceController;
// use App\Http\Controllers\UserLogsController;
// use App\Http\Controllers\PaymentMethodController;
// use App\Http\Controllers\PaymentController;



// Route::prefix('/api')->group(function(){
//     Route::prefix('/users')->controller(UsersController::class)->group(function () {
//         Route::get('/{page?}/{search?}', 'getList');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Pet Routes
//     Route::prefix('/pets')->controller(PetController::class)->group(function () {
//         Route::get('/list', 'getList');
//         Route::post('/create', 'store');
//     });

//     // Appointment History Routes
//     Route::prefix('/appointment-history')->controller(AppointmentHistoryController::class)->group(function () {
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Appointment Routes
//     Route::prefix('/appointments')->controller(AppointmentController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Invoice Routes
//     Route::prefix('/invoices')->controller(InvoicesController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Invoice Detail Routes
//     Route::prefix('/invoice-details')->controller(InvoiceDetailController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Medical History Routes
//     Route::prefix('/medical-histories')->controller(MedicalHistoryController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Medical Record Routes
//     Route::prefix('/medical-records')->controller(MedicalRecordsController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     // Medications Routes
//     Route::prefix('/medications')->controller(MedicationController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //PetNodes Routes
//     Route::prefix('/pet-notes')->controller(PetNotesController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //Prescriptions Routes
//     Route::prefix('/prescriptions')->controller(PrescriptionsController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //ServiceCategory Routes
//     Route::prefix('/service-categories')->controller(ServiceCategoriesController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //Service Routes
//     Route::prefix('/services')->controller(ServiceController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //UsersLog Routes
//     Route::prefix('/user-logs')->controller(UserLogsController::class)->group(function () {
//         Route::get('/', 'getList');
//         Route::get('/{id}', 'getDetail');
//         Route::post('/', 'create');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'delete');
//     });

//     //PayMethod Routes
//     Route::prefix('/payment-methods')->controller(PaymentMethodController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });

//     // Payments Routes
//     Route::prefix('/payments')->controller(PaymentController::class)->group(function () {
//         Route::get('/', 'index');
//         Route::post('/', 'store');
//         Route::put('/{id}', 'update');
//         Route::delete('/{id}', 'destroy');
//     });
// });

