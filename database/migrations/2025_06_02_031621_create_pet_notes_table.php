<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('petnotes', function (Blueprint $table) {
        $table->string('NoteID')->primary();
        $table->string('PetID');
        $table->string('CreatedBy');
        $table->dateTime('CreatedAt')->nullable();
        $table->text('Content');
        $table->string('ServiceID')->nullable();

        $table->foreign('PetID')->references('PetID')->on('pets');
        $table->foreign('CreatedBy')->references('UserID')->on('users');
        $table->foreign('ServiceID')->references('ServiceID')->on('services');
    });
}

    public function down(): void
    {
        Schema::dropIfExists('pet_notes');
    }
};
