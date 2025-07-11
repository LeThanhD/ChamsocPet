<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   public function up()
{
    Schema::table('notifications', function (Blueprint $table) {
        $table->string('action')->nullable()->after('is_read');
        $table->json('action_data')->nullable()->after('action');
    });
}

public function down()
{
    Schema::table('notifications', function (Blueprint $table) {
        $table->dropColumn(['action', 'action_data']);
    });
}
};
