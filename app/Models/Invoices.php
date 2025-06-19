<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Invoices extends Model
{
    protected $table = 'Invoices';
    protected $primaryKey = 'InvoiceID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PetID',
        'CreatedAt',
        'TotalAmount',
    ];
}
