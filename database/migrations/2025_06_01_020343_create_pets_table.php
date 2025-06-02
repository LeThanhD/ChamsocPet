<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('pets', function (Blueprint $table) {
            $table->string('PetID')->primary();
            $table->string('Name');
            $table->string('Species');
            $table->string('Breed');
            $table->date('BirthDate')->nullable();
            $table->string('Gender', 10)->nullable();
            $table->decimal('Weight', 5, 2)->nullable();
            $table->string('FurColor')->nullable();
            $table->string('UserID');
            $table->foreign('UserID')->references('UserID')->on('users');
        });
    }

    public function down()
    {
        Schema::dropIfExists('pets');
    }
};
