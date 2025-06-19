<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentMethod extends Model
{
    protected $table = 'PaymentMethods';
    protected $primaryKey = 'MethodID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = ['MethodID', 'MethodName'];
}
