<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAppointmentServiceTable extends Migration
{
    public function up()
    {
        Schema::create('appointment_service', function (Blueprint $table) {
            $table->id(); // Tạo trường ID tự động
            $table->foreignId('appointment_id')  // Tạo khoá ngoại cho bảng appointments
                  ->constrained('appointments')  // Liên kết với bảng appointments
                  ->onDelete('cascade');  // Khi xóa appointment thì xóa bản ghi này
            $table->foreignId('service_id')  // Tạo khoá ngoại cho bảng services
                  ->constrained('services')  // Liên kết với bảng services
                  ->onDelete('cascade');  // Khi xóa service thì xóa bản ghi này
            $table->timestamps();  // Tạo cột created_at và updated_at
        });
    }

    public function down()
    {
        Schema::dropIfExists('appointment_service');  // Xóa bảng pivot
    }
}
