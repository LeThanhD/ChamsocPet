<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('InvoiceDetails', function (Blueprint $table) {
            $table->string('DetailID', 50)->primary(); // Trigger sinh
            $table->string('InvoiceID', 50);
            $table->string('ServiceID', 50)->nullable();
            $table->string('MedicationID', 50)->nullable();
            $table->integer('Quantity')->default(1);
            $table->decimal('UnitPrice', 10, 2);

            $table->foreign('InvoiceID')->references('InvoiceID')->on('Invoices')->onDelete('cascade');
            $table->foreign('ServiceID')->references('ServiceID')->on('Services')->onDelete('set null');
            $table->foreign('MedicationID')->references('MedicationID')->on('Medications')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('InvoiceDetails');
    }
};