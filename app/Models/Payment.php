<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $table = 'payments';
    protected $primaryKey = 'PaymentID';
     public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
    'PaymentID',
    'InvoiceID',
    'PaidAmount',
    'Note',
    'PaymentTime',
    'status',
    'user_confirmed',
    'UserID'
];

public function user()
{
    return $this->belongsTo(User::class, 'UserID', 'UserID');
}


}
