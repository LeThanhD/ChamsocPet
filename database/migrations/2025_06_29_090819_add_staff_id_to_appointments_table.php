<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('appointments', function (Blueprint $table) {
            $table->unsignedBigInteger('staff_id')->nullable()->after('UserID');

            // Giả sử bảng users có cột id là khóa chính
            $table->foreign('staff_id')->references('id')->on('users')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('appointments', function (Blueprint $table) {
            $table->unsignedBigInteger('staff_id')->nullable(); // KHỚP với users.id
            $table->foreign('staff_id')->references('id')->on('users')->onDelete('set null');
        });

    }
};

