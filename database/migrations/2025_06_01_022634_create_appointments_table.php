<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
               Schema::create('appointmenthistory', function (Blueprint $table) {
    $table->string('HistoryID', 50)->primary();
    $table->string('AppointmentID', 50);
    $table->dateTime('UpdatedAt')->default(DB::raw('CURRENT_TIMESTAMP'));
    $table->string('StatusBefore', 50);
    $table->string('StatusAfter', 50);
    $table->text('Note')->nullable();

    // Tạo foreign key
    $table->foreign('AppointmentID')->references('AppointmentID')->on('appointments');
});
    }

    public function down(): void
    {
        Schema::dropIfExists('AppointmentHistory');
    }
};