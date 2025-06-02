
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('Appointments', function (Blueprint $table) {
            $table->string('AppointmentID', 50)->primary(); // Được trigger sinh tự động
            $table->string('PetID', 100);
            $table->string('UserID', 50);
            $table->date('AppointmentDate');
            $table->time('AppointmentTime');
            $table->text('Reason');
            $table->string('Status', 50);

            $table->foreign('PetID')->references('PetID')->on('Pets')->onDelete('cascade');
            $table->foreign('UserID')->references('UserID')->on('Users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Appointments');
    }
};
