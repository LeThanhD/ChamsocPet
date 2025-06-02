<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('Invoices', function (Blueprint $table) {
            $table->string('InvoiceID', 50)->primary(); // Trigger sinh tự động
            $table->string('PetID', 100);
            $table->dateTime('CreatedAt')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->decimal('TotalAmount', 10, 2);

            $table->foreign('PetID')->references('PetID')->on('Pets')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Invoices');
    }
};
