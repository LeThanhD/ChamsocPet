<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateRoleLengthInUsersTable extends Migration
{
    public function up()
    {
        Schema::table('Users', function (Blueprint $table) {
            $table->string('Role', 20)->change();
        });
    }

    public function down()
    {
        Schema::table('Users', function (Blueprint $table) {
            $table->string('Role', 5)->change(); // nếu trước đó là 5 ký tự
        });
    }
}
