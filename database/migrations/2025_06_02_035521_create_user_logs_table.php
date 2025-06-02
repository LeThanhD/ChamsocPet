<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_logs', function (Blueprint $table) {
            $table->string('LogID', 50)->primary();
            $table->string('UserID', 50);
            $table->string('ActionType', 50);
            $table->text('ActionDetail')->nullable();
            $table->dateTime('ActionTime')->default(DB::raw('CURRENT_TIMESTAMP'));

            $table->foreign('UserID')->references('UserID')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_logs');
    }
};
