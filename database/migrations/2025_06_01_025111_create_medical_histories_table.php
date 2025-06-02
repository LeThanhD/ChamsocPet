<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('MedicalHistory', function (Blueprint $table) {
            $table->string('HistoryID', 50)->primary(); // Trigger tự động sinh
            $table->string('PetID', 100);
            $table->dateTime('VisitDate');
            $table->text('Symptoms')->nullable();
            $table->text('Diagnosis')->nullable();
            $table->text('Treatment')->nullable();
            $table->text('Notes')->nullable();
            $table->string('UserID', 50);

            $table->foreign('PetID')->references('PetID')->on('Pets')->onDelete('cascade');
            $table->foreign('UserID')->references('UserID')->on('Users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('MedicalHistory');
    }
};
