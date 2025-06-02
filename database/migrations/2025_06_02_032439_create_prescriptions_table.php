<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   public function up(): void
{
    Schema::create('prescriptions', function (Blueprint $table) {
        $table->string('PrescriptionID')->primary();
        $table->string('RecordID');
        $table->string('MedicationID');
        $table->string('Dosage', 100)->nullable();
        $table->string('Frequency', 100)->nullable();
        $table->string('Duration', 100)->nullable();

        $table->foreign('RecordID')->references('RecordID')->on('medicalrecords');
        $table->foreign('MedicationID')->references('MedicationID')->on('medications');
    });
}

    public function down(): void
    {
        Schema::dropIfExists('prescriptions');
    }
};
