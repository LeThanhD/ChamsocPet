<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InvoiceDetail extends Model
{
    protected $table = 'InvoiceDetails';
    protected $primaryKey = 'DetailID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'InvoiceID',
        'ServiceID',
        'MedicationID',
        'Quantity',
        'UnitPrice'
    ];
}
