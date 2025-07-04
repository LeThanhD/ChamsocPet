<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('status')->default('pending'); // Thêm cột 'status'
        });
    }   

    public function down()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn('status'); // Xóa cột 'status' nếu rollback migration
        });
    }

};
