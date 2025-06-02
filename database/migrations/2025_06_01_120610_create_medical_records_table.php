<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medical_records', function (Blueprint $table) {
            $table->string('RecordID')->primary();
            $table->string('PetID');
            $table->string('UserID');
            $table->text('Diagnosis')->nullable();
            $table->text('Treatment')->nullable();
            $table->dateTime('RecordDate')->nullable();
            $table->timestamps();

            $table->foreign('PetID')->references('PetID')->on('pets');
            $table->foreign('UserID')->references('UserID')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_records');
    }
};
