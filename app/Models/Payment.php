<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $table = 'Payments';
    protected $primaryKey = 'PaymentID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PaymentID', 'InvoiceID', 'MethodID', 'PaidAmount', 'PaymentTime', 'Note'
    ];
}
