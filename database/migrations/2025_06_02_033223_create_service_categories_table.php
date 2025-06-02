<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('servicecategories', function (Blueprint $table) {
        $table->string('CategoryID')->primary();
        $table->string('CategoryName', 100);
    });
}

    public function down(): void
    {
        Schema::dropIfExists('service_categories');
    }
};
