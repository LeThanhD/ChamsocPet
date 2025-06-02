<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('medications', function (Blueprint $table) {
        $table->string('MedicationID')->primary();
        $table->string('Name', 100);
        $table->text('UsageInstructions')->nullable();
        $table->integer('Quantity')->default(0);
        $table->string('Unit', 20);
        $table->timestamps();
    });
}

    public function down(): void
    {
        Schema::dropIfExists('medications');
    }
};
