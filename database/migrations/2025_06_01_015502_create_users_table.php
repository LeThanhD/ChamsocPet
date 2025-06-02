<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->string('UserID')->primary();
            $table->string('Username')->unique();
            $table->string('PasswordHash');
            $table->string('FullName');
            $table->boolean('Gender')->nullable();
            $table->date('BirthDate')->nullable();
            $table->string('Phone', 20)->nullable();
            $table->text('Address')->nullable();
            $table->string('Email')->unique();
            $table->string('NationalID', 20)->nullable();
            $table->string('ProfilePicture')->nullable();
            $table->enum('Role', ['staff', 'owner'])->default('staff');
            $table->enum('Status', ['active', 'inactive', 'banned'])->default('active');
            $table->timestamp('CreatedAt')->useCurrent();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
