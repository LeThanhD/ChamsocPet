<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('services', function (Blueprint $table) {
            $table->string('ServiceID', 50)->primary();
            $table->string('ServiceName', 100);
            $table->text('Description')->nullable();
            $table->decimal('Price', 10, 2);
            $table->string('CategoryID', 50);

            $table->foreign('CategoryID')->references('CategoryID')->on('servicecategories')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('services');
    }
};
